-- 修复默认 100kcal 数据的脚本
-- 基于一般营养数据估算 (每100g)

-- ==========================================
-- 1. 主食类
-- ==========================================
-- 粥类 (水分大，热量低)
UPDATE diet_food_nutrition SET calories=46, protein=1.1, fat=0.3, carbohydrate=9.9 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '大米粥');
UPDATE diet_food_nutrition SET calories=47, protein=1.5, fat=0.5, carbohydrate=9.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '杂粮粥');
UPDATE diet_food_nutrition SET calories=55, protein=3.0, fat=1.5, carbohydrate=7.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '皮蛋瘦肉粥');
UPDATE diet_food_nutrition SET calories=35, protein=0.5, fat=0.1, carbohydrate=8.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '南瓜粥');
UPDATE diet_food_nutrition SET calories=45, protein=2.0, fat=0.2, carbohydrate=9.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '绿豆粥');
UPDATE diet_food_nutrition SET calories=85, protein=2.5, fat=1.0, carbohydrate=17.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '八宝粥');

-- 面点 (碳水为主)
UPDATE diet_food_nutrition SET calories=223, protein=7.0, fat=1.1, carbohydrate=47.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '白面馒头');
UPDATE diet_food_nutrition SET calories=215, protein=6.5, fat=1.0, carbohydrate=45.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '花卷');
UPDATE diet_food_nutrition SET calories=200, protein=5.5, fat=6.0, carbohydrate=32.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '菜包子');
UPDATE diet_food_nutrition SET calories=240, protein=6.0, fat=3.0, carbohydrate=48.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '豆沙包');
UPDATE diet_food_nutrition SET calories=180, protein=7.0, fat=8.0, carbohydrate=20.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒸饺');
UPDATE diet_food_nutrition SET calories=190, protein=7.5, fat=8.5, carbohydrate=22.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '水饺');
UPDATE diet_food_nutrition SET calories=200, protein=7.0, fat=9.0, carbohydrate=24.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '馄饨');
UPDATE diet_food_nutrition SET calories=260, protein=8.0, fat=12.0, carbohydrate=30.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '煎饼果子(家常版)');
UPDATE diet_food_nutrition SET calories=388, protein=6.0, fat=17.0, carbohydrate=51.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '油条(少油版)');
UPDATE diet_food_nutrition SET calories=280, protein=7.0, fat=10.0, carbohydrate=40.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '葱油饼');
UPDATE diet_food_nutrition SET calories=255, protein=8.0, fat=12.0, carbohydrate=28.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '鸡蛋灌饼');

-- 饭类
UPDATE diet_food_nutrition SET calories=111, protein=2.6, fat=0.9, carbohydrate=23.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '糙米饭');
UPDATE diet_food_nutrition SET calories=114, protein=2.6, fat=0.5, carbohydrate=25.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '二米饭(大米小米)');
UPDATE diet_food_nutrition SET calories=120, protein=3.5, fat=0.4, carbohydrate=26.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红豆饭');
UPDATE diet_food_nutrition SET calories=115, protein=2.0, fat=0.3, carbohydrate=26.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '紫薯饭');
UPDATE diet_food_nutrition SET calories=170, protein=5.0, fat=6.0, carbohydrate=24.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '炒饭');

-- 面条
UPDATE diet_food_nutrition SET calories=109, protein=3.6, fat=0.5, carbohydrate=23.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '阳春面');
UPDATE diet_food_nutrition SET calories=160, protein=6.0, fat=5.0, carbohydrate=24.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '炸酱面(家常)');
UPDATE diet_food_nutrition SET calories=140, protein=7.0, fat=4.0, carbohydrate=20.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '牛肉面');
UPDATE diet_food_nutrition SET calories=130, protein=4.0, fat=3.0, carbohydrate=22.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '凉面');
UPDATE diet_food_nutrition SET calories=180, protein=6.0, fat=8.0, carbohydrate=22.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '炒面');

-- 根茎类
UPDATE diet_food_nutrition SET calories=86, protein=1.6, fat=0.2, carbohydrate=20.1 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒸红薯');
UPDATE diet_food_nutrition SET calories=112, protein=4.0, fat=1.2, carbohydrate=22.8 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒸玉米');
UPDATE diet_food_nutrition SET calories=57, protein=1.9, fat=0.2, carbohydrate=12.4 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒸山药');

