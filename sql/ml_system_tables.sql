-- ================================
-- ML推荐管理系统核心数据表
-- ================================

USE smart_diet_dev;

-- ML模型信息表
CREATE TABLE IF NOT EXISTS `ml_model_info` (
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

-- ML训练历史表
CREATE TABLE IF NOT EXISTS `ml_training_history` (
  `training_id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '训练ID',
  `model_type` VARCHAR(50) NOT NULL COMMENT '模型类型',
  `training_status` VARCHAR(20) NOT NULL COMMENT '训练状态：pending/training/completed/failed',
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

-- ML推荐统计表
CREATE TABLE IF NOT EXISTS `ml_recommendation_stats` (
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

-- ML服务状态记录表
CREATE TABLE IF NOT EXISTS `ml_service_status` (
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

-- 修改diet_recommendation表，添加ML相关字段
ALTER TABLE `diet_recommendation` 
ADD COLUMN IF NOT EXISTS `confidence_score` DECIMAL(5,4) DEFAULT NULL COMMENT '置信度评分',
ADD COLUMN IF NOT EXISTS `applied_flag` CHAR(1) DEFAULT '0' COMMENT '是否应用：0否 1是',
ADD COLUMN IF NOT EXISTS `response_time` INT(11) DEFAULT NULL COMMENT '推荐响应时间（毫秒）';

-- 修改algorithm_type字段默认值
ALTER TABLE `diet_recommendation` 
MODIFY COLUMN `algorithm_type` VARCHAR(50) DEFAULT 'rule_based' COMMENT '推荐算法类型';

SELECT 'ML系统数据表创建完成' AS message;

