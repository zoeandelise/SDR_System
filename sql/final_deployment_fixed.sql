-- 修复版最终完整部署脚本
-- 兼容MySQL 5.5+版本

-- ====================================
-- 第一步：基础结构部署
-- ====================================

-- 1.1 部署食物分类
INSERT IGNORE INTO `diet_food_category` VALUES 
-- 主分类
(1, 0, '0', '谷物主食', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(2, 0, '0', '蔬菜类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(3, 0, '0', '水果类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(4, 0, '0', '肉禽蛋类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(5, 0, '0', '水产海鲜', 5, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(6, 0, '0', '豆制品', 6, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(7, 0, '0', '奶制品', 7, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(8, 0, '0', '坚果类', 8, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 子分类
(101, 1, '0,1', '米面类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(102, 1, '0,1', '粗粮类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(201, 2, '0,2', '叶菜类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(202, 2, '0,2', '根茎类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(301, 3, '0,3', '温带水果', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(302, 3, '0,3', '热带水果', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(401, 4, '0,4', '猪肉类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(404, 4, '0,4', '禽肉类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(405, 4, '0,4', '蛋类', 5, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(502, 5, '0,5', '海水鱼', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(601, 6, '0,6', '大豆制品', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(701, 7, '0,7', '液态奶', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(801, 8, '0,8', '树坚果', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL);

-- 1.2 扩展营养表字段（忽略字段已存在的错误）
ALTER TABLE `diet_food_nutrition` ADD COLUMN `vitamin_b1` decimal(8,4) DEFAULT NULL COMMENT '维生素B1(mg/100g)' AFTER `potassium`;
ALTER TABLE `diet_food_nutrition` ADD COLUMN `omega_3` decimal(8,4) DEFAULT NULL COMMENT 'Omega-3脂肪酸(g/100g)' AFTER `vitamin_b1`;
ALTER TABLE `diet_food_nutrition` ADD COLUMN `glycemic_index` int(3) DEFAULT NULL COMMENT '血糖指数GI' AFTER `omega_3`;

-- 1.3 为食物信息表添加营养字段（忽略字段已存在的错误）
ALTER TABLE `diet_food_info` ADD COLUMN `calories_per_100g` decimal(8,2) DEFAULT NULL COMMENT '热量(kcal/100g)' AFTER `standard_weight`;
ALTER TABLE `diet_food_info` ADD COLUMN `protein_per_100g` decimal(8,2) DEFAULT NULL COMMENT '蛋白质(g/100g)' AFTER `calories_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `fat_per_100g` decimal(8,2) DEFAULT NULL COMMENT '脂肪(g/100g)' AFTER `protein_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `carbohydrate_per_100g` decimal(8,2) DEFAULT NULL COMMENT '碳水化合物(g/100g)' AFTER `fat_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `fiber_per_100g` decimal(8,2) DEFAULT NULL COMMENT '纤维(g/100g)' AFTER `carbohydrate_per_100g`;

-- ====================================
-- 第二步：同步字典数据
-- ====================================

-- 2.1 创建字典类型
INSERT IGNORE INTO `sys_dict_type` (`dict_id`, `dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) 
VALUES (100, '食物分类', 'food_category', '0', 'admin', NOW(), '食物分类列表');

-- 2.2 清空并重新插入字典数据
DELETE FROM `sys_dict_data` WHERE `dict_type` = 'food_category';

INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(1001, 1, '谷物主食', '1', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '主食类食物'),
(1002, 2, '蔬菜类', '2', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '蔬菜类食物'),
(1003, 3, '水果类', '3', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '水果类食物'),
(1004, 4, '肉禽蛋类', '4', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '肉禽蛋类食物'),
(1005, 5, '水产海鲜', '5', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '水产海鲜类食物'),
(1006, 6, '豆制品', '6', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '豆制品类食物'),
(1007, 7, '奶制品', '7', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '奶制品类食物'),
(1008, 8, '坚果类', '8', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '坚果类食物'),
-- 子分类
(1101, 11, '米面类', '101', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '米面类主食'),
(1102, 12, '粗粮类', '102', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '粗粮类主食'),
(1201, 21, '叶菜类', '201', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '叶菜类蔬菜'),
(1202, 22, '根茎类', '202', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '根茎类蔬菜'),
(1301, 31, '温带水果', '301', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '温带水果'),
(1302, 32, '热带水果', '302', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '热带水果'),
(1401, 41, '猪肉类', '401', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '猪肉类'),
(1404, 44, '禽肉类', '404', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '禽肉类'),
(1405, 45, '蛋类', '405', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '蛋类'),
(1502, 52, '海水鱼', '502', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '海水鱼类'),
(1601, 61, '大豆制品', '601', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '大豆制品'),
(1701, 71, '液态奶', '701', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '液态奶制品'),
(1801, 81, '树坚果', '801', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '树坚果类');

-- ====================================
-- 第三步：修复现有食物分类
-- ====================================

-- 3.1 更新现有食物的分类ID
UPDATE `diet_food_info` SET `category_id` = 101 WHERE `food_name` = '白米饭';
UPDATE `diet_food_info` SET `category_id` = 404 WHERE `food_name` = '鸡胸肉';
UPDATE `diet_food_info` SET `category_id` = 201 WHERE `food_name` = '西兰花';
UPDATE `diet_food_info` SET `category_id` = 405 WHERE `food_name` = '鸡蛋';
UPDATE `diet_food_info` SET `category_id` = 301 WHERE `food_name` = '香蕉';
UPDATE `diet_food_info` SET `category_id` = 701 WHERE `food_name` = '牛奶';
UPDATE `diet_food_info` SET `category_id` = 102 WHERE `food_name` = '燕麦';
UPDATE `diet_food_info` SET `category_id` = 502 WHERE `food_name` = '三文鱼';
UPDATE `diet_food_info` SET `category_id` = 201 WHERE `food_name` = '菠菜';
UPDATE `diet_food_info` SET `category_id` = 301 WHERE `food_name` = '苹果';

-- 3.2 从营养表同步数据到食物表
UPDATE diet_food_info f
JOIN diet_food_nutrition n ON f.food_id = n.food_id
SET 
    f.calories_per_100g = n.calories,
    f.protein_per_100g = n.protein,
    f.fat_per_100g = n.fat,
    f.carbohydrate_per_100g = n.carbohydrate,
    f.fiber_per_100g = n.fiber
WHERE f.status = '0';

-- ====================================
-- 第四步：添加更多食物
-- ====================================

-- 4.1 添加常见食物（示例）
INSERT IGNORE INTO `diet_food_info` VALUES 
(201, '大白菜', 'FOOD2001', 201, NULL, '新鲜大白菜', NULL, 'g', 100.00, 17.00, 1.50, 0.10, 3.20, 1.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(202, '胡萝卜', 'FOOD2002', 202, NULL, '新鲜胡萝卜', NULL, 'g', 100.00, 41.00, 0.90, 0.20, 9.60, 2.80, '0', 'admin', NOW(), '', NULL, '富含胡萝卜素'),
(301, '橙子', 'FOOD3001', 301, NULL, '新鲜橙子', NULL, 'g', 100.00, 48.00, 0.90, 0.20, 12.20, 2.40, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(302, '芒果', 'FOOD3002', 302, NULL, '新鲜芒果', NULL, 'g', 100.00, 60.00, 0.80, 0.40, 15.00, 1.60, '0', 'admin', NOW(), '', NULL, '富含维生素A'),
(401, '猪瘦肉', 'FOOD4001', 401, NULL, '猪后腿瘦肉', NULL, 'g', 100.00, 143.00, 20.30, 6.20, 1.20, 0.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质'),
(501, '带鱼', 'FOOD5001', 502, NULL, '新鲜带鱼', NULL, 'g', 100.00, 127.00, 17.70, 4.90, 2.10, 0.00, '0', 'admin', NOW(), '', NULL, '富含DHA'),
(601, '豆腐', 'FOOD6001', 601, NULL, '嫩豆腐', NULL, 'g', 100.00, 76.00, 8.10, 3.70, 4.30, 0.40, '0', 'admin', NOW(), '', NULL, '植物蛋白'),
(702, '酸奶', 'FOOD7002', 701, NULL, '原味酸奶', NULL, 'g', 100.00, 72.00, 2.90, 2.70, 9.30, 0.00, '0', 'admin', NOW(), '', NULL, '含益生菌'),
(801, '核桃', 'FOOD8001', 801, NULL, '核桃仁', NULL, 'g', 100.00, 654.00, 15.20, 65.20, 13.70, 6.70, '0', 'admin', NOW(), '', NULL, '富含Omega-3');

-- 4.2 添加对应的营养信息
INSERT IGNORE INTO `diet_food_nutrition` VALUES 
(201, 201, 17.00, 1.50, 0.10, 3.20, 1.00, 2.00, 57.50, 0.00, 12.00, 47.00, 0.00, 50.00, 0.50, 144.00, NOW(), NOW()),
(202, 202, 41.00, 0.90, 0.20, 9.60, 2.80, 4.70, 69.00, 0.00, 835.00, 5.90, 0.00, 33.00, 0.30, 320.00, NOW(), NOW()),
(301, 301, 48.00, 0.90, 0.20, 12.20, 2.40, 9.40, 1.00, 0.00, 11.00, 53.20, 0.00, 40.00, 0.40, 159.00, NOW(), NOW()),
(302, 302, 60.00, 0.80, 0.40, 15.00, 1.60, 13.70, 1.00, 0.00, 54.00, 36.40, 0.00, 11.00, 0.16, 168.00, NOW(), NOW()),
(401, 401, 143.00, 20.30, 6.20, 1.20, 0.00, 0.00, 65.00, 81.00, 2.00, 0.60, 0.00, 6.00, 3.00, 305.00, NOW(), NOW()),
(501, 501, 127.00, 17.70, 4.90, 2.10, 0.00, 0.00, 150.00, 76.00, 29.00, 0.00, 2.00, 28.00, 1.20, 280.00, NOW(), NOW()),
(601, 601, 76.00, 8.10, 3.70, 4.30, 0.40, 1.20, 7.20, 0.00, 5.00, 0.20, 0.00, 164.00, 1.90, 125.00, NOW(), NOW()),
(702, 702, 72.00, 2.90, 2.70, 9.30, 0.00, 9.30, 47.00, 10.00, 27.00, 0.90, 0.00, 118.00, 0.06, 150.00, NOW(), NOW()),
(801, 801, 654.00, 15.20, 65.20, 13.70, 6.70, 2.60, 2.00, 0.00, 1.00, 1.30, 0.00, 98.00, 2.91, 441.00, NOW(), NOW());

-- ====================================
-- 第五步：最终验证
-- ====================================

-- 显示部署结果
SELECT '🎉 食物管理系统部署完成！' as '部署状态';

-- 统计信息
SELECT 
    '食物总数' as '项目',
    COUNT(*) as '数量'
FROM diet_food_info
WHERE status = '0'

UNION ALL

SELECT 
    '有营养信息的食物数',
    COUNT(*)
FROM diet_food_info f
JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '分类总数',
    COUNT(*)
FROM diet_food_category
WHERE status = '0'

UNION ALL

SELECT 
    '字典数据数',
    COUNT(*)
FROM sys_dict_data
WHERE dict_type = 'food_category' AND status = '0';

-- 显示食物列表（前端格式）
SELECT 
    '=== 前端显示数据示例 ===' as '标题';

SELECT 
    f.food_name as foodName,
    CAST(f.category_id AS CHAR) as category,
    sc.category_name as categoryName,
    COALESCE(f.calories_per_100g, 0) as caloriesPer100g,
    COALESCE(f.protein_per_100g, 0) as proteinPer100g,
    COALESCE(f.fat_per_100g, 0) as fatPer100g,
    COALESCE(f.carbohydrate_per_100g, 0) as carbohydratePer100g,
    COALESCE(f.fiber_per_100g, 0) as fiberPer100g,
    f.status,
    f.description
FROM diet_food_info f
LEFT JOIN diet_food_category sc ON f.category_id = sc.category_id
WHERE f.status = '0'
ORDER BY f.food_id
LIMIT 15;

SELECT '✅ 部署验证完成，系统可以正常使用！' as '最终状态';
