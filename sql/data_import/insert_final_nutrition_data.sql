-- ================================
-- 补充剩余35种食物营养数据
-- ================================

USE smart_diet_dev;

-- ================================
-- 补充蛋奶豆坚果饮品类营养数据（96-110）
-- ================================

INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source) VALUES
-- 蛋奶类
(96, 54.00, 3.00, 3.20, 3.40, 0, 27.0, 37.0, 0, 15.0, '["dairy","lactose"]', '["healthy","children","pregnancy","osteoporosis"]', '["lactose_intolerance","dairy_allergy"]', 'official'),
(97, 72.00, 2.50, 2.70, 9.30, 0, 48.0, 47.0, 0, 13.0, '["dairy","lactose"]', '["healthy","children","pregnancy","digestive_health"]', '["lactose_intolerance","dairy_allergy"]', 'official'),
(98, 328.00, 25.00, 20.40, 3.50, 0, 0, 584.0, 5.0, 75.0, '["dairy","lactose"]', '["healthy","high_protein","calcium"]', '["hypertension","lactose_intolerance"]', 'official'),
(99, 14.00, 1.80, 0.70, 1.10, 1.10, 30.0, 3.0, 27.0, 0, '["soy"]', '["healthy","vegetarian","diabetes","hypertension"]', '["gout","soy_allergy"]', 'official'),
-- 豆类
(100, 359.00, 35.00, 16.00, 18.60, 15.50, 15.0, 2.0, 75.0, 0, '["soy"]', '["healthy","vegetarian","high_protein"]', '["gout"]', 'official'),
(101, 341.00, 36.00, 15.90, 18.10, 10.20, 42.0, 3.0, 68.0, 0, '["soy"]', '["healthy","vegetarian","diabetes"]', '["gout"]', 'official'),
(102, 309.00, 20.20, 0.60, 63.40, 7.70, 25.0, 1.0, 53.0, 0, '["soy"]', '["healthy","vegetarian","diabetes","heart_health"]', '["gout"]', 'official'),
-- 坚果类
(103, 654.00, 15.20, 65.20, 9.60, 9.50, 15.0, 2.0, 25.0, 0, '["nuts","tree_nuts"]', '["healthy","brain_health"]', '["nut_allergy"]', 'official'),
(104, 578.00, 22.00, 50.60, 17.90, 11.80, 0, 1.0, 58.0, 0, '["nuts","tree_nuts"]', '["healthy","heart_health"]', '["nut_allergy"]', 'official'),
(105, 574.00, 21.70, 48.70, 21.70, 6.90, 15.0, 1.0, 79.0, 0, '["nuts","peanuts"]', '["healthy","high_protein"]', '["gout","peanut_allergy"]', 'official'),
(106, 552.00, 17.30, 43.80, 28.70, 3.30, 25.0, 12.0, 54.0, 0, '["nuts","tree_nuts"]', '["healthy"]', '["nut_allergy"]', 'official'),
-- 饮品类
(107, 1.00, 0.20, 0, 0, 0, 0, 1.0, 0, 0, NULL, '["healthy","antioxidant","weight_loss"]', NULL, 'official'),
(108, 6.00, 0.10, 0, 1.60, 0.10, 0, 1.0, 0, 0, NULL, '["healthy","immunity","detox"]', NULL, 'official'),
(109, 82.00, 0.30, 0, 20.30, 0, 55.0, 4.0, 0, 0, NULL, '["healthy"]', '["diabetes"]', 'official'),
(110, 19.00, 0.20, 0.20, 3.70, 1.10, 54.0, 105.0, 0, 0, NULL, '["healthy","hydration"]', NULL, 'official');

-- 验证导入结果
SELECT '✓ 已完成所有55种食物营养数据导入！' AS '完成提示';

SELECT 
    COUNT(*) AS '总营养记录数',
    COUNT(gi_value) AS 'GI值记录数',
    ROUND(COUNT(gi_value) * 100.0 / COUNT(*), 2) AS 'GI值覆盖率(%)',
    COUNT(sodium_per_100g) AS '钠含量记录数',
    ROUND(COUNT(sodium_per_100g) * 100.0 / COUNT(*), 2) AS '钠覆盖率(%)',
    COUNT(purine_per_100g) AS '嘌呤记录数',
    ROUND(COUNT(purine_per_100g) * 100.0 / COUNT(*), 2) AS '嘌呤覆盖率(%)'
FROM diet_food_nutrition;

-- 按分类统计完整度
SELECT 
    c.category_name AS '食物分类',
    COUNT(f.food_id) AS '食物数量',
    COUNT(n.gi_value) AS 'GI值数量',
    ROUND(COUNT(n.gi_value) * 100.0 / COUNT(f.food_id), 2) AS '完整度(%)'
FROM diet_food_category c
LEFT JOIN diet_food_info f ON c.category_id = f.category_id
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
GROUP BY c.category_id, c.category_name
ORDER BY COUNT(f.food_id) DESC;

