-- ================================
-- 计算用户健康指标 - BMI和BMR
-- ================================
-- 执行说明：
-- 1. 需要先执行alter_user_health_table.sql添加bmi和bmr字段
-- 2. 包含异常值过滤逻辑（age>120或height<50时不计算）
-- 3. 执行时间约5-15秒（取决于用户数量）
-- 4. 建议先在测试环境验证计算结果
-- ================================

USE smart_diet_dev;

-- ================================
-- 一、数据质量预检查
-- ================================

SELECT '========== 开始数据质量预检查 ==========' AS '检查阶段';

-- 检查异常数据
SELECT 
    '异常数据统计' AS '统计项',
    COUNT(CASE WHEN height < 50 OR height > 250 THEN 1 END) AS '身高异常数',
    COUNT(CASE WHEN weight < 20 OR weight > 300 THEN 1 END) AS '体重异常数',
    COUNT(CASE WHEN age < 1 OR age > 120 THEN 1 END) AS '年龄异常数',
    COUNT(CASE WHEN height IS NULL OR height <= 0 THEN 1 END) AS '身高空值数',
    COUNT(CASE WHEN weight IS NULL OR weight <= 0 THEN 1 END) AS '体重空值数',
    COUNT(CASE WHEN age IS NULL OR age <= 0 THEN 1 END) AS '年龄空值数'
FROM sys_user_health;

-- 显示异常数据明细（用于人工核查）
SELECT 
    '异常数据明细(需人工核查)' AS '提示',
    user_id AS '用户ID',
    height AS '身高(cm)',
    weight AS '体重(kg)',
    age AS '年龄',
    gender AS '性别',
    CASE 
        WHEN height < 50 OR height > 250 THEN '身高异常'
        WHEN weight < 20 OR weight > 300 THEN '体重异常'
        WHEN age < 1 OR age > 120 THEN '年龄异常'
        WHEN height IS NULL OR height <= 0 THEN '身高缺失'
        WHEN weight IS NULL OR weight <= 0 THEN '体重缺失'
        WHEN age IS NULL OR age <= 0 THEN '年龄缺失'
        ELSE '其他异常'
    END AS '异常类型'
FROM sys_user_health
WHERE 
    height < 50 OR height > 250 OR height IS NULL OR height <= 0
    OR weight < 20 OR weight > 300 OR weight IS NULL OR weight <= 0
    OR age < 1 OR age > 120 OR age IS NULL OR age <= 0
ORDER BY user_id;

SELECT '' AS '';

-- ================================
-- 二、计算BMI（Body Mass Index）
-- ================================

SELECT '========== 开始计算BMI ==========' AS '计算阶段';

-- 计算公式：BMI = 体重(kg) / (身高(m))²
-- 只计算数据合理的用户（height: 50-250cm, weight: 20-300kg）

UPDATE sys_user_health 
SET 
    bmi = ROUND(weight / POWER(height/100, 2), 2),
    profile_generated_time = NOW()
WHERE 
    height >= 50 AND height <= 250  -- 身高合理范围
    AND weight >= 20 AND weight <= 300  -- 体重合理范围
    AND height IS NOT NULL 
    AND weight IS NOT NULL
    AND height > 0 
    AND weight > 0;

-- 验证BMI计算结果
SELECT 
    'BMI计算结果统计' AS '统计项',
    COUNT(*) AS '总用户数',
    COUNT(bmi) AS 'BMI计算成功数',
    ROUND(COUNT(bmi) * 100.0 / COUNT(*), 2) AS '计算覆盖率(%)',
    ROUND(MIN(bmi), 2) AS '最小BMI',
    ROUND(MAX(bmi), 2) AS '最大BMI',
    ROUND(AVG(bmi), 2) AS '平均BMI'
FROM sys_user_health;

