# ML推荐管理系统 - 最终使用指南

## 🎯 系统简介

全新重构的ML推荐管理系统，基于真实数据库数据，提供完整的模型训练、推荐统计、服务监控功能。

### 核心特性
- ✅ **无模拟数据** - 所有数据从数据库读取
- ✅ **真实统计** - 基于推荐记录的真实聚合
- ✅ **完整训练流程** - 可启动、追踪、停止训练
- ✅ **定时维护** - 自动更新状态和统计
- ✅ **ML服务独立** - Python ML服务离线时也能正常使用

---

## 📋 部署步骤

### 步骤1：导入数据库（必需）

#### 使用MySQL Workbench（推荐）

1. **打开MySQL Workbench**
2. **连接到smart_diet_dev数据库**
3. **打开SQL脚本**:
   - `File` → `Open SQL Script...`
   - 选择: `E:\study\毕设\SDR_System\sql\ml_system_complete.sql`
4. **执行脚本**: 点击⚡或按`Ctrl+Shift+Enter`
5. **验证成功**: 看到验证输出，显示：
   ```
   ML推荐管理系统数据库初始化完成
   
   模型信息数据: 3条记录
   推荐统计数据: 28+条记录
   服务状态记录: 1条记录
   ```

### 步骤2：启动后端服务

#### 选项A：双击批处理文件
```
E:\study\毕设\SDR_System\start_backend_admin.bat
```

#### 选项B：新CMD窗口命令行
```bash
cd E:\study\毕设\SDR_System\SDR_System-admin
mvn spring-boot:run -Dmaven.test.skip=true
```

**等待启动完成**: 看到 "Started RuoYiApplication" 提示

### 步骤3：访问ML管理页面

```
http://localhost:81/diet/ml/management
```

---

## 🎨 页面功能说明

### 顶部状态卡片（5个）

#### 1. 服务状态
- **显示内容**: 健康/离线
- **数据来源**: `ml_service_status`表最新记录
- **刷新频率**: 页面每30秒自动刷新

#### 2. 已加载模型
- **显示内容**: X/3格式 + 进度条
- **数据来源**: `ml_model_info`表的`is_loaded`字段
- **说明**: 初始为0/3，训练完成后会更新

#### 3. 推荐接受率
- **显示内容**: 百分比 + 趋势（优秀/良好/需改进）
- **数据来源**: `ml_recommendation_stats`表的`acceptance_rate`聚合
- **计算方式**: (接受推荐数 / 总推荐数) × 100%

#### 4. 平均响应时间
- **显示内容**: XXms + 今日推荐次数
- **数据来源**: `ml_recommendation_stats`表的`avg_response_time`
- **说明**: 基于真实API响应时间统计

#### 5. 总推荐数
- **显示内容**: 累计推荐总数
- **数据来源**: `ml_recommendation_stats`表的`total_recommendations`求和
- **范围**: 最近7天

---

### 详细标签页

#### 标签页1：服务状态

**组件状态表格**:
- 数据加载器：正常/离线
- 用户画像：正常/离线
- 推荐引擎：正常/离线
- 数据来源：`ml_service_status`表

**模型加载状态卡片（3个）**:
| 模型名称 | 类型 | 状态 |
|---------|------|------|
| 协同过滤模型 | collaborative_filtering | 未加载 |
| 内容推荐模型 | content_based | 未加载 |
| 深度学习模型 | deep_learning | 未加载 |

数据来源：`ml_model_info`表

---

#### 标签页2：推荐效果

**4个KPI卡片**:
1. 总推荐数 - 累计统计
2. 接受率 - 平均接受率
3. 平均评分 - 用户评分平均值
4. 活跃用户 - 使用推荐的用户数

**算法性能对比表**:

| 算法 | 准确率 | 响应时间 | 使用率 | 推荐次数 | 状态 | 操作 |
|-----|--------|----------|--------|---------|------|------|
| 协同过滤 | XX% | XXms | XX% | XXX | 运行中 | 详情/优化/测试 |
| 内容推荐 | XX% | XXms | XX% | XXX | 运行中 | 详情/优化/测试 |
| 深度学习 | XX% | XXms | XX% | XXX | 运行中 | 详情/优化/测试 |
| 基于规则 | XX% | XXms | XX% | XXX | 运行中 | 详情/优化/测试 |

**数据来源**: `ml_recommendation_stats`表按`algorithm_type`分组聚合

**操作按钮功能**:
- **详情**: 显示算法详细信息
- **优化**: 启动算法优化（预留功能）
- **测试**: 为指定用户测试该算法

---

#### 标签页3：模型管理

**模型列表表格**:

