-- 基础食物数据初始化脚本

-- 插入常见食物信息
INSERT INTO `diet_food_info` VALUES 
(1, '白米饭', 'FOOD0101', 1, NULL, '普通白米饭，主食类', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '主食，提供碳水化合物'),
(2, '鸡胸肉', 'FOOD0401', 4, NULL, '去皮鸡胸肉，高蛋白低脂肪', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质来源'),
(3, '西兰花', 'FOOD0201', 2, NULL, '新鲜西兰花，富含维生素', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含维生素C和膳食纤维'),
(4, '鸡蛋', 'FOOD0402', 4, NULL, '普通鸡蛋，营养全面', NULL, '个', 50.00, '0', 'admin', NOW(), '', NULL, '完整蛋白质，营养丰富'),
(5, '香蕉', 'FOOD0301', 3, NULL, '新鲜香蕉，富含钾元素', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '快速能量补充'),
(6, '牛奶', 'FOOD0701', 7, NULL, '纯牛奶，富含钙质', NULL, 'ml', 250.00, '0', 'admin', NOW(), '', NULL, '优质蛋白质和钙质'),
(7, '燕麦', 'FOOD0102', 1, NULL, '燕麦片，富含膳食纤维', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '高纤维，饱腹感强'),
(8, '三文鱼', 'FOOD0501', 5, NULL, '新鲜三文鱼，富含Omega-3', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '优质脂肪酸来源'),
(9, '菠菜', 'FOOD0202', 2, NULL, '新鲜菠菜，富含铁质', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '富含铁和叶酸'),
(10, '苹果', 'FOOD0302', 3, NULL, '新鲜苹果，富含纤维', NULL, 'g', 100.00, '0', 'admin', NOW(), '', NULL, '天然果糖，维生素C');

-- 插入对应的营养信息
INSERT INTO `diet_food_nutrition` VALUES 
(1, 1, 130.00, 2.60, 0.30, 28.00, 0.40, 0.10, 1.00, 0.00, 0.00, 0.00, 0.00, 10.00, 0.80, 35.00, NOW(), NOW()),
(2, 2, 165.00, 31.00, 3.60, 0.00, 0.00, 0.00, 74.00, 85.00, 7.00, 0.00, 0.10, 15.00, 1.04, 256.00, NOW(), NOW()),
(3, 3, 34.00, 2.80, 0.40, 7.00, 2.60, 1.50, 33.00, 0.00, 623.00, 89.20, 0.00, 47.00, 0.73, 316.00, NOW(), NOW()),
(4, 4, 155.00, 13.00, 11.00, 1.10, 0.00, 0.40, 124.00, 372.00, 140.00, 0.00, 1.20, 50.00, 1.75, 126.00, NOW(), NOW()),
(5, 5, 89.00, 1.10, 0.30, 23.00, 2.60, 12.20, 1.00, 0.00, 64.00, 8.70, 0.00, 5.00, 0.26, 358.00, NOW(), NOW()),
(6, 6, 150.00, 7.50, 8.50, 11.25, 0.00, 11.25, 300.00, 33.00, 128.00, 3.00, 3.00, 300.00, 0.10, 370.00, NOW(), NOW()),
(7, 7, 389.00, 16.90, 6.90, 66.30, 10.60, 0.99, 2.00, 0.00, 0.00, 0.00, 0.00, 54.00, 4.72, 429.00, NOW(), NOW()),
(8, 8, 208.00, 25.40, 12.35, 0.00, 0.00, 0.00, 59.00, 55.00, 25.00, 0.00, 11.30, 12.00, 0.80, 384.00, NOW(), NOW()),
(9, 9, 23.00, 2.90, 0.40, 3.60, 2.20, 0.40, 79.00, 0.00, 469.00, 28.10, 0.00, 99.00, 2.71, 558.00, NOW(), NOW()),
(10, 10, 52.00, 0.30, 0.20, 14.00, 2.40, 10.40, 1.00, 0.00, 3.00, 4.60, 0.00, 6.00, 0.12, 107.00, NOW(), NOW());

-- 插入用户健康信息示例数据（可选）
INSERT INTO `sys_user_health` VALUES 
(1, 1, 170.00, 70.00, 25, '0', '2', '1', 65.00, 2200, NULL, NULL, NOW(), NOW()),
(2, 2, 160.00, 55.00, 22, '1', '1', '0', 55.00, 1800, '海鲜过敏', NULL, NOW(), NOW());

-- 更新系统配置，添加更多配置项
INSERT INTO `diet_system_config` VALUES 
(6, '默认每日热量目标(男性)', 'default.daily.calories.male', '2500', 'Y', 'admin', NOW(), '', NULL, '成年男性默认每日热量需求'),
(7, '默认每日热量目标(女性)', 'default.daily.calories.female', '2000', 'Y', 'admin', NOW(), '', NULL, '成年女性默认每日热量需求'),
(8, '蛋白质推荐比例', 'nutrition.protein.ratio', '0.15', 'Y', 'admin', NOW(), '', NULL, '蛋白质占总热量的推荐比例'),
(9, '脂肪推荐比例', 'nutrition.fat.ratio', '0.25', 'Y', 'admin', NOW(), '', NULL, '脂肪占总热量的推荐比例'),
(10, '碳水化合物推荐比例', 'nutrition.carbohydrate.ratio', '0.60', 'Y', 'admin', NOW(), '', NULL, '碳水化合物占总热量的推荐比例'),
(11, 'AI识别置信度阈值', 'ai.confidence.threshold', '0.7', 'Y', 'admin', NOW(), '', NULL, 'AI识别结果的最低置信度要求'),
(12, '推荐食物数量限制', 'recommendation.food.limit', '10', 'Y', 'admin', NOW(), '', NULL, '单次推荐返回的食物数量上限');

-- 创建一些测试用的饮食记录
INSERT INTO `diet_record` VALUES 
(1, 1, '2025-01-22', '0', 350.00, 15.50, 8.20, 65.00, NULL, NULL, '早餐：燕麦+牛奶+香蕉', NOW(), NOW()),
(2, 1, '2025-01-22', '1', 580.00, 45.00, 12.00, 35.00, NULL, NULL, '午餐：鸡胸肉+米饭+西兰花', NOW(), NOW()),
(3, 1, '2025-01-22', '2', 420.00, 35.00, 15.00, 25.00, NULL, NULL, '晚餐：三文鱼+菠菜', NOW(), NOW()),
(4, 2, '2025-01-22', '0', 280.00, 12.00, 6.50, 48.00, NULL, NULL, '早餐：燕麦+苹果', NOW(), NOW()),
(5, 2, '2025-01-22', '1', 450.00, 32.00, 8.00, 42.00, NULL, NULL, '午餐：鸡胸肉+米饭', NOW(), NOW());

-- 创建字典数据（餐次类型）
INSERT INTO `sys_dict_type` VALUES (100, '餐次类型', 'diet_meal_type', '0', 'admin', NOW(), '', NULL, '饮食记录的餐次类型');

INSERT INTO `sys_dict_data` VALUES 
(100, 0, '早餐', '0', 'diet_meal_type', NULL, 'default', 'N', '0', 'admin', NOW(), '', NULL, '早餐'),
(101, 1, '午餐', '1', 'diet_meal_type', NULL, 'default', 'N', '0', 'admin', NOW(), '', NULL, '午餐'),
(102, 2, '晚餐', '2', 'diet_meal_type', NULL, 'default', 'N', '0', 'admin', NOW(), '', NULL, '晚餐'),
(103, 3, '加餐', '3', 'diet_meal_type', NULL, 'default', 'N', '0', 'admin', NOW(), '', NULL, '加餐/零食');

-- 创建活动水平字典
INSERT INTO `sys_dict_type` VALUES (101, '活动水平', 'diet_activity_level', '0', 'admin', NOW(), '', NULL, '用户活动水平分类');

INSERT INTO `sys_dict_data` VALUES 
(104, 0, '久坐', '0', 'diet_activity_level', NULL, 'info', 'N', '0', 'admin', NOW(), '', NULL, '久坐少动'),
(105, 1, '轻度活动', '1', 'diet_activity_level', NULL, 'primary', 'N', '0', 'admin', NOW(), '', NULL, '轻度活动'),
(106, 2, '中度活动', '2', 'diet_activity_level', NULL, 'success', 'N', '0', 'admin', NOW(), '', NULL, '中度活动'),
(107, 3, '重度活动', '3', 'diet_activity_level', NULL, 'warning', 'N', '0', 'admin', NOW(), '', NULL, '重度活动'),
(108, 4, '极重度活动', '4', 'diet_activity_level', NULL, 'danger', 'N', '0', 'admin', NOW(), '', NULL, '极重度活动');

-- 创建健康目标字典
INSERT INTO `sys_dict_type` VALUES (102, '健康目标', 'diet_health_goal', '0', 'admin', NOW(), '', NULL, '用户健康目标分类');

INSERT INTO `sys_dict_data` VALUES 
(109, 0, '保持体重', '0', 'diet_health_goal', NULL, 'primary', 'N', '0', 'admin', NOW(), '', NULL, '维持当前体重'),
(110, 1, '减脂', '1', 'diet_health_goal', NULL, 'success', 'N', '0', 'admin', NOW(), '', NULL, '减脂瘦身'),
(111, 2, '增肌', '2', 'diet_health_goal', NULL, 'warning', 'N', '0', 'admin', NOW(), '', NULL, '增肌塑形'),
(112, 3, '增重', '3', 'diet_health_goal', NULL, 'info', 'N', '0', 'admin', NOW(), '', NULL, '健康增重');
