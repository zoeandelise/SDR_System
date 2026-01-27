-- 为食物信息表添加营养字段，以便前端直接显示
-- 这样可以避免复杂的关联查询

-- ====================================
-- 1. 为diet_food_info表添加营养字段
-- ====================================

-- 添加基础营养字段
ALTER TABLE `diet_food_info` 
ADD COLUMN `calories_per_100g` decimal(8,2) DEFAULT NULL COMMENT '热量(kcal/100g)' AFTER `standard_weight`,
ADD COLUMN `protein_per_100g` decimal(8,2) DEFAULT NULL COMMENT '蛋白质(g/100g)' AFTER `calories_per_100g`,
ADD COLUMN `fat_per_100g` decimal(8,2) DEFAULT NULL COMMENT '脂肪(g/100g)' AFTER `protein_per_100g`,
ADD COLUMN `carbohydrate_per_100g` decimal(8,2) DEFAULT NULL COMMENT '碳水化合物(g/100g)' AFTER `fat_per_100g`,
ADD COLUMN `fiber_per_100g` decimal(8,2) DEFAULT NULL COMMENT '纤维(g/100g)' AFTER `carbohydrate_per_100g`;

-- ====================================
-- 2. 从营养表同步数据到食物表
-- ====================================

-- 更新现有食物的营养数据
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
-- 3. 为没有营养信息的食物设置默认值
-- ====================================

-- 根据食物分类设置默认营养值
-- 主食类（谷物主食）
UPDATE diet_food_info 
SET 
    calories_per_100g = 350.00,
    protein_per_100g = 8.00,
    fat_per_100g = 2.00,
    carbohydrate_per_100g = 75.00,
    fiber_per_100g = 3.00
WHERE category_id IN (1, 101, 102, 103) 
AND calories_per_100g IS NULL;

-- 蔬菜类
UPDATE diet_food_info 
SET 
    calories_per_100g = 25.00,
    protein_per_100g = 2.00,
    fat_per_100g = 0.30,
    carbohydrate_per_100g = 5.00,
    fiber_per_100g = 2.50
WHERE category_id IN (2, 201, 202, 203, 204) 
AND calories_per_100g IS NULL;

-- 水果类
UPDATE diet_food_info 
SET 
    calories_per_100g = 50.00,
    protein_per_100g = 0.80,
    fat_per_100g = 0.20,
    carbohydrate_per_100g = 12.00,
    fiber_per_100g = 2.00
WHERE category_id IN (3, 301, 302, 303) 
AND calories_per_100g IS NULL;

-- 肉禽蛋类
UPDATE diet_food_info 
SET 
    calories_per_100g = 150.00,
    protein_per_100g = 20.00,
    fat_per_100g = 8.00,
    carbohydrate_per_100g = 0.00,
    fiber_per_100g = 0.00
WHERE category_id IN (4, 401, 402, 403, 404, 405) 
AND calories_per_100g IS NULL;

-- 水产海鲜类
UPDATE diet_food_info 
SET 
    calories_per_100g = 100.00,
    protein_per_100g = 18.00,
    fat_per_100g = 3.00,
    carbohydrate_per_100g = 0.00,
    fiber_per_100g = 0.00
WHERE category_id IN (5, 501, 502, 503, 504) 
AND calories_per_100g IS NULL;

-- 豆制品类
UPDATE diet_food_info 
SET 
    calories_per_100g = 120.00,
    protein_per_100g = 12.00,
    fat_per_100g = 5.00,
    carbohydrate_per_100g = 8.00,
    fiber_per_100g = 3.00
WHERE category_id IN (6, 601, 602) 
AND calories_per_100g IS NULL;

-- 奶制品类
UPDATE diet_food_info 
SET 
    calories_per_100g = 60.00,
    protein_per_100g = 3.50,
    fat_per_100g = 3.00,
    carbohydrate_per_100g = 5.00,
    fiber_per_100g = 0.00
WHERE category_id IN (7, 701, 702, 703) 
AND calories_per_100g IS NULL;

-- 坚果类
UPDATE diet_food_info 
SET 
    calories_per_100g = 580.00,
    protein_per_100g = 20.00,
    fat_per_100g = 50.00,
    carbohydrate_per_100g = 20.00,
    fiber_per_100g = 8.00
WHERE category_id IN (8, 801, 802) 
AND calories_per_100g IS NULL;

-- ====================================
-- 4. 验证更新结果
-- ====================================

-- 检查营养数据完整性
SELECT 
    '=== 营养数据完整性检查 ===' as check_title;

SELECT 
    f.food_name as '食物名称',
    sc.category_name as '分类',
    f.calories_per_100g as '热量',
    f.protein_per_100g as '蛋白质',
    f.fat_per_100g as '脂肪',
    f.carbohydrate_per_100g as '碳水化合物',
    f.fiber_per_100g as '纤维',
    CASE 
        WHEN f.calories_per_100g IS NULL THEN '❌ 缺少营养数据'
        ELSE '✅ 营养数据完整'
    END as '状态'
FROM diet_food_info f
LEFT JOIN diet_food_category sc ON f.category_id = sc.category_id
WHERE f.status = '0'
ORDER BY f.food_id
LIMIT 20;

-- 统计各分类营养数据覆盖率
SELECT 
    '=== 分类营养数据覆盖率 ===' as check_title;

SELECT 
    COALESCE(c.category_name, '未分类') as '主分类',
    COUNT(f.food_id) as '总食物数',
    COUNT(f.calories_per_100g) as '有营养数据数',
    CONCAT(ROUND(COUNT(f.calories_per_100g) * 100.0 / COUNT(f.food_id), 1), '%') as '覆盖率'
FROM diet_food_category c
LEFT JOIN diet_food_category sc ON c.category_id = sc.parent_id
LEFT JOIN diet_food_info f ON sc.category_id = f.category_id AND f.status = '0'
WHERE c.parent_id = 0
GROUP BY c.category_id, c.category_name
ORDER BY c.category_id;

SELECT 'Nutrition fields added to food info table successfully! 🎉' as result;