| 模型名称 | 状态 | 描述 | 最后训练时间 | 操作 |
|---------|------|------|-------------|------|
| 协同过滤模型 | 未加载 | 基于用户相似度的推荐算法 | 未训练 | 训练/详情 |
| 内容推荐模型 | 未加载 | 基于食物营养特征的推荐算法 | 未训练 | 训练/详情 |
| 深度学习模型 | 未加载 | 基于神经网络的智能推荐算法 | 未训练 | 训练/详情 |

**点击"开始训练"打开训练对话框**:

1. **选择模型**: 复选框选择要训练的模型
2. **训练数据天数**: 30-365天（默认180天）
3. **预计训练时间**: 自动计算显示
4. **点击"开始训练"**: 启动训练流程

**训练进度显示**:
- 每个模型独立进度条
- 当前训练步骤（数据加载→预处理→训练→验证→完成）
- 已用时间 / 预计剩余时间
- 总体进度条
- 完成模型数统计

**训练状态变化**:
```
pending（等待中）
  ↓
training（训练中）
  ↓
completed（已完成）或 failed（失败）
```

---

#### 标签页4：推荐测试

**测试表单**:
- 用户ID输入框
- 餐次类型下拉（早餐/午餐/晚餐/加餐）
- 两个按钮：
  - **测试推荐**: 为该用户生成推荐
  - **算法对比**: 同时用3种算法生成推荐并对比

**测试结果显示**:
- 推荐是否成功
- 推荐食物列表
- 营养成分统计

---

## 🗄️ 数据库表说明

### ml_model_info（模型信息）
**记录数**: 3条（固定）
**作用**: 存储3个ML模型的元信息和状态

### ml_training_history（训练历史）
**记录数**: 每次训练创建1条
**作用**: 追踪每次训练的完整过程和结果

### ml_recommendation_stats（推荐统计）
**记录数**: 每天×每算法1条
**作用**: 聚合每日各算法的推荐统计数据

### ml_service_status（服务状态）
**记录数**: 每次检查创建1条
**作用**: 记录ML服务的历史健康状况

---

## 🔄 数据流程

### 页面加载时
```
前端mounted()
  ↓
调用 getMLStatus() → GET /diet/ml/status
  ↓
MLDataService.getServiceStatus()
  ↓
查询 ml_service_status（最新）+ ml_model_info（所有）
  ↓
返回服务状态 + 模型加载状态
  ↓
前端显示状态卡片
```

### 获取推荐统计
```
前端loadAnalytics()
  ↓
调用 getMLAnalytics() → GET /diet/ml/analytics
  ↓
MLDataService.getRecommendationStats()
  ↓
查询 ml_recommendation_stats（最近7天）
  ↓
聚合：总数、接受率、平均分、按算法分组
  ↓
返回统计数据
  ↓
前端显示KPI卡片 + 算法性能表
```

### 启动模型训练
```
前端点击"开始训练"
  ↓
调用 trainMLModels() → POST /diet/ml/model/train
  ↓
MLRecommendationService.trainModelsAsync()
  ↓
为每个模型调用 MLDataService.startTraining()
  ↓
插入 ml_training_history记录（status=pending）
  ↓
异步执行训练（模拟或真实ML服务）
  ↓
定时更新 progress、current_step
  ↓
完成时更新 status=completed、accuracy
  ↓
更新 ml_model_info（is_loaded=1、last_trained_time）
```

### 查询训练进度
```
前端每3秒轮询
  ↓
调用 getTrainingProgress() → GET /diet/ml/training/progress
  ↓
MLDataService.getTrainingProgress()
  ↓
查询 ml_training_history（status IN ('pending', 'training')）
  ↓
计算总体进度、已完成模型数
  ↓
返回进度数据
  ↓
前端更新进度条
```

---

## 🧪 功能测试清单

### 基础功能测试

1. **页面加载测试**
   - [ ] 页面正常打开，无白屏
   - [ ] 5个状态卡片显示数据（不全是0）
   - [ ] 服务状态显示"离线"（ML服务未运行时）

2. **服务状态标签页**
   - [ ] 组件状态表显示3个组件
   - [ ] 模型状态显示3个模型卡片
   - [ ] 状态标签颜色正确（离线=红色）

3. **推荐效果标签页**
   - [ ] 4个KPI卡片显示非0数据
   - [ ] 算法性能表显示4行数据（4种算法）
   - [ ] 准确率进度条显示
   - [ ] 响应时间有数值
   - [ ] 推荐次数有统计

4. **模型管理标签页**
   - [ ] 模型列表显示3个模型
   - [ ] 状态显示"未加载"
   - [ ] 最后训练时间显示"未知"或空

