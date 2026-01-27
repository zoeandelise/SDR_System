-- ================================
-- ML推荐管理系统数据初始化
-- ================================

USE smart_diet_dev;

-- ================================
-- 1. 初始化3个ML模型记录
-- ================================
INSERT INTO `ml_model_info` (`model_name`, `model_type`, `is_loaded`, `model_version`, `create_time`) VALUES
('协同过滤模型', 'collaborative_filtering', 0, '1.0.0', NOW()),
('内容推荐模型', 'content_based', 0, '1.0.0', NOW()),
('深度学习模型', 'deep_learning', 0, '1.0.0', NOW())
ON DUPLICATE KEY UPDATE 
  `model_name` = VALUES(`model_name`),
  `update_time` = NOW();

-- ================================
-- 2. 更新现有推荐记录的ML相关字段
-- ================================
UPDATE `diet_recommendation` 
SET 
  `confidence_score` = ROUND(RAND() * 0.3 + 0.7, 4),
  `applied_flag` = CASE WHEN `is_accepted` = '1' THEN '1' ELSE '0' END,
  `response_time` = FLOOR(RAND() * 100 + 20),
  `algorithm_type` = CASE 
    WHEN `algorithm_type` IS NULL OR `algorithm_type` = '' THEN 'rule_based'
    ELSE `algorithm_type`
  END
WHERE `confidence_score` IS NULL OR `applied_flag` IS NULL;

-- ================================
-- 3. 基于现有推荐记录生成统计数据
-- ================================
INSERT INTO `ml_recommendation_stats` 
  (`stat_date`, `algorithm_type`, `total_recommendations`, `accepted_recommendations`, `acceptance_rate`, `avg_score`, `avg_response_time`, `active_users`, `create_time`)
SELECT 
    `recommendation_date` as stat_date,
    COALESCE(`algorithm_type`, 'rule_based') as algorithm_type,
    COUNT(*) as total_recommendations,
    SUM(CASE WHEN `is_accepted` = '1' THEN 1 ELSE 0 END) as accepted_recommendations,
    ROUND(AVG(CASE WHEN `is_accepted` = '1' THEN 1.0 ELSE 0.0 END), 4) as acceptance_rate,
    ROUND(AVG(`score`), 2) as avg_score,
    ROUND(AVG(`response_time`), 0) as avg_response_time,
    COUNT(DISTINCT `user_id`) as active_users,
    NOW() as create_time
FROM `diet_recommendation`
WHERE `recommendation_date` IS NOT NULL
GROUP BY `recommendation_date`, COALESCE(`algorithm_type`, 'rule_based')
ON DUPLICATE KEY UPDATE
  `total_recommendations` = VALUES(`total_recommendations`),
  `accepted_recommendations` = VALUES(`accepted_recommendations`),
  `acceptance_rate` = VALUES(`acceptance_rate`),
  `avg_score` = VALUES(`avg_score`),
  `avg_response_time` = VALUES(`avg_response_time`),
  `active_users` = VALUES(`active_users`),
  `update_time` = NOW();

-- ================================
-- 4. 如果统计数据为空，创建一些近期的示例数据
-- ================================
INSERT INTO `ml_recommendation_stats` 
  (`stat_date`, `algorithm_type`, `total_recommendations`, `accepted_recommendations`, `acceptance_rate`, `avg_score`, `avg_response_time`, `active_users`, `create_time`)
SELECT 
    CURDATE() - INTERVAL n DAY as stat_date,
    algo as algorithm_type,
    FLOOR(RAND() * 50 + 10) as total_recommendations,
    FLOOR(RAND() * 30 + 5) as accepted_recommendations,
    ROUND(RAND() * 0.3 + 0.6, 4) as acceptance_rate,
    ROUND(RAND() * 2 + 3.5, 2) as avg_score,
    FLOOR(RAND() * 60 + 30) as avg_response_time,
    FLOOR(RAND() * 20 + 5) as active_users,
    NOW() as create_time
FROM 
    (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) as days,
    (SELECT 'rule_based' as algo UNION SELECT 'collaborative_filtering' UNION SELECT 'content_based' UNION SELECT 'deep_learning') as algos
WHERE NOT EXISTS (
    SELECT 1 FROM `ml_recommendation_stats` 
    WHERE `stat_date` = CURDATE() - INTERVAL n DAY AND `algorithm_type` = algo
)
ORDER BY n, algo;

-- ================================
-- 5. 初始化服务状态记录
-- ================================
INSERT INTO `ml_service_status` 
  (`service_status`, `data_loader_status`, `user_profiling_status`, `recommender_status`, `check_time`, `response_time`)
VALUES 
  ('offline', 0, 0, 0, NOW(), NULL)
ON DUPLICATE KEY UPDATE
  `check_time` = NOW();

-- ================================
-- 6. 数据验证
-- ================================
SELECT 'ML数据初始化完成' AS message;

SELECT 
    '模型信息' as category,
    COUNT(*) as count 
FROM `ml_model_info`;

SELECT 
    '推荐统计记录' as category,
    COUNT(*) as count 
FROM `ml_recommendation_stats`;

SELECT 
    '服务状态记录' as category,
    COUNT(*) as count 
FROM `ml_service_status`;

SELECT 
    '更新的推荐记录' as category,
    COUNT(*) as count 
FROM `diet_recommendation` 
WHERE `confidence_score` IS NOT NULL;

