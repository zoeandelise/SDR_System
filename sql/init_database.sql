-- ========================================
-- 智能饮食推荐系统 - 数据库初始化脚本
-- ========================================

-- 1. 创建数据库
DROP DATABASE IF EXISTS `smart_diet_dev`;
CREATE DATABASE `smart_diet_dev` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 使用数据库
USE `smart_diet_dev`;

-- 提示：数据库创建成功
SELECT '数据库 smart_diet_dev 创建成功！' AS message;
SELECT '请继续执行 ry_20250522.sql 和 diet_system.sql 来创建表结构和初始数据' AS next_step;