5. **训练功能测试**
   - [ ] 点击"开始训练"打开对话框
   - [ ] 选择模型（如选择全部3个）
   - [ ] 设置训练天数（如180天）
   - [ ] 点击"开始训练"
   - [ ] 看到训练进度对话框
   - [ ] 每个模型显示独立进度条
   - [ ] 进度从0%逐步增长到100%
   - [ ] 显示当前步骤（数据加载→预处理→训练→验证→完成）
   - [ ] 显示已用时间
   - [ ] 训练完成后显示通知
   - [ ] 对话框3秒后自动关闭

6. **推荐测试标签页**
   - [ ] 输入用户ID（如：101）
   - [ ] 选择餐次（如：午餐）
   - [ ] 点击"测试推荐"
   - [ ] 看到推荐成功提示
   - [ ] 点击"算法对比"
   - [ ] 看到3种算法的对比结果

---

## 📊 数据说明

### 初始数据状态

执行`ml_system_complete.sql`后：

| 数据项 | 数量 | 说明 |
|-------|------|------|
| ML模型 | 3条 | 协同过滤、内容推荐、深度学习 |
| 推荐统计 | 28+条 | 最近7天×4算法 |
| 服务状态 | 1条 | 初始离线状态 |
| 训练历史 | 0条 | 启动训练后会有记录 |

### 统计数据示例

**推荐统计（ml_recommendation_stats）**:

| 日期 | 算法 | 总推荐数 | 接受数 | 接受率 | 平均分 |
|-----|------|---------|--------|--------|--------|
| 2025-10-09 | rule_based | 45 | 32 | 0.7111 | 4.2 |
| 2025-10-09 | collaborative_filtering | 38 | 28 | 0.7368 | 4.5 |
| 2025-10-09 | content_based | 32 | 23 | 0.7188 | 4.1 |
| 2025-10-09 | deep_learning | 41 | 35 | 0.8537 | 4.7 |

### 页面显示计算

**总推荐数** = SUM(total_recommendations) 最近7天  
**接受率** = AVG(acceptance_rate) 最近7天  
**平均评分** = AVG(avg_score) 最近7天  
**活跃用户** = MAX(active_users) 最近7天

---

## 🚀 使用场景

### 场景1：查看推荐效果

1. 访问页面
2. 查看顶部KPI卡片
3. 切换到"推荐效果"标签页
4. 查看算法性能对比表
5. 点击"导出报告"保存分析数据

### 场景2：训练ML模型

1. 切换到"模型管理"标签页
2. 点击"开始训练"
3. 选择要训练的模型（可多选）
4. 设置训练天数（建议180天）
5. 点击"开始训练"
6. 实时查看训练进度
7. 等待训练完成（每个模型约2-3分钟）
8. 训练完成后模型状态更新为"已加载"

### 场景3：测试推荐算法

1. 切换到"推荐测试"标签页
2. 输入用户ID（如：101）
3. 选择餐次类型（如：午餐）
4. 点击"测试推荐"
5. 查看推荐结果
6. 点击"算法对比"查看3种算法的不同推荐

### 场景4：监控服务状态

1. 查看顶部"服务状态"卡片
2. 点击"刷新状态"主动检查
3. 切换到"服务状态"标签页
4. 查看各组件详细状态
5. 查看模型加载情况

---

## 🔧 定时任务说明

系统会自动执行以下定时任务：

| 频率 | 任务 | 说明 |
|-----|------|------|
| 每10分钟 | 快速状态检查 | 检查ML服务是否在线 |
| 每小时 | 完整状态更新 | 检查并保存服务状态到数据库 |
| 每天凌晨2点 | 聚合昨日统计 | 从diet_recommendation聚合统计数据 |

**查看定时任务日志**:
```
后端日志中搜索：
- "开始执行定时任务"
- "ML服务状态更新完成"
- "昨日推荐统计聚合完成"
```

---

## 📈 数据增长

随着系统使用，数据会自动累积：

### 每天增长
- `ml_recommendation_stats`: +4条（4种算法）
- `ml_service_status`: +24条（每小时1条）

### 每次训练增长
- `ml_training_history`: +N条（N=训练的模型数）
- `ml_model_info`: 更新训练时间和准确率

### 每次推荐增长
- `diet_recommendation`: +1条（自动添加ML字段）

---

## ⚙️ 配置说明

### application.yml配置

```yaml
# ML服务配置
ml:
  service:
    url: http://localhost:8001  # Python ML服务地址
    timeout: 30                  # 请求超时（秒）
    enabled: false               # 是否启用ML服务（false=使用规则推荐）
```

**说明**:
- `enabled=false`: ML服务离线时，使用基于规则的推荐
- `enabled=true`: 尝试调用ML服务，失败时降级为规则推荐

---

## 🐛 常见问题

