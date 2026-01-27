-- ================================
-- 补充剩余食物营养数据（水果类、肉类、海鲜类、豆奶类）
-- ================================

USE smart_diet_dev;

-- ================================
-- 水果类（76-83）
-- ================================

INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source) VALUES
(76, 48.00, 0.90, 0.20, 11.10, 0.60, 43.0, 2.0, 2.3, 0, '["healthy","immunity","children"]', NULL, 'official'),
(77, 69.00, 0.50, 0.20, 17.10, 0.40, 43.0, 2.0, 2.3, 0, '["healthy"]', '["diabetes"]', 'official'),
(78, 32.00, 1.00, 0.20, 7.10, 1.10, 40.0, 2.0, 2.4, 0, '["healthy","diabetes","children"]', NULL, 'official'),
(79, 61.00, 0.80, 0.60, 14.50, 2.60, 52.0, 3.0, 4.2, 0, '["healthy","immunity"]', NULL, 'official'),
(80, 57.00, 0.70, 0.30, 14.50, 2.40, 53.0, 1.0, 5.1, 0, '["healthy","antioxidant"]', NULL, 'official'),
(81, 60.00, 0.60, 0.20, 15.00, 1.30, 51.0, 2.0, 6.8, 0, '["healthy"]', NULL, 'official'),
(82, 63.00, 1.10, 0.20, 14.40, 0.30, 22.0, 8.0, 2.6, 0, '["healthy","children"]', NULL, 'official'),
(83, 51.00, 0.40, 0.10, 13.10, 3.10, 38.0, 3.0, 1.5, 0, '["healthy","diabetes","hypertension"]', NULL, 'official');

-- ================================
-- 肉类（84-88）
-- ================================

INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source) VALUES
(84, 133.00, 19.40, 5.00, 2.50, 0, 0, 65.0, 137.4, 58.0, '["healthy","diabetes","weight_loss","high_protein","hypertension","hyperlipidemia"]', NULL, 'official'),
(85, 125.00, 20.10, 4.20, 0, 0, 0, 53.0, 83.7, 63.0, '["healthy","high_protein","anemia"]', '["gout","hyperlipidemia"]', 'official'),
(86, 143.00, 20.30, 6.20, 1.50, 0, 0, 58.0, 122.5, 81.0, '["healthy","weight_loss"]', '["gout"]', 'official'),
(87, 203.00, 19.00, 14.10, 0, 0, 0, 92.0, 111.5, 70.0, '["healthy","high_protein"]', '["gout","hyperlipidemia"]', 'official'),
(88, 135.00, 15.50, 7.50, 0, 0, 0, 94.0, 138.4, 94.0, '["healthy"]', '["gout"]', 'official');

-- ================================
-- 海鲜类（89-94）
-- ================================

INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source) VALUES
(89, 139.00, 17.20, 7.80, 0, 0, 0, 59.0, 119.3, 86.0, '["fish","seafood"]', '["healthy","heart_health","omega3"]', '["gout","fish_allergy"]', 'official'),
(90, 127.00, 17.70, 4.90, 2.10, 0, 0, 150.0, 135.5, 76.0, '["fish","seafood"]', '["healthy"]', '["gout","fish_allergy"]', 'official'),
(91, 87.00, 16.40, 1.20, 2.80, 0, 0, 133.0, 137.7, 154.0, '["shellfish","seafood"]', '["healthy","high_protein"]', '["gout","hyperlipidemia","shellfish_allergy"]', 'official'),
(92, 103.00, 17.50, 2.60, 6.20, 0, 0, 193.0, 81.6, 267.0, '["shellfish","seafood"]', '["healthy"]', '["gout","hyperlipidemia","shellfish_allergy"]', 'official'),
(93, 105.00, 18.60, 3.10, 0, 0, 0, 57.0, 132.6, 86.0, '["fish","seafood"]', '["healthy"]', '["gout","fish_allergy"]', 'official'),
(94, 60.00, 12.60, 0.60, 2.60, 0, 0, 142.0, 89.5, 140.0, '["shellfish","seafood"]', '["healthy"]', '["gout","shellfish_allergy"]', 'official');

-- ================================
-- 蛋奶豆类（95-110）
-- ================================

INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, allergen_tags, suitable_for, unsuitable_for, data_source) VALUES
(95, 144.00, 13.30, 8.80, 2.80, 0, 0, 131.0, 0, 585.0, '["egg"]', '["healthy","high_protein","children","pregnancy"]', '["hyperlipidemia","egg_allergy"]', 'official');

-- 查询剩余food_id
SELECT food_id, food_name, category_id FROM diet_food_info WHERE food_id > 95 ORDER BY food_id;

