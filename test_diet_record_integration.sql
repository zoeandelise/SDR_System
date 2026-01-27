-- 饮食记录模块数据库集成测试脚本
-- 用于验证数据保存和读取的完整性

-- 1. 测试基础记录插入
INSERT INTO diet_record (
    user_id, record_date, meal_type, 
    total_calories, total_protein, total_fat, total_carbohydrate,
    notes, create_time
) VALUES (
    1, '2025-01-22', '0',
    450.5, 25.3, 15.2, 35.8,
    '早餐测试记录', NOW()
);

-- 2. 验证记录插入
SELECT * FROM diet_record WHERE user_id = 1 AND record_date = '2025-01-22';

-- 3. 测试按日期查询
SELECT 
    r.record_id,
    r.user_id,
    r.record_date,
    r.meal_type,
    r.total_calories,
    u.user_name
FROM diet_record r
LEFT JOIN sys_user u ON r.user_id = u.user_id
WHERE r.record_date = '2025-01-22'
ORDER BY r.meal_type;

-- 4. 测试营养统计查询
SELECT 
    user_id,
    SUM(total_calories) as total_calories,
    SUM(total_protein) as total_protein,
    SUM(total_fat) as total_fat,
    SUM(total_carbohydrate) as total_carbohydrate
FROM diet_record
WHERE user_id = 1 
    AND record_date BETWEEN '2025-01-20' AND '2025-01-25'
GROUP BY user_id;

-- 5. 测试按用户和日期范围查询
SELECT 
    record_date,
    meal_type,
    total_calories,
    notes
FROM diet_record
WHERE user_id = 1 
    AND record_date BETWEEN '2025-01-20' AND '2025-01-25'
ORDER BY record_date DESC, meal_type ASC;

-- 6. 测试更新操作
UPDATE diet_record 
SET total_calories = 480.0,
    total_protein = 28.0,
    update_time = NOW()
WHERE user_id = 1 AND record_date = '2025-01-22' AND meal_type = '0';

-- 7. 验证更新结果
SELECT * FROM diet_record 
WHERE user_id = 1 AND record_date = '2025-01-22' AND meal_type = '0';

-- 8. 测试食物信息关联查询（如果有食物数据）
SELECT 
    r.record_id,
    r.record_date,
    r.meal_type,
    r.total_calories,
    f.food_name,
    f.food_code
FROM diet_record r
LEFT JOIN diet_food_info f ON f.food_id = 1  -- 假设关联食物ID
WHERE r.user_id = 1
LIMIT 5;

-- 9. 清理测试数据（可选）
-- DELETE FROM diet_record WHERE user_id = 1 AND record_date = '2025-01-22';

-- 10. 验证数据库表结构
DESCRIBE diet_record;

-- 11. 检查索引
SHOW INDEX FROM diet_record;

-- 测试结果验证说明：
-- 1. 所有查询应该返回预期结果
-- 2. 营养统计应该正确汇总数据
-- 3. 日期范围查询应该按条件过滤
-- 4. 更新操作应该正确修改数据
-- 5. 表结构应该包含所有必需字段
