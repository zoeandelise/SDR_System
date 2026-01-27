"""
智能饮食推荐系统 - 高级推荐算法
包含：协同过滤、内容推荐、深度学习、混合推荐
"""

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity, euclidean_distances
from sklearn.decomposition import TruncatedSVD
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestRegressor
from sklearn.neural_network import MLPRegressor
import logging
from typing import List, Dict, Tuple, Optional, Any
import json
import pickle
import os
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

logger = logging.getLogger(__name__)

class CollaborativeFilteringRecommender:
    """协同过滤推荐算法"""
    
    def __init__(self, n_factors=50, learning_rate=0.01, regularization=0.02, n_epochs=100):
        self.n_factors = n_factors
        self.learning_rate = learning_rate
        self.regularization = regularization
        self.n_epochs = n_epochs
        self.user_factors = None
        self.item_factors = None
        self.user_bias = None
        self.item_bias = None
        self.global_mean = 0
        self.user_encoder = LabelEncoder()
        self.item_encoder = LabelEncoder()
        self.is_trained = False
        
    def fit(self, interactions_df: pd.DataFrame) -> Dict[str, Any]:
        """训练协同过滤模型"""
        logger.info("开始训练协同过滤模型...")
        
        # 数据预处理
        users = self.user_encoder.fit_transform(interactions_df['user_id'])
        items = self.item_encoder.fit_transform(interactions_df['food_id'])
        ratings = interactions_df['rating'].values.astype(np.float32)
        
        n_users = len(self.user_encoder.classes_)
        n_items = len(self.item_encoder.classes_)
        
        # 初始化参数
        self.user_factors = np.random.normal(0, 0.1, (n_users, self.n_factors))
        self.item_factors = np.random.normal(0, 0.1, (n_items, self.n_factors))
        self.user_bias = np.zeros(n_users)
        self.item_bias = np.zeros(n_items)
        self.global_mean = np.mean(ratings)
        
        # SGD训练
        training_losses = []
        for epoch in range(self.n_epochs):
            epoch_loss = 0
            
            # 随机打乱数据
            indices = np.random.permutation(len(interactions_df))
            
            for idx in indices:
                user = users[idx]
                item = items[idx]
                rating = ratings[idx]
                
                # 预测
                prediction = (self.global_mean + 
                            self.user_bias[user] + 
                            self.item_bias[item] + 
                            np.dot(self.user_factors[user], self.item_factors[item]))
                
                # 计算误差
                error = rating - prediction
                epoch_loss += error ** 2
                
                # 更新参数
                # 偏置项更新
                self.user_bias[user] += self.learning_rate * (error - self.regularization * self.user_bias[user])
                self.item_bias[item] += self.learning_rate * (error - self.regularization * self.item_bias[item])
                
                # 因子更新
                user_factors_copy = self.user_factors[user].copy()
                self.user_factors[user] += self.learning_rate * (error * self.item_factors[item] - 
                                                                self.regularization * self.user_factors[user])
                self.item_factors[item] += self.learning_rate * (error * user_factors_copy - 
                                                                self.regularization * self.item_factors[item])
            
            training_losses.append(epoch_loss / len(interactions_df))
            
            if epoch % 20 == 0:
                logger.info(f"Epoch {epoch}, Loss: {training_losses[-1]:.4f}")
        
        self.is_trained = True
        logger.info("协同过滤模型训练完成")
        
        return {
            "training_losses": training_losses,
            "final_loss": training_losses[-1],
            "n_users": n_users,
            "n_items": n_items
        }
    
    def predict(self, user_id: int, food_id: int) -> float:
        """预测用户对食物的评分"""
        if not self.is_trained:
            return self.global_mean
        
        try:
            user_idx = self.user_encoder.transform([user_id])[0]
            item_idx = self.item_encoder.transform([food_id])[0]
            
            prediction = (self.global_mean + 
                         self.user_bias[user_idx] + 
                         self.item_bias[item_idx] + 
                         np.dot(self.user_factors[user_idx], self.item_factors[item_idx]))
            
            return max(0, min(5, prediction))  # 限制在0-5范围内
        except ValueError:
            return self.global_mean
    
    def recommend(self, user_id: int, food_ids: List[int], n_recommendations: int = 10) -> List[Tuple[int, float]]:
        """为用户推荐食物"""
        if not self.is_trained:
            return [(food_id, 3.0) for food_id in food_ids[:n_recommendations]]
        
        predictions = []
        for food_id in food_ids:
            score = self.predict(user_id, food_id)
            predictions.append((food_id, score))
        
        # 按分数排序
        predictions.sort(key=lambda x: x[1], reverse=True)
        return predictions[:n_recommendations]

