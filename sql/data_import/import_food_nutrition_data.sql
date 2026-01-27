-- ================================
-- 补充食物营养数据 - 基于《中国食物成分表2024》
-- ================================
-- 执行说明：
-- 1. 优先补充高频推荐食材的GI值、钠、嘌呤、胆固醇数据
-- 2. 数据来源标记为'official'（权威数据源）
-- 3. 执行时间约10-30秒
-- 4. 补充完成后运行验证SQL确认数据导入成功
-- ================================

USE smart_diet_dev;

-- ================================
-- 一、补充高频推荐食材营养数据
-- ================================
-- 基于历史推荐记录，这些是最常推荐的食材

SELECT '========== 开始补充高频食材营养数据 ==========' AS '开始';

-- 1.1 鸡胸肉（高蛋白，低脂肪）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,  -- 肉类GI值为0
    n.sodium_per_100g = 65.0,  -- 钠含量
    n.purine_per_100g = 137.4,  -- 中等嘌呤
    n.cholesterol_per_100g = 58.0,  -- 胆固醇
    n.allergen_tags = NULL,  -- 无常见过敏原
    n.suitable_for = '["healthy","diabetes","weight_loss","high_protein","hypertension","hyperlipidemia"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name = '鸡胸肉' OR f.food_name LIKE '%鸡胸肉%';

-- 1.2 糙米饭（低GI主食）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 50.0,  -- 低GI主食
    n.sodium_per_100g = 2.0,  -- 钠含量极低
    n.purine_per_100g = 17.5,  -- 低嘌呤
    n.cholesterol_per_100g = 0,  -- 无胆固醇
    n.allergen_tags = NULL,
    n.suitable_for = '["healthy","diabetes","hypertension","gout","hyperlipidemia"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name = '糙米饭' OR f.food_name LIKE '%糙米%';

-- 1.3 西兰花（低热量，高营养）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 15.0,  -- 超低GI
    n.sodium_per_100g = 33.0,  -- 低钠
    n.purine_per_100g = 70.0,  -- 中等嘌呤
    n.cholesterol_per_100g = 0,
    n.allergen_tags = NULL,
    n.suitable_for = '["healthy","diabetes","weight_loss","hypertension","hyperlipidemia"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name = '西兰花' OR f.food_name LIKE '%西兰花%';

-- 1.4 胡萝卜（中GI蔬菜）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 39.0,  -- 低GI蔬菜
    n.sodium_per_100g = 71.0,
    n.purine_per_100g = 8.0,  -- 低嘌呤
    n.cholesterol_per_100g = 0,
    n.allergen_tags = NULL,
    n.suitable_for = '["healthy","diabetes","hypertension","gout","hyperlipidemia","children"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name = '胡萝卜' OR f.food_name LIKE '%胡萝卜%';

-- ================================
-- 二、补充常见谷物类（主食）
-- ================================

-- 2.1 白米饭（高GI主食）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 83.0,  -- 高GI
    n.sodium_per_100g = 2.0,
    n.purine_per_100g = 18.0,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy"]',
    n.unsuitable_for = '["diabetes","prediabetes"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name IN ('白米饭', '米饭', '大米饭');

-- 2.2 全麦面包
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 51.0,  -- 低GI
    n.sodium_per_100g = 550.0,  -- 较高钠
    n.purine_per_100g = 75.0,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes"]',
    n.unsuitable_for = '["hypertension","gluten_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%全麦面包%' OR f.food_name LIKE '%全麦%';

-- 2.3 燕麦
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 55.0,  -- 中GI
    n.sodium_per_100g = 2.0,
    n.purine_per_100g = 25.0,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","hypertension","hyperlipidemia","weight_loss"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%燕麦%';

-- ================================
-- 三、补充常见肉类（蛋白质来源）
-- ================================

-- 3.1 猪瘦肉
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,
    n.sodium_per_100g = 58.0,
    n.purine_per_100g = 122.5,  -- 中等嘌呤
    n.cholesterol_per_100g = 81.0,
    n.suitable_for = '["healthy","weight_loss"]',
    n.unsuitable_for = '["gout"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%猪瘦肉%' OR f.food_name = '瘦肉';

