-- 营养表扩展脚本 - 添加更多营养素字段

-- 为 diet_food_nutrition 表添加更多营养素字段
ALTER TABLE `diet_food_nutrition` 
ADD COLUMN `vitamin_b1` decimal(8,4) DEFAULT NULL COMMENT '维生素B1/硫胺素(mg/100g)' AFTER `potassium`,
ADD COLUMN `vitamin_b2` decimal(8,4) DEFAULT NULL COMMENT '维生素B2/核黄素(mg/100g)' AFTER `vitamin_b1`,
ADD COLUMN `vitamin_b3` decimal(8,4) DEFAULT NULL COMMENT '维生素B3/烟酸(mg/100g)' AFTER `vitamin_b2`,
ADD COLUMN `vitamin_b6` decimal(8,4) DEFAULT NULL COMMENT '维生素B6(mg/100g)' AFTER `vitamin_b3`,
ADD COLUMN `vitamin_b12` decimal(8,4) DEFAULT NULL COMMENT '维生素B12(μg/100g)' AFTER `vitamin_b6`,
ADD COLUMN `folate` decimal(8,2) DEFAULT NULL COMMENT '叶酸(μg/100g)' AFTER `vitamin_b12`,
ADD COLUMN `vitamin_e` decimal(8,2) DEFAULT NULL COMMENT '维生素E(mg/100g)' AFTER `folate`,
ADD COLUMN `vitamin_k` decimal(8,2) DEFAULT NULL COMMENT '维生素K(μg/100g)' AFTER `vitamin_e`,
ADD COLUMN `magnesium` decimal(8,2) DEFAULT NULL COMMENT '镁(mg/100g)' AFTER `vitamin_k`,
ADD COLUMN `phosphorus` decimal(8,2) DEFAULT NULL COMMENT '磷(mg/100g)' AFTER `magnesium`,
ADD COLUMN `zinc` decimal(8,2) DEFAULT NULL COMMENT '锌(mg/100g)' AFTER `phosphorus`,
ADD COLUMN `copper` decimal(8,4) DEFAULT NULL COMMENT '铜(mg/100g)' AFTER `zinc`,
ADD COLUMN `manganese` decimal(8,4) DEFAULT NULL COMMENT '锰(mg/100g)' AFTER `copper`,
ADD COLUMN `selenium` decimal(8,2) DEFAULT NULL COMMENT '硒(μg/100g)' AFTER `manganese`,
ADD COLUMN `iodine` decimal(8,2) DEFAULT NULL COMMENT '碘(μg/100g)' AFTER `selenium`,
ADD COLUMN `omega_3` decimal(8,4) DEFAULT NULL COMMENT 'Omega-3脂肪酸(g/100g)' AFTER `iodine`,
ADD COLUMN `omega_6` decimal(8,4) DEFAULT NULL COMMENT 'Omega-6脂肪酸(g/100g)' AFTER `omega_3`,
ADD COLUMN `saturated_fat` decimal(8,2) DEFAULT NULL COMMENT '饱和脂肪酸(g/100g)' AFTER `omega_6`,
ADD COLUMN `monounsaturated_fat` decimal(8,2) DEFAULT NULL COMMENT '单不饱和脂肪酸(g/100g)' AFTER `saturated_fat`,
ADD COLUMN `polyunsaturated_fat` decimal(8,2) DEFAULT NULL COMMENT '多不饱和脂肪酸(g/100g)' AFTER `monounsaturated_fat`,
ADD COLUMN `glycemic_index` int(3) DEFAULT NULL COMMENT '血糖指数GI' AFTER `polyunsaturated_fat`,
ADD COLUMN `antioxidant_capacity` decimal(10,2) DEFAULT NULL COMMENT '抗氧化能力(ORAC值)' AFTER `glycemic_index`;
