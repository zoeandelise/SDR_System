-- ================================
-- 隐藏与毕设无关的菜单模块
-- ================================
-- 功能：精简系统菜单，只保留饮食推荐相关功能
-- 项目：基于机器学习的个性化健康饮食推荐系统
-- ================================

USE smart_diet_dev;

-- 查看隐藏前的菜单结构
SELECT '========== 隐藏前的一级菜单 ==========' AS '操作';
SELECT 
    menu_id AS '菜单ID',
    menu_name AS '菜单名称',
    order_num AS '排序',
    visible AS '可见性',
    CASE visible 
        WHEN '0' THEN '显示'
        WHEN '1' THEN '隐藏'
    END AS '状态'
FROM sys_menu
WHERE parent_id = 0
ORDER BY order_num;

-- ================================
-- 隐藏系统监控模块（全部）
-- ================================
-- 包含：在线用户、定时任务、数据监控、服务监控、缓存监控等

UPDATE sys_menu 
SET visible = '1', 
    update_time = NOW() 
WHERE menu_id = 2;  -- 系统监控

SELECT '✓ 已隐藏：系统监控模块' AS '操作结果';

-- ================================
-- 隐藏系统工具模块（全部）
-- ================================
-- 包含：表单构建、代码生成、系统接口(Swagger)

UPDATE sys_menu 
SET visible = '1',
    update_time = NOW()
WHERE menu_id = 3;  -- 系统工具

SELECT '✓ 已隐藏：系统工具模块' AS '操作结果';

-- ================================
-- 隐藏若依官网链接
-- ================================

UPDATE sys_menu 
SET visible = '1',
    update_time = NOW()
WHERE menu_id = 4;  -- 若依官网

SELECT '✓ 已隐藏：若依官网链接' AS '操作结果';

-- ================================
-- 隐藏系统管理中不相关的子菜单
-- ================================

-- 隐藏部门管理（不需要）
UPDATE sys_menu 
SET visible = '1',
    update_time = NOW()
WHERE menu_id = 103;  -- 部门管理

-- 隐藏岗位管理（不需要）
UPDATE sys_menu 
SET visible = '1',
    update_time = NOW()
WHERE menu_id = 104;  -- 岗位管理

-- 隐藏通知公告（不需要）
UPDATE sys_menu 
SET visible = '1',
    update_time = NOW()
WHERE menu_id = 107;  -- 通知公告

-- 可选：隐藏字典管理和参数设置（如果确定不需要）
-- UPDATE sys_menu SET visible = '1' WHERE menu_id IN (105, 106);

SELECT '✓ 已隐藏：部门管理、岗位管理、通知公告' AS '操作结果';

-- ================================
-- 验证隐藏结果
-- ================================

SELECT '========== 隐藏后的一级菜单 ==========' AS '验证';
SELECT 
    menu_id AS '菜单ID',
    menu_name AS '菜单名称',
    order_num AS '排序',
    CASE visible 
        WHEN '0' THEN '✓ 显示'
        WHEN '1' THEN '✗ 隐藏'
    END AS '状态',
    CASE visible
        WHEN '0' THEN '保留'
        WHEN '1' THEN '已隐藏'
    END AS '备注'
FROM sys_menu
WHERE parent_id = 0
ORDER BY order_num;

-- 查看精简后的菜单结构
SELECT '========== 精简后可见的菜单结构 ==========' AS '结果';
SELECT 
    CONCAT(REPEAT('  ', CASE WHEN parent_id=0 THEN 0 ELSE 1 END), menu_name) AS '菜单结构',
    path AS '路径',
    CASE visible WHEN '0' THEN '显示' ELSE '隐藏' END AS '状态'
FROM sys_menu
WHERE visible = '0'
  AND menu_type IN ('M', 'C')
ORDER BY order_num, parent_id;

-- 统计
SELECT '========== 精简统计 ==========' AS '统计';
SELECT 
    '原菜单总数' AS '项目',
    COUNT(*) AS '数量'
FROM sys_menu WHERE parent_id = 0
UNION ALL
SELECT 
    '保留菜单数',
    COUNT(*)
FROM sys_menu WHERE parent_id = 0 AND visible = '0'
UNION ALL
SELECT 
    '隐藏菜单数',
    COUNT(*)
FROM sys_menu WHERE parent_id = 0 AND visible = '1';

SELECT '✓ 菜单精简完成！刷新前端页面查看效果' AS '完成提示';