-- BMI分布统计
SELECT 
    'BMI分布统计' AS '统计项',
    COUNT(CASE WHEN bmi < 18.5 THEN 1 END) AS '偏瘦(<18.5)',
    ROUND(COUNT(CASE WHEN bmi < 18.5 THEN 1 END) * 100.0 / NULLIF(COUNT(bmi), 0), 2) AS '偏瘦占比(%)',
    COUNT(CASE WHEN bmi >= 18.5 AND bmi < 24 THEN 1 END) AS '正常(18.5-24)',
    ROUND(COUNT(CASE WHEN bmi >= 18.5 AND bmi < 24 THEN 1 END) * 100.0 / NULLIF(COUNT(bmi), 0), 2) AS '正常占比(%)',
    COUNT(CASE WHEN bmi >= 24 AND bmi < 28 THEN 1 END) AS '超重(24-28)',
    ROUND(COUNT(CASE WHEN bmi >= 24 AND bmi < 28 THEN 1 END) * 100.0 / NULLIF(COUNT(bmi), 0), 2) AS '超重占比(%)',
    COUNT(CASE WHEN bmi >= 28 THEN 1 END) AS '肥胖(≥28)',
    ROUND(COUNT(CASE WHEN bmi >= 28 THEN 1 END) * 100.0 / NULLIF(COUNT(bmi), 0), 2) AS '肥胖占比(%)'
FROM sys_user_health;

SELECT '' AS '';

-- ================================
-- 三、计算BMR（Basal Metabolic Rate 基础代谢率）
-- ================================

SELECT '========== 开始计算BMR ==========' AS '计算阶段';

-- Harris-Benedict公式：
-- 男性(gender='0')：BMR = 88.362 + (13.397 × 体重kg) + (4.799 × 身高cm) - (5.677 × 年龄)
-- 女性(gender='1')：BMR = 447.593 + (9.247 × 体重kg) + (3.098 × 身高cm) - (4.330 × 年龄)
-- 只计算数据合理的用户

UPDATE sys_user_health 
SET 
    bmr = CASE 
        -- 男性
        WHEN gender = '0' THEN 
            ROUND(88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age))
        -- 女性
        WHEN gender = '1' THEN 
            ROUND(447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age))
        ELSE NULL
    END,
    profile_generated_time = NOW()
WHERE 
    height >= 50 AND height <= 250  -- 身高合理范围
    AND weight >= 20 AND weight <= 300  -- 体重合理范围
    AND age >= 1 AND age <= 120  -- 年龄合理范围
    AND height IS NOT NULL 
    AND weight IS NOT NULL
    AND age IS NOT NULL
    AND gender IS NOT NULL
    AND gender IN ('0', '1')
    AND height > 0 
    AND weight > 0
    AND age > 0;

-- 验证BMR计算结果
SELECT 
    'BMR计算结果统计' AS '统计项',
    COUNT(*) AS '总用户数',
    COUNT(bmr) AS 'BMR计算成功数',
    ROUND(COUNT(bmr) * 100.0 / COUNT(*), 2) AS '计算覆盖率(%)',
    MIN(bmr) AS '最小BMR(kcal/天)',
    MAX(bmr) AS '最大BMR(kcal/天)',
    ROUND(AVG(bmr)) AS '平均BMR(kcal/天)'
FROM sys_user_health;

-- BMR按性别分布统计
SELECT 
    'BMR按性别分布' AS '统计项',
    CASE WHEN gender = '0' THEN '男性' WHEN gender = '1' THEN '女性' ELSE '未知' END AS '性别',
    COUNT(bmr) AS '计算成功数',
    ROUND(AVG(bmr)) AS '平均BMR',
    MIN(bmr) AS '最小BMR',
    MAX(bmr) AS '最大BMR'
FROM sys_user_health
WHERE bmr IS NOT NULL
GROUP BY gender;

SELECT '' AS '';

-- ================================
-- 四、计算每日营养素目标（基于BMR和活动量）
-- ================================

SELECT '========== 开始计算每日营养素目标 ==========' AS '计算阶段';