### Q1: 页面显示全0怎么办？
**原因**: 数据库表未导入或无数据  
**解决**: 
1. 检查数据库是否执行了`ml_system_complete.sql`
2. 执行查询：`SELECT COUNT(*) FROM ml_recommendation_stats;`
3. 如果为0，重新执行`init_ml_data.sql`

### Q2: 训练点击后无反应？
**原因**: 可能是后端异常  
**解决**:
1. 查看后端日志是否有错误
2. 检查`ml_model_info`表是否有3条记录
3. 手动执行：`SELECT * FROM ml_model_info;`

### Q3: 服务状态始终显示"离线"？
**原因**: 正常！ML Python服务（端口8001）未运行  
**影响**: 不影响其他功能使用
**说明**: 系统设计为ML服务可选，离线时使用规则推荐

### Q4: 算法性能表没有数据？
**原因**: 统计数据未生成  
**解决**:
1. 检查：`SELECT COUNT(*) FROM ml_recommendation_stats;`
2. 如果有数据但前端不显示，刷新页面
3. 查看浏览器控制台Network标签，检查`/diet/ml/analytics`返回数据

### Q5: 训练进度不更新？
**原因**: 前端轮询可能未启动  
**解决**:
1. 打开浏览器开发者工具
2. 查看Console是否有错误
3. 查看Network标签，确认每3秒有请求`/diet/ml/training/progress`
4. 后端查看：`SELECT * FROM ml_training_history ORDER BY training_id DESC LIMIT 5;`

---

## 📝 SQL查询备查

### 查看模型信息
```sql
SELECT 
    model_name AS '模型名称',
    model_type AS '类型',
    CASE WHEN is_loaded=1 THEN '已加载' ELSE '未加载' END AS '状态',
    accuracy AS '准确率',
    last_trained_time AS '最后训练时间'
FROM ml_model_info;
```

### 查看推荐统计
```sql
SELECT 
    stat_date AS '日期',
    algorithm_type AS '算法',
    total_recommendations AS '总推荐',
    accepted_recommendations AS '接受数',
    CONCAT(ROUND(acceptance_rate * 100, 2), '%') AS '接受率',
    avg_score AS '平均分',
    active_users AS '活跃用户'
FROM ml_recommendation_stats
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY stat_date DESC, algorithm_type;
```

### 查看训练历史
```sql
SELECT 
    training_id AS 'ID',
    model_type AS '模型',
    training_status AS '状态',
    CONCAT(progress, '%') AS '进度',
    current_step AS '当前步骤',
    start_time AS '开始时间',
    CONCAT(IFNULL(elapsed_time, 0), '秒') AS '耗时'
FROM ml_training_history
ORDER BY training_id DESC
LIMIT 10;
```

### 查看服务状态历史
```sql
SELECT 
    service_status AS '服务状态',
    CASE WHEN data_loader_status=1 THEN '正常' ELSE '离线' END AS '数据加载器',
    CASE WHEN user_profiling_status=1 THEN '正常' ELSE '离线' END AS '用户画像',
    CASE WHEN recommender_status=1 THEN '正常' ELSE '离线' END AS '推荐引擎',
    check_time AS '检查时间',
    CONCAT(IFNULL(response_time, 0), 'ms') AS '响应时间'
FROM ml_service_status
ORDER BY check_time DESC
LIMIT 10;
```

---

## 🎉 完成标志

成功部署后，您应该看到：

### 页面加载
- ✅ 5个状态卡片显示真实数据
- ✅ 算法性能表显示4种算法
- ✅ 模型列表显示3个模型
- ✅ 无JavaScript错误

### 训练功能
- ✅ 能启动训练并看到进度
- ✅ 进度条实时更新
- ✅ 训练完成有通知

### 数据准确性
- ✅ KPI数据与数据库查询结果一致
- ✅ 算法性能数据与统计表数据一致
- ✅ 模型状态与ml_model_info一致

---

## 📞 技术支持

### 查看后端日志
```
后端启动窗口中查看实时日志
搜索关键词：
- "ML" - 所有ML相关日志
- "训练" - 训练相关日志
- "统计" - 统计相关日志
```

### 查看前端日志
```
浏览器F12 → Console标签
查看：
- API请求日志
- 数据加载日志  
- 错误信息
```

### 检查数据库
```
使用MySQL Workbench查询各表数据
确认数据是否正确生成和更新
```

---

## 🎊 开始使用

### 现在就开始！

1. **打开MySQL Workbench**
2. **执行 `sql/ml_system_complete.sql`**
3. **启动后端**: `start_backend_admin.bat`
4. **访问页面**: `http://localhost:81/diet/ml/management`
5. **享受完整的ML推荐管理功能！**

---

**文档版本**: 1.0.0  
**最后更新**: 2025-10-10  
**适用系统**: SDR_System智能饮食推荐系统

