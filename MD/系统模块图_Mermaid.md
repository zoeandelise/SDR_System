# 智能健康饮食推荐系统 - Mermaid模块图

## 📋 目录
- [1. 总体系统架构图](#1-总体系统架构图)
- [2. 前端应用模块图](#2-前端应用模块图)
- [3. 后端服务模块图](#3-后端服务模块图)
- [4. 数据库架构图](#4-数据库架构图)
- [5. AI智能推荐模块图](#5-ai智能推荐模块图)
- [6. 用户端功能模块图](#6-用户端功能模块图)
- [7. 管理端功能模块图](#7-管理端功能模块图)
- [8. 核心业务流程图](#8-核心业务流程图)
- [9. 数据流转图](#9-数据流转图)
- [10. ML算法模块图](#10-ml算法模块图)

---

## 1. 总体系统架构图

```mermaid
graph TB
    subgraph "客户端层"
        A[用户端 React<br/>:3000]
        B[管理端 Vue<br/>:81]
    end
    
    subgraph "应用服务层"
        C[Spring Boot<br/>:8080]
        D[Python ML服务<br/>:8001]
    end
    
    subgraph "数据存储层"
        E[(MySQL<br/>主数据库)]
        F[(MongoDB<br/>详细存储)]
        G[(Neo4j<br/>知识图谱)]
    end
    
    subgraph "核心功能模块"
        H[AI智能推荐]
        I[饮食记录管理]
        J[营养分析]
        K[用户健康画像]
        L[ML推荐管理]
    end
    
    A -->|HTTP/REST| C
    B -->|HTTP/REST| C
    C -->|调用| D
    C -->|读写| E
    C -->|存储详情| F
    C -->|图谱查询| G
    
    C --> H
    C --> I
    C --> J
    C --> K
    C --> L
    
    style A fill:#4CAF50
    style B fill:#2196F3
    style C fill:#FF9800
    style D fill:#9C27B0
    style E fill:#F44336
    style F fill:#00BCD4
    style G fill:#E91E63
    style H fill:#FFD700
```

---

## 2. 前端应用模块图

```mermaid
graph TB
    subgraph "用户端 (React + TypeScript)"
        A1[登录页<br/>SimpleLoginPage]
        A2[首页<br/>NewHomePage]
        A3[AI智能推荐⭐<br/>SmartRecommendationPage]
        A4[营养分析<br/>NutritionAnalysisPage]
        A5[饮食记录<br/>SimpleDietLogPage]
        A6[食物库<br/>SimpleFoodDatabasePage]
        A7[健康画像<br/>SimpleProfilePage]
    end
    
    subgraph "管理端 (Vue + Element UI)"
        B1[首页仪表板<br/>index.vue]
        B2[ML推荐管理⭐<br/>management.vue]
        B3[用户管理]
        B4[食物管理]
        B5[系统设置]
    end
    
    subgraph "共享服务"
        C1[API服务<br/>api.ts]
        C2[认证服务<br/>authService.ts]
        C3[路由配置<br/>Router]
    end
    
    A1 --> A2
    A2 --> A3
    A2 --> A4
    A2 --> A5
    A2 --> A6
    A2 --> A7
    
    A3 --> C1
    A4 --> C1
    A5 --> C1
    A6 --> C1
    A7 --> C1
    
    B2 --> C1
    B3 --> C1
    B4 --> C1
    
    C1 --> C2
    
    style A3 fill:#FFD700
    style B2 fill:#FFD700
```

---

## 3. 后端服务模块图

```mermaid
graph TB
    subgraph "SDR_System 后端架构"
        subgraph "SDR_System-admin (Web入口)"
            A1[UserDietApiController<br/>用户端API]
            A2[启动类<br/>Application]
            A3[配置文件<br/>application.yml]
        end
        
        subgraph "SDR_System-diet (核心业务)"
            B1[SmartRecommendationController<br/>智能推荐API]
            B2[DietMLController<br/>ML管理API]
            B3[SmartRecommendationService<br/>推荐服务]
            B4[MLDataService<br/>ML数据服务]
            B5[DietRecordService<br/>记录服务]
        end
        
        subgraph "SDR_System-framework (框架层)"
            C1[CorsConfig<br/>跨域配置]
            C2[SecurityConfig<br/>安全配置]
            C3[Token拦截器]
        end
        
        subgraph "SDR_System-system (系统管理)"
            D1[用户管理]
            D2[菜单管理]
            D3[权限管理]
        end
        
        subgraph "SDR_System-common (通用工具)"
            E1[工具类]
            E2[常量定义]
            E3[异常处理]
        end
    end
    
    A1 --> B1
    A1 --> B3
    B1 --> B3
    B2 --> B4
    B1 --> B5
    
    A2 --> C1
    C3 --> C2
    
    B3 --> E1
    B4 --> E1
    
    style B1 fill:#FFD700
    style B2 fill:#FFD700
    style B3 fill:#FFD700
```

---

## 4. 数据库架构图

```mermaid
graph TB
    subgraph "MySQL 主数据库"
        M1[(sys_user_health<br/>用户健康数据<br/>160条)]
        M2[(diet_food_info<br/>食物基础信息<br/>55种)]
        M3[(diet_food_nutrition<br/>食物营养数据<br/>55种)]
        M4[(diet_record<br/>饮食记录<br/>331条)]
        M5[(diet_recommendation<br/>推荐记录<br/>68条)]
        M6[(diet_ai_recognition<br/>AI识别记录)]
        M7[(diet_food_category<br/>食物分类)]
    end
    
    subgraph "MongoDB 详细存储"
        N1[(diet_record_detail<br/>记录详情JSON)]
        N2[(用户行为日志)]
    end
    
    subgraph "Neo4j 知识图谱"
        G1((Food<br/>食物节点))
        G2((Nutrient<br/>营养素节点))
        G3((Disease<br/>疾病节点))
        G4((HealthGoal<br/>健康目标))
    end
    
    M2 --> M3
    M1 --> M4
    M2 --> M4
    M1 --> M5
    M2 --> M5
    
    M4 -.详情.-> N1
    
    G1 -->|CONTAINS| G2
    G1 -->|SUITABLE_FOR| G4
    G1 -->|UNSUITABLE_FOR| G3
    
    style M1 fill:#FF6B6B
    style M5 fill:#FFD700
```

---

## 5. AI智能推荐模块图

```mermaid
graph LR
    subgraph "用户输入"
        A[用户ID<br/>餐次类型]
    end
    
    subgraph "步骤1: 健康数据获取"
        B1[查询用户健康数据]
        B2[BMI: 体重指数]
        B3[BMR: 基础代谢率]
        B4[营养目标]
        B5[饮食偏好]
        B6[不喜欢食材]
    end
    
    subgraph "步骤2: 营养目标计算"
        C1[calculate_meal_nutrition_target]
        C2[早餐30%]
        C3[午餐40%]
        C4[晚餐30%]
        C5[加餐10%]
    end
    
    subgraph "步骤3: 候选食物查询"
        D1[diet_food_info]
        D2[diet_food_nutrition]
        D3[status='0'<br/>calories>0]
    end
    
    subgraph "步骤4: 偏好过滤"
        E1[排除不喜欢食材]
        E2[过敏原过滤]
        E3[慢性病规则]
    end
    
    subgraph "步骤5: 营养匹配评分"
        F1[calculate_nutrition_match_score]
        F2[热量评分 40%]
        F3[蛋白质评分 25%]
        F4[碳水评分 20%]
        F5[脂肪评分 15%]
    end
    
    subgraph "步骤6: 历史反馈加权"
        G1[查询历史推荐]
        G2[用户评分]
        G3[营养70%+历史30%]
    end
    
    subgraph "步骤7: 排序输出"
        H1[按final_score降序]
        H2[返回TOP 10]
        H3[推荐结果展示]
    end
    
    A --> B1
    B1 --> B2 & B3 & B4 & B5 & B6
    B2 & B3 & B4 --> C1
    C1 --> C2 & C3 & C4 & C5
    C2 & C3 & C4 & C5 --> D1
    D1 --> D2
    D2 --> D3
    D3 --> E1
    E1 --> E2 --> E3
    E3 --> F1
    F1 --> F2 & F3 & F4 & F5
    F2 & F3 & F4 & F5 --> G1
    G1 --> G2 --> G3
    G3 --> H1 --> H2 --> H3
    
    style A fill:#4CAF50
    style C1 fill:#FFD700
    style F1 fill:#FFD700
    style H3 fill:#FF6B6B
```

---

## 6. 用户端功能模块图

```mermaid
graph TB
    subgraph "用户端核心功能"
        A[用户登录]
        
        subgraph "首页功能"
            B1[ML横幅展示]
            B2[今日营养摄入]
            B3[快捷操作]
            B4[饮食记录展示]
        end
        
        subgraph "AI智能推荐⭐"
            C1[算法说明]
            C2[餐次选择]
            C3[营养目标展示]
            C4[推荐结果列表]
            C5[匹配度评分]
            C6[推荐理由]
            C7[算法工作原理]
            C8[推荐质量分析]
        end
        
        subgraph "营养分析"
            D1[时间范围选择]
            D2[营养统计数据]
            D3[可视化图表]
            D4[AI饮食建议]
        end
        
        subgraph "饮食记录"
            E1[记录列表]
            E2[添加记录]
            E3[删除记录]
            E4[营养标签]
        end
        
        subgraph "食物库"
            F1[食物展示55种]
            F2[搜索功能]
            F3[营养详情]
        end
        
        subgraph "健康画像"
            G1[BMI/BMR展示]
            G2[基础信息]
            G3[代谢指标]
            G4[健康目标]
        end
    end
    
    A --> B1
    B1 --> C1
    B1 --> D1
    B1 --> E1
    B1 --> F1
    B1 --> G1
    
    C1 --> C2 --> C3 --> C4
    C4 --> C5 & C6
    C4 --> C7 --> C8
    
    D1 --> D2 --> D3 --> D4
    E1 --> E2 & E3 & E4
    F1 --> F2 --> F3
    G1 --> G2 --> G3 --> G4
    
    style C1 fill:#FFD700
    style C4 fill:#FFD700
```

---

## 7. 管理端功能模块图

```mermaid
graph TB
    subgraph "管理端核心功能"
        A[管理员登录]
        
        subgraph "首页仪表板"
            B1[系统概览]
            B2[数据统计]
            B3[快捷入口]
        end
        
        subgraph "ML推荐管理⭐"
            C1[推荐效果分析]
            C2[总推荐数: 68条]
            C3[接受率: 60.29%]
            C4[平均评分: 90.86]
            C5[活跃用户: 31人]
            C6[算法性能对比]
            C7[ML智能推荐 88%]
            C8[规则推荐 7%]
            C9[快速推荐 4%]
            C10[模型训练功能]
            C11[实时进度追踪]
            C12[模式切换]
        end
        
        subgraph "用户管理"
            D1[用户列表]
            D2[用户搜索]
            D3[健康数据查看]
            D4[权限管理]
        end
        
        subgraph "食物管理"
            E1[食物列表]
            E2[营养数据维护]
            E3[分类管理]
        end
        
        subgraph "系统设置"
            F1[算法参数配置]
            F2[系统参数]
            F3[菜单管理]
        end
    end
    
    A --> B1
    B1 --> C1
    B1 --> D1
    B1 --> E1
    B1 --> F1
    
    C1 --> C2 & C3 & C4 & C5
    C1 --> C6
    C6 --> C7 & C8 & C9
    C1 --> C10
    C10 --> C11 --> C12
    
    D1 --> D2 --> D3 --> D4
    E1 --> E2 --> E3
    F1 --> F2 --> F3
    
    style C1 fill:#FFD700
    style C2 fill:#FF6B6B
    style C10 fill:#4CAF50
```

---

## 8. 核心业务流程图

### 8.1 智能推荐业务流程（紧凑版）

```mermaid
flowchart LR
    Start([访问推荐页]) --> Step1[选择餐次]
    Step1 --> Step2{健康数据}
    Step2 -->|成功| Step3[计算营养目标]
    Step2 -->|失败| Error1[提示完善]
    
    Step3 --> Step4[查询食物]
    Step4 --> Step5[偏好过滤]
    Step5 --> Step6[营养评分⭐]
    Step6 --> Step7[历史反馈]
    Step7 --> Step8[综合评分⭐]
    Step8 --> Step9[健康过滤]
    Step9 --> Step10[排序TOP10]
    Step10 --> End([展示结果])
    
    Error1 --> End
    
    style Start fill:#4CAF50
    style Step6 fill:#FFD700
    style Step8 fill:#FFD700
    style End fill:#FF6B6B
```

### 8.1.1 智能推荐业务流程（分组版）

```mermaid
flowchart TD
    Start([用户访问AI推荐页面]) --> Step1[选择餐次]
    
    subgraph 准备阶段
        Step1 --> Step2{获取健康数据}
        Step2 -->|成功| Step3[计算营养目标]
        Step2 -->|失败| Error1[提示完善]
    end
    
    subgraph 候选筛选
        Step3 --> Step4[查询55种食物]
        Step4 --> Step5[偏好过滤]
    end
    
    subgraph 评分计算⭐
        Step5 --> Step6[营养评分<br/>四维算法]
        Step6 --> Step7[查询历史]
        Step7 --> Step8[综合评分<br/>70%+30%]
    end
    
    subgraph 输出生成
        Step8 --> Step9[健康规则过滤]
        Step9 --> Step10[排序TOP10]
        Step10 --> Step11[生成理由+份量]
    end
    
    Step11 --> End([展示结果])
    Error1 --> End
    
    style Start fill:#4CAF50
    style Step6 fill:#FFD700
    style Step8 fill:#FFD700
    style End fill:#FF6B6B
```

### 8.1.2 智能推荐核心算法（极简版）

```mermaid
flowchart LR
    A([用户输入]) --> B[营养目标]
    B --> C[食物筛选]
    C --> D[评分算法⭐]
    D --> E[综合评分]
    E --> F[TOP10]
    F --> G([推荐结果])
    
    style D fill:#FFD700
    style E fill:#FFD700
```

### 8.2 饮食记录业务流程（紧凑版）

```mermaid
flowchart LR
    Start([添加记录]) --> Step1{录入方式}
    Step1 -->|手动| Step2[搜索食物]
    Step1 -->|AI| Step3[上传照片]
    
    Step2 --> Step4[选择食物]
    Step3 --> Step5{AI识别}
    Step5 -->|成功| Step4
    Step5 -->|失败| Step2
    
    Step4 --> Step6[输入份量+餐次]
    Step6 --> Step7[计算营养⭐]
    Step7 --> Step8[保存数据]
    Step8 --> Step9[更新统计]
    Step9 --> End([保存成功])
    
    style Start fill:#4CAF50
    style Step7 fill:#FFD700
    style End fill:#FF6B6B
```

### 8.2.1 饮食记录业务流程（分组版）

```mermaid
flowchart TD
    Start([用户添加记录])
    
    subgraph 食物识别
        Start --> Step1{录入方式}
        Step1 -->|手动| Step2[搜索选择]
        Step1 -->|AI识别| Step3[上传照片]
        Step3 --> Step4{识别结果}
        Step4 -->|成功| Step5[确认食物]
        Step4 -->|失败| Step2
        Step2 --> Step5
    end
    
    subgraph 数据录入
        Step5 --> Step6[输入份量]
        Step6 --> Step7[选择餐次]
    end
    
    subgraph 营养计算⭐
        Step7 --> Step8[自动计算营养素]
    end
    
    subgraph 数据存储
        Step8 --> Step9[MySQL主表]
        Step9 --> Step10[MongoDB详情]
        Step10 --> Step11[更新统计]
    end
    
    Step11 --> End([完成])
    
    style Start fill:#4CAF50
    style Step8 fill:#FFD700
    style End fill:#FF6B6B
```

### 8.3 ML模型训练流程（紧凑版）

```mermaid
flowchart LR
    Start([启动训练]) --> Step1{选择模型}
    Step1 -->|协同| M1[CF]
    Step1 -->|内容| M2[CB]
    Step1 -->|深度| M3[DL]
    
    M1 & M2 & M3 --> Step2[加载数据68条]
    Step2 --> Step3{训练模式}
    Step3 -->|模拟| Step4[模拟进度]
    Step3 -->|真实| Step5[真实训练⭐]
    
    Step4 & Step5 --> Step6[更新进度]
    Step6 --> Step7{完成?}
    Step7 -->|否| Step6
    Step7 -->|是| End([训练完成])
    
    style Start fill:#4CAF50
    style Step5 fill:#FFD700
    style End fill:#FF6B6B
```

### 8.3.1 ML模型训练流程（分组版）

```mermaid
flowchart TD
    Start([管理员启动训练])
    
    subgraph 模型选择
        Start --> Step1[选择模型类型]
        Step1 --> Step2{模型}
        Step2 -->|协同过滤| M1[CF]
        Step2 -->|内容推荐| M2[CB]
        Step2 -->|深度学习| M3[DL]
    end
    
    subgraph 数据准备
        M1 & M2 & M3 --> Step3[加载68条记录]
    end
    
    subgraph 训练执行⭐
        Step3 --> Step4{模式}
        Step4 -->|模拟| Step5[模拟进度]
        Step4 -->|真实| Step6[实际训练]
        Step5 & Step6 --> Step7[实时更新]
        Step7 --> Step8{完成?}
        Step8 -->|否| Step7
    end
    
    subgraph 结果保存
        Step8 -->|是| Step9[保存记录]
        Step9 --> Step10[更新状态]
    end
    
    Step10 --> End([完成])
    
    style Start fill:#4CAF50
    style Step6 fill:#FFD700
    style End fill:#FF6B6B
```

---

## 9. 数据流转图

```mermaid
flowchart LR
    subgraph "用户交互层"
        A1[用户端浏览器]
        A2[管理端浏览器]
    end
    
    subgraph "API网关层"
        B1[用户端API<br/>UserDietApiController]
        B2[管理端API<br/>DietMLController]
        B3[推荐API<br/>SmartRecommendationController]
    end
    
    subgraph "业务逻辑层"
        C1[推荐服务<br/>SmartRecommendationService]
        C2[ML数据服务<br/>MLDataService]
        C3[记录服务<br/>DietRecordService]
    end
    
    subgraph "数据访问层"
        D1[MyBatis Mapper]
        D2[MongoDB Repository]
        D3[Neo4j Repository]
    end
    
    subgraph "数据存储层"
        E1[(MySQL)]
        E2[(MongoDB)]
        E3[(Neo4j)]
    end
    
    subgraph "外部服务"
        F1[Python ML服务<br/>:8001]
    end
    
    A1 -->|HTTP请求| B1
    A2 -->|HTTP请求| B2
    A1 -->|推荐请求| B3
    
    B1 --> C3
    B2 --> C2
    B3 --> C1
    
    C1 --> D1
    C2 --> D1
    C3 --> D1
    C3 --> D2
    C1 --> D3
    
    D1 -->|SQL查询| E1
    D2 -->|文档操作| E2
    D3 -->|图查询| E3
    
    E1 -->|数据返回| D1
    E2 -->|数据返回| D2
    E3 -->|数据返回| D3
    
    C2 <-->|HTTP调用| F1
    
    style B3 fill:#FFD700
    style C1 fill:#FFD700
    style E1 fill:#FF6B6B
```

---

## 10. ML算法模块图

```mermaid
graph TB
    subgraph "ML算法体系"
        subgraph "核心算法函数 (SQL)"
            A1[calculate_meal_nutrition_target<br/>营养目标计算]
            A2[calculate_nutrition_match_score<br/>营养匹配评分]
            A3[generate_personalized_recommendation<br/>个性化推荐]
        end
        
        subgraph "优化算法"
            B1[get_recent_food_penalty<br/>近期推荐惩罚]
            B2[calculate_category_diversity_bonus<br/>分类多样性奖励]
        end
        
        subgraph "评分维度"
            C1[热量评分<br/>权重40%]
            C2[蛋白质评分<br/>权重25%]
            C3[碳水评分<br/>权重20%]
            C4[脂肪评分<br/>权重15%]
        end
        
        subgraph "综合评分"
            D1[营养匹配度<br/>权重70%]
            D2[历史反馈<br/>权重30%]
            D3[最终评分<br/>0-100分]
        end
        
        subgraph "健康规则过滤"
            E1[过敏原过滤]
            E2[慢性病规则<br/>糖尿病/高血压/痛风]
            E3[饮食偏好<br/>素食/低糖/低盐]
        end
        
        subgraph "ML模型 (Python)"
            F1[协同过滤模型<br/>Collaborative Filtering]
            F2[内容推荐模型<br/>Content-Based]
            F3[深度学习模型<br/>Deep Learning]
        end
    end
    
    A1 --> A2
    A2 --> C1 & C2 & C3 & C4
    C1 & C2 & C3 & C4 --> D1
    A3 --> D2
    D1 & D2 --> D3
    
    A3 --> B1 & B2
    A3 --> E1 & E2 & E3
    
    D3 --> F1 & F2 & F3
    
    style A2 fill:#FFD700
    style A3 fill:#FFD700
    style D3 fill:#FF6B6B
```

---

## 📊 图表说明

### 流程图版本对比

每个核心业务流程提供了**3个版本**，您可以根据使用场景选择：

| 版本 | 特点 | 适用场景 | 推荐度 |
|------|------|----------|--------|
| **紧凑版 (LR)** | 横向布局，节点文字精简 | PPT展示、宽屏显示、快速理解 | ⭐⭐⭐⭐⭐ |
| **分组版 (TD)** | 使用subgraph分阶段 | 详细文档、技术讨论、逻辑清晰 | ⭐⭐⭐⭐ |
| **极简版 (LR)** | 只保留核心步骤 | 答辩演示、概览说明、时间紧张 | ⭐⭐⭐ |

**推荐使用**：
- **答辩PPT**：极简版或紧凑版
- **答辩讲解**：紧凑版（边讲边指）
- **文档说明**：分组版（结构清晰）
- **快速预览**：极简版

### 优化效果对比

**原版本问题**：
- ❌ 节点文字过长（如"计算个性化营养目标<br/>基于BMR/BMI"）
- ❌ 纵向布局过长，不适合宽屏
- ❌ 13个步骤节点，视觉拥挤

**紧凑版优化**：
- ✅ 文字精简50%（如"计算营养目标"）
- ✅ 横向布局，适合宽屏展示
- ✅ 保留核心逻辑，视觉清爽

**分组版优化**：
- ✅ 按业务阶段分组（准备→筛选→评分→输出）
- ✅ 层次分明，便于理解
- ✅ 重点模块标注⭐

**极简版优化**：
- ✅ 只保留7个核心节点
- ✅ 适合快速讲解（30秒内）
- ✅ 突出核心算法

### 使用说明
1. 将以上Mermaid代码复制到支持Mermaid的Markdown编辑器中查看
2. 推荐工具：
   - **Typora** - 最佳体验，自动渲染
   - **VS Code** - 安装 "Markdown Preview Mermaid Support" 插件
   - **在线工具** - https://mermaid.live/ （可导出PNG/SVG）
   - **GitHub** - 直接支持Mermaid语法，push后自动渲染

### 图表类型
- `graph TB/LR`: 流程图 (上下/左右布局)
- `flowchart TD/LR`: 增强流程图（推荐使用）
- `subgraph`: 子图模块分组

### 颜色说明
- 🟡 黄色 (#FFD700): 核心/重点模块（算法、计算）
- 🔴 红色 (#FF6B6B): 数据库/输出结果
- 🟢 绿色 (#4CAF50): 起始/用户输入
- 🔵 蓝色 (#2196F3): 一般模块
- 🟣 紫色 (#9C27B0): AI/ML服务

### 导出为图片
在 https://mermaid.live/ 中：
1. 粘贴代码到左侧编辑器
2. 右侧实时预览
3. 点击 **Actions** → **Download PNG** 或 **Download SVG**
4. 插入到PPT/Word中使用

---

**创建日期**: 2025-10-17  
**更新日期**: 2025-10-17  
**版本**: v1.1 (优化版)  
**适用范围**: 毕业设计答辩、系统文档、技术汇报