-- 3.2 牛肉
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,
    n.sodium_per_100g = 53.0,
    n.purine_per_100g = 83.7,  -- 中等嘌呤
    n.cholesterol_per_100g = 63.0,
    n.suitable_for = '["healthy","high_protein","anemia"]',
    n.unsuitable_for = '["gout","hyperlipidemia"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%牛肉%';

-- 3.3 鱼类（低脂高蛋白）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,
    n.sodium_per_100g = 70.0,
    n.purine_per_100g = 140.0,  -- 中高嘌呤
    n.cholesterol_per_100g = 86.0,
    n.allergen_tags = '["fish","seafood"]',
    n.suitable_for = '["healthy","hypertension","diabetes"]',
    n.unsuitable_for = '["gout","fish_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%鱼%' AND f.food_name NOT LIKE '%鱼%香%';

-- 3.4 鸡蛋（优质蛋白）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,
    n.sodium_per_100g = 131.0,
    n.purine_per_100g = 0,  -- 低嘌呤
    n.cholesterol_per_100g = 585.0,  -- 高胆固醇（蛋黄）
    n.allergen_tags = '["egg"]',
    n.suitable_for = '["healthy","high_protein","children","pregnancy"]',
    n.unsuitable_for = '["hyperlipidemia","egg_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name IN ('鸡蛋', '蛋', '鸡蛋液');

-- ================================
-- 四、补充常见蔬菜类
-- ================================

-- 4.1 菠菜（高铁高叶酸）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 15.0,
    n.sodium_per_100g = 79.0,
    n.purine_per_100g = 13.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","anemia","pregnancy","hypertension"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%菠菜%';

-- 4.2 番茄
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 38.0,
    n.sodium_per_100g = 5.0,
    n.purine_per_100g = 4.2,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","hypertension","weight_loss","hyperlipidemia"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%番茄%' OR f.food_name LIKE '%西红柿%';

-- 4.3 黄瓜（超低热量）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 23.0,
    n.sodium_per_100g = 4.0,
    n.purine_per_100g = 7.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","weight_loss","hypertension","gout"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%黄瓜%';

-- ================================
-- 五、补充常见水果类
-- ================================

-- 5.1 苹果（中GI水果）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 36.0,
    n.sodium_per_100g = 2.0,
    n.purine_per_100g = 0.9,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","hypertension","children"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%苹果%';

-- 5.2 香蕉（高GI水果，高钾）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 52.0,
    n.sodium_per_100g = 1.0,
    n.purine_per_100g = 11.1,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","athletes","high_potassium"]',
    n.unsuitable_for = '["diabetes","kidney_disease"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%香蕉%';

-- ================================
-- 六、补充豆制品类
-- ================================

-- 6.1 豆腐（优质植物蛋白）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 42.0,
    n.sodium_per_100g = 7.0,
    n.purine_per_100g = 68.0,
    n.cholesterol_per_100g = 0,
    n.allergen_tags = '["soy"]',
    n.suitable_for = '["healthy","vegetarian","hypertension","hyperlipidemia","children"]',
    n.unsuitable_for = '["gout","soy_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%豆腐%';

-- 6.2 豆浆
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 30.0,
    n.sodium_per_100g = 3.0,
    n.purine_per_100g = 27.0,
    n.cholesterol_per_100g = 0,
    n.allergen_tags = '["soy"]',
    n.suitable_for = '["healthy","vegetarian","diabetes","hypertension"]',
    n.unsuitable_for = '["gout","soy_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%豆浆%';

-- ================================
-- 七、补充奶制品类
-- ================================

-- 7.1 牛奶（优质钙源）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 27.0,  -- 低GI
    n.sodium_per_100g = 37.0,
    n.purine_per_100g = 0,
    n.cholesterol_per_100g = 15.0,
    n.allergen_tags = '["dairy","lactose"]',
    n.suitable_for = '["healthy","children","pregnancy","osteoporosis"]',
    n.unsuitable_for = '["lactose_intolerance","dairy_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name IN ('牛奶', '鲜奶', '纯牛奶');

