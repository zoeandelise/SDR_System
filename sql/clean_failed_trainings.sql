-- 清理失败的训练记录
USE smart_diet_dev;

DELETE FROM ml_training_history WHERE training_status = 'pending';

SELECT '已清理失败的训练记录' AS message;
SELECT COUNT(*) AS remaining_records FROM ml_training_history;

