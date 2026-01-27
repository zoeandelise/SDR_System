-- 食物分类数据初始化脚本

-- 清空现有分类数据（如果需要重新初始化）
-- DELETE FROM diet_food_category;

-- 插入主要食物分类
INSERT INTO `diet_food_category` VALUES 
-- 主食类
(1, 0, '0', '谷物主食', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 蔬菜类
(2, 0, '0', '蔬菜类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 水果类
(3, 0, '0', '水果类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 肉禽蛋类
(4, 0, '0', '肉禽蛋类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 水产海鲜类
(5, 0, '0', '水产海鲜', 5, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 豆制品类
(6, 0, '0', '豆制品', 6, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 奶制品类
(7, 0, '0', '奶制品', 7, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 坚果类
(8, 0, '0', '坚果类', 8, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 油脂类
(9, 0, '0', '油脂类', 9, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 调料类
(10, 0, '0', '调料类', 10, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 饮品类
(11, 0, '0', '饮品类', 11, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
-- 零食类
(12, 0, '0', '零食类', 12, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL);

-- 插入二级分类
INSERT INTO `diet_food_category` VALUES 
-- 谷物主食子分类
(101, 1, '0,1', '米面类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(102, 1, '0,1', '粗粮类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(103, 1, '0,1', '薯类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 蔬菜类子分类
(201, 2, '0,2', '叶菜类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(202, 2, '0,2', '根茎类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(203, 2, '0,2', '瓜果类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(204, 2, '0,2', '菌菇类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 水果类子分类
(301, 3, '0,3', '热带水果', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(302, 3, '0,3', '温带水果', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(303, 3, '0,3', '浆果类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 肉禽蛋类子分类
(401, 4, '0,4', '猪肉类', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(402, 4, '0,4', '牛肉类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(403, 4, '0,4', '羊肉类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(404, 4, '0,4', '禽肉类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(405, 4, '0,4', '蛋类', 5, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 水产海鲜子分类
(501, 5, '0,5', '淡水鱼', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(502, 5, '0,5', '海水鱼', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(503, 5, '0,5', '贝类', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(504, 5, '0,5', '虾蟹类', 4, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 豆制品子分类
(601, 6, '0,6', '大豆制品', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(602, 6, '0,6', '其他豆类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 奶制品子分类
(701, 7, '0,7', '液态奶', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(702, 7, '0,7', '酸奶', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(703, 7, '0,7', '奶酪', 3, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),

-- 坚果类子分类
(801, 8, '0,8', '树坚果', 1, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL),
(802, 8, '0,8', '种子类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL);
