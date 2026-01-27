-- 健康饮食推荐系统菜单初始化脚本
-- 添加饮食管理主菜单和相关子菜单

-- 1. 添加饮食管理主菜单 (一级菜单)
INSERT INTO sys_menu VALUES('2000', '饮食管理', '0', '5', 'diet', null, '', '', 1, 0, 'M', '0', '0', '', 'shopping', 'admin', sysdate(), '', null, '饮食管理目录');

-- 2. 添加二级菜单
-- 2.1 饮食仪表盘
INSERT INTO sys_menu VALUES('2001', '饮食仪表盘', '2000', '1', 'dashboard', 'diet/dashboard/index', '', '', 1, 0, 'C', '0', '0', 'diet:dashboard:view', 'dashboard', 'admin', sysdate(), '', null, '饮食仪表盘菜单');

-- 2.2 饮食记录管理
INSERT INTO sys_menu VALUES('2002', '饮食记录', '2000', '2', 'record', 'diet/record/index', '', '', 1, 0, 'C', '0', '0', 'diet:record:list', 'documentation', 'admin', sysdate(), '', null, '饮食记录菜单');

-- 2.3 食物库管理
INSERT INTO sys_menu VALUES('2003', '食物库', '2000', '3', 'food', 'diet/food/index', '', '', 1, 0, 'C', '0', '0', 'diet:food:list', 'component', 'admin', sysdate(), '', null, '食物库管理菜单');

-- 2.4 营养分析
INSERT INTO sys_menu VALUES('2004', '营养分析', '2000', '4', 'analysis', 'diet/analysis/index', '', '', 1, 0, 'C', '0', '0', 'diet:analysis:view', 'chart', 'admin', sysdate(), '', null, '营养分析菜单');

-- 2.5 推荐方案
INSERT INTO sys_menu VALUES('2005', '推荐方案', '2000', '5', 'recommendation', 'diet/recommendation/index', '', '', 1, 0, 'C', '0', '0', 'diet:recommendation:list', 'star', 'admin', sysdate(), '', null, '推荐方案菜单');

-- 2.6 健康目标
INSERT INTO sys_menu VALUES('2006', '健康目标', '2000', '6', 'goal', 'diet/goal/index', '', '', 1, 0, 'C', '0', '0', 'diet:goal:list', 'skill', 'admin', sysdate(), '', null, '健康目标管理菜单');

-- 2.7 用户画像
INSERT INTO sys_menu VALUES('2007', '用户画像', '2000', '7', 'profile', 'diet/profile/index', '', '', 1, 0, 'C', '0', '0', 'diet:profile:view', 'peoples', 'admin', sysdate(), '', null, '用户画像菜单');

-- 3. 添加饮食记录管理的功能按钮 (三级菜单)
-- 3.1 饮食记录按钮
INSERT INTO sys_menu VALUES('2100', '饮食记录查询', '2002', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:query', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2101', '饮食记录新增', '2002', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:add', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2102', '饮食记录修改', '2002', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:edit', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2103', '饮食记录删除', '2002', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:remove', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2104', '饮食记录导出', '2002', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:export', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2105', '食物识别', '2002', '6', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:record:recognize', '#', 'admin', sysdate(), '', null, '');

-- 3.2 食物库按钮
INSERT INTO sys_menu VALUES('2106', '食物查询', '2003', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:query', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2107', '食物新增', '2003', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:add', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2108', '食物修改', '2003', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:edit', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2109', '食物删除', '2003', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:remove', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2110', '食物导出', '2003', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:export', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2111', '食物导入', '2003', '6', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:food:import', '#', 'admin', sysdate(), '', null, '');

-- 3.3 推荐方案按钮
INSERT INTO sys_menu VALUES('2112', '推荐查询', '2005', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:recommendation:query', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2113', '推荐生成', '2005', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:recommendation:generate', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2114', '推荐修改', '2005', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:recommendation:edit', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2115', '推荐删除', '2005', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:recommendation:remove', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2116', '推荐导出', '2005', '5', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:recommendation:export', '#', 'admin', sysdate(), '', null, '');

-- 3.4 健康目标按钮
INSERT INTO sys_menu VALUES('2117', '目标查询', '2006', '1', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:goal:query', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2118', '目标新增', '2006', '2', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:goal:add', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2119', '目标修改', '2006', '3', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:goal:edit', '#', 'admin', sysdate(), '', null, '');
INSERT INTO sys_menu VALUES('2120', '目标删除', '2006', '4', '', '', '', '', 1, 0, 'F', '0', '0', 'diet:goal:remove', '#', 'admin', sysdate(), '', null, '');

-- 4. 为超级管理员角色分配所有饮食管理权限
INSERT INTO sys_role_menu SELECT '1', menu_id FROM sys_menu WHERE menu_id >= 2000 AND menu_id <= 2120;

-- 5. 添加字典类型和字典数据
-- 餐次类型字典
INSERT INTO sys_dict_type VALUES(11, '餐次类型', 'diet_meal_type', '0', 'admin', sysdate(), '', null, '饮食记录餐次类型');

INSERT INTO sys_dict_data VALUES(41, 1, '早餐', '0', 'diet_meal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '早餐');
INSERT INTO sys_dict_data VALUES(42, 2, '午餐', '1', 'diet_meal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '午餐');
INSERT INTO sys_dict_data VALUES(43, 3, '晚餐', '2', 'diet_meal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '晚餐');
INSERT INTO sys_dict_data VALUES(44, 4, '加餐', '3', 'diet_meal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '加餐/零食');

-- 健康目标类型字典
INSERT INTO sys_dict_type VALUES(12, '健康目标类型', 'diet_goal_type', '0', 'admin', sysdate(), '', null, '健康目标类型');

INSERT INTO sys_dict_data VALUES(45, 1, '减重', 'weight_loss', 'diet_goal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '减重目标');
INSERT INTO sys_dict_data VALUES(46, 2, '增重', 'weight_gain', 'diet_goal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '增重目标');
INSERT INTO sys_dict_data VALUES(47, 3, '维持', 'maintain', 'diet_goal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '维持体重');
INSERT INTO sys_dict_data VALUES(48, 4, '增肌', 'muscle_gain', 'diet_goal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '增肌目标');
INSERT INTO sys_dict_data VALUES(49, 5, '降脂', 'fat_loss', 'diet_goal_type', '', '', 'Y', '0', 'admin', sysdate(), '', null, '降脂目标');

-- 活动水平字典
INSERT INTO sys_dict_type VALUES(13, '活动水平', 'diet_activity_level', '0', 'admin', sysdate(), '', null, '用户活动水平');

INSERT INTO sys_dict_data VALUES(50, 1, '久坐', 'sedentary', 'diet_activity_level', '', '', 'Y', '0', 'admin', sysdate(), '', null, '久坐不动');
INSERT INTO sys_dict_data VALUES(51, 2, '轻度活动', 'light', 'diet_activity_level', '', '', 'Y', '0', 'admin', sysdate(), '', null, '轻度活动');
INSERT INTO sys_dict_data VALUES(52, 3, '中度活动', 'moderate', 'diet_activity_level', '', '', 'Y', '0', 'admin', sysdate(), '', null, '中度活动');
INSERT INTO sys_dict_data VALUES(53, 4, '重度活动', 'active', 'diet_activity_level', '', '', 'Y', '0', 'admin', sysdate(), '', null, '重度活动');
INSERT INTO sys_dict_data VALUES(54, 5, '极重度活动', 'very_active', 'diet_activity_level', '', '', 'Y', '0', 'admin', sysdate(), '', null, '极重度活动');

COMMIT;
