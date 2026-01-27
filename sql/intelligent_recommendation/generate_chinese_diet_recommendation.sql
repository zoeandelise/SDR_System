-- ===================================================================
-- 中式饮食智能推荐算法 (Chinese Diet Recommendation)
-- ===================================================================

DROP PROCEDURE IF EXISTS generate_chinese_diet_recommendation;

DELIMITER $$

CREATE PROCEDURE generate_chinese_diet_recommendation(
    IN p_user_id BIGINT,
    IN p_meal_type CHAR(1), -- 0早餐 1午餐 2晚餐 3加餐
    IN p_count INT
)
BEGIN
    DECLARE v_target_calories INT;
    DECLARE v_bmr DECIMAL(10,2);
    DECLARE v_health_goal CHAR(1);
    DECLARE v_diseases VARCHAR(255);
    DECLARE v_allergies VARCHAR(255);
    DECLARE v_preferences VARCHAR(255);
    DECLARE i INT DEFAULT 0;
    DECLARE v_combo_id INT DEFAULT 0;
    
    -- 获取用户BMR和目标及健康信息
    SELECT bmr, health_goal, diseases, allergies, diet_preferences 
    INTO v_bmr, v_health_goal, v_diseases, v_allergies, v_preferences
    FROM sys_user_health WHERE user_id = p_user_id LIMIT 1;
    
    -- 计算餐次目标热量
    SET v_target_calories = CASE p_meal_type
        WHEN '0' THEN v_bmr * 1.2 * 0.30 -- 早餐 30%
        WHEN '1' THEN v_bmr * 1.2 * 0.40 -- 午餐 40%
        WHEN '2' THEN v_bmr * 1.2 * 0.30 -- 晚餐 30%
        ELSE v_bmr * 1.2 * 0.10          -- 加餐 10%
    END;
    
    -- 目标调整 (减脂/增肌)
    IF v_health_goal = '1' THEN SET v_target_calories = v_target_calories * 0.85; END IF; -- 减脂
    IF v_health_goal = '2' THEN SET v_target_calories = v_target_calories * 1.15; END IF; -- 增肌
    
    -- 创建结果表
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
    CREATE TEMPORARY TABLE temp_recommendations (
        combo_id INT,
        food_id BIGINT,
        food_name VARCHAR(100),
        category_name VARCHAR(50),
        role VARCHAR(20), -- 主食/蛋白/蔬菜/汤/加餐
        portion INT, -- 份量(g)
        calories DECIMAL(8,2),
        protein DECIMAL(8,2),
        fat DECIMAL(8,2),
        carbohydrate DECIMAL(8,2),
        reason VARCHAR(255)
    );
    
    -- 循环生成 p_count 个组合
    WHILE i < p_count DO
        SET v_combo_id = i + 1;
        
        IF p_meal_type = '0' THEN -- 早餐 (粥/面 + 蛋/奶 + 小菜)
            -- 1. 主食 (粥/包子/面)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '主食', 
                   FLOOR(150 + RAND() * 50), -- 150-200g
                   n.calories, n.protein, n.fat, n.carbohydrate, '暖胃主食'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 1 AND (f.food_name LIKE '%粥%' OR f.food_name LIKE '%包%' OR f.food_name LIKE '%面%')
            -- 糖尿病过滤 (少喝粥)
            AND (FIND_IN_SET('糖尿病', v_diseases) = 0 OR f.food_name NOT LIKE '%粥%')
            -- 小麦过敏过滤 (少吃面/包)
            AND (FIND_IN_SET('小麦', v_allergies) = 0 OR (f.food_name NOT LIKE '%面%' AND f.food_name NOT LIKE '%包%' AND f.food_name NOT LIKE '%馒头%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 2. 蛋白 (蛋/奶/豆浆)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '蛋白', 
                   FLOOR(50 + RAND() * 100), -- 50-150g (如1个蛋约50g, 一杯奶200g)
                   n.calories, n.protein, n.fat, n.carbohydrate, '优质蛋白'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE (f.food_name LIKE '%蛋%' OR f.food_name LIKE '%奶%' OR f.food_name LIKE '%豆浆%')
            -- 过敏过滤
            AND (FIND_IN_SET('牛奶', v_allergies) = 0 OR f.food_name NOT LIKE '%奶%')
            AND (FIND_IN_SET('鸡蛋', v_allergies) = 0 OR f.food_name NOT LIKE '%蛋%')
            -- 痛风过滤 (少喝豆浆)
            AND (FIND_IN_SET('痛风', v_diseases) = 0 OR f.food_name NOT LIKE '%豆浆%')
            -- 素食过滤 (奶蛋素可吃，纯素不吃蛋奶，这里假设是蛋奶素，或者只过滤肉)
            ORDER BY RAND() LIMIT 1;
            
            -- 3. 小菜 (蔬菜)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '小菜', 
                   FLOOR(50 + RAND() * 50), -- 50-100g
                   n.calories, n.protein, n.fat, n.carbohydrate, '清爽小菜'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 2
            -- 高血压/清淡过滤 (少吃咸菜)
            AND ((FIND_IN_SET('高血压', v_diseases) = 0 AND FIND_IN_SET('清淡', v_preferences) = 0) OR (f.food_name NOT LIKE '%咸%' AND f.food_name NOT LIKE '%腌%' AND f.food_name NOT LIKE '%榨菜%'))
            -- 辣过滤
            AND (FIND_IN_SET('清淡', v_preferences) = 0 OR f.food_name NOT LIKE '%辣%')
            ORDER BY RAND() LIMIT 1;
            
        ELSEIF p_meal_type = '1' THEN -- 午餐 (米/面 + 肉 + 菜 + 汤)
            -- 1. 主食 (米饭/面条)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '主食', 
                   FLOOR(150 + RAND() * 50), -- 150-200g
                   n.calories, n.protein, n.fat, n.carbohydrate, '饱腹主食'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 1 AND (f.food_name LIKE '%米%' OR f.food_name LIKE '%面%' OR f.food_name LIKE '%饼%')
            -- 糖尿病过滤 (少吃精米面，这里简单过滤，实际应推荐杂粮)
            -- 小麦过敏
            AND (FIND_IN_SET('小麦', v_allergies) = 0 OR (f.food_name NOT LIKE '%面%' AND f.food_name NOT LIKE '%饼%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 2. 肉菜 (Category 4/5)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '荤菜', 
                   FLOOR(100 + RAND() * 50), -- 100-150g
                   n.calories, n.protein, n.fat, n.carbohydrate, '解馋硬菜'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id IN (4, 5)
            -- 素食过滤
            AND (FIND_IN_SET('素食', v_preferences) = 0)
            -- 海鲜过敏
            AND (FIND_IN_SET('海鲜', v_allergies) = 0 OR (f.food_name NOT LIKE '%鱼%' AND f.food_name NOT LIKE '%虾%' AND f.food_name NOT LIKE '%蟹%'))
            -- 痛风过滤 (少吃海鲜/内脏)
            AND (FIND_IN_SET('痛风', v_diseases) = 0 OR (f.food_name NOT LIKE '%鱼%' AND f.food_name NOT LIKE '%虾%' AND f.food_name NOT LIKE '%肝%' AND f.food_name NOT LIKE '%肠%'))
            -- 清淡/高血压过滤 (少吃红烧/咸/辣)
            AND ((FIND_IN_SET('高血压', v_diseases) = 0 AND FIND_IN_SET('清淡', v_preferences) = 0) OR (f.food_name NOT LIKE '%红烧%' AND f.food_name NOT LIKE '%咸%' AND f.food_name NOT LIKE '%辣%' AND f.food_name NOT LIKE '%炸%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 3. 素菜 (Category 2)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '素菜', 
                   FLOOR(150 + RAND() * 50), -- 150-200g
                   n.calories, n.protein, n.fat, n.carbohydrate, '维生素补充'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 2
            -- 清淡/辣过滤
            AND (FIND_IN_SET('清淡', v_preferences) = 0 OR (f.food_name NOT LIKE '%辣%' AND f.food_name NOT LIKE '%炸%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 4. 汤 (Category 8)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '汤羹', 
                   200, -- 200ml
                   n.calories, n.protein, n.fat, n.carbohydrate, '滋润汤品'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE (c.category_id = 8 OR f.food_name LIKE '%汤%')
            -- 痛风过滤 (少喝肉汤)
            AND (FIND_IN_SET('痛风', v_diseases) = 0 OR (f.food_name NOT LIKE '%排骨%' AND f.food_name NOT LIKE '%鸡%' AND f.food_name NOT LIKE '%鸭%'))
            ORDER BY RAND() LIMIT 1;
            
        ELSEIF p_meal_type = '2' THEN -- 晚餐 (杂粮/少主食 + 清淡肉/鱼 + 多菜 + 汤)
            -- 1. 主食 (杂粮/粥)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '主食', 
                   FLOOR(100 + RAND() * 50), -- 100-150g (少吃点)
                   n.calories, n.protein, n.fat, n.carbohydrate, '低卡主食'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 1
            -- 糖尿病过滤 (少喝粥)
            AND (FIND_IN_SET('糖尿病', v_diseases) = 0 OR f.food_name NOT LIKE '%粥%')
            -- 小麦过敏
            AND (FIND_IN_SET('小麦', v_allergies) = 0 OR (f.food_name NOT LIKE '%面%' AND f.food_name NOT LIKE '%馒头%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 2. 轻荤 (鱼/虾/鸡)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '荤菜', 
                   FLOOR(80 + RAND() * 40), -- 80-120g
                   n.calories, n.protein, n.fat, n.carbohydrate, '优质低脂蛋白'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id IN (4, 5) AND (f.food_name LIKE '%鱼%' OR f.food_name LIKE '%虾%' OR f.food_name LIKE '%鸡%')
            -- 素食过滤
            AND (FIND_IN_SET('素食', v_preferences) = 0)
            -- 海鲜过敏
            AND (FIND_IN_SET('海鲜', v_allergies) = 0 OR (f.food_name NOT LIKE '%鱼%' AND f.food_name NOT LIKE '%虾%'))
            -- 痛风过滤
            AND (FIND_IN_SET('痛风', v_diseases) = 0 OR (f.food_name NOT LIKE '%鱼%' AND f.food_name NOT LIKE '%虾%'))
            ORDER BY RAND() LIMIT 1;
            
            -- 3. 多素菜
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '素菜', 
                   FLOOR(200 + RAND() * 50), -- 200-250g
                   n.calories, n.protein, n.fat, n.carbohydrate, '高纤维饱腹'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id = 2
            -- 清淡/辣过滤
            AND (FIND_IN_SET('清淡', v_preferences) = 0 OR (f.food_name NOT LIKE '%辣%' AND f.food_name NOT LIKE '%炸%'))
            ORDER BY RAND() LIMIT 1;
            
             -- 4. 汤
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '汤羹', 
                   200,
                   n.calories, n.protein, n.fat, n.carbohydrate, '助眠汤品'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE (c.category_id = 8 OR f.food_name LIKE '%汤%')
            -- 痛风过滤
            AND (FIND_IN_SET('痛风', v_diseases) = 0 OR (f.food_name NOT LIKE '%排骨%' AND f.food_name NOT LIKE '%鸡%' AND f.food_name NOT LIKE '%鸭%'))
            ORDER BY RAND() LIMIT 1;
            
        ELSE -- 加餐 (水果/坚果/奶)
            INSERT INTO temp_recommendations
            SELECT v_combo_id, f.food_id, f.food_name, c.category_name, '加餐', 
                   FLOOR(100 + RAND() * 50),
                   n.calories, n.protein, n.fat, n.carbohydrate, '健康零食'
            FROM diet_food_info f
            JOIN diet_food_nutrition n ON f.food_id = n.food_id
            JOIN diet_food_category c ON f.category_id = c.category_id
            WHERE c.category_id IN (3, 6, 7)
            -- 坚果过敏
            AND (FIND_IN_SET('坚果', v_allergies) = 0 OR (f.food_name NOT LIKE '%核桃%' AND f.food_name NOT LIKE '%杏仁%' AND f.food_name NOT LIKE '%花生%'))
            -- 牛奶过敏
            AND (FIND_IN_SET('牛奶', v_allergies) = 0 OR f.food_name NOT LIKE '%奶%')
            ORDER BY RAND() LIMIT 2;
        END IF;
        
        SET i = i + 1;
    END WHILE;
    
    -- 返回结果
    SELECT * FROM temp_recommendations;
    
    DROP TEMPORARY TABLE IF EXISTS temp_recommendations;
END$$

DELIMITER ;
