-- 食物库完整部署脚本
-- 执行顺序：分类 -> 食物信息 -> 营养信息 -> 扩展字段 -> 扩展营养数据

-- ====================================
-- 1. 初始化食物分类数据
-- ====================================

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
(12, 0, '0', '零食类', 12, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL)
ON DUPLICATE KEY UPDATE category_name = VALUES(category_name);

-- 插入二级分类（部分示例）
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
(802, 8, '0,8', '种子类', 2, NULL, NULL, NULL, '0', '0', 'admin', NOW(), '', NULL)
ON DUPLICATE KEY UPDATE category_name = VALUES(category_name);

-- ====================================
-- 2. 扩展营养表字段
-- ====================================

-- 为 diet_food_nutrition 表添加更多营养素字段
-- 注意：如果字段已存在会报错，请手动执行或忽略错误

-- 检查并添加维生素B1字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_b1 decimal(8,4) DEFAULT NULL COMMENT ''维生素B1/硫胺素(mg/100g)'' AFTER potassium');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_b1');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_b1 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素B2字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_b2 decimal(8,4) DEFAULT NULL COMMENT ''维生素B2/核黄素(mg/100g)'' AFTER vitamin_b1');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_b2');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_b2 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素B3字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_b3 decimal(8,4) DEFAULT NULL COMMENT ''维生素B3/烟酸(mg/100g)'' AFTER vitamin_b2');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_b3');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_b3 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素B6字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_b6 decimal(8,4) DEFAULT NULL COMMENT ''维生素B6(mg/100g)'' AFTER vitamin_b3');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_b6');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_b6 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素B12字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_b12 decimal(8,4) DEFAULT NULL COMMENT ''维生素B12(μg/100g)'' AFTER vitamin_b6');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_b12');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_b12 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加叶酸字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN folate decimal(8,2) DEFAULT NULL COMMENT ''叶酸(μg/100g)'' AFTER vitamin_b12');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'folate');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''folate already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素E字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_e decimal(8,2) DEFAULT NULL COMMENT ''维生素E(mg/100g)'' AFTER folate');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_e');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_e already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加维生素K字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN vitamin_k decimal(8,2) DEFAULT NULL COMMENT ''维生素K(μg/100g)'' AFTER vitamin_e');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'vitamin_k');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''vitamin_k already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加镁字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN magnesium decimal(8,2) DEFAULT NULL COMMENT ''镁(mg/100g)'' AFTER vitamin_k');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'magnesium');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''magnesium already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加磷字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN phosphorus decimal(8,2) DEFAULT NULL COMMENT ''磷(mg/100g)'' AFTER magnesium');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'phosphorus');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''phosphorus already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加锌字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN zinc decimal(8,2) DEFAULT NULL COMMENT ''锌(mg/100g)'' AFTER phosphorus');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'zinc');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''zinc already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加铜字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN copper decimal(8,4) DEFAULT NULL COMMENT ''铜(mg/100g)'' AFTER zinc');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'copper');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''copper already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加锰字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN manganese decimal(8,4) DEFAULT NULL COMMENT ''锰(mg/100g)'' AFTER copper');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'manganese');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''manganese already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加硒字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN selenium decimal(8,2) DEFAULT NULL COMMENT ''硒(μg/100g)'' AFTER manganese');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'selenium');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''selenium already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加碘字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN iodine decimal(8,2) DEFAULT NULL COMMENT ''碘(μg/100g)'' AFTER selenium');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'iodine');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''iodine already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加Omega-3字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN omega_3 decimal(8,4) DEFAULT NULL COMMENT ''Omega-3脂肪酸(g/100g)'' AFTER iodine');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'omega_3');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''omega_3 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加Omega-6字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN omega_6 decimal(8,4) DEFAULT NULL COMMENT ''Omega-6脂肪酸(g/100g)'' AFTER omega_3');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'omega_6');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''omega_6 already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加饱和脂肪酸字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN saturated_fat decimal(8,2) DEFAULT NULL COMMENT ''饱和脂肪酸(g/100g)'' AFTER omega_6');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'saturated_fat');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''saturated_fat already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加单不饱和脂肪酸字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN monounsaturated_fat decimal(8,2) DEFAULT NULL COMMENT ''单不饱和脂肪酸(g/100g)'' AFTER saturated_fat');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'monounsaturated_fat');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''monounsaturated_fat already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加多不饱和脂肪酸字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN polyunsaturated_fat decimal(8,2) DEFAULT NULL COMMENT ''多不饱和脂肪酸(g/100g)'' AFTER monounsaturated_fat');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'polyunsaturated_fat');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''polyunsaturated_fat already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加血糖指数字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN glycemic_index int(3) DEFAULT NULL COMMENT ''血糖指数GI'' AFTER polyunsaturated_fat');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'glycemic_index');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''glycemic_index already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 检查并添加抗氧化能力字段
SET @sql = CONCAT('ALTER TABLE diet_food_nutrition ADD COLUMN antioxidant_capacity decimal(10,2) DEFAULT NULL COMMENT ''抗氧化能力(ORAC值)'' AFTER glycemic_index');
SET @table_exists = (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'diet_food_nutrition' AND column_name = 'antioxidant_capacity');
SET @sql = IF(@table_exists = 0, @sql, 'SELECT ''antioxidant_capacity already exists'' as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ====================================
-- 3. 部署完成提示
-- ====================================

SELECT 'Food database deployment completed successfully!' as status;

-- 验证部署结果
SELECT 
    '食物分类数量' as metric,
    COUNT(*) as count
FROM diet_food_category
WHERE status = '0'

UNION ALL

SELECT 
    '一级分类数量' as metric,
    COUNT(*) as count
FROM diet_food_category
WHERE parent_id = 0 AND status = '0'

UNION ALL

SELECT 
    '二级分类数量' as metric,
    COUNT(*) as count
FROM diet_food_category
WHERE parent_id != 0 AND status = '0';

-- 显示分类结构
SELECT 
    CASE 
        WHEN parent_id = 0 THEN CONCAT('【', category_name, '】')
        ELSE CONCAT('  └─ ', category_name)
    END as category_structure
FROM diet_food_category
WHERE status = '0'
ORDER BY 
    CASE WHEN parent_id = 0 THEN category_id ELSE parent_id END,
    CASE WHEN parent_id = 0 THEN 0 ELSE category_id END;
