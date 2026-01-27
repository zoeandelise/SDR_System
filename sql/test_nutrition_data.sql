-- 验证营养数据导入结果

USE smart_diet_dev;

-- 查看高频食材的营养数据
SELECT 
    f.food_name AS '食材名称',
    n.gi_value AS 'GI值',
    n.sodium_per_100g AS '钠(mg)',
    n.purine_per_100g AS '嘌呤(mg)',
    n.cholesterol_per_100g AS '胆固醇(mg)',
    n.suitable_for AS '适用人群',
    n.data_source AS '数据来源'
FROM diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
WHERE f.food_name IN ('鸡胸肉', '糙米饭', '西兰花', '胡萝卜', '白米饭', '牛奶', '鸡蛋')
ORDER BY f.food_name;

-- 统计各分类营养数据完整度
SELECT 
    c.category_name AS '分类',
    COUNT(f.food_id) AS '食物数',
    COUNT(n.gi_value) AS 'GI值数',
    ROUND(COUNT(n.gi_value) * 100.0 / COUNT(f.food_id), 2) AS '完整度(%)'
FROM diet_food_category c
LEFT JOIN diet_food_info f ON c.category_id = f.category_id  
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
GROUP BY c.category_id, c.category_name;

