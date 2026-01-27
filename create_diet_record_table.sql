-- 创建饮食记录表
CREATE TABLE IF NOT EXISTS `diet_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `record_date` date NOT NULL COMMENT '记录日期',
  `meal_type` char(1) NOT NULL COMMENT '餐次类型(0早餐 1午餐 2晚餐 3加餐)',
  `total_calories` decimal(8,2) DEFAULT 0.00 COMMENT '总热量(kcal)',
  `total_protein` decimal(8,2) DEFAULT 0.00 COMMENT '总蛋白质(g)',
  `total_fat` decimal(8,2) DEFAULT 0.00 COMMENT '总脂肪(g)',
  `total_carbohydrate` decimal(8,2) DEFAULT 0.00 COMMENT '总碳水化合物(g)',
  `mongo_doc_id` varchar(100) DEFAULT NULL COMMENT 'MongoDB文档ID',
  `image_urls` text COMMENT '食物照片URLs',
  `notes` text COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_user_date` (`user_id`, `record_date`),
  KEY `idx_meal_type` (`meal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食记录表';

-- 创建饮食推荐记录表
CREATE TABLE IF NOT EXISTS `diet_recommendation` (
  `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '推荐ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `recommendation_date` date NOT NULL COMMENT '推荐日期',
  `meal_type` char(1) NOT NULL COMMENT '餐次类型(0早餐 1午餐 2晚餐 3加餐)',
  `recommended_foods` text COMMENT '推荐食物列表(JSON)',
  `target_calories` decimal(8,2) DEFAULT NULL COMMENT '目标热量',
  `algorithm_type` varchar(50) DEFAULT NULL COMMENT '推荐算法类型',
  `confidence_score` decimal(5,4) DEFAULT NULL COMMENT '推荐置信度',
  `status` char(1) DEFAULT '0' COMMENT '状态(0待确认 1已采纳 2已拒绝)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`recommendation_id`),
  KEY `idx_user_date` (`user_id`, `recommendation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食推荐记录表';
