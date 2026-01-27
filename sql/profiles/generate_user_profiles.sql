-- ================================
-- 生成用户画像数据 - 基于年龄分层的饮食偏好
-- ================================
-- 执行说明：
-- 1. 基于现有100条用户数据，按年龄分层生成饮食偏好
-- 2. 18-30岁：30%添加"低糖"偏好
-- 3. 50岁以上：50%添加"低盐"偏好
-- 4. 确保符合真实人群饮食需求
-- ================================

USE smart_diet_dev;

SELECT '========== 开始生成用户画像数据 ==========' AS '开始';

-- ================================
-- 一、18-30岁年轻人群（注重体型管理）
-- ================================

-- 30%年轻人添加低糖偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_ARRAY('low_sugar', 'high_protein'),
    recommendation_strategy = 'balanced',
    diet_restriction_level = 'moderate',
    profile_generated_time = NOW()
WHERE 
    age >= 18 AND age < 30
    AND MOD(user_id, 10) < 3;  -- 30%概率

-- 超重年轻人添加减重偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_ARRAY('weight_loss', 'low_fat'),
    recommendation_strategy = 'health',
    diet_restriction_level = 'strict',
    profile_generated_time = NOW()
WHERE 
    age >= 18 AND age < 30
    AND bmi >= 24  -- 超重用户
    AND (diet_preferences IS NULL OR JSON_LENGTH(diet_preferences) = 0);

-- 其余年轻人默认均衡饮食
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_ARRAY('balanced'),
    recommendation_strategy = 'taste',
    diet_restriction_level = 'flexible',
    profile_generated_time = NOW()
WHERE 
    age >= 18 AND age < 30
    AND (diet_preferences IS NULL OR JSON_LENGTH(diet_preferences) = 0);

-- ================================
-- 二、30-50岁中年人群（关注健康）
-- ================================

UPDATE sys_user_health 
SET 
    diet_preferences = JSON_ARRAY('balanced', 'low_salt'),
    recommendation_strategy = 'health',
    diet_restriction_level = 'moderate',
    profile_generated_time = NOW()
WHERE 
    age >= 30 AND age < 50
    AND (diet_preferences IS NULL OR JSON_LENGTH(diet_preferences) = 0);

-- ================================
-- 三、50岁以上中老年人群（低盐低脂）
-- ================================

-- 50%老年人添加低盐偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_ARRAY('low_salt', 'low_fat', 'soft_food'),
    recommendation_strategy = 'health',
    diet_restriction_level = 'strict',
    profile_generated_time = NOW()
WHERE 
    age >= 50;

-- ================================
-- 四、基于慢性病调整偏好
-- ================================

-- 糖尿病用户强制添加低糖偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_MERGE_PRESERVE(
        COALESCE(diet_preferences, JSON_ARRAY()), 
        JSON_ARRAY('low_sugar', 'low_gi')
    ),
    diet_restriction_level = 'strict',
    disease_severity = CASE 
        WHEN diseases LIKE '%severe%' THEN 'severe'
        WHEN diseases LIKE '%moderate%' THEN 'moderate'
        ELSE 'mild'
    END
WHERE 
    diseases LIKE '%diabetes%';

-- 高血压用户强制添加低盐偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_MERGE_PRESERVE(
        COALESCE(diet_preferences, JSON_ARRAY()), 
        JSON_ARRAY('low_salt')
    ),
    diet_restriction_level = 'strict',
    disease_severity = CASE 
        WHEN diseases LIKE '%severe%' THEN 'severe'
        WHEN diseases LIKE '%moderate%' THEN 'moderate'
        ELSE 'mild'
    END
WHERE 
    diseases LIKE '%hypertension%';

-- 痛风用户添加低嘌呤偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_MERGE_PRESERVE(
        COALESCE(diet_preferences, JSON_ARRAY()), 
        JSON_ARRAY('low_purine')
    ),
    diet_restriction_level = 'strict'
WHERE 
    diseases LIKE '%gout%';

