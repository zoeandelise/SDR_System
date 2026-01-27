-- ================================
-- 智能饮食推荐系统 - 真实用户数据生成脚本
-- 生成30个真实用户及其完整的健康和饮食数据
-- ================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================
-- 1. 创建真实用户 (30个用户)
-- 密码统一为: admin123 (加密后的值)
-- ================================
INSERT INTO `sys_user` (`user_id`, `dept_id`, `user_name`, `nick_name`, `user_type`, `email`, `phonenumber`, `sex`, `avatar`, `password`, `status`, `del_flag`, `create_by`, `create_time`, `update_time`, `remark`) VALUES
(101, 103, 'zhangwei', '张伟', '00', 'zhangwei@diet.com', '13800138001', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健身爱好者'),
(102, 103, 'lina', '李娜', '00', 'lina@diet.com', '13800138002', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '素食主义者'),
(103, 103, 'wangjun', '王军', '00', 'wangjun@diet.com', '13800138003', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '减脂中'),
(104, 103, 'zhangli', '张丽', '00', 'zhangli@diet.com', '13800138004', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健康饮食'),
(105, 103, 'liuqiang', '刘强', '00', 'liuqiang@diet.com', '13800138005', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '增肌计划'),
(106, 103, 'chenfang', '陈芳', '00', 'chenfang@diet.com', '13800138006', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '产后恢复'),
(107, 103, 'yangmin', '杨敏', '00', 'yangmin@diet.com', '13800138007', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '上班族'),
(108, 103, 'zhaolei', '赵磊', '00', 'zhaolei@diet.com', '13800138008', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '运动员'),
(109, 103, 'sunyan', '孙艳', '00', 'sunyan@diet.com', '13800138009', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '模特'),
(110, 103, 'zhoujie', '周杰', '00', 'zhoujie@diet.com', '13800138010', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '程序员'),
(111, 103, 'wuxia', '吴霞', '00', 'wuxia@diet.com', '13800138011', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健身教练'),
(112, 103, 'zhengpeng', '郑鹏', '00', 'zhengpeng@diet.com', '13800138012', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '篮球爱好者'),
(113, 103, 'wanghui', '王慧', '00', 'wanghui@diet.com', '13800138013', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '瑜伽爱好者'),
(114, 103, 'lixiang', '李翔', '00', 'lixiang@diet.com', '13800138014', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '马拉松选手'),
(115, 103, 'zhangjing', '张静', '00', 'zhangjing@diet.com', '13800138015', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '营养师'),
(116, 103, 'liuyang', '刘洋', '00', 'liuyang@diet.com', '13800138016', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '游泳教练'),
(117, 103, 'chenhao', '陈浩', '00', 'chenhao@diet.com', '13800138017', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健美运动员'),
(118, 103, 'yangxue', '杨雪', '00', 'yangxue@diet.com', '13800138018', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '舞蹈演员'),
(119, 103, 'zhaoyun', '赵云', '00', 'zhaoyun@diet.com', '13800138019', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '武术爱好者'),
(120, 103, 'sunli', '孙丽', '00', 'sunli@diet.com', '13800138020', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '白领'),
(121, 103, 'zhouming', '周明', '00', 'zhouming@diet.com', '13800138021', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健身达人'),
(122, 103, 'wuqian', '吴倩', '00', 'wuqian@diet.com', '13800138022', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '爬山爱好者'),
(123, 103, 'zhenghua', '郑华', '00', 'zhenghua@diet.com', '13800138023', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '力量训练'),
(124, 103, 'wangting', '王婷', '00', 'wangting@diet.com', '13800138024', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '普拉提教练'),
(125, 103, 'lifei', '李飞', '00', 'lifei@diet.com', '13800138025', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '自行车爱好者'),
(126, 103, 'zhangyue', '张悦', '00', 'zhangyue@diet.com', '13800138026', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健康管理'),
(127, 103, 'liubin', '刘斌', '00', 'liubin@diet.com', '13800138027', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '足球运动员'),
(128, 103, 'chenjuan', '陈娟', '00', 'chenjuan@diet.com', '13800138028', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '减肥达人'),
(129, 103, 'yanggang', '杨刚', '00', 'yanggang@diet.com', '13800138029', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健身教练'),
(130, 103, 'zhaomei', '赵梅', '00', 'zhaomei@diet.com', '13800138030', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', 'admin', NOW(), NOW(), '健康顾问');

-- ================================
-- 2. 用户健康信息 (30个用户)
-- health_goal: 0保持 1减脂 2增肌 3增重
-- activity_level: 0久坐 1轻度 2中度 3重度 4极重度
-- ================================
INSERT INTO `sys_user_health` (`user_id`, `height`, `weight`, `age`, `gender`, `activity_level`, `health_goal`, `target_weight`, `daily_calorie_goal`, `allergies`, `diseases`, `create_time`, `update_time`) VALUES
(101, 175.0, 75.0, 28, '0', '3', '2', 80.0, 2800, '无', '无', NOW(), NOW()),
(102, 162.0, 52.0, 25, '1', '2', '0', 52.0, 1800, '海鲜', '无', NOW(), NOW()),
(103, 178.0, 85.0, 32, '0', '2', '1', 75.0, 2000, '无', '高血压', NOW(), NOW()),
(104, 165.0, 58.0, 27, '1', '2', '0', 58.0, 1900, '无', '无', NOW(), NOW()),
(105, 180.0, 70.0, 26, '0', '4', '2', 78.0, 3000, '无', '无', NOW(), NOW()),
(106, 160.0, 65.0, 30, '1', '1', '1', 55.0, 1600, '牛奶', '无', NOW(), NOW()),
(107, 168.0, 60.0, 29, '1', '2', '0', 60.0, 1950, '无', '无', NOW(), NOW()),
(108, 185.0, 78.0, 24, '0', '4', '2', 85.0, 3200, '无', '无', NOW(), NOW()),
(109, 158.0, 48.0, 23, '1', '3', '0', 48.0, 2100, '花生', '无', NOW(), NOW()),
(110, 172.0, 68.0, 31, '0', '1', '0', 68.0, 2200, '无', '糖尿病', NOW(), NOW()),
(111, 170.0, 65.0, 27, '1', '4', '2', 62.0, 2500, '无', '无', NOW(), NOW()),
(112, 182.0, 90.0, 35, '0', '3', '1', 80.0, 2400, '无', '脂肪肝', NOW(), NOW()),
(113, 166.0, 54.0, 26, '1', '3', '0', 54.0, 2000, '无', '无', NOW(), NOW()),
(114, 176.0, 68.0, 29, '0', '4', '0', 68.0, 2600, '无', '无', NOW(), NOW()),
(115, 163.0, 55.0, 28, '1', '2', '0', 55.0, 1850, '无', '无', NOW(), NOW()),
(116, 179.0, 72.0, 30, '0', '3', '2', 77.0, 2900, '无', '无', NOW(), NOW()),
(117, 188.0, 95.0, 27, '0', '4', '2', 100.0, 3500, '无', '无', NOW(), NOW()),
(118, 169.0, 50.0, 24, '1', '3', '0', 50.0, 1950, '无', '无', NOW(), NOW()),
(119, 174.0, 73.0, 33, '0', '3', '2', 78.0, 2850, '无', '无', NOW(), NOW()),
(120, 161.0, 56.0, 28, '1', '1', '1', 52.0, 1650, '无', '无', NOW(), NOW()),
(121, 177.0, 76.0, 26, '0', '4', '2', 82.0, 3100, '无', '无', NOW(), NOW()),
(122, 164.0, 59.0, 25, '1', '2', '0', 59.0, 1900, '坚果', '无', NOW(), NOW()),
(123, 181.0, 82.0, 29, '0', '4', '2', 88.0, 3200, '无', '无', NOW(), NOW()),
(124, 167.0, 53.0, 27, '1', '2', '0', 53.0, 1880, '无', '无', NOW(), NOW()),
(125, 175.0, 70.0, 31, '0', '3', '0', 70.0, 2500, '无', '无', NOW(), NOW()),
(126, 162.0, 57.0, 26, '1', '2', '1', 54.0, 1750, '无', '无', NOW(), NOW()),
(127, 183.0, 80.0, 28, '0', '4', '2', 85.0, 3000, '无', '无', NOW(), NOW()),
(128, 159.0, 62.0, 30, '1', '2', '1', 55.0, 1700, '无', '无', NOW(), NOW()),
(129, 186.0, 88.0, 32, '0', '4', '2', 93.0, 3300, '无', '无', NOW(), NOW()),
(130, 165.0, 60.0, 29, '1', '2', '0', 60.0, 1900, '无', '无', NOW(), NOW());

-- ================================
-- 3. 用户饮食偏好 (30个用户)
-- ================================
INSERT INTO `diet_user_preference` (`user_id`, `preferred_foods`, `disliked_foods`, `cuisine_preferences`, `dietary_restrictions`, `meal_frequency`, `snack_preference`, `spice_level`, `create_time`, `update_time`) VALUES
(101, '["鸡胸肉","西兰花","糙米","鸡蛋"]', '["肥肉","油炸食品"]', '川菜,粤菜', '低脂', 5, '1', '2', NOW(), NOW()),
(102, '["豆腐","蔬菜","水果","坚果"]', '["肉类","海鲜"]', '素食,粤菜', '素食', 4, '1', '0', NOW(), NOW()),
(103, '["鱼肉","蔬菜","全麦面包"]', '["油腻食物"]', '粤菜,淮扬菜', '低盐低脂', 4, '0', '1', NOW(), NOW()),
(104, '["酸奶","水果","沙拉","燕麦"]', '["辛辣食物"]', '西餐,日料', '低糖', 4, '2', '0', NOW(), NOW()),
(105, '["牛肉","鸡蛋","牛奶","坚果"]', '["素食"]', '西餐,川菜', '高蛋白', 6, '2', '2', NOW(), NOW()),
(106, '["鱼","虾","蔬菜","水果"]', '["牛奶","奶制品"]', '粤菜,日料', '无乳制品', 4, '1', '1', NOW(), NOW()),
(107, '["三文鱼","牛油果","藜麦"]', '["油炸食品"]', '西餐,日料', '健康饮食', 4, '1', '1', NOW(), NOW()),
(108, '["鸡胸肉","牛肉","鸡蛋","燕麦"]', '["快餐"]', '西餐', '高蛋白低碳水', 6, '2', '1', NOW(), NOW()),
(109, '["蔬菜沙拉","水果","酸奶"]', '["高热量食物"]', '西餐,日料', '低脂低热量', 5, '2', '0', NOW(), NOW()),
(110, '["鱼肉","蔬菜","粗粮"]', '["甜食","饮料"]', '淮扬菜,粤菜', '低糖低盐', 4, '0', '1', NOW(), NOW()),
(111, '["鸡胸肉","蛋白粉","香蕉"]', '["油腻食物"]', '西餐', '高蛋白', 6, '2', '1', NOW(), NOW()),
(112, '["蔬菜","粗粮","瘦肉"]', '["油炸食品","肥肉"]', '粤菜', '低脂低热量', 4, '0', '1', NOW(), NOW()),
(113, '["沙拉","酸奶","水果","坚果"]', '["重口味"]', '西餐', '健康饮食', 4, '2', '0', NOW(), NOW()),
(114, '["三文鱼","牛肉","蔬菜"]', '["碳水化合物"]', '日料,西餐', '低碳水', 5, '1', '1', NOW(), NOW()),
(115, '["蔬菜","豆制品","水果"]', '["油腻"]', '淮扬菜,粤菜', '清淡饮食', 4, '1', '0', NOW(), NOW()),
(116, '["鸡胸肉","虾","糙米"]', '["甜食"]', '粤菜,日料', '高蛋白', 5, '1', '1', NOW(), NOW()),
(117, '["牛肉","鸡蛋","牛奶","燕麦"]', '["素食"]', '西餐', '高蛋白高热量', 7, '2', '1', NOW(), NOW()),
(118, '["沙拉","酸奶","水果"]', '["油炸"]', '西餐,日料', '低脂', 4, '2', '0', NOW(), NOW()),
(119, '["鸡肉","牛肉","鱼肉"]', '["甜食"]', '川菜,湘菜', '高蛋白', 5, '1', '3', NOW(), NOW()),
(120, '["蔬菜","水果","酸奶"]', '["辛辣"]', '粤菜,淮扬菜', '清淡', 4, '1', '0', NOW(), NOW()),
(121, '["鸡胸肉","鱼肉","蛋白粉"]', '["碳水"]', '西餐', '高蛋白低碳水', 6, '2', '1', NOW(), NOW()),
(122, '["蔬菜","水果","坚果"]', '["油腻"]', '素食', '素食', 4, '2', '1', NOW(), NOW()),
(123, '["牛肉","鸡蛋","牛奶"]', '["素食"]', '西餐', '高蛋白', 6, '2', '1', NOW(), NOW()),
(124, '["沙拉","酸奶","水果"]', '["油炸"]', '西餐', '健康饮食', 4, '2', '0', NOW(), NOW()),
(125, '["鸡肉","鱼肉","蔬菜"]', '["快餐"]', '粤菜', '均衡饮食', 4, '1', '1', NOW(), NOW()),
(126, '["蔬菜","豆制品","水果"]', '["油腻"]', '淮扬菜', '清淡低脂', 4, '1', '0', NOW(), NOW()),
(127, '["牛肉","鸡胸肉","蛋白粉"]', '["甜食"]', '西餐', '高蛋白', 6, '2', '1', NOW(), NOW()),
(128, '["蔬菜","水果","酸奶"]', '["油炸","高热量"]', '粤菜,西餐', '低脂低热量', 4, '1', '0', NOW(), NOW()),
(129, '["鸡胸肉","牛肉","鱼肉"]', '["素食"]', '西餐', '高蛋白高热量', 7, '2', '1', NOW(), NOW()),
(130, '["蔬菜","豆制品","水果"]', '["辛辣"]', '淮扬菜,粤菜', '清淡健康', 4, '1', '0', NOW(), NOW());

-- ================================
-- 4. 生成最近7天的饮食记录 (每个用户每天2-4条记录)
-- meal_type: 0早餐 1午餐 2晚餐 3加餐
-- ================================

-- 用户101的饮食记录
INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) VALUES
(101, '0', '早餐：鸡蛋,全麦面包,牛奶', 450.0, 28.0, 12.0, 52.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(101, '1', '午餐：鸡胸肉,糙米饭,西兰花', 650.0, 45.0, 8.0, 85.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(101, '2', '晚餐：三文鱼,藜麦,蔬菜沙拉', 580.0, 38.0, 18.0, 65.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(101, '3', '加餐：香蕉,蛋白粉', 320.0, 25.0, 2.0, 48.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(101, '0', '早餐：燕麦,鸡蛋,牛奶', 420.0, 26.0, 11.0, 50.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(101, '1', '午餐：牛肉,糙米,西兰花', 720.0, 48.0, 15.0, 82.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(101, '2', '晚餐：鸡胸肉,红薯,蔬菜', 600.0, 42.0, 8.0, 78.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),

(101, '0', '早餐：鸡蛋,全麦面包,酸奶', 480.0, 30.0, 13.0, 55.0, DATE_SUB(CURDATE(), INTERVAL 4 DAY), NOW()),
(101, '1', '午餐：鸡胸肉,意大利面,沙拉', 680.0, 46.0, 10.0, 88.0, DATE_SUB(CURDATE(), INTERVAL 4 DAY), NOW()),
(101, '2', '晚餐：鱼肉,藜麦,蔬菜', 550.0, 40.0, 12.0, 62.0, DATE_SUB(CURDATE(), INTERVAL 4 DAY), NOW()),
(101, '3', '加餐：坚果,香蕉', 280.0, 8.0, 15.0, 32.0, DATE_SUB(CURDATE(), INTERVAL 4 DAY), NOW()),

-- 用户102的饮食记录
(102, '0', '早餐：豆浆,全麦面包,水果', 350.0, 15.0, 8.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(102, '1', '午餐：豆腐,蔬菜,糙米', 480.0, 22.0, 10.0, 72.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(102, '2', '晚餐：素炒时蔬,豆制品', 420.0, 18.0, 12.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(102, '0', '早餐：燕麦,水果,坚果', 380.0, 12.0, 14.0, 52.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(102, '1', '午餐：蔬菜沙拉,豆腐,糙米', 450.0, 20.0, 11.0, 65.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(102, '2', '晚餐：素食汤,蔬菜', 380.0, 15.0, 8.0, 55.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(102, '3', '加餐：水果,酸奶', 200.0, 6.0, 4.0, 35.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),

-- 用户103的饮食记录
(103, '0', '早餐：鸡蛋,燕麦,牛奶', 420.0, 25.0, 12.0, 48.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(103, '1', '午餐：鱼肉,糙米,蔬菜', 550.0, 38.0, 10.0, 68.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(103, '2', '晚餐：鸡胸肉,红薯,沙拉', 520.0, 40.0, 8.0, 62.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(103, '0', '早餐：全麦面包,鸡蛋,豆浆', 400.0, 22.0, 10.0, 52.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(103, '1', '午餐：鱼肉,藜麦,西兰花', 580.0, 42.0, 12.0, 65.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),
(103, '2', '晚餐：鸡胸肉,蔬菜,粗粮', 500.0, 38.0, 8.0, 60.0, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NOW()),

-- 用户104-108的饮食记录
(104, '0', '早餐：酸奶,水果,全麦面包', 380.0, 16.0, 8.0, 62.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(104, '1', '午餐：鸡胸肉,沙拉,糙米', 520.0, 38.0, 10.0, 65.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(104, '2', '晚餐：鱼肉,蔬菜,红薯', 480.0, 35.0, 12.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(105, '0', '早餐：鸡蛋,牛奶,燕麦', 520.0, 32.0, 15.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(105, '1', '午餐：牛肉,糙米,西兰花', 780.0, 52.0, 18.0, 88.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(105, '2', '晚餐：鸡胸肉,红薯,蔬菜', 680.0, 48.0, 12.0, 82.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(105, '3', '加餐：蛋白粉,香蕉', 380.0, 30.0, 3.0, 52.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(106, '0', '早餐：燕麦,水果,豆浆', 350.0, 14.0, 8.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(106, '1', '午餐：鱼肉,糙米,蔬菜', 480.0, 35.0, 10.0, 62.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(106, '2', '晚餐：鸡胸肉,沙拉', 420.0, 38.0, 8.0, 45.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(107, '0', '早餐：三文鱼,全麦面包', 450.0, 28.0, 18.0, 42.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(107, '1', '午餐：鸡胸肉,藜麦,蔬菜', 520.0, 42.0, 10.0, 58.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(107, '2', '晚餐：虾,沙拉,红薯', 480.0, 36.0, 8.0, 62.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),

(108, '0', '早餐：鸡蛋,燕麦,牛奶', 580.0, 38.0, 16.0, 65.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(108, '1', '午餐：牛肉,糙米,西兰花', 820.0, 58.0, 20.0, 92.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(108, '2', '晚餐：鸡胸肉,红薯,蔬菜', 720.0, 52.0, 14.0, 85.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW()),
(108, '3', '加餐：蛋白粉,香蕉,坚果', 420.0, 32.0, 12.0, 48.0, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NOW());

-- 为其余用户生成至少一天的饮食记录
INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) 
SELECT 
    u.user_id,
    '0' as meal_type,
    '早餐：鸡蛋,全麦面包,牛奶' as notes,
    420.0 + (RAND() * 80) as total_calories,
    25.0 + (RAND() * 10) as total_protein,
    12.0 + (RAND() * 6) as total_fat,
    50.0 + (RAND() * 20) as total_carbohydrate,
    DATE_SUB(CURDATE(), INTERVAL 1 DAY) as record_date,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 109 AND 130;

INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) 
SELECT 
    u.user_id,
    '1' as meal_type,
    '午餐：鸡胸肉,糙米,蔬菜' as notes,
    580.0 + (RAND() * 120) as total_calories,
    40.0 + (RAND() * 15) as total_protein,
    10.0 + (RAND() * 8) as total_fat,
    68.0 + (RAND() * 25) as total_carbohydrate,
    DATE_SUB(CURDATE(), INTERVAL 1 DAY) as record_date,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 109 AND 130;

INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) 
SELECT 
    u.user_id,
    '2' as meal_type,
    '晚餐：鱼肉,红薯,沙拉' as notes,
    520.0 + (RAND() * 100) as total_calories,
    38.0 + (RAND() * 12) as total_protein,
    10.0 + (RAND() * 6) as total_fat,
    62.0 + (RAND() * 20) as total_carbohydrate,
    DATE_SUB(CURDATE(), INTERVAL 1 DAY) as record_date,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 109 AND 130;

-- 今天的记录
INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) 
SELECT 
    u.user_id,
    '0' as meal_type,
    '早餐：燕麦,鸡蛋,酸奶' as notes,
    400.0 + (RAND() * 100) as total_calories,
    22.0 + (RAND() * 12) as total_protein,
    10.0 + (RAND() * 8) as total_fat,
    48.0 + (RAND() * 22) as total_carbohydrate,
    CURDATE() as record_date,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 101 AND 130;

INSERT INTO `diet_record` (`user_id`, `meal_type`, `notes`, `total_calories`, `total_protein`, `total_fat`, `total_carbohydrate`, `record_date`, `create_time`) 
SELECT 
    u.user_id,
    '1' as meal_type,
    CASE 
        WHEN MOD(u.user_id, 3) = 0 THEN '午餐：牛肉,糙米,西兰花'
        WHEN MOD(u.user_id, 3) = 1 THEN '午餐：鸡胸肉,藜麦,蔬菜沙拉'
        ELSE '午餐：三文鱼,红薯,蔬菜'
    END as notes,
    620.0 + (RAND() * 150) as total_calories,
    42.0 + (RAND() * 18) as total_protein,
    12.0 + (RAND() * 10) as total_fat,
    72.0 + (RAND() * 28) as total_carbohydrate,
    CURDATE() as record_date,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 101 AND 130;

-- ================================
-- 5. 生成推荐记录
-- ================================
INSERT INTO `diet_recommendation` (`user_id`, `recommendation_date`, `meal_type`, `target_calories`, `target_protein`, `target_fat`, `target_carbohydrate`, `recommended_foods`, `recommendation_reason`, `algorithm_type`, `score`, `is_accepted`, `create_time`) 
SELECT 
    u.user_id,
    CURDATE() as recommendation_date,
    '1' as meal_type,
    600.0 + (RAND() * 200) as target_calories,
    40.0 + (RAND() * 15) as target_protein,
    15.0 + (RAND() * 10) as target_fat,
    70.0 + (RAND() * 30) as target_carbohydrate,
    '鸡胸肉,糙米饭,西兰花,胡萝卜' as recommended_foods,
    '根据您的健康目标和今日营养摄入情况，为您推荐均衡的午餐搭配' as recommendation_reason,
    'ML智能推荐' as algorithm_type,
    85.0 + (RAND() * 12) as score,
    CASE WHEN RAND() > 0.3 THEN '1' ELSE '0' END as is_accepted,
    NOW() as create_time
FROM sys_user u 
WHERE u.user_id BETWEEN 101 AND 130;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================
-- 数据验证
-- ================================
SELECT '用户数据统计' as info;
SELECT COUNT(*) as user_count FROM sys_user WHERE user_id >= 101;

SELECT '健康信息统计' as info;
SELECT COUNT(*) as health_count FROM sys_user_health WHERE user_id >= 101;

SELECT '饮食记录统计' as info;
SELECT COUNT(*) as record_count FROM diet_record WHERE user_id >= 101;

SELECT '推荐记录统计' as info;
SELECT COUNT(*) as recommendation_count FROM diet_recommendation WHERE user_id >= 101;

SELECT '最近7天活跃用户统计' as info;
SELECT COUNT(DISTINCT user_id) as active_users 
FROM diet_record 
WHERE user_id >= 101 
AND record_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);

