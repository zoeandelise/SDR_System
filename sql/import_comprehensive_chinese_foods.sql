-- 全面扩展中式食物库 (100+ 种)
-- 包含：主食、蛋白、蔬菜、肉菜、汤羹、加餐

-- 清理旧数据（可选，为了避免重复，这里使用 INSERT IGNORE 或先删除特定名称的）
-- DELETE FROM diet_food_nutrition WHERE food_id IN (SELECT food_id FROM diet_food_info WHERE food_name IN (...));
-- DELETE FROM diet_food_info WHERE food_name IN (...);

-- ==========================================
-- 1. 主食类 (Category ID: 1)
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('小米粥', 1, '0', NOW()),
('大米粥', 1, '0', NOW()),
('杂粮粥', 1, '0', NOW()),
('皮蛋瘦肉粥', 1, '0', NOW()),
('南瓜粥', 1, '0', NOW()),
('绿豆粥', 1, '0', NOW()),
('八宝粥', 1, '0', NOW()),
('全麦馒头', 1, '0', NOW()),
('白面馒头', 1, '0', NOW()),
('花卷', 1, '0', NOW()),
('肉包子', 1, '0', NOW()),
('菜包子', 1, '0', NOW()),
('豆沙包', 1, '0', NOW()),
('蒸饺', 1, '0', NOW()),
('水饺', 1, '0', NOW()),
('馄饨', 1, '0', NOW()),
('煎饼果子(家常版)', 1, '0', NOW()),
('油条(少油版)', 1, '0', NOW()),
('葱油饼', 1, '0', NOW()),
('鸡蛋灌饼', 1, '0', NOW()),
('米饭', 1, '0', NOW()),
('糙米饭', 1, '0', NOW()),
('二米饭(大米小米)', 1, '0', NOW()),
('红豆饭', 1, '0', NOW()),
('紫薯饭', 1, '0', NOW()),
('阳春面', 1, '0', NOW()),
('炸酱面(家常)', 1, '0', NOW()),
('西红柿鸡蛋面', 1, '0', NOW()),
('牛肉面', 1, '0', NOW()),
('凉面', 1, '0', NOW()),
('炒面', 1, '0', NOW()),
('炒饭', 1, '0', NOW()),
('蒸红薯', 1, '0', NOW()),
('蒸玉米', 1, '0', NOW()),
('蒸山药', 1, '0', NOW());

-- ==========================================
-- 2. 蛋白类 (Category ID: 4/6/7) - 早餐/加餐常用
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('水煮蛋', 4, '0', NOW()),
('茶叶蛋', 4, '0', NOW()),
('煎蛋', 4, '0', NOW()),
('蒸蛋羹', 4, '0', NOW()),
('卤蛋', 4, '0', NOW()),
('咸鸭蛋', 4, '0', NOW()),
('热牛奶', 7, '0', NOW()),
('无糖酸奶', 7, '0', NOW()),
('豆浆(无糖)', 8, '0', NOW()),
('豆浆(微糖)', 8, '0', NOW()),
('豆腐脑(咸)', 6, '0', NOW()),
('豆腐脑(甜)', 6, '0', NOW());

-- ==========================================
-- 3. 蔬菜小菜 (Category ID: 2)
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('凉拌黄瓜', 2, '0', NOW()),
('凉拌海带丝', 2, '0', NOW()),
('凉拌木耳', 2, '0', NOW()),
('凉拌菠菜', 2, '0', NOW()),
('拍黄瓜', 2, '0', NOW()),
('小葱拌豆腐', 2, '0', NOW()),
('咸菜(少量)', 2, '0', NOW()),
('榨菜', 2, '0', NOW()),
('腌萝卜', 2, '0', NOW()),
('泡菜', 2, '0', NOW()),
('清炒时蔬', 2, '0', NOW()),
('蒜蓉空心菜', 2, '0', NOW()),
('清炒油麦菜', 2, '0', NOW()),
('清炒小白菜', 2, '0', NOW()),
('耗油生菜', 2, '0', NOW()),
('炒合菜', 2, '0', NOW()),
('地三鲜(少油)', 2, '0', NOW()),
('干煸四季豆', 2, '0', NOW()),
('酸辣土豆丝', 2, '0', NOW()),
('手撕包菜', 2, '0', NOW()),
('西红柿炒鸡蛋', 2, '0', NOW()), -- 虽有蛋，常作素菜
('韭菜炒鸡蛋', 2, '0', NOW());

