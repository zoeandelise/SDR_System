-- 扩展食物库数据脚本
-- 在现有基础上添加更多常见食物

-- 谷物主食类
INSERT INTO `diet_food_info` VALUES 
-- 米面类
(11, '糙米饭', 'FOOD0111', 101, NULL, '糙米制作的米饭，营养更丰富', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '全谷物，富含B族维生素'),
(12, '小麦面条', 'FOOD0112', 101, NULL, '普通小麦面条', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '主食，提供碳水化合物'),
(13, '全麦面包', 'FOOD0113', 101, NULL, '全麦制作的面包', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高纤维，营养丰富'),
(14, '馒头', 'FOOD0114', 101, NULL, '普通白面馒头', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '传统主食'),

-- 粗粮类
(15, '小米粥', 'FOOD0121', 102, NULL, '小米熬制的粥', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '易消化，营养丰富'),
(16, '黑米饭', 'FOOD0122', 102, NULL, '黑米制作的米饭', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),
(17, '玉米', 'FOOD0123', 102, NULL, '新鲜玉米', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含膳食纤维'),
(18, '藜麦', 'FOOD0124', 102, NULL, '藜麦，超级食物', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '完整蛋白质，营养全面'),

-- 薯类
(19, '红薯', 'FOOD0131', 103, NULL, '蒸熟的红薯', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含胡萝卜素'),
(20, '土豆', 'FOOD0132', 103, NULL, '普通土豆', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(21, '紫薯', 'FOOD0133', 103, NULL, '紫薯，富含花青素', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '抗氧化食物');

-- 蔬菜类
INSERT INTO `diet_food_info` VALUES 
-- 叶菜类
(22, '小白菜', 'FOOD0211', 201, NULL, '新鲜小白菜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(23, '油菜', 'FOOD0212', 201, NULL, '新鲜油菜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含叶酸'),
(24, '韭菜', 'FOOD0213', 201, NULL, '新鲜韭菜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素A'),
(25, '芹菜', 'FOOD0214', 201, NULL, '新鲜芹菜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含膳食纤维'),
(26, '生菜', 'FOOD0215', 201, NULL, '新鲜生菜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低热量，适合减肥'),

-- 根茎类
(27, '胡萝卜', 'FOOD0221', 202, NULL, '新鲜胡萝卜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含胡萝卜素'),
(28, '白萝卜', 'FOOD0222', 202, NULL, '新鲜白萝卜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(29, '莲藕', 'FOOD0223', 202, NULL, '新鲜莲藕', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含淀粉'),
(30, '山药', 'FOOD0224', 202, NULL, '新鲜山药', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '健脾养胃'),

-- 瓜果类
(31, '冬瓜', 'FOOD0231', 203, NULL, '新鲜冬瓜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低热量，利尿'),
(32, '黄瓜', 'FOOD0232', 203, NULL, '新鲜黄瓜', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低热量，清热'),
(33, '番茄', 'FOOD0233', 203, NULL, '新鲜番茄', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含番茄红素'),
(34, '茄子', 'FOOD0234', 203, NULL, '新鲜茄子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),

-- 菌菇类
(35, '香菇', 'FOOD0241', 204, NULL, '新鲜香菇', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含多糖'),
(36, '金针菇', 'FOOD0242', 204, NULL, '新鲜金针菇', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含蛋白质'),
(37, '平菇', 'FOOD0243', 204, NULL, '新鲜平菇', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低热量高蛋白'),
(38, '木耳', 'FOOD0244', 204, NULL, '黑木耳', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含铁质');

-- 水果类
INSERT INTO `diet_food_info` VALUES 
-- 热带水果
(39, '芒果', 'FOOD0311', 301, NULL, '新鲜芒果', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素A'),
(40, '菠萝', 'FOOD0312', 301, NULL, '新鲜菠萝', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(41, '椰子', 'FOOD0313', 301, NULL, '椰子肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含中链脂肪酸'),
(42, '火龙果', 'FOOD0314', 301, NULL, '新鲜火龙果', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),

-- 温带水果
(43, '梨', 'FOOD0321', 302, NULL, '新鲜梨', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '清热润燥'),
(44, '桃子', 'FOOD0322', 302, NULL, '新鲜桃子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(45, '葡萄', 'FOOD0323', 302, NULL, '新鲜葡萄', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),
(46, '柚子', 'FOOD0324', 302, NULL, '新鲜柚子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),

-- 浆果类
(47, '草莓', 'FOOD0331', 303, NULL, '新鲜草莓', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C'),
(48, '蓝莓', 'FOOD0332', 303, NULL, '新鲜蓝莓', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),
(49, '黑莓', 'FOOD0333', 303, NULL, '新鲜黑莓', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '抗氧化水果'),
(50, '覆盆子', 'FOOD0334', 303, NULL, '新鲜覆盆子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C');

-- 肉禽蛋类
INSERT INTO `diet_food_info` VALUES 
-- 猪肉类
(51, '猪瘦肉', 'FOOD0411', 401, NULL, '猪后腿瘦肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质'),
(52, '猪里脊', 'FOOD0412', 401, NULL, '猪里脊肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低脂高蛋白'),
(53, '猪排骨', 'FOOD0413', 401, NULL, '猪排骨', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含钙质'),

-- 牛肉类
(54, '牛瘦肉', 'FOOD0421', 402, NULL, '牛后腿瘦肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高蛋白低脂'),
(55, '牛腩', 'FOOD0422', 402, NULL, '牛腩肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含铁质'),

-- 羊肉类
(56, '羊瘦肉', 'FOOD0431', 403, NULL, '羊后腿瘦肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '温补食材'),

-- 禽肉类
(57, '鸭胸肉', 'FOOD0441', 404, NULL, '去皮鸭胸肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质'),
(58, '鹅肉', 'FOOD0442', 404, NULL, '鹅胸肉', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高蛋白食物'),

-- 蛋类
(59, '鸭蛋', 'FOOD0451', 405, NULL, '普通鸭蛋', NULL, '个', 60.00, '0', 'admin', NOW(), '', NULL, '营养丰富'),
(60, '鹌鹑蛋', 'FOOD0452', 405, NULL, '鹌鹑蛋', NULL, '个', 10.00, '0', 'admin', NOW(), '', NULL, '营养密度高');

-- 水产海鲜类
INSERT INTO `diet_food_info` VALUES 
-- 淡水鱼
(61, '草鱼', 'FOOD0511', 501, NULL, '新鲜草鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质'),
(62, '鲫鱼', 'FOOD0512', 501, NULL, '新鲜鲫鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '易消化'),
(63, '鲤鱼', 'FOOD0513', 501, NULL, '新鲜鲤鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '营养丰富'),

-- 海水鱼
(64, '带鱼', 'FOOD0521', 502, NULL, '新鲜带鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含DHA'),
(65, '黄花鱼', 'FOOD0522', 502, NULL, '新鲜黄花鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质海鱼'),
(66, '鲈鱼', 'FOOD0523', 502, NULL, '新鲜鲈鱼', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低脂高蛋白'),

-- 贝类
(67, '扇贝', 'FOOD0531', 503, NULL, '新鲜扇贝', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含蛋白质'),
(68, '牡蛎', 'FOOD0532', 503, NULL, '新鲜牡蛎', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含锌'),
(69, '蛤蜊', 'FOOD0533', 503, NULL, '新鲜蛤蜊', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含铁质'),

-- 虾蟹类
(70, '基围虾', 'FOOD0541', 504, NULL, '新鲜基围虾', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '低脂高蛋白'),
(71, '大闸蟹', 'FOOD0542', 504, NULL, '新鲜大闸蟹', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含蛋白质'),
(72, '龙虾', 'FOOD0543', 504, NULL, '新鲜龙虾', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质海鲜');

-- 豆制品类
INSERT INTO `diet_food_info` VALUES 
-- 大豆制品
(73, '豆腐', 'FOOD0611', 601, NULL, '嫩豆腐', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '植物蛋白'),
(74, '豆浆', 'FOOD0612', 601, NULL, '纯豆浆', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '植物蛋白饮品'),
(75, '豆腐干', 'FOOD0613', 601, NULL, '豆腐干', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高蛋白零食'),
(76, '腐竹', 'FOOD0614', 601, NULL, '腐竹', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高蛋白食材'),

-- 其他豆类
(77, '绿豆', 'FOOD0621', 602, NULL, '绿豆', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '清热解毒'),
(78, '红豆', 'FOOD0622', 602, NULL, '红豆', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含铁质'),
(79, '黑豆', 'FOOD0623', 602, NULL, '黑豆', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含花青素'),
(80, '黄豆', 'FOOD0624', 602, NULL, '黄豆', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '完整蛋白质');

-- 奶制品类
INSERT INTO `diet_food_info` VALUES 
-- 液态奶
(81, '全脂牛奶', 'FOOD0711', 701, NULL, '全脂纯牛奶', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '富含钙质'),
(82, '脱脂牛奶', 'FOOD0712', 701, NULL, '脱脂纯牛奶', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '低脂高蛋白'),
(83, '羊奶', 'FOOD0713', 701, NULL, '纯羊奶', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '易消化'),

-- 酸奶
(84, '原味酸奶', 'FOOD0721', 702, NULL, '原味酸奶', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '含益生菌'),
(85, '希腊酸奶', 'FOOD0722', 702, NULL, '希腊酸奶', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高蛋白酸奶'),

-- 奶酪
(86, '奶酪片', 'FOOD0731', 703, NULL, '奶酪片', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高钙食品'),
(87, '马苏里拉奶酪', 'FOOD0732', 703, NULL, '马苏里拉奶酪', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '制作披萨用');

-- 坚果类
INSERT INTO `diet_food_info` VALUES 
-- 树坚果
(88, '核桃', 'FOOD0811', 801, NULL, '核桃仁', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含Omega-3'),
(89, '杏仁', 'FOOD0812', 801, NULL, '杏仁', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素E'),
(90, '腰果', 'FOOD0813', 801, NULL, '腰果', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含镁'),
(91, '开心果', 'FOOD0814', 801, NULL, '开心果', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含蛋白质'),
(92, '榛子', 'FOOD0815', 801, NULL, '榛子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素E'),

-- 种子类
(93, '花生', 'FOOD0821', 802, NULL, '花生米', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含蛋白质'),
(94, '瓜子', 'FOOD0822', 802, NULL, '葵花籽', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素E'),
(95, '南瓜子', 'FOOD0823', 802, NULL, '南瓜子', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含锌'),
(96, '芝麻', 'FOOD0824', 802, NULL, '黑芝麻', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含钙质');

-- 饮品类
INSERT INTO `diet_food_info` VALUES 
(97, '绿茶', 'FOOD1101', 11, NULL, '绿茶', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '富含抗氧化物'),
(98, '咖啡', 'FOOD1102', 11, NULL, '黑咖啡', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '提神醒脑'),
(99, '蜂蜜水', 'FOOD1103', 11, NULL, '蜂蜜水', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '天然甜味剂'),
(100, '柠檬水', 'FOOD1104', 11, NULL, '柠檬水', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '富含维生素C');
