USE smart_diet_dev;

CREATE TABLE IF NOT EXISTS `diet_goal` (
  `goal_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '目标ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '用户ID',
  `goal_type` varchar(20) DEFAULT NULL COMMENT '目标类型(0减重 1增重 2维持 3增肌 4减脂 5改善血糖 6改善血压)',
  `goal_name` varchar(100) DEFAULT NULL COMMENT '目标名称',
  `description` varchar(500) DEFAULT NULL COMMENT '目标描述',
  `target_value` decimal(10,2) DEFAULT NULL COMMENT '目标值',
  `current_value` decimal(10,2) DEFAULT NULL COMMENT '当前值',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `start_date` datetime DEFAULT NULL COMMENT '开始日期',
  `target_date` datetime DEFAULT NULL COMMENT '目标日期',
  `status` char(1) DEFAULT '0' COMMENT '状态(0进行中 1已完成 2已暂停 3已取消)',
  `priority` char(1) DEFAULT '1' COMMENT '优先级(0低 1中 2高)',
  `completion_percentage` decimal(5,2) DEFAULT '0.00' COMMENT '完成百分比',
  `reminder_settings` varchar(255) DEFAULT NULL COMMENT '提醒设置',
  `reward_mechanism` varchar(255) DEFAULT NULL COMMENT '奖励机制',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`goal_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康目标表';
