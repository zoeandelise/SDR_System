# 🚀 智能饮食推荐系统快速启动指南

## ✅ 已修复的启动问题

### 1. **Controller方法调用问题**
- ✅ 修复了 `SysUserHealthController` 中 `success()` 方法调用错误
- ✅ 改为使用 `success(Object data)` 的正确重载版本

### 2. **MongoDB依赖问题**
- ✅ 在 `DietRecordServiceImpl` 中添加了 `@Autowired(required = false)` 
- ✅ 所有MongoDB操作都添加了null检查，支持渐进式启用

### 3. **依赖配置完善**
- ✅ 添加了httpmime依赖支持文件上传
- ✅ 简化了Neo4j配置，避免版本冲突
- ✅ 使用条件注解控制服务启用

## 🎯 当前可用功能

### 核心功能 (仅需MySQL)
- ✅ 用户健康信息管理 - BMI计算、热量需求计算
- ✅ 食物信息管理 - 10种预置食物，完整营养数据
- ✅ 饮食记录管理 - 基础记录功能，营养统计
- ✅ Mock AI识别 - 90%成功率模拟，支持文件上传
- ✅ 健康评估报告 - 个性化建议和风险提示
- ✅ 前端界面 - 仪表板、图表、管理页面

## 📋 启动步骤

### 1. 编译项目
```bash
cd E:\study\毕设\SDR_System
mvn clean install -DskipTests
```

### 2. 导入基础数据 (如果还没导入)
```bash
mysql -u root -p smart_diet_dev < sql/food_data_init.sql
```

### 3. 启动后端服务
```bash
cd SDR_System-admin
mvn spring-boot:run
```

### 4. 启动前端服务
```bash
cd SDR_System-ui
npm run dev
```

## 🧪 测试功能

### 1. 登录系统
- URL: `http://localhost:80`
- 账号: `admin`
- 密码: `admin123`

### 2. 核心功能测试

#### 健康信息管理
- 访问: `http://localhost:80/#/diet/health`
- 测试BMI计算和健康评估

#### 食物管理
- 访问: `http://localhost:80/#/diet/food`
- 测试食物搜索: 搜索"鸡胸肉"、"西兰花"等

#### 饮食记录
- 访问: `http://localhost:80/#/diet/record`
- 测试Mock AI识别功能

#### 饮食仪表板
- 访问: `http://localhost:80/#/diet/dashboard`
- 查看营养统计图表

### 3. API测试
```bash
# 获取食物列表
curl -X GET "http://localhost:8080/diet/food/list"

# 搜索食物
curl -X GET "http://localhost:8080/diet/food/search/鸡胸肉"

# 获取健康评估
curl -X GET "http://localhost:8080/diet/health/assessment"

# 计算BMI
curl -X GET "http://localhost:8080/diet/health/bmi"
```

## 📊 预置测试数据

### 食物信息 (10种)
1. 白米饭 - 130kcal/100g
2. 鸡胸肉 - 165kcal/100g  
3. 西兰花 - 34kcal/100g
4. 鸡蛋 - 155kcal/100g
5. 香蕉 - 89kcal/100g
6. 牛奶 - 150kcal/250ml
7. 燕麦 - 389kcal/100g
8. 三文鱼 - 208kcal/100g
9. 菠菜 - 23kcal/100g
10. 苹果 - 52kcal/100g

### 用户健康档案 (2个示例)
- 用户1: 男性, 25岁, 170cm, 70kg, 中度活动, 减脂目标
- 用户2: 女性, 22岁, 160cm, 55kg, 轻度活动, 保持体重

### 饮食记录 (5条示例)
- 涵盖早餐、午餐、晚餐的搭配示例
- 包含营养数据和热量统计

## 🔧 配置说明

### 当前配置 (application.yml)
```yaml
# MySQL配置 - 必需
spring:
  datasource:
    druid:
      master:
        url: jdbc:mysql://localhost:3306/smart_diet_dev

# Mock AI服务 - 已启用
diet:
  ai:
    mock:
      enabled: true

# MongoDB - 已禁用 (可选)
# Neo4j - 已禁用 (可选)
```

## 🔄 渐进式功能启用

### 启用MongoDB (可选)
1. 启动MongoDB: `mongod --dbpath /path/to/data`
2. 取消注释application.yml中的MongoDB配置
3. 重启应用

### 启用Neo4j (可选)  
1. 启动Neo4j: `neo4j start`
2. 取消注释application.yml中的Neo4j配置
3. 重启应用

### 启用真实AI服务 (可选)
1. 部署AI服务到 `http://localhost:5000`
2. 修改配置: `diet.ai.mock.enabled: false`
3. 重启应用

## ⚡ 故障排除

### 常见问题
1. **编译错误**: 运行 `mvn clean install -U`
2. **端口冲突**: 修改application.yml中的server.port
3. **数据库连接**: 检查MySQL服务和数据库名称
4. **前端启动**: 删除node_modules重新 `npm install`

### 检查服务状态
```bash
# 检查后端服务
curl http://localhost:8080/actuator/health

# 检查前端服务
curl http://localhost:80

# 检查数据库
mysql -u root -p smart_diet_dev -e "SELECT COUNT(*) FROM diet_food_info;"
```

## 📈 系统特性

### 智能计算
- **BMI自动计算**: 根据身高体重实时计算
- **热量需求**: Harris-Benedict公式精确计算
- **营养配比**: 15%蛋白质 + 25%脂肪 + 60%碳水

### Mock AI识别
- **高仿真度**: 90%成功率，1-3秒响应时间
- **随机识别**: 1-3种食物，包含重量估算
- **完整数据**: 置信度、边界框、营养信息

### 健康管理
- **个性化建议**: 基于BMI、年龄、健康目标
- **风险提示**: 体重异常、疾病、过敏提醒
- **科学评估**: 多维度健康状况分析

---

**🎉 系统已准备就绪！享受智能饮食管理体验！**

如有问题，请检查日志文件或联系技术支持。
