-- ================================
-- ML推荐管理系统完整数据库脚本
-- 包含：表创建、表修改、数据初始化、统计生成
-- 执行数据库：smart_diet_dev
-- ================================

USE smart_diet_dev;

SET FOREIGN_KEY_CHECKS = 0;

-- ================================
-- 第一部分：创建ML核心数据表
-- ================================

-- 1. ML模型信息表
DROP TABLE IF EXISTS `ml_model_info`;
CREATE TABLE `ml_model_info` (
  `model_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '模型ID',
  `model_name` VARCHAR(100) NOT NULL COMMENT '模型名称',
  `model_type` VARCHAR(50) NOT NULL COMMENT '模型类型：collaborative_filtering/content_based/deep_learning',
  `model_version` VARCHAR(50) DEFAULT '1.0.0' COMMENT '模型版本',
  `is_loaded` TINYINT(1) DEFAULT 0 COMMENT '是否已加载：0否 1是',
  `model_path` VARCHAR(500) DEFAULT NULL COMMENT '模型文件路径',
  `accuracy` DECIMAL(5,4) DEFAULT NULL COMMENT '准确率',
  `last_trained_time` DATETIME DEFAULT NULL COMMENT '最后训练时间',
  `training_data_size` INT(11) DEFAULT NULL COMMENT '训练数据量',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `uk_model_type` (`model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ML模型信息表';

-- 2. ML训练历史表
DROP TABLE IF EXISTS `ml_training_history`;
CREATE TABLE `ml_training_history` (
  `training_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '训练ID',
  `model_type` VARCHAR(50) NOT NULL COMMENT '模型类型',
  `training_status` VARCHAR(20) NOT NULL COMMENT '训练状态：pending/training/completed/failed/cancelled',
  `progress` INT(3) DEFAULT 0 COMMENT '训练进度 0-100',
  `current_step` VARCHAR(200) DEFAULT NULL COMMENT '当前训练步骤描述',
  `start_time` DATETIME DEFAULT NULL COMMENT '开始时间',
  `end_time` DATETIME DEFAULT NULL COMMENT '结束时间',
  `elapsed_time` INT(11) DEFAULT NULL COMMENT '耗时（秒）',
  `training_days` INT(11) DEFAULT 180 COMMENT '训练数据天数',
  `data_size` INT(11) DEFAULT NULL COMMENT '训练数据量',
  `accuracy` DECIMAL(5,4) DEFAULT NULL COMMENT '训练后准确率',
  `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`training_id`),
  KEY `idx_model_type` (`model_type`),
  KEY `idx_status` (`training_status`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ML训练历史表';

-- 3. ML推荐统计表
DROP TABLE IF EXISTS `ml_recommendation_stats`;
CREATE TABLE `ml_recommendation_stats` (
  `stat_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `stat_date` DATE NOT NULL COMMENT '统计日期',
  `algorithm_type` VARCHAR(50) DEFAULT 'rule_based' COMMENT '算法类型',
  `total_recommendations` INT(11) DEFAULT 0 COMMENT '总推荐数',
  `accepted_recommendations` INT(11) DEFAULT 0 COMMENT '接受推荐数',
  `acceptance_rate` DECIMAL(5,4) DEFAULT 0.0000 COMMENT '接受率',
  `avg_score` DECIMAL(5,2) DEFAULT 0.00 COMMENT '平均评分',
  `avg_response_time` INT(11) DEFAULT NULL COMMENT '平均响应时间（毫秒）',
  `active_users` INT(11) DEFAULT 0 COMMENT '活跃用户数',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stat_id`),
  UNIQUE KEY `uk_date_algorithm` (`stat_date`, `algorithm_type`),
  KEY `idx_stat_date` (`stat_date`),
  KEY `idx_algorithm_type` (`algorithm_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ML推荐统计表';

-- 4. ML服务状态记录表
DROP TABLE IF EXISTS `ml_service_status`;
CREATE TABLE `ml_service_status` (
  `status_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '状态ID',
  `service_status` VARCHAR(20) NOT NULL COMMENT '服务状态：healthy/offline/degraded',
  `data_loader_status` TINYINT(1) DEFAULT 0 COMMENT '数据加载器状态：0离线 1正常',
  `user_profiling_status` TINYINT(1) DEFAULT 0 COMMENT '用户画像状态：0离线 1正常',
  `recommender_status` TINYINT(1) DEFAULT 0 COMMENT '推荐引擎状态：0离线 1正常',
  `check_time` DATETIME NOT NULL COMMENT '检查时间',
  `response_time` INT(11) DEFAULT NULL COMMENT '响应时间（毫秒）',
  `error_message` TEXT DEFAULT NULL COMMENT '错误信息',
  PRIMARY KEY (`status_id`),
  KEY `idx_check_time` (`check_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ML服务状态记录表';

-- ================================
-- 第二部分：修改现有表
-- ================================

-- 检查并添加diet_recommendation表的ML相关字段
SET @dbname = DATABASE();
SET @tablename = 'diet_recommendation';
SET @columnname1 = 'confidence_score';
SET @columnname2 = 'applied_flag';
SET @columnname3 = 'response_time';

-- 添加confidence_score字段
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE (table_name = @tablename) AND (table_schema = @dbname) AND (column_name = @columnname1)) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname1, ' DECIMAL(5,4) DEFAULT NULL COMMENT ''置信度评分''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 添加applied_flag字段
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE (table_name = @tablename) AND (table_schema = @dbname) AND (column_name = @columnname2)) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname2, ' CHAR(1) DEFAULT ''0'' COMMENT ''是否应用：0否 1是''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 添加response_time字段
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE (table_name = @tablename) AND (table_schema = @dbname) AND (column_name = @columnname3)) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname3, ' INT(11) DEFAULT NULL COMMENT ''推荐响应时间（毫秒）''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 修改algorithm_type字段类型和默认值
ALTER TABLE `diet_recommendation` 
MODIFY COLUMN `algorithm_type` VARCHAR(50) DEFAULT 'rule_based' COMMENT '推荐算法类型';

-- ================================
-- 第三部分：初始化ML基础数据
-- ================================

-- 1. 初始化3个ML模型记录
INSERT INTO `ml_model_info` (`model_name`, `model_type`, `is_loaded`, `model_version`, `create_time`) VALUES
('协同过滤模型', 'collaborative_filtering', 0, '1.0.0', NOW()),
('内容推荐模型', 'content_based', 0, '1.0.0', NOW()),
('深度学习模型', 'deep_learning', 0, '1.0.0', NOW())
ON DUPLICATE KEY UPDATE 
  `model_name` = VALUES(`model_name`),
  `update_time` = NOW();

-- 2. 初始化服务状态记录
INSERT INTO `ml_service_status` 
  (`service_status`, `data_loader_status`, `user_profiling_status`, `recommender_status`, `check_time`, `response_time`)
VALUES 
  ('offline', 0, 0, 0, NOW(), NULL);

-- ================================
-- 第四部分：更新现有推荐记录
-- ================================

-- 为现有推荐记录添加ML相关数据
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
-- 第五部分：生成推荐统计数据
-- ================================

-- 基于现有推荐记录生成统计数据
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

-- 如果现有推荐记录很少，生成最近7天的示例统计数据
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
    (SELECT 'rule_based' as algo 
     UNION SELECT 'collaborative_filtering' 
     UNION SELECT 'content_based' 
     UNION SELECT 'deep_learning') as algos
WHERE NOT EXISTS (
    SELECT 1 FROM `ml_recommendation_stats` 
    WHERE `stat_date` = CURDATE() - INTERVAL n DAY AND `algorithm_type` = algo
)
ORDER BY n, algo;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================
-- 第六部分：数据验证
-- ================================

SELECT '========================================' AS '';
SELECT 'ML推荐管理系统数据库初始化完成' AS '状态';
SELECT '========================================' AS '';

SELECT '1. ML核心表创建' AS '检查项';
SELECT 
    TABLE_NAME AS '表名',
    TABLE_COMMENT AS '说明',
    CREATE_TIME AS '创建时间'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME LIKE 'ml_%'
ORDER BY TABLE_NAME;

SELECT '2. 模型信息数据' AS '检查项';
SELECT 
    model_name AS '模型名称',
    model_type AS '模型类型',
    CASE WHEN is_loaded = 1 THEN '已加载' ELSE '未加载' END AS '加载状态',
    model_version AS '版本',
    IFNULL(last_trained_time, '从未训练') AS '最后训练时间'
FROM ml_model_info
ORDER BY model_id;

SELECT '3. 推荐统计数据' AS '检查项';
SELECT 
    COUNT(*) AS '统计记录数',
    COUNT(DISTINCT stat_date) AS '统计天数',
    COUNT(DISTINCT algorithm_type) AS '算法类型数',
    MIN(stat_date) AS '最早日期',
    MAX(stat_date) AS '最新日期'
FROM ml_recommendation_stats;

SELECT '4. 算法类型分布' AS '检查项';
SELECT 
    algorithm_type AS '算法类型',
    COUNT(*) AS '记录数',
    SUM(total_recommendations) AS '总推荐数',
    ROUND(AVG(acceptance_rate) * 100, 2) AS '平均接受率(%)',
    ROUND(AVG(avg_score), 2) AS '平均评分'
FROM ml_recommendation_stats
GROUP BY algorithm_type
ORDER BY algorithm_type;

SELECT '5. 服务状态记录' AS '检查项';
SELECT 
    service_status AS '服务状态',
    CASE WHEN data_loader_status = 1 THEN '正常' ELSE '离线' END AS '数据加载器',
    CASE WHEN user_profiling_status = 1 THEN '正常' ELSE '离线' END AS '用户画像',
    CASE WHEN recommender_status = 1 THEN '正常' ELSE '离线' END AS '推荐引擎',
    check_time AS '检查时间'
FROM ml_service_status
ORDER BY check_time DESC
LIMIT 1;

SELECT '6. diet_recommendation表字段' AS '检查项';
SELECT 
    COLUMN_NAME AS '字段名',
    COLUMN_TYPE AS '类型',
    COLUMN_COMMENT AS '说明'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_recommendation'
  AND COLUMN_NAME IN ('confidence_score', 'applied_flag', 'response_time', 'algorithm_type')
ORDER BY ORDINAL_POSITION;

SELECT '7. 训练历史记录' AS '检查项';
SELECT 
    CASE WHEN COUNT(*) = 0 THEN '暂无训练记录（正常，启动训练后会有记录）' ELSE CONCAT('共', COUNT(*), '条记录') END AS '状态'
FROM ml_training_history;

SELECT '========================================' AS '';
SELECT '初始化完成！可以启动后端服务了' AS '提示';
SELECT '访问: http://localhost:81/diet/ml/management' AS '测试地址';
SELECT '========================================' AS '';

-- ================================
-- 附录：快速查询语句
-- ================================

-- 查看所有ML相关表
-- SHOW TABLES LIKE 'ml_%';

-- 查看模型信息
-- SELECT * FROM ml_model_info;

-- 查看最近推荐统计
-- SELECT * FROM ml_recommendation_stats ORDER BY stat_date DESC, algorithm_type LIMIT 20;

-- 查看服务状态历史
-- SELECT * FROM ml_service_status ORDER BY check_time DESC LIMIT 10;

-- 查看训练历史
-- SELECT * FROM ml_training_history ORDER BY start_time DESC LIMIT 10;

-- 按算法类型汇总推荐数据
-- SELECT 
--     algorithm_type,
--     SUM(total_recommendations) as total,
--     AVG(acceptance_rate) as avg_acceptance,
--     AVG(avg_score) as avg_score
-- FROM ml_recommendation_stats
-- GROUP BY algorithm_type;

-- 查看最近7天推荐趋势
-- SELECT 
--     stat_date,
--     SUM(total_recommendations) as daily_total,
--     AVG(acceptance_rate) as daily_acceptance,
--     SUM(active_users) as daily_users
-- FROM ml_recommendation_stats
-- WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
-- GROUP BY stat_date
-- ORDER BY stat_date DESC;

