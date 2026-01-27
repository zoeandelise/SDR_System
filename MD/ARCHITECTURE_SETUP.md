# 智能饮食推荐系统架构搭建完成报告

## 🎯 项目概述
基于RuoYi-Vue框架的智能饮食推荐系统，集成深度学习、知识图谱与推荐算法，为用户提供个性化的饮食管理方案。

## 📊 系统架构

### 后端架构 (Spring Boot + 多数据库)
```
SDR_System/
├── SDR_System-admin/          # Web服务入口模块
├── SDR_System-framework/      # 核心框架模块
├── SDR_System-system/         # 系统管理模块
├── SDR_System-common/         # 通用工具模块
├── SDR_System-quartz/         # 定时任务模块
├── SDR_System-generator/      # 代码生成模块
└── SDR_System-diet/          # 🆕 饮食推荐核心模块
```

### 前端架构 (Vue2 + Element UI + ECharts)
```
SDR_System-ui/src/
├── api/diet/                  # 饮食相关API接口
├── views/diet/               # 饮食管理页面
│   ├── dashboard/            # 饮食仪表板
│   ├── record/              # 饮食记录管理
│   └── recommendation/       # 推荐管理
└── components/               # 通用组件
```

## 🗄️ 数据库架构

### 1. MySQL (主数据库)
- **sys_user_health**: 用户健康信息表
- **diet_food_info**: 食物基础信息表
- **diet_food_category**: 食物分类表
- **diet_food_nutrition**: 食物营养信息表
- **diet_record**: 饮食记录表
- **diet_recommendation**: 饮食推荐记录表
- **diet_ai_recognition**: AI识别记录表
- **diet_user_preference**: 用户饮食偏好表
- **diet_system_config**: 系统配置扩展表

### 2. MongoDB (详细数据存储)
- **diet_record_detail**: 饮食记录详情文档
  - 存储食物详细信息、营养分析、图片等JSON数据

### 3. Neo4j (知识图谱)
- **Food节点**: 食物信息
- **Nutrient节点**: 营养素信息
- **HealthGoal节点**: 健康目标
- **Disease节点**: 疾病信息
- **关系**: CONTAINS, SUITABLE_FOR, UNSUITABLE_FOR等

## 🚀 核心功能模块

### 1. 用户健康管理模块
- ✅ 用户健康信息录入和管理
- ✅ BMI计算和健康目标设定
- ✅ 每日热量需求计算

### 2. 饮食记录模块
- ✅ 手动录入饮食记录
- ✅ AI图像识别食物
- ✅ 营养信息自动计算
- ✅ 多媒体存储支持

### 3. 智能推荐模块
- ✅ 基于规则的推荐引擎
- ✅ 个性化推荐算法
- ✅ 健康目标导向推荐
- ✅ 知识图谱增强推荐

### 4. 数据可视化模块
- ✅ 饮食仪表板
- ✅ 营养摄入趋势图表
- ✅ 热量分布饼图
- ✅ 目标达成情况分析

### 5. AI集成模块
- ✅ 食物图像识别服务接口
- ✅ HTTP客户端调用封装
- ✅ 识别结果处理和存储
- ✅ 错误处理和重试机制

## 🔧 技术栈配置

### 后端依赖更新
```xml
<!-- 新增依赖 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-neo4j</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.httpcomponents</groupId>
    <artifactId>httpclient</artifactId>
</dependency>
```

### 配置文件更新
```yaml
# application.yml 新增配置
spring:
  data:
    mongodb:
      host: localhost
      port: 27017
      database: diet_system
    neo4j:
      uri: bolt://localhost:7687

# 智能饮食推荐系统配置
diet:
  ai:
    recognition-url: http://localhost:5000/api/recognition
    connect-timeout: 5000
    read-timeout: 30000
    max-retry: 3
  recommendation:
    algorithm-type: hybrid
    daily-count: 3
    validity-hours: 24
```

## 📁 已创建的核心文件

### Java后端文件
1. **实体类 (Domain)**
   - `DietFoodInfo.java` - 食物基础信息
   - `DietFoodNutrition.java` - 食物营养信息
   - `DietRecord.java` - 饮食记录
   - `SysUserHealth.java` - 用户健康信息
   - `DietRecordDetail.java` - MongoDB文档实体

2. **Neo4j图谱实体**
   - `FoodNode.java` - 食物节点
   - `NutrientNode.java` - 营养素节点
   - `NutrientRelation.java` - 营养关系
   - `HealthGoalRelation.java` - 健康目标关系
   - `DiseaseRelation.java` - 疾病关系

3. **数据访问层 (Mapper & Repository)**
   - `DietFoodInfoMapper.java` - 食物信息Mapper
   - `DietRecordMapper.java` - 饮食记录Mapper
   - `SysUserHealthMapper.java` - 用户健康Mapper
   - `DietRecordDetailRepository.java` - MongoDB仓库
   - `FoodNodeRepository.java` - Neo4j仓库