class ContentBasedRecommender:
    """基于内容的推荐算法"""
    
    def __init__(self):
        self.food_features = None
        self.tfidf_vectorizer = TfidfVectorizer(max_features=1000, stop_words='english')
        self.scaler = StandardScaler()
        self.feature_matrix = None
        self.food_encoder = LabelEncoder()
        self.is_trained = False
        
    def fit(self, food_df: pd.DataFrame, nutrition_df: pd.DataFrame) -> Dict[str, Any]:
        """训练内容推荐模型"""
        logger.info("开始训练内容推荐模型...")
        
        # 合并食物和营养信息
        food_data = food_df.merge(nutrition_df, on='food_id', how='left')
        
        # 提取特征
        # 1. 营养特征
        nutrition_features = ['calories', 'protein', 'fat', 'carbohydrate', 'fiber', 'sugar', 'sodium']
        nutrition_matrix = food_data[nutrition_features].fillna(0).values
        nutrition_matrix = self.scaler.fit_transform(nutrition_matrix)
        
        # 2. 文本特征（食物描述）
        descriptions = food_data['description'].fillna('')
        text_matrix = self.tfidf_vectorizer.fit_transform(descriptions).toarray()
        
        # 3. 分类特征
        categories = pd.get_dummies(food_data['category_id']).values
        
        # 合并所有特征
        self.feature_matrix = np.hstack([nutrition_matrix, text_matrix, categories])
        self.food_encoder.fit(food_data['food_id'])
        
        # 计算食物相似度矩阵
        self.similarity_matrix = cosine_similarity(self.feature_matrix)
        
        self.is_trained = True
        logger.info("内容推荐模型训练完成")
        
        return {
            "n_foods": len(food_data),
            "feature_dim": self.feature_matrix.shape[1],
            "nutrition_features": len(nutrition_features),
            "text_features": text_matrix.shape[1],
            "category_features": categories.shape[1]
        }
    
    def find_similar_foods(self, food_id: int, n_similar: int = 10) -> List[Tuple[int, float]]:
        """寻找相似食物"""
        if not self.is_trained:
            return []
        
        try:
            food_idx = self.food_encoder.transform([food_id])[0]
            similarities = self.similarity_matrix[food_idx]
            
            # 获取最相似的食物（排除自己）
            similar_indices = np.argsort(similarities)[::-1][1:n_similar+1]
            
            similar_foods = []
            for idx in similar_indices:
                similar_food_id = self.food_encoder.classes_[idx]
                similarity_score = similarities[idx]
                similar_foods.append((similar_food_id, similarity_score))
            
            return similar_foods
        except ValueError:
            return []
    
    def recommend_by_preferences(self, liked_foods: List[int], all_foods: List[int], 
                                n_recommendations: int = 10) -> List[Tuple[int, float]]:
        """基于用户喜好推荐"""
        if not self.is_trained or not liked_foods:
            return [(food_id, 0.5) for food_id in all_foods[:n_recommendations]]
        
        # 计算用户偏好向量（喜欢食物的平均特征向量）
        try:
            liked_indices = [self.food_encoder.transform([food_id])[0] for food_id in liked_foods 
                           if food_id in self.food_encoder.classes_]
            
            if not liked_indices:
                return [(food_id, 0.5) for food_id in all_foods[:n_recommendations]]
            
            user_profile = np.mean(self.feature_matrix[liked_indices], axis=0)
            
            # 计算所有食物与用户偏好的相似度
            recommendations = []
            for food_id in all_foods:
                if food_id not in liked_foods:  # 不推荐已经喜欢的食物
                    try:
                        food_idx = self.food_encoder.transform([food_id])[0]
                        similarity = cosine_similarity([user_profile], [self.feature_matrix[food_idx]])[0][0]
                        recommendations.append((food_id, similarity))
                    except ValueError:
                        recommendations.append((food_id, 0.5))
            
            # 排序并返回
            recommendations.sort(key=lambda x: x[1], reverse=True)
            return recommendations[:n_recommendations]
            
        except Exception as e:
            logger.error(f"内容推荐出错: {e}")
            return [(food_id, 0.5) for food_id in all_foods[:n_recommendations]]

