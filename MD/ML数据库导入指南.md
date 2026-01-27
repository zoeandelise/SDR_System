# ML推荐系统数据库导入指南

## 📋 需要导入的SQL文件

1. `sql/ml_system_tables.sql` - 创建4个ML相关表
2. `sql/init_ml_data.sql` - 初始化ML数据

---

## 🔧 方法1：使用MySQL Workbench（推荐）

### 步骤：

1. **打开MySQL Workbench**

2. **连接数据库**
   - 点击已保存的连接，或新建连接
   - 主机: localhost
   - 端口: 3306
   - 用户名: root
   - 密码: （您的MySQL密码）

3. **选择数据库**
   - 在左侧Schema列表中，双击 `smart_diet_dev`
   - 或执行: `USE smart_diet_dev;`

4. **导入第一个SQL文件**
   - 点击菜单: `File` → `Open SQL Script...`
   - 选择: `E:\study\毕设\SDR_System\sql\ml_system_tables.sql`
   - 点击工具栏的 ⚡ 图标（Execute）或按 `Ctrl+Shift+Enter`
   - 等待执行完成，查看 `Output` 窗口确认成功

5. **导入第二个SQL文件**
   - 点击菜单: `File` → `Open SQL Script...`
   - 选择: `E:\study\毕设\SDR_System\sql\init_ml_data.sql`
   - 点击 ⚡ 执行
   - 等待完成，应该看到统计信息

6. **验证导入成功**
   - 执行以下SQL查看数据：
   ```sql
   SELECT '模型信息' as 表, COUNT(*) as 记录数 FROM ml_model_info
   UNION ALL
   SELECT '推荐统计', COUNT(*) FROM ml_recommendation_stats
   UNION ALL
   SELECT '服务状态', COUNT(*) FROM ml_service_status
   UNION ALL
   SELECT '训练历史', COUNT(*) FROM ml_training_history;
   ```
   - 预期结果：
     - 模型信息: 3条
     - 推荐统计: 28条（7天×4算法）
     - 服务状态: 1条
     - 训练历史: 0条

---

## 🔧 方法2：使用命令行（如果可用）

### 前提条件
MySQL配置中SSL不是必需的，或已正确配置SSL

### 执行步骤：

```bash
# 进入项目目录
cd E:\study\毕设\SDR_System

# 执行批处理文件
.\import_ml_tables.bat

# 或手动执行
mysql -u root -p smart_diet_dev < sql/ml_system_tables.sql
mysql -u root -p smart_diet_dev < sql/init_ml_data.sql
```

---

## ✅ 验证清单

导入完成后，在MySQL中验证：

### 1. 检查表是否创建
```sql
SHOW TABLES LIKE 'ml_%';
```
预期结果：4个表
- ml_model_info
- ml_training_history  
- ml_recommendation_stats
- ml_service_status

### 2. 检查模型记录
```sql
SELECT model_name, model_type, is_loaded FROM ml_model_info;
```
预期结果：3条记录
| model_name | model_type | is_loaded |
|------------|------------|-----------|
| 协同过滤模型 | collaborative_filtering | 0 |
| 内容推荐模型 | content_based | 0 |
| 深度学习模型 | deep_learning | 0 |

### 3. 检查推荐统计
```sql
SELECT 
    stat_date,
    algorithm_type,
    total_recommendations,
    acceptance_rate,
    active_users
FROM ml_recommendation_stats
ORDER BY stat_date DESC, algorithm_type
LIMIT 10;
```
预期结果：至少28条记录（7天×4算法）

### 4. 检查diet_recommendation表字段
```sql
DESCRIBE diet_recommendation;
```
确认包含以下字段：
- confidence_score
- applied_flag
- response_time

---

## ❌ 常见问题

### 问题1：SSL连接错误
```
ERROR 2026 (HY000): SSL connection error
```
**解决方案**: 使用MySQL Workbench GUI导入

### 问题2：表已存在
```
ERROR 1050 (42S01): Table 'xxx' already exists
```
**解决方案**: 
- 正常！脚本使用`CREATE TABLE IF NOT EXISTS`
- 不影响使用

### 问题3：字段已存在
```
ERROR 1060 (42S21): Duplicate column name 'xxx'
```
**解决方案**:
- 正常！脚本使用`ADD COLUMN IF NOT EXISTS`
- 不影响使用

### 问题4：数据重复插入
```
Duplicate entry for key 'uk_date_algorithm'
```
**解决方案**:
- 正常！脚本使用`ON DUPLICATE KEY UPDATE`
- 会更新现有数据

---

## 🎯 导入成功标志

看到以下输出表示成功：

```
ML系统数据表创建完成

模型信息: 3
推荐统计记录: 28+
服务状态记录: 1
更新的推荐记录: (根据现有数据)
```

---

## 🚀 导入后下一步

1. ✅ 关闭MySQL Workbench
2. ✅ 启动后端服务
3. ✅ 访问 `http://localhost:81/diet/ml/management`
4. ✅ 查看真实数据展示

---

**创建时间**: 2025-10-10 12:28  
**重要性**: ⭐⭐⭐⭐⭐ （必须执行才能使用ML管理功能）

