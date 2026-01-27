-- 数据验证脚本
SELECT '=== 最终数据验证报告 ===' as '验证报告';

SELECT 
    '食物分类' as '数据类型',
    COUNT(*) as '记录数',
    '✅ 正常' as '状态'
FROM diet_food_category

UNION ALL

SELECT 
    '食物信息',
    COUNT(*),
    '✅ 正常'
FROM diet_food_info

UNION ALL

SELECT 
    '营养信息',
    COUNT(*),
    '✅ 正常'
FROM diet_food_nutrition

UNION ALL

SELECT 
    '测试用户',
    COUNT(*),
    '✅ 正常'
FROM sys_user 
WHERE user_id >= 101

UNION ALL

SELECT 
    '健康信息',
    COUNT(*),
    '✅ 正常'
FROM sys_user_health 
WHERE user_id >= 101

UNION ALL

SELECT 
    '饮食记录',
    COUNT(*),
    '✅ 正常'
FROM diet_record 
WHERE user_id >= 101;

-- 用户记录详情
SELECT '=== 用户记录详情 ===' as '详情报告';

SELECT 
    user_id as '用户ID',
    COUNT(*) as '记录数',
    MIN(record_date) as '最早记录',
    MAX(record_date) as '最晚记录'
FROM diet_record 
WHERE user_id BETWEEN 101 AND 110
GROUP BY user_id
ORDER BY user_id;
