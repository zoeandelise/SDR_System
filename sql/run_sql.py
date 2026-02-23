import pymysql

conn = pymysql.connect(
    host='localhost',
    port=3306,
    user='root',
    password='1234',
    database='smart_diet_dev',
    ssl_disabled=True
)
cursor = conn.cursor()

# 1. 饮食管理提到最前面
cursor.execute("UPDATE sys_menu SET order_num = 1 WHERE menu_id = 2000")
print(f"饮食管理(2000) order_num -> 1, affected: {cursor.rowcount}")

# 2. 系统管理放到后面
cursor.execute("UPDATE sys_menu SET order_num = 10 WHERE menu_id = 1")
print(f"系统管理(1) order_num -> 10, affected: {cursor.rowcount}")

# 3. 隐藏系统监控
cursor.execute("UPDATE sys_menu SET visible = '1' WHERE menu_id = 2")
print(f"系统监控(2) visible -> 1, affected: {cursor.rowcount}")

# 4. 隐藏系统工具
cursor.execute("UPDATE sys_menu SET visible = '1' WHERE menu_id = 3")
print(f"系统工具(3) visible -> 1, affected: {cursor.rowcount}")

# 5. 隐藏若依官网
cursor.execute("UPDATE sys_menu SET visible = '1' WHERE menu_id = 4")
print(f"若依官网(4) visible -> 1, affected: {cursor.rowcount}")

conn.commit()

# 验证结果
cursor.execute("SELECT menu_id, menu_name, order_num, visible FROM sys_menu WHERE parent_id = 0 ORDER BY order_num")
print("\n=== 一级菜单排序结果 ===")
for row in cursor.fetchall():
    vis = "可见" if row[3] == '0' else "隐藏"
    print(f"  ID={row[0]}, 名称={row[1]}, 排序={row[2]}, {vis}")

cursor.close()
conn.close()
print("\n完成！")
