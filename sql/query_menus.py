import pymysql

conn = pymysql.connect(
    host='localhost', port=3306, user='root', password='1234', database='smart_diet_dev', ssl_disabled=True
)
cursor = conn.cursor(pymysql.cursors.DictCursor)
cursor.execute("SELECT menu_id, menu_name, parent_id, path, component, visible, perms FROM sys_menu WHERE menu_name LIKE '%ML%' OR menu_name LIKE '%推荐%' OR menu_name LIKE '%目标%' OR menu_name LIKE '%图谱%' OR path LIKE '%recognition%' OR path LIKE '%ml%';")
rows = cursor.fetchall()
for row in rows:
    print(row)
cursor.close()
conn.close()
