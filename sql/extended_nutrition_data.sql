-- 扩展营养数据脚本 - 为现有食物添加新的营养素信息

-- 更新基础食物的扩展营养信息
-- 白米饭 (ID: 1)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.02, `vitamin_b2` = 0.02, `vitamin_b3` = 1.30, `vitamin_b6` = 0.05, `vitamin_b12` = 0.00,
    `folate` = 3.00, `vitamin_e` = 0.07, `vitamin_k` = 0.10, `magnesium` = 12.00, `phosphorus` = 43.00,
    `zinc` = 0.70, `copper` = 0.12, `manganese` = 0.47, `selenium` = 2.30, `iodine` = 2.50,
    `omega_3` = 0.01, `omega_6` = 0.09, `saturated_fat` = 0.09, `monounsaturated_fat` = 0.09, `polyunsaturated_fat` = 0.10,
    `glycemic_index` = 73, `antioxidant_capacity` = 56.00
WHERE `nutrition_id` = 1;

-- 鸡胸肉 (ID: 2)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.07, `vitamin_b2` = 0.10, `vitamin_b3` = 13.40, `vitamin_b6` = 0.60, `vitamin_b12` = 0.34,
    `folate` = 4.00, `vitamin_e` = 0.27, `vitamin_k` = 0.40, `magnesium` = 25.00, `phosphorus` = 228.00,
    `zinc` = 0.90, `copper` = 0.04, `manganese` = 0.02, `selenium` = 27.60, `iodine` = 7.00,
    `omega_3` = 0.06, `omega_6` = 0.79, `saturated_fat` = 1.02, `monounsaturated_fat` = 1.24, `polyunsaturated_fat` = 0.86,
    `glycemic_index` = 0, `antioxidant_capacity` = 300.00
WHERE `nutrition_id` = 2;

-- 西兰花 (ID: 3)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.07, `vitamin_b2` = 0.12, `vitamin_b3` = 0.64, `vitamin_b6` = 0.18, `vitamin_b12` = 0.00,
    `folate` = 63.00, `vitamin_e` = 0.78, `vitamin_k` = 101.60, `magnesium` = 21.00, `phosphorus` = 66.00,
    `zinc` = 0.41, `copper` = 0.05, `manganese` = 0.21, `selenium` = 2.50, `iodine` = 15.00,
    `omega_3` = 0.09, `omega_6` = 0.06, `saturated_fat` = 0.08, `monounsaturated_fat` = 0.01, `polyunsaturated_fat` = 0.15,
    `glycemic_index` = 10, `antioxidant_capacity` = 3083.00
WHERE `nutrition_id` = 3;

-- 鸡蛋 (ID: 4)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.04, `vitamin_b2` = 0.44, `vitamin_b3` = 0.08, `vitamin_b6` = 0.17, `vitamin_b12` = 0.89,
    `folate` = 47.00, `vitamin_e` = 1.05, `vitamin_k` = 0.30, `magnesium` = 12.00, `phosphorus` = 198.00,
    `zinc` = 1.29, `copper` = 0.07, `manganese` = 0.03, `selenium` = 30.70, `iodine` = 20.00,
    `omega_3` = 0.04, `omega_6` = 1.41, `saturated_fat` = 3.13, `monounsaturated_fat` = 3.66, `polyunsaturated_fat` = 1.91,
    `glycemic_index` = 0, `antioxidant_capacity` = 1140.00
WHERE `nutrition_id` = 4;

-- 香蕉 (ID: 5)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.03, `vitamin_b2` = 0.07, `vitamin_b3` = 0.67, `vitamin_b6` = 0.37, `vitamin_b12` = 0.00,
    `folate` = 20.00, `vitamin_e` = 0.10, `vitamin_k` = 0.50, `magnesium` = 27.00, `phosphorus` = 22.00,
    `zinc` = 0.15, `copper` = 0.08, `manganese` = 0.27, `selenium` = 1.00, `iodine` = 3.00,
    `omega_3` = 0.03, `omega_6` = 0.05, `saturated_fat` = 0.11, `monounsaturated_fat` = 0.03, `polyunsaturated_fat` = 0.07,
    `glycemic_index` = 51, `antioxidant_capacity` = 795.00
WHERE `nutrition_id` = 5;

