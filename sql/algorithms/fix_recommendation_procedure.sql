-- 修复推荐存储过程的JSON转换问题
USE smart_diet_dev;

DROP PROCEDURE IF EXISTS generate_personalized_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_personalized_recommendation(
    IN p_user_id BIGINT,
    IN p_meal_type VARCHAR(10),
    IN p_recommendation_count INT
)
BEGIN
    DECLARE v_target_calories INT;
    DECLARE v_target_protein DECIMAL(6,2);
    DECLARE v_target_carb DECIMAL(6,2);
    DECLARE v_target_fat DECIMAL(6,2);
    
    -- 直接计算营养目标，不使用JSON函数
    -- 获取用户每日营养目标
    SELECT 
        COALESCE(daily_calorie_goal, 2000),
        COALESCE(daily_protein_goal, 60),
        COALESCE(daily_carb_goal, 250),
        COALESCE(daily_fat_goal, 60)
    INTO v_target_calories, v_target_protein, v_target_carb, v_target_fat
    FROM sys_user_health
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- 根据餐次分配比例
    SET v_target_calories = ROUND(v_target_calories * CASE 
        WHEN p_meal_type = '0' THEN 0.30
        WHEN p_meal_type = '1' THEN 0.40
        WHEN p_meal_type = '2' THEN 0.30
        WHEN p_meal_type = '3' THEN 0.10
        ELSE 0.33
    END);
    
    SET v_target_protein = ROUND(v_target_protein * CASE 
        WHEN p_meal_type = '0' THEN 0.30
        WHEN p_meal_type = '1' THEN 0.40
        WHEN p_meal_type = '2' THEN 0.30
        WHEN p_meal_type = '3' THEN 0.10
        ELSE 0.33
    END, 2);
    
    SET v_target_carb = ROUND(v_target_carb * CASE 
        WHEN p_meal_type = '0' THEN 0.30
        WHEN p_meal_type = '1' THEN 0.40
        WHEN p_meal_type = '2' THEN 0.30
        WHEN p_meal_type = '3' THEN 0.10
        ELSE 0.33
    END, 2);
    
    SET v_target_fat = ROUND(v_target_fat * CASE 
        WHEN p_meal_type = '0' THEN 0.30
        WHEN p_meal_type = '1' THEN 0.40
        WHEN p_meal_type = '2' THEN 0.30
        WHEN p_meal_type = '3' THEN 0.10
        ELSE 0.33
    END, 2);
    
    -- 查询并评分所有候选食物
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        n.calories AS calories_per_100g,
        n.protein AS protein_per_100g,
        n.carbohydrate AS carb_per_100g,
        n.fat AS fat_per_100g,
        
        -- 计算营养匹配度（简化版，避免函数调用）
        ROUND(
            -- 热量匹配（40%权重）
            GREATEST(0, 100 - ABS(n.calories - v_target_calories) / v_target_calories * 100) * 0.40 +
            -- 蛋白质匹配（25%权重）
            GREATEST(0, 100 - ABS(n.protein - v_target_protein) / v_target_protein * 150) * 0.25 +
            -- 碳水匹配（20%权重）
            GREATEST(0, 100 - ABS(n.carbohydrate - v_target_carb) / v_target_carb * 150) * 0.20 +
            -- 脂肪匹配（15%权重）
            GREATEST(0, 100 - ABS(n.fat - v_target_fat) / v_target_fat * 150) * 0.15,
            2
        ) AS nutrition_score,
        
        -- 简化的综合评分
        ROUND(
            -- 营养匹配（70%）
            (GREATEST(0, 100 - ABS(n.calories - v_target_calories) / v_target_calories * 100) * 0.40 +
             GREATEST(0, 100 - ABS(n.protein - v_target_protein) / v_target_protein * 150) * 0.25 +
             GREATEST(0, 100 - ABS(n.carbohydrate - v_target_carb) / v_target_carb * 150) * 0.20 +
             GREATEST(0, 100 - ABS(n.fat - v_target_fat) / v_target_fat * 150) * 0.15) * 0.70 +
            -- 历史反馈（30%，默认50分）
            50 * 0.30,
            2
        ) AS final_score,
        
        -- 推荐建议份量(g)
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        
        -- 推荐理由
        CONCAT(
            '营养匹配度: ', 
            ROUND(
                GREATEST(0, 100 - ABS(n.calories - v_target_calories) / v_target_calories * 100) * 0.40 +
                GREATEST(0, 100 - ABS(n.protein - v_target_protein) / v_target_protein * 150) * 0.25 +
                GREATEST(0, 100 - ABS(n.carbohydrate - v_target_carb) / v_target_carb * 150) * 0.20 +
                GREATEST(0, 100 - ABS(n.fat - v_target_fat) / v_target_fat * 150) * 0.15
            ), 
            '分; ',
            '提供热量约 ', ROUND(n.calories * (v_target_calories / NULLIF(n.calories, 0))), ' kcal; ',
            '蛋白质 ', ROUND(n.protein * (v_target_calories / NULLIF(n.calories, 0))), 'g'
        ) AS recommendation_reason
        
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    LEFT JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0'
      AND n.calories IS NOT NULL
      AND n.calories > 0
    ORDER BY final_score DESC
    LIMIT p_recommendation_count;
    
END$$

DELIMITER ;

-- 测试
SELECT '✓ 存储过程已修复' AS status;
CALL generate_personalized_recommendation(1, '1', 5);

