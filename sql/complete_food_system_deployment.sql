-- 完整食物系统部署脚本
-- 包含分类、食物、营养信息、字典同步等所有内容

-- ====================================
-- 1. 部署食物分类和基础结构
-- ====================================

-- 执行简化版基础部署
SOURCE sql/simple_deploy.sql;

-- ====================================
-- 2. 修复现有食物分类并添加新食物
-- ====================================

-- 执行食物修复和扩展脚本
SOURCE sql/fix_existing_foods_and_add_more.sql;

-- ====================================
-- 3. 同步字典数据
-- ====================================

-- 执行字典同步脚本
SOURCE sql/sync_food_category_dict.sql;

-- ====================================
-- 4. 验证部署结果
-- ====================================

-- 检查食物与分类关联情况
SELECT 
    '=== 食物分类关联检查 ===' as check_title;

SELECT 
    f.food_name as '食物名称',
    c.category_name as '主分类',
    sc.category_name as '子分类',
    f.category_id as '分类ID',
    CASE WHEN n.nutrition_id IS NULL THEN '❌ 缺少营养信息' ELSE '✅ 营养信息完整' END as '营养状态'
FROM diet_food_info f
LEFT JOIN diet_food_category sc ON f.category_id = sc.category_id
LEFT JOIN diet_food_category c ON sc.parent_id = c.category_id
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0'
ORDER BY c.category_id, sc.category_id, f.food_name
LIMIT 20;

-- 检查字典数据
SELECT 
    '=== 字典数据检查 ===' as check_title;

SELECT 
    dict_label as '分类名称',
    dict_value as '分类值',
    list_class as '样式',
    status as '状态'
FROM sys_dict_data 
WHERE dict_type = 'food_category' 
ORDER BY CAST(dict_value AS UNSIGNED)
LIMIT 15;

-- 统计各分类食物数量
SELECT 
    '=== 分类统计 ===' as check_title;

SELECT 
    COALESCE(c.category_name, '未分类') as '主分类',
    COALESCE(sc.category_name, '无子分类') as '子分类',
    COUNT(f.food_id) as '食物数量',
    COUNT(n.nutrition_id) as '有营养信息数量'
FROM diet_food_category c
LEFT JOIN diet_food_category sc ON c.category_id = sc.parent_id
LEFT JOIN diet_food_info f ON sc.category_id = f.category_id AND f.status = '0'
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE c.parent_id = 0
GROUP BY c.category_id, c.category_name, sc.category_id, sc.category_name
ORDER BY c.category_id, sc.category_id;

-- 检查营养表字段
SELECT 
    '=== 营养表字段检查 ===' as check_title;

SELECT 
    COLUMN_NAME as '字段名',
    DATA_TYPE as '数据类型',
    COLUMN_COMMENT as '注释'
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'diet_food_nutrition' 
AND COLUMN_NAME IN ('vitamin_b1', 'vitamin_b2', 'omega_3', 'glycemic_index', 'antioxidant_capacity')
ORDER BY ORDINAL_POSITION;

-- 系统概览
SELECT 
    '=== 系统概览 ===' as check_title;

SELECT 
    '总食物数量' as '指标',
    COUNT(*) as '数值'
FROM diet_food_info
WHERE status = '0'

UNION ALL

SELECT 
    '有营养信息的食物数量' as '指标',
    COUNT(*) as '数值'
FROM diet_food_info f
JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '食物分类数量' as '指标',
    COUNT(*) as '数值'
FROM diet_food_category
WHERE status = '0'

UNION ALL

SELECT 
    '字典数据数量' as '指标',
    COUNT(*) as '数值'
FROM sys_dict_data
WHERE dict_type = 'food_category' AND status = '0';

-- ====================================
-- 5. 前端显示字段映射检查
-- ====================================

-- 检查前端需要的字段是否正确映射
SELECT 
    '=== 前端字段映射检查 ===' as check_title;

-- 模拟前端需要的数据格式
SELECT 
    f.food_name as foodName,
    CAST(f.category_id AS CHAR) as category,  -- 前端字典需要的字符串格式
    sc.category_name as categoryName,
    '100' as caloriesPer100g,  -- 示例营养数据
    '20' as proteinPer100g,
    '5' as fatPer100g,
    '15' as carbohydratePer100g,
    '2' as fiberPer100g,
    f.status,
    f.description
FROM diet_food_info f
LEFT JOIN diet_food_category sc ON f.category_id = sc.category_id
WHERE f.status = '0'
ORDER BY f.food_id
LIMIT 10;

SELECT 'Food system deployment completed successfully! 🎉' as deployment_status;
