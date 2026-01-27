-- ================================
-- 健康饮食推荐算法 V1.0
-- 基于现有数据：用户健康指标 + 基础营养素
-- ================================
-- 功能：为指定用户生成个性化饮食推荐
-- 输入：用户ID、餐次类型
-- 输出：推荐食物列表（含营养匹配度评分）
-- ================================

USE smart_diet_dev;

-- ================================
-- 核心函数1：计算用户营养需求
-- ================================
-- 功能：基于用户健康数据计算单餐营养目标

DROP FUNCTION IF EXISTS calculate_meal_nutrition_target;

DELIMITER $$

CREATE FUNCTION calculate_meal_nutrition_target(
    p_user_id BIGINT,
    p_meal_type VARCHAR(10)  -- '0'=早餐, '1'=午餐, '2'=晚餐, '3'=加餐
)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_daily_calorie INT;
    DECLARE v_daily_protein DECIMAL(6,2);
    DECLARE v_daily_carb DECIMAL(6,2);
    DECLARE v_daily_fat DECIMAL(6,2);
    DECLARE v_meal_ratio DECIMAL(4,2);
    DECLARE result JSON;
    
    -- 获取用户每日营养目标
    SELECT 
        COALESCE(daily_calorie_goal, 2000),
        COALESCE(daily_protein_goal, 60),
        COALESCE(daily_carb_goal, 250),
        COALESCE(daily_fat_goal, 60)
    INTO v_daily_calorie, v_daily_protein, v_daily_carb, v_daily_fat
    FROM sys_user_health
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- 根据餐次分配营养比例
    -- 早餐30%，午餐40%，晚餐30%，加餐10%
    SET v_meal_ratio = CASE 
        WHEN p_meal_type = '0' THEN 0.30
        WHEN p_meal_type = '1' THEN 0.40
        WHEN p_meal_type = '2' THEN 0.30
        WHEN p_meal_type = '3' THEN 0.10
        ELSE 0.33
    END;
    
    -- 构建JSON结果
    SET result = JSON_OBJECT(
        'target_calories', ROUND(v_daily_calorie * v_meal_ratio),
        'target_protein', ROUND(v_daily_protein * v_meal_ratio, 2),
        'target_carb', ROUND(v_daily_carb * v_meal_ratio, 2),
        'target_fat', ROUND(v_daily_fat * v_meal_ratio, 2),
        'meal_ratio', v_meal_ratio
    );
    
    RETURN result;
END$$

DELIMITER ;

-- ================================
-- 核心函数2：计算食物营养匹配度
-- ================================
-- 功能：计算单个食物与目标营养的匹配评分（0-100分）

DROP FUNCTION IF EXISTS calculate_nutrition_match_score;

DELIMITER $$