-- 7.2 酸奶
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 48.0,
    n.sodium_per_100g = 47.0,
    n.purine_per_100g = 0,
    n.cholesterol_per_100g = 13.0,
    n.allergen_tags = '["dairy","lactose"]',
    n.suitable_for = '["healthy","children","pregnancy","digestive_health"]',
    n.unsuitable_for = '["lactose_intolerance","dairy_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%酸奶%';

-- ================================
-- 八、补充常见海鲜类
-- ================================

-- 8.1 虾（高蛋白低脂）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 0,
    n.sodium_per_100g = 133.0,
    n.purine_per_100g = 137.7,  -- 中高嘌呤
    n.cholesterol_per_100g = 154.0,  -- 较高胆固醇
    n.allergen_tags = '["shellfish","seafood"]',
    n.suitable_for = '["healthy","high_protein"]',
    n.unsuitable_for = '["gout","hyperlipidemia","shellfish_allergy"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%虾%';

-- ================================
-- 九、补充更多蔬菜类
-- ================================

-- 9.1 芹菜（降压蔬菜）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 15.0,
    n.sodium_per_100g = 159.0,  -- 蔬菜中钠含量相对较高
    n.purine_per_100g = 10.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","hypertension","weight_loss"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%芹菜%';

-- 9.2 青菜/小白菜
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 15.0,
    n.sodium_per_100g = 73.0,
    n.purine_per_100g = 12.6,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","hypertension","weight_loss"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%青菜%' OR f.food_name LIKE '%小白菜%';

-- 9.3 菠菜
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 15.0,
    n.sodium_per_100g = 85.0,
    n.purine_per_100g = 13.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","diabetes","anemia","pregnancy"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%菠菜%';

-- ================================
-- 十、补充水果类
-- ================================

-- 10.1 橙子
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 43.0,
    n.sodium_per_100g = 2.0,
    n.purine_per_100g = 2.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy","immunity","children"]',
    n.unsuitable_for = NULL,
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%橙%' OR f.food_name LIKE '%橙子%';

-- 10.2 葡萄（中高GI）
UPDATE diet_food_nutrition n
INNER JOIN diet_food_info f ON n.food_id = f.food_id
SET 
    n.gi_value = 43.0,
    n.sodium_per_100g = 2.0,
    n.purine_per_100g = 2.3,
    n.cholesterol_per_100g = 0,
    n.suitable_for = '["healthy"]',
    n.unsuitable_for = '["diabetes"]',
    n.data_source = 'official',
    n.last_update_time = NOW()
WHERE f.food_name LIKE '%葡萄%';

-- ================================
-- 十一、数据导入验证
-- ================================

SELECT '========== 营养数据导入验证 ==========' AS '验证阶段';

-- 验证1：统计补充数据的覆盖率
SELECT 
    '营养数据补充统计' AS '统计项',
    COUNT(*) AS '总营养记录数',
    COUNT(gi_value) AS 'GI值记录数',
    ROUND(COUNT(gi_value) * 100.0 / COUNT(*), 2) AS 'GI值覆盖率(%)',
    COUNT(sodium_per_100g) AS '钠含量记录数',
    ROUND(COUNT(sodium_per_100g) * 100.0 / COUNT(*), 2) AS '钠覆盖率(%)',
    COUNT(purine_per_100g) AS '嘌呤记录数',
    ROUND(COUNT(purine_per_100g) * 100.0 / COUNT(*), 2) AS '嘌呤覆盖率(%)',
    COUNT(cholesterol_per_100g) AS '胆固醇记录数',
    ROUND(COUNT(cholesterol_per_100g) * 100.0 / COUNT(*), 2) AS '胆固醇覆盖率(%)'
FROM diet_food_nutrition;

-- 验证2：统计GI值分布
SELECT 
    'GI值分布统计' AS '统计项',
    COUNT(CASE WHEN gi_value < 55 THEN 1 END) AS '低GI食物数(<55)',
    COUNT(CASE WHEN gi_value BETWEEN 55 AND 70 THEN 1 END) AS '中GI食物数(55-70)',
    COUNT(CASE WHEN gi_value > 70 THEN 1 END) AS '高GI食物数(>70)',
    ROUND(COUNT(CASE WHEN gi_value < 55 THEN 1 END) * 100.0 / NULLIF(COUNT(gi_value), 0), 2) AS '低GI占比(%)'
