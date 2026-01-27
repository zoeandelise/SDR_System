"""
基于内容的推荐模型
根据食物的营养特征进行推荐
"""

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler, MinMaxScaler
import joblib
import os
from config.model_config import CONTENT_BASED_CONFIG

class ContentBasedRecommender:
    def __init__(self, config=None):
        self.config = config or CONTENT_BASED_CONFIG
        self.food_features = None
        self.food_similarity_matrix = None
        self.scaler = None
        self.food_mapping = {}
        self.reverse_food_mapping = {}
        self.user_profiles = {}
        
    def prepare_food_features(self, food_df):
        """准备食物特征矩阵"""
        # 选择营养特征
        feature_columns = [col for col in self.config['features'] if col in food_df.columns]
        
        if not feature_columns:
            # 如果没有指定特征，使用默认营养特征
            feature_columns = ['calories', 'protein', 'fat', 'carbohydrate']
            feature_columns = [col for col in feature_columns if col in food_df.columns]
        
        # 提取特征矩阵
        self.food_features = food_df[feature_columns].fillna(0)
        
        # 特征归一化
        if self.config['normalization'] == 'standard':
            self.scaler = StandardScaler()
        else:
            self.scaler = MinMaxScaler()
            
        self.food_features = self.scaler.fit_transform(self.food_features)
        
        # 创建食物映射
        self.food_mapping = {food_id: idx for idx, food_id in enumerate(food_df['food_id'])}
        self.reverse_food_mapping = {idx: food_id for food_id, idx in self.food_mapping.items()}
        
        print(f"准备了 {len(feature_columns)} 个营养特征: {feature_columns}")
        
    def compute_food_similarity(self):
        """计算食物相似度矩阵"""
        self.food_similarity_matrix = cosine_similarity(self.food_features)
        np.fill_diagonal(self.food_similarity_matrix, 0)  # 移除自相似度
        
    def build_user_profile(self, user_id, user_interactions):
        """构建用户营养偏好画像"""
        if len(user_interactions) == 0:
            return np.zeros(self.food_features.shape[1])
            
        # 根据用户交互的食物计算平均特征向量
        user_food_features = []
        weights = []
        
        for _, interaction in user_interactions.iterrows():
            food_id = interaction['food_id']
            if food_id in self.food_mapping:
                food_idx = self.food_mapping[food_id]
                food_feature = self.food_features[food_idx]
                
                # 使用评分或频次作为权重
                weight = interaction.get('rating', 1.0)
                if 'frequency' in interaction:
                    weight *= interaction['frequency']
                    
                user_food_features.append(food_feature)
                weights.append(weight)
        
        if user_food_features:
            # 加权平均构建用户画像
            weights = np.array(weights)
            weights = weights / np.sum(weights)  # 归一化权重
            
            user_profile = np.average(user_food_features, axis=0, weights=weights)
            self.user_profiles[user_id] = user_profile
            return user_profile
        else:
            return np.zeros(self.food_features.shape[1])
    
    def train(self, food_df, interactions_df):
        """训练基于内容的推荐模型"""
        try:
            print("开始训练基于内容的推荐模型...")
            
            if food_df.empty:
                print("警告: 食物数据为空，使用示例数据")
                food_df = self._create_sample_food_data()
            
            # 准备食物特征
            self.prepare_food_features(food_df)
            print(f"✓ 食物特征准备完成: {len(self.food_mapping)} 种食物")
            
            # 计算食物相似度
            self.compute_food_similarity()
            print(f"✓ 食物相似度计算完成")
            
            # 为每个用户构建画像
            if not interactions_df.empty:
                unique_users = interactions_df['user_id'].unique()
                print(f"✓ 开始为 {len(unique_users)} 个用户构建画像...")
                
                for user_id in unique_users:
                    user_interactions = interactions_df[interactions_df['user_id'] == user_id]
                    self.build_user_profile(user_id, user_interactions)
                
                print(f"✓ 用户画像构建完成: {len(self.user_profiles)} 个用户")
            
            print("✅ 基于内容的推荐模型训练完成")
            return True
            
        except Exception as e:
            print(f"❌ 内容推荐模型训练失败: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def _create_sample_food_data(self):
        """创建示例食物数据"""
        import pandas as pd
        food_data = [
            {'food_id': i+1, 'calories': 100+i*10, 'protein': 10+i, 'fat': 5+i*0.5, 'carbohydrate': 20+i*2}
            for i in range(20)
        ]
        return pd.DataFrame(food_data)
    
    def recommend_similar_foods(self, food_id, n_recommendations=10):
        """推荐与指定食物相似的食物"""
        if food_id not in self.food_mapping:
            return []
            
        food_idx = self.food_mapping[food_id]
        similarity_scores = self.food_similarity_matrix[food_idx]
        
        # 获取最相似的食物
        similar_indices = np.argsort(similarity_scores)[::-1][:n_recommendations]
        
        recommendations = []
        for idx in similar_indices:
            similar_food_id = self.reverse_food_mapping[idx]
            score = similarity_scores[idx]
            recommendations.append((similar_food_id, score))
            
        return recommendations
    
    def recommend_for_user(self, user_id, n_recommendations=10, exclude_seen=True, user_interactions=None):
        """为用户推荐食物"""
        # 如果用户没有画像，尝试构建
        if user_id not in self.user_profiles and user_interactions is not None:
            self.build_user_profile(user_id, user_interactions)
            
        if user_id not in self.user_profiles:
            # 冷启动：返回热门食物或随机推荐
            return self._cold_start_recommendation(n_recommendations)
            
        user_profile = self.user_profiles[user_id]
        
        # 计算用户画像与所有食物的相似度
        food_scores = []
        seen_foods = set()
        
        if exclude_seen and user_interactions is not None:
            seen_foods = set(user_interactions['food_id'])
        
        for food_idx, food_feature in enumerate(self.food_features):
            food_id = self.reverse_food_mapping[food_idx]
            
            if exclude_seen and food_id in seen_foods:
                continue
                
            # 计算余弦相似度
            similarity = np.dot(user_profile, food_feature) / (
                np.linalg.norm(user_profile) * np.linalg.norm(food_feature) + 1e-10
            )
            
            food_scores.append((food_id, similarity))
        
        # 按相似度排序
        food_scores.sort(key=lambda x: x[1], reverse=True)
        
        # 添加多样性
        if self.config.get('diversity_weight', 0) > 0:
            food_scores = self._add_diversity(food_scores, n_recommendations)
            
        return food_scores[:n_recommendations]
    
    def _cold_start_recommendation(self, n_recommendations=10):
        """冷启动推荐策略"""
        # 简单策略：随机推荐或返回营养均衡的食物
        food_ids = list(self.reverse_food_mapping.values())
        np.random.shuffle(food_ids)
        return [(food_id, 0.5) for food_id in food_ids[:n_recommendations]]
    
    def _add_diversity(self, food_scores, n_recommendations):
        """增加推荐多样性"""
        if len(food_scores) <= n_recommendations:
            return food_scores
            
        diverse_recommendations = []
        remaining_foods = food_scores.copy()
        
        # 选择第一个最高分的食物
        if remaining_foods:
            diverse_recommendations.append(remaining_foods.pop(0))
        
        # 逐个选择，平衡相似度和多样性
        while len(diverse_recommendations) < n_recommendations and remaining_foods:
            best_candidate = None
            best_score = -1
            best_idx = -1
            
            for idx, (food_id, similarity) in enumerate(remaining_foods):
                if food_id not in self.food_mapping:
                    continue
                    
                # 计算与已选择食物的多样性
                diversity_score = self._compute_diversity_score(
                    food_id, [item[0] for item in diverse_recommendations]
                )
                
                # 组合相似度和多样性分数
                combined_score = (
                    (1 - self.config['diversity_weight']) * similarity +
                    self.config['diversity_weight'] * diversity_score
                )
                
                if combined_score > best_score:
                    best_score = combined_score
                    best_candidate = (food_id, similarity)
                    best_idx = idx
            
            if best_candidate:
                diverse_recommendations.append(best_candidate)
                remaining_foods.pop(best_idx)
            else:
                break
                
        return diverse_recommendations
    
    def _compute_diversity_score(self, candidate_food_id, selected_food_ids):
        """计算候选食物与已选择食物的多样性分数"""
        if not selected_food_ids or candidate_food_id not in self.food_mapping:
            return 1.0
            
        candidate_idx = self.food_mapping[candidate_food_id]
        min_similarity = 1.0
        
        for selected_food_id in selected_food_ids:
            if selected_food_id in self.food_mapping:
                selected_idx = self.food_mapping[selected_food_id]
                similarity = self.food_similarity_matrix[candidate_idx][selected_idx]
                min_similarity = min(min_similarity, similarity)
        
        # 多样性分数 = 1 - 最大相似度
        return 1.0 - min_similarity
    
    def update_user_profile(self, user_id, new_interactions):
        """更新用户画像"""
        self.build_user_profile(user_id, new_interactions)
    
    def save_model(self, filepath):
        """保存模型"""
        try:
            # 确保目录存在
            import os
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            
            model_data = {
                'config': self.config,
                'food_features': self.food_features,
                'food_similarity_matrix': self.food_similarity_matrix,
                'scaler': self.scaler,
                'food_mapping': self.food_mapping,
                'reverse_food_mapping': self.reverse_food_mapping,
                'user_profiles': self.user_profiles
            }
            joblib.dump(model_data, filepath)
            print(f"✅ 基于内容的推荐模型已保存到: {filepath}")
            return True
        except Exception as e:
            print(f"❌ 保存内容推荐模型失败: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def load_model(self, filepath):
        """加载模型"""
        if os.path.exists(filepath):
            model_data = joblib.load(filepath)
            self.config = model_data['config']
            self.food_features = model_data['food_features']
            self.food_similarity_matrix = model_data['food_similarity_matrix']
            self.scaler = model_data['scaler']
            self.food_mapping = model_data['food_mapping']
            self.reverse_food_mapping = model_data['reverse_food_mapping']
            self.user_profiles = model_data['user_profiles']
            print(f"基于内容的推荐模型已从 {filepath} 加载")
            return True
        return False
    
    def explain_recommendation(self, user_id, food_id):
        """解释为什么推荐某个食物"""
        if user_id not in self.user_profiles or food_id not in self.food_mapping:
            return "无法提供解释"
            
        user_profile = self.user_profiles[user_id]
        food_idx = self.food_mapping[food_id]
        food_feature = self.food_features[food_idx]
        
        # 找到最匹配的特征
        feature_similarities = user_profile * food_feature
        top_features_idx = np.argsort(feature_similarities)[::-1][:3]
        
        explanations = []
        feature_names = self.config['features']
        
        for idx in top_features_idx:
            if idx < len(feature_names):
                feature_name = feature_names[idx]
                explanations.append(f"营养特征 '{feature_name}' 匹配您的偏好")
        
        return "; ".join(explanations)
