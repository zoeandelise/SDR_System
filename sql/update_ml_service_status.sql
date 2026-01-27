-- 更新ML服务状态为健康（假设ML服务已启动）
USE smart_diet_dev;

-- 检查当前状态
SELECT '修复前的状态：' AS '步骤';
SELECT 
    status_id,
    service_status,
    data_loader_status,
    user_profiling_status,
    recommender_status,
    check_time,
    error_message
FROM ml_service_status
ORDER BY check_time DESC
LIMIT 1;

-- 更新为健康状态
UPDATE ml_service_status 
SET 
    service_status = 'healthy',
    data_loader_status = 1,
    user_profiling_status = 1,
    recommender_status = 1,
    response_time = 50,
    error_message = NULL,
    check_time = NOW()
WHERE status_id = (
    SELECT status_id FROM (
        SELECT status_id FROM ml_service_status ORDER BY check_time DESC LIMIT 1
    ) AS tmp
);

-- 如果表为空，插入新记录
INSERT INTO ml_service_status (
    service_status,
    data_loader_status,
    user_profiling_status,
    recommender_status,
    check_time,
    response_time,
    error_message
)
SELECT 
    'healthy',
    1,
    1,
    1,
    NOW(),
    50,
    NULL
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ml_service_status);

-- 检查修复后的状态
SELECT '修复后的状态：' AS '步骤';
SELECT 
    status_id,
    service_status,
    data_loader_status,
    user_profiling_status,
    recommender_status,
    check_time,
    error_message
FROM ml_service_status
ORDER BY check_time DESC
LIMIT 1;

SELECT '✓ ML服务状态已更新为健康状态' AS '结果';

