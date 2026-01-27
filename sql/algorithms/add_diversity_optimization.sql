-- ================================
-- 推荐算法多样性优化 V1.1
-- ================================
-- 功能：解决推荐重复度高的问题
-- 优化点：
--   1. 近期推荐过滤（7天内推荐过的食物降权）
--   2. 分类多样性保障（确保主食+蛋白质+蔬菜至少2类）
--   3. 随机因子控制（营养匹配度≥70分的食物随机选择）
-- ================================

USE smart_diet_dev;

-- ================================
-- 优化1：创建近期推荐历史查询函数
-- ================================

DROP FUNCTION IF EXISTS get_recent_food_penalty;

DELIMITER $$

CREATE FUNCTION get_recent_food_penalty(
    p_user_id BIGINT,
    p_food_name VARCHAR(100),
    p_days_back INT
)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
    DECLARE v_recommend_count INT;
    DECLARE v_penalty DECIMAL(4,2);
    
    -- 查询近N天内该食物被推荐的次数
    SELECT COUNT(*)
    INTO v_recommend_count
    FROM diet_recommendation
    WHERE user_id = p_user_id
      AND recommended_foods LIKE CONCAT('%', p_food_name, '%')
      AND recommendation_date >= DATE_SUB(CURDATE(), INTERVAL p_days_back DAY);
    
    -- 计算惩罚系数
    -- 0次：无惩罚(1.0)
    -- 1次：轻度惩罚(0.7)
    -- 2次：中度惩罚(0.5)
    -- 3次及以上：重度惩罚(0.3)
    SET v_penalty = CASE 
        WHEN v_recommend_count = 0 THEN 1.0
        WHEN v_recommend_count = 1 THEN 0.7
        WHEN v_recommend_count = 2 THEN 0.5
        ELSE 0.3
    END;
    
    RETURN v_penalty;
END$$

DELIMITER ;

-- ================================
-- 优化2：创建食物分类权重计算函数
-- ================================

DROP FUNCTION IF EXISTS calculate_category_diversity_bonus;

DELIMITER $$