-- ==========================================
-- 2. 蛋白类
-- ==========================================
UPDATE diet_food_nutrition SET calories=150, protein=12.0, fat=10.0, carbohydrate=2.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '茶叶蛋');
UPDATE diet_food_nutrition SET calories=200, protein=13.0, fat=15.0, carbohydrate=1.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '煎蛋');
UPDATE diet_food_nutrition SET calories=48, protein=5.0, fat=2.5, carbohydrate=1.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒸蛋羹');
UPDATE diet_food_nutrition SET calories=160, protein=13.0, fat=11.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '卤蛋');
UPDATE diet_food_nutrition SET calories=190, protein=12.0, fat=13.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '咸鸭蛋');
UPDATE diet_food_nutrition SET calories=72, protein=3.0, fat=3.0, carbohydrate=9.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '无糖酸奶');
UPDATE diet_food_nutrition SET calories=45, protein=3.0, fat=1.6, carbohydrate=4.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '豆浆(微糖)');
UPDATE diet_food_nutrition SET calories=60, protein=5.0, fat=3.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '豆腐脑(咸)');
UPDATE diet_food_nutrition SET calories=70, protein=4.0, fat=2.0, carbohydrate=9.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '豆腐脑(甜)');

-- ==========================================
-- 3. 蔬菜小菜
-- ==========================================
UPDATE diet_food_nutrition SET calories=40, protein=1.0, fat=2.0, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '凉拌海带丝');
UPDATE diet_food_nutrition SET calories=45, protein=1.5, fat=2.5, carbohydrate=6.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '凉拌木耳');
UPDATE diet_food_nutrition SET calories=40, protein=2.0, fat=2.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '凉拌菠菜');
UPDATE diet_food_nutrition SET calories=35, protein=1.0, fat=2.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '拍黄瓜');
UPDATE diet_food_nutrition SET calories=60, protein=5.0, fat=3.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '小葱拌豆腐');
UPDATE diet_food_nutrition SET calories=30, protein=1.0, fat=0.5, carbohydrate=6.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '咸菜(少量)');
UPDATE diet_food_nutrition SET calories=25, protein=1.0, fat=0.2, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '榨菜');
UPDATE diet_food_nutrition SET calories=30, protein=0.8, fat=0.2, carbohydrate=7.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '腌萝卜');
UPDATE diet_food_nutrition SET calories=28, protein=1.5, fat=0.3, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '泡菜');
UPDATE diet_food_nutrition SET calories=60, protein=2.5, fat=4.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '蒜蓉空心菜');
UPDATE diet_food_nutrition SET calories=55, protein=1.5, fat=4.0, carbohydrate=3.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '清炒油麦菜');
UPDATE diet_food_nutrition SET calories=45, protein=1.5, fat=3.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '清炒小白菜');
UPDATE diet_food_nutrition SET calories=50, protein=1.5, fat=3.5, carbohydrate=3.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '耗油生菜');
UPDATE diet_food_nutrition SET calories=90, protein=4.0, fat=6.0, carbohydrate=6.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '炒合菜');
UPDATE diet_food_nutrition SET calories=120, protein=2.0, fat=8.0, carbohydrate=12.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '地三鲜(少油)');
UPDATE diet_food_nutrition SET calories=95, protein=2.5, fat=7.0, carbohydrate=6.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '干煸四季豆');
UPDATE diet_food_nutrition SET calories=110, protein=2.0, fat=6.0, carbohydrate=14.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '酸辣土豆丝');
UPDATE diet_food_nutrition SET calories=70, protein=1.5, fat=5.0, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '手撕包菜');
UPDATE diet_food_nutrition SET calories=130, protein=6.0, fat=10.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '韭菜炒鸡蛋');

