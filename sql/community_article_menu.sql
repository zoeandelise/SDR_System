-- 社区管理和科普资讯管理菜单初始化
-- 在饮食管理(2000)下新增两个菜单

-- 社区帖子管理（菜单ID: 2008）
INSERT IGNORE INTO sys_menu VALUES('2008', '社区管理', '2000', '8', 'community', 'diet/community/index', '', '', 1, 0, 'C', '0', '0', 'diet:community:list', 'peoples', 'admin', sysdate(), '', null, '社区帖子管理菜单');

-- 科普资讯管理（菜单ID: 2009）
INSERT IGNORE INTO sys_menu VALUES('2009', '科普资讯', '2000', '9', 'article', 'diet/article/index', '', '', 1, 0, 'C', '0', '0', 'diet:article:list', 'education', 'admin', sysdate(), '', null, '科普资讯管理菜单');

-- 为超级管理员角色分配新菜单权限
INSERT IGNORE INTO sys_role_menu VALUES('1', '2008');
INSERT IGNORE INTO sys_role_menu VALUES('1', '2009');

COMMIT;
