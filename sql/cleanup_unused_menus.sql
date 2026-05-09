-- 删除没有后端支持的孤儿菜单：用户管理(饮食方向)、系统统计、用户画像
DELETE FROM sys_menu WHERE path IN ('admin-users', 'admin-stats', 'profile') AND component LIKE 'diet/%';
COMMIT;
