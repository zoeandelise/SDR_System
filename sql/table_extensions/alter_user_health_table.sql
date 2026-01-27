-- ================================
-- 扩展用户健康表结构 - 添加算法所需关键字段
-- ================================
-- 执行说明：
-- 1. 执行前请备份sys_user_health表数据
-- 2. 建议先在测试环境验证
-- 3. 执行时间约5-10秒
-- 4. 字段设计已考虑后续计算和查询优化
-- ================================

USE smart_diet_dev;

-- 检查表是否存在
SELECT 
    CASE WHEN COUNT(*) > 0 THEN '✓ sys_user_health表存在，开始扩展字段' ELSE '✗ 表不存在，请先创建基础表' END AS '检查结果'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smart_diet_dev' AND TABLE_NAME = 'sys_user_health';

-- ================================
-- 一、添加BMI字段（Body Mass Index 体质指数）
-- ================================
-- 计算公式：BMI = 体重(kg) / (身高(m))²
-- 分类：<18.5偏瘦, 18.5-24正常, 24-28超重, ≥28肥胖

-- 检查并添加bmi字段
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'sys_user_health' 
  AND COLUMN_NAME = 'bmi';

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE sys_user_health ADD COLUMN bmi DECIMAL(5,2) DEFAULT NULL COMMENT ''BMI体质指数(计算字段:weight/POWER(height/100,2),<18.5偏瘦,18.5-24正常,24-28超重,≥28肥胖)''',
    'SELECT ''bmi already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 二、添加BMR字段（Basal Metabolic Rate 基础代谢率）
-- ================================
-- 计算公式（Harris-Benedict）：
-- 男性：BMR = 88.362 + (13.397 × 体重kg) + (4.799 × 身高cm) - (5.677 × 年龄)
-- 女性：BMR = 447.593 + (9.247 × 体重kg) + (3.098 × 身高cm) - (4.330 × 年龄)

-- 检查并添加bmr字段
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'sys_user_health' 
  AND COLUMN_NAME = 'bmr';

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE sys_user_health ADD COLUMN bmr INT DEFAULT NULL COMMENT ''基础代谢率BMR(kcal/天,根据Harris-Benedict公式计算,用于每日热量目标设定)''',
    'SELECT ''bmr already exists'' AS Info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================
-- 三、添加饮食偏好标签字段
-- ================================
-- 数据格式：JSON数组，如 ["vegetarian","low_sugar","halal"]
-- 常见值：vegetarian(素食), vegan(严格素食), halal(清真), kosher(犹太洁食),
--        low_sugar(低糖), low_salt(低盐), low_fat(低脂), high_protein(高蛋白)

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS diet_preferences VARCHAR(500) DEFAULT NULL 
COMMENT '饮食偏好标签(JSON数组,如["vegetarian","low_sugar","halal","low_salt","high_protein"])';

-- ================================
-- 四、添加不喜欢的食材列表字段
-- ================================
-- 数据格式：JSON数组，如 ["broccoli","cilantro","durian"]
-- 用于个性化推荐时过滤用户不喜欢的食材

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS food_dislikes VARCHAR(1000) DEFAULT NULL 
COMMENT '不喜欢的食材列表(JSON数组,如["broccoli","cilantro","durian"],用于推荐过滤)';

-- ================================
-- 五、添加推荐策略偏好字段
-- ================================
-- 值：balanced(营养均衡优先), health(健康优先), taste(口味优先), variety(多样性优先)

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS recommendation_strategy VARCHAR(50) DEFAULT 'balanced' 
COMMENT '推荐策略偏好(balanced:营养均衡,health:健康优先,taste:口味优先,variety:多样性)';

-- ================================
-- 六、添加饮食限制强度字段
-- ================================
-- 值：strict(严格,完全遵循健康规则), moderate(适中,允许偶尔例外), flexible(灵活,仅提示)
-- 用于控制推荐算法对健康规则的严格程度

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS diet_restriction_level VARCHAR(20) DEFAULT 'moderate' 
COMMENT '饮食限制强度(strict:严格遵循,moderate:适中,flexible:灵活提示)';

-- ================================
-- 七、添加用户画像生成时间字段
-- ================================

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS profile_generated_time DATETIME DEFAULT NULL 
COMMENT '用户画像生成时间(用于标记画像数据的时效性)';

-- ================================
-- 八、添加每日蛋白质目标字段
-- ================================
-- 推荐摄入：1.2-1.5 g/kg体重（根据活动量调整）

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS daily_protein_goal DECIMAL(6,2) DEFAULT NULL 
COMMENT '每日蛋白质目标(g/天,推荐1.2-1.5g/kg体重,根据活动量调整)';

