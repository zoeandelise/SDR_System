-- 智能饮食推荐系统数据库表结构

-- 用户健康信息表
CREATE TABLE `sys_user_health` (
  `health_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '健康信息ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高(cm)',
  `weight` decimal(5,2) DEFAULT NULL COMMENT '体重(kg)',
  `age` int(3) DEFAULT NULL COMMENT '年龄',
  `gender` char(1) DEFAULT NULL COMMENT '性别(0男 1女)',
  `activity_level` char(1) DEFAULT '2' COMMENT '活动水平(0久坐 1轻度 2中度 3重度 4极重度)',
  `health_goal` char(1) DEFAULT '0' COMMENT '健康目标(0保持 1减脂 2增肌 3增重)',
  `target_weight` decimal(5,2) DEFAULT NULL COMMENT '目标体重(kg)',
  `daily_calorie_goal` int(11) DEFAULT NULL COMMENT '每日热量目标(kcal)',
  `allergies` varchar(500) DEFAULT NULL COMMENT '过敏信息',
  `diseases` varchar(500) DEFAULT NULL COMMENT '疾病信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`health_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户健康信息表';

-- 食物基础信息表
CREATE TABLE `diet_food_info` (
  `food_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '食物ID',
  `food_name` varchar(100) NOT NULL COMMENT '食物名称',
  `food_code` varchar(50) DEFAULT NULL COMMENT '食物编码',
  `category_id` bigint(20) DEFAULT NULL COMMENT '食物分类ID',
  `brand` varchar(100) DEFAULT NULL COMMENT '品牌',
  `description` text COMMENT '食物描述',
  `image_url` varchar(255) DEFAULT NULL COMMENT '食物图片URL',
  `unit` varchar(20) DEFAULT 'g' COMMENT '计量单位',
  `standard_weight` decimal(8,2) DEFAULT 100.00 COMMENT '标准重量(g)',
  `status` char(1) DEFAULT '0' COMMENT '状态(0正常 1停用)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`food_id`),
  UNIQUE KEY `uk_food_name` (`food_name`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='食物基础信息表';

-- 食物分类表
CREATE TABLE `diet_food_category` (
  `category_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父分类ID',
  `ancestors` varchar(50) DEFAULT '' COMMENT '祖级列表',
  `category_name` varchar(30) NOT NULL COMMENT '分类名称',
  `order_num` int(4) DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `status` char(1) DEFAULT '0' COMMENT '分类状态(0正常 1停用)',
  `del_flag` char(1) DEFAULT '0' COMMENT '删除标志(0代表存在 2代表删除)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='食物分类表';

-- 食物营养信息表
CREATE TABLE `diet_food_nutrition` (
  `nutrition_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '营养信息ID',
  `food_id` bigint(20) NOT NULL COMMENT '食物ID',
  `calories` decimal(8,2) DEFAULT NULL COMMENT '热量(kcal/100g)',
  `protein` decimal(8,2) DEFAULT NULL COMMENT '蛋白质(g/100g)',
  `fat` decimal(8,2) DEFAULT NULL COMMENT '脂肪(g/100g)',
  `carbohydrate` decimal(8,2) DEFAULT NULL COMMENT '碳水化合物(g/100g)',
  `fiber` decimal(8,2) DEFAULT NULL COMMENT '膳食纤维(g/100g)',
  `sugar` decimal(8,2) DEFAULT NULL COMMENT '糖分(g/100g)',
  `sodium` decimal(8,2) DEFAULT NULL COMMENT '钠(mg/100g)',
  `cholesterol` decimal(8,2) DEFAULT NULL COMMENT '胆固醇(mg/100g)',
  `vitamin_a` decimal(8,2) DEFAULT NULL COMMENT '维生素A(μg/100g)',
  `vitamin_c` decimal(8,2) DEFAULT NULL COMMENT '维生素C(mg/100g)',
  `vitamin_d` decimal(8,2) DEFAULT NULL COMMENT '维生素D(μg/100g)',
  `calcium` decimal(8,2) DEFAULT NULL COMMENT '钙(mg/100g)',
  `iron` decimal(8,2) DEFAULT NULL COMMENT '铁(mg/100g)',
  `potassium` decimal(8,2) DEFAULT NULL COMMENT '钾(mg/100g)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`nutrition_id`),
  UNIQUE KEY `uk_food_id` (`food_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='食物营养信息表';

-- 饮食记录表 (MySQL存储基本信息，详细数据存储在MongoDB)
CREATE TABLE `diet_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `record_date` date NOT NULL COMMENT '记录日期',
  `meal_type` char(1) NOT NULL COMMENT '餐次类型(0早餐 1午餐 2晚餐 3加餐)',
  `total_calories` decimal(8,2) DEFAULT 0.00 COMMENT '总热量(kcal)',
  `total_protein` decimal(8,2) DEFAULT 0.00 COMMENT '总蛋白质(g)',
  `total_fat` decimal(8,2) DEFAULT 0.00 COMMENT '总脂肪(g)',
  `total_carbohydrate` decimal(8,2) DEFAULT 0.00 COMMENT '总碳水化合物(g)',
  `mongo_doc_id` varchar(100) DEFAULT NULL COMMENT 'MongoDB文档ID',
  `image_urls` text COMMENT '食物照片URLs',
  `notes` text COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_user_date` (`user_id`, `record_date`),
  KEY `idx_meal_type` (`meal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食记录表';

-- 饮食推荐记录表
CREATE TABLE `diet_recommendation` (
  `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '推荐ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `recommendation_date` date NOT NULL COMMENT '推荐日期',
  `meal_type` char(1) NOT NULL COMMENT '餐次类型(0早餐 1午餐 2晚餐 3加餐)',
  `recommended_foods` text COMMENT '推荐食物列表(JSON格式)',
  `target_calories` decimal(8,2) DEFAULT NULL COMMENT '目标热量(kcal)',
  `target_protein` decimal(8,2) DEFAULT NULL COMMENT '目标蛋白质(g)',
  `target_fat` decimal(8,2) DEFAULT NULL COMMENT '目标脂肪(g)',
  `target_carbohydrate` decimal(8,2) DEFAULT NULL COMMENT '目标碳水化合物(g)',
  `recommendation_reason` text COMMENT '推荐理由',
  `algorithm_type` varchar(50) DEFAULT NULL COMMENT '推荐算法类型',
  `score` decimal(5,2) DEFAULT NULL COMMENT '推荐评分',
  `is_accepted` char(1) DEFAULT '2' COMMENT '是否接受(0拒绝 1接受 2待定)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`recommendation_id`),
  KEY `idx_user_date` (`user_id`, `recommendation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食推荐记录表';

-- AI识别记录表
CREATE TABLE `diet_ai_recognition` (
  `recognition_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '识别ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `image_url` varchar(255) NOT NULL COMMENT '原始图片URL',
  `processed_image_url` varchar(255) DEFAULT NULL COMMENT '处理后图片URL',
  `recognition_result` text COMMENT '识别结果(JSON格式)',
  `confidence_score` decimal(5,4) DEFAULT NULL COMMENT '置信度分数',
  `processing_time` int(11) DEFAULT NULL COMMENT '处理时间(毫秒)',
  `ai_model_version` varchar(50) DEFAULT NULL COMMENT 'AI模型版本',
  `status` char(1) DEFAULT '0' COMMENT '状态(0成功 1失败 2处理中)',
  `error_message` text COMMENT '错误信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`recognition_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI识别记录表';

-- 用户饮食偏好表
CREATE TABLE `diet_user_preference` (
  `preference_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '偏好ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `preferred_foods` text COMMENT '偏好食物列表(JSON格式)',
  `disliked_foods` text COMMENT '不喜欢食物列表(JSON格式)',
  `cuisine_preferences` varchar(500) DEFAULT NULL COMMENT '菜系偏好',
  `dietary_restrictions` varchar(500) DEFAULT NULL COMMENT '饮食限制',
  `meal_frequency` int(2) DEFAULT 3 COMMENT '每日用餐次数',
  `snack_preference` char(1) DEFAULT '1' COMMENT '零食偏好(0不吃 1偶尔 2经常)',
  `spice_level` char(1) DEFAULT '2' COMMENT '辣度偏好(0不辣 1微辣 2中辣 3重辣)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户饮食偏好表';

-- 系统配置扩展表
CREATE TABLE `diet_system_config` (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_name` varchar(100) NOT NULL COMMENT '配置名称',
  `config_key` varchar(100) NOT NULL COMMENT '配置键名',
  `config_value` text COMMENT '配置键值',
  `config_type` char(1) DEFAULT 'N' COMMENT '系统内置(Y是 N否)',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食系统配置表';

-- 插入初始食物分类数据
INSERT INTO `diet_food_category` VALUES 
(1, 0, '0', '谷薯类', 1, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(2, 0, '0', '蔬菜类', 2, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(3, 0, '0', '水果类', 3, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(4, 0, '0', '肉禽蛋类', 4, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(5, 0, '0', '水产类', 5, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(6, 0, '0', '豆类坚果', 6, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(7, 0, '0', '奶制品', 7, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL),
(8, 0, '0', '饮品类', 8, NULL, NULL, NULL, '0', '0', 'admin', sysdate(), '', NULL);

-- 插入系统配置数据
INSERT INTO `diet_system_config` VALUES 
(1, 'AI识别服务地址', 'ai.recognition.url', 'http://localhost:5000/api/recognition', 'Y', 'admin', sysdate(), '', NULL, 'AI食物识别服务的API地址'),
(2, 'MongoDB连接字符串', 'mongodb.connection.uri', 'mongodb://localhost:27017/diet_system', 'Y', 'admin', sysdate(), '', NULL, 'MongoDB数据库连接配置'),
(3, 'Neo4j连接地址', 'neo4j.connection.uri', 'bolt://localhost:7687', 'Y', 'admin', sysdate(), '', NULL, 'Neo4j知识图谱数据库连接'),
(4, '推荐算法类型', 'recommendation.algorithm.type', 'hybrid', 'Y', 'admin', sysdate(), '', NULL, '推荐算法类型(rule/collaborative/hybrid)'),
(5, '每日推荐次数', 'recommendation.daily.count', '3', 'Y', 'admin', sysdate(), '', NULL, '系统每日为用户生成推荐的次数');