-- 牛奶 (ID: 6)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.04, `vitamin_b2` = 0.18, `vitamin_b3` = 0.09, `vitamin_b6` = 0.04, `vitamin_b12` = 0.44,
    `folate` = 5.00, `vitamin_e` = 0.07, `vitamin_k` = 0.40, `magnesium` = 10.00, `phosphorus` = 93.00,
    `zinc` = 0.38, `copper` = 0.01, `manganese` = 0.00, `selenium` = 3.70, `iodine` = 15.90,
    `omega_3` = 0.08, `omega_6` = 0.07, `saturated_fat` = 1.87, `monounsaturated_fat` = 0.81, `polyunsaturated_fat` = 0.20,
    `glycemic_index` = 39, `antioxidant_capacity` = 156.00
WHERE `nutrition_id` = 6;

-- 燕麦 (ID: 7)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.76, `vitamin_b2` = 0.14, `vitamin_b3` = 0.96, `vitamin_b6` = 0.12, `vitamin_b12` = 0.00,
    `folate` = 56.00, `vitamin_e` = 0.70, `vitamin_k` = 2.00, `magnesium` = 177.00, `phosphorus` = 523.00,
    `zinc` = 3.97, `copper` = 0.63, `manganese` = 4.92, `selenium` = 28.90, `iodine` = 7.50,
    `omega_3` = 0.11, `omega_6` = 2.42, `saturated_fat` = 1.22, `monounsaturated_fat` = 2.18, `polyunsaturated_fat` = 2.54,
    `glycemic_index` = 55, `antioxidant_capacity` = 1708.00
WHERE `nutrition_id` = 7;

-- 三文鱼 (ID: 8)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.23, `vitamin_b2` = 0.38, `vitamin_b3` = 8.56, `vitamin_b6` = 0.94, `vitamin_b12` = 3.18,
    `folate` = 25.00, `vitamin_e` = 3.55, `vitamin_k` = 0.10, `magnesium` = 30.00, `phosphorus` = 252.00,
    `zinc` = 0.64, `copper` = 0.25, `manganese` = 0.02, `selenium` = 36.50, `iodine` = 8.00,
    `omega_3` = 2.26, `omega_6` = 0.17, `saturated_fat` = 3.05, `monounsaturated_fat` = 3.77, `polyunsaturated_fat` = 2.54,
    `glycemic_index` = 0, `antioxidant_capacity` = 3182.00
WHERE `nutrition_id` = 8;

-- 菠菜 (ID: 9)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.08, `vitamin_b2` = 0.19, `vitamin_b3` = 0.72, `vitamin_b6` = 0.20, `vitamin_b12` = 0.00,
    `folate` = 194.00, `vitamin_e` = 2.03, `vitamin_k` = 482.90, `magnesium` = 79.00, `phosphorus` = 49.00,
    `zinc` = 0.53, `copper` = 0.13, `manganese` = 0.90, `selenium` = 1.00, `iodine` = 12.00,
    `omega_3` = 0.14, `omega_6` = 0.03, `saturated_fat` = 0.06, `monounsaturated_fat` = 0.01, `polyunsaturated_fat` = 0.17,
    `glycemic_index` = 15, `antioxidant_capacity` = 1515.00
WHERE `nutrition_id` = 9;

-- 苹果 (ID: 10)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.02, `vitamin_b2` = 0.03, `vitamin_b3` = 0.09, `vitamin_b6` = 0.04, `vitamin_b12` = 0.00,
    `folate` = 3.00, `vitamin_e` = 0.18, `vitamin_k` = 2.20, `magnesium` = 5.00, `phosphorus` = 11.00,
    `zinc` = 0.04, `copper` = 0.03, `manganese` = 0.04, `selenium` = 0.00, `iodine` = 1.00,
    `omega_3` = 0.01, `omega_6` = 0.04, `saturated_fat` = 0.06, `monounsaturated_fat` = 0.01, `polyunsaturated_fat` = 0.05,
    `glycemic_index` = 36, `antioxidant_capacity` = 3049.00
WHERE `nutrition_id` = 10;

