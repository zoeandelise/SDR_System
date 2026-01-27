-- 清理不符合中国饮食习惯的单一食材，并优化菜名

-- 1. 删除豆类和坚果 (通常不作为正餐菜肴)
DELETE FROM diet_food_nutrition WHERE food_id IN (SELECT food_id FROM diet_food_info WHERE food_name IN ('黄豆', '黑豆', '红豆', '核桃', '杏仁', '花生', '腰果'));
DELETE FROM diet_food_info WHERE food_name IN ('黄豆', '黑豆', '红豆', '核桃', '杏仁', '花生', '腰果');

-- 2. 删除生肉和生海鲜 (已由成品菜替代，或即将替代)
DELETE FROM diet_food_nutrition WHERE food_id IN (SELECT food_id FROM diet_food_info WHERE food_name IN ('鸡胸肉', '瘦牛肉', '瘦猪肉', '羊肉', '鸭肉', '三文鱼', '带鱼', '虾', '螃蟹', '鲈鱼', '扇贝'));
DELETE FROM diet_food_info WHERE food_name IN ('鸡胸肉', '瘦牛肉', '瘦猪肉', '羊肉', '鸭肉', '三文鱼', '带鱼', '虾', '螃蟹', '鲈鱼', '扇贝');

-- 3. 删除已存在成品菜的单一蔬菜 (避免重复)
-- 已有: 蒜蓉西兰花(116), 凉拌黄瓜(117)
DELETE FROM diet_food_nutrition WHERE food_id IN (SELECT food_id FROM diet_food_info WHERE food_name IN ('西兰花', '黄瓜'));
DELETE FROM diet_food_info WHERE food_name IN ('西兰花', '黄瓜');

-- 4. 将剩余单一蔬菜重命名为常见家常菜
UPDATE diet_food_info SET food_name = '清炒菠菜' WHERE food_name = '菠菜';
UPDATE diet_food_info SET food_name = '炒胡萝卜片' WHERE food_name = '胡萝卜';
UPDATE diet_food_info SET food_name = '凉拌西红柿' WHERE food_name = '番茄';
UPDATE diet_food_info SET food_name = '醋溜白菜' WHERE food_name = '白菜';
UPDATE diet_food_info SET food_name = '西芹百合' WHERE food_name = '芹菜';
UPDATE diet_food_info SET food_name = '虎皮青椒' WHERE food_name = '青椒';
UPDATE diet_food_info SET food_name = '红烧茄子' WHERE food_name = '茄子';
UPDATE diet_food_info SET food_name = '红烧冬瓜' WHERE food_name = '冬瓜';

-- 5. 补充更多肉类/海鲜成品菜 (弥补删除生肉后的空缺)
-- 香煎鸡胸肉
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '香煎鸡胸肉', 4, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '香煎鸡胸肉');
SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '香煎鸡胸肉');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 165, 30.0, 3.5, 0.0, 120, 45, 140 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 黑椒牛柳
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '黑椒牛柳', 4, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '黑椒牛柳');
SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '黑椒牛柳');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 220, 18.0, 15.0, 4.0, 380, 55, 110 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 白灼虾
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '白灼虾', 5, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '白灼虾');
SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '白灼虾');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 95, 20.0, 1.0, 0.5, 140, 40, 150 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 葱爆羊肉
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '葱爆羊肉', 4, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '葱爆羊肉');
SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '葱爆羊肉');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 240, 16.0, 18.0, 3.0, 350, 55, 130 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);

-- 6. 补充汤类 (作为副菜或单独分类，目前算作副菜/其他)
-- 紫菜蛋花汤
INSERT INTO diet_food_info (food_name, category_id, status, create_time) 
SELECT '紫菜蛋花汤', 2, '0', NOW() WHERE NOT EXISTS (SELECT 1 FROM diet_food_info WHERE food_name = '紫菜蛋花汤');
SET @food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '紫菜蛋花汤');
INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, sodium_per_100g, gi_value, purine_per_100g)
SELECT @food_id, 35, 3.0, 2.0, 1.0, 200, 20, 30 WHERE NOT EXISTS (SELECT 1 FROM diet_food_nutrition WHERE food_id = @food_id);
