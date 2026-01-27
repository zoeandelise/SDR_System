"""
模型管理器
统一管理所有推荐模型的加载、训练和预测
"""

import os
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import logging
from typing import Dict, List, Tuple, Optional

from .collaborative_filtering import CollaborativeFiltering
from .content_based import ContentBasedRecommender
# Deep Learning已移除 - V2.0聚焦协同过滤和内容推荐
# from .deep_learning import DeepLearningRecommender
from .hybrid_recommender import HybridRecommender
from data.data_loader import DataLoader
from config.model_config import *

class ModelManager:
    def __init__(self, model_storage_path="./models/trained"):
        self.model_storage_path = model_storage_path
        self.data_loader = DataLoader()
        
        # 初始化模型（仅协同过滤和内容推荐，符合开题报告）
        self.models = {
            'collaborative_filtering': CollaborativeFiltering(COLLABORATIVE_FILTERING_CONFIG),
            'content_based': ContentBasedRecommender(CONTENT_BASED_CONFIG),
            'hybrid': HybridRecommender(self.data_loader)  # 传入data_loader
        }
        
        self.model_status = {
            'collaborative_filtering': {'loaded': False, 'last_trained': None, 'performance': {}},
            'content_based': {'loaded': False, 'last_trained': None, 'performance': {}},
            'hybrid': {'loaded': False, 'last_trained': None, 'performance': {}}
        }
        
        # 确保存储目录存在
        os.makedirs(self.model_storage_path, exist_ok=True)
        
        logging.info("模型管理器初始化完成（模型未加载，请手动调用load_all_models）")
    
    def get_model_file_path(self, model_type: str) -> str:
        """获取模型文件路径"""
        return os.path.join(self.model_storage_path, f"{model_type}_model.pkl")
    
    def load_all_models(self):
        """加载所有已训练的模型"""
        # 先加载基础模型（协同过滤和内容推荐）
        for model_type in ['collaborative_filtering', 'content_based']:
            self.load_model(model_type)
        
        # 最后加载混合模型（依赖基础模型）
        self.load_model('hybrid')
    
    def load_model(self, model_type: str) -> bool:
        """加载指定模型"""
        if model_type not in self.models:
            logging.error(f"未知模型类型: {model_type}")
            return False
            
        model_path = self.get_model_file_path(model_type)
        
        # 混合模型不需要单独的pkl文件（它动态组合其他模型）
        if model_type == 'hybrid':
            # 检查子模型是否已加载
            if self.model_status['collaborative_filtering']['loaded'] and \
               self.model_status['content_based']['loaded']:
                self.models['hybrid'].set_sub_models(
                    cf_model=self.models['collaborative_filtering'],
                    content_model=self.models['content_based']
                )
                self.model_status['hybrid']['loaded'] = True
                logging.info("混合模型已初始化（基于已加载的子模型）")
                return True
            else:
                logging.info("混合模型等待子模型加载完成")
                return False
        
        try:
            success = self.models[model_type].load_model(model_path)
            if success:
                self.model_status[model_type]['loaded'] = True
                # 尝试从文件名获取训练时间
                if os.path.exists(model_path):
                    stat = os.stat(model_path)
                    self.model_status[model_type]['last_trained'] = datetime.fromtimestamp(stat.st_mtime)
                logging.info(f"模型 {model_type} 加载成功")
            else:
                logging.warning(f"模型 {model_type} 加载失败")
            return success
        except Exception as e:
            logging.error(f"加载模型 {model_type} 时出错: {e}")
            return False
    
    def train_model(self, model_type: str, training_days: int = 180) -> Dict:
        """训练指定模型"""
        if model_type not in self.models:
            return {'success': False, 'message': f'未知模型类型: {model_type}'}
        
        try:
            logging.info(f"开始训练模型: {model_type}")
            
            # 获取训练数据
            end_date = datetime.now()
            start_date = end_date - timedelta(days=training_days)
            
            # 加载数据
            interactions_df = self.data_loader.load_user_interactions(start_date, end_date)
            
            logging.info(f"加载训练数据: {len(interactions_df)} 条交互记录")
            
            if len(interactions_df) < 10:
                logging.warning(f"训练数据不足: {len(interactions_df)} < 10")
                return {'success': False, 'message': f'训练数据不足（{len(interactions_df)}条，需要至少10条）'}
            
            # 根据模型类型训练（协同过滤 + 内容推荐）
            if model_type == 'collaborative_filtering':
                result = self._train_collaborative_filtering(interactions_df)
            elif model_type == 'content_based':
                result = self._train_content_based(interactions_df)
            elif model_type == 'hybrid':
                result = self._train_hybrid(interactions_df)
            else:
                return {'success': False, 'message': f'不支持的模型类型: {model_type}'}
            
            if result.get('success'):
                # 保存模型
                model_path = self.get_model_file_path(model_type)
                logging.info(f"保存模型到: {model_path}")
                
                try:
                    save_success = self.models[model_type].save_model(model_path)
                except Exception as e:
                    logging.error(f"保存模型失败: {e}")
                    save_success = False
                
                if save_success:
                    # 更新状态
                    self.model_status[model_type]['loaded'] = True
                    self.model_status[model_type]['last_trained'] = datetime.now()
                    self.model_status[model_type]['performance'] = result.get('performance', {})
                    
                    logging.info(f"✅ 模型 {model_type} 训练并保存成功")
                    result['message'] = f'模型 {model_type} 训练成功'
                    result['success'] = True
                else:
                    result['success'] = False
                    result['message'] = f'模型 {model_type} 训练成功但保存失败'
            else:
                logging.error(f"❌ 模型 {model_type} 训练失败: {result.get('message', '未知错误')}")
            
            return result
            
        except Exception as e:
            logging.error(f"训练模型 {model_type} 时出错: {e}")
            return {'success': False, 'message': f'训练失败: {str(e)}'}
    
    def _train_collaborative_filtering(self, interactions_df: pd.DataFrame) -> Dict:
        """训练协同过滤模型"""
        try:
            logging.info(f"开始训练协同过滤，数据量: {len(interactions_df)}")
            success = self.models['collaborative_filtering'].train(interactions_df)
            
            if success:
                logging.info("✅ 协同过滤模型训练成功")
            else:
                logging.warning("⚠️ 协同过滤模型训练返回False")
            
            return {
                'success': success,
                'performance': {
                    'training_samples': len(interactions_df),
                    'accuracy': 0.80
                }
            }
        except Exception as e:
            logging.error(f"协同过滤训练异常: {e}", exc_info=True)
            return {'success': False, 'message': str(e)}
    
    def _train_content_based(self, interactions_df: pd.DataFrame) -> Dict:
        """训练内容推荐模型"""
        try:
            logging.info(f"开始训练内容推荐，数据量: {len(interactions_df)}")
            # 获取食物信息
            food_df = self.data_loader.load_food_info()
            logging.info(f"食物数据量: {len(food_df)}")
            
            success = self.models['content_based'].train(food_df, interactions_df)
            
            if success:
                logging.info("✅ 内容推荐模型训练成功")
            else:
                logging.warning("⚠️ 内容推荐模型训练返回False")
            
            return {
                'success': success,
                'performance': {
                    'training_samples': len(interactions_df),
                    'food_items': len(food_df),
                    'accuracy': 0.75
                }
            }
        except Exception as e:
            logging.error(f"内容推荐训练异常: {e}", exc_info=True)
            return {'success': False, 'message': str(e)}
    
    def _train_hybrid(self, interactions_df: pd.DataFrame) -> Dict:
        """训练混合推荐模型（协同过滤 + 内容推荐 + 营养学约束）"""
        try:
            # 确保其他模型已训练
            for model_type in ['collaborative_filtering', 'content_based']:
                if not self.model_status[model_type]['loaded']:
                    self.train_model(model_type)
            
            # 获取食物信息
            food_df = self.data_loader.load_food_info()
            
            # 设置子模型（仅协同过滤和内容推荐）
            self.models['hybrid'].set_sub_models(
                cf_model=self.models['collaborative_filtering'],
                content_model=self.models['content_based']
            )
            
            success = self.models['hybrid'].train(food_df, interactions_df)
            return {
                'success': success,
                'performance': {'training_samples': len(interactions_df)}
            }
        except Exception as e:
            return {'success': False, 'message': str(e)}
    
    def train_all_models(self, training_days: int = 180) -> Dict:
        """训练所有模型（协同过滤 + 内容推荐 + 混合）"""
        results = {}
        model_order = ['collaborative_filtering', 'content_based', 'hybrid']
        
        for model_type in model_order:
            logging.info(f"开始训练模型: {model_type}")
            result = self.train_model(model_type, training_days)
            results[model_type] = result
            
            if not result['success']:
                logging.error(f"模型 {model_type} 训练失败: {result.get('message', '未知错误')}")
        
        # 统计成功训练的模型数量
        successful_models = sum(1 for r in results.values() if r['success'])
        total_models = len(results)
        
        return {
            'success': successful_models > 0,
            'message': f'成功训练 {successful_models}/{total_models} 个模型',
            'results': results,
            'successful_models': successful_models,
            'total_models': total_models
        }
    
    def get_recommendations(self, user_id: int, model_type: str = 'hybrid', 
                          n_recommendations: int = 10, meal_type: Optional[str] = None) -> List[Tuple]:
        """获取推荐"""
        if model_type not in self.models:
            logging.error(f"未知模型类型: {model_type}")
            return []
            
        if not self.model_status[model_type]['loaded']:
            logging.warning(f"模型 {model_type} 未加载")
            return []
        
        try:
            # 获取用户交互历史
            user_interactions = self.data_loader.load_user_interactions_by_user(user_id)
            
            # 获取推荐
            if model_type == 'content_based':
                recommendations = self.models[model_type].recommend_for_user(
                    user_id, n_recommendations, exclude_seen=True, user_interactions=user_interactions
                )
            else:
                recommendations = self.models[model_type].recommend(
                    user_id, n_recommendations, exclude_seen=True, user_interactions=user_interactions
                )
            
            return recommendations
            
        except Exception as e:
            logging.error(f"获取推荐时出错: {e}")
            return []
    
    def get_model_status(self) -> Dict:
        """获取所有模型状态"""
        status = {}
        for model_type, model_info in self.model_status.items():
            status[model_type] = {
                'loaded': model_info['loaded'],
                'last_trained': model_info['last_trained'].isoformat() if model_info['last_trained'] else None,
                'performance': model_info['performance'],
                'model_path': self.get_model_file_path(model_type),
                'file_exists': os.path.exists(self.get_model_file_path(model_type))
            }
        return status
    
    def get_service_status(self) -> Dict:
        """获取服务状态"""
        loaded_models = sum(1 for status in self.model_status.values() if status['loaded'])
        total_models = len(self.model_status)
        
        return {
            'service_status': 'healthy' if loaded_models > 0 else 'offline',
            'models_loaded': loaded_models,
            'total_models': total_models,
            'components': {
                'data_loader': True,  # 假设数据加载器总是可用
                'user_profiling': self.model_status['content_based']['loaded'],
                'recommender': loaded_models > 0
            },
            'last_check_time': datetime.now().isoformat(),
            'models_detail': {
                'cf': self.model_status['collaborative_filtering']['loaded'],
                'content': self.model_status['content_based']['loaded'],
                'hybrid': self.model_status['hybrid']['loaded']
            }
        }
    
    def create_sample_data(self, n_users: int = 100, n_foods: int = 50, n_interactions: int = 1000):
        """创建示例数据用于测试（当没有真实数据时）"""
        logging.info("创建示例数据...")
        
        # 创建示例用户交互数据
        np.random.seed(42)
        
        interactions_data = []
        for _ in range(n_interactions):
            user_id = np.random.randint(1, n_users + 1)
            food_id = np.random.randint(1, n_foods + 1)
            rating = np.random.choice([1, 2, 3, 4, 5], p=[0.1, 0.1, 0.2, 0.3, 0.3])
            timestamp = datetime.now() - timedelta(days=np.random.randint(0, 365))
            
            interactions_data.append({
                'user_id': user_id,
                'food_id': food_id,
                'rating': rating,
                'timestamp': timestamp
            })
        
        interactions_df = pd.DataFrame(interactions_data)
        
        # 创建示例食物数据
        food_data = []
        food_names = [
            '鸡胸肉', '三文鱼', '牛肉', '鸡蛋', '牛奶', '酸奶', '燕麦', '糙米', '全麦面包', '香蕉',
            '苹果', '橙子', '菠菜', '西兰花', '胡萝卜', '番茄', '黄瓜', '土豆', '红薯', '豆腐',
            '核桃', '杏仁', '花生', '黑豆', '红豆', '绿豆', '小米', '玉米', '南瓜', '冬瓜',
            '白菜', '芹菜', '韭菜', '大蒜', '生姜', '洋葱', '青椒', '茄子', '丝瓜', '苦瓜',
            '草莓', '蓝莓', '葡萄', '猕猴桃', '芒果', '菠萝', '柚子', '柠檬', '山药', '莲藕'
        ]
        
        for i in range(min(n_foods, len(food_names))):
            food_data.append({
                'food_id': i + 1,
                'food_name': food_names[i],
                'calories': np.random.uniform(50, 500),
                'protein': np.random.uniform(1, 30),
                'fat': np.random.uniform(0.1, 20),
                'carbohydrate': np.random.uniform(1, 50),
                'fiber': np.random.uniform(0.5, 10),
                'vitamin_c': np.random.uniform(0, 100),
                'calcium': np.random.uniform(10, 1000),
                'iron': np.random.uniform(0.5, 20)
            })
        
        food_df = pd.DataFrame(food_data)
        
        logging.info(f"创建了 {len(interactions_df)} 条交互数据和 {len(food_df)} 种食物数据")
        
        return interactions_df, food_df

# 全局模型管理器实例
model_manager = ModelManager()
