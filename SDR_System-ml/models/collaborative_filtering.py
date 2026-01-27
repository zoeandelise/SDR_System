"""
协同过滤推荐模型（优化版）
基于用户相似度进行推荐
改进：支持隐式反馈、优化相似度计算、添加冷启动处理
"""

import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.model_selection import train_test_split
import joblib
import os
from config.model_config import COLLABORATIVE_FILTERING_CONFIG
import logging

logger = logging.getLogger(__name__)

class CollaborativeFiltering:
    def __init__(self, config=None):
        self.config = config or COLLABORATIVE_FILTERING_CONFIG
        self.user_similarity_matrix = None
        self.item_similarity_matrix = None
        self.user_item_matrix = None
        self.user_mapping = {}
        self.item_mapping = {}
        self.reverse_user_mapping = {}
        self.reverse_item_mapping = {}
        self.global_mean = 0.0  # 全局平均评分
        
    def prepare_data(self, interactions_df):
        """准备训练数据"""
        # 过滤低频用户和物品（降低阈值以适应数据稀疏）
        user_counts = interactions_df['user_id'].value_counts()
        item_counts = interactions_df['food_id'].value_counts()
        
        # 降低阈值：用户至少2条交互，食物至少被2个用户交互
        valid_users = user_counts[user_counts >= 2].index
        valid_items = item_counts[item_counts >= 2].index
        
        filtered_df = interactions_df[
            (interactions_df['user_id'].isin(valid_users)) &
            (interactions_df['food_id'].isin(valid_items))
        ]
        
        logger.info(f"数据过滤: {len(interactions_df)} → {len(filtered_df)} 条交互")
        
        # 创建用户和物品映射
        unique_users = filtered_df['user_id'].unique()
        unique_items = filtered_df['food_id'].unique()
        
        self.user_mapping = {user_id: idx for idx, user_id in enumerate(unique_users)}
        self.item_mapping = {item_id: idx for idx, item_id in enumerate(unique_items)}
        self.reverse_user_mapping = {idx: user_id for user_id, idx in self.user_mapping.items()}
        self.reverse_item_mapping = {idx: item_id for item_id, idx in self.item_mapping.items()}
        
        # 创建用户-物品矩阵
        n_users = len(unique_users)
        n_items = len(unique_items)
        
        self.user_item_matrix = np.zeros((n_users, n_items))
        
        for _, row in filtered_df.iterrows():
            user_idx = self.user_mapping[row['user_id']]
            item_idx = self.item_mapping[row['food_id']]
            # 使用评分或隐式反馈
            rating = row.get('rating', 1.0)
            self.user_item_matrix[user_idx, item_idx] = rating
            
        return filtered_df
    
    def compute_user_similarity(self):
        """计算用户相似度矩阵"""
        # 使用余弦相似度
        self.user_similarity_matrix = cosine_similarity(self.user_item_matrix)
        
        # 移除对角线（自己与自己的相似度）
        np.fill_diagonal(self.user_similarity_matrix, 0)
        
    def compute_item_similarity(self):
        """计算物品相似度矩阵"""
        # 转置矩阵来计算物品相似度
        item_matrix = self.user_item_matrix.T
        self.item_similarity_matrix = cosine_similarity(item_matrix)
        np.fill_diagonal(self.item_similarity_matrix, 0)
    
    def train(self, interactions_df):
        """训练协同过滤模型"""
        logger.info("开始训练协同过滤模型...")
        
        try:
            # 准备数据
            filtered_df = self.prepare_data(interactions_df)
            
            # 计算全局平均评分（用于冷启动）
            self.global_mean = self.user_item_matrix[self.user_item_matrix > 0].mean()
            logger.info(f"全局平均评分: {self.global_mean:.2f}")
            
            # 计算相似度矩阵
            if self.config['user_based']:
                self.compute_user_similarity()
                logger.info("完成用户相似度计算")
            else:
                self.compute_item_similarity()
                logger.info("完成物品相似度计算")
            
            logger.info("协同过滤模型训练完成")
            return True
        except Exception as e:
            logger.error(f"协同过滤训练失败: {e}")
            return False
    
    def predict_user_preference(self, user_id, food_id):
        """预测用户对特定食物的偏好"""
        if user_id not in self.user_mapping or food_id not in self.item_mapping:
            return 0.0
            
        user_idx = self.user_mapping[user_id]
        item_idx = self.item_mapping[food_id]
        
        if self.config['user_based']:
            # 基于用户的协同过滤
            similar_users = self.user_similarity_matrix[user_idx]
            user_ratings = self.user_item_matrix[:, item_idx]
            
            # 加权平均
            numerator = np.sum(similar_users * user_ratings)
            denominator = np.sum(np.abs(similar_users))
            
            if denominator > 0:
                return numerator / denominator
        else:
            # 基于物品的协同过滤
            similar_items = self.item_similarity_matrix[item_idx]
            user_ratings = self.user_item_matrix[user_idx, :]
            
            numerator = np.sum(similar_items * user_ratings)
            denominator = np.sum(np.abs(similar_items))
            
            if denominator > 0:
                return numerator / denominator
                
        return 0.0
    
    def recommend(self, user_id, n_recommendations=10, exclude_seen=True):
        """为用户生成推荐"""
        if user_id not in self.user_mapping:
            return []
            
        user_idx = self.user_mapping[user_id]
        scores = []
        
        for item_idx in range(len(self.reverse_item_mapping)):
            food_id = self.reverse_item_mapping[item_idx]
            
            # 排除已评分的物品
            if exclude_seen and self.user_item_matrix[user_idx, item_idx] > 0:
                continue
                
            score = self.predict_user_preference(user_id, food_id)
            scores.append((food_id, score))
        
        # 按分数排序并返回Top-N
        scores.sort(key=lambda x: x[1], reverse=True)
        return scores[:n_recommendations]
    
    def save_model(self, filepath):
        """保存模型"""
        try:
            # 确保目录存在
            import os
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            
            model_data = {
                'config': self.config,
                'user_similarity_matrix': self.user_similarity_matrix,
                'item_similarity_matrix': self.item_similarity_matrix,
                'user_item_matrix': self.user_item_matrix,
                'user_mapping': self.user_mapping,
                'item_mapping': self.item_mapping,
                'reverse_user_mapping': self.reverse_user_mapping,
                'reverse_item_mapping': self.reverse_item_mapping,
                'global_mean': self.global_mean
            }
            joblib.dump(model_data, filepath)
            logger.info(f"✅ 协同过滤模型已保存到: {filepath}")
            return True
        except Exception as e:
            logger.error(f"❌ 保存协同过滤模型失败: {e}")
            return False
    
    def load_model(self, filepath):
        """加载模型"""
        if os.path.exists(filepath):
            model_data = joblib.load(filepath)
            self.config = model_data['config']
            self.user_similarity_matrix = model_data['user_similarity_matrix']
            self.item_similarity_matrix = model_data['item_similarity_matrix']
            self.user_item_matrix = model_data['user_item_matrix']
            self.user_mapping = model_data['user_mapping']
            self.item_mapping = model_data['item_mapping']
            self.reverse_user_mapping = model_data['reverse_user_mapping']
            self.reverse_item_mapping = model_data['reverse_item_mapping']
            print(f"协同过滤模型已从 {filepath} 加载")
            return True
        return False
    
    def evaluate(self, test_df, metrics=['precision', 'recall', 'f1']):
        """评估模型性能"""
        results = {}
        
        # 实现各种评估指标
        for metric in metrics:
            if metric == 'precision':
                results[metric] = self._compute_precision(test_df)
            elif metric == 'recall':
                results[metric] = self._compute_recall(test_df)
            elif metric == 'f1':
                precision = results.get('precision', self._compute_precision(test_df))
                recall = results.get('recall', self._compute_recall(test_df))
                results[metric] = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
                
        return results
    
    def _compute_precision(self, test_df, k=10):
        """计算Precision@K"""
        # 简化的precision计算
        total_precision = 0
        valid_users = 0
        
        for user_id in test_df['user_id'].unique():
            if user_id in self.user_mapping:
                recommendations = self.recommend(user_id, n_recommendations=k)
                user_test_items = set(test_df[test_df['user_id'] == user_id]['food_id'])
                recommended_items = set([item[0] for item in recommendations])
                
                if len(recommended_items) > 0:
                    precision = len(user_test_items & recommended_items) / len(recommended_items)
                    total_precision += precision
                    valid_users += 1
        
        return total_precision / valid_users if valid_users > 0 else 0
    
    def _compute_recall(self, test_df, k=10):
        """计算Recall@K"""
        total_recall = 0
        valid_users = 0
        
        for user_id in test_df['user_id'].unique():
            if user_id in self.user_mapping:
                recommendations = self.recommend(user_id, n_recommendations=k)
                user_test_items = set(test_df[test_df['user_id'] == user_id]['food_id'])
                recommended_items = set([item[0] for item in recommendations])
                
                if len(user_test_items) > 0:
                    recall = len(user_test_items & recommended_items) / len(user_test_items)
                    total_recall += recall
                    valid_users += 1
        
        return total_recall / valid_users if valid_users > 0 else 0
