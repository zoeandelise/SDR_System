-- ================================
-- 健康饮食规则引擎 - 食物与人群映射规则
-- ================================
-- 执行说明：
-- 1. 需要先执行alter_food_nutrition_table.sql添加标签字段
-- 2. 根据营养成分自动标注食物的适用/不适用人群
-- 3. 包含特殊人群规则（孕妇、儿童、老年人等）
-- ================================

USE smart_diet_dev;

-- ================================
-- 一、基于GI值的糖尿病规则
-- ================================

UPDATE diet_food_nutrition 
SET 
    suitable_for = CASE 
        WHEN gi_value IS NOT NULL AND gi_value < 55 THEN 
            JSON_ARRAY('healthy', 'diabetes', 'prediabetes', 'weight_loss')
        WHEN gi_value IS NOT NULL AND gi_value BETWEEN 55 AND 70 THEN 
            JSON_ARRAY('healthy', 'moderate_diabetes')
        ELSE suitable_for
    END,
    unsuitable_for = CASE 
        WHEN gi_value IS NOT NULL AND gi_value > 70 THEN 
            JSON_ARRAY('diabetes', 'prediabetes', 'insulin_resistance')
        ELSE unsuitable_for
    END
WHERE gi_value IS NOT NULL;

-- ================================
-- 二、基于钠含量的高血压规则
-- ================================

UPDATE diet_food_nutrition 
SET 
    suitable_for = CASE 
        WHEN sodium_per_100g IS NOT NULL AND sodium_per_100g < 120 THEN 
            JSON_MERGE_PRESERVE(COALESCE(suitable_for, JSON_ARRAY()), JSON_ARRAY('hypertension', 'heart_disease', 'kidney_disease'))
        ELSE suitable_for
    END,
    unsuitable_for = CASE 
        WHEN sodium_per_100g IS NOT NULL AND sodium_per_100g > 300 THEN 
            JSON_MERGE_PRESERVE(COALESCE(unsuitable_for, JSON_ARRAY()), JSON_ARRAY('hypertension', 'heart_disease', 'kidney_disease'))
        ELSE unsuitable_for
    END
WHERE sodium_per_100g IS NOT NULL;

-- ================================
-- 三、基于嘌呤含量的痛风规则
-- ================================

UPDATE diet_food_nutrition 
SET 
    suitable_for = CASE 
        WHEN purine_per_100g IS NOT NULL AND purine_per_100g < 50 THEN 
            JSON_MERGE_PRESERVE(COALESCE(suitable_for, JSON_ARRAY()), JSON_ARRAY('gout', 'hyperuricemia'))
        ELSE suitable_for
    END,
    unsuitable_for = CASE 
        WHEN purine_per_100g IS NOT NULL AND purine_per_100g > 150 THEN 
            JSON_MERGE_PRESERVE(COALESCE(unsuitable_for, JSON_ARRAY()), JSON_ARRAY('gout', 'hyperuricemia'))
        ELSE unsuitable_for
    END
WHERE purine_per_100g IS NOT NULL;

-- ================================
-- 四、基于胆固醇的高血脂规则
-- ================================

UPDATE diet_food_nutrition 
SET 
    suitable_for = CASE 
        WHEN cholesterol_per_100g IS NOT NULL AND cholesterol_per_100g < 100 THEN 
            JSON_MERGE_PRESERVE(COALESCE(suitable_for, JSON_ARRAY()), JSON_ARRAY('hyperlipidemia', 'high_cholesterol'))
        ELSE suitable_for
    END,
    unsuitable_for = CASE 
        WHEN cholesterol_per_100g IS NOT NULL AND cholesterol_per_100g > 200 THEN 
            JSON_MERGE_PRESERVE(COALESCE(unsuitable_for, JSON_ARRAY()), JSON_ARRAY('hyperlipidemia', 'high_cholesterol'))
        ELSE unsuitable_for
    END
WHERE cholesterol_per_100g IS NOT NULL;

-- ================================
-- 五、特殊人群规则 - 孕妇
-- ================================

