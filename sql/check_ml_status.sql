-- 检查ML服务状态表
USE smart_diet_dev;

-- 查看当前状态记录
SELECT 
    status_id,
    service_status,
    data_loader_status,
    user_profiling_status,
    recommender_status,
    check_time,
    response_time,
    error_message
FROM ml_service_status
ORDER BY check_time DESC
LIMIT 5;

-- 如果表为空或数据不对，执行下面的修复
-- TRUNCATE TABLE ml_service_status;

-- INSERT INTO ml_service_status (
--     service_status,
--     data_loader_status,
--     user_profiling_status,
--     recommender_status,
--     check_time,
--     response_time,
--     error_message
-- ) VALUES (
--     'offline',
--     0,
--     0,
--     0,
--     NOW(),
--     0,
--     'ML服务未启动'
-- );

