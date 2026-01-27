"""
数据加载和预处理模块（简化版 - 仅MySQL）
MongoDB和Redis功能已移除，简化系统依赖
"""

import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import logging
from utils.config import Config

logger = logging.getLogger(__name__)

class DataLoader:
    """数据加载器（仅MySQL）"""
    
    def __init__(self):
        self.mysql_engine = None
        self._initialize_connections()
    
    def _initialize_connections(self):
        """初始化数据库连接（仅MySQL）"""
        try:
            # MySQL连接
            self.mysql_engine = create_engine(Config.get_mysql_url())
            logger.info("✓ MySQL连接初始化成功")
            
        except Exception as e:
            logger.error(f"数据库连接初始化失败: {e}")
            raise
    
    def get_user_basic_info(self, user_id: int = None) -> pd.DataFrame:
        """获取用户基础信息"""
        query = """
        SELECT 
            u.user_id,
            u.user_name,
            u.email,
            u.phonenumber,
            u.sex as gender,
            u.create_time,
            uh.height,
            uh.weight,
            uh.age,
            uh.activity_level,
            uh.health_goal,
            uh.target_weight,
            uh.daily_calorie_goal,
            uh.allergies,
            uh.diseases
        FROM sys_user u
        LEFT JOIN sys_user_health uh ON u.user_id = uh.user_id
        WHERE u.del_flag = '0'
        """
        
        if user_id:
            query += f" AND u.user_id = {user_id}"
        
        try:
            return pd.read_sql(query, self.mysql_engine)
        except Exception as e:
            logger.error(f"获取用户基础信息失败: {e}")
            return pd.DataFrame()
    
    def get_diet_records(self, user_id: int = None, days_back: int = 30) -> pd.DataFrame:
        """获取饮食记录数据"""
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days_back)
        
        query = """
        SELECT 
            record_id,
            user_id,
            record_date,
            meal_type,
            total_calories,
            total_protein,
            total_fat,
            total_carbohydrate,
            mongo_doc_id,
            image_urls,
            notes,
            create_time
        FROM diet_record
        WHERE record_date BETWEEN :start_date AND :end_date
        """
        
        params = {'start_date': start_date, 'end_date': end_date}
        
        if user_id:
            query += " AND user_id = :user_id"
            params['user_id'] = user_id
        
        try:
            return pd.read_sql(text(query), self.mysql_engine, params=params)
        except Exception as e:
            logger.error(f"获取饮食记录失败: {e}")
            return pd.DataFrame()
    
    def get_food_info(self) -> pd.DataFrame:
        """获取食物基础信息（JOIN营养表）"""
        query = """
        SELECT 
            f.food_id,
            f.food_name,
            f.category_id,
            f.description,
            f.brand,
            n.calories as calories_per_100g,
            n.protein as protein_per_100g,
            n.fat as fat_per_100g,
            n.carbohydrate as carbohydrate_per_100g,
            n.fiber as fiber_per_100g,
            n.vitamin_c,
            n.calcium,
            n.iron,
            f.create_time
        FROM diet_food_info f
        LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id
        WHERE f.status = '0'
        """
        
        try:
            df = pd.read_sql(query, self.mysql_engine)
            logger.info(f"✅ 加载了 {len(df)} 种食物信息")
            return df
        except Exception as e:
            logger.error(f"获取食物信息失败: {e}", exc_info=True)
            return pd.DataFrame()
    
    def get_recommendations_history(self, user_id: int = None, days_back: int = 90) -> pd.DataFrame:
        """获取推荐历史数据"""
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days_back)
        
        query = """
        SELECT 
            recommendation_id,
            user_id,
            recommendation_date,
            meal_type,
            recommended_foods,
            target_calories,
            target_protein,
            target_fat,
            target_carbohydrate,
            recommendation_reason,
            algorithm_type,
            score,
            is_accepted,
            create_time
        FROM diet_recommendation
        WHERE recommendation_date BETWEEN :start_date AND :end_date
        """
        
        params = {'start_date': start_date, 'end_date': end_date}
        
        if user_id:
            query += " AND user_id = :user_id"
            params['user_id'] = user_id
        
        try:
            return pd.read_sql(text(query), self.mysql_engine, params=params)
        except Exception as e:
            logger.error(f"获取推荐历史失败: {e}")
            return pd.DataFrame()
    
    def get_user_preferences(self, user_id: int = None) -> pd.DataFrame:
        """获取用户饮食偏好"""
        query = """
        SELECT 
            preference_id,
            user_id,
            preferred_foods,
            disliked_foods,
            cuisine_preferences,
            dietary_restrictions,
            meal_frequency,
            snack_preference,
            spice_level,
            create_time,
            update_time
        FROM diet_user_preference
        """
        
        if user_id:
            query += f" WHERE user_id = {user_id}"
        
        try:
            return pd.read_sql(query, self.mysql_engine)
        except Exception as e:
            logger.error(f"获取用户偏好失败: {e}")
            return pd.DataFrame()
    
    def build_user_item_matrix(self, interaction_type: str = "consumption") -> pd.DataFrame:
        """构建用户-物品交互矩阵"""
        try:
            # 基于饮食记录构建交互矩阵
            diet_records = self.get_diet_records(days_back=180)
            
            if diet_records.empty:
                logger.warning("没有找到饮食记录数据")
                return pd.DataFrame()
            
            # 从notes字段中提取食物名称（简化处理）
            diet_records['food_names'] = diet_records['notes'].fillna('未知食物')
            
            # 计算隐式评分
            diet_records['implicit_rating'] = self._calculate_implicit_rating(diet_records)
            
            # 构建用户-食物矩阵
            user_item_matrix = diet_records.pivot_table(
                index='user_id',
                columns='food_names',
                values='implicit_rating',
                aggfunc='mean',
                fill_value=0
            )
            
            return user_item_matrix
            
        except Exception as e:
            logger.error(f"构建用户-物品矩阵失败: {e}")
            return pd.DataFrame()
    
    def _calculate_implicit_rating(self, records: pd.DataFrame) -> pd.Series:
        """计算隐式评分"""
        # 基于多个因素计算隐式评分
        ratings = pd.Series(index=records.index, dtype=float)
        
        for idx, record in records.iterrows():
            score = 1.0  # 基础分
            
            # 热量合理性 (目标2000卡路里)
            if 1800 <= record['total_calories'] <= 2200:
                score += 1.0
            elif 1500 <= record['total_calories'] <= 2500:
                score += 0.5
            
            # 营养平衡性
            if record['total_protein'] > 0 and record['total_fat'] > 0 and record['total_carbohydrate'] > 0:
                score += 1.0
            
            # 有图片说明用户重视 
            if pd.notna(record['image_urls']) and record['image_urls']:
                score += 0.5
            
            # 有备注说明用户认真记录
            if pd.notna(record['notes']) and len(str(record['notes'])) > 5:
                score += 0.5
            
            ratings.iloc[idx] = min(5.0, score)  # 最高5分
        
        return ratings
    
    def get_food_nutrition_matrix(self) -> pd.DataFrame:
        """获取食物营养特征矩阵"""
        food_info = self.get_food_info()
        
        if food_info.empty:
            return pd.DataFrame()
        
        # 选择营养特征列
        nutrition_columns = [
            'calories_per_100g', 'protein_per_100g', 'fat_per_100g',
            'carbohydrate_per_100g', 'fiber_per_100g', 'sodium_per_100g'
        ]
        
        # 填充缺失值并标准化
        nutrition_matrix = food_info[['food_id', 'food_name'] + nutrition_columns].copy()
        nutrition_matrix[nutrition_columns] = nutrition_matrix[nutrition_columns].fillna(0)
        
        return nutrition_matrix
    
    def get_training_data(self, days_back: int = 180) -> Dict[str, pd.DataFrame]:
        """获取模型训练所需的所有数据"""
        logger.info(f"获取最近{days_back}天的训练数据...")
        
        training_data = {
            'users': self.get_user_basic_info(),
            'diet_records': self.get_diet_records(days_back=days_back),
            'food_info': self.get_food_info(),
            'recommendations': self.get_recommendations_history(days_back=days_back),
            'preferences': self.get_user_preferences(),
            'user_item_matrix': self.build_user_item_matrix()
        }
        
        # 数据质量检查
        self._validate_training_data(training_data)
        
        return training_data
    
    def _validate_training_data(self, data: Dict[str, pd.DataFrame]):
        """验证训练数据质量"""
        for name, df in data.items():
            if df.empty:
                logger.warning(f"数据集 {name} 为空")
            else:
                logger.info(f"数据集 {name}: {len(df)} 条记录")
                
                # 检查关键字段的缺失情况
                if name == 'diet_records':
                    missing_calories = df['total_calories'].isna().sum()
                    if missing_calories > 0:
                        logger.warning(f"饮食记录中有 {missing_calories} 条缺少热量数据")
                
                elif name == 'users':
                    missing_health = df[['height', 'weight', 'age']].isna().sum().sum()
                    if missing_health > 0:
                        logger.warning(f"用户数据中有 {missing_health} 个健康信息缺失")
    
    def load_user_interactions(self, start_date=None, end_date=None):
        """加载用户交互数据（兼容性方法）"""
        try:
            # 尝试从饮食记录构建交互数据
            diet_records = self.get_diet_records(days_back=180)
            
            if diet_records.empty:
                return self._create_sample_interaction_data()
            
            # 将饮食记录转换为交互数据
            interactions = []
            for _, record in diet_records.iterrows():
                # 从notes中提取食物名称（简化处理）
                food_name = str(record.get('notes', '未知食物'))
                
                interactions.append({
                    'user_id': record['user_id'],
                    'food_id': hash(food_name) % 100 + 1,  # 简单的食物ID映射
                    'rating': self._calculate_implicit_rating_single(record),
                    'timestamp': record.get('record_date', datetime.now()),
                    'interaction_type': 'consumption'
                })
            
            return pd.DataFrame(interactions)
            
        except Exception as e:
            logger.error(f"加载用户交互数据失败: {e}")
            return self._create_sample_interaction_data()
    
    def load_user_interactions_by_user(self, user_id):
        """加载特定用户的交互数据（兼容性方法）"""
        try:
            diet_records = self.get_diet_records(user_id=user_id, days_back=180)
            
            if diet_records.empty:
                return self._create_sample_user_interaction_data(user_id)
            
            interactions = []
            for _, record in diet_records.iterrows():
                food_name = str(record.get('notes', '未知食物'))
                
                interactions.append({
                    'user_id': user_id,
                    'food_id': hash(food_name) % 100 + 1,
                    'rating': self._calculate_implicit_rating_single(record),
                    'timestamp': record.get('record_date', datetime.now()),
                    'interaction_type': 'consumption'
                })
            
            return pd.DataFrame(interactions)
            
        except Exception as e:
            logger.error(f"加载用户{user_id}交互数据失败: {e}")
            return self._create_sample_user_interaction_data(user_id)
    
    def load_food_info(self):
        """加载食物信息（兼容性方法）"""
        try:
            food_info = self.get_food_info()
            
            if food_info.empty:
                return self._create_sample_food_data()
            
            # 转换列名以匹配模型期望
            food_info_mapped = food_info.rename(columns={
                'calories_per_100g': 'calories',
                'protein_per_100g': 'protein',
                'fat_per_100g': 'fat',
                'carbohydrate_per_100g': 'carbohydrate',
                'fiber_per_100g': 'fiber',
                'sodium_per_100g': 'sodium'
            })
            
            return food_info_mapped
            
        except Exception as e:
            logger.error(f"加载食物信息失败: {e}")
            return self._create_sample_food_data()
    
    def _calculate_implicit_rating_single(self, record):
        """计算单条记录的隐式评分"""
        score = 1.0
        
        # 热量合理性
        calories = record.get('total_calories', 0)
        if 1800 <= calories <= 2200:
            score += 2.0
        elif 1500 <= calories <= 2500:
            score += 1.0
        
        # 营养平衡性
        if (record.get('total_protein', 0) > 0 and 
            record.get('total_fat', 0) > 0 and 
            record.get('total_carbohydrate', 0) > 0):
            score += 1.0
        
        # 有图片或备注
        if (pd.notna(record.get('image_urls')) or 
            (pd.notna(record.get('notes')) and len(str(record.get('notes', ''))) > 5)):
            score += 1.0
        
        return min(5.0, score)
    
    def _create_sample_food_data(self):
        """创建示例食物数据"""
        food_data = [
            {'food_id': 1, 'food_name': '鸡胸肉', 'calories': 165, 'protein': 31, 'fat': 3.6, 'carbohydrate': 0},
            {'food_id': 2, 'food_name': '三文鱼', 'calories': 208, 'protein': 22, 'fat': 12, 'carbohydrate': 0},
            {'food_id': 3, 'food_name': '牛肉', 'calories': 250, 'protein': 26, 'fat': 15, 'carbohydrate': 0},
            {'food_id': 4, 'food_name': '鸡蛋', 'calories': 155, 'protein': 13, 'fat': 11, 'carbohydrate': 1.1},
            {'food_id': 5, 'food_name': '牛奶', 'calories': 42, 'protein': 3.4, 'fat': 1, 'carbohydrate': 5},
            {'food_id': 6, 'food_name': '燕麦', 'calories': 68, 'protein': 2.4, 'fat': 1.4, 'carbohydrate': 12},
            {'food_id': 7, 'food_name': '香蕉', 'calories': 89, 'protein': 1.1, 'fat': 0.3, 'carbohydrate': 23},
            {'food_id': 8, 'food_name': '苹果', 'calories': 52, 'protein': 0.3, 'fat': 0.2, 'carbohydrate': 14},
            {'food_id': 9, 'food_name': '菠菜', 'calories': 23, 'protein': 2.9, 'fat': 0.4, 'carbohydrate': 3.6},
            {'food_id': 10, 'food_name': '西兰花', 'calories': 34, 'protein': 2.8, 'fat': 0.4, 'carbohydrate': 7},
            {'food_id': 11, 'food_name': '胡萝卜', 'calories': 41, 'protein': 0.9, 'fat': 0.2, 'carbohydrate': 10},
            {'food_id': 12, 'food_name': '番茄', 'calories': 18, 'protein': 0.9, 'fat': 0.2, 'carbohydrate': 3.9},
            {'food_id': 13, 'food_name': '土豆', 'calories': 77, 'protein': 2, 'fat': 0.1, 'carbohydrate': 17},
            {'food_id': 14, 'food_name': '红薯', 'calories': 86, 'protein': 1.6, 'fat': 0.1, 'carbohydrate': 20},
            {'food_id': 15, 'food_name': '豆腐', 'calories': 76, 'protein': 8, 'fat': 4.8, 'carbohydrate': 1.9},
            {'food_id': 16, 'food_name': '糙米', 'calories': 111, 'protein': 2.6, 'fat': 0.9, 'carbohydrate': 23},
            {'food_id': 17, 'food_name': '全麦面包', 'calories': 69, 'protein': 3.6, 'fat': 1.2, 'carbohydrate': 12},
            {'food_id': 18, 'food_name': '酸奶', 'calories': 59, 'protein': 10, 'fat': 0.4, 'carbohydrate': 3.6},
            {'food_id': 19, 'food_name': '橙子', 'calories': 47, 'protein': 0.9, 'fat': 0.1, 'carbohydrate': 12},
            {'food_id': 20, 'food_name': '黄瓜', 'calories': 15, 'protein': 0.7, 'fat': 0.1, 'carbohydrate': 3.6}
        ]
        return pd.DataFrame(food_data)
    
    def _create_sample_interaction_data(self, n_interactions=500):
        """创建示例交互数据"""
        np.random.seed(42)
        
        interactions_data = []
        for _ in range(n_interactions):
            user_id = np.random.randint(1, 51)
            food_id = np.random.randint(1, 21)
            rating = np.random.choice([3, 4, 5], p=[0.3, 0.4, 0.3])
            timestamp = datetime.now() - timedelta(days=np.random.randint(0, 180))
            
            interactions_data.append({
                'user_id': user_id,
                'food_id': food_id,
                'rating': rating,
                'timestamp': timestamp,
                'interaction_type': 'consumption'
            })
        
        return pd.DataFrame(interactions_data)
    
    def _create_sample_user_interaction_data(self, user_id, n_interactions=15):
        """为特定用户创建示例交互数据"""
        np.random.seed(user_id)
        
        interactions_data = []
        for _ in range(n_interactions):
            food_id = np.random.randint(1, 21)
            rating = np.random.choice([3, 4, 5], p=[0.2, 0.5, 0.3])
            timestamp = datetime.now() - timedelta(days=np.random.randint(0, 90))
            
            interactions_data.append({
                'user_id': user_id,
                'food_id': food_id,
                'rating': rating,
                'timestamp': timestamp,
                'interaction_type': 'consumption'
            })
        
        return pd.DataFrame(interactions_data)

    def close_connections(self):
        """关闭数据库连接"""
        try:
            if self.mysql_engine:
                self.mysql_engine.dispose()
            logger.info("MySQL连接已关闭")
        except Exception as e:
            logger.error(f"关闭数据库连接失败: {e}")
