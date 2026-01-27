-- ================================
-- 健康饮食推荐系统 - 数据质量报告生成脚本
-- ================================
-- 执行说明：
-- 1. 此脚本需在check_diet_data_quality.sql之后执行
-- 2. 生成的报告数据可导出为CSV或复制到Markdown文档
-- 3. 建议使用 mysql -u root -p -t < generate_data_quality_report.sql > report.txt 保存输出
-- 4. 执行时间约15-45秒
-- ================================

USE smart_diet_dev;

-- 生成报告头
SELECT '╔═══════════════════════════════════════════════════════════╗' AS '';
SELECT '║     健康饮食推荐系统 - 数据质量检查报告                  ║' AS '';
SELECT '║     生成时间: ' AS '', NOW() AS '时间戳', '                           ║' AS '';
SELECT '╚═══════════════════════════════════════════════════════════╝' AS '';
SELECT '' AS '';

-- ================================
-- 报告第一部分：数据规模概览
-- ================================

SELECT '【一、数据规模概览】' AS '报告章节';
SELECT '' AS '';

SELECT 
    '数据表' AS '类别',
    '记录数' AS '指标',
    '备注' AS '说明'
UNION ALL
SELECT 
    '用户健康数据',
    CAST(COUNT(*) AS CHAR),
    CONCAT('唯一用户:', COUNT(DISTINCT user_id), '人')
FROM sys_user_health
UNION ALL
SELECT 
    '食物基础信息',
    CAST(COUNT(*) AS CHAR),
    CONCAT('正常状态:', COUNT(CASE WHEN status='0' THEN 1 END), '种')
FROM diet_food_info
UNION ALL
SELECT 
    '食物营养数据',
    CAST(COUNT(*) AS CHAR),
    CONCAT('关联食物:', COUNT(DISTINCT food_id), '种')
FROM diet_food_nutrition
UNION ALL
SELECT 
    '饮食推荐记录',
    CAST(COUNT(*) AS CHAR),
    CONCAT('时间跨度:', DATEDIFF(MAX(recommendation_date), MIN(recommendation_date)), '天')
FROM diet_recommendation;

SELECT '' AS '';

-- ================================
-- 报告第二部分：用户健康数据质量
-- ================================

SELECT '【二、用户健康数据质量分析】' AS '报告章节';
SELECT '' AS '';

-- 2.1 基础数据完整性
SELECT '2.1 基础数据完整性' AS '小节';
SELECT 
    '检查项' AS '项目',
    '非空率(%)' AS '指标',
    '状态' AS '评价'