-- ==========================================
-- 4. 肉菜
-- ==========================================
UPDATE diet_food_nutrition SET calories=160, protein=10.0, fat=10.0, carbohydrate=8.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '鱼香肉丝');
UPDATE diet_food_nutrition SET calories=400, protein=10.0, fat=38.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '回锅肉');
UPDATE diet_food_nutrition SET calories=180, protein=12.0, fat=12.0, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '木须肉');
UPDATE diet_food_nutrition SET calories=210, protein=18.0, fat=12.0, carbohydrate=8.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '京酱肉丝');
UPDATE diet_food_nutrition SET calories=250, protein=12.0, fat=15.0, carbohydrate=18.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '糖醋里脊');
UPDATE diet_food_nutrition SET calories=280, protein=15.0, fat=22.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '小炒肉');
UPDATE diet_food_nutrition SET calories=260, protein=16.0, fat=20.0, carbohydrate=6.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红烧排骨');
UPDATE diet_food_nutrition SET calories=140, protein=8.0, fat=6.0, carbohydrate=12.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '土豆炖牛腩');
UPDATE diet_food_nutrition SET calories=220, protein=18.0, fat=15.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '葱爆羊肉');
UPDATE diet_food_nutrition SET calories=160, protein=18.0, fat=8.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红烧鱼块');
UPDATE diet_food_nutrition SET calories=140, protein=16.0, fat=7.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '酸菜鱼');
UPDATE diet_food_nutrition SET calories=150, protein=17.0, fat=8.0, carbohydrate=2.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '水煮鱼');
UPDATE diet_food_nutrition SET calories=90, protein=18.0, fat=1.0, carbohydrate=1.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '白灼虾');
UPDATE diet_food_nutrition SET calories=180, protein=16.0, fat=10.0, carbohydrate=5.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '油焖大虾');
UPDATE diet_food_nutrition SET calories=190, protein=18.0, fat=12.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红烧鸡块');
UPDATE diet_food_nutrition SET calories=150, protein=16.0, fat=8.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '香菇滑鸡');
UPDATE diet_food_nutrition SET calories=240, protein=17.0, fat=18.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '口水鸡');

-- ==========================================
-- 5. 汤羹
-- ==========================================
UPDATE diet_food_nutrition SET calories=40, protein=2.5, fat=2.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '冬瓜排骨汤');
UPDATE diet_food_nutrition SET calories=60, protein=3.0, fat=2.5, carbohydrate=7.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '玉米排骨汤');
UPDATE diet_food_nutrition SET calories=30, protein=2.0, fat=1.0, carbohydrate=3.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '菌菇汤');
UPDATE diet_food_nutrition SET calories=45, protein=2.5, fat=2.0, carbohydrate=4.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '酸辣汤');
UPDATE diet_food_nutrition SET calories=55, protein=5.0, fat=2.5, carbohydrate=2.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '鲫鱼豆腐汤');
UPDATE diet_food_nutrition SET calories=80, protein=6.0, fat=5.0, carbohydrate=2.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '老鸭汤');
UPDATE diet_food_nutrition SET calories=45, protein=2.0, fat=0.2, carbohydrate=9.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '绿豆汤');
UPDATE diet_food_nutrition SET calories=50, protein=1.0, fat=0.2, carbohydrate=11.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '银耳莲子羹');

-- ==========================================
-- 6. 加餐/水果
-- ==========================================
UPDATE diet_food_nutrition SET calories=93, protein=1.4, fat=0.2, carbohydrate=22.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '香蕉');
UPDATE diet_food_nutrition SET calories=47, protein=0.8, fat=0.2, carbohydrate=10.5 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '橙子');
UPDATE diet_food_nutrition SET calories=43, protein=0.5, fat=0.2, carbohydrate=10.3 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '葡萄');
UPDATE diet_food_nutrition SET calories=31, protein=0.6, fat=0.1, carbohydrate=6.8 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '西瓜');
UPDATE diet_food_nutrition SET calories=51, protein=0.4, fat=0.2, carbohydrate=13.1 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '梨');
UPDATE diet_food_nutrition SET calories=42, protein=0.9, fat=0.1, carbohydrate=10.1 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '桃子');
UPDATE diet_food_nutrition SET calories=654, protein=15.0, fat=65.0, carbohydrate=13.7 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '核桃(3-5个)');
UPDATE diet_food_nutrition SET calories=578, protein=21.0, fat=50.0, carbohydrate=21.0 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '杏仁(10颗)');
UPDATE diet_food_nutrition SET calories=264, protein=3.2, fat=0.5, carbohydrate=61.8 WHERE food_id = (SELECT food_id FROM diet_food_info WHERE food_name = '红枣(3-5颗)');
