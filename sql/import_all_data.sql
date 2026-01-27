-- 智能饮食推荐系统 - 一键导入所有测试数据
-- 执行顺序：基础数据 -> 用户数据 -> 饮食记录数据

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================
-- 清理现有测试数据（可选）
-- ================================
-- 删除测试用户的饮食记录
DELETE FROM diet_record WHERE user_id >= 101;

-- 删除测试用户的健康信息
DELETE FROM sys_user_health WHERE user_id >= 101;

-- 删除测试用户信息
DELETE FROM sys_user WHERE user_id >= 101;

-- 重置AUTO_INCREMENT
ALTER TABLE diet_record AUTO_INCREMENT = 1;
ALTER TABLE sys_user_health AUTO_INCREMENT = 1;

-- ================================
-- 1. 导入食物基础数据
-- ================================
SOURCE comprehensive_diet_data.sql;

-- ================================  
-- 2. 导入饮食记录数据
-- ================================
SOURCE diet_records_data.sql;

-- ================================
-- 3. 数据验证和统计
-- ================================
SELECT '=== 数据导入完成统计 ===' as '状态报告';

SELECT 
    '食物分类' as '数据类型',
    COUNT(*) as '记录数',
    '已导入完成' as '状态'
FROM diet_food_category

UNION ALL

SELECT 
    '食物信息',
    COUNT(*),
    '已导入完成'
FROM diet_food_info

UNION ALL

SELECT 
    '营养信息',
    COUNT(*),
    '已导入完成'
FROM diet_food_nutrition

UNION ALL

SELECT 
    '测试用户',
    COUNT(*),
    '已导入完成'
FROM sys_user 
WHERE user_id >= 101

UNION ALL

SELECT 
    '健康信息',
    COUNT(*),
    '已导入完成'
FROM sys_user_health 
WHERE user_id >= 101

UNION ALL

SELECT 
    '饮食记录',
    COUNT(*),
    '已导入完成'
FROM diet_record 
WHERE user_id >= 101;

-- 详细统计信息
SELECT '=== 饮食记录详细统计 ===' as '详细报告';

SELECT 
    CASE meal_type 
        WHEN '0' THEN '早餐'
        WHEN '1' THEN '午餐' 
        WHEN '2' THEN '晚餐'
        WHEN '3' THEN '加餐'
        ELSE '未知'
    END as '餐次类型',
    COUNT(*) as '记录数量',
    ROUND(AVG(total_calories), 2) as '平均热量(kcal)',
    ROUND(AVG(total_protein), 2) as '平均蛋白质(g)',
    ROUND(AVG(total_fat), 2) as '平均脂肪(g)',
    ROUND(AVG(total_carbohydrate), 2) as '平均碳水(g)'
FROM diet_record 
WHERE user_id >= 101
GROUP BY meal_type
ORDER BY meal_type;

-- 用户记录分布统计
SELECT '=== 用户记录分布 ===' as '用户统计';

SELECT 
    user_id as '用户ID',
    COUNT(*) as '总记录数',
    COUNT(CASE WHEN meal_type = '0' THEN 1 END) as '早餐',
    COUNT(CASE WHEN meal_type = '1' THEN 1 END) as '午餐',
    COUNT(CASE WHEN meal_type = '2' THEN 1 END) as '晚餐',
    COUNT(CASE WHEN meal_type = '3' THEN 1 END) as '加餐',
    ROUND(AVG(total_calories), 2) as '日均热量'
FROM diet_record 
WHERE user_id BETWEEN 101 AND 110  -- 显示前10个用户
GROUP BY user_id
ORDER BY user_id;

-- 时间分布统计
SELECT '=== 时间分布统计 ===' as '时间统计';

SELECT 
    record_date as '日期',
    COUNT(*) as '当日记录数',
    COUNT(DISTINCT user_id) as '活跃用户数',
    ROUND(AVG(total_calories), 2) as '平均热量'
FROM diet_record 
WHERE user_id >= 101
GROUP BY record_date
ORDER BY record_date
LIMIT 10;  -- 显示前10天

-- 营养素分析
SELECT '=== 营养素统计分析 ===' as '营养分析';

SELECT 
    '总体营养状况' as '分析项目',
    CONCAT(
        '平均热量: ', ROUND(AVG(total_calories), 2), 'kcal, ',
        '平均蛋白质: ', ROUND(AVG(total_protein), 2), 'g, ',
        '平均脂肪: ', ROUND(AVG(total_fat), 2), 'g, ',
        '平均碳水: ', ROUND(AVG(total_carbohydrate), 2), 'g'
    ) as '统计结果'
FROM diet_record 
WHERE user_id >= 101

UNION ALL

SELECT 
    '热量分布',
    CONCAT(
        '低热量(<300): ', COUNT(CASE WHEN total_calories < 300 THEN 1 END), '条, ',
        '中热量(300-600): ', COUNT(CASE WHEN total_calories BETWEEN 300 AND 600 THEN 1 END), '条, ',
        '高热量(>600): ', COUNT(CASE WHEN total_calories > 600 THEN 1 END), '条'
    )
FROM diet_record 
WHERE user_id >= 101;

SET FOREIGN_KEY_CHECKS = 1;

SELECT '=== 数据导入成功！===' as '完成状态',
       '已为50个用户导入丰富的饮食数据' as '导入内容',
       '可以开始使用机器学习推荐功能了' as '下一步操作';
