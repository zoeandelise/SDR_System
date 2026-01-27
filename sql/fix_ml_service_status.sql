-- 修复ML服务状态显示
USE smart_diet_dev;

-- 清理旧的服务状态记录
TRUNCATE TABLE ml_service_status;

-- 插入健康的初始状态（假设ML服务未启动，显示离线状态）
INSERT INTO ml_service_status (
    service_status,
    data_loader_status,
    user_profiling_status,
    recommender_status,
    check_time,
    response_time,
    error_message
) VALUES (
    'offline',
    0,
    0,
    0,
    NOW(),
    0,
    'ML服务未启动或无法连接'
);

-- 如果ML服务已启动，取消下面的注释并执行
-- UPDATE ml_service_status 
-- SET service_status = 'healthy',
--     data_loader_status = 1,
--     user_profiling_status = 1,
--     recommender_status = 1,
--     error_message = NULL,
--     response_time = 50
-- WHERE status_id = (SELECT MAX(status_id) FROM (SELECT * FROM ml_service_status) t);

SELECT '服务状态已修复' AS message;
SELECT * FROM ml_service_status ORDER BY check_time DESC LIMIT 1;

