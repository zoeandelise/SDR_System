# ML服务状态异常修复指南

## 问题描述

在访问 `http://localhost:81/diet/ml/management` 时，组件状态显示：
- 数据加载器：**异常**
- 用户画像：**异常**
- 推荐引擎：**异常**
- 服务状态：**离线**

## 问题原因

组件状态异常的根本原因是：
1. **ML Python服务未启动**（端口8001）
2. **ML服务启动在错误的端口**（8002而不是8001）⚠️ **常见问题**
3. **数据库中的服务状态记录未更新**
4. **健康检查失败**

## 快速修复方案

### 方案零：端口问题一键修复（最常见）⭐

如果ML服务启动在**端口8002**而不是8001：

```batch
fix_port_and_restart.bat
```

此脚本会自动：
1. ✓ 停止8002端口的ML服务
2. ✓ 检查8001端口可用性
3. ✓ 在正确的端口8001重启服务
4. ✓ 验证服务状态
5. ✓ 刷新后端状态

**或者手动操作**：
```batch
# 停止当前的ML服务（Ctrl+C）
# 然后重新启动（代码已修复为8001端口）
cd SDR_System-ml
python enhanced_ml_server.py
```

### 方案一：使用自动化脚本（推荐）

#### 1. 诊断问题
```batch
check_ml_service.bat
```

此脚本会自动检查：
- ✓ ML服务端口8001是否被占用
- ✓ ML服务健康检查是否通过
- ✓ 后端服务状态
- ✓ 数据库状态

#### 2. 修复问题
```batch
fix_ml_status.bat
```

选择修复方式：
- **选项1**：启动ML服务（如果服务未运行）
- **选项2**：仅更新数据库状态（如果服务已运行但状态未同步）
- **选项3**：完整修复（启动服务 + 更新状态）

### 方案二：手动修复

#### 步骤1：检查ML服务状态

```batch
# 检查端口8001是否被占用
netstat -ano | findstr ":8001"
```

如果**没有输出**，说明ML服务未启动，继续步骤2。
如果**有输出**，说明服务已运行，跳到步骤3。

#### 步骤2：启动ML服务

```batch
cd SDR_System-ml
python enhanced_ml_server.py
```

等待服务启动（约3-5秒），当看到以下信息时表示成功：
```
INFO:     Uvicorn running on http://0.0.0.0:8001
INFO:     Application startup complete.
```

#### 步骤3：验证服务健康状态

```batch
# 测试健康检查接口
curl http://localhost:8001/health
```

应该返回类似：
```json
{
  "status": "healthy",
  "components": {
    "dataLoader": true,
    "userProfiling": true,
    "recommender": true
  }
}
```

#### 步骤4：刷新后端服务状态

有两种方式：

**方式A：通过API调用（推荐）**
```batch
curl -X POST http://localhost:8080/diet/ml/status/refresh ^
     -H "Content-Type: application/json"
```

**方式B：直接更新数据库**
```batch
mysql -u root -p1234 smart_diet_dev < sql\update_ml_service_status.sql
```

#### 步骤5：在前端页面刷新

1. 打开浏览器访问：`http://localhost:81/diet/ml/management`
2. 点击页面右上角的 **"刷新状态"** 按钮
3. 查看组件状态是否变为 **"正常"**

## 详细技术说明

### 数据流程

```
ML Python服务(8001)
    ↓ 健康检查
后端Java服务(8080) → 读取/更新 ml_service_status表
    ↓ API响应
前端页面(81) → 显示状态
```

### 关键配置

#### 1. 后端配置（application.yml）
```yaml
ml:
  service:
    url: http://localhost:8001
    timeout: 30000
    enabled: true
```

#### 2. 数据库表结构（ml_service_status）
```sql
- service_status: 'healthy'/'offline'
- data_loader_status: 1/0
- user_profiling_status: 1/0
- recommender_status: 1/0
- check_time: 最后检查时间
```

#### 3. 前端API调用
```javascript
// 获取状态
GET /diet/ml/status

// 刷新状态（会触发健康检查）
POST /diet/ml/status/refresh
```

### 状态判断逻辑

前端组件状态判断：
```javascript
// components.dataLoader 为 true 时显示"正常"
// components.dataLoader 为 false 时显示"异常"
serviceStatus.components && serviceStatus.components.dataLoader ? '正常' : '异常'
```

