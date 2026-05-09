import pymysql

conn = pymysql.connect(
    host='localhost', port=3306, user='root', password='1234', database='smart_diet_dev', ssl_disabled=True
)
cursor = conn.cursor()

try:
    # Insert ML Management
    cursor.execute("""
        INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
        VALUES ('ML推荐管理', 2000, 6, 'ml', 'diet/ml/management', 1, 0, 'C', '0', '0', 'diet:ml:list', 'tree-table', 'admin', sysdate(), 'ML推荐模型监控中台')
    """)
    print("Inserted ML Management")

    # Insert AI Recognition
    cursor.execute("""
        INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
        VALUES ('AI图谱测试工作台', 2000, 7, 'recognition', 'diet/recognition/index', 1, 0, 'C', '0', '0', 'diet:recognition:list', 'camera', 'admin', sysdate(), 'AI图谱校验工作站')
    """)
    print("Inserted AI Recognition Workbench")

    conn.commit()
    print("Database updated successfully.")
except Exception as e:
    print(f"Error: {e}")
    conn.rollback()
finally:
    cursor.close()
    conn.close()
