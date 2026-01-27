-- ===================================================================
-- 个性化健康推荐算法（基于用户健康信息的差异化推荐）
-- ===================================================================

DROP PROCEDURE IF EXISTS generate_personalized_health_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_personalized_health_recommendation(
    IN p_user_id BIGINT,
    IN p_meal_type CHAR(1),
    IN p_count INT
)
BEGIN
    DECLARE v_gender CHAR(1);
    DECLARE v_age INT;
    DECLARE v_height DECIMAL(5,2);
    DECLARE v_weight DECIMAL(5,2);
    DECLARE v_target_weight DECIMAL(5,2);
    DECLARE v_health_goal CHAR(1);
    DECLARE v_diseases VARCHAR(500);
    DECLARE v_allergies VARCHAR(500);
    DECLARE v_diet_preferences VARCHAR(500);
    DECLARE v_bmr DECIMAL(10,2);
    DECLARE v_target_calories INT;
    DECLARE v_target_protein DECIMAL(6,2);
    
    -- 获取用户健康信息
    SELECT gender, age, height, weight, target_weight, health_goal, 
           diseases, allergies, diet_preferences, bmr
    INTO v_gender, v_age, v_height, v_weight, v_target_weight, v_health_goal,
         v_diseases, v_allergies, v_diet_preferences, v_bmr
    FROM sys_user_health
    WHERE user_id = p_user_id
    LIMIT 1;
    
    -- 根据健康目标计算目标热量和蛋白质
    SET v_target_calories = CASE p_meal_type
        WHEN '0' THEN CAST(v_bmr * 0.30 AS UNSIGNED)  -- 早餐30%
        WHEN '1' THEN CAST(v_bmr * 0.40 AS UNSIGNED)  -- 午餐40%
        WHEN '2' THEN CAST(v_bmr * 0.30 AS UNSIGNED)  -- 晚餐30%
        ELSE CAST(v_bmr * 0.15 AS UNSIGNED)           -- 加餐15%
    END;
    
    -- 健康目标调整（减脂/增肌/保持）
    SET v_target_calories = CASE v_health_goal
        WHEN '0' THEN CAST(v_target_calories * 0.85 AS UNSIGNED)  -- 减脂：减少15%热量
        WHEN '1' THEN CAST(v_target_calories * 1.15 AS UNSIGNED)  -- 增肌：增加15%热量
        ELSE v_target_calories                                     -- 保持：不变
    END;
    
    SET v_target_protein = CASE v_health_goal
        WHEN '0' THEN v_weight * 1.2    -- 减脂：1.2g/kg
        WHEN '1' THEN v_weight * 2.0    -- 增肌：2.0g/kg
        ELSE v_weight * 1.0             -- 保持：1.0g/kg
    END;
    
    -- 创建临时表存储推荐结果
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
    CREATE TEMPORARY TABLE temp_recommendations (
        food_id INT,
        food_name VARCHAR(100),
        category_name VARCHAR(50),
        calories_per_100g DECIMAL(8,2),
        protein_per_100g DECIMAL(6,2),
        carb_per_100g DECIMAL(6,2),
        fat_per_100g DECIMAL(6,2),
        sodium_per_100g DECIMAL(8,2),
        gi_value INT,
        purine_per_100g DECIMAL(8,2),
        health_score DECIMAL(10,2),
        recommendation_reason TEXT
    );
    
    -- 插入符合条件的食物
    INSERT INTO temp_recommendations
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        n.calories AS calories_per_100g,
        n.protein AS protein_per_100g,
        n.carbohydrate AS carb_per_100g,
        n.fat AS fat_per_100g,
        n.sodium_per_100g,
        n.gi_value,
        n.purine_per_100g,
        100.0 AS health_score,  -- 初始分数100
        '' AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    INNER JOIN diet_food_category c ON f.category_id = c.category_id
    WHERE f.status = '0';  -- 正常状态
    
    -- ===== 健康约束规则引擎 =====
    
    -- 规则1：高血压约束（控制钠<200mg，优先高钾食物）
    IF v_diseases LIKE '%高血压%' THEN
        UPDATE temp_recommendations
        SET health_score = health_score - 50,
            recommendation_reason = CONCAT(recommendation_reason, '⚠️高钠不适合高血压;')
        WHERE sodium_per_100g > 200;
        
        UPDATE temp_recommendations
        SET health_score = health_score + 20,
            recommendation_reason = CONCAT(recommendation_reason, '✓低钠适合高血压;')
        WHERE sodium_per_100g <= 100;
    END IF;
    
    -- 规则2：糖尿病约束（控制GI值<55，增加膳食纤维）
    IF v_diseases LIKE '%糖尿病%' THEN
        UPDATE temp_recommendations
        SET health_score = health_score - 40,
            recommendation_reason = CONCAT(recommendation_reason, '⚠️高GI不适合糖尿病;')
        WHERE gi_value > 70;
        
        UPDATE temp_recommendations
        SET health_score = health_score + 25,
            recommendation_reason = CONCAT(recommendation_reason, '✓低GI适合糖尿病;')
        WHERE gi_value <= 55;
        
        UPDATE temp_recommendations
        SET health_score = health_score - 30,
            recommendation_reason = CONCAT(recommendation_reason, '⚠️高碳水需谨慎;')
        WHERE carb_per_100g > 60;
    END IF;
    
    -- 规则3：痛风约束（严格控制嘌呤<100mg）
    IF v_diseases LIKE '%痛风%' THEN
        DELETE FROM temp_recommendations WHERE purine_per_100g > 100;
        
        UPDATE temp_recommendations
        SET health_score = health_score + 30,
            recommendation_reason = CONCAT(recommendation_reason, '✓低嘌呤安全食用;')
        WHERE purine_per_100g <= 50;
    END IF;
    
    -- 规则4：过敏源排除（黑名单机制）
    IF v_allergies IS NOT NULL AND v_allergies != '' THEN
        IF v_allergies LIKE '%海鲜%' THEN
            DELETE FROM temp_recommendations WHERE category_name = '水产类';
        END IF;
        IF v_allergies LIKE '%坚果%' THEN
            DELETE FROM temp_recommendations WHERE category_name LIKE '%坚果%';
        END IF;
        IF v_allergies LIKE '%乳制品%' OR v_allergies LIKE '%牛奶%' THEN
            DELETE FROM temp_recommendations WHERE category_name = '蛋奶类';
        END IF;
        IF v_allergies LIKE '%大豆%' THEN
            DELETE FROM temp_recommendations WHERE food_name LIKE '%豆%';
        END IF;
    END IF;
    
    -- 规则5：饮食偏好调整
    IF v_diet_preferences LIKE '%清淡%' OR v_diet_preferences LIKE '%低油低盐%' THEN
        UPDATE temp_recommendations
        SET health_score = health_score + 15,
            recommendation_reason = CONCAT(recommendation_reason, '✓清淡健康;')
        WHERE sodium_per_100g < 100 AND fat_per_100g < 10;
    END IF;
    
    IF v_diet_preferences LIKE '%素食%' THEN
        DELETE FROM temp_recommendations WHERE category_name IN ('肉类', '水产类');
        
        UPDATE temp_recommendations
        SET health_score = health_score + 20,
            recommendation_reason = CONCAT(recommendation_reason, '✓植物性食物;')
        WHERE category_name IN ('蔬菜类', '豆类坚果', '谷物类');
    END IF;
    
    -- 规则6：健康目标优化
    IF v_health_goal = '0' THEN  -- 减脂
        UPDATE temp_recommendations
        SET health_score = health_score + 30,
            recommendation_reason = CONCAT(recommendation_reason, '✓低热量助减脂;')
        WHERE calories_per_100g < 150;
        
        UPDATE temp_recommendations
        SET health_score = health_score - 20,
            recommendation_reason = CONCAT(recommendation_reason, '⚠️高热量不利减脂;')
        WHERE calories_per_100g > 400;
        
        UPDATE temp_recommendations
        SET health_score = health_score + 15,
            recommendation_reason = CONCAT(recommendation_reason, '✓高蛋白增强饱腹感;')
        WHERE protein_per_100g > 15;
        
    ELSEIF v_health_goal = '1' THEN  -- 增肌
        UPDATE temp_recommendations
        SET health_score = health_score + 40,
            recommendation_reason = CONCAT(recommendation_reason, '✓高蛋白促进肌肉生长;')
        WHERE protein_per_100g > 20;
        
        UPDATE temp_recommendations
        SET health_score = health_score - 15,
            recommendation_reason = CONCAT(recommendation_reason, '⚠️低蛋白不利增肌;')
        WHERE protein_per_100g < 10;
        
    ELSE  -- 保持
        UPDATE temp_recommendations
        SET health_score = health_score + 10,
            recommendation_reason = CONCAT(recommendation_reason, '✓营养均衡;')
        WHERE calories_per_100g BETWEEN 100 AND 300;
    END IF;
    
    -- 计算推荐份量（基于目标热量）
    UPDATE temp_recommendations
    SET health_score = health_score * (1 + RAND() * 0.3);  -- 添加随机因子增加多样性
    
    -- 返回Top N推荐
    SELECT 
        food_id,
        food_name,
        category_name,
        calories_per_100g,
        protein_per_100g,
        carb_per_100g,
        fat_per_100g,
        ROUND(health_score, 2) AS final_score,
        ROUND(v_target_calories / calories_per_100g * 100) AS recommended_portion,
        CONCAT(
            recommendation_reason,
            '推荐份量约', ROUND(v_target_calories / calories_per_100g * 100), 'g; ',
            '提供热量', ROUND(v_target_calories), 'kcal; ',
            '蛋白质', ROUND(protein_per_100g * v_target_calories / calories_per_100g), 'g'
        ) AS recommendation_reason
    FROM temp_recommendations
    WHERE health_score > 0
    ORDER BY health_score DESC, RAND()
    LIMIT p_count;
    
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
    
END$$

DELIMITER ;

