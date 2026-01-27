-- ===================================================================
-- ML训练历史表性能优化索引
-- 用于提升training_status查询和进度更新的性能
-- ===================================================================

USE smart_diet_dev;

-- 1. 训练状态索引（WHERE training_status IN ('pending', 'training')）
CREATE INDEX IF NOT EXISTS idx_training_status 
ON ml_training_history(training_status);

-- 2. 开始时间索引（ORDER BY start_time DESC）
CREATE INDEX IF NOT EXISTS idx_start_time 
ON ml_training_history(start_time DESC);

-- 3. 模型类型索引（WHERE model_type = ?）
CREATE INDEX IF NOT EXISTS idx_model_type 
ON ml_training_history(model_type);

-- 4. 联合索引（WHERE + ORDER BY优化）
CREATE INDEX IF NOT EXISTS idx_status_time 
ON ml_training_history(training_status, start_time DESC);

-- 5. 训练ID主键已存在，无需额外创建

-- 验证索引创建
SHOW INDEX FROM ml_training_history;

SELECT 
    '索引优化完成' AS status,
    COUNT(*) AS index_count 
FROM information_schema.statistics 
WHERE table_schema = 'smart_diet_dev' 
AND table_name = 'ml_training_history';

