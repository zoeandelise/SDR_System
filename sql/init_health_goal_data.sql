USE smart_diet_dev;

-- 如果还没有创建表，先确保表存在
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
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4 COMMENT='健康目标表';

-- 插入多条真实的测试目标数据，为前端表格提供有效展示流
INSERT INTO `diet_goal` (`goal_id`, `user_id`, `goal_type`, `goal_name`, `description`, `target_value`, `current_value`, `unit`, `start_date`, `target_date`, `status`, `priority`, `completion_percentage`, `create_by`, `create_time`, `remark`) VALUES
(1001, 1, '0', '深秋减脂突击', '在两个月内把体重压碎到65kg以内', 65.00, 72.50, 'kg', '2026-02-10 08:00:00', '2026-04-10 08:00:00', '0', '2', 89.65, 'admin', NOW(), 'InitialWeight:78'),
(1002, 1, '3', '胸肌厚度提升计划', '配合力量训练将骨骼肌提升到36kg', 36.00, 32.50, 'kg', '2026-01-01 09:00:00', '2026-06-30 20:00:00', '0', '1', 90.27, 'admin', NOW(), 'InitialWeight:30'),
(1003, 1, '5', '戒断碳水降血糖', '控制空腹血糖水平到正常范围', 5.50, 6.20, 'mmol/L', '2026-02-20 07:00:00', '2026-03-20 07:00:00', '0', '2', 88.70, 'admin', NOW(), 'InitialWeight:7.8'),
(1004, 2, '2', '健康体脂维持', '维持现有体脂率在18%左右', 18.00, 18.50, '%', '2026-01-15 10:00:00', '2026-12-31 23:59:59', '0', '0', 97.22, 'admin', NOW(), 'InitialWeight:19'),
(1005, 1, '1', '力量突破储备期', '为了突破三大项重量，增加一定的净体重', 80.00, 78.00, 'kg', '2025-11-01 08:00:00', '2026-01-31 20:00:00', '1', '1', 100.00, 'admin', '2025-11-01 10:00:00', 'InitialWeight:74');