class DeepLearningRecommender:
    """深度学习推荐算法"""
    
    def __init__(self, embedding_dim=64, hidden_dims=[128, 64, 32]):
        self.embedding_dim = embedding_dim
        self.hidden_dims = hidden_dims
        self.model = None
        self.user_encoder = LabelEncoder()
        self.item_encoder = LabelEncoder()
        self.scaler = StandardScaler()
        self.is_trained = False
        
    def _create_features(self, interactions_df: pd.DataFrame, food_df: pd.DataFrame, 
                        nutrition_df: pd.DataFrame, user_health_df: pd.DataFrame) -> np.ndarray:
        """创建深度学习特征"""
        features = []
        
        for _, row in interactions_df.iterrows():
            user_id = row['user_id']
            food_id = row['food_id']
            
            # 用户特征
            user_health = user_health_df[user_health_df['user_id'] == user_id]
            if not user_health.empty:
                user_features = [
                    user_health.iloc[0]['age'],
                    user_health.iloc[0]['height'],
                    user_health.iloc[0]['weight'],
                    user_health.iloc[0]['activity_level'],
                    user_health.iloc[0]['health_goal']
                ]
            else:
                user_features = [25, 170, 65, 2, 0]  # 默认值
            
            # 食物特征
            nutrition = nutrition_df[nutrition_df['food_id'] == food_id]
            if not nutrition.empty:
                food_features = [
                    nutrition.iloc[0]['calories'],
                    nutrition.iloc[0]['protein'],
                    nutrition.iloc[0]['fat'],
                    nutrition.iloc[0]['carbohydrate'],
                    nutrition.iloc[0]['fiber']
                ]
            else:
                food_features = [100, 5, 3, 20, 2]  # 默认值
            
            # 上下文特征
            context_features = [
                row.get('meal_type', 1),  # 餐次
                pd.to_datetime(row.get('timestamp', datetime.now())).hour,  # 小时
                pd.to_datetime(row.get('timestamp', datetime.now())).weekday()  # 星期
            ]
            
            features.append(user_features + food_features + context_features)
        
        return np.array(features)
    
    def fit(self, interactions_df: pd.DataFrame, food_df: pd.DataFrame, 
            nutrition_df: pd.DataFrame, user_health_df: pd.DataFrame) -> Dict[str, Any]:
        """训练深度学习模型"""
        logger.info("开始训练深度学习模型...")
        
        # 创建特征
        X = self._create_features(interactions_df, food_df, nutrition_df, user_health_df)
        y = interactions_df['rating'].values
        
        # 标准化特征
        X_scaled = self.scaler.fit_transform(X)
        
        # 创建并训练神经网络
        self.model = MLPRegressor(
            hidden_layer_sizes=tuple(self.hidden_dims),
            activation='relu',
            solver='adam',
            learning_rate='adaptive',
            max_iter=500,
            random_state=42,
            early_stopping=True,
            validation_fraction=0.1
        )
        
        self.model.fit(X_scaled, y)
        
        # 编码用户和物品ID
        self.user_encoder.fit(interactions_df['user_id'])
        self.item_encoder.fit(interactions_df['food_id'])
        
        self.is_trained = True
        logger.info("深度学习模型训练完成")
        
        return {
            "training_score": self.model.score(X_scaled, y),
            "n_features": X.shape[1],
            "n_samples": X.shape[0],
            "n_iterations": self.model.n_iter_
        }
    
    def predict(self, user_id: int, food_id: int, meal_type: int = 1, 
                hour: int = 12, weekday: int = 1) -> float:
        """预测评分"""
        if not self.is_trained:
            return 3.0
        
        # 构造特征向量（需要完整的用户和食物信息）
        # 这里使用简化的特征，实际应用中需要查询数据库
        features = np.array([[
            25, 170, 65, 2, 0,  # 用户特征（默认值）
            100, 5, 3, 20, 2,   # 食物特征（默认值）
            meal_type, hour, weekday  # 上下文特征
        ]])
        
        features_scaled = self.scaler.transform(features)
        prediction = self.model.predict(features_scaled)[0]
        
        return max(0, min(5, prediction))
    
    def recommend(self, user_id: int, food_ids: List[int], meal_type: int = 1,
                 n_recommendations: int = 10) -> List[Tuple[int, float]]:
        """推荐食物"""
        if not self.is_trained:
            return [(food_id, 3.0) for food_id in food_ids[:n_recommendations]]
        
        predictions = []
        current_hour = datetime.now().hour
        current_weekday = datetime.now().weekday()
        
        for food_id in food_ids:
            score = self.predict(user_id, food_id, meal_type, current_hour, current_weekday)
            predictions.append((food_id, score))
        
        predictions.sort(key=lambda x: x[1], reverse=True)
        return predictions[:n_recommendations]

