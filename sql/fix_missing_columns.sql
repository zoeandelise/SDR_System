-- 修复 sys_user_health 表缺失字段
-- 请逐条执行，如果提示 "Duplicate column name" (重复字段名)，请忽略该错误继续下一条

-- 1. 添加职业字段 (这是报错的主要原因)
ALTER TABLE sys_user_health ADD COLUMN occupation VARCHAR(100) DEFAULT NULL COMMENT '职业';

-- 2. 添加食量偏好
ALTER TABLE sys_user_health ADD COLUMN portion_preference VARCHAR(20) DEFAULT 'normal' COMMENT '食量偏好(small/normal/large)';

-- 3. 添加饮食偏好
ALTER TABLE sys_user_health ADD COLUMN diet_preferences VARCHAR(500) DEFAULT NULL COMMENT '饮食偏好';

-- 4. 添加每日营养目标
ALTER TABLE sys_user_health ADD COLUMN daily_protein_goal INT DEFAULT 80 COMMENT '每日蛋白质目标(g)';
ALTER TABLE sys_user_health ADD COLUMN daily_carb_goal INT DEFAULT 250 COMMENT '每日碳水目标(g)';
ALTER TABLE sys_user_health ADD COLUMN daily_fat_goal INT DEFAULT 60 COMMENT '每日脂肪目标(g)';

-- 5. 验证添加结果
DESCRIBE sys_user_health;

SELECT '✅ 所有缺少的字段已尝试添加。请检查上方是否有 occupation 字段。' as result;
