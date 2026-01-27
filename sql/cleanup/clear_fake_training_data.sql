-- ================================
-- 清除模拟训练数据
-- ================================
-- 功能：清空ml_training_history表中的假训练记录
-- 原因：这些记录是模拟数据，不是真实训练
-- ================================

USE smart_diet_dev;

-- 查看当前训练记录
SELECT '清理前的训练记录：' AS '步骤';
SELECT 
    training_id,
    model_type,
    training_status,
    progress,
    start_time,
    end_time
FROM ml_training_history
ORDER BY training_id DESC;

-- 清空所有训练记录
TRUNCATE TABLE ml_training_history;

-- 验证清理结果
SELECT '清理后的训练记录：' AS '步骤';
SELECT COUNT(*) AS '训练记录数' FROM ml_training_history;

SELECT '✓ 模拟训练数据已清除' AS '结果';
SELECT '现在训练对话框将显示"无训练进行中"，这是真实状态' AS '说明';

