USE smart_diet_dev;
-- 修正重名：2121 和 2006 都叫"健康目标"，但2121指向diet/health/userHealthList，改名为"健康管理"
UPDATE sys_menu SET menu_name = '健康管理' WHERE menu_id = 2121;