-- 高血脂用户添加低脂偏好
UPDATE sys_user_health 
SET 
    diet_preferences = JSON_MERGE_PRESERVE(
        COALESCE(diet_preferences, JSON_ARRAY()), 
        JSON_ARRAY('low_fat', 'low_cholesterol')
    ),
    diet_restriction_level = 'strict'
WHERE 
    diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%';

-- ================================
-- 五、生成不喜欢的食材（随机2-5种）
-- ================================

-- 为40%的用户生成不喜欢的食材
UPDATE sys_user_health 
SET 
    food_dislikes = ELT(
        MOD(user_id, 10) + 1,
        JSON_ARRAY('broccoli', 'cilantro'),
        JSON_ARRAY('durian', 'blue_cheese'),
        JSON_ARRAY('liver', 'kidney'),
        JSON_ARRAY('bitter_melon', 'celery'),
        JSON_ARRAY('eggplant', 'mushroom'),
        JSON_ARRAY('onion', 'garlic'),
        JSON_ARRAY('fish', 'seafood'),
        JSON_ARRAY('spicy_food'),
        JSON_ARRAY('beans', 'soy'),
        JSON_ARRAY()
    )
WHERE 
    MOD(user_id, 10) < 4;  -- 40%用户有不喜欢的食材

-- ================================
-- 六、设置最后体检时间
-- ================================

-- 为所有用户设置最后体检时间（最近3个月内）
UPDATE sys_user_health 
SET 
    last_checkup_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 90) DAY)
WHERE 
    last_checkup_date IS NULL;

-- ================================
-- 七、验证画像生成结果
-- ================================

SELECT '========== 用户画像生成完成，验证结果 ==========' AS '验证';

-- 统计饮食偏好分布
SELECT 
    '饮食偏好统计' AS '统计项',
    COUNT(*) AS '总用户数',
    COUNT(diet_preferences) AS '有偏好用户数',
    ROUND(COUNT(diet_preferences) * 100.0 / COUNT(*), 2) AS '覆盖率(%)'
FROM sys_user_health;

-- 按年龄段统计偏好分布
SELECT 
    '年龄段偏好分布' AS '统计类别',
    CASE 
        WHEN age < 30 THEN '18-30岁'
        WHEN age < 50 THEN '30-50岁'
        ELSE '50岁以上'
    END AS '年龄段',
    COUNT(*) AS '人数',
    COUNT(CASE WHEN diet_preferences LIKE '%low_sugar%' THEN 1 END) AS '低糖偏好',
    COUNT(CASE WHEN diet_preferences LIKE '%low_salt%' THEN 1 END) AS '低盐偏好',
    COUNT(CASE WHEN diet_preferences LIKE '%low_fat%' THEN 1 END) AS '低脂偏好',
    COUNT(food_dislikes) AS '有不喜欢食材'
FROM sys_user_health
GROUP BY 
    CASE 
        WHEN age < 30 THEN '18-30岁'
        WHEN age < 50 THEN '30-50岁'
        ELSE '50岁以上'
    END;

-- 慢性病用户偏好统计
SELECT 
    '慢性病用户偏好' AS '统计类别',
    diseases AS '疾病类型',
    COUNT(*) AS '用户数',
    diet_preferences AS '饮食偏好',
    diet_restriction_level AS '限制强度'
FROM sys_user_health
WHERE diseases IS NOT NULL AND diseases != ''
GROUP BY diseases, diet_preferences, diet_restriction_level
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 样本数据展示
SELECT '用户画像样本展示(前10条)' AS '样本';
SELECT 
    user_id AS '用户ID',
    age AS '年龄',
    CASE WHEN gender='0' THEN '男' WHEN gender='1' THEN '女' END AS '性别',
    diseases AS '慢性病',
    diet_preferences AS '饮食偏好',
    food_dislikes AS '不喜欢食材',
    recommendation_strategy AS '推荐策略',
    diet_restriction_level AS '限制强度'
FROM sys_user_health
WHERE diet_preferences IS NOT NULL
ORDER BY user_id
LIMIT 10;

SELECT '✓ 用户画像生成完成！' AS '完成提示',
       CONCAT('共生成 ', COUNT(*), ' 个用户画像') AS '统计'
FROM sys_user_health 
WHERE diet_preferences IS NOT NULL;

