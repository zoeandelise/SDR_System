-- 用户体重记录表
-- 用于追踪用户体重变化

CREATE TABLE IF NOT EXISTS diet_weight_record (
  record_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  weight DECIMAL(5,2) NOT NULL COMMENT '体重(kg)',
  record_date DATE NOT NULL COMMENT '记录日期',
  notes VARCHAR(200) COMMENT '备注',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_user_date (user_id, record_date),
  KEY idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户体重记录表';
