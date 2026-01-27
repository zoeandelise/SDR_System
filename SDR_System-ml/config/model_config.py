"""
机器学习模型配置文件
定义各个推荐模型的参数和配置
"""

# 协同过滤模型配置
COLLABORATIVE_FILTERING_CONFIG = {
    "algorithm": "KNNBasic",  # 可选: KNNBasic, KNNWithMeans, SVD, NMF
    "k": 40,  # 邻居数量
    "min_k": 5,  # 最小邻居数
    "similarity": "cosine",  # 相似度度量: cosine, pearson, msd
    "user_based": True,  # True为基于用户，False为基于物品
    "verbose": True
}

# 内容推荐模型配置
CONTENT_BASED_CONFIG = {
    "features": [
        "calories", "protein", "fat", "carbohydrate", 
        "fiber", "vitamin_c", "calcium", "iron"
    ],
    "similarity_threshold": 0.6,
    "max_recommendations": 20,
    "diversity_weight": 0.3,  # 多样性权重
    "normalization": "min_max"  # 特征归一化方法
}

# 深度学习模型配置
DEEP_LEARNING_CONFIG = {
    "model_type": "neural_collaborative_filtering",  # NCF模型
    "embedding_dim": 50,  # 嵌入维度
    "hidden_layers": [100, 50, 25],  # 隐藏层结构
    "dropout_rate": 0.2,
    "learning_rate": 0.001,
    "batch_size": 256,
    "epochs": 100,
    "early_stopping_patience": 10
}

# 混合推荐配置
HYBRID_CONFIG = {
    "weights": {
        "collaborative": 0.4,  # 协同过滤权重
        "content": 0.3,        # 内容推荐权重
        "deep": 0.3           # 深度学习权重
    },
    "min_confidence": 0.5,  # 最小置信度
    "diversity_boost": True,  # 是否增强多样性
    "cold_start_strategy": "content_based"  # 冷启动策略
}

# 训练参数配置
TRAINING_CONFIG = {
    "test_size": 0.2,  # 测试集比例
    "validation_size": 0.1,  # 验证集比例
    "random_state": 42,
    "cross_validation_folds": 5,
    "metrics": ["rmse", "mae", "precision_k", "recall_k", "f1_k"],
    "k_values": [5, 10, 20]  # Top-K评估的K值
}

# 数据预处理配置
DATA_CONFIG = {
    "min_interactions": 5,  # 用户最少交互次数
    "min_ratings": 3,       # 食物最少评分次数
    "rating_scale": (1, 5), # 评分范围
    "implicit_threshold": 3, # 隐式反馈阈值
    "time_decay": True,     # 是否应用时间衰减
    "decay_factor": 0.95    # 时间衰减因子
}

# 模型评估配置
EVALUATION_CONFIG = {
    "online_metrics": ["ctr", "conversion_rate", "diversity", "novelty"],
    "offline_metrics": ["precision", "recall", "ndcg", "coverage"],
    "evaluation_period": "weekly",  # 评估周期
    "min_evaluation_data": 100     # 最少评估数据量
}
