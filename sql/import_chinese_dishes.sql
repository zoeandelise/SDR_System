-- 导入常见中国菜肴数据
-- 注意：这里假设 category_id 如下：
-- 1: 谷物类, 2: 蔬菜类, 4: 肉类, 5: 海鲜类, 6: 蛋奶类, 7: 豆类坚果

-- 1. 宫保鸡丁 (主菜 - 肉类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '宫保鸡丁', 4, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '宫保鸡丁');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '宫保鸡丁');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 180, 15.0, 10.0, 8.0, 350, 55, 80 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 2. 红烧肉 (主菜 - 肉类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '红烧肉', 4, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '红烧肉');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红烧肉');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 350, 10.0, 30.0, 5.0, 400, 60, 100 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 3. 清蒸鲈鱼 (主菜 - 海鲜类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '清蒸鲈鱼', 5, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '清蒸鲈鱼');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '清蒸鲈鱼');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 110, 20.0, 3.0, 1.0, 150, 45, 120 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 4. 番茄炒蛋 (主菜 - 蛋奶类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '番茄炒蛋', 6, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '番茄炒蛋');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '番茄炒蛋');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 120, 8.0, 8.0, 4.0, 250, 50, 20 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 5. 麻婆豆腐 (主菜 - 豆类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '麻婆豆腐', 7, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '麻婆豆腐');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '麻婆豆腐');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 140, 10.0, 9.0, 5.0, 450, 40, 60 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 6. 蒜蓉西兰花 (副菜 - 蔬菜类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '蒜蓉西兰花', 2, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '蒜蓉西兰花');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒜蓉西兰花');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 60, 4.0, 3.0, 5.0, 150, 30, 20 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 7. 凉拌黄瓜 (副菜 - 蔬菜类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '凉拌黄瓜', 2, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '凉拌黄瓜');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '凉拌黄瓜');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 45, 1.0, 2.0, 4.0, 200, 15, 10 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 8. 扬州炒饭 (主食 - 谷物类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '扬州炒饭', 1, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '扬州炒饭');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '扬州炒饭');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 180, 5.0, 6.0, 28.0, 300, 70, 30 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 9. 猪肉白菜饺子 (主食 - 谷物类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '猪肉白菜饺子', 1, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '猪肉白菜饺子');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '猪肉白菜饺子');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 220, 8.0, 10.0, 25.0, 350, 60, 50 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 10. 青椒土豆丝 (副菜 - 蔬菜类)
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '青椒土豆丝', 2, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '青椒土豆丝');

SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '青椒土豆丝');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 120, 2.0, 6.0, 15.0, 200, 65, 20 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);