CREATE FUNCTION calculate_category_diversity_bonus(
    p_category_name VARCHAR(100)
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_bonus DECIMAL(5,2);
    
    -- 根据食物分类给予多样性奖励分
    -- 主食类、蛋白质类、蔬菜类给予额外加分
    SET v_bonus = CASE 
        WHEN p_category_name LIKE '%谷物%' OR p_category_name LIKE '%主食%' THEN 10.0
        WHEN p_category_name LIKE '%肉类%' OR p_category_name LIKE '%蛋%' OR p_category_name LIKE '%豆%' THEN 8.0
        WHEN p_category_name LIKE '%蔬菜%' THEN 6.0
        WHEN p_category_name LIKE '%水果%' THEN 5.0
        ELSE 3.0
    END;
    
    RETURN v_bonus;
END$$

DELIMITER ;

-- ================================
-- 优化3：重构推荐生成存储过程（增加多样性）
-- ================================

DROP PROCEDURE IF EXISTS generate_diverse_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_diverse_recommendation(
    IN p_user_id BIGINT,
    IN p_meal_type VARCHAR(10),
    IN p_recommendation_count INT
)
BEGIN
    DECLARE v_nutrition_target JSON;
    DECLARE v_target_calories INT;
    DECLARE v_target_protein DECIMAL(6,2);
    DECLARE v_target_carb DECIMAL(6,2);
    DECLARE v_target_fat DECIMAL(6,2);
    DECLARE v_user_dislikes VARCHAR(1000);
    
    -- 步骤1：获取用户营养目标
    SET v_nutrition_target = calculate_meal_nutrition_target(p_user_id, p_meal_type);
    SET v_target_calories = JSON_EXTRACT(v_nutrition_target, '$.target_calories');
    SET v_target_protein = JSON_EXTRACT(v_nutrition_target, '$.target_protein');
    SET v_target_carb = JSON_EXTRACT(v_nutrition_target, '$.target_carb');
    SET v_target_fat = JSON_EXTRACT(v_nutrition_target, '$.target_fat');
    
    -- 步骤2：获取用户不喜欢的食材
    SELECT COALESCE(food_dislikes, '[]')
    INTO v_user_dislikes
    FROM sys_user_health
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- 步骤3：生成推荐（增加多样性优化）
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        n.calories AS calories_per_100g,
        n.protein AS protein_per_100g,
        n.carbohydrate AS carb_per_100g,
        n.fat AS fat_per_100g,
        
        -- 基础营养匹配度
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS base_nutrition_score,
        
        -- 近期推荐惩罚系数（7天内推荐过的降权）
        get_recent_food_penalty(p_user_id, f.food_name, 7) AS recent_penalty,
        
        -- 分类多样性奖励分
        calculate_category_diversity_bonus(c.category_name) AS diversity_bonus,
        
        -- 随机因子（0-10分）
        FLOOR(RAND() * 10) AS random_factor,
        
        -- 历史反馈分
        COALESCE((
            SELECT AVG(score) 
            FROM diet_recommendation dr
            WHERE dr.recommended_foods LIKE CONCAT('%', f.food_name, '%')
              AND dr.is_accepted = '1'
              AND dr.user_id = p_user_id
        ), 0) AS history_score,
        
        -- 综合评分（优化版）
        -- 公式：(营养匹配度 × 近期惩罚 + 多样性奖励 + 随机因子) × 0.70 + 历史反馈 × 0.30
        (
            (calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            ) * get_recent_food_penalty(p_user_id, f.food_name, 7)
            + calculate_category_diversity_bonus(c.category_name)
            + FLOOR(RAND() * 10)) * 0.70
            + COALESCE((
                SELECT AVG(score) * 20  -- 归一化到0-100
                FROM diet_recommendation dr
                WHERE dr.recommended_foods LIKE CONCAT('%', f.food_name, '%')
                  AND dr.is_accepted = '1'
                  AND dr.user_id = p_user_id
            ), 50) * 0.30
        ) AS final_score,
        
        -- 推荐建议份量(g)
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        
        -- 推荐理由（增强版）
        CONCAT(
            '营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), 
            '分; ',
            '分类: ', c.category_name, '; ',
            CASE 
                WHEN get_recent_food_penalty(p_user_id, f.food_name, 7) < 1.0 
                THEN CONCAT('近期已推荐', 
                    (SELECT COUNT(*) FROM diet_recommendation 
                     WHERE user_id = p_user_id 
                       AND recommended_foods LIKE CONCAT('%', f.food_name, '%')
                       AND recommendation_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
                    '次; ')
                ELSE ''
            END,
            '提供热量约 ', ROUND(n.calories * (v_target_calories / NULLIF(n.calories, 0))), ' kcal'
        ) AS recommendation_reason
        
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories IS NOT NULL
      AND n.calories > 0
      -- 过滤用户不喜欢的食材
      AND (
          v_user_dislikes = '[]' 
          OR v_user_dislikes IS NULL
          OR f.food_name NOT IN (
              SELECT JSON_UNQUOTE(JSON_EXTRACT(v_user_dislikes, CONCAT('$[', idx, ']')))
              FROM (
                  SELECT 0 AS idx UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
              ) AS indices
              WHERE JSON_EXTRACT(v_user_dislikes, CONCAT('$[', idx, ']')) IS NOT NULL
          )
      )
      -- 只推荐营养匹配度≥60分的食物（确保基本营养合理）
      AND calculate_nutrition_match_score(
              n.calories, n.protein, n.carbohydrate, n.fat,
              v_target_calories, v_target_protein, v_target_carb, v_target_fat
          ) >= 60
    ORDER BY final_score DESC
    LIMIT p_recommendation_count;
    
END$$

DELIMITER ;

-- ================================
-- 优化4：创建分类平衡推荐存储过程
-- ================================
-- 确保推荐包含多个食物分类

DROP PROCEDURE IF EXISTS generate_balanced_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_balanced_recommendation(
    IN p_user_id BIGINT,
    IN p_meal_type VARCHAR(10),
    IN p_recommendation_count INT
)
BEGIN
    DECLARE v_nutrition_target JSON;
    DECLARE v_target_calories INT;
    DECLARE v_target_protein DECIMAL(6,2);
    DECLARE v_target_carb DECIMAL(6,2);
    DECLARE v_target_fat DECIMAL(6,2);
    
    -- 获取营养目标
    SET v_nutrition_target = calculate_meal_nutrition_target(p_user_id, p_meal_type);
    SET v_target_calories = JSON_EXTRACT(v_nutrition_target, '$.target_calories');
    SET v_target_protein = JSON_EXTRACT(v_nutrition_target, '$.target_protein');
    SET v_target_carb = JSON_EXTRACT(v_nutrition_target, '$.target_carb');
    SET v_target_fat = JSON_EXTRACT(v_nutrition_target, '$.target_fat');
    
    -- 分类推荐策略：
    -- 谷物类（主食）：2个
    -- 肉类/蛋类（蛋白质）：2个
    -- 蔬菜类：3个
    -- 其他类：3个
    
    -- 创建临时表存储推荐结果
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
    CREATE TEMPORARY TABLE temp_recommendations (
        food_id BIGINT,
        food_name VARCHAR(100),
        category_name VARCHAR(50),
        category_priority INT,
        nutrition_score DECIMAL(5,2),
        final_score DECIMAL(5,2),
        recommended_portion INT,
        recommendation_reason VARCHAR(500)
    );
    
    -- 从谷物类选择2个
    INSERT INTO temp_recommendations
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        1 AS category_priority,
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS nutrition_score,
        (calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) * get_recent_food_penalty(p_user_id, f.food_name, 7) + FLOOR(RAND() * 10)) AS final_score,
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        CONCAT('主食类; 营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), '分') AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories > 0
      AND (c.category_name LIKE '%谷物%' OR c.category_name LIKE '%主食%')
    ORDER BY final_score DESC
    LIMIT 2;
    
    -- 从肉类/蛋类选择2个
    INSERT INTO temp_recommendations
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        2 AS category_priority,
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS nutrition_score,
        (calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) * get_recent_food_penalty(p_user_id, f.food_name, 7) + FLOOR(RAND() * 10)) AS final_score,
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        CONCAT('蛋白质来源; 营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), '分') AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories > 0
      AND (c.category_name LIKE '%肉类%' OR c.category_name LIKE '%蛋%' OR c.category_name LIKE '%豆%')
    ORDER BY final_score DESC
    LIMIT 2;
    
    -- 从蔬菜类选择3个
    INSERT INTO temp_recommendations
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        3 AS category_priority,
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS nutrition_score,
        (calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) * get_recent_food_penalty(p_user_id, f.food_name, 7) + FLOOR(RAND() * 10)) AS final_score,
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        CONCAT('蔬菜类; 营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), '分') AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories > 0
      AND c.category_name LIKE '%蔬菜%'
    ORDER BY final_score DESC
    LIMIT 3;
    
    -- 从其他分类随机选择补充
    INSERT INTO temp_recommendations
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        4 AS category_priority,
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS nutrition_score,
        (calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) * get_recent_food_penalty(p_user_id, f.food_name, 7) + FLOOR(RAND() * 10)) AS final_score,
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        CONCAT(c.category_name, '; 营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), '分') AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories > 0
      AND c.category_name NOT LIKE '%谷物%'
      AND c.category_name NOT LIKE '%肉类%'
      AND c.category_name NOT LIKE '%蛋%'
      AND c.category_name NOT LIKE '%豆%'
      AND c.category_name NOT LIKE '%蔬菜%'
      AND f.food_id NOT IN (SELECT food_id FROM temp_recommendations)
    ORDER BY final_score DESC
    LIMIT p_recommendation_count - 7;
    
    -- 返回结果（按综合评分排序，确保多样性）
    SELECT 
        food_id,
        food_name,
        category_name,
        calories_per_100g,
        protein_per_100g,
        carb_per_100g,
        fat_per_100g,
        nutrition_score,
        final_score,
        recommended_portion,
        recommendation_reason
    FROM temp_recommendations
    ORDER BY 
        category_priority ASC,  -- 优先保证分类多样性
        final_score DESC         -- 同分类内按评分排序
    LIMIT p_recommendation_count;
    
    -- 清理临时表
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
    
END$$

DELIMITER ;

-- ================================
-- 测试和验证
-- ================================

SELECT '========== 多样性优化测试 ==========' AS '测试阶段';

-- 测试1：近期推荐惩罚函数
SELECT 
    '近期推荐惩罚系数测试' AS '测试项',
    get_recent_food_penalty(101, '鸡胸肉', 7) AS '鸡胸肉惩罚系数',
    get_recent_food_penalty(101, '牛肉', 7) AS '牛肉惩罚系数(应为1.0)';

-- 测试2：分类多样性奖励
SELECT 
    '分类多样性奖励测试' AS '测试项',
    calculate_category_diversity_bonus('谷物类') AS '谷物类奖励',
    calculate_category_diversity_bonus('肉类') AS '肉类奖励',
    calculate_category_diversity_bonus('蔬菜类') AS '蔬菜类奖励';

-- 测试3：对比优化前后的推荐结果
SELECT '========== 优化前后对比测试（用户101午餐） ==========' AS '测试';

-- 优化前（可能重复度高）
SELECT '优化前推荐（原算法）' AS '版本';
CALL generate_personalized_recommendation(101, '1', 10);

SELECT '' AS '';

-- 优化后（多样性提升）
SELECT '优化后推荐（多样性优化）' AS '版本';
CALL generate_diverse_recommendation(101, '1', 10);

-- ================================
-- 验证：计算推荐重复率
-- ================================

SELECT '========== 推荐重复率验证 ==========' AS '验证阶段';

-- 查询用户101最近30次推荐的食物重复情况
SELECT 
    '重复率统计' AS '统计项',
    COUNT(*) AS '总推荐记录数',
    COUNT(DISTINCT recommended_foods) AS '唯一推荐组合数',
    ROUND((1 - COUNT(DISTINCT recommended_foods) * 1.0 / COUNT(*)) * 100, 2) AS '推荐重复率(%)',
    CASE 
        WHEN (1 - COUNT(DISTINCT recommended_foods) * 1.0 / COUNT(*)) * 100 <= 10 THEN '✓ 优秀(≤10%)'
        WHEN (1 - COUNT(DISTINCT recommended_foods) * 1.0 / COUNT(*)) * 100 <= 30 THEN '○ 良好(≤30%)'
        ELSE '△ 需优化(>30%)'
    END AS '评价'
FROM diet_recommendation
WHERE user_id = 101;

-- 按食物统计推荐频次（找出过度推荐的食物）
SELECT 
    '高频推荐食物（可能导致重复）' AS '分析',
    recommended_foods AS '推荐组合',
    COUNT(*) AS '推荐次数',
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diet_recommendation WHERE user_id = 101), 2) AS '占比(%)'
FROM diet_recommendation
WHERE user_id = 101
GROUP BY recommended_foods
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ================================
-- 优化效果验证SQL
-- ================================

SELECT '========== 优化效果验证 ==========' AS '验证';

-- 验证1：检查分类多样性
SELECT 
    '推荐分类多样性验证' AS '验证项',
    COUNT(DISTINCT category_name) AS '推荐分类数',
    CASE 
        WHEN COUNT(DISTINCT category_name) >= 3 THEN '✓ 多样性优秀(≥3类)'
        WHEN COUNT(DISTINCT category_name) >= 2 THEN '○ 多样性良好(≥2类)'
        ELSE '△ 多样性不足(<2类)'
    END AS '评价'
FROM temp_recommendations;

SELECT '✓ 多样性优化创建成功！' AS '提示',
       '使用 CALL generate_diverse_recommendation(user_id, meal_type, count) 生成多样化推荐' AS '使用方法';