UNION ALL
SELECT 
    '身高数据',
    CAST(ROUND(COUNT(CASE WHEN height > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN height > 0 THEN 1 END) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN height > 0 THEN 1 END) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '✗ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '体重数据',
    CAST(ROUND(COUNT(CASE WHEN weight > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN weight > 0 THEN 1 END) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN weight > 0 THEN 1 END) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '✗ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '年龄数据',
    CAST(ROUND(COUNT(CASE WHEN age > 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN age > 0 THEN 1 END) * 100.0 / COUNT(*) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN age > 0 THEN 1 END) * 100.0 / COUNT(*) >= 80 THEN '○ 良好'
        ELSE '✗ 需改进'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '慢性病标签',
    CAST(ROUND(COUNT(CASE WHEN diseases IS NOT NULL AND diseases != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN diseases IS NOT NULL AND diseases != '' THEN 1 END) * 100.0 / COUNT(*) >= 20 THEN '✓ 达标'
        WHEN COUNT(CASE WHEN diseases IS NOT NULL AND diseases != '' THEN 1 END) * 100.0 / COUNT(*) >= 10 THEN '○ 可接受'
        ELSE '✗ 不足'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '过敏原标签',
    CAST(ROUND(COUNT(CASE WHEN allergies IS NOT NULL AND allergies != '' THEN 1 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN allergies IS NOT NULL AND allergies != '' THEN 1 END) * 100.0 / COUNT(*) >= 10 THEN '✓ 达标'
        WHEN COUNT(CASE WHEN allergies IS NOT NULL AND allergies != '' THEN 1 END) * 100.0 / COUNT(*) >= 5 THEN '○ 可接受'
        ELSE '✗ 不足'
    END
FROM sys_user_health;

SELECT '' AS '';

-- 2.2 慢性病用户样本分布
SELECT '2.2 慢性病用户样本分布（算法训练关键）' AS '小节';
SELECT 
    '慢性病类型' AS '类别',
    '用户数' AS '数量',
    '占比(%)' AS '比例',
    '样本充足性' AS '评估'
UNION ALL
SELECT 
    '糖尿病',
    CAST(SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) AS CHAR),
    CAST(ROUND(SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) >= 50 THEN '✓ 充足'
        WHEN SUM(CASE WHEN diseases LIKE '%diabetes%' THEN 1 ELSE 0 END) >= 20 THEN '○ 基本可用'
        ELSE '✗ 样本不足'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '高血压',
    CAST(SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) AS CHAR),
    CAST(ROUND(SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) >= 50 THEN '✓ 充足'
        WHEN SUM(CASE WHEN diseases LIKE '%hypertension%' THEN 1 ELSE 0 END) >= 20 THEN '○ 基本可用'
        ELSE '✗ 样本不足'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '高血脂',
    CAST(SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) AS CHAR),
    CAST(ROUND(SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) >= 30 THEN '✓ 充足'
        WHEN SUM(CASE WHEN diseases LIKE '%hyperlipidemia%' OR diseases LIKE '%high_cholesterol%' THEN 1 ELSE 0 END) >= 10 THEN '○ 基本可用'
        ELSE '✗ 样本不足'
    END
FROM sys_user_health
UNION ALL
SELECT 
    '痛风',
    CAST(SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) AS CHAR),
    CAST(ROUND(SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CHAR),
    CASE 
        WHEN SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) >= 20 THEN '✓ 充足'
        WHEN SUM(CASE WHEN diseases LIKE '%gout%' THEN 1 ELSE 0 END) >= 8 THEN '○ 基本可用'
        ELSE '✗ 样本不足'
    END
FROM sys_user_health;

SELECT '' AS '';

-- 2.3 数据异常值统计
SELECT '2.3 用户数据异常值检测' AS '小节';
SELECT 
    '异常类型' AS '类别',
    '异常记录数' AS '数量',
    '处理建议' AS '建议'
UNION ALL
SELECT 
    '身高异常(<50cm or >250cm)',
    CAST(COUNT(CASE WHEN height < 50 OR height > 250 THEN 1 END) AS CHAR),
    CASE WHEN COUNT(CASE WHEN height < 50 OR height > 250 THEN 1 END) > 0 
         THEN '需人工核查或过滤' ELSE '无需处理' END
FROM sys_user_health
UNION ALL
SELECT 
    '体重异常(<20kg or >300kg)',
    CAST(COUNT(CASE WHEN weight < 20 OR weight > 300 THEN 1 END) AS CHAR),
    CASE WHEN COUNT(CASE WHEN weight < 20 OR weight > 300 THEN 1 END) > 0 
         THEN '需人工核查或过滤' ELSE '无需处理' END
FROM sys_user_health
UNION ALL
SELECT 
    '年龄异常(<1 or >120)',
    CAST(COUNT(CASE WHEN age < 1 OR age > 120 THEN 1 END) AS CHAR),
    CASE WHEN COUNT(CASE WHEN age < 1 OR age > 120 THEN 1 END) > 0 
         THEN '需人工核查或过滤' ELSE '无需处理' END
FROM sys_user_health;

SELECT '' AS '';

-- ================================
-- 报告第三部分：食物营养数据质量
-- ================================

SELECT '【三、食物营养数据质量分析】' AS '报告章节';
SELECT '' AS '';

-- 3.1 食物分类覆盖情况
SELECT '3.1 食物分类覆盖情况' AS '小节';
SELECT 
    c.category_name AS '分类名称',
    CAST(COUNT(f.food_id) AS CHAR) AS '食物数量',
    CAST(ROUND(COUNT(f.food_id) * 100.0 / (SELECT COUNT(*) FROM diet_food_info), 2) AS CHAR) AS '占比(%)'
FROM diet_food_category c
LEFT JOIN diet_food_info f ON c.category_id = f.category_id
GROUP BY c.category_id, c.category_name
ORDER BY COUNT(f.food_id) DESC
LIMIT 10;

SELECT '' AS '';

-- 3.2 营养数据关联完整性
SELECT '3.2 营养数据关联完整性' AS '小节';
SELECT 
    '统计项' AS '项目',
    '数值' AS '指标',
    '状态' AS '评价'
UNION ALL
SELECT 
    '食物总数',
    CAST(COUNT(DISTINCT f.food_id) AS CHAR),
    '-'
FROM diet_food_info f WHERE f.status = '0'
UNION ALL
SELECT 
    '有营养数据的食物数',
    CAST(COUNT(DISTINCT n.food_id) AS CHAR),
    '-'
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0'
UNION ALL
SELECT 
    '营养数据覆盖率(%)',
    CAST(ROUND(COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id), 0), 2) AS CHAR),
    CASE 
        WHEN ROUND(COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id), 0), 2) >= 90 THEN '✓ 优秀'
        WHEN ROUND(COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id), 0), 2) >= 70 THEN '○ 良好'
        ELSE '✗ 需补充'
    END