-- 为新增食物添加扩展营养信息
-- 糙米饭 (ID: 11)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.40, `vitamin_b2` = 0.04, `vitamin_b3` = 2.98, `vitamin_b6` = 0.51, `vitamin_b12` = 0.00,
    `folate` = 20.00, `vitamin_e` = 1.20, `vitamin_k` = 1.90, `magnesium` = 44.00, `phosphorus` = 150.00,
    `zinc` = 1.16, `copper` = 0.20, `manganese` = 1.11, `selenium` = 23.40, `iodine` = 2.50,
    `omega_3` = 0.03, `omega_6` = 0.31, `saturated_fat` = 0.18, `monounsaturated_fat` = 0.31, `polyunsaturated_fat` = 0.34,
    `glycemic_index` = 50, `antioxidant_capacity` = 1200.00
WHERE `nutrition_id` = 11;

-- 全麦面包 (ID: 13)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.41, `vitamin_b2` = 0.10, `vitamin_b3` = 4.96, `vitamin_b6` = 0.27, `vitamin_b12` = 0.00,
    `folate` = 44.00, `vitamin_e` = 1.01, `vitamin_k` = 4.60, `magnesium` = 82.00, `phosphorus` = 212.00,
    `zinc` = 1.81, `copper` = 0.26, `manganese` = 1.61, `selenium` = 28.10, `iodine` = 5.00,
    `omega_3` = 0.16, `omega_6` = 1.16, `saturated_fat` = 0.72, `monounsaturated_fat` = 0.58, `polyunsaturated_fat` = 1.32,
    `glycemic_index` = 51, `antioxidant_capacity` = 1421.00
WHERE `nutrition_id` = 13;

-- 藜麦 (ID: 18)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.36, `vitamin_b2` = 0.32, `vitamin_b3` = 1.52, `vitamin_b6` = 0.49, `vitamin_b12` = 0.00,
    `folate` = 184.00, `vitamin_e` = 2.44, `vitamin_k` = 0.00, `magnesium` = 197.00, `phosphorus` = 457.00,
    `zinc` = 3.10, `copper` = 0.59, `manganese` = 2.03, `selenium` = 8.50, `iodine` = 0.00,
    `omega_3` = 0.26, `omega_6` = 2.98, `saturated_fat` = 0.71, `monounsaturated_fat` = 1.61, `polyunsaturated_fat` = 3.32,
    `glycemic_index` = 53, `antioxidant_capacity` = 926.00
WHERE `nutrition_id` = 18;

-- 红薯 (ID: 19)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.08, `vitamin_b2` = 0.06, `vitamin_b3` = 0.56, `vitamin_b6` = 0.21, `vitamin_b12` = 0.00,
    `folate` = 11.00, `vitamin_e` = 0.26, `vitamin_k` = 1.80, `magnesium` = 25.00, `phosphorus` = 47.00,
    `zinc` = 0.30, `copper` = 0.15, `manganese` = 0.26, `selenium` = 0.60, `iodine` = 2.00,
    `omega_3` = 0.01, `omega_6` = 0.01, `saturated_fat` = 0.02, `monounsaturated_fat` = 0.00, `polyunsaturated_fat` = 0.05,
    `glycemic_index` = 63, `antioxidant_capacity` = 902.00
WHERE `nutrition_id` = 19;

-- 胡萝卜 (ID: 27)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.07, `vitamin_b2` = 0.06, `vitamin_b3` = 0.98, `vitamin_b6` = 0.14, `vitamin_b12` = 0.00,
    `folate` = 19.00, `vitamin_e` = 0.66, `vitamin_k` = 13.20, `magnesium` = 12.00, `phosphorus` = 35.00,
    `zinc` = 0.24, `copper` = 0.05, `manganese` = 0.14, `selenium` = 0.10, `iodine` = 15.00,
    `omega_3` = 0.00, `omega_6` = 0.12, `saturated_fat` = 0.04, `monounsaturated_fat` = 0.01, `polyunsaturated_fat` = 0.12,
    `glycemic_index` = 47, `antioxidant_capacity` = 666.00
WHERE `nutrition_id` = 27;

-- 番茄 (ID: 33)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.04, `vitamin_b2` = 0.02, `vitamin_b3` = 0.59, `vitamin_b6` = 0.08, `vitamin_b12` = 0.00,
    `folate` = 15.00, `vitamin_e` = 0.54, `vitamin_k` = 7.90, `magnesium` = 11.00, `phosphorus` = 24.00,
    `zinc` = 0.17, `copper` = 0.06, `manganese` = 0.11, `selenium` = 0.00, `iodine` = 2.00,
    `omega_3` = 0.00, `omega_6` = 0.08, `saturated_fat` = 0.03, `monounsaturated_fat` = 0.03, `polyunsaturated_fat` = 0.08,
    `glycemic_index` = 10, `antioxidant_capacity` = 546.00
