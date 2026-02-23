-- 食物营养数据修正脚本
-- 根据实际表结构修正

-- ====================================
-- 表结构说明：
-- diet_food_info: 基本信息表 (food_id, food_name, standard_weight)
-- diet_food_nutrition: 营养数据表 (food_id, calories, protein, fat, carbohydrate)
-- 营养值都是 每100g 的数据
-- ====================================

-- ====================================
-- 1. 先查询问题食物的当前数据
-- ====================================
SELECT f.food_name, n.calories, n.protein, n.fat, n.carbohydrate, f.standard_weight
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.food_name IN ('豆浆', '蒜蓉西兰花', '小米粥', '干煸四季豆', '豆浆(无糖)', '蒸玉米', '泡菜', '冬瓜排骨汤');

-- ====================================
-- 2. 更新标准分量 (standard_weight)
-- ====================================

-- 豆浆类 - 250ml
UPDATE diet_food_info SET standard_weight = 250 WHERE food_name IN ('豆浆', '豆浆(无糖)');

-- 蔬菜类 - 150g
UPDATE diet_food_info SET standard_weight = 150 WHERE food_name IN ('蒜蓉西兰花', '干煸四季豆', '蒸玉米', '清炒小白菜', '手撕包菜');

-- 汤/粥类 - 250-300g
UPDATE diet_food_info SET standard_weight = 250 WHERE food_name LIKE '%粥%';
UPDATE diet_food_info SET standard_weight = 300 WHERE food_name LIKE '%汤%';

-- 泡菜 - 50g
UPDATE diet_food_info SET standard_weight = 50 WHERE food_name = '泡菜';

-- 米饭类 - 150g
UPDATE diet_food_info SET standard_weight = 150 WHERE food_name IN ('白米饭', '米饭', '糙米饭');

-- 面条类 - 200g
UPDATE diet_food_info SET standard_weight = 200 WHERE food_name LIKE '%面%' OR food_name LIKE '%面条%';

-- 鸡蛋类 - 50g (1个)
UPDATE diet_food_info SET standard_weight = 50 WHERE food_name IN ('鸡蛋', '水煮蛋', '煎蛋');

-- 肉类 - 100g
UPDATE diet_food_info SET standard_weight = 100 WHERE food_name IN ('鸡胸肉', '鸡腿肉', '猪瘦肉', '牛肉');

-- ====================================
-- 3. 修正营养数据 (每100g标准值)
-- 使用 INSERT ... ON DUPLICATE KEY UPDATE 或 UPDATE JOIN
-- ====================================

-- 豆浆（无糖）- 每100ml约35kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 35, n.protein = 3.6, n.fat = 1.8, n.carbohydrate = 1.2
WHERE f.food_name IN ('豆浆', '豆浆(无糖)');

-- 蒜蓉西兰花 - 每100g约40kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 40, n.protein = 2.8, n.fat = 2.0, n.carbohydrate = 3.5
WHERE f.food_name = '蒜蓉西兰花';

-- 小米粥 - 每100g约46kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 46, n.protein = 1.5, n.fat = 0.7, n.carbohydrate = 9.0
WHERE f.food_name = '小米粥';

-- 干煸四季豆 - 每100g约95kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 95, n.protein = 2.5, n.fat = 5.0, n.carbohydrate = 10.0
WHERE f.food_name = '干煸四季豆';

-- 蒸玉米 - 每100g约112kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 112, n.protein = 4.0, n.fat = 1.2, n.carbohydrate = 23.0
WHERE f.food_name IN ('蒸玉米', '玉米');

-- 泡菜 - 每100g约28kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 28, n.protein = 1.5, n.fat = 0.3, n.carbohydrate = 5.0
WHERE f.food_name = '泡菜';

-- 冬瓜排骨汤 - 每100ml约40kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 40, n.protein = 2.5, n.fat = 2.0, n.carbohydrate = 2.5
WHERE f.food_name = '冬瓜排骨汤';

-- 绿豆汤 - 每100ml约35kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 35, n.protein = 1.5, n.fat = 0.5, n.carbohydrate = 6.0
WHERE f.food_name = '绿豆汤';

-- ====================================
-- 4. 批量修正常见食物营养数据
-- ====================================

-- 白米饭 - 每100g约116kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 116, n.protein = 2.6, n.fat = 0.3, n.carbohydrate = 25.6
WHERE f.food_name IN ('白米饭', '米饭');

-- 西兰花 - 每100g约34kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 34, n.protein = 4.3, n.fat = 0.4, n.carbohydrate = 5.0
WHERE f.food_name LIKE '%西兰花%';

-- 鸡胸肉 - 每100g约133kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 133, n.protein = 19.3, n.fat = 5.0, n.carbohydrate = 2.5
WHERE f.food_name = '鸡胸肉';

-- 鸡蛋 - 每100g约144kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 144, n.protein = 13.3, n.fat = 8.6, n.carbohydrate = 2.8
WHERE f.food_name IN ('鸡蛋', '水煮蛋', '煎蛋');

-- 凉拌黄瓜 - 每100g约20kcal
UPDATE diet_food_nutrition n
JOIN diet_food_info f ON n.food_id = f.food_id
SET n.calories = 20, n.protein = 0.8, n.fat = 0.5, n.carbohydrate = 3.0
WHERE f.food_name LIKE '%黄瓜%';

-- ====================================
-- 5. 验证修正结果
-- ====================================
SELECT f.food_name, n.calories AS '热量(每100g)', n.protein AS '蛋白质(g)', 
       f.standard_weight AS '标准分量(g)',
       ROUND(n.calories * f.standard_weight / 100) AS '实际热量(kcal)'
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.food_name IN ('豆浆', '蒜蓉西兰花', '小米粥', '干煸四季豆', '豆浆(无糖)', 
                      '蒸玉米', '泡菜', '冬瓜排骨汤', '白米饭', '鸡蛋', '西兰花', '绿豆汤')
ORDER BY f.food_name;

SELECT '✅ 食物营养数据修正完成！' as result;
