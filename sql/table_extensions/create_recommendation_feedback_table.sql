-- ================================
-- 创建推荐反馈扩展表 - 记录用户对推荐的详细反馈
-- ================================
-- 执行说明：
-- 1. 此表用于补充diet_recommendation表，记录更详细的用户反馈信息
-- 2. 用于算法优化和个性化推荐改进
-- 3. 执行时间约3-5秒
-- 4. 建议先在测试环境验证
-- ================================

USE smart_diet_dev;

-- ================================
-- 一、创建推荐反馈扩展表
-- ================================

DROP TABLE IF EXISTS diet_recommendation_feedback;

CREATE TABLE diet_recommendation_feedback (
    -- 主键
    feedback_id BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '反馈ID',
    
    -- 关联字段
    recommendation_id BIGINT(20) NOT NULL COMMENT '推荐记录ID(关联diet_recommendation表)',
    user_id BIGINT(20) NOT NULL COMMENT '用户ID',
    
    -- 反馈类型和结果
    feedback_type TINYINT(1) NOT NULL COMMENT '反馈类型:1=接受,2=完全拒绝,3=部分接受,4=收藏,5=举报不当',
    
    -- 拒绝原因（标准化）
    reject_reason VARCHAR(50) DEFAULT NULL COMMENT '拒绝原因:taste(口味不喜欢),ingredient(食材不喜欢),cooking_method(烹饪方式),allergy(过敏),health(健康原因),time(时间不够),cost(成本太高),availability(食材难买),other(其他)',
    
    -- 拒绝详细说明
    reject_details VARCHAR(500) DEFAULT NULL COMMENT '拒绝详细说明(如"不喜欢西兰花","对虾过敏"等具体原因)',
    
    -- 拒绝的具体食材（JSON数组）
    rejected_foods VARCHAR(500) DEFAULT NULL COMMENT '拒绝的具体食材列表(JSON数组,如["broccoli","shrimp"])',
    
    -- 用户评分
    rating TINYINT(1) DEFAULT NULL COMMENT '用户评分(1-5星,5星最高)',
    
    -- 用户文本评价
    comment TEXT DEFAULT NULL COMMENT '用户文本评价',
    
    -- 实际执行情况（部分接受时）
    actual_followed TINYINT(1) DEFAULT 0 COMMENT '是否实际遵循:0=未遵循,1=完全遵循,2=部分遵循',
    actual_followed_percentage DECIMAL(5,2) DEFAULT NULL COMMENT '实际遵循比例(%,0-100)',
    
    -- 替换食材信息（用户自己调整的）
    replaced_foods VARCHAR(1000) DEFAULT NULL COMMENT '用户替换的食材(JSON对象,如{"original":"broccoli","replaced":"cauliflower"})',
    
    -- 健康反馈
    felt_better TINYINT(1) DEFAULT NULL COMMENT '食用后感觉:1=感觉很好,0=无明显变化,-1=感觉不适',
    health_effect VARCHAR(200) DEFAULT NULL COMMENT '健康效果描述(如"血糖控制良好","感觉有饱腹感")',
    
    -- 重复选择意愿
    would_repeat TINYINT(1) DEFAULT NULL COMMENT '是否愿意重复:1=愿意,0=不愿意',
    
    -- 时间戳
    feedback_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '反馈时间',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    -- 主键和索引
    PRIMARY KEY (feedback_id),
    KEY idx_recommendation_id (recommendation_id),
    KEY idx_user_id (user_id),
    KEY idx_feedback_type (feedback_type),
    KEY idx_reject_reason (reject_reason),
    KEY idx_rating (rating),
    KEY idx_feedback_time (feedback_time),
    
    -- 外键约束（可选，如果需要强制引用完整性）
    -- CONSTRAINT fk_recommendation FOREIGN KEY (recommendation_id) REFERENCES diet_recommendation(recommendation_id) ON DELETE CASCADE,
    -- CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES sys_user(user_id) ON DELETE CASCADE,
    
    -- 数据约束
    CONSTRAINT chk_feedback_type CHECK (feedback_type IN (1, 2, 3, 4, 5)),
    CONSTRAINT chk_rating CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),
    CONSTRAINT chk_actual_followed CHECK (actual_followed IN (0, 1, 2)),
    CONSTRAINT chk_followed_percentage CHECK (actual_followed_percentage IS NULL OR (actual_followed_percentage >= 0 AND actual_followed_percentage <= 100)),
    CONSTRAINT chk_felt_better CHECK (felt_better IS NULL OR felt_better IN (-1, 0, 1)),
    CONSTRAINT chk_would_repeat CHECK (would_repeat IS NULL OR would_repeat IN (0, 1))
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食推荐反馈扩展表(记录用户对推荐的详细反馈,用于算法优化)';

-- ================================
-- 二、创建拒绝原因统计视图
-- ================================
-- 用于快速查询各类拒绝原因的分布

CREATE OR REPLACE VIEW v_reject_reason_stats AS
SELECT 
    reject_reason AS '拒绝原因',
    COUNT(*) AS '拒绝次数',
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diet_recommendation_feedback WHERE feedback_type = 2), 2) AS '占比(%)',
    GROUP_CONCAT(DISTINCT reject_details SEPARATOR '; ') AS '典型原因示例'
