-- 安全分步部署脚本
-- 每个步骤都可以单独执行，避免语法错误

-- ====================================
-- 步骤1：部署食物分类数据
-- ====================================

-- 主分类
INSERT IGNORE INTO `diet_food_category` VALUES 
(1, 0, '0', '谷物主食', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(2, 0, '0', '蔬菜类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(3, 0, '0', '水果类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(4, 0, '0', '肉禽蛋类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(5, 0, '0', '水产海鲜', 5, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(6, 0, '0', '豆制品', 6, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(7, 0, '0', '奶制品', 7, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(8, 0, '0', '坚果类', 8, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL);

-- 子分类
INSERT IGNORE INTO `diet_food_category` VALUES 
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

SELECT '✅ 步骤1完成：食物分类部署成功' as result;

-- ====================================
-- 步骤2：添加营养字段到食物表（可能会有字段已存在的错误，请忽略）
-- ====================================

ALTER TABLE `diet_food_info` ADD COLUMN `calories_per_100g` decimal(8,2) DEFAULT NULL COMMENT '热量(kcal/100g)' AFTER `standard_weight`;
ALTER TABLE `diet_food_info` ADD COLUMN `protein_per_100g` decimal(8,2) DEFAULT NULL COMMENT '蛋白质(g/100g)' AFTER `calories_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `fat_per_100g` decimal(8,2) DEFAULT NULL COMMENT '脂肪(g/100g)' AFTER `protein_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `carbohydrate_per_100g` decimal(8,2) DEFAULT NULL COMMENT '碳水化合物(g/100g)' AFTER `fat_per_100g`;
ALTER TABLE `diet_food_info` ADD COLUMN `fiber_per_100g` decimal(8,2) DEFAULT NULL COMMENT '纤维(g/100g)' AFTER `carbohydrate_per_100g`;

SELECT '✅ 步骤2完成：营养字段添加成功（如有错误请忽略）' as result;

-- ====================================
-- 步骤3：创建字典数据
-- ====================================

-- 创建字典类型
INSERT IGNORE INTO `sys_dict_type` (`dict_id`, `dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) 
VALUES (100, '食物分类', 'food_category', '0', 'admin', NOW(), '食物分类列表');

-- 删除旧的字典数据
DELETE FROM `sys_dict_data` WHERE `dict_type` = 'food_category';

-- 插入新的字典数据
INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(1001, 1, '谷物主食', '1', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '主食类食物'),
(1002, 2, '蔬菜类', '2', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '蔬菜类食物'),
(1003, 3, '水果类', '3', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '水果类食物'),
(1004, 4, '肉禽蛋类', '4', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '肉禽蛋类食物'),
(1005, 5, '水产海鲜', '5', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '水产海鲜类食物'),
(1006, 6, '豆制品', '6', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '豆制品类食物'),
(1007, 7, '奶制品', '7', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '奶制品类食物'),
(1008, 8, '坚果类', '8', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '坚果类食物');

-- 插入子分类字典数据
INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
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

SELECT '✅ 步骤3完成：字典数据创建成功' as result;

-- ====================================
-- 步骤4：修复现有食物分类
-- ====================================

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

SELECT '✅ 步骤4完成：现有食物分类修复成功' as result;

-- ====================================
-- 步骤5：同步营养数据
-- ====================================

-- 从营养表同步数据到食物表
UPDATE diet_food_info f
JOIN diet_food_nutrition n ON f.food_id = n.food_id
SET 
    f.calories_per_100g = n.calories,
    f.protein_per_100g = n.protein,
    f.fat_per_100g = n.fat,
    f.carbohydrate_per_100g = n.carbohydrate,
    f.fiber_per_100g = n.fiber
WHERE f.status = '0';

SELECT '✅ 步骤5完成：营养数据同步成功' as result;

-- ====================================
-- 步骤6：添加更多食物示例
-- ====================================

INSERT IGNORE INTO `diet_food_info` VALUES 
(201, '大白菜', 'FOOD2001', 201, NULL, '新鲜大白菜', NULL, 'g', 100.00, 17.00, 1.50, 0.10, 3.20, 1.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(202, '胡萝卜', 'FOOD2002', 202, NULL, '新鲜胡萝卜', NULL, 'g', 100.00, 41.00, 0.90, 0.20, 9.60, 2.80, '0', 'admin', NOW(), '', NULL, '富含胡萝卜素'),
(301, '橙子', 'FOOD3001', 301, NULL, '新鲜橙子', NULL, 'g', 100.00, 48.00, 0.90, 0.20, 12.20, 2.40, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(401, '猪瘦肉', 'FOOD4001', 401, NULL, '猪后腿瘦肉', NULL, 'g', 100.00, 143.00, 20.30, 6.20, 1.20, 0.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质'),
(601, '豆腐', 'FOOD6001', 601, NULL, '嫩豆腐', NULL, 'g', 100.00, 76.00, 8.10, 3.70, 4.30, 0.40, '0', 'admin', NOW(), '', NULL, '植物蛋白');

SELECT '✅ 步骤6完成：示例食物添加成功' as result;

-- ====================================
-- 最终验证
-- ====================================

SELECT '🎉 完整部署成功！' as '最终状态';

-- 统计结果
SELECT 
    '食物总数' as '项目',
    COUNT(*) as '数量'
FROM diet_food_info
WHERE status = '0'

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

-- 显示前端数据格式
SELECT 
    f.food_name as foodName,
    CAST(f.category_id AS CHAR) as category,
    sc.category_name as categoryName,
    COALESCE(f.calories_per_100g, 0) as caloriesPer100g,
    COALESCE(f.protein_per_100g, 0) as proteinPer100g,
    COALESCE(f.fat_per_100g, 0) as fatPer100g,
    COALESCE(f.carbohydrate_per_100g, 0) as carbohydratePer100g,
    COALESCE(f.fiber_per_100g, 0) as fiberPer100g,
    f.status
FROM diet_food_info f
LEFT JOIN diet_food_category sc ON f.category_id = sc.category_id
WHERE f.status = '0'
ORDER BY f.food_id
LIMIT 10;

SELECT '✅ 系统已就绪，可以正常使用！' as '验证结果';