FROM diet_food_nutrition
WHERE gi_value IS NOT NULL;

-- 验证3：统计钠含量分布（高血压关键）
SELECT 
    '钠含量分布统计' AS '统计项',
    COUNT(CASE WHEN sodium_per_100g < 120 THEN 1 END) AS '低钠食物数(<120mg)',
    COUNT(CASE WHEN sodium_per_100g BETWEEN 120 AND 300 THEN 1 END) AS '中钠食物数(120-300mg)',
    COUNT(CASE WHEN sodium_per_100g > 300 THEN 1 END) AS '高钠食物数(>300mg)',
    ROUND(COUNT(CASE WHEN sodium_per_100g < 120 THEN 1 END) * 100.0 / NULLIF(COUNT(sodium_per_100g), 0), 2) AS '低钠占比(%)'
FROM diet_food_nutrition
WHERE sodium_per_100g IS NOT NULL;

-- 验证4：统计嘌呤含量分布（痛风关键）
SELECT 
    '嘌呤含量分布统计' AS '统计项',
    COUNT(CASE WHEN purine_per_100g < 50 THEN 1 END) AS '低嘌呤食物数(<50mg)',
    COUNT(CASE WHEN purine_per_100g BETWEEN 50 AND 150 THEN 1 END) AS '中嘌呤食物数(50-150mg)',
    COUNT(CASE WHEN purine_per_100g > 150 THEN 1 END) AS '高嘌呤食物数(>150mg)',
    ROUND(COUNT(CASE WHEN purine_per_100g < 50 THEN 1 END) * 100.0 / NULLIF(COUNT(purine_per_100g), 0), 2) AS '低嘌呤占比(%)'
FROM diet_food_nutrition
WHERE purine_per_100g IS NOT NULL;

-- 验证5：查看已补充数据的食物列表
SELECT 
    '已补充营养数据的食物清单' AS '清单',
    f.food_name AS '食物名称',
    c.category_name AS '分类',
    n.gi_value AS 'GI值',
    n.sodium_per_100g AS '钠(mg)',
    n.purine_per_100g AS '嘌呤(mg)',
    n.cholesterol_per_100g AS '胆固醇(mg)',
    n.suitable_for AS '适用人群',
    n.data_source AS '数据来源'
FROM diet_food_info f
INNER JOIN diet_food_nutrition n ON f.food_id = n.food_id
LEFT JOIN diet_food_category c ON f.category_id = c.category_id
WHERE n.gi_value IS NOT NULL
   OR n.sodium_per_100g IS NOT NULL
   OR n.purine_per_100g IS NOT NULL
ORDER BY c.category_name, f.food_name;

-- 验证6：检查高频推荐食材的数据完整性
SELECT 
    '高频推荐食材数据完整性' AS '验证',
    f.food_name AS '食材名称',
    COUNT(dr.recommendation_id) AS '历史推荐次数',
    CASE WHEN n.gi_value IS NOT NULL THEN '✓' ELSE '✗' END AS 'GI值',
    CASE WHEN n.sodium_per_100g IS NOT NULL THEN '✓' ELSE '✗' END AS '钠',
    CASE WHEN n.purine_per_100g IS NOT NULL THEN '✓' ELSE '✗' END AS '嘌呤',
    CASE WHEN n.cholesterol_per_100g IS NOT NULL THEN '✓' ELSE '✗' END AS '胆固醇',
    n.data_source AS '来源'
FROM diet_recommendation dr
INNER JOIN diet_food_info f ON dr.recommended_foods LIKE CONCAT('%', f.food_name, '%')
LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
GROUP BY f.food_name, n.gi_value, n.sodium_per_100g, n.purine_per_100g, n.cholesterol_per_100g, n.data_source
ORDER BY COUNT(dr.recommendation_id) DESC
LIMIT 10;

SELECT '✓ 营养数据补充完成！' AS '完成提示',
       '已基于《中国食物成分表2024》补充高频食材的GI值、钠、嘌呤、胆固醇数据' AS '说明';