CREATE FUNCTION calculate_nutrition_match_score(
    p_food_calories DECIMAL(8,2),
    p_food_protein DECIMAL(8,2),
    p_food_carb DECIMAL(8,2),
    p_food_fat DECIMAL(8,2),
    p_target_calories INT,
    p_target_protein DECIMAL(6,2),
    p_target_carb DECIMAL(6,2),
    p_target_fat DECIMAL(6,2)
)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_calorie_score DECIMAL(5,2);
    DECLARE v_protein_score DECIMAL(5,2);
    DECLARE v_carb_score DECIMAL(5,2);
    DECLARE v_fat_score DECIMAL(5,2);
    DECLARE v_total_score DECIMAL(5,2);
    
    -- 计算热量匹配度（权重40%）
    -- 在目标±20%范围内得满分，超出范围线性扣分
    SET v_calorie_score = CASE 
        WHEN p_food_calories BETWEEN p_target_calories * 0.8 AND p_target_calories * 1.2 THEN 100
        WHEN p_food_calories < p_target_calories * 0.8 THEN 
            GREATEST(0, 100 - (p_target_calories * 0.8 - p_food_calories) / p_target_calories * 100)
        ELSE 
            GREATEST(0, 100 - (p_food_calories - p_target_calories * 1.2) / p_target_calories * 100)
    END;
    
    -- 计算蛋白质匹配度（权重25%）
    SET v_protein_score = CASE 
        WHEN p_food_protein BETWEEN p_target_protein * 0.7 AND p_target_protein * 1.3 THEN 100
        WHEN p_food_protein < p_target_protein * 0.7 THEN 
            GREATEST(0, 100 - (p_target_protein * 0.7 - p_food_protein) / p_target_protein * 200)
        ELSE 
            GREATEST(0, 100 - (p_food_protein - p_target_protein * 1.3) / p_target_protein * 200)
    END;
    
    -- 计算碳水匹配度（权重20%）
    SET v_carb_score = CASE 
        WHEN p_food_carb BETWEEN p_target_carb * 0.7 AND p_target_carb * 1.3 THEN 100
        WHEN p_food_carb < p_target_carb * 0.7 THEN 
            GREATEST(0, 100 - (p_target_carb * 0.7 - p_food_carb) / p_target_carb * 150)
        ELSE 
            GREATEST(0, 100 - (p_food_carb - p_target_carb * 1.3) / p_target_carb * 150)
    END;
    
    -- 计算脂肪匹配度（权重15%）
    SET v_fat_score = CASE 
        WHEN p_food_fat BETWEEN p_target_fat * 0.7 AND p_target_fat * 1.3 THEN 100
        WHEN p_food_fat < p_target_fat * 0.7 THEN 
            GREATEST(0, 100 - (p_target_fat * 0.7 - p_food_fat) / p_target_fat * 150)
        ELSE 
            GREATEST(0, 100 - (p_food_fat - p_target_fat * 1.3) / p_target_fat * 150)
    END;
    
    -- 加权计算总分
    SET v_total_score = (
        v_calorie_score * 0.40 +
        v_protein_score * 0.25 +
        v_carb_score * 0.20 +
        v_fat_score * 0.15
    );
    
    RETURN ROUND(v_total_score, 2);
END$$

DELIMITER ;

-- ================================
-- 核心函数3：生成个性化推荐
-- ================================
-- 功能：为用户生成完整的推荐列表（存储过程）

DROP PROCEDURE IF EXISTS generate_personalized_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_personalized_recommendation(
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
    DECLARE v_user_preferences VARCHAR(500);
    DECLARE v_user_dislikes VARCHAR(1000);
    
    -- 步骤1：获取用户营养目标
    SET v_nutrition_target = calculate_meal_nutrition_target(p_user_id, p_meal_type);
    SET v_target_calories = JSON_EXTRACT(v_nutrition_target, '$.target_calories');
    SET v_target_protein = JSON_EXTRACT(v_nutrition_target, '$.target_protein');
    SET v_target_carb = JSON_EXTRACT(v_nutrition_target, '$.target_carb');
    SET v_target_fat = JSON_EXTRACT(v_nutrition_target, '$.target_fat');
    
    -- 步骤2：获取用户偏好和禁忌
    SELECT 
        COALESCE(diet_preferences, '[]'),
        COALESCE(food_dislikes, '[]')
    INTO v_user_preferences, v_user_dislikes
    FROM sys_user_health
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- 步骤3：查询并评分所有候选食物
    -- 排除用户不喜欢的食材
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        n.calories AS calories_per_100g,
        n.protein AS protein_per_100g,
        n.carbohydrate AS carb_per_100g,
        n.fat AS fat_per_100g,
        
        -- 计算营养匹配度
        calculate_nutrition_match_score(
            n.calories, n.protein, n.carbohydrate, n.fat,
            v_target_calories, v_target_protein, v_target_carb, v_target_fat
        ) AS nutrition_score,
        
        -- 计算历史反馈加权分（基于该食物的历史推荐评分）
        COALESCE((
            SELECT AVG(score) 
            FROM diet_recommendation dr
            WHERE dr.recommended_foods LIKE CONCAT('%', f.food_name, '%')
              AND dr.is_accepted = '1'
        ), 0) AS history_score,
        
        -- 综合评分 = 营养匹配度(70%) + 历史反馈(30%)
        (
            calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            ) * 0.70 +
            COALESCE((
                SELECT AVG(score) * 20  -- 归一化到0-100
                FROM diet_recommendation dr
                WHERE dr.recommended_foods LIKE CONCAT('%', f.food_name, '%')
                  AND dr.is_accepted = '1'
            ), 50) * 0.30
        ) AS final_score,
        
        -- 推荐建议份量(g)
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        
        -- 推荐理由
        CONCAT(
            '营养匹配度: ', 
            ROUND(calculate_nutrition_match_score(
                n.calories, n.protein, n.carbohydrate, n.fat,
                v_target_calories, v_target_protein, v_target_carb, v_target_fat
            )), 
            '分; ',
            '提供热量约 ', ROUND(n.calories * (v_target_calories / NULLIF(n.calories, 0))), ' kcal; ',
            '蛋白质 ', ROUND(n.protein * (v_target_calories / NULLIF(n.calories, 0))), 'g'
        ) AS recommendation_reason
        
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'  -- 只推荐正常状态的食物
      AND n.calories IS NOT NULL
      AND n.calories > 0
      -- 过滤用户不喜欢的食材（如果food_dislikes不为空）
      AND (
          v_user_dislikes = '[]' 
          OR f.food_name NOT IN (
              SELECT JSON_UNQUOTE(JSON_EXTRACT(v_user_dislikes, CONCAT('$[', idx, ']')))
              FROM (
                  SELECT 0 AS idx UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
              ) AS indices
              WHERE JSON_EXTRACT(v_user_dislikes, CONCAT('$[', idx, ']')) IS NOT NULL
          )
      )
    ORDER BY final_score DESC
    LIMIT p_recommendation_count;
    
