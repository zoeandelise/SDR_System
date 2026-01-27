-- ================================
-- 扩展食物营养表结构 - 添加健康推荐关键字段
-- ================================
-- 执行说明：
-- 1. 执行前请备份diet_food_nutrition表数据
-- 2. 建议先在测试环境验证字段类型和默认值
-- 3. 执行时间约5-15秒（取决于数据量）
-- 4. 字段类型已优化兼容性（支持合理数值范围）
-- ================================

USE smart_diet_dev;

-- 检查表是否存在
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✓ diet_food_nutrition表存在，开始扩展字段' ELSE '✗ 表不存在，请先创建基础表' END AS '检查结果'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smart_diet_dev' AND TABLE_NAME = 'diet_food_nutrition';

-- ================================
-- 一、添加GI值字段（血糖生成指数）
-- ================================
-- 数值范围：0-100（小数点后2位）
-- 用途：糖尿病用户推荐算法

-- 检查并添加gi_value字段
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'gi_value';

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE diet_food_nutrition ADD COLUMN gi_value DECIMAL(5,2) DEFAULT NULL COMMENT ''GI值(血糖生成指数,0-100,低GI<55,中GI 55-70,高GI>70)''',
    'SELECT ''gi_value already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 二、添加钠含量字段
-- ================================
-- 数值范围：0-10000 mg/100g（支持高钠食物如酱油等）
-- 用途：高血压用户推荐算法

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'sodium_per_100g';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN sodium_per_100g DECIMAL(8,2) DEFAULT NULL COMMENT ''钠含量(mg/100g,高血压用户需控制<2000mg/天)''',
    'SELECT ''sodium_per_100g already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 三、添加嘌呤含量字段
-- ================================
-- 数值范围：0-1000 mg/100g（极少数食物超过1000）
-- 用途：痛风用户推荐算法

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'purine_per_100g';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN purine_per_100g DECIMAL(8,2) DEFAULT NULL COMMENT ''嘌呤含量(mg/100g,痛风用户需控制:低嘌呤<50,中嘌呤50-150,高嘌呤>150)''',
    'SELECT ''purine_per_100g already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 四、添加胆固醇含量字段
-- ================================
-- 数值范围：0-5000 mg/100g（动物内脏等高胆固醇食物）
-- 用途：高血脂用户推荐算法

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'cholesterol_per_100g';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN cholesterol_per_100g DECIMAL(8,2) DEFAULT NULL COMMENT ''胆固醇含量(mg/100g,高血脂用户需控制<300mg/天)''',
    'SELECT ''cholesterol_per_100g already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 五、添加过敏原标签字段
-- ================================
-- 数据格式：JSON数组，如 ["peanuts","dairy","gluten"]
-- 用途：过敏用户安全推荐

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'allergen_tags';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN allergen_tags VARCHAR(500) DEFAULT NULL COMMENT ''过敏原标签(JSON数组格式,如["peanuts","dairy","gluten","soy","egg","fish","shellfish"])''',
    'SELECT ''allergen_tags already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 六、添加适用人群标签字段
-- ================================
-- 数据格式：JSON数组，如 ["healthy","diabetes_ok","pregnancy_ok"]
-- 用途：正向推荐规则引擎

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'suitable_for';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN suitable_for VARCHAR(500) DEFAULT NULL COMMENT ''适用人群标签(JSON数组格式,如["healthy","diabetes","hypertension","pregnancy","children"])''',
    'SELECT ''suitable_for already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 七、添加不适用人群标签字段
-- ================================
-- 数据格式：JSON数组，如 ["diabetes","gout","pregnancy"]
-- 用途：负向过滤规则引擎

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'unsuitable_for';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN unsuitable_for VARCHAR(500) DEFAULT NULL COMMENT ''不适用人群标签(JSON数组格式,如["diabetes","hypertension","gout","pregnancy","children","kidney_disease"])''',
    'SELECT ''unsuitable_for already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 八、添加数据来源标识字段
-- ================================
-- 用于标记数据是权威来源还是推断值
-- 值：'official'(官方数据), 'inferred'(推断), 'manual'(人工录入)

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'data_source';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN data_source VARCHAR(50) DEFAULT ''manual'' COMMENT ''数据来源(official:权威数据源,inferred:算法推断,manual:人工录入)''',
    'SELECT ''data_source already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 九、添加最后更新时间字段
