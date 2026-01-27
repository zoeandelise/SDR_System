"""
混合推荐系统核心模块（V2.0）
整合协同过滤和内容推荐，结合营养学约束规则
体现创新点：协同过滤算法与营养学约束规则相结合
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Any, Optional, Tuple
import logging
from datetime import datetime, timedelta
import json
import joblib
import os

# 机器学习库
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import StandardScaler
from surprise import SVD, Dataset, Reader

logger = logging.getLogger(__name__)

class HybridRecommender:
    """混合推荐系统（协同过滤 + 内容推荐 + 营养学约束）"""
    
    def __init__(self, data_loader):
        self.data_loader = data_loader
        
        # 推荐算法模块（仅协同过滤和内容推荐）
        self.cf_recommender = CollaborativeFilteringRecommender()
        self.content_recommender = ContentBasedRecommender()
        
        # 模型状态
        self.models_loaded = {
            'cf': False,
            'content': False
        }
        
        # 算法权重（协同过滤主导，内容推荐辅助）
        self.algorithm_weights = {
            'cf': 0.6,
            'content': 0.4
        }
        
        # 缓存
        self._cache = {}
        
        # 子模型引用（用于外部设置）
        self.cf_model = None
        self.content_model = None
    
    def set_sub_models(self, cf_model=None, content_model=None):
        """设置子模型（用于训练后的模型注入）"""
        if cf_model:
            self.cf_model = cf_model
            self.models_loaded['cf'] = True
            logger.info("协同过滤子模型已设置")
        
        if content_model:
            self.content_model = content_model
            self.models_loaded['content'] = True
            logger.info("内容推荐子模型已设置")
    
    def recommend(self, user_id: int, n_recommendations: int = 10, 
                  exclude_seen: bool = True, user_interactions=None) -> List[Tuple]:
        """
        为用户生成混合推荐（同步接口）
        返回格式：[(food_id, score), ...]
        """
        try:
            recommendations = []
            
            # 1. 协同过滤推荐
            if self.cf_model and self.models_loaded['cf']:
                try:
                    cf_recs = self.cf_model.recommend(
                        user_id, n_recommendations, exclude_seen
                    )
                    # 加权
                    for food_id, score in cf_recs:
                        recommendations.append((
                            food_id, 
                            score * self.algorithm_weights['cf']
                        ))
                except Exception as e:
                    logger.warning(f"协同过滤推荐失败: {e}")
            
            # 2. 内容推荐
            if self.content_model and self.models_loaded['content']:
                try:
                    content_recs = self.content_model.recommend_for_user(
                        user_id, n_recommendations, exclude_seen, user_interactions
                    )
                    # 加权并合并
                    for food_id, score in content_recs:
                        # 查找是否已存在
                        found = False
                        for i, (fid, s) in enumerate(recommendations):
                            if fid == food_id:
                                recommendations[i] = (
                                    fid, 
                                    s + score * self.algorithm_weights['content']
                                )
                                found = True
                                break
                        
                        if not found:
                            recommendations.append((
                                food_id, 
                                score * self.algorithm_weights['content']
                            ))
                except Exception as e:
                    logger.warning(f"内容推荐失败: {e}")
            
            # 按分数排序并返回top-N
            recommendations.sort(key=lambda x: x[1], reverse=True)
            return recommendations[:n_recommendations]
            
        except Exception as e:
            logger.error(f"混合推荐失败: {e}")
            return []
    
    def train(self, food_df, interactions_df):
        """训练混合推荐模型"""
        logger.info("训练混合推荐模型（基于已训练的子模型）")
        
        try:
            # 验证子模型是否已加载
            if not self.models_loaded['cf'] or not self.models_loaded['content']:
                logger.warning("子模型未完全加载")
                return False
            
            # 混合推荐模型主要是设置融合权重
            # 可以基于验证集性能动态调整权重
            logger.info(f"混合推荐权重: CF={self.algorithm_weights['cf']}, Content={self.algorithm_weights['content']}")
            
            return True
            
        except Exception as e:
            logger.error(f"混合推荐模型训练失败: {e}")
            return False
    
    def save_model(self, filepath: str):
        """保存混合推荐配置"""
        try:
            config = {
                'algorithm_weights': self.algorithm_weights,
                'models_loaded': self.models_loaded
            }
            joblib.dump(config, filepath)
            logger.info(f"混合推荐配置已保存: {filepath}")
            return True
        except Exception as e:
            logger.error(f"保存混合推荐配置失败: {e}")
            return False
    
    def load_model(self, filepath: str):
        """加载混合推荐配置"""
        try:
            if os.path.exists(filepath):
                config = joblib.load(filepath)
                self.algorithm_weights = config.get('algorithm_weights', self.algorithm_weights)
                logger.info(f"混合推荐配置已加载: {filepath}")
                return True
            return False
        except Exception as e:
            logger.error(f"加载混合推荐配置失败: {e}")
            return False
    
    async def load_models(self):
        """加载预训练模型"""
        try:
            model_path = "./models/saved/"
            
            # 加载协同过滤模型
            if os.path.exists(f"{model_path}cf_model.pkl"):
                self.cf_recommender.load_model(f"{model_path}cf_model.pkl")
                self.models_loaded['cf'] = True
                logger.info("协同过滤模型加载成功")
            
            # 加载内容推荐模型
            if os.path.exists(f"{model_path}content_model.pkl"):
                self.content_recommender.load_model(f"{model_path}content_model.pkl")
                self.models_loaded['content'] = True
                logger.info("内容推荐模型加载成功")
            
            # 如果没有预训练模型，进行快速训练
            if not any(self.models_loaded.values()):
                logger.info("未找到预训练模型，开始快速训练...")
                await self.quick_train()
                
        except Exception as e:
            logger.error(f"模型加载失败: {e}")
    
    async def get_personalized_recommendations(
        self, 
        user_id: int, 
        meal_type: str,
        target_calories: Optional[float] = None,
        special_requirements: Optional[str] = None,
        disliked_foods: List[str] = None,
        n_recommendations: int = 10
    ) -> List[Dict[str, Any]]:
        """获取个性化推荐"""
        
        try:
            # 获取用户画像
            from models.user_profiling import UserProfileService
            user_profiler = UserProfileService(self.data_loader)
            user_profile = await user_profiler.build_user_profile(user_id)
            
            # 多算法推荐
            recommendations = {}
            
            # 1. 协同过滤推荐
            if self.models_loaded['cf']:
                try:
                    cf_recs = await self.cf_recommender.recommend(user_id, meal_type, n_recommendations)
                    recommendations['cf'] = cf_recs
                except Exception as e:
                    logger.warning(f"协同过滤推荐失败: {e}")
            
            # 2. 内容推荐（结合营养学约束）
            if self.models_loaded['content']:
                try:
                    content_recs = await self.content_recommender.recommend(
                        user_profile, meal_type, target_calories, n_recommendations
                    )
                    recommendations['content'] = content_recs
                except Exception as e:
                    logger.warning(f"内容推荐失败: {e}")
            
            # 3. 混合推荐（应用营养学约束规则）
            if recommendations:
                final_recs = self._combine_recommendations(
                    recommendations, 
                    user_profile,
                    disliked_foods or [],
                    special_requirements,
                    n_recommendations
                )
            else:
                # 降级到规则推荐
                final_recs = await self._rule_based_recommendation(
                    user_profile, meal_type, target_calories, n_recommendations
                )
            
            # 添加推荐理由和置信度
            final_recs = self._add_recommendation_metadata(final_recs, user_profile, meal_type)
            
            return final_recs
            
        except Exception as e:
            logger.error(f"个性化推荐生成失败: {e}")
            raise
    
    def _combine_recommendations(
        self, 
        recommendations: Dict[str, List], 
        user_profile: Dict,
        disliked_foods: List[str],
        special_requirements: Optional[str],
        n_recommendations: int
    ) -> List[Dict[str, Any]]:
        """混合多种推荐算法的结果"""
        
        # 收集所有推荐食物
        all_recommendations = {}
        
        for algorithm, recs in recommendations.items():
            weight = self.algorithm_weights.get(algorithm, 0.3)
            
            for rec in recs:
                food_name = rec['food_name']
                
                if food_name in disliked_foods:
                    continue  # 跳过不喜欢的食物
                
                if food_name not in all_recommendations:
                    all_recommendations[food_name] = {
                        'food_name': food_name,
                        'total_score': 0,
                        'algorithm_scores': {},
                        'nutrition_info': rec.get('nutrition_info', {}),
                        'recommendation_reason': []
                    }
                
                # 累加加权分数
                score = rec.get('score', 0.5) * weight
                all_recommendations[food_name]['total_score'] += score
                all_recommendations[food_name]['algorithm_scores'][algorithm] = rec.get('score', 0.5)
                
                # 收集推荐理由
                if 'reason' in rec:
                    all_recommendations[food_name]['recommendation_reason'].append(
                        f"{algorithm}: {rec['reason']}"
                    )
        
        # 按总分排序
        sorted_recommendations = sorted(
            all_recommendations.values(),
            key=lambda x: x['total_score'],
            reverse=True
        )
        
        # 应用特殊要求过滤
        if special_requirements:
            sorted_recommendations = self._apply_special_requirements(
                sorted_recommendations, special_requirements
            )
        
        # 返回top-N
        final_recs = sorted_recommendations[:n_recommendations]
        
        # 确保推荐多样性
        final_recs = self._ensure_diversity(final_recs, user_profile)
        
        return final_recs
    
    def _apply_special_requirements(self, recommendations: List[Dict], requirements: str) -> List[Dict]:
        """应用特殊要求过滤"""
        requirements_lower = requirements.lower()
        
        filtered_recs = []
        for rec in recommendations:
            food_name_lower = rec['food_name'].lower()
            
            # 简单的关键词过滤
            if '低热量' in requirements_lower:
                calories = rec.get('nutrition_info', {}).get('calories_per_100g', 0)
                if calories > 200:  # 超过200卡/100g认为是高热量
                    continue
            
            if '高蛋白' in requirements_lower:
                protein = rec.get('nutrition_info', {}).get('protein_per_100g', 0)
                if protein < 15:  # 低于15g/100g蛋白质
                    continue
            
            if '素食' in requirements_lower or 'vegetarian' in requirements_lower:
                if any(meat in food_name_lower for meat in ['肉', '鸡', '猪', '牛', '鱼', '虾']):
                    continue
            
            filtered_recs.append(rec)
        
        return filtered_recs
    
    def _ensure_diversity(self, recommendations: List[Dict], user_profile: Dict) -> List[Dict]:
        """确保推荐多样性"""
        if len(recommendations) <= 3:
            return recommendations
        
        # 简单的多样性策略：确保不同类别的食物都有
        diverse_recs = []
        food_categories = set()
        
        for rec in recommendations:
            food_name = rec['food_name']
            
            # 简单分类（基于食物名称关键词）
            category = self._classify_food(food_name)
            
            if len(diverse_recs) < 3 or category not in food_categories:
                diverse_recs.append(rec)
                food_categories.add(category)
            elif len(diverse_recs) < len(recommendations):
                diverse_recs.append(rec)
        
        return diverse_recs
    
    def _classify_food(self, food_name: str) -> str:
        """简单食物分类"""
        food_name_lower = food_name.lower()
        
        if any(grain in food_name_lower for grain in ['米', '面', '粥', '饭', '面条']):
            return '主食'
        elif any(meat in food_name_lower for meat in ['肉', '鸡', '猪', '牛', '鱼', '虾']):
            return '蛋白质'
        elif any(veg in food_name_lower for veg in ['菜', '菠菜', '西兰花', '萝卜', '土豆']):
            return '蔬菜'
        elif any(fruit in food_name_lower for fruit in ['苹果', '香蕉', '橙子', '水果']):
            return '水果'
        else:
            return '其他'
    
    async def _rule_based_recommendation(
        self, 
        user_profile: Dict, 
        meal_type: str, 
        target_calories: Optional[float],
        n_recommendations: int
    ) -> List[Dict[str, Any]]:
        """规则推荐（降级方案）"""
        
        logger.info("使用规则推荐作为降级方案")
        
        # 获取食物库
        food_df = self.data_loader.get_food_info()
        if food_df.empty:
            return self._get_default_recommendations(meal_type)
        
        # 根据餐次类型过滤
        meal_filters = {
            '0': ['早餐', '粥', '牛奶', '鸡蛋', '面包'],  # 早餐
            '1': ['午餐', '米饭', '肉', '菜'],              # 午餐
            '2': ['晚餐', '汤', '菜', '粥'],               # 晚餐
            '3': ['水果', '坚果', '酸奶']                  # 加餐
        }
        
        keywords = meal_filters.get(meal_type, ['营养', '健康'])
        
        # 简单关键词匹配
        filtered_foods = food_df[
            food_df['food_name'].str.contains('|'.join(keywords), na=False)
        ]
        
        if filtered_foods.empty:
            filtered_foods = food_df.sample(min(n_recommendations, len(food_df)))
        
        # 构建推荐结果
        recommendations = []
        for _, food in filtered_foods.head(n_recommendations).iterrows():
            rec = {
                'food_name': food['food_name'],
                'food_id': food['food_id'],
                'score': 0.7,  # 规则推荐默认分数
                'nutrition_info': {
                    'calories_per_100g': food.get('calories_per_100g', 0),
                    'protein_per_100g': food.get('protein_per_100g', 0),
                    'fat_per_100g': food.get('fat_per_100g', 0),
                    'carbohydrate_per_100g': food.get('carbohydrate_per_100g', 0)
                },
                'algorithm_used': 'rule_based',
                'reason': f"基于{self._get_meal_type_name(meal_type)}的营养需求推荐"
            }
            recommendations.append(rec)
        
        return recommendations
    
    def _get_default_recommendations(self, meal_type: str) -> List[Dict[str, Any]]:
        """获取默认推荐（最后降级方案）"""
        default_foods = {
            '0': [  # 早餐
                {'name': '燕麦粥', 'calories': 68, 'protein': 2.4, 'reason': '富含膳食纤维，提供持久能量'},
                {'name': '鸡蛋', 'calories': 155, 'protein': 13, 'reason': '优质蛋白质来源'},
                {'name': '牛奶', 'calories': 54, 'protein': 3.4, 'reason': '补充钙质和蛋白质'},
                {'name': '全麦面包', 'calories': 247, 'protein': 13, 'reason': '复合碳水化合物，提供稳定血糖'},
                {'name': '香蕉', 'calories': 89, 'protein': 1.1, 'reason': '天然糖分，快速补充能量'}
            ],
            '1': [  # 午餐
                {'name': '糙米饭', 'calories': 112, 'protein': 2.6, 'reason': '优质碳水化合物主食'},
                {'name': '鸡胸肉', 'calories': 165, 'protein': 31, 'reason': '低脂高蛋白'},
                {'name': '西兰花', 'calories': 34, 'protein': 2.8, 'reason': '富含维生素C和膳食纤维'},
                {'name': '三文鱼', 'calories': 208, 'protein': 25, 'reason': '富含Omega-3脂肪酸'},
                {'name': '菠菜', 'calories': 23, 'protein': 2.9, 'reason': '富含铁质和叶酸'}
            ],
            '2': [  # 晚餐
                {'name': '小米粥', 'calories': 46, 'protein': 1.5, 'reason': '易消化，养胃'},
                {'name': '蒸蛋羹', 'calories': 155, 'protein': 13, 'reason': '软嫩易消化的蛋白质'},
                {'name': '青菜汤', 'calories': 15, 'protein': 1.5, 'reason': '清淡营养，促进消化'},
                {'name': '豆腐', 'calories': 76, 'protein': 8, 'reason': '植物蛋白，低热量'},
                {'name': '紫薯', 'calories': 82, 'protein': 1.3, 'reason': '富含花青素和膳食纤维'}
            ],
            '3': [  # 加餐
                {'name': '苹果', 'calories': 52, 'protein': 0.3, 'reason': '维生素C丰富，低热量'},
                {'name': '核桃', 'calories': 654, 'protein': 15, 'reason': '健康脂肪，益智健脑'},
                {'name': '酸奶', 'calories': 59, 'protein': 10, 'reason': '益生菌，促进肠道健康'},
                {'name': '蓝莓', 'calories': 57, 'protein': 0.7, 'reason': '抗氧化，保护视力'},
                {'name': '杏仁', 'calories': 575, 'protein': 21, 'reason': '维生素E丰富，护肤养颜'}
            ]
        }
        
        foods = default_foods.get(meal_type, default_foods['1'])
        
        return [
            {
                'food_name': food['name'],
                'food_id': hash(food['name']) % 10000,  # 模拟ID
                'score': 0.6,
                'nutrition_info': {
                    'calories_per_100g': food['calories'],
                    'protein_per_100g': food['protein'],
                    'fat_per_100g': 0,
                    'carbohydrate_per_100g': 0
                },
                'algorithm_used': 'default_rules',
                'reason': food['reason']
            }
            for food in foods[:n_recommendations]
        ]
    
    def _add_recommendation_metadata(
        self, 
        recommendations: List[Dict], 
        user_profile: Dict, 
        meal_type: str
    ) -> List[Dict[str, Any]]:
        """添加推荐元数据"""
        
        meal_names = {'0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'}
        meal_name = meal_names.get(meal_type, '餐次')
        
        for i, rec in enumerate(recommendations):
            # 置信度评分
            rec['confidence'] = min(1.0, rec.get('score', 0.5) + 0.1)
            
            # 排名
            rec['rank'] = i + 1
            
            # 适合性评分
            rec['suitability'] = self._calculate_suitability(rec, user_profile, meal_type)
            
            # 推荐理由优化
            if 'reason' not in rec or not rec['reason']:
                rec['reason'] = f"适合{meal_name}食用的营养选择"
            
            # 营养亮点
            rec['nutrition_highlights'] = self._get_nutrition_highlights(rec['nutrition_info'])
        
        return recommendations
    
    def _calculate_suitability(self, recommendation: Dict, user_profile: Dict, meal_type: str) -> float:
        """计算食物对用户的适合度"""
        suitability = 0.5  # 基础分
        
        nutrition = recommendation.get('nutrition_info', {})
        basic_info = user_profile.get('basic_info', {})
        health_profile = user_profile.get('health_profile', {})
        
        # 热量适合度
        daily_need = health_profile.get('daily_calorie_need', 2000)
        meal_calorie_target = daily_need / 4 if meal_type == '3' else daily_need / 3  # 加餐分配更少
        
        food_calories = nutrition.get('calories_per_100g', 0)
        if 0.5 * meal_calorie_target <= food_calories <= 1.5 * meal_calorie_target:
            suitability += 0.2
        
        # 健康目标适合度
        health_goal = basic_info.get('health_goal', '0')
        if health_goal == '1':  # 减脂
            if food_calories < 150:  # 低热量食物
                suitability += 0.2
        elif health_goal == '2':  # 增肌
            protein = nutrition.get('protein_per_100g', 0)
            if protein > 20:  # 高蛋白食物
                suitability += 0.2
        
        # BMI适合度
        bmi = basic_info.get('bmi')
        if bmi:
            if bmi > 25 and food_calories < 100:  # 超重用户推荐低热量
                suitability += 0.1
            elif bmi < 18.5 and food_calories > 200:  # 偏瘦用户推荐高热量
                suitability += 0.1
        
        return min(1.0, suitability)
    
    def _get_nutrition_highlights(self, nutrition_info: Dict) -> List[str]:
        """获取营养亮点"""
        highlights = []
        
        calories = nutrition_info.get('calories_per_100g', 0)
        protein = nutrition_info.get('protein_per_100g', 0)
        fiber = nutrition_info.get('fiber_per_100g', 0)
        
        if calories < 50:
            highlights.append("超低热量")
        elif calories < 100:
            highlights.append("低热量")
        
        if protein > 20:
            highlights.append("高蛋白")
        elif protein > 10:
            highlights.append("优质蛋白")
        
        if fiber > 5:
            highlights.append("高纤维")
        
        return highlights
    
    def _get_meal_type_name(self, meal_type: str) -> str:
        """获取餐次类型名称"""
        names = {'0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'}
        return names.get(meal_type, '餐次')
    
    async def quick_train(self):
        """快速训练基础模型"""
        logger.info("开始快速训练推荐模型...")
        
        try:
            # 获取训练数据
            training_data = self.data_loader.get_training_data(days_back=90)
            
            # 训练协同过滤模型
            if not training_data['user_item_matrix'].empty:
                await self.cf_recommender.quick_train(training_data['user_item_matrix'])
                self.models_loaded['cf'] = True
                logger.info("协同过滤模型快速训练完成")
            
            # 训练内容推荐模型
            if not training_data['food_info'].empty:
                await self.content_recommender.quick_train(training_data['food_info'])
                self.models_loaded['content'] = True
                logger.info("内容推荐模型快速训练完成")
            
            logger.info("快速训练完成")
            
        except Exception as e:
            logger.error(f"快速训练失败: {e}")
    
    async def train_models(
        self, 
        model_types: List[str],
        training_data_days: int = 180,
        validation_split: float = 0.2
    ):
        """完整模型训练"""
        logger.info(f"开始训练模型: {model_types}")
        
        try:
            # 获取训练数据
            training_data = self.data_loader.get_training_data(days_back=training_data_days)
            
            # 数据分割
            train_data, val_data = self._split_training_data(training_data, validation_split)
            
            # 训练指定模型
            for model_type in model_types:
                if model_type == "collaborative_filtering":
                    await self.cf_recommender.full_train(train_data, val_data)
                    self.models_loaded['cf'] = True
                    
                elif model_type == "content_based":
                    await self.content_recommender.full_train(train_data, val_data)
                    self.models_loaded['content'] = True
                    
                elif model_type == "deep_learning":
                    await self.deep_recommender.full_train(train_data, val_data)
                    self.models_loaded['deep'] = True
            
            # 保存模型
            await self._save_models()
            
            logger.info("模型训练完成")
            
        except Exception as e:
            logger.error(f"模型训练失败: {e}")
            raise
    
    def _split_training_data(self, data: Dict, validation_split: float) -> Tuple[Dict, Dict]:
        """分割训练和验证数据"""
        train_data = {}
        val_data = {}
        
        for key, df in data.items():
            if not df.empty and 'record_date' in df.columns:
                # 按时间分割
                df_sorted = df.sort_values('record_date')
                split_idx = int(len(df) * (1 - validation_split))
                
                train_data[key] = df_sorted.iloc[:split_idx]
                val_data[key] = df_sorted.iloc[split_idx:]
            else:
                train_data[key] = df
                val_data[key] = pd.DataFrame()
        
        return train_data, val_data
    
    async def _save_models(self):
        """保存训练好的模型"""
        model_path = "./models/saved/"
        os.makedirs(model_path, exist_ok=True)
        
        try:
            if self.models_loaded['cf']:
                self.cf_recommender.save_model(f"{model_path}cf_model.pkl")
            
            if self.models_loaded['content']:
                self.content_recommender.save_model(f"{model_path}content_model.pkl")
            
            if self.models_loaded['deep']:
                self.deep_recommender.save_model(f"{model_path}deep_model.pth")
            
            logger.info("模型保存成功")
            
        except Exception as e:
            logger.error(f"模型保存失败: {e}")
    
    def get_model_status(self) -> Dict[str, bool]:
        """获取模型状态"""
        return self.models_loaded.copy()
    
    def get_algorithm_info(self) -> Dict[str, Any]:
        """获取算法信息"""
        return {
            'algorithms_used': [k for k, v in self.models_loaded.items() if v],
            'algorithm_weights': self.algorithm_weights,
            'total_algorithms': sum(1 for v in self.models_loaded.values() if v),
            'recommendation_strategy': 'hybrid_weighted_combination'
        }
    
    def get_detailed_status(self) -> Dict[str, Any]:
        """获取详细状态"""
        return {
            'service_status': 'active',
            'models_loaded': self.models_loaded,
            'algorithm_weights': self.algorithm_weights,
            'cache_size': len(self._cache),
            'last_trained': self._get_last_training_time(),
            'model_performance': self._get_model_performance()
        }
    
    def _get_last_training_time(self) -> Optional[str]:
        """获取最后训练时间"""
        model_path = "./models/saved/"
        if not os.path.exists(model_path):
            return None
        
        try:
            model_files = [f for f in os.listdir(model_path) if f.endswith(('.pkl', '.pth'))]
            if model_files:
                latest_file = max(
                    [os.path.join(model_path, f) for f in model_files],
                    key=os.path.getmtime
                )
                return datetime.fromtimestamp(os.path.getmtime(latest_file)).isoformat()
        except Exception:
            pass
        
        return None
    
    def _get_model_performance(self) -> Dict[str, float]:
        """获取模型性能指标（模拟）"""
        # 实际应该从验证结果中获取
        return {
            'cf_precision': 0.75,
            'cf_recall': 0.68,
            'content_precision': 0.82,
            'content_recall': 0.71,
            'deep_precision': 0.79,
            'deep_recall': 0.73,
            'overall_satisfaction': 0.85
        }
    
    async def process_user_feedback(
        self, 
        user_id: int, 
        recommendation_id: int,
        feedback_type: str,
        rating: Optional[float] = None
    ):
        """处理用户反馈"""
        try:
            # 记录反馈到数据库
            feedback_data = {
                'user_id': user_id,
                'recommendation_id': recommendation_id,
                'feedback_type': feedback_type,
                'rating': rating,
                'timestamp': datetime.now()
            }
            
            # 更新模型（在线学习）
            await self._update_models_with_feedback(feedback_data)
            
            logger.info(f"用户 {user_id} 的反馈已处理: {feedback_type}")
            
        except Exception as e:
            logger.error(f"处理用户反馈失败: {e}")
            raise
    
    async def _update_models_with_feedback(self, feedback_data: Dict):
        """基于反馈更新模型"""
        # 这里可以实现在线学习逻辑
        # 暂时只记录反馈，模型更新在批量训练时进行
        logger.info(f"收到用户反馈: user_id={feedback_data['user_id']}, type={feedback_data['feedback_type']}")
    
    async def get_recommendation_analytics(self) -> Dict[str, Any]:
        """获取推荐效果分析"""
        try:
            # 获取最近推荐数据
            recommendations_df = self.data_loader.get_recommendations_history(days_back=30)
            
            if recommendations_df.empty:
                return {'total_recommendations': 0, 'acceptance_rate': 0}
            
            # 计算关键指标
            total_recs = len(recommendations_df)
            accepted_recs = len(recommendations_df[recommendations_df['is_accepted'] == '1'])
            acceptance_rate = accepted_recs / total_recs if total_recs > 0 else 0
            
            # 按算法类型分析
            algorithm_performance = recommendations_df.groupby('algorithm_type').agg({
                'is_accepted': lambda x: (x == '1').mean(),
                'score': 'mean'
            }).to_dict('index')
            
            return {
                'total_recommendations': total_recs,
                'accepted_recommendations': accepted_recs,
                'acceptance_rate': round(acceptance_rate, 3),
                'algorithm_performance': algorithm_performance,
                'avg_score': round(recommendations_df['score'].mean(), 2),
                'generated_at': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"获取推荐分析失败: {e}")
            return {'error': str(e)}


class CollaborativeFilteringRecommender:
    """协同过滤推荐器"""
    
    def __init__(self):
        self.model = None
        self.user_item_matrix = None
        self.trained = False
    
    async def quick_train(self, user_item_matrix: pd.DataFrame):
        """快速训练"""
        try:
            self.user_item_matrix = user_item_matrix
            
            # 使用surprise库进行协同过滤
            reader = Reader(rating_scale=(1, 5))
            
            # 转换数据格式
            ratings_data = []
            for user_id in user_item_matrix.index:
                for food_name in user_item_matrix.columns:
                    rating = user_item_matrix.loc[user_id, food_name]
                    if rating > 0:
                        ratings_data.append([user_id, food_name, rating])
            
            if not ratings_data:
                logger.warning("没有评分数据，跳过协同过滤训练")
                return
            
            ratings_df = pd.DataFrame(ratings_data, columns=['user_id', 'food_name', 'rating'])
            dataset = Dataset.load_from_df(ratings_df, reader)
            trainset = dataset.build_full_trainset()
            
            # 训练SVD模型
            self.model = SVD(n_factors=20, n_epochs=10, lr_all=0.005, reg_all=0.02)
            self.model.fit(trainset)
            self.trained = True
            
            logger.info("协同过滤快速训练完成")
            
        except Exception as e:
            logger.error(f"协同过滤训练失败: {e}")
    
    async def recommend(self, user_id: int, meal_type: str, n_recommendations: int) -> List[Dict]:
        """生成协同过滤推荐"""
        if not self.trained or self.user_item_matrix is None:
            return []
        
        try:
            # 获取用户未评分的食物
            if user_id not in self.user_item_matrix.index:
                return []  # 新用户，无法使用协同过滤
            
            user_ratings = self.user_item_matrix.loc[user_id]
            unrated_foods = user_ratings[user_ratings == 0].index.tolist()
            
            if not unrated_foods:
                return []
            
            # 预测评分
            predictions = []
            for food_name in unrated_foods:
                pred = self.model.predict(user_id, food_name)
                if pred.est > 3.0:  # 只推荐预测评分较高的
                    predictions.append({
                        'food_name': food_name,
                        'score': pred.est / 5.0,  # 归一化到0-1
                        'reason': f"基于相似用户的喜好推荐",
                        'algorithm_used': 'collaborative_filtering'
                    })
            
            # 按评分排序
            predictions.sort(key=lambda x: x['score'], reverse=True)
            
            return predictions[:n_recommendations]
            
        except Exception as e:
            logger.error(f"协同过滤推荐失败: {e}")
            return []
    
    def save_model(self, filepath: str):
        """保存模型"""
        if self.model:
            joblib.dump({
                'model': self.model,
                'user_item_matrix': self.user_item_matrix,
                'trained': self.trained
            }, filepath)
    
    def load_model(self, filepath: str):
        """加载模型"""
        try:
            data = joblib.load(filepath)
            self.model = data['model']
            self.user_item_matrix = data['user_item_matrix']
            self.trained = data['trained']
        except Exception as e:
            logger.error(f"加载协同过滤模型失败: {e}")


class ContentBasedRecommender:
    """内容推荐器"""
    
    def __init__(self):
        self.food_features = None
        self.feature_scaler = StandardScaler()
        self.tfidf_vectorizer = TfidfVectorizer(max_features=1000)
        self.trained = False
    
    async def quick_train(self, food_info: pd.DataFrame):
        """快速训练"""
        try:
            self.food_features = self._prepare_food_features(food_info)
            self.trained = True
            logger.info("内容推荐快速训练完成")
            
        except Exception as e:
            logger.error(f"内容推荐训练失败: {e}")
    
    def _prepare_food_features(self, food_info: pd.DataFrame) -> pd.DataFrame:
        """准备食物特征"""
        # 营养特征标准化
        nutrition_cols = [
            'calories_per_100g', 'protein_per_100g', 'fat_per_100g',
            'carbohydrate_per_100g', 'fiber_per_100g'
        ]
        
        # 选择存在的列
        available_cols = [col for col in nutrition_cols if col in food_info.columns]
        
        if available_cols:
            nutrition_features = food_info[available_cols].fillna(0)
            nutrition_scaled = self.feature_scaler.fit_transform(nutrition_features)
            
            # 创建特征DataFrame
            feature_df = pd.DataFrame(
                nutrition_scaled,
                columns=available_cols,
                index=food_info.index
            )
            
            # 添加食物基础信息
            feature_df['food_id'] = food_info['food_id']
            feature_df['food_name'] = food_info['food_name']
            feature_df['category'] = food_info.get('category', '未分类')
            
            return feature_df
        
        return pd.DataFrame()
    
    async def recommend(
        self, 
        user_profile: Dict, 
        meal_type: str,
        target_calories: Optional[float],
        n_recommendations: int
    ) -> List[Dict]:
        """生成内容推荐"""
        if not self.trained or self.food_features is None or self.food_features.empty:
            return []
        
        try:
            # 构建用户偏好向量
            user_vector = self._build_user_preference_vector(user_profile, meal_type, target_calories)
            
            # 计算食物相似度
            food_similarities = self._calculate_food_similarities(user_vector)
            
            # 过滤和排序
            recommendations = self._filter_and_rank_foods(
                food_similarities, user_profile, meal_type, n_recommendations
            )
            
            return recommendations
            
        except Exception as e:
            logger.error(f"内容推荐失败: {e}")
            return []
    
    def _build_user_preference_vector(
        self, 
        user_profile: Dict, 
        meal_type: str,
        target_calories: Optional[float]
    ) -> np.ndarray:
        """构建用户偏好向量"""
        # 基于用户画像构建偏好向量
        basic_info = user_profile.get('basic_info', {})
        health_profile = user_profile.get('health_profile', {})
        dietary_behavior = user_profile.get('dietary_behavior', {})
        
        # 目标营养需求
        if target_calories is None:
            target_calories = health_profile.get('daily_calorie_need', 2000) / 3  # 单餐热量
        
        # 基于健康目标调整偏好
        health_goal = basic_info.get('health_goal', '0')
        if health_goal == '1':  # 减脂
            preferred_nutrition = [target_calories * 0.8, 25, 8, 30]  # 低热量，高蛋白
        elif health_goal == '2':  # 增肌
            preferred_nutrition = [target_calories * 1.2, 35, 15, 40]  # 高热量，高蛋白
        else:  # 保持
            preferred_nutrition = [target_calories, 20, 12, 35]  # 均衡营养
        
        # 标准化偏好向量
        preference_vector = np.array(preferred_nutrition + [3.0])  # 添加纤维偏好
        return self.feature_scaler.transform([preference_vector])[0]
    
    def _calculate_food_similarities(self, user_vector: np.ndarray) -> List[Tuple[str, float]]:
        """计算食物相似度"""
        nutrition_cols = [col for col in self.food_features.columns 
                         if col.endswith('_per_100g')]
        
        food_nutrition = self.food_features[nutrition_cols].values
        
        # 计算余弦相似度
        similarities = cosine_similarity([user_vector], food_nutrition)[0]
        
        # 与食物名称配对
        food_similarities = list(zip(self.food_features['food_name'], similarities))
        
        return food_similarities
    
    def _filter_and_rank_foods(
        self, 
        similarities: List[Tuple[str, float]],
        user_profile: Dict,
        meal_type: str,
        n_recommendations: int
    ) -> List[Dict]:
        """过滤和排序食物"""
        
        # 过滤不喜欢的食物
        disliked_foods = user_profile.get('preferences', {}).get('disliked_foods', [])
        filtered_similarities = [
            (food, sim) for food, sim in similarities 
            if food not in disliked_foods and sim > 0.1
        ]
        
        # 按相似度排序
        filtered_similarities.sort(key=lambda x: x[1], reverse=True)
        
        # 构建推荐结果
        recommendations = []
        for food_name, similarity in filtered_similarities[:n_recommendations]:
            # 获取食物详细信息
            food_info = self.food_features[self.food_features['food_name'] == food_name].iloc[0]
            
            rec = {
                'food_name': food_name,
                'food_id': food_info['food_id'],
                'score': similarity,
                'nutrition_info': {
                    'calories_per_100g': food_info.get('calories_per_100g', 0),
                    'protein_per_100g': food_info.get('protein_per_100g', 0),
                    'fat_per_100g': food_info.get('fat_per_100g', 0),
                    'carbohydrate_per_100g': food_info.get('carbohydrate_per_100g', 0)
                },
                'algorithm_used': 'content_based',
                'reason': f"基于营养成分和您的健康目标推荐"
            }
            recommendations.append(rec)
        
        return recommendations
    
    def save_model(self, filepath: str):
        """保存模型"""
        if self.trained:
            joblib.dump({
                'food_features': self.food_features,
                'feature_scaler': self.feature_scaler,
                'tfidf_vectorizer': self.tfidf_vectorizer,
                'trained': self.trained
            }, filepath)
    
    def load_model(self, filepath: str):
        """加载模型"""
        try:
            data = joblib.load(filepath)
            self.food_features = data['food_features']
            self.feature_scaler = data['feature_scaler']
            self.tfidf_vectorizer = data['tfidf_vectorizer']
            self.trained = data['trained']
        except Exception as e:
            logger.error(f"加载内容推荐模型失败: {e}")


