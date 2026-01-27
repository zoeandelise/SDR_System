-- ================================
-- 扩展用户健康表结构 - 添加算法所需关键字段（兼容MySQL 5.7+）
-- ================================
-- 执行说明：
-- 1. 执行前请备份sys_user_health表数据
-- 2. 兼容MySQL 5.7+版本
-- 3. 执行时间约5-10秒
-- ================================

USE smart_diet_dev;

-- 检查表是否存在
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✓ sys_user_health表存在，开始扩展字段' ELSE '✗ 表不存在，请先创建基础表' END AS '检查结果'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smart_diet_dev' AND TABLE_NAME = 'sys_user_health';

-- 添加所有字段（使用存储过程方式）
DELIMITER $$

DROP PROCEDURE IF EXISTS add_user_health_columns$$

CREATE PROCEDURE add_user_health_columns()
BEGIN
    -- BMI字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='bmi') THEN
        ALTER TABLE sys_user_health ADD COLUMN bmi DECIMAL(5,2) DEFAULT NULL 
        COMMENT 'BMI体质指数(计算字段:weight/POWER(height/100,2),<18.5偏瘦,18.5-24正常,24-28超重,≥28肥胖)';
    END IF;
    
    -- BMR字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='bmr') THEN
        ALTER TABLE sys_user_health ADD COLUMN bmr INT DEFAULT NULL 
        COMMENT '基础代谢率BMR(kcal/天,根据Harris-Benedict公式计算,用于每日热量目标设定)';
    END IF;
    
    -- diet_preferences字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='diet_preferences') THEN
        ALTER TABLE sys_user_health ADD COLUMN diet_preferences VARCHAR(500) DEFAULT NULL 
        COMMENT '饮食偏好标签(JSON数组,如["vegetarian","low_sugar","halal","low_salt","high_protein"])';
    END IF;
    
    -- food_dislikes字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='food_dislikes') THEN
        ALTER TABLE sys_user_health ADD COLUMN food_dislikes VARCHAR(1000) DEFAULT NULL 
        COMMENT '不喜欢的食材列表(JSON数组,如["broccoli","cilantro","durian"],用于推荐过滤)';
    END IF;
    
    -- recommendation_strategy字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='recommendation_strategy') THEN
        ALTER TABLE sys_user_health ADD COLUMN recommendation_strategy VARCHAR(50) DEFAULT 'balanced' 
        COMMENT '推荐策略偏好(balanced:营养均衡,health:健康优先,taste:口味优先,variety:多样性)';
    END IF;
    
    -- diet_restriction_level字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='diet_restriction_level') THEN
        ALTER TABLE sys_user_health ADD COLUMN diet_restriction_level VARCHAR(20) DEFAULT 'moderate' 
        COMMENT '饮食限制强度(strict:严格遵循,moderate:适中,flexible:灵活提示)';
    END IF;
    
    -- profile_generated_time字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='profile_generated_time') THEN
        ALTER TABLE sys_user_health ADD COLUMN profile_generated_time DATETIME DEFAULT NULL 
        COMMENT '用户画像生成时间(用于标记画像数据的时效性)';
    END IF;
    
    -- daily_protein_goal字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='daily_protein_goal') THEN
        ALTER TABLE sys_user_health ADD COLUMN daily_protein_goal DECIMAL(6,2) DEFAULT NULL 
        COMMENT '每日蛋白质目标(g/天,推荐1.2-1.5g/kg体重,根据活动量调整)';
    END IF;
    
    -- daily_carb_goal字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='daily_carb_goal') THEN
        ALTER TABLE sys_user_health ADD COLUMN daily_carb_goal DECIMAL(6,2) DEFAULT NULL 
        COMMENT '每日碳水化合物目标(g/天,推荐占总热量50-65%)';
    END IF;
    
    -- daily_fat_goal字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='daily_fat_goal') THEN
        ALTER TABLE sys_user_health ADD COLUMN daily_fat_goal DECIMAL(6,2) DEFAULT NULL 
        COMMENT '每日脂肪目标(g/天,推荐占总热量20-30%)';
    END IF;
    
    -- disease_severity字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='disease_severity') THEN
        ALTER TABLE sys_user_health ADD COLUMN disease_severity VARCHAR(20) DEFAULT NULL 
        COMMENT '慢性病严重程度(mild:轻度,moderate:中度,severe:重度,用于调整饮食限制强度)';
    END IF;
    
    -- last_checkup_date字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='sys_user_health' AND COLUMN_NAME='last_checkup_date') THEN
        ALTER TABLE sys_user_health ADD COLUMN last_checkup_date DATE DEFAULT NULL 
        COMMENT '最后体检日期(用于判断健康数据时效性)';
    END IF;
END$$

DELIMITER ;

-- 执行存储过程
CALL add_user_health_columns();

-- 删除存储过程
DROP PROCEDURE IF EXISTS add_user_health_columns;

-- 验证结果
SELECT '========== 字段扩展完成，验证结果 ==========' AS '验证';

SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    COLUMN_COMMENT AS '注释'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'sys_user_health'
  AND COLUMN_NAME IN ('bmi', 'bmr', 'diet_preferences', 'food_dislikes', 'recommendation_strategy',
                       'diet_restriction_level', 'daily_protein_goal', 'daily_carb_goal', 'daily_fat_goal',
                       'disease_severity', 'last_checkup_date', 'profile_generated_time')
ORDER BY ORDINAL_POSITION;

SELECT '✓ 字段扩展完成！下一步：执行calculate_user_metrics.sql计算BMI和BMR' AS '提示';