-- 孕妇不宜高汞鱼类（需要基于食物名称判断）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.unsuitable_for = JSON_MERGE_PRESERVE(COALESCE(n.unsuitable_for, JSON_ARRAY()), JSON_ARRAY('pregnancy'))
WHERE 
    f.food_name IN ('金枪鱼', '鲨鱼', '旗鱼', '马林鱼', '方头鱼')
    OR f.food_name LIKE '%金枪鱼%'
    OR f.food_name LIKE '%鲨鱼%';

-- 孕妇适宜高叶酸食物（绿叶蔬菜、豆类）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
INNER JOIN diet_food_category c ON f.category_id = c.category_id
SET 
    n.suitable_for = JSON_MERGE_PRESERVE(COALESCE(n.suitable_for, JSON_ARRAY()), JSON_ARRAY('pregnancy'))
WHERE 
    c.category_name LIKE '%蔬菜%'
    AND (f.food_name LIKE '%菠菜%' OR f.food_name LIKE '%西兰花%' OR f.food_name LIKE '%芦笋%');

-- ================================
-- 六、特殊人群规则 - 儿童
-- ================================

-- 儿童需要高钙食材（牛奶、豆腐、奶酪）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.suitable_for = JSON_MERGE_PRESERVE(COALESCE(n.suitable_for, JSON_ARRAY()), JSON_ARRAY('children', 'adolescents'))
WHERE 
    f.food_name IN ('牛奶', '酸奶', '豆腐', '奶酪', '芝麻', '虾皮')
    OR f.food_name LIKE '%牛奶%'
    OR f.food_name LIKE '%奶酪%';

-- 儿童不宜辛辣刺激食物
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.unsuitable_for = JSON_MERGE_PRESERVE(COALESCE(n.unsuitable_for, JSON_ARRAY()), JSON_ARRAY('children'))
WHERE 
    f.food_name LIKE '%辣椒%'
    OR f.food_name LIKE '%芥末%'
    OR f.food_name LIKE '%花椒%';

-- ================================
-- 七、验证规则应用结果
-- ================================

SELECT '========== 规则应用完成，验证结果 ==========' AS '提示';

SELECT 
    '规则类型' AS '类别',
    '适用人群标签数' AS '数量',
    '不适用人群标签数' AS '数量2'
UNION ALL
SELECT 
    '糖尿病规则',
    CAST(COUNT(CASE WHEN suitable_for LIKE '%diabetes%' THEN 1 END) AS CHAR),
    CAST(COUNT(CASE WHEN unsuitable_for LIKE '%diabetes%' THEN 1 END) AS CHAR)
FROM diet_food_nutrition
UNION ALL
SELECT 
    '高血压规则',
    CAST(COUNT(CASE WHEN suitable_for LIKE '%hypertension%' THEN 1 END) AS CHAR),
    CAST(COUNT(CASE WHEN unsuitable_for LIKE '%hypertension%' THEN 1 END) AS CHAR)
FROM diet_food_nutrition
UNION ALL
SELECT 
    '痛风规则',
    CAST(COUNT(CASE WHEN suitable_for LIKE '%gout%' THEN 1 END) AS CHAR),
    CAST(COUNT(CASE WHEN unsuitable_for LIKE '%gout%' THEN 1 END) AS CHAR)
FROM diet_food_nutrition
UNION ALL
SELECT 
    '孕妇规则',
    CAST(COUNT(CASE WHEN suitable_for LIKE '%pregnancy%' THEN 1 END) AS CHAR),
    CAST(COUNT(CASE WHEN unsuitable_for LIKE '%pregnancy%' THEN 1 END) AS CHAR)
FROM diet_food_nutrition
UNION ALL
SELECT 
    '儿童规则',
    CAST(COUNT(CASE WHEN suitable_for LIKE '%children%' THEN 1 END) AS CHAR),
    CAST(COUNT(CASE WHEN unsuitable_for LIKE '%children%' THEN 1 END) AS CHAR)
FROM diet_food_nutrition;

SELECT '✓ 健康规则映射完成！' AS '完成提示';