-- 总热量 = BMR × 活动系数
-- activity_level: 1=久坐(1.2), 2=轻度活动(1.375), 3=中度活动(1.55), 4=重度活动(1.725), 5=极重度(1.9)
-- 蛋白质：1.2-1.5 g/kg体重（根据活动量）
-- 碳水：占总热量50-60% (1g碳水=4kcal)
-- 脂肪：占总热量20-30% (1g脂肪=9kcal)

UPDATE sys_user_health 
SET 
    -- 每日热量目标（如果未手动设置）
    daily_calorie_goal = CASE 
        WHEN daily_calorie_goal IS NULL OR daily_calorie_goal = 0 THEN
            ROUND(bmr * CASE 
                WHEN activity_level = '1' THEN 1.2
                WHEN activity_level = '2' THEN 1.375
                WHEN activity_level = '3' THEN 1.55
                WHEN activity_level = '4' THEN 1.725
                WHEN activity_level = '5' THEN 1.9
                ELSE 1.375  -- 默认轻度活动
            END)
        ELSE daily_calorie_goal
    END,
    
    -- 蛋白质目标（1.2-1.5 g/kg，根据活动量调整）
    daily_protein_goal = ROUND(weight * CASE 
        WHEN activity_level IN ('1', '2') THEN 1.2
        WHEN activity_level = '3' THEN 1.3
        WHEN activity_level IN ('4', '5') THEN 1.5
        ELSE 1.2
    END, 2),
    
    -- 碳水化合物目标（占总热量55%，1g碳水=4kcal）
    daily_carb_goal = ROUND(
        (bmr * CASE 
            WHEN activity_level = '1' THEN 1.2
            WHEN activity_level = '2' THEN 1.375
            WHEN activity_level = '3' THEN 1.55
            WHEN activity_level = '4' THEN 1.725
            WHEN activity_level = '5' THEN 1.9
            ELSE 1.375
        END) * 0.55 / 4, 2
    ),
    
    -- 脂肪目标（占总热量25%，1g脂肪=9kcal）
    daily_fat_goal = ROUND(
        (bmr * CASE 
            WHEN activity_level = '1' THEN 1.2
            WHEN activity_level = '2' THEN 1.375
            WHEN activity_level = '3' THEN 1.55
            WHEN activity_level = '4' THEN 1.725
            WHEN activity_level = '5' THEN 1.9
            ELSE 1.375
        END) * 0.25 / 9, 2
    ),
    
    profile_generated_time = NOW()
WHERE 
    bmr IS NOT NULL 
    AND weight IS NOT NULL
    AND weight > 0;

-- 验证营养素目标计算结果
SELECT 
    '每日营养素目标统计' AS '统计项',
    COUNT(daily_calorie_goal) AS '热量目标计算数',
    ROUND(AVG(daily_calorie_goal)) AS '平均热量目标(kcal)',
    COUNT(daily_protein_goal) AS '蛋白质目标计算数',
    ROUND(AVG(daily_protein_goal), 2) AS '平均蛋白质目标(g)',
    COUNT(daily_carb_goal) AS '碳水目标计算数',
    ROUND(AVG(daily_carb_goal), 2) AS '平均碳水目标(g)',
    COUNT(daily_fat_goal) AS '脂肪目标计算数',
    ROUND(AVG(daily_fat_goal), 2) AS '平均脂肪目标(g)'
FROM sys_user_health;

SELECT '' AS '';

-- ================================
-- 五、异常值二次检查和标记
-- ================================

SELECT '========== 异常值二次检查 ==========' AS '检查阶段';

-- 检查计算结果是否在合理范围
SELECT 
    '计算结果异常值检查' AS '检查项',
    COUNT(CASE WHEN bmi < 10 OR bmi > 60 THEN 1 END) AS 'BMI异常数(<10或>60)',
    COUNT(CASE WHEN bmr < 800 OR bmr > 5000 THEN 1 END) AS 'BMR异常数(<800或>5000)',
    COUNT(CASE WHEN daily_calorie_goal < 800 OR daily_calorie_goal > 5000 THEN 1 END) AS '热量目标异常数',
    COUNT(CASE WHEN daily_protein_goal < 20 OR daily_protein_goal > 500 THEN 1 END) AS '蛋白质目标异常数'
