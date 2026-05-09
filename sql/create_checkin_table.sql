-- =============================================
-- Phase 25: 饮食打卡表
-- =============================================
CREATE TABLE IF NOT EXISTS `diet_checkin` (
  `checkin_id`     BIGINT        NOT NULL AUTO_INCREMENT COMMENT '打卡ID',
  `user_id`        BIGINT        NOT NULL COMMENT '用户ID',
  `checkin_date`   DATE          NOT NULL COMMENT '打卡日期',
  `meal_summary`   VARCHAR(500)  DEFAULT NULL COMMENT '当日饮食摘要',
  `total_calories` DECIMAL(10,2) DEFAULT 0 COMMENT '当日总热量',
  `mood`           VARCHAR(20)   DEFAULT 'good' COMMENT '心情(great/good/normal/bad)',
  `note`           VARCHAR(200)  DEFAULT NULL COMMENT '打卡心得',
  `create_time`    DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `checkin_date`),
  KEY `idx_checkin_date` (`checkin_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食打卡表';