-- ==========================================
-- 4. 肉菜 (Category ID: 4/5)
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('宫保鸡丁', 4, '0', NOW()),
('鱼香肉丝', 4, '0', NOW()),
('红烧肉(家常)', 4, '0', NOW()),
('回锅肉', 4, '0', NOW()),
('木须肉', 4, '0', NOW()),
('京酱肉丝', 4, '0', NOW()),
('糖醋里脊', 4, '0', NOW()),
('小炒肉', 4, '0', NOW()),
('红烧排骨', 4, '0', NOW()),
('土豆炖牛腩', 4, '0', NOW()),
('葱爆羊肉', 4, '0', NOW()),
('清蒸鱼', 5, '0', NOW()),
('红烧鱼块', 5, '0', NOW()),
('酸菜鱼', 5, '0', NOW()),
('水煮鱼', 5, '0', NOW()),
('白灼虾', 5, '0', NOW()),
('油焖大虾', 5, '0', NOW()),
('红烧鸡块', 4, '0', NOW()),
('香菇滑鸡', 4, '0', NOW()),
('口水鸡', 4, '0', NOW());

-- ==========================================
-- 5. 汤羹 (Category ID: 8)
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('紫菜蛋花汤', 8, '0', NOW()),
('西红柿鸡蛋汤', 8, '0', NOW()),
('冬瓜排骨汤', 8, '0', NOW()),
('玉米排骨汤', 8, '0', NOW()),
('菌菇汤', 8, '0', NOW()),
('酸辣汤', 8, '0', NOW()),
('鲫鱼豆腐汤', 8, '0', NOW()),
('老鸭汤', 8, '0', NOW()),
('绿豆汤', 8, '0', NOW()),
('银耳莲子羹', 8, '0', NOW());

-- ==========================================
-- 6. 加餐/水果 (Category ID: 3/6)
-- ==========================================
INSERT IGNORE INTO diet_food_info (food_name, category_id, status, create_time) VALUES
('苹果', 3, '0', NOW()),
('香蕉', 3, '0', NOW()),
('橙子', 3, '0', NOW()),
('葡萄', 3, '0', NOW()),
('西瓜', 3, '0', NOW()),
('梨', 3, '0', NOW()),
('桃子', 3, '0', NOW()),
('核桃(3-5个)', 6, '0', NOW()),
('杏仁(10颗)', 6, '0', NOW()),
('红枣(3-5颗)', 3, '0', NOW());

-- ==========================================
-- 插入营养数据 (估算值，每100g)
-- ==========================================
-- 辅助存储过程或直接插入
-- 这里使用 INSERT INTO ... SELECT ... 模式

-- 主食
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 46, 1.4, 0.7, 8.4 FROM diet_food_info WHERE food_name = '小米粥';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 116, 2.6, 0.3, 25.9 FROM diet_food_info WHERE food_name = '米饭';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 223, 7.0, 1.1, 47.0 FROM diet_food_info WHERE food_name = '全麦馒头';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 250, 8.0, 10.0, 30.0 FROM diet_food_info WHERE food_name = '肉包子';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 137, 2.8, 0.4, 30.0 FROM diet_food_info WHERE food_name = '西红柿鸡蛋面';

-- 蛋白
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 144, 13.3, 8.8, 2.8 FROM diet_food_info WHERE food_name = '水煮蛋';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 54, 3.0, 3.2, 3.4 FROM diet_food_info WHERE food_name = '热牛奶';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 31, 3.2, 1.6, 1.2 FROM diet_food_info WHERE food_name = '豆浆(无糖)';

-- 蔬菜
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 35, 1.0, 2.0, 4.0 FROM diet_food_info WHERE food_name = '凉拌黄瓜';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 50, 2.0, 3.0, 5.0 FROM diet_food_info WHERE food_name = '清炒时蔬';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 85, 5.0, 6.0, 4.0 FROM diet_food_info WHERE food_name = '西红柿炒鸡蛋';

-- 肉菜
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 180, 15.0, 12.0, 6.0 FROM diet_food_info WHERE food_name = '宫保鸡丁';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 110, 18.0, 3.0, 2.0 FROM diet_food_info WHERE food_name = '清蒸鱼';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 350, 10.0, 30.0, 5.0 FROM diet_food_info WHERE food_name = '红烧肉(家常)';

-- 汤
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 25, 2.0, 1.0, 2.0 FROM diet_food_info WHERE food_name = '紫菜蛋花汤';
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 15, 1.0, 0.5, 2.0 FROM diet_food_info WHERE food_name = '西红柿鸡蛋汤';

-- 水果
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 52, 0.3, 0.2, 13.7 FROM diet_food_info WHERE food_name = '苹果';

-- 补充默认值 (对于未明确设置的)
INSERT IGNORE INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate)
SELECT food_id, 100, 5, 5, 10 FROM diet_food_info WHERE food_id NOT IN (SELECT food_id FROM diet_food_nutrition);