-- ================================

SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'last_update_time';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD COLUMN last_update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''最后更新时间''',
    'SELECT ''last_update_time already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 十、创建索引优化查询性能
-- ================================

-- GI值索引（用于糖尿病用户快速筛选低GI食物）
SET @index_exists = 0;
SELECT COUNT(*) INTO @index_exists 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND INDEX_NAME = 'idx_gi_value';

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_gi_value ON diet_food_nutrition(gi_value)',
    'SELECT ''Index idx_gi_value already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 钠含量索引（用于高血压用户快速筛选低钠食物）
SET @index_exists = 0;
SELECT COUNT(*) INTO @index_exists 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND INDEX_NAME = 'idx_sodium';

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_sodium ON diet_food_nutrition(sodium_per_100g)',
    'SELECT ''Index idx_sodium already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 嘌呤含量索引（用于痛风用户快速筛选低嘌呤食物）
SET @index_exists = 0;
SELECT COUNT(*) INTO @index_exists 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND INDEX_NAME = 'idx_purine';

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_purine ON diet_food_nutrition(purine_per_100g)',
    'SELECT ''Index idx_purine already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 胆固醇含量索引（用于高血脂用户快速筛选低胆固醇食物）
SET @index_exists = 0;
SELECT COUNT(*) INTO @index_exists 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND INDEX_NAME = 'idx_cholesterol';

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_cholesterol ON diet_food_nutrition(cholesterol_per_100g)',
    'SELECT ''Index idx_cholesterol already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 十一、添加数据约束（确保数据合理性）
-- ================================
-- 注意：CHECK约束在MySQL 8.0.16+才支持，旧版本会忽略

-- GI值范围约束
SET @constraint_exists = 0;
SELECT COUNT(*) INTO @constraint_exists 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND CONSTRAINT_NAME = 'chk_gi_value';

SET @sql = IF(@constraint_exists = 0,
    'ALTER TABLE diet_food_nutrition ADD CONSTRAINT chk_gi_value CHECK (gi_value IS NULL OR (gi_value >= 0 AND gi_value <= 100))',
    'SELECT ''Constraint chk_gi_value already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 十二、验证字段添加结果
-- ================================

SELECT '========== 字段扩展完成，验证结果 ==========' AS '验证';

-- 查看新增字段
SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    COLUMN_TYPE AS '完整类型',
    IS_NULLABLE AS '可空',
    COLUMN_DEFAULT AS '默认值',
    COLUMN_COMMENT AS '注释'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition'
  AND COLUMN_NAME IN ('gi_value', 'sodium_per_100g', 'purine_per_100g', 'cholesterol_per_100g', 
                       'allergen_tags', 'suitable_for', 'unsuitable_for', 'data_source', 'last_update_time')
ORDER BY ORDINAL_POSITION;

-- 统计扩展字段覆盖率
SELECT 
    '扩展字段覆盖率统计' AS '统计项',
    COUNT(*) AS '总记录数',
    COUNT(gi_value) AS 'GI值记录数',
    ROUND(COUNT(gi_value) * 100.0 / COUNT(*), 2) AS 'GI值覆盖率(%)',
    COUNT(sodium_per_100g) AS '钠含量记录数',
    ROUND(COUNT(sodium_per_100g) * 100.0 / COUNT(*), 2) AS '钠覆盖率(%)',
    COUNT(purine_per_100g) AS '嘌呤记录数',
    ROUND(COUNT(purine_per_100g) * 100.0 / COUNT(*), 2) AS '嘌呤覆盖率(%)',
    COUNT(cholesterol_per_100g) AS '胆固醇记录数',
    ROUND(COUNT(cholesterol_per_100g) * 100.0 / COUNT(*), 2) AS '胆固醇覆盖率(%)'
FROM diet_food_nutrition;

SELECT '✓ 字段扩展完成！下一步：执行import_food_nutrition_data.sql补充营养数据' AS '提示';

