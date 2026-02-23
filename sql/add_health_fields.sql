-- 为 sys_user_health 表添加健康目标所需的新字段
-- 如果字段已存在会报错，可忽略

-- 添加饮食偏好字段
ALTER TABLE sys_user_health 
ADD COLUMN diet_preferences VARCHAR(500) DEFAULT NULL COMMENT '饮食偏好';

-- 添加每日蛋白质目标
ALTER TABLE sys_user_health 
ADD COLUMN daily_protein_goal INT DEFAULT 80 COMMENT '每日蛋白质目标(g)';

-- 添加每日碳水目标
ALTER TABLE sys_user_health 
ADD COLUMN daily_carb_goal INT DEFAULT 250 COMMENT '每日碳水目标(g)';

-- 添加每日脂肪目标
ALTER TABLE sys_user_health 
ADD COLUMN daily_fat_goal INT DEFAULT 60 COMMENT '每日脂肪目标(g)';

-- 添加食量偏好字段
ALTER TABLE sys_user_health 
ADD COLUMN portion_preference VARCHAR(20) DEFAULT 'normal' COMMENT '食量偏好(small/normal/large)';

-- 添加职业字段
ALTER TABLE sys_user_health 
ADD COLUMN occupation VARCHAR(100) DEFAULT NULL COMMENT '职业';

-- 验证表结构
DESCRIBE sys_user_health;

-- 检查是否添加成功
SELECT column_name, column_type, column_comment 
FROM information_schema.columns 
WHERE table_name = 'sys_user_health' 
AND column_name IN ('diet_preferences', 'daily_protein_goal', 'daily_carb_goal', 'daily_fat_goal', 'portion_preference', 'occupation');

SELECT '✅ sys_user_health 表新字段添加完成！' as result;