-- ================================
-- 九、添加每日碳水化合物目标字段
-- ================================
-- 推荐摄入：占总热量50-65%

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS daily_carb_goal DECIMAL(6,2) DEFAULT NULL 
COMMENT '每日碳水化合物目标(g/天,推荐占总热量50-65%)';

-- ================================
-- 十、添加每日脂肪目标字段
-- ================================
-- 推荐摄入：占总热量20-30%

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS daily_fat_goal DECIMAL(6,2) DEFAULT NULL 
COMMENT '每日脂肪目标(g/天,推荐占总热量20-30%)';

-- ================================
-- 十一、添加慢性病严重程度字段
-- ================================
-- 值：mild(轻度), moderate(中度), severe(重度)
-- 用于根据病情严重程度调整饮食限制力度

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS disease_severity VARCHAR(20) DEFAULT NULL 
COMMENT '慢性病严重程度(mild:轻度,moderate:中度,severe:重度,用于调整饮食限制强度)';

-- ================================
-- 十二、添加最后体检时间字段
-- ================================
-- 用于判断健康数据的时效性

ALTER TABLE sys_user_health 
ADD COLUMN IF NOT EXISTS last_checkup_date DATE DEFAULT NULL 
COMMENT '最后体检日期(用于判断健康数据时效性)';

-- ================================
-- 十三、创建索引优化查询性能
-- ================================

-- BMI索引（用于按体型筛选用户）
CREATE INDEX IF NOT EXISTS idx_bmi ON sys_user_health(bmi);

-- BMR索引（用于按代谢率筛选）
CREATE INDEX IF NOT EXISTS idx_bmr ON sys_user_health(bmr);

-- 慢性病索引（用于按疾病类型筛选）
CREATE INDEX IF NOT EXISTS idx_diseases ON sys_user_health(diseases);

-- 过敏原索引（用于安全推荐）
CREATE INDEX IF NOT EXISTS idx_allergies ON sys_user_health(allergies);

-- ================================
-- 十四、添加数据约束（确保数据合理性）
-- ================================

-- BMI范围约束（考虑极端体型，范围10-60）
ALTER TABLE sys_user_health 
ADD CONSTRAINT chk_bmi CHECK (bmi IS NULL OR (bmi >= 10 AND bmi <= 60));

-- BMR范围约束（成年人基础代谢率800-3000）
ALTER TABLE sys_user_health 
ADD CONSTRAINT chk_bmr CHECK (bmr IS NULL OR (bmr >= 800 AND bmr <= 5000));

-- 每日热量目标约束（800-5000 kcal）
ALTER TABLE sys_user_health 
ADD CONSTRAINT chk_daily_calorie CHECK (daily_calorie_goal IS NULL OR (daily_calorie_goal >= 800 AND daily_calorie_goal <= 5000));

-- 蛋白质目标约束（20-500g）
ALTER TABLE sys_user_health 
ADD CONSTRAINT chk_protein_goal CHECK (daily_protein_goal IS NULL OR (daily_protein_goal >= 20 AND daily_protein_goal <= 500));

-- ================================
-- 十五、验证字段添加结果
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
  AND TABLE_NAME = 'sys_user_health'
  AND COLUMN_NAME IN ('bmi', 'bmr', 'diet_preferences', 'food_dislikes', 'recommendation_strategy',
                       'diet_restriction_level', 'daily_protein_goal', 'daily_carb_goal', 'daily_fat_goal',
                       'disease_severity', 'last_checkup_date', 'profile_generated_time')
ORDER BY ORDINAL_POSITION;

-- 统计扩展字段覆盖率
SELECT 
    '扩展字段覆盖率统计' AS '统计项',
    COUNT(*) AS '总用户数',
    COUNT(bmi) AS 'BMI记录数',
    ROUND(COUNT(bmi) * 100.0 / COUNT(*), 2) AS 'BMI覆盖率(%)',
    COUNT(bmr) AS 'BMR记录数',
    ROUND(COUNT(bmr) * 100.0 / COUNT(*), 2) AS 'BMR覆盖率(%)',
    COUNT(diet_preferences) AS '饮食偏好记录数',
    ROUND(COUNT(diet_preferences) * 100.0 / COUNT(*), 2) AS '饮食偏好覆盖率(%)',
    COUNT(food_dislikes) AS '不喜欢食材记录数',
    ROUND(COUNT(food_dislikes) * 100.0 / COUNT(*), 2) AS '不喜欢食材覆盖率(%)'
FROM sys_user_health;

SELECT '✓ 字段扩展完成！下一步：执行calculate_user_metrics.sql计算BMI和BMR' AS '提示';