class HybridRecommender:
    """混合推荐算法"""
    
    def __init__(self, weights=None):
        if weights is None:
            weights = {'cf': 0.4, 'content': 0.3, 'deep': 0.3}
        self.weights = weights
        
        self.cf_recommender = CollaborativeFilteringRecommender()
        self.content_recommender = ContentBasedRecommender()
        self.deep_recommender = DeepLearningRecommender()
        
        self.is_trained = False
        
    def fit(self, interactions_df: pd.DataFrame, food_df: pd.DataFrame, 
            nutrition_df: pd.DataFrame, user_health_df: pd.DataFrame) -> Dict[str, Any]:
        """训练所有子模型"""
        logger.info("开始训练混合推荐模型...")
        
        results = {}
        
        # 训练协同过滤
        if len(interactions_df) > 10:  # 至少需要一定量的交互数据
            cf_result = self.cf_recommender.fit(interactions_df)
            results['collaborative_filtering'] = cf_result
        
        # 训练内容推荐
        content_result = self.content_recommender.fit(food_df, nutrition_df)
        results['content_based'] = content_result
        
        # 训练深度学习模型
        if len(interactions_df) > 50:  # 深度学习需要更多数据
            deep_result = self.deep_recommender.fit(interactions_df, food_df, nutrition_df, user_health_df)
            results['deep_learning'] = deep_result
        
        self.is_trained = True
        logger.info("混合推荐模型训练完成")
        
        return results
    
    def recommend(self, user_id: int, food_ids: List[int], user_preferences: Dict[str, Any] = None,
                 n_recommendations: int = 10) -> Dict[str, Any]:
        """混合推荐"""
        if not self.is_trained:
            return {
                'recommendations': [(food_id, 3.0) for food_id in food_ids[:n_recommendations]],
                'algorithm_scores': {},
                'final_algorithm': 'default'
            }
        
        all_recommendations = {}
        algorithm_scores = {}
        
        # 协同过滤推荐
        if self.cf_recommender.is_trained:
            cf_recs = self.cf_recommender.recommend(user_id, food_ids, n_recommendations * 2)
            all_recommendations['cf'] = dict(cf_recs)
            algorithm_scores['collaborative_filtering'] = {'count': len(cf_recs), 'avg_score': np.mean([score for _, score in cf_recs])}
        
        # 内容推荐
        if self.content_recommender.is_trained:
            if user_preferences and 'liked_foods' in user_preferences:
                content_recs = self.content_recommender.recommend_by_preferences(
                    user_preferences['liked_foods'], food_ids, n_recommendations * 2
                )
            else:
                content_recs = [(food_id, 0.5) for food_id in food_ids[:n_recommendations * 2]]
            all_recommendations['content'] = dict(content_recs)
            algorithm_scores['content_based'] = {'count': len(content_recs), 'avg_score': np.mean([score for _, score in content_recs])}
        
        # 深度学习推荐
        if self.deep_recommender.is_trained:
            meal_type = user_preferences.get('meal_type', 1) if user_preferences else 1
            deep_recs = self.deep_recommender.recommend(user_id, food_ids, meal_type, n_recommendations * 2)
            all_recommendations['deep'] = dict(deep_recs)
            algorithm_scores['deep_learning'] = {'count': len(deep_recs), 'avg_score': np.mean([score for _, score in deep_recs])}
        
        # 融合推荐结果
        final_scores = {}
        for food_id in food_ids:
            weighted_score = 0
            total_weight = 0
            
            for algo, weight in self.weights.items():
                if algo in all_recommendations and food_id in all_recommendations[algo]:
                    weighted_score += weight * all_recommendations[algo][food_id]
                    total_weight += weight
            
            if total_weight > 0:
                final_scores[food_id] = weighted_score / total_weight
            else:
                final_scores[food_id] = 3.0  # 默认分数
        
        # 排序并返回
        sorted_recommendations = sorted(final_scores.items(), key=lambda x: x[1], reverse=True)
        final_recommendations = sorted_recommendations[:n_recommendations]
        
        return {
            'recommendations': final_recommendations,
            'algorithm_scores': algorithm_scores,
            'final_algorithm': 'hybrid',
            'weights_used': self.weights,
            'available_algorithms': list(all_recommendations.keys())
        }
    
    def save_models(self, model_dir: str):
        """保存模型"""
        os.makedirs(model_dir, exist_ok=True)
        
        # 保存协同过滤模型
        if self.cf_recommender.is_trained:
            cf_model = {
                'user_factors': self.cf_recommender.user_factors,
                'item_factors': self.cf_recommender.item_factors,
                'user_bias': self.cf_recommender.user_bias,
                'item_bias': self.cf_recommender.item_bias,
                'global_mean': self.cf_recommender.global_mean,
                'user_encoder': self.cf_recommender.user_encoder,
                'item_encoder': self.cf_recommender.item_encoder
            }
            with open(os.path.join(model_dir, 'cf_model.pkl'), 'wb') as f:
                pickle.dump(cf_model, f)
        
        # 保存内容推荐模型
        if self.content_recommender.is_trained:
            content_model = {
                'feature_matrix': self.content_recommender.feature_matrix,
                'similarity_matrix': self.content_recommender.similarity_matrix,
                'tfidf_vectorizer': self.content_recommender.tfidf_vectorizer,
                'scaler': self.content_recommender.scaler,
                'food_encoder': self.content_recommender.food_encoder
            }
            with open(os.path.join(model_dir, 'content_model.pkl'), 'wb') as f:
                pickle.dump(content_model, f)
        
        # 保存深度学习模型
        if self.deep_recommender.is_trained:
            deep_model = {
                'model': self.deep_recommender.model,
                'user_encoder': self.deep_recommender.user_encoder,
                'item_encoder': self.deep_recommender.item_encoder,
                'scaler': self.deep_recommender.scaler
            }
            with open(os.path.join(model_dir, 'deep_model.pkl'), 'wb') as f:
                pickle.dump(deep_model, f)
        
        logger.info(f"模型已保存到 {model_dir}")
    
    def load_models(self, model_dir: str):
        """加载模型"""
        try:
            # 加载协同过滤模型
            cf_path = os.path.join(model_dir, 'cf_model.pkl')
            if os.path.exists(cf_path):
                with open(cf_path, 'rb') as f:
                    cf_model = pickle.load(f)
                self.cf_recommender.user_factors = cf_model['user_factors']
                self.cf_recommender.item_factors = cf_model['item_factors']
                self.cf_recommender.user_bias = cf_model['user_bias']
                self.cf_recommender.item_bias = cf_model['item_bias']
                self.cf_recommender.global_mean = cf_model['global_mean']
                self.cf_recommender.user_encoder = cf_model['user_encoder']
                self.cf_recommender.item_encoder = cf_model['item_encoder']
                self.cf_recommender.is_trained = True
            
            # 加载内容推荐模型
            content_path = os.path.join(model_dir, 'content_model.pkl')
            if os.path.exists(content_path):
                with open(content_path, 'rb') as f:
                    content_model = pickle.load(f)
                self.content_recommender.feature_matrix = content_model['feature_matrix']
                self.content_recommender.similarity_matrix = content_model['similarity_matrix']
                self.content_recommender.tfidf_vectorizer = content_model['tfidf_vectorizer']
                self.content_recommender.scaler = content_model['scaler']
                self.content_recommender.food_encoder = content_model['food_encoder']
                self.content_recommender.is_trained = True
            
            # 加载深度学习模型
            deep_path = os.path.join(model_dir, 'deep_model.pkl')
            if os.path.exists(deep_path):
                with open(deep_path, 'rb') as f:
                    deep_model = pickle.load(f)
                self.deep_recommender.model = deep_model['model']
                self.deep_recommender.user_encoder = deep_model['user_encoder']
                self.deep_recommender.item_encoder = deep_model['item_encoder']
                self.deep_recommender.scaler = deep_model['scaler']
                self.deep_recommender.is_trained = True
            
            self.is_trained = True
            logger.info(f"模型已从 {model_dir} 加载")
            
        except Exception as e:
            logger.error(f"加载模型失败: {e}")
            self.is_trained = False