FROM diet_food_info f
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
WHERE f.status = '0';

SELECT '' AS '';

-- 3.3 关键营养字段完整性
SELECT '3.3 关键营养字段完整性（算法必需）' AS '小节';
SELECT 
    '营养成分' AS '字段',
    '非空率(%)' AS '完整度',
    '状态' AS '评价'
UNION ALL
SELECT 
    '热量(calories)',
    CAST(ROUND(COUNT(CASE WHEN calories IS NOT NULL AND calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN calories IS NOT NULL AND calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN calories IS NOT NULL AND calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 80 THEN '○ 良好'
        ELSE '✗ 需补充'
    END
FROM diet_food_nutrition
UNION ALL
SELECT 
    '蛋白质(protein)',
    CAST(ROUND(COUNT(CASE WHEN protein IS NOT NULL AND protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN protein IS NOT NULL AND protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN protein IS NOT NULL AND protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 80 THEN '○ 良好'
        ELSE '✗ 需补充'
    END
FROM diet_food_nutrition
UNION ALL
SELECT 
    '脂肪(fat)',
    CAST(ROUND(COUNT(CASE WHEN fat IS NOT NULL AND fat >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN fat IS NOT NULL AND fat >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN fat IS NOT NULL AND fat >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 80 THEN '○ 良好'
        ELSE '✗ 需补充'
    END
FROM diet_food_nutrition
UNION ALL
SELECT 
    '碳水化合物(carbohydrate)',
    CAST(ROUND(COUNT(CASE WHEN carbohydrate IS NOT NULL AND carbohydrate >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN carbohydrate IS NOT NULL AND carbohydrate >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 95 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN carbohydrate IS NOT NULL AND carbohydrate >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 80 THEN '○ 良好'
        ELSE '✗ 需补充'
    END
FROM diet_food_nutrition;

SELECT '' AS '';

-- 3.4 算法所需扩展字段检查
SELECT '3.4 算法所需扩展字段检查（健康推荐关键）' AS '小节';
SELECT 
    '字段名称' AS '字段',
    '存在状态' AS '状态',
    '影响功能' AS '影响',
    '优先级' AS '重要性'
UNION ALL
SELECT 
    'gi_value (GI值)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='gi_value') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '糖尿病用户推荐',
    '高'
UNION ALL
SELECT 
    'sodium_per_100g (钠含量)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='sodium_per_100g') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '高血压用户推荐',
    '高'
UNION ALL
SELECT 
    'purine_per_100g (嘌呤)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='purine_per_100g') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '痛风用户推荐',
    '高'
UNION ALL
SELECT 
    'cholesterol_per_100g (胆固醇)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='cholesterol_per_100g') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '高血脂用户推荐',
    '高'
UNION ALL
SELECT 
    'allergen_tags (过敏原标签)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='allergen_tags') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '过敏用户安全推荐',
    '中'
UNION ALL
SELECT 
    'suitable_for (适用人群)',
    CASE WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA='smart_diet_dev' AND TABLE_NAME='diet_food_nutrition' AND COLUMN_NAME='suitable_for') > 0 
         THEN '✓ 已存在' ELSE '✗ 缺失' END,
    '个性化健康推荐',
    '中';

SELECT '' AS '';

-- ================================
-- 报告第四部分：推荐记录数据质量
-- ================================

SELECT '【四、推荐记录数据质量分析】' AS '报告章节';
SELECT '' AS '';

-- 4.1 推荐数据规模
SELECT '4.1 推荐数据规模与时间跨度' AS '小节';
SELECT 
    '统计项' AS '项目',
    '数值' AS '指标'
UNION ALL
SELECT '总推荐记录数', CAST(COUNT(*) AS CHAR) FROM diet_recommendation
UNION ALL
SELECT '涉及用户数', CAST(COUNT(DISTINCT user_id) AS CHAR) FROM diet_recommendation
UNION ALL
SELECT '推荐日期数', CAST(COUNT(DISTINCT DATE(recommendation_date)) AS CHAR) FROM diet_recommendation
UNION ALL
SELECT '最早推荐日期', CAST(MIN(recommendation_date) AS CHAR) FROM diet_recommendation
UNION ALL
SELECT '最新推荐日期', CAST(MAX(recommendation_date) AS CHAR) FROM diet_recommendation
UNION ALL
SELECT '时间跨度(天)', CAST(DATEDIFF(MAX(recommendation_date), MIN(recommendation_date)) AS CHAR) FROM diet_recommendation;

SELECT '' AS '';

-- 4.2 用户反馈质量
SELECT '4.2 用户反馈质量（算法优化关键）' AS '小节';
SELECT 
    '反馈指标' AS '项目',
    '数值' AS '指标',
    '状态' AS '评价'
UNION ALL
SELECT 
    '反馈率(%)',
    CAST(ROUND(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 50 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 30 THEN '○ 良好'
        ELSE '✗ 偏低'
    END
FROM diet_recommendation
UNION ALL
SELECT 
    '接受率(%)',
    CAST(ROUND(COUNT(CASE WHEN is_accepted = '1' THEN 1 END) * 100.0 / 
               NULLIF(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN is_accepted = '1' THEN 1 END) * 100.0 / 
             NULLIF(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END), 0) >= 70 THEN '✓ 优秀'
        WHEN COUNT(CASE WHEN is_accepted = '1' THEN 1 END) * 100.0 / 
             NULLIF(COUNT(CASE WHEN is_accepted IS NOT NULL AND is_accepted != '' THEN 1 END), 0) >= 50 THEN '○ 良好'
        ELSE '○ 正常'
    END
FROM diet_recommendation
UNION ALL
SELECT 
    '评分覆盖率(%)',
    CAST(ROUND(COUNT(CASE WHEN score IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS CHAR),
    CASE 
        WHEN COUNT(CASE WHEN score IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 40 THEN '✓ 良好'
        WHEN COUNT(CASE WHEN score IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) >= 20 THEN '○ 可接受'
        ELSE '✗ 不足'
    END
FROM diet_recommendation
UNION ALL
SELECT 
    '平均评分',
    CAST(ROUND(AVG(score), 2) AS CHAR),
    CASE 
        WHEN AVG(score) >= 4.0 THEN '✓ 优秀'
        WHEN AVG(score) >= 3.5 THEN '○ 良好'
        ELSE '○ 中等'
    END
FROM diet_recommendation WHERE score IS NOT NULL;

SELECT '' AS '';

-- 4.3 算法类型分布
SELECT '4.3 算法类型分布' AS '小节';
SELECT 
    COALESCE(algorithm_type, 'NULL/未分类') AS '算法类型',
    CAST(COUNT(*) AS CHAR) AS '推荐次数',
    CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diet_recommendation), 2) AS CHAR) AS '占比(%)'
FROM diet_recommendation
GROUP BY algorithm_type
ORDER BY COUNT(*) DESC;

SELECT '' AS '';

-- ================================
-- 报告第五部分：综合评分与建议
-- ================================

SELECT '【五、综合评分与改进建议】' AS '报告章节';
SELECT '' AS '';

-- 5.1 综合评分
SELECT '5.1 数据质量综合评分' AS '小节';
SELECT 
    '评分维度' AS '维度',
    '得分' AS '分数',
    '权重' AS '权重',
    '加权得分' AS '加权分'
UNION ALL
SELECT 
    '用户数据完整性',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.4 +
        (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.3 +
        (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.3
    ), 2) AS CHAR),
    '30%',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.4 +
        (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.3 +
        (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.3
    ) * 0.3, 2) AS CHAR)
UNION ALL
SELECT 
    '食物营养完整性',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.4 +
        (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.3 +
        (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
         FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.3
    ), 2) AS CHAR),
    '40%',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.4 +
        (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.3 +
        (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
         FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.3
    ) * 0.4, 2) AS CHAR)
UNION ALL
SELECT 
    '推荐反馈质量',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.5 +
        (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.5
    ), 2) AS CHAR),
    '30%',
    CAST(ROUND((
        (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.5 +
        (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.5
    ) * 0.3, 2) AS CHAR);

SELECT '' AS '';

SELECT 
    '【综合评分】' AS '最终评分',
    CAST(ROUND(
        (
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.12 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.16 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.12 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.12 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2
    ) AS CHAR) AS '得分(满分100)',
    CASE 
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.12 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.16 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.12 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.12 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 80 THEN '✓ 优秀 - 可直接用于算法训练'
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.12 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.16 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.12 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.12 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 60 THEN '○ 良好 - 补充关键字段后可用'
        WHEN ROUND((
            (SELECT COUNT(CASE WHEN height > 0 AND weight > 0 AND age > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.12 +
            (SELECT COUNT(CASE WHEN diseases IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN allergies IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM sys_user_health) * 0.09 +
            (SELECT COUNT(CASE WHEN calories > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.16 +
            (SELECT COUNT(CASE WHEN protein >= 0 THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_food_nutrition) * 0.12 +
            (SELECT COUNT(DISTINCT n.food_id) * 100.0 / NULLIF(COUNT(DISTINCT f.food_id),0) 
             FROM diet_food_info f LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id WHERE f.status='0') * 0.12 +
            (SELECT COUNT(CASE WHEN is_accepted IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15 +
            (SELECT COUNT(CASE WHEN recommended_foods IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(*),0) FROM diet_recommendation) * 0.15
        ), 2) >= 40 THEN '△ 中等 - 需大量补充数据'
        ELSE '✗ 较差 - 建议重新设计数据采集'
    END AS '质量等级';

SELECT '' AS '';

-- 5.2 改进建议
SELECT '5.2 数据改进优先级建议' AS '小节';
SELECT 
    '优先级' AS '级别',
    '改进项' AS '项目',
    '具体行动' AS '建议'
UNION ALL
SELECT 
    'P0-紧急',
    '扩展食物营养表字段',
    '添加GI值/钠/嘌呤/胆固醇字段（执行alter_food_nutrition_table.sql）'
UNION ALL
SELECT 
    'P0-紧急',
    '计算用户BMI和BMR',
    '执行calculate_user_metrics.sql生成计算字段'
UNION ALL
SELECT 
    'P1-重要',
    '补充食物营养数据',
    '基于《中国食物成分表2024》导入主食/肉类/蔬菜的GI值和特殊成分'
UNION ALL
SELECT 
    'P1-重要',
    '增加慢性病用户样本',
    '确保糖尿病/高血压/痛风用户各>=20例，用于算法训练'
UNION ALL
SELECT 
    'P2-常规',
    '清洗异常数据',
    '过滤身高/体重/年龄异常值，执行clean_recommendation_data.sql'
UNION ALL
SELECT 
    'P2-常规',
    '生成用户饮食偏好',
    '基于年龄/健康状况生成diet_preferences字段'
UNION ALL
SELECT 
    'P3-优化',
    '创建推荐反馈扩展表',
    '记录用户拒绝原因，用于算法优化';

-- 报告尾部
SELECT '' AS '';
SELECT '╔═══════════════════════════════════════════════════════════╗' AS '';
SELECT '║                 数据质量检查报告生成完毕                  ║' AS '';
SELECT '║     请根据以上分析结果，按优先级执行数据补充方案          ║' AS '';
SELECT '╚═══════════════════════════════════════════════════════════╝' AS '';

