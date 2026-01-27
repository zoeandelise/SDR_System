-- 创建带随机性的多样化推荐存储过程
USE smart_diet_dev;

DROP PROCEDURE IF EXISTS generate_diverse_recommendation_simple;

DELIMITER $$

CREATE PROCEDURE generate_diverse_recommendation_simple(
    IN p_user_id BIGINT,
    IN p_meal_type VARCHAR(10),
    IN p_recommendation_count INT
)
BEGIN
    DECLARE v_target_calories INT;
    DECLARE v_target_protein DECIMAL(6,2);
    DECLARE v_target_carb DECIMAL(6,2);
    DECLARE v_target_fat DECIMAL(6,2);
    
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
    
    -- 查询并评分，添加随机因子
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        n.calories AS calories_per_100g,
        n.protein AS protein_per_100g,
        n.carbohydrate AS carb_per_100g,
        n.fat AS fat_per_100g,
        
        -- 基础营养匹配度
        ROUND(
            GREATEST(0, 100 - ABS(n.calories - v_target_calories) / v_target_calories * 100) * 0.40 +
            GREATEST(0, 100 - ABS(n.protein - v_target_protein) / v_target_protein * 150) * 0.25 +
            GREATEST(0, 100 - ABS(n.carbohydrate - v_target_carb) / v_target_carb * 150) * 0.20 +
            GREATEST(0, 100 - ABS(n.fat - v_target_fat) / v_target_fat * 150) * 0.15,
            2
        ) AS nutrition_score,
        
        -- 综合评分 = 营养匹配70% + 随机因子30%（让每次结果不同）
        ROUND(
            (GREATEST(0, 100 - ABS(n.calories - v_target_calories) / v_target_calories * 100) * 0.40 +
             GREATEST(0, 100 - ABS(n.protein - v_target_protein) / v_target_protein * 150) * 0.25 +
             GREATEST(0, 100 - ABS(n.carbohydrate - v_target_carb) / v_target_carb * 150) * 0.20 +
             GREATEST(0, 100 - ABS(n.fat - v_target_fat) / v_target_fat * 150) * 0.15) * 0.70 +
            FLOOR(RAND() * 40) * 0.30,  -- 随机因子0-40分，权重30%
            2
        ) AS final_score,
        
        ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100) AS recommended_portion,
        
        CONCAT(
            '推荐食用量: ', ROUND((v_target_calories / NULLIF(n.calories, 0)) * 100), 'g; ',
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

SELECT '✓ 多样化推荐存储过程已创建（含随机因子）' AS status;

-- 测试3次，应该看到不同结果
SELECT '测试1:' AS test;
CALL generate_diverse_recommendation_simple(1, '1', 5);

SELECT '测试2:' AS test;
CALL generate_diverse_recommendation_simple(1, '1', 5);

SELECT '测试3:' AS test;
CALL generate_diverse_recommendation_simple(1, '1', 5);