FROM diet_recommendation_feedback
WHERE feedback_type = 2 AND reject_reason IS NOT NULL
GROUP BY reject_reason
ORDER BY COUNT(*) DESC;

-- ================================
-- 三、创建用户不喜欢食材统计视图
-- ================================
-- 用于汇总用户拒绝的食材，辅助个性化推荐

CREATE OR REPLACE VIEW v_user_disliked_foods AS
SELECT 
    user_id AS '用户ID',
    COUNT(DISTINCT feedback_id) AS '拒绝次数',
    rejected_foods AS '拒绝的食材',
    COUNT(CASE WHEN reject_reason = 'taste' THEN 1 END) AS '口味原因拒绝',
    COUNT(CASE WHEN reject_reason = 'allergy' THEN 1 END) AS '过敏原因拒绝',
    COUNT(CASE WHEN reject_reason = 'ingredient' THEN 1 END) AS '食材原因拒绝'
FROM diet_recommendation_feedback
WHERE rejected_foods IS NOT NULL
GROUP BY user_id, rejected_foods;

-- ================================
-- 四、创建推荐质量评分视图
-- ================================
-- 按算法类型统计推荐质量

CREATE OR REPLACE VIEW v_recommendation_quality_by_algorithm AS
SELECT 
    dr.algorithm_type AS '算法类型',
    COUNT(drf.feedback_id) AS '反馈总数',
    COUNT(CASE WHEN drf.feedback_type = 1 THEN 1 END) AS '接受数',
    ROUND(COUNT(CASE WHEN drf.feedback_type = 1 THEN 1 END) * 100.0 / COUNT(drf.feedback_id), 2) AS '接受率(%)',
    ROUND(AVG(drf.rating), 2) AS '平均评分',
    COUNT(CASE WHEN drf.would_repeat = 1 THEN 1 END) AS '愿意重复数',
    ROUND(COUNT(CASE WHEN drf.would_repeat = 1 THEN 1 END) * 100.0 / 
          NULLIF(COUNT(CASE WHEN drf.would_repeat IS NOT NULL THEN 1 END), 0), 2) AS '重复意愿率(%)'
FROM diet_recommendation dr
INNER JOIN diet_recommendation_feedback drf ON dr.recommendation_id = drf.recommendation_id
GROUP BY dr.algorithm_type
ORDER BY AVG(drf.rating) DESC;

-- ================================
-- 五、插入示例数据（可选，用于测试）
-- ================================
-- 如果diet_recommendation表中有数据，可以为其生成一些示例反馈

/*
-- 为最近的10条推荐记录生成示例反馈
INSERT INTO diet_recommendation_feedback 
    (recommendation_id, user_id, feedback_type, reject_reason, reject_details, rating, would_repeat, feedback_time)
SELECT 
    recommendation_id,
    user_id,
    CASE 
        WHEN RAND() < 0.7 THEN 1  -- 70%接受
        WHEN RAND() < 0.9 THEN 2  -- 20%拒绝
        ELSE 3  -- 10%部分接受
    END AS feedback_type,
    CASE 
        WHEN RAND() < 0.9 THEN NULL
        ELSE ELT(FLOOR(1 + RAND() * 5), 'taste', 'ingredient', 'time', 'cost', 'other')
    END AS reject_reason,
    CASE 
        WHEN RAND() < 0.9 THEN NULL
        ELSE '示例拒绝原因'
    END AS reject_details,
    FLOOR(3 + RAND() * 3) AS rating,  -- 评分3-5
    CASE WHEN RAND() < 0.8 THEN 1 ELSE 0 END AS would_repeat,
    DATE_ADD(recommendation_date, INTERVAL FLOOR(RAND() * 24) HOUR) AS feedback_time
FROM diet_recommendation
ORDER BY recommendation_date DESC
LIMIT 10;
*/

-- ================================
-- 六、验证表创建结果
-- ================================

SELECT '========== 表创建完成，验证结果 ==========' AS '验证';

-- 查看表结构
SELECT 
    COLUMN_NAME AS '字段名',
    DATA_TYPE AS '数据类型',
    COLUMN_TYPE AS '完整类型',
    IS_NULLABLE AS '可空',
    COLUMN_DEFAULT AS '默认值',
    COLUMN_COMMENT AS '注释'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_recommendation_feedback'
ORDER BY ORDINAL_POSITION;

-- 查看索引
SELECT 
    INDEX_NAME AS '索引名',
    COLUMN_NAME AS '字段名',
    INDEX_TYPE AS '索引类型'
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME = 'diet_recommendation_feedback'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- 查看视图
SELECT 
    TABLE_NAME AS '视图名',
    VIEW_DEFINITION AS '视图定义'
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'smart_diet_dev' 
  AND TABLE_NAME LIKE 'v_%reject%' OR TABLE_NAME LIKE 'v_%quality%' OR TABLE_NAME LIKE 'v_%disliked%';

SELECT '✓ diet_recommendation_feedback表创建成功！' AS '提示',
       '该表可用于记录用户对推荐的详细反馈，辅助算法优化' AS '用途';

