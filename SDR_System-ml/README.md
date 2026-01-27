# 智能饮食推荐ML服务 v2.0

基于协同过滤和深度学习的个性化饮食推荐系统机器学习服务。

## 🎯 版本特性

### V2.0 新特性
- ✅ **统一服务架构**：将10+个服务文件统一为单一入口 `main_service.py`
- ✅ **真实训练**：移除模拟训练，仅支持真实ML模型训练
- ✅ **异步训练队列**：支持多模型并行训练
- ✅ **实时进度更新**：训练进度实时写入数据库
- ✅ **优化算法**：改进协同过滤、内容推荐和深度学习算法
- ✅ **简化部署**：一键启动脚本，自动检查环境和依赖

## 📋 系统要求

- **Python**: 3.8+ 
- **数据库**: MySQL 5.7+, MongoDB 4.0+, Redis 5.0+
- **内存**: 建议 4GB+
- **磁盘**: 至少 2GB 可用空间

## 🚀 快速开始

### 1. 安装依赖

```bash
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 2. 配置环境

复制配置文件并根据实际情况修改：

```bash
cp config.env.example config.env
```

编辑 `config.env` 文件，配置数据库连接信息：

```env
# MySQL配置
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DATABASE=smart_diet_dev

# MongoDB配置
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_DATABASE=diet_system

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
```

### 3. 启动服务

#### Windows:
```bash
start_ml_service.bat
```

#### Linux/Mac:
```bash
chmod +x start_ml_service.sh
./start_ml_service.sh
```

#### 或直接运行:
```bash
python main_service.py
```

服务将在 **http://localhost:8001** 启动

## 📡 API文档

启动服务后访问：
- **Swagger UI**: http://localhost:8001/docs
- **ReDoc**: http://localhost:8001/redoc

### 主要接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/health` | GET | 健康检查 |
| `/api/model/train` | POST | 启动模型训练 |
| `/api/training/progress` | GET | 查询训练进度 |
| `/api/training/stop` | POST | 停止训练 |
| `/api/recommend` | POST | 获取推荐 |
| `/api/models/status` | GET | 查询模型状态 |

### 训练接口示例

```bash
curl -X POST "http://localhost:8001/api/model/train" \
  -H "Content-Type: application/json" \
  -d '{
    "model_type": "collaborative_filtering",
    "training_days": 180,
    "training_id": 1
  }'
```

### 推荐接口示例

```bash
curl -X POST "http://localhost:8001/api/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "meal_type": "1",
    "n_recommendations": 10
  }'
```

## 🧠 支持的模型

本系统采用**协同过滤算法与营养学约束规则相结合**的混合推荐模型，这是本研究的核心创新点。

### 1. 协同过滤模型 (Collaborative Filtering) ⭐核心算法
- **算法**: SVD (Singular Value Decomposition)
- **特点**: 基于用户行为相似度，通过分析相似用户的饮食选择进行推荐
- **适用**: 有历史交互数据的用户
- **优势**: "物以类聚，人以群分"，推荐准确度高

### 2. 内容推荐模型 (Content-Based) ⭐营养学约束
- **算法**: 余弦相似度 + 营养特征匹配
- **特点**: 基于食物营养成分相似度，结合营养学约束规则
- **适用**: 新用户、冷启动场景、特殊健康需求用户
- **优势**: 能够确保推荐结果符合营养学标准和用户健康需求

### 3. 混合推荐模型 (Hybrid) ⭐创新点
- **算法**: 加权融合协同过滤 + 内容推荐 + 营养学约束规则
- **特点**: 
  - 个性化推荐：协同过滤算法分析用户相似性
  - 健康约束：营养学规则过滤不适合的食物
  - 冷启动处理：内容推荐为新用户提供初始推荐
- **推荐**: 生产环境使用，体现本研究创新性

## 📁 项目结构

```
SDR_System-ml/
├── main_service.py          # 主服务入口（新）
├── config/                  # 配置文件
│   └── model_config.py
├── models/                  # 模型定义
│   ├── model_manager.py
│   ├── collaborative_filtering.py
│   ├── content_based.py
│   ├── deep_learning.py
│   └── hybrid_recommender.py
├── training/                # 训练模块
│   └── model_trainer.py
├── data/                    # 数据处理
│   └── data_loader.py
├── utils/                   # 工具函数
│   └── config.py
├── logs/                    # 日志目录
├── models/saved/            # 保存的模型
├── start_ml_service.bat     # Windows启动脚本
├── start_ml_service.sh      # Linux/Mac启动脚本
└── requirements.txt         # Python依赖
```

## 🔧 训练流程

### 1. 手动训练

通过管理界面 (http://localhost:81/diet/ml/management) 或API接口启动训练。

### 2. 训练步骤

```
1. 数据加载 (10%)
2. 数据预处理 (20%)
3. 特征工程 (30%)
4. 模型训练 (60%)
5. 模型验证 (80%)
6. 模型保存 (100%)
```

### 3. 训练时间

- 协同过滤: 约 60-90秒
- 内容推荐: 约 40-60秒
- 混合模型优化: 约 20-30秒
- 总计: 约 2-3分钟

## 🐛 故障排查

### 问题1: 服务无法启动

```bash
# 检查端口是否被占用
netstat -ano | findstr "8001"  # Windows
lsof -i :8001                  # Linux/Mac

# 检查Python版本
python --version

# 检查依赖是否安装
pip list | grep fastapi
```

### 问题2: 数据库连接失败

```bash
# 检查MySQL是否运行
mysql -h localhost -u root -p

# 检查配置文件
cat config.env

# 测试连接
python -c "from data.data_loader import DataLoader; DataLoader()"
```

### 问题3: 训练失败

- 检查数据库中是否有足够的训练数据 (建议 > 100条)
- 查看日志文件: `logs/ml_service.log`
- 检查训练历史表: `ml_training_history`

### 问题4: 内存不足

- 减少训练数据天数 (如从365天改为180天)
- 调整batch_size参数
- 关闭其他占用内存的程序

## 📊 性能优化建议

1. **数据库索引**: 确保训练相关表已创建索引
2. **Redis缓存**: 启用Redis缓存推荐结果
3. **模型预加载**: 服务启动时自动加载已训练模型
4. **并行训练**: 避免同时训练多个模型

## 🔐 安全建议

1. 生产环境修改默认密码
2. 使用环境变量存储敏感信息
3. 启用API认证
4. 限制API访问频率

## 📝 更新日志

### v2.0.0 (2025-10-31)
- 🎉 **重大重构**: 统一服务架构
- 🗑️ 移除模拟训练功能
- 🗑️ 移除深度学习模块（聚焦核心算法）
- ⚡ 优化协同过滤和内容推荐算法
- 🎨 全新管理界面
- 📚 完善文档和启动脚本
- 💡 突出创新点：协同过滤与营养学约束相结合

### v1.0.0 (2025-10-10)
- 初始版本发布

## 🤝 参与贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

本项目采用 MIT 许可证

## 👨‍💻 作者

向俊宇 - 湖南信息学院

## 📧 联系方式

如有问题，请通过以下方式联系：
- 邮箱: student@example.com
- 项目地址: https://github.com/username/SDR_System

---

**注意**: 本项目仅用于学术研究和学习交流，不得用于商业用途。
