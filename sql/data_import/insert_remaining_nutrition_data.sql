-- ================================
-- 补充剩余食物营养数据
-- ================================

USE smart_diet_dev;

-- ================================
-- 水果类营养数据 (76-83)
-- ================================

-- 橙子 (76)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (76, 48.00, 0.90, 0.20, 11.10, 0.60, 43.0, 2.0, 2.3, 0, '["healthy","immunity","children"]', NULL, 'official');

-- 葡萄 (77)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (77, 69.00, 0.50, 0.20, 17.10, 0.40, 43.0, 2.0, 2.3, 0, '["healthy"]', '["diabetes"]', 'official');

-- 草莓 (78)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (78, 32.00, 1.00, 0.20, 7.10, 1.10, 40.0, 1.0, 1.3, 0, '["healthy","diabetes","weight_loss"]', NULL, 'official');

-- 猕猴桃 (79)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (79, 61.00, 1.20, 0.60, 14.20, 2.60, 52.0, 2.6, 4.1, 0, '["healthy","immunity","diabetes"]', NULL, 'official');

-- 蓝莓 (80)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (80, 57.00, 0.70, 0.30, 14.50, 2.40, 53.0, 1.0, 12.0, 0, '["healthy","diabetes","antioxidant"]', NULL, 'official');

-- 芒果 (81)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (81, 60.00, 0.80, 0.20, 14.80, 1.30, 51.0, 2.0, 6.8, 0, '["healthy"]', NULL, 'official');

-- 樱桃 (82)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (82, 63.00, 1.10, 0.20, 14.40, 0.30, 22.0, 4.0, 2.4, 0, '["healthy","diabetes"]', NULL, 'official');

-- 梨 (83)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (83, 51.00, 0.40, 0.10, 13.10, 3.10, 38.0, 2.0, 1.4, 0, '["healthy","diabetes"]', NULL, 'official');

-- ================================
-- 肉类营养数据 (84-88)
-- ================================

-- 鸡胸肉 (84) ⭐高频推荐
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (84, 133.00, 19.40, 5.00, 2.50, 0, 0, 65.0, 137.4, 58.0, '["healthy","diabetes","weight_loss","high_protein","hypertension","hyperlipidemia"]', NULL, 'official');

-- 瘦牛肉 (85)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (85, 125.00, 20.10, 4.20, 0.20, 0, 0, 53.0, 83.7, 63.0, '["healthy","high_protein","anemia"]', '["gout","hyperlipidemia"]', 'official');

-- 瘦猪肉 (86)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (86, 143.00, 20.30, 6.20, 1.50, 0, 0, 58.0, 122.5, 81.0, '["healthy","weight_loss"]', '["gout"]', 'official');

-- 羊肉 (87)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (87, 203.00, 19.00, 14.10, 0.20, 0, 0, 92.0, 111.5, 92.0, '["healthy","high_protein"]', '["gout","hyperlipidemia"]', 'official');

-- 鸭肉 (88)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (88, 240.00, 15.50, 19.70, 0.20, 0, 0, 69.0, 138.4, 94.0, '["healthy"]', '["gout","hyperlipidemia"]', 'official');

-- ================================
-- 海鲜类营养数据 (89-94)
-- ================================

-- 三文鱼 (89)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (89, 139.00, 17.20, 7.80, 0, 0, 0, 59.0, 120.0, 63.0, '["fish","seafood"]', '["healthy","hypertension","diabetes","omega3"]', '["fish_allergy"]', 'official');

-- 带鱼 (90)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (90, 127.00, 17.70, 4.90, 2.10, 0, 0, 150.0, 160.0, 76.0, '["fish","seafood"]', '["healthy","high_protein"]', '["gout","fish_allergy"]', 'official');

-- 虾 (91)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (91, 93.00, 18.60, 1.00, 2.80, 0, 0, 133.0, 137.7, 154.0, '["shellfish","seafood"]', '["healthy","high_protein"]', '["gout","hyperlipidemia","shellfish_allergy"]', 'official');

-- 螃蟹 (92)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (92, 103.00, 17.50, 2.60, 2.30, 0, 0, 193.0, 147.3, 267.0, '["shellfish","seafood"]', '["healthy"]', '["gout","hyperlipidemia","shellfish_allergy"]', 'official');

-- 鲈鱼 (93)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (93, 105.00, 18.60, 3.10, 0.50, 0, 0, 60.0, 100.0, 86.0, '["fish","seafood"]', '["healthy","hypertension","diabetes"]', '["fish_allergy"]', 'official');

-- 扇贝 (94)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (94, 60.00, 13.00, 0.60, 2.70, 0, 0, 120.0, 90.0, 140.0, '["shellfish","seafood"]', '["healthy","high_protein"]', '["shellfish_allergy"]', 'official');

-- ================================
-- 蛋类营养数据 (95)
-- ================================

-- 鸡蛋 (95) ⭐高频推荐
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source)
VALUES (95, 144.00, 13.30, 8.80, 2.80, 0, 0, 131.0, 0, 585.0, '["egg"]', '["healthy","high_protein","children","pregnancy"]', '["hyperlipidemia","egg_allergy"]', 'official');

SELECT '✓ 已补充水果类6种、肉类5种、海鲜类6种、蛋类1种，共18种' AS '补充完成';

-- 最终验证
SELECT 
    '最终统计' AS '统计项',
    COUNT(*) AS '总营养记录数',
    COUNT(gi_value) AS 'GI值记录数',
    ROUND(COUNT(gi_value) * 100.0 / COUNT(*), 2) AS 'GI值覆盖率(%)',
    COUNT(CASE WHEN gi_value < 55 THEN 1 END) AS '低GI食物数',
    COUNT(CASE WHEN purine_per_100g < 50 THEN 1 END) AS '低嘌呤食物数'
FROM diet_food_nutrition;

