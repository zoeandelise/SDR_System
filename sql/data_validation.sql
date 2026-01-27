-- 数据验证脚本 - 验证食物库数据完整性

-- 1. 检查没有营养信息的食物
SELECT 
    f.food_id,
    f.food_name,
    f.category_id,
    c.category_name
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
LEFT JOIN diet_food_category c ON f.category_id = c.category_id
WHERE n.nutrition_id IS NULL
AND f.status = '0';

-- 2. 检查营养信息缺失关键字段的记录
SELECT 
    n.nutrition_id,
    f.food_name,
    CASE 
        WHEN n.calories IS NULL THEN '缺少热量, '
        ELSE ''
    END +
    CASE 
        WHEN n.protein IS NULL THEN '缺少蛋白质, '
        ELSE ''
    END +
    CASE 
        WHEN n.fat IS NULL THEN '缺少脂肪, '
        ELSE ''
    END +
    CASE 
        WHEN n.carbohydrate IS NULL THEN '缺少碳水化合物, '
        ELSE ''
    END AS missing_fields
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE (n.calories IS NULL OR n.protein IS NULL OR n.fat IS NULL OR n.carbohydrate IS NULL)
AND f.status = '0';

-- 3. 统计各分类的食物数量
SELECT 
    c.category_name,
    COUNT(f.food_id) as food_count,
    COUNT(n.nutrition_id) as nutrition_count,
    (COUNT(f.food_id) - COUNT(n.nutrition_id)) as missing_nutrition
FROM diet_food_category c
LEFT JOIN diet_food_info f ON c.category_id = f.category_id AND f.status = '0'
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE c.parent_id = 0  -- 只看一级分类
GROUP BY c.category_id, c.category_name
ORDER BY c.category_id;

-- 4. 检查食物分类是否完整
SELECT 
    f.food_id,
    f.food_name,
    f.category_id
FROM diet_food_info f
LEFT JOIN diet_food_category c ON f.category_id = c.category_id
WHERE c.category_id IS NULL
AND f.status = '0';

-- 5. 检查重复的食物名称
SELECT 
    food_name,
    COUNT(*) as count
FROM diet_food_info
WHERE status = '0'
GROUP BY food_name
HAVING COUNT(*) > 1;

-- 6. 营养数据合理性检查（检查异常值）
SELECT 
    f.food_name,
    n.calories,
    n.protein,
    n.fat,
    n.carbohydrate,
    CASE 
        WHEN n.calories > 900 THEN '热量过高'
        WHEN n.calories < 0 THEN '热量为负'
        WHEN n.protein > 100 THEN '蛋白质过高'
        WHEN n.protein < 0 THEN '蛋白质为负'
        WHEN n.fat > 100 THEN '脂肪过高'
        WHEN n.fat < 0 THEN '脂肪为负'
        WHEN n.carbohydrate > 100 THEN '碳水化合物过高'
        WHEN n.carbohydrate < 0 THEN '碳水化合物为负'
        ELSE '正常'
    END as status_check
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'
AND (n.calories > 900 OR n.calories < 0 
     OR n.protein > 100 OR n.protein < 0
     OR n.fat > 100 OR n.fat < 0
     OR n.carbohydrate > 100 OR n.carbohydrate < 0);

-- 7. 统计营养素覆盖率
SELECT 
    '热量' as nutrient, 
    COUNT(CASE WHEN calories IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN calories IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '蛋白质' as nutrient,
    COUNT(CASE WHEN protein IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN protein IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '脂肪' as nutrient,
    COUNT(CASE WHEN fat IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN fat IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '碳水化合物' as nutrient,
    COUNT(CASE WHEN carbohydrate IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN carbohydrate IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '维生素C' as nutrient,
    COUNT(CASE WHEN vitamin_c IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN vitamin_c IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '钙' as nutrient,
    COUNT(CASE WHEN calcium IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN calcium IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '铁' as nutrient,
    COUNT(CASE WHEN iron IS NOT NULL THEN 1 END) as has_value,
    COUNT(*) as total,
    ROUND(COUNT(CASE WHEN iron IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as coverage_rate
FROM diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.status = '0';

-- 8. 生成食物库概览报告
SELECT 
    '总食物数量' as metric,
    COUNT(*) as value
FROM diet_food_info
WHERE status = '0'

UNION ALL

SELECT 
    '有营养信息的食物数量' as metric,
    COUNT(*) as value
FROM diet_food_info f
JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0'

UNION ALL

SELECT 
    '食物分类数量' as metric,
    COUNT(*) as value
FROM diet_food_category
WHERE status = '0'

UNION ALL

SELECT 
    '一级分类数量' as metric,
    COUNT(*) as value
FROM diet_food_category
WHERE parent_id = 0 AND status = '0'

UNION ALL

SELECT 
    '二级分类数量' as metric,
    COUNT(*) as value
FROM diet_food_category
WHERE parent_id != 0 AND status = '0';
