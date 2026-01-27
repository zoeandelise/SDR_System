-- ================================
-- 完整食物营养数据导入（INSERT版本）
-- ================================
-- 说明：diet_food_nutrition表当前为空，需要先INSERT基础数据
-- 数据来源：《中国食物成分表2024》
-- ================================

USE smart_diet_dev;

-- 清空现有数据（如果有）
TRUNCATE TABLE diet_food_nutrition;

-- ================================
-- 谷物类营养数据
-- ================================

-- 白米饭 (food_id=56)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (56, 116.00, 2.60, 0.30, 25.90, 0.30, 83.0, 2.0, 18.0, 0, '["healthy"]', '["diabetes","prediabetes"]', 'official');

-- 糙米饭 (food_id=57)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (57, 112.00, 2.50, 0.80, 23.50, 1.80, 50.0, 2.0, 17.5, 0, '["healthy","diabetes","hypertension","gout","hyperlipidemia"]', NULL, 'official');

-- 全麦面包 (food_id=58)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (58, 246.00, 8.50, 3.40, 45.80, 5.80, 51.0, 550.0, 75.0, 0, '["healthy","diabetes"]', '["hypertension"]', 'official');

-- 燕麦片 (food_id=59)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (59, 367.00, 15.00, 6.70, 61.60, 5.30, 55.0, 2.0, 25.0, 0, '["healthy","diabetes","hypertension","hyperlipidemia","weight_loss"]', NULL, 'official');

-- 小米粥 (food_id=60)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (60, 46.00, 1.50, 0.20, 9.10, 0.40, 61.5, 1.0, 16.0, 0, '["healthy"]', NULL, 'official');

-- 红薯 (food_id=61)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (61, 99.00, 1.10, 0.20, 23.10, 1.60, 54.0, 28.0, 2.4, 0, '["healthy","diabetes"]', NULL, 'official');

-- 玉米 (food_id=62)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (62, 106.00, 4.00, 1.20, 22.80, 2.90, 55.0, 1.0, 9.4, 0, '["healthy","diabetes"]', NULL, 'official');

-- 荞麦面 (food_id=63)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (63, 337.00, 9.30, 2.30, 73.00, 6.50, 54.0, 6.0, 34.0, 0, '["healthy","diabetes","hyperlipidemia"]', NULL, 'official');

-- ================================
-- 蔬菜类营养数据
-- ================================

-- 西兰花 (food_id=64)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (64, 36.00, 4.10, 0.60, 4.30, 1.60, 15.0, 33.0, 70.0, 0, '["healthy","diabetes","weight_loss","hypertension","hyperlipidemia"]', NULL, 'official');

-- 菠菜 (food_id=65)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (65, 28.00, 2.60, 0.30, 2.80, 1.70, 15.0, 79.0, 13.3, 0, '["healthy","diabetes","anemia","pregnancy","hypertension"]', NULL, 'official');

-- 胡萝卜 (food_id=66)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (66, 39.00, 1.00, 0.20, 8.80, 3.20, 39.0, 71.0, 8.0, 0, '["healthy","diabetes","hypertension","gout","hyperlipidemia","children"]', NULL, 'official');

-- 番茄 (food_id=67)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (67, 19.00, 0.90, 0.20, 4.00, 0.50, 38.0, 5.0, 4.2, 0, '["healthy","diabetes","hypertension","weight_loss","hyperlipidemia"]', NULL, 'official');

-- 黄瓜 (food_id=68)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (68, 16.00, 0.80, 0.20, 2.90, 0.50, 23.0, 4.0, 7.3, 0, '["healthy","diabetes","weight_loss","hypertension","gout"]', NULL, 'official');

-- 白菜 (food_id=69)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (69, 17.00, 1.50, 0.20, 2.40, 0.80, 15.0, 57.0, 11.7, 0, '["healthy","diabetes","weight_loss","hypertension"]', NULL, 'official');

-- 芹菜 (food_id=70)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (70, 20.00, 1.20, 0.20, 3.90, 1.40, 15.0, 159.0, 10.3, 0, '["healthy","hypertension","weight_loss"]', NULL, 'official');

-- 青椒 (food_id=71)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (71, 23.00, 1.00, 0.30, 5.00, 1.40, 15.0, 2.0, 6.5, 0, '["healthy","diabetes","hypertension"]', NULL, 'official');

-- 茄子 (food_id=72)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (72, 25.00, 1.10, 0.20, 5.20, 1.30, 15.0, 5.0, 9.2, 0, '["healthy","diabetes","weight_loss"]', NULL, 'official');

-- 冬瓜 (food_id=73)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (73, 12.00, 0.40, 0.20, 2.60, 0.70, 15.0, 1.8, 2.8, 0, '["healthy","diabetes","weight_loss","hypertension","gout"]', NULL, 'official');

-- ================================
-- 水果类营养数据
-- ================================

-- 苹果 (food_id=74)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (74, 54.00, 0.20, 0.20, 13.70, 1.20, 36.0, 2.0, 0.9, 0, '["healthy","diabetes","hypertension","children"]', NULL, 'official');

-- 香蕉 (food_id=75)
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber, gi_value, sodium_per_100g, purine_per_100g, cholesterol_per_100g, suitable_for, unsuitable_for, data_source)
VALUES (75, 93.00, 1.40, 0.20, 22.00, 1.20, 52.0, 1.0, 11.1, 0, '["healthy","athletes"]', '["diabetes","kidney_disease"]', 'official');

SELECT '✓ 已导入谷物类8种、蔬菜类10种、水果类2种，共20种食物的完整营养数据' AS '完成提示';

-- 验证导入结果
SELECT 
    COUNT(*) AS '总营养记录数',
    COUNT(gi_value) AS 'GI值记录数',
    COUNT(sodium_per_100g) AS '钠含量记录数',
    COUNT(purine_per_100g) AS '嘌呤记录数',
    ROUND(COUNT(gi_value) * 100.0 / COUNT(*), 2) AS 'GI值覆盖率(%)'
FROM diet_food_nutrition;