END$$

DELIMITER ;

-- ================================
-- 验证和测试
-- ================================

-- 测试1：查看用户101的营养目标
SELECT 
    user_id,
    calculate_meal_nutrition_target(101, '1') AS lunch_target
FROM sys_user_health
WHERE user_id = 101
LIMIT 1;

-- 测试2：计算特定食物的匹配度
SELECT 
    calculate_nutrition_match_score(
        500,  -- 食物热量
        25,   -- 食物蛋白质
        60,   -- 食物碳水
        15,   -- 食物脂肪
        600,  -- 目标热量
        30,   -- 目标蛋白质
        70,   -- 目标碳水
        20    -- 目标脂肪
    ) AS match_score;

-- 测试3：为用户101生成午餐推荐（前10个）
CALL generate_personalized_recommendation(101, '1', 10);

-- ================================
-- 算法说明
-- ================================

/*
算法流程：
1. 输入：用户ID(101) + 餐次类型('1'=午餐)
2. 查询：sys_user_health表获取用户BMR、营养目标
3. 计算：单餐营养目标（午餐=每日40%）
4. 匹配：遍历diet_food_info和diet_food_nutrition，计算匹配度
5. 过滤：排除food_dislikes中的食材
6. 评分：营养匹配度(70%) + 历史反馈(30%)
7. 排序：按综合评分降序
8. 输出：前N个推荐食物

评分逻辑：
- 热量匹配：在目标±20%范围内得满分(权重40%)
- 蛋白质匹配：在目标±30%范围内得满分(权重25%)
- 碳水匹配：在目标±30%范围内得满分(权重20%)
- 脂肪匹配：在目标±30%范围内得满分(权重15%)
- 历史反馈：基于该食物历史推荐的平均评分(权重30%)

数据表使用：
- sys_user_health: 用户健康数据、营养目标、偏好
- diet_food_info: 食物基础信息
- diet_food_nutrition: 食物营养数据
- diet_food_category: 食物分类
- diet_recommendation: 历史推荐记录（用于反馈优化）

与未来数据衔接点：
1. GI值：可在函数中增加糖尿病用户的GI值过滤
2. 钠含量：可在函数中增加高血压用户的低钠过滤
3. 嘌呤：可在函数中增加痛风用户的低嘌呤过滤
4. 适用/不适用人群标签：直接用于过滤条件
*/

SELECT '✓ 推荐算法V1.0创建成功！' AS '提示',
       '使用 CALL generate_personalized_recommendation(user_id, meal_type, count) 生成推荐' AS '使用方法';