FROM sys_user_health;

-- 显示计算结果异常的用户
SELECT 
    '计算结果异常的用户明细' AS '提示',
    user_id AS '用户ID',
    height AS '身高',
    weight AS '体重',
    age AS '年龄',
    gender AS '性别',
    bmi AS 'BMI',
    bmr AS 'BMR',
    daily_calorie_goal AS '热量目标',
    CASE 
        WHEN bmi < 10 OR bmi > 60 THEN 'BMI异常'
        WHEN bmr < 800 OR bmr > 5000 THEN 'BMR异常'
        WHEN daily_calorie_goal < 800 OR daily_calorie_goal > 5000 THEN '热量目标异常'
        ELSE '其他异常'
    END AS '异常类型'
FROM sys_user_health
WHERE 
    (bmi IS NOT NULL AND (bmi < 10 OR bmi > 60))
    OR (bmr IS NOT NULL AND (bmr < 800 OR bmr > 5000))
    OR (daily_calorie_goal IS NOT NULL AND (daily_calorie_goal < 800 OR daily_calorie_goal > 5000));

SELECT '' AS '';

-- ================================
-- 六、计算完成总结报告
-- ================================

SELECT '========== 计算完成总结报告 ==========' AS '报告';

SELECT 
    '指标' AS '计算指标',
    '成功数' AS '成功计算数',
    '总用户数' AS '总数',
    '覆盖率(%)' AS '覆盖率',
    '状态' AS '状态'
UNION ALL
SELECT 
    'BMI体质指数',
    CAST(COUNT(bmi) AS CHAR),
    CAST(COUNT(*) AS CHAR),
    CAST(ROUND(COUNT(bmi) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(bmi) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(bmi) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '△ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    'BMR基础代谢率',
    CAST(COUNT(bmr) AS CHAR),
    CAST(COUNT(*) AS CHAR),
    CAST(ROUND(COUNT(bmr) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(bmr) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(bmr) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '△ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '每日热量目标',
    CAST(COUNT(daily_calorie_goal) AS CHAR),
    CAST(COUNT(*) AS CHAR),
    CAST(ROUND(COUNT(daily_calorie_goal) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(daily_calorie_goal) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(daily_calorie_goal) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '△ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '每日蛋白质目标',
    CAST(COUNT(daily_protein_goal) AS CHAR),
    CAST(COUNT(*) AS CHAR),
    CAST(ROUND(COUNT(daily_protein_goal) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(daily_protein_goal) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(daily_protein_goal) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '△ 需改进'
    END
FROM sys_user_health;

-- 样本数据展示（前10条）
SELECT '' AS '';
SELECT '计算结果样本展示(前10条)' AS '样本';
SELECT 
    user_id AS '用户ID',
    height AS '身高(cm)',
    weight AS '体重(kg)',
    age AS '年龄',
    CASE WHEN gender='0' THEN '男' WHEN gender='1' THEN '女' ELSE '未知' END AS '性别',
    bmi AS 'BMI',
    CASE 
        WHEN bmi < 18.5 THEN '偏瘦'
        WHEN bmi < 24 THEN '正常'
        WHEN bmi < 28 THEN '超重'
        ELSE '肥胖'
    END AS 'BMI分类',
    bmr AS 'BMR(kcal)',
    daily_calorie_goal AS '热量目标',
    daily_protein_goal AS '蛋白质目标(g)',
    profile_generated_time AS '计算时间'
FROM sys_user_health
WHERE bmi IS NOT NULL AND bmr IS NOT NULL
ORDER BY user_id
LIMIT 10;

SELECT '' AS '';
SELECT '✓ 用户健康指标计算完成！' AS '完成提示',
       '下一步：执行generate_user_profiles.sql生成用户画像数据' AS '下一步操作';