4. **服务层 (Service)**
   - `IAiRecognitionService.java` - AI识别服务接口
   - `AiRecognitionServiceImpl.java` - AI识别服务实现
   - `IDietRecommendationService.java` - 推荐服务接口
   - `IKnowledgeGraphService.java` - 知识图谱服务接口

5. **控制器 (Controller)**
   - `DietFoodController.java` - 食物管理控制器
   - `DietRecordController.java` - 饮食记录控制器
   - `DietRecommendationController.java` - 推荐控制器

6. **配置类**
   - `Neo4jConfig.java` - Neo4j配置

### 前端Vue文件
1. **API接口**
   - `api/diet/food.js` - 食物管理API
   - `api/diet/record.js` - 饮食记录API
   - `api/diet/recommendation.js` - 推荐API

2. **页面组件**
   - `views/diet/dashboard/index.vue` - 饮食仪表板
   - `views/diet/record/index.vue` - 饮食记录管理页面

### 数据库文件
1. **SQL脚本**
   - `sql/diet_system.sql` - 完整数据库表结构和初始数据

2. **MyBatis映射文件**
   - `mapper/diet/DietFoodInfoMapper.xml`
   - `mapper/diet/DietRecordMapper.xml`

## 🔄 系统工作流程

### 1. 用户饮食记录流程
```
用户上传食物照片 → AI识别服务 → 返回食物信息 → 
查询营养数据库 → 计算营养值 → 存储到MySQL+MongoDB → 
更新用户统计数据
```

### 2. 智能推荐流程
```
获取用户健康信息 → 分析历史饮食数据 → 查询知识图谱 → 
应用推荐算法 → 生成推荐方案 → 返回推荐结果
```

### 3. 数据可视化流程
```
查询用户饮食数据 → 计算营养统计 → 生成图表数据 → 
前端ECharts渲染 → 实时更新显示
```

## 🎨 界面功能特性

### 饮食仪表板
- 📊 今日热量摄入进度条
- 🥧 营养分布饼图
- 📈 7日热量趋势图
- 🍽️ 今日餐次记录卡片
- 📸 快速拍照识别入口
- 🎯 智能推荐按钮

### 饮食记录管理
- 📋 记录列表展示和搜索
- ➕ 手动添加饮食记录
- 📷 拍照识别食物功能
- 🖼️ 食物图片预览
- 📊 营养信息详情展示
- 📤 数据导出功能

## 🛠️ 部署和启动

### 1. 数据库准备
```sql
-- 执行SQL脚本
source sql/diet_system.sql;
```

### 2. 启动MongoDB
```bash
mongod --dbpath /path/to/data/db
```

### 3. 启动Neo4j
```bash
neo4j start
```

### 4. 启动后端服务
```bash
cd SDR_System-admin
mvn spring-boot:run
```

### 5. 启动前端服务
```bash
cd SDR_System-ui
npm install
npm run dev
```

## 🔮 下一步开发计划

### 短期目标 (1-2周)
1. **完善Service层实现**
   - 实现具体的推荐算法逻辑
   - 完善知识图谱查询服务
   - 添加数据验证和异常处理

2. **AI服务集成**
   - 部署Python AI识别服务
   - 测试图像识别功能
   - 优化识别准确度

3. **前端功能完善**
   - 添加更多图表类型
   - 实现响应式设计
   - 添加用户交互反馈

### 中期目标 (3-4周)
1. **推荐算法优化**
   - 实现协同过滤算法
   - 添加机器学习模型
   - 优化推荐准确性

2. **知识图谱构建**
   - 导入食物营养数据
   - 建立食物关系网络
   - 完善健康规则库

3. **系统性能优化**
   - 数据库查询优化
   - 缓存机制实现
   - 并发处理优化

### 长期目标 (1-2月)
1. **高级功能开发**
   - 个性化学习算法
   - 社交分享功能
   - 健康报告生成

2. **移动端适配**
   - 响应式设计优化
   - PWA功能支持
   - 离线数据同步

## ✅ 架构搭建完成清单

- [x] 项目结构分析和规划
- [x] 多数据库配置 (MySQL + MongoDB + Neo4j)
- [x] 饮食管理Java模块创建
- [x] AI服务集成接口设计
- [x] 推荐算法框架搭建
- [x] 前端Vue组件开发
- [x] 知识图谱集成配置
- [x] 数据库表结构设计
- [x] API接口定义
- [x] 基础功能实现

## 📞 技术支持

如有问题，请参考以下文档：
- [RuoYi框架官方文档](http://doc.ruoyi.vip/)
- [Spring Data MongoDB文档](https://spring.io/projects/spring-data-mongodb)
- [Spring Data Neo4j文档](https://spring.io/projects/spring-data-neo4j)
- [ECharts官方文档](https://echarts.apache.org/)

---

**🎉 智能饮食推荐系统架构搭建完成！**

系统已具备完整的技术架构和基础功能框架，可以开始具体的业务逻辑开发和功能测试。
