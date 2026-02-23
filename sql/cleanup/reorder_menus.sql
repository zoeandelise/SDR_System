-- ================================
-- 导航栏菜单重排脚本
-- ================================
-- 功能：饮食管理提到最前，系统管理后移，隐藏无关菜单
-- 项目：基于机器学习的个性化健康饮食推荐系统
-- ================================

USE smart_diet_dev;

-- ========== 1. 调整一级菜单排序 ==========

-- 饮食管理提到最前面 (order_num = 1)
UPDATE sys_menu SET order_num = 1 WHERE menu_id = 2000;

-- 系统管理放到后面 (order_num = 10)
UPDATE sys_menu SET order_num = 10 WHERE menu_id = 1;

-- ========== 2. 隐藏不需要的菜单 ==========

-- 隐藏系统监控 (menu_id = 2)
UPDATE sys_menu SET visible = '1' WHERE menu_id = 2;

-- 隐藏系统工具 (menu_id = 3)
UPDATE sys_menu SET visible = '1' WHERE menu_id = 3;

-- 隐藏若依官网 (menu_id = 4)
UPDATE sys_menu SET visible = '1' WHERE menu_id = 4;

-- ========== 3. 验证结果 ==========
SELECT 
    menu_id AS '菜单ID',
    menu_name AS '菜单名称',
    order_num AS '排序',
    visible AS '可见性(0=可见,1=隐藏)'
FROM sys_menu 
WHERE parent_id = 0 
ORDER BY order_num;
