-- ===================================================================
-- 个性化健康推荐算法 V2（基于中国饮食习惯的组合推荐）
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
    
    -- 根据健康目标计算目标热量
    SET v_target_calories = CASE p_meal_type
        WHEN '0' THEN CAST(v_bmr * 0.30 AS UNSIGNED)  -- 早餐30%
        WHEN '1' THEN CAST(v_bmr * 0.40 AS UNSIGNED)  -- 午餐40%
        WHEN '2' THEN CAST(v_bmr * 0.30 AS UNSIGNED)  -- 晚餐30%
        ELSE CAST(v_bmr * 0.10 AS UNSIGNED)           -- 加餐10%
    END;
    
    -- 健康目标调整
    SET v_target_calories = CASE v_health_goal
        WHEN '0' THEN CAST(v_target_calories * 0.85 AS UNSIGNED)  -- 减脂
        WHEN '1' THEN CAST(v_target_calories * 1.15 AS UNSIGNED)  -- 增肌
        ELSE v_target_calories
    END;
    
    -- 创建临时表存储所有候选食物
    DROP TEMPORARY TABLE IF EXISTS temp_candidates;
    CREATE TEMPORARY TABLE temp_candidates (
        food_id INT,
        food_name VARCHAR(100),
        category_name VARCHAR(50),
        parent_category_name VARCHAR(50),
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
    
    -- 插入候选食物（关联父分类以便筛选）
    INSERT INTO temp_candidates
    SELECT 
        f.food_id,
        f.food_name,
        c.category_name,
        pc.category_name as parent_category_name,
        n.calories,
        n.protein,
        n.carbohydrate,
        n.fat,
        n.sodium_per_100g,
        n.gi_value,
        n.purine_per_100g,
        100.0 AS health_score,
        '' AS recommendation_reason
    FROM diet_food_info f
    INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
    INNER JOIN diet_food_category c ON f.category_id = c.category_id
    LEFT JOIN diet_food_category pc ON c.parent_id = pc.category_id
    WHERE f.status = '0';
    
    -- ===== 健康规则引擎 (复用原有逻辑) =====
    
    -- 规则1：高血压
    IF v_diseases LIKE '%高血压%' THEN
        UPDATE temp_candidates SET health_score = health_score - 50, recommendation_reason = CONCAT(recommendation_reason, '⚠️高钠;') WHERE sodium_per_100g > 200;
        UPDATE temp_candidates SET health_score = health_score + 20, recommendation_reason = CONCAT(recommendation_reason, '✓低钠;') WHERE sodium_per_100g <= 100;
    END IF;
    
    -- 规则2：糖尿病
    IF v_diseases LIKE '%糖尿病%' THEN
        UPDATE temp_candidates SET health_score = health_score - 40, recommendation_reason = CONCAT(recommendation_reason, '⚠️高GI;') WHERE gi_value > 70;
        UPDATE temp_candidates SET health_score = health_score + 25, recommendation_reason = CONCAT(recommendation_reason, '✓低GI;') WHERE gi_value <= 55;
    END IF;
    
    -- 规则3：痛风
    IF v_diseases LIKE '%痛风%' THEN
        DELETE FROM temp_candidates WHERE purine_per_100g > 100;
    END IF;
    
    -- 规则4：过敏
    IF v_allergies IS NOT NULL AND v_allergies != '' THEN
        IF v_allergies LIKE '%海鲜%' THEN DELETE FROM temp_candidates WHERE parent_category_name = '水产海鲜' OR category_name = '水产海鲜'; END IF;
        IF v_allergies LIKE '%坚果%' THEN DELETE FROM temp_candidates WHERE parent_category_name = '坚果类' OR category_name = '坚果类'; END IF;
        IF v_allergies LIKE '%乳制品%' THEN DELETE FROM temp_candidates WHERE parent_category_name = '奶制品' OR category_name = '奶制品'; END IF;
    END IF;
    
    -- 规则5：偏好
    IF v_diet_preferences LIKE '%素食%' THEN
        DELETE FROM temp_candidates WHERE parent_category_name IN ('肉禽蛋类', '水产海鲜');
    END IF;
    
    -- 添加随机因子
    UPDATE temp_candidates SET health_score = health_score * (1 + RAND() * 0.2);
    
    -- ===== 组合推荐逻辑 =====
    
    -- 创建最终结果表
    DROP TEMPORARY TABLE IF EXISTS temp_final_result;
    CREATE TEMPORARY TABLE temp_final_result (
        food_id INT,
        food_name VARCHAR(100),
        category_name VARCHAR(50),
        calories_per_100g DECIMAL(8,2),
        protein_per_100g DECIMAL(6,2),
        carb_per_100g DECIMAL(6,2),
        fat_per_100g DECIMAL(6,2),
        final_score DECIMAL(10,2),
        recommended_portion INT,
        recommendation_reason TEXT,
        role VARCHAR(20) -- 角色：主食/主菜/副菜
    );
    
    -- 1. 选主食 (Carb) - 约40%热量
    INSERT INTO temp_final_result
    SELECT 
        food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
        ROUND((v_target_calories * 0.4) / calories_per_100g * 100),
        CONCAT(recommendation_reason, '主食推荐;'),
        '主食'
    FROM temp_candidates
    WHERE (parent_category_name = '谷物类' OR category_name = '谷物类' OR category_name LIKE '%薯%')
    ORDER BY health_score DESC LIMIT 1;
    
    -- 移除已选
    DELETE FROM temp_candidates WHERE food_id IN (SELECT food_id FROM temp_final_result);
    
    -- 2. 选主菜 (Protein) - 约30%热量
    INSERT INTO temp_final_result
    SELECT 
        food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
        ROUND((v_target_calories * 0.3) / calories_per_100g * 100),
        CONCAT(recommendation_reason, '优质蛋白;'),
        '主菜'
    FROM temp_candidates
    WHERE (parent_category_name IN ('肉类', '海鲜类', '蛋奶类', '豆类坚果') OR category_name IN ('肉类', '海鲜类', '蛋奶类', '豆类坚果'))
    ORDER BY health_score DESC LIMIT 1;

    -- 移除已选
    DELETE FROM temp_candidates WHERE food_id IN (SELECT food_id FROM temp_final_result);

    -- 3. 选汤 (Soup) - 约10%热量
    INSERT INTO temp_final_result
    SELECT 
        food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
        ROUND((v_target_calories * 0.1) / calories_per_100g * 100),
        CONCAT(recommendation_reason, '佐餐汤品;'),
        '汤'
    FROM temp_candidates
    WHERE (food_name LIKE '%汤%' OR category_name LIKE '%汤%')
    ORDER BY health_score DESC LIMIT 1;
    
    -- 移除已选
    DELETE FROM temp_candidates WHERE food_id IN (SELECT food_id FROM temp_final_result);
    
    -- 4. 选副菜 (Veggie) - 约20%热量
    -- 如果有汤，选1个副菜；如果没有汤，选2个副菜
    IF (SELECT COUNT(*) FROM temp_final_result WHERE role = '汤') > 0 THEN
        INSERT INTO temp_final_result
        SELECT 
            food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
            ROUND((v_target_calories * 0.2) / calories_per_100g * 100),
            CONCAT(recommendation_reason, '维生素补充;'),
            '副菜'
        FROM temp_candidates
        WHERE (parent_category_name IN ('蔬菜类', '水果类') OR category_name IN ('蔬菜类', '水果类'))
        ORDER BY health_score DESC LIMIT 1;
    ELSE
        INSERT INTO temp_final_result
        SELECT 
            food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
            ROUND((v_target_calories * 0.2) / calories_per_100g * 100),
            CONCAT(recommendation_reason, '维生素补充;'),
            '副菜'
        FROM temp_candidates
        WHERE (parent_category_name IN ('蔬菜类', '水果类') OR category_name IN ('蔬菜类', '水果类'))
        ORDER BY health_score DESC LIMIT 2;
    END IF;
    
    -- 移除已选
    DELETE FROM temp_candidates WHERE food_id IN (SELECT food_id FROM temp_final_result);
    
    -- 如果没有选够（比如数据不足），补充任意高分食物
    IF (SELECT COUNT(*) FROM temp_final_result) < 3 THEN
        INSERT INTO temp_final_result
        SELECT 
            food_id, food_name, category_name, calories_per_100g, protein_per_100g, carb_per_100g, fat_per_100g, health_score,
            ROUND((v_target_calories * 0.3) / calories_per_100g * 100),
            CONCAT(recommendation_reason, '补充推荐;'),
            '补充'
        FROM temp_candidates
        ORDER BY health_score DESC LIMIT 2;
    END IF;
    
    -- 返回结果
    SELECT 
        food_id,
        food_name,
        category_name,
        calories_per_100g,
        protein_per_100g,
        carb_per_100g,
        fat_per_100g,
        final_score,
        recommended_portion,
        CONCAT(
            recommendation_reason,
            '推荐份量约', recommended_portion, 'g; ',
            '提供热量', ROUND(calories_per_100g * recommended_portion / 100), 'kcal'
        ) AS recommendation_reason,
        role
    FROM temp_final_result;
    
    DROP TEMPORARY TABLE IF EXISTS temp_candidates;
    DROP TEMPORARY TABLE IF EXISTS temp_final_result;
    
END$$

DELIMITER ;
