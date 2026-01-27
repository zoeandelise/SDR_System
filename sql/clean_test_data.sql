-- 清理现有测试数据
SET FOREIGN_KEY_CHECKS = 0;

-- 删除测试用户的饮食记录
DELETE FROM diet_record WHERE user_id >= 101;

-- 删除测试用户的健康信息
DELETE FROM sys_user_health WHERE user_id >= 101;

-- 删除测试用户信息
DELETE FROM sys_user WHERE user_id >= 101;

-- 重置AUTO_INCREMENT
ALTER TABLE diet_record AUTO_INCREMENT = 1;
ALTER TABLE sys_user_health AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

SELECT '测试数据清理完成' as '状态';