WHERE `nutrition_id` = 33;

-- 草莓 (ID: 47)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.02, `vitamin_b2` = 0.02, `vitamin_b3` = 0.39, `vitamin_b6` = 0.05, `vitamin_b12` = 0.00,
    `folate` = 24.00, `vitamin_e` = 0.29, `vitamin_k` = 2.20, `magnesium` = 13.00, `phosphorus` = 24.00,
    `zinc` = 0.14, `copper` = 0.05, `manganese` = 0.39, `selenium` = 0.40, `iodine` = 1.00,
    `omega_3` = 0.07, `omega_6` = 0.09, `saturated_fat` = 0.02, `monounsaturated_fat` = 0.04, `polyunsaturated_fat` = 0.16,
    `glycemic_index` = 40, `antioxidant_capacity` = 4302.00
WHERE `nutrition_id` = 47;

-- 蓝莓 (ID: 48)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.04, `vitamin_b2` = 0.04, `vitamin_b3` = 0.42, `vitamin_b6` = 0.05, `vitamin_b12` = 0.00,
    `folate` = 6.00, `vitamin_e` = 0.57, `vitamin_k` = 19.30, `magnesium` = 6.00, `phosphorus` = 12.00,
    `zinc` = 0.16, `copper` = 0.06, `manganese` = 0.34, `selenium` = 0.10, `iodine` = 1.00,
    `omega_3` = 0.06, `omega_6` = 0.09, `saturated_fat` = 0.05, `monounsaturated_fat` = 0.05, `polyunsaturated_fat` = 0.15,
    `glycemic_index` = 53, `antioxidant_capacity` = 9621.00
WHERE `nutrition_id` = 48;

-- 核桃 (ID: 88)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.34, `vitamin_b2` = 0.15, `vitamin_b3` = 1.13, `vitamin_b6` = 0.54, `vitamin_b12` = 0.00,
    `folate` = 98.00, `vitamin_e` = 0.70, `vitamin_k` = 2.70, `magnesium` = 158.00, `phosphorus` = 346.00,
    `zinc` = 3.09, `copper` = 1.59, `manganese` = 3.41, `selenium` = 4.90, `iodine` = 3.10,
    `omega_3` = 9.08, `omega_6` = 38.09, `saturated_fat` = 6.13, `monounsaturated_fat` = 8.93, `polyunsaturated_fat` = 47.17,
    `glycemic_index` = 15, `antioxidant_capacity` = 13541.00
WHERE `nutrition_id` = 88;

-- 三文鱼扩展数据已在上面更新

-- 豆腐 (ID: 73)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.08, `vitamin_b2` = 0.05, `vitamin_b3` = 0.23, `vitamin_b6` = 0.05, `vitamin_b12` = 0.00,
    `folate` = 15.00, `vitamin_e` = 0.01, `vitamin_k` = 2.40, `magnesium` = 30.00, `phosphorus` = 97.00,
    `zinc` = 0.80, `copper` = 0.19, `manganese` = 0.61, `selenium` = 8.90, `iodine` = 15.00,
    `omega_3` = 0.63, `omega_6` = 2.00, `saturated_fat` = 0.54, `monounsaturated_fat` = 0.82, `polyunsaturated_fat` = 2.08,
    `glycemic_index` = 15, `antioxidant_capacity` = 500.00
WHERE `nutrition_id` = 73;

-- 酸奶 (ID: 84)
UPDATE `diet_food_nutrition` SET 
    `vitamin_b1` = 0.04, `vitamin_b2` = 0.14, `vitamin_b3` = 0.08, `vitamin_b6` = 0.03, `vitamin_b12` = 0.37,
    `folate` = 7.00, `vitamin_e` = 0.06, `vitamin_k` = 0.20, `magnesium` = 12.00, `phosphorus` = 95.00,
    `zinc` = 0.59, `copper` = 0.01, `manganese` = 0.00, `selenium` = 2.20, `iodine` = 15.90,
    `omega_3` = 0.08, `omega_6` = 0.06, `saturated_fat` = 1.55, `monounsaturated_fat` = 0.68, `polyunsaturated_fat` = 0.08,
    `glycemic_index` = 35, `antioxidant_capacity` = 200.00
WHERE `nutrition_id` = 84;
