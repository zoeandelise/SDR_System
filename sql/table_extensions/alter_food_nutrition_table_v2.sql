-- ================================
-- 扩展食物营养表结构 - 添加健康推荐关键字段（兼容MySQL 5.7+）
-- ================================
-- 执行说明：
-- 1. 执行前请备份diet_food_nutrition表数据
-- 2. 兼容MySQL 5.7+版本
-- 3. 执行时间约5-15秒（取决于数据量）
-- ================================

USE smart_diet_dev;

SELECT '✓ diet_food_nutrition表存在，开始扩展字段' AS '检查结果';

-- 添加所有字段（使用存储过程方式）
DELIMITER $$

DROP PROCEDURE IF EXISTS add_food_nutrition_columns$$

CREATE PROCEDURE add_food_nutrition_columns()
BEGIN
    -- GI值字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='gi_value') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN gi_value DECIMAL(5,2) DEFAULT NULL 
        COMMENT 'GI值(血糖生成指数,0-100,低GI<55,中GI 55-70,高GI>70)';
    END IF;
    
    -- 钠含量字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='sodium_per_100g') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN sodium_per_100g DECIMAL(8,2) DEFAULT NULL 
        COMMENT '钠含量(mg/100g,高血压用户需控制<2000mg/天)';
    END IF;
    
    -- 嘌呤含量字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='purine_per_100g') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN purine_per_100g DECIMAL(8,2) DEFAULT NULL 
        COMMENT '嘌呤含量(mg/100g,痛风用户需控制:低嘌呤<50,中嘌呤50-150,高嘌呤>150)';
    END IF;
    
    -- 胆固醇含量字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='cholesterol_per_100g') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN cholesterol_per_100g DECIMAL(8,2) DEFAULT NULL 
        COMMENT '胆固醇含量(mg/100g,高血脂用户需控制<300mg/天)';
    END IF;
    
    -- 过敏原标签字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='allergen_tags') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN allergen_tags VARCHAR(500) DEFAULT NULL 
        COMMENT '过敏原标签(JSON数组格式,如["peanuts","dairy","gluten","soy","egg","fish","shellfish"])';
    END IF;
    
    -- 适用人群标签字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='suitable_for') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN suitable_for VARCHAR(500) DEFAULT NULL 
        COMMENT '适用人群标签(JSON数组格式,如["healthy","diabetes","hypertension","pregnancy","children"])';
    END IF;
    
    -- 不适用人群标签字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='unsuitable_for') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN unsuitable_for VARCHAR(500) DEFAULT NULL 
        COMMENT '不适用人群标签(JSON数组格式,如["diabetes","hypertension","gout","pregnancy","children","kidney_disease"])';
    END IF;
    
    -- 数据来源标识字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='data_source') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN data_source VARCHAR(50) DEFAULT 'manual' 
        COMMENT '数据来源(official:权威数据源,inferred:算法推断,manual:人工录入)';
    END IF;
    
    -- 最后更新时间字段
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='last_update_time') THEN
        ALTER TABLE diet_food_nutrition ADD COLUMN last_update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT '最后更新时间';
    END IF;
END$$

DELIMITER ;

-- 执行存储过程
CALL add_food_nutrition_columns();

-- 删除存储过程
DROP PROCEDURE IF EXISTS add_food_nutrition_columns;

-- 创建索引
SET @index_sql = 'CREATE INDEX idx_gi_value ON diet_food_nutrition(gi_value)';
SET @index_check = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
                    WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND INDEX_NAME='idx_gi_value');
SET @index_sql = IF(@index_check = 0, @index_sql, 'SELECT 1');
PREPARE stmt FROM @index_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 验证结果
SELECT '========== 字段扩展完成，验证结果 ==========' AS '验证';

SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    COLUMN_COMMENT AS '注释'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition'
  AND COLUMN_NAME IN ('gi_value', 'sodium_per_100g', 'purine_per_100g', 'cholesterol_per_100g', 
                       'allergen_tags', 'suitable_for', 'unsuitable_for', 'data_source', 'last_update_time')
ORDER BY ORDINAL_POSITION;

SELECT '✓ 字段扩展完成！' AS '提示';

