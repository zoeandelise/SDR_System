-- ===============================================
-- 饮食打卡管理菜单 SQL 脚本
-- 请在数据库连接工具中执行此脚本，或确保系统自动加载
-- ===============================================

-- 假设“饮食管理”模块的 parent_id 存在且已知，下面插入“打卡记录”菜单（以 2026 为主键示例，如主键冲突请自动调整）
-- 如果没有统一的“饮食管理”父菜单，则挂载在顶级或普通业务菜单下，这里设 parent_id = 2000 作为一个挂载点。
-- 如果 sys_menu 主键为自增，请去除 id 字段。

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('打卡记录', 2000, 3, 'checkin', 'diet/checkin/index', 1, 0, 'C', '0', '0', 'diet:checkin:list', 'date', 'admin', sysdate(), '', null, '饮食打卡记录菜单');

-- 按钮权限
SELECT @last_id := LAST_INSERT_ID();

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES 
('饮食打卡查询', @last_id, 1,  '', '', 1, 0, 'F', '0', '0', 'diet:checkin:query',  '#', 'admin', sysdate(), '', null, ''),
('饮食打卡删除', @last_id, 2,  '', '', 1, 0, 'F', '0', '0', 'diet:checkin:remove', '#', 'admin', sysdate(), '', null, ''),
('饮食打卡导出', @last_id, 3,  '', '', 1, 0, 'F', '0', '0', 'diet:checkin:export', '#', 'admin', sysdate(), '', null, '');