后端状态转换：
```java
// 从数据库读取 data_loader_status（0或1）
// 转换为 boolean 后放入 components.dataLoader
components.put("dataLoader", data_loader_status == 1);
```

## 常见问题排查

### Q0：ML服务启动在端口8002而不是8001 ⚠️ **最常见问题**

**症状**：
```
启动增强版ML服务器在端口 8002
```

**原因**：
- 旧版本代码配置为8002端口
- 但后端期望连接到8001端口

**解决方法**：
```batch
# 方法1：使用自动修复工具（推荐）
fix_port_and_restart.bat

# 方法2：手动修复
# a. 停止当前服务（在运行窗口按Ctrl+C）
# b. 确认代码已更新（enhanced_ml_server.py中PORT = 8001）
# c. 重新启动
cd SDR_System-ml
python enhanced_ml_server.py

# 方法3：使用快速启动脚本
快速启动ML服务8001.bat
```

**验证修复**：
启动后应该看到：
```
启动增强版ML服务器在端口 8001  ✓
```

### Q1：执行刷新状态后仍显示异常

**可能原因**：
- ML服务未完全启动（需要等待3-5秒）
- 健康检查接口返回错误
- 网络连接问题

**解决方法**：
1. 检查ML服务控制台是否有错误信息
2. 手动访问 `http://localhost:8001/health` 验证
3. 检查防火墙设置

### Q2：ML服务启动失败

**可能原因**：
- Python环境未配置
- 依赖包未安装
- 端口8001被占用

**解决方法**：
```batch
# 1. 检查Python版本（需要3.8+）
python --version

# 2. 安装依赖
cd SDR_System-ml
pip install -r requirements.txt

# 3. 检查并释放端口
netstat -ano | findstr ":8001"
# 如果被占用，kill对应进程或使用其他端口
```

### Q3：数据库更新失败

**可能原因**：
- MySQL服务未启动
- 数据库连接信息错误
- ml_service_status表不存在

**解决方法**：
```batch
# 检查MySQL服务
net start | findstr "MySQL"

# 检查表是否存在
mysql -u root -p1234 -e "USE smart_diet_dev; SHOW TABLES LIKE 'ml_service_status';"

# 如果表不存在，重新创建
mysql -u root -p1234 smart_diet_dev < sql\ml_system_tables.sql
```

### Q4：页面一直显示"加载中"

**可能原因**：
- 后端服务未启动（端口8080）
- API请求被拦截（CORS问题）
- Token失效

**解决方法**：
1. 确认后端服务正在运行
2. 检查浏览器控制台的网络请求
3. 重新登录系统

## 验证修复成功

修复成功后，页面应显示：

```
组件状态
├─ 数据加载器    [正常]
├─ 用户画像      [正常]
├─ 推荐引擎      [正常]
└─ 最后检查      2025/10/10 16:45:30

服务状态          [在线]
已加载模型        3/3
```

## 预防措施

为避免此问题再次发生：

1. **开机自启动ML服务**
   - 创建Windows服务或计划任务
   - 或使用 `start_all_services.bat` 统一启动所有服务

2. **定期健康检查**
   - 后端可配置定时任务自动检查ML服务状态
   - 发现异常自动告警

3. **监控日志**
   - 定期查看 `SDR_System-ml/logs/` 目录
   - 及时发现和处理异常

## 相关文件

- `check_ml_service.bat` - ML服务诊断工具
- `fix_ml_status.bat` - ML服务状态修复工具
- `sql/update_ml_service_status.sql` - 数据库状态更新SQL
- `sql/check_ml_status.sql` - 数据库状态查询SQL
- `SDR_System-ml/enhanced_ml_server.py` - ML服务主程序
- `SDR_System-diet/src/main/java/com/SDR_System/diet/service/MLDataService.java` - 后端服务状态管理

## 技术支持

如果按照以上步骤仍无法解决问题，请：

1. 收集以下日志信息：
   - ML服务启动日志
   - 后端服务日志（logs/）
   - 浏览器控制台错误信息

2. 检查系统环境：
   - Python版本：`python --version`
   - Java版本：`java -version`
   - MySQL版本：`mysql --version`

3. 提供具体的错误信息截图

---

**最后更新**：2025-10-10
**适用版本**：SDR_System v1.0+

