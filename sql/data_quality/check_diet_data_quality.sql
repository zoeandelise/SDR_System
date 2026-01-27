-- ================================
-- 健康饮食推荐系统 - 数据质量检查脚本
-- ================================
-- 执行说明：
-- 1. 执行前需确认数据库权限（需SELECT权限）
-- 2. 建议先在测试环境验证
-- 3. 执行时间约10-30秒（取决于数据量）
-- 4. 执行后将输出多个统计结果集，请逐个查看
-- ================================

USE smart_diet_dev;

-- ================================
-- 一、用户健康数据完整性检查
-- ================================

SELECT '========== 用户健康数据完整性检查 ==========' AS '检查项目';

-- 1.1 基础统计
SELECT 
    '用户健康数据总览' AS '统计项',
    COUNT(*) AS '总记录数',
    COUNT(DISTINCT user_id) AS '唯一用户数',
    COUNT(CASE WHEN height IS NOT NULL AND height > 0 THEN 1 END) AS '有效身高记录数',
    ROUND(COUNT(CASE WHEN height IS NOT NULL AND height > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '身高非空率(%)',
    COUNT(CASE WHEN weight IS NOT NULL AND weight > 0 THEN 1 END) AS '有效体重记录数',
    ROUND(COUNT(CASE WHEN weight IS NOT NULL AND weight > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '体重非空率(%)',
    COUNT(CASE WHEN age IS NOT NULL AND age > 0 THEN 1 END) AS '有效年龄记录数',
    ROUND(COUNT(CASE WHEN age IS NOT NULL AND age > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '年龄非空率(%)'
FROM sys_user_health;

-- 1.2 慢性病标签覆盖率
SELECT 
    '慢性病数据覆盖率' AS '统计项',             
    COUNT(*) AS '总用户数',
    COUNT(CASE WHEN diseases IS NOT NULL AND diseases != '' THEN 1 END) AS '有慢性病标签用户数',
    ROUND(COUNT(CASE WHEN diseases IS NOT NULL AND diseases != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS '慢性病标签覆盖率(%)'
FROM sys_user_health;

-- 1.3 慢性病类型分布统计
SELECT 
    '慢性病类型分布' AS '统计类别',
    SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) AS '糖尿病用户数',
    ROUND(SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS '糖尿病占比(%)',
    SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) AS '高血压用户数',
    ROUND(SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS '高血压占比(%)',
    SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) AS '高血脂用户数',
    ROUND(SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS '高血脂占比(%)',
    SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) AS '痛风用户数',
    ROUND(SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS '痛风占比(%)',
    SUM(CASE WHEN diseases LIKE '%fatty_liver%' THEN 1 ELSE 0 END) AS '脂肪肝用户数',
    ROUND(SUM(CASE WHEN diseases LIKE '%fatty_liver%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS '脂肪肝占比(%)'
FROM sys_user_health;

-- 1.4 过敏原标签覆盖率
SELECT 
    '过敏原数据覆盖率' AS '统计项',
    COUNT(*) AS '总用户数',
    COUNT(CASE WHEN allergies IS NOT NULL AND allergies != '' THEN 1 END) AS '有过敏原标签用户数',
    ROUND(COUNT(CASE WHEN allergies IS NOT NULL AND allergies != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS '过敏原标签覆盖率(%)'
FROM sys_user_health;

-- 1.5 过敏原类型分布
SELECT 
    '过敏原类型分布' AS '统计类别',
    SUM(CASE WHEN allergies LIKE '%peanut%' OR allergies LIKE '%nuts%' THEN 1 ELSE 0 END) AS '坚果过敏',
    SUM(CASE WHEN allergies LIKE '%dairy%' OR allergies LIKE '%milk%' OR allergies LIKE '%lactose%' THEN 1 ELSE 0 END) AS '乳制品过敏',
    SUM(CASE WHEN allergies LIKE '%seafood%' OR allergies LIKE '%fish%' OR allergies LIKE '%shrimp%' OR allergies LIKE '%shellfish%' THEN 1 ELSE 0 END) AS '海鲜过敏',
    SUM(CASE WHEN allergies LIKE '%gluten%' THEN 1 ELSE 0 END) AS '麸质过敏',
    SUM(CASE WHEN allergies LIKE '%egg%' THEN 1 ELSE 0 END) AS '鸡蛋过敏',
    SUM(CASE WHEN allergies LIKE '%soy%' THEN 1 ELSE 0 END) AS '豆类过敏'
FROM sys_user_health;

-- 1.6 年龄和BMI分布（需先计算BMI）
SELECT 
    '用户年龄和体型分布' AS '统计类别',
    COUNT(CASE WHEN age >= 18 AND age < 30 THEN 1 END) AS '18-30岁',
    COUNT(CASE WHEN age >= 30 AND age < 40 THEN 1 END) AS '30-40岁',
    COUNT(CASE WHEN age >= 40 AND age < 50 THEN 1 END) AS '40-50岁',
    COUNT(CASE WHEN age >= 50 THEN 1 END) AS '50岁以上',
    COUNT(CASE WHEN weight/(POWER(height/100,2)) < 18.5 THEN 1 END) AS '偏瘦(BMI<18.5)',
    COUNT(CASE WHEN weight/(POWER(height/100,2)) >= 18.5 AND weight/(POWER(height/100,2)) < 24 THEN 1 END) AS '正常(BMI 18.5-24)',
    COUNT(CASE WHEN weight/(POWER(height/100,2)) >= 24 AND weight/(POWER(height/100,2)) < 28 THEN 1 END) AS '超重(BMI 24-28)',
    COUNT(CASE WHEN weight/(POWER(height/100,2)) >= 28 THEN 1 END) AS '肥胖(BMI≥28)'
FROM sys_user_health
WHERE height > 0 AND weight > 0;

-- 1.7 数据异常值检测
SELECT 
    '用户健康数据异常值检测' AS '检测项',
    COUNT(CASE WHEN height < 50 OR height > 250 THEN 1 END) AS '身高异常(cm)',
    COUNT(CASE WHEN weight < 20 OR weight > 300 THEN 1 END) AS '体重异常(kg)',
    COUNT(CASE WHEN age < 1 OR age > 120 THEN 1 END) AS '年龄异常',
    COUNT(CASE WHEN daily_calorie_goal < 800 OR daily_calorie_goal > 5000 THEN 1 END) AS '每日热量目标异常'
FROM sys_user_health;

-- ================================
-- 二、食物营养数据完整性检查
-- ================================

SELECT '========== 食物营养数据完整性检查 ==========' AS '检查项目';

-- 2.1 食物基础信息统计
SELECT 
    '食物基础信息总览' AS '统计项',
    COUNT(*) AS '总食物数',
    COUNT(DISTINCT food_name) AS '唯一食物名称数',
    COUNT(DISTINCT category_id) AS '食物分类数',
    COUNT(CASE WHEN status = '0' THEN 1 END) AS '正常状态食物数',
    COUNT(CASE WHEN status = '1' THEN 1 END) AS '停用食物数'
FROM diet_food_info;

-- 2.2 食物分类分布统计（详细）
SELECT 
    '食物分类分布' AS '统计类别',
    c.category_name AS '分类名称',
    c.category_id AS '分类ID',
    COUNT(f.food_id) AS '该分类食物数量',
    ROUND(COUNT(f.food_id) * 100.0 / (SELECT COUNT(*) FROM diet_food_info), 2) AS '占比(%)'
FROM diet_food_category c
LEFT JOIN diet_food_info f ON c.category_id = f.category_id
GROUP BY c.category_id, c.category_name
ORDER BY COUNT(f.food_id) DESC;

-- 2.3 食物营养数据关联完整性
SELECT 
    '食物营养数据关联' AS '统计项',
    COUNT(DISTINCT f.food_id) AS '食物总数',
    COUNT(DISTINCT n.food_id) AS '有营养数据的食物数',
    ROUND(COUNT(DISTINCT n.food_id) * 100.0 / COUNT(DISTINCT f.food_id), 2) AS '营养数据覆盖率(%)',
    COUNT(DISTINCT f.food_id) - COUNT(DISTINCT n.food_id) AS '缺失营养数据的食物数'
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0';

-- 2.4 营养成分字段完整性
SELECT 
    '营养成分字段完整性' AS '统计项',
    COUNT(*) AS '营养记录总数',
    COUNT(CASE WHEN calories IS NOT NULL AND calories > 0 THEN 1 END) AS '有效热量记录',
    ROUND(COUNT(CASE WHEN calories IS NOT NULL AND calories > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '热量非空率(%)',
    COUNT(CASE WHEN protein IS NOT NULL AND protein >= 0 THEN 1 END) AS '有效蛋白质记录',
    ROUND(COUNT(CASE WHEN protein IS NOT NULL AND protein >= 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '蛋白质非空率(%)',
    COUNT(CASE WHEN fat IS NOT NULL AND fat >= 0 THEN 1 END) AS '有效脂肪记录',
    ROUND(COUNT(CASE WHEN fat IS NOT NULL AND fat >= 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '脂肪非空率(%)',
    COUNT(CASE WHEN carbohydrate IS NOT NULL AND carbohydrate >= 0 THEN 1 END) AS '有效碳水记录',
    ROUND(COUNT(CASE WHEN carbohydrate IS NOT NULL AND carbohydrate >= 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '碳水非空率(%)',
    COUNT(CASE WHEN fiber IS NOT NULL AND fiber >= 0 THEN 1 END) AS '有效膳食纤维记录',
    ROUND(COUNT(CASE WHEN fiber IS NOT NULL AND fiber >= 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '膳食纤维非空率(%)'
FROM diet_food_nutrition;

-- 2.5 营养数据异常值检测
SELECT 
    '营养数据异常值检测' AS '检测项',
    COUNT(CASE WHEN calories < 0 OR calories > 900 THEN 1 END) AS '热量异常(kcal/100g)',
    COUNT(CASE WHEN protein < 0 OR protein > 100 THEN 1 END) AS '蛋白质异常(g/100g)',
    COUNT(CASE WHEN fat < 0 OR fat > 100 THEN 1 END) AS '脂肪异常(g/100g)',
    COUNT(CASE WHEN carbohydrate < 0 OR carbohydrate > 100 THEN 1 END) AS '碳水异常(g/100g)',
    COUNT(CASE WHEN fiber < 0 OR fiber > 50 THEN 1 END) AS '膳食纤维异常(g/100g)'
FROM diet_food_nutrition;

-- 2.6 关键字段缺失检查（为算法准备）
SELECT 
    '算法所需关键字段缺失检查' AS '检查项',
    'GI值(血糖生成指数)' AS '字段名',
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '已存在' ELSE '缺失' END AS '字段状态',
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '可用于糖尿病推荐' ELSE '需要补充' END AS '影响'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'gi_value'
UNION ALL
SELECT 
    '算法所需关键字段缺失检查',
    '钠含量(mg/100g)',
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '已存在' ELSE '缺失' END,
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '可用于高血压推荐' ELSE '需要补充' END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'sodium_per_100g'
UNION ALL
SELECT 
    '算法所需关键字段缺失检查',
    '嘌呤含量(mg/100g)',
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '已存在' ELSE '缺失' END,
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '可用于痛风推荐' ELSE '需要补充' END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'purine_per_100g'
UNION ALL
SELECT 
    '算法所需关键字段缺失检查',
    '胆固醇含量(mg/100g)',
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '已存在' ELSE '缺失' END,
    CASE WHEN COUNT(COLUMN_NAME) > 0 THEN '可用于高血脂推荐' ELSE '需要补充' END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_food_nutrition' 
  AND COLUMN_NAME = 'cholesterol_per_100g';

-- ================================
-- 三、推荐记录数据质量检查
-- ================================

SELECT '========== 推荐记录数据质量检查 ==========' AS '检查项目';

-- 3.1 推荐记录基础统计
SELECT 
    '推荐记录总览' AS '统计项',
    COUNT(*) AS '总推荐记录数',
    COUNT(DISTINCT user_id) AS '涉及用户数',
    COUNT(DISTINCT DATE(recommendation_date)) AS '推荐日期数',
    MIN(recommendation_date) AS '最早推荐日期',
    MAX(recommendation_date) AS '最新推荐日期',
    DATEDIFF(MAX(recommendation_date), MIN(recommendation_date)) AS '时间跨度(天)'
FROM diet_recommendation;

-- 3.2 推荐算法类型分布
SELECT 
    '推荐算法类型分布' AS '统计类别',
    COALESCE(algorithm_type, 'NULL值') AS '算法类型',
    COUNT(*) AS '推荐次数',
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diet_recommendation), 2) AS '占比(%)',
    COUNT(DISTINCT user_id) AS '使用用户数'
FROM diet_recommendation
GROUP BY algorithm_type
ORDER BY COUNT(*) DESC;

-- 3.3 用户反馈率统计
SELECT 
    '用户反馈率统计' AS '统计项',
    COUNT(*) AS '总推荐数',
    COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END) AS '有反馈推荐数',
    ROUND(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS '反馈率(%)',
    COUNT(CASE WHEN is_accepted = '1' THEN 1 END) AS '接受数',
    COUNT(CASE WHEN is_accepted = '0' OR is_accepted = '2' THEN 1 END) AS '拒绝数',
    ROUND(COUNT(CASE WHEN is_accepted = '1' THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END), 0), 2) AS '接受率(%)'
FROM diet_recommendation;

-- 3.4 评分数据统计
SELECT 
    '评分数据统计' AS '统计项',
    COUNT(CASE WHEN score IS NOT NULL THEN 1 END) AS '有评分记录数',
    ROUND(COUNT(CASE WHEN score IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) AS '评分覆盖率(%)',
    ROUND(AVG(score), 2) AS '平均评分',
    MIN(score) AS '最低评分',
    MAX(score) AS '最高评分',
    COUNT(CASE WHEN score >= 4 THEN 1 END) AS '高分(≥4)数量',
    COUNT(CASE WHEN score < 3 THEN 1 END) AS '低分(<3)数量'
FROM diet_recommendation
WHERE score IS NOT NULL;

-- 3.5 推荐记录数据完整性
SELECT 
    '推荐记录字段完整性' AS '统计项',
    ROUND(COUNT(CASE WHEN target_calories IS NOT NULL AND target_calories > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS '目标热量非空率(%)',
    ROUND(COUNT(CASE WHEN target_protein IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) AS '目标蛋白质非空率(%)',
    ROUND(COUNT(CASE WHEN recommended_foods IS NOT NULL AND recommended_foods != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS '推荐食物非空率(%)',
    ROUND(COUNT(CASE WHEN recommendation_reason IS NOT NULL AND recommendation_reason != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS '推荐理由非空率(%)'
FROM diet_recommendation;

-- 3.6 推荐记录异常值检测
SELECT 
    '推荐记录异常值检测' AS '检测项',
    COUNT(CASE WHEN target_calories < 100 OR target_calories > 5000 THEN 1 END) AS '目标热量异常',
    COUNT(CASE WHEN target_protein < 0 OR target_protein > 500 THEN 1 END) AS '目标蛋白质异常',
    COUNT(CASE WHEN recommended_foods IS NULL OR recommended_foods = '' THEN 1 END) AS '推荐食物为空',
    COUNT(CASE WHEN algorithm_type IS NULL OR algorithm_type = '' THEN 1 END) AS '算法类型为空'
FROM diet_recommendation;

-- 3.7 用户推荐覆盖率
SELECT 
    '用户推荐覆盖率' AS '统计项',
    (SELECT COUNT(DISTINCT user_id) FROM sys_user_health) AS '用户总数',
    COUNT(DISTINCT dr.user_id) AS '有推荐记录的用户数',
    ROUND(COUNT(DISTINCT dr.user_id) * 100.0 / 
          (SELECT COUNT(DISTINCT user_id) FROM sys_user_health), 2) AS '用户覆盖率(%)',
    (SELECT COUNT(DISTINCT user_id) FROM sys_user_health) - COUNT(DISTINCT dr.user_id) AS '未覆盖用户数'
FROM diet_recommendation dr;

-- ================================
-- 四、数据质量评分总结
-- ================================

SELECT '========== 数据质量评分总结 ==========' AS '检查项目';

SELECT 
    '数据质量评分' AS '评分项',
    ROUND(
        (
            -- 用户健康数据完整性权重30%
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            
            -- 食物营养数据完整性权重40%
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.15 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.1 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id) * 0.15 +
            
            -- 推荐记录质量权重30%
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2
    ) AS '综合评分(0-100)',
    CASE 
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.15 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.1 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id) * 0.15 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 80 THEN '优秀 - 可直接用于算法训练'
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.15 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.1 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id) * 0.15 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 60 THEN '良好 - 需补充关键字段后可用'
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) FROM sys_user_health) * 0.1 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.15 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.1 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id) * 0.15 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 40 THEN '中等 - 需大量补充数据'
        ELSE '较差 - 建议重新设计数据采集方案'
    END AS '质量等级与建议';

-- 检查完成提示
SELECT '========== 数据质量检查完成 ==========' AS '提示',
       '请查看以上各项统计结果，并参考generate_data_quality_report.sql生成详细报告' AS '下一步操作';

