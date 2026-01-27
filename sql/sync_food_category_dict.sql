-- 同步食物分类到系统字典

-- ====================================
-- 1. 创建或更新食物分类字典类型
-- ====================================

-- 插入或更新字典类型
INSERT INTO `sys_dict_type` (`dict_id`, `dict_name`, `dict_type`, `status`, `create_by`, `create_time`, `remark`) 
VALUES (100, '食物分类', 'food_category', '0', 'admin', NOW(), '食物分类列表')
ON DUPLICATE KEY UPDATE 
    dict_name = VALUES(dict_name),
    status = VALUES(status),
    update_by = 'admin',
    update_time = NOW();

-- ====================================
-- 2. 清空并重新插入字典数据
-- ====================================

-- 删除现有的食物分类字典数据
DELETE FROM `sys_dict_data` WHERE `dict_type` = 'food_category';

-- 插入主分类字典数据
INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
(1001, 1, '谷物主食', '1', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '主食类食物'),
(1002, 2, '蔬菜类', '2', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '蔬菜类食物'),
(1003, 3, '水果类', '3', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '水果类食物'),
(1004, 4, '肉禽蛋类', '4', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '肉禽蛋类食物'),
(1005, 5, '水产海鲜', '5', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '水产海鲜类食物'),
(1006, 6, '豆制品', '6', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '豆制品类食物'),
(1007, 7, '奶制品', '7', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '奶制品类食物'),
(1008, 8, '坚果类', '8', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '坚果类食物'),
(1009, 9, '油脂类', '9', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '油脂类食物'),
(1010, 10, '调料类', '10', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '调料类食物'),
(1011, 11, '饮品类', '11', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '饮品类食物'),
(1012, 12, '零食类', '12', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '零食类食物');

-- 插入子分类字典数据（主要的子分类）
INSERT INTO `sys_dict_data` (`dict_code`, `dict_sort`, `dict_label`, `dict_value`, `dict_type`, `css_class`, `list_class`, `is_default`, `status`, `create_by`, `create_time`, `remark`) VALUES
-- 谷物主食子分类
(1101, 11, '米面类', '101', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '米面类主食'),
(1102, 12, '粗粮类', '102', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '粗粮类主食'),
(1103, 13, '薯类', '103', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '薯类主食'),

-- 蔬菜类子分类
(1201, 21, '叶菜类', '201', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '叶菜类蔬菜'),
(1202, 22, '根茎类', '202', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '根茎类蔬菜'),
(1203, 23, '瓜果类', '203', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '瓜果类蔬菜'),
(1204, 24, '菌菇类', '204', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '菌菇类蔬菜'),

-- 水果类子分类
(1301, 31, '热带水果', '301', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '热带水果'),
(1302, 32, '温带水果', '302', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '温带水果'),
(1303, 33, '浆果类', '303', 'food_category', '', 'info', 'N', '0', 'admin', NOW(), '浆果类水果'),

-- 肉禽蛋类子分类
(1401, 41, '猪肉类', '401', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '猪肉类'),
(1402, 42, '牛肉类', '402', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '牛肉类'),
(1403, 43, '羊肉类', '403', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '羊肉类'),
(1404, 44, '禽肉类', '404', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '禽肉类'),
(1405, 45, '蛋类', '405', 'food_category', '', 'warning', 'N', '0', 'admin', NOW(), '蛋类'),

-- 水产海鲜子分类
(1501, 51, '淡水鱼', '501', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '淡水鱼类'),
(1502, 52, '海水鱼', '502', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '海水鱼类'),
(1503, 53, '贝类', '503', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '贝类'),
(1504, 54, '虾蟹类', '504', 'food_category', '', 'danger', 'N', '0', 'admin', NOW(), '虾蟹类'),

-- 豆制品子分类
(1601, 61, '大豆制品', '601', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '大豆制品'),
(1602, 62, '其他豆类', '602', 'food_category', '', 'default', 'N', '0', 'admin', NOW(), '其他豆类'),

-- 奶制品子分类
(1701, 71, '液态奶', '701', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '液态奶制品'),
(1702, 72, '酸奶', '702', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '酸奶制品'),
(1703, 73, '奶酪', '703', 'food_category', '', 'primary', 'N', '0', 'admin', NOW(), '奶酪制品'),

-- 坚果类子分类
(1801, 81, '树坚果', '801', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '树坚果类'),
(1802, 82, '种子类', '802', 'food_category', '', 'success', 'N', '0', 'admin', NOW(), '种子类');

-- ====================================
-- 3. 验证字典数据
-- ====================================

-- 查看字典类型
SELECT * FROM `sys_dict_type` WHERE `dict_type` = 'food_category';

-- 查看字典数据
SELECT 
    dict_code,
    dict_sort,
    dict_label,
    dict_value,
    list_class,
    status
FROM `sys_dict_data` 
WHERE `dict_type` = 'food_category' 
ORDER BY dict_sort;

-- ====================================
-- 4. 更新现有食物的分类字段
-- ====================================

-- 注意：前端使用的是categoryId字段，需要确保数据库字段名匹配
-- 如果前端使用的是category字段，需要添加该字段或修改前端

-- 检查食物表结构
DESCRIBE diet_food_info;

-- 如果需要添加category字段映射到categoryId
-- ALTER TABLE diet_food_info ADD COLUMN category varchar(10) COMMENT '分类编码' AFTER category_id;
-- UPDATE diet_food_info SET category = CAST(category_id AS CHAR) WHERE category_id IS NOT NULL;

SELECT 'Food category dictionary synchronization completed!' as status;
