"""
智能饮食推荐系统 - 增强版数据加载器
支持从MySQL和MongoDB加载数据用于机器学习训练
"""

import pandas as pd
import numpy as np
import pymysql
from pymongo import MongoClient
import logging
from typing import Dict, List, Tuple, Optional, Any
from datetime import datetime, timedelta
import json
import os
from dataclasses import dataclass

logger = logging.getLogger(__name__)

@dataclass
class DatabaseConfig:
    """数据库配置"""
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_user: str = "root"
    mysql_password: str = "1234"
    mysql_database: str = "smart_diet_dev"
    
    mongo_host: str = "localhost"
    mongo_port: int = 27017
    mongo_database: str = "diet_system"

class EnhancedDataLoader:
    """增强版数据加载器"""
    
    def __init__(self, config: DatabaseConfig = None):
        self.config = config or DatabaseConfig()
        self.mysql_connection = None
        self.mongo_client = None
        self.mongo_db = None
        
    def connect_databases(self):
        """连接数据库"""
        try:
            # 连接MySQL
            self.mysql_connection = pymysql.connect(
                host=self.config.mysql_host,
                port=self.config.mysql_port,
                user=self.config.mysql_user,
                password=self.config.mysql_password,
                database=self.config.mysql_database,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor
            )
            
            # 连接MongoDB
            self.mongo_client = MongoClient(
                host=self.config.mongo_host,
                port=self.config.mongo_port
            )
            self.mongo_db = self.mongo_client[self.config.mongo_database]
            
            logger.info("数据库连接成功")
            return True
            
        except Exception as e:
            logger.error(f"数据库连接失败: {e}")
            return False
    
    def close_connections(self):
        """关闭数据库连接"""
        try:
            if self.mysql_connection:
                self.mysql_connection.close()
            if self.mongo_client:
                self.mongo_client.close()
            logger.info("数据库连接已关闭")
        except Exception as e:
            logger.error(f"关闭数据库连接失败: {e}")
    
    def load_food_data(self) -> pd.DataFrame:
        """加载食物基础信息"""
        try:
            query = """
            SELECT 
                fi.food_id,
                fi.food_name,
                fi.food_code,
                fi.category_id,
                fi.description,
                fi.unit,
                fi.standard_weight,
                fc.category_name
            FROM diet_food_info fi
            LEFT JOIN diet_food_category fc ON fi.category_id = fc.category_id
            WHERE fi.status = '0'
            """
            
            with self.mysql_connection.cursor() as cursor:
                cursor.execute(query)
                results = cursor.fetchall()
            
            df = pd.DataFrame(results)
            logger.info(f"加载食物数据: {len(df)} 条记录")
            return df
            
        except Exception as e:
            logger.error(f"加载食物数据失败: {e}")
            return pd.DataFrame()
    
    def load_nutrition_data(self) -> pd.DataFrame:
        """加载营养信息"""
        try:
            query = """
            SELECT 
                food_id,
                calories,
                protein,
                fat,
                carbohydrate,
                fiber,
                sugar,
                sodium,
                cholesterol,
                vitamin_a,
                vitamin_c,
                vitamin_d,
                calcium,
                iron,
                potassium
            FROM diet_food_nutrition
            """
            
            with self.mysql_connection.cursor() as cursor:
                cursor.execute(query)
                results = cursor.fetchall()
            
            df = pd.DataFrame(results)
            # 处理缺失值
            df = df.fillna(0)
            logger.info(f"加载营养数据: {len(df)} 条记录")
            return df
            
        except Exception as e:
            logger.error(f"加载营养数据失败: {e}")
            return pd.DataFrame()
    
    def load_user_health_data(self) -> pd.DataFrame:
        """加载用户健康信息"""
        try:
            query = """
            SELECT 
                uh.user_id,
                uh.height,
                uh.weight,
                uh.age,
                uh.gender,
                uh.activity_level,
                uh.health_goal,
                uh.target_weight,
                uh.daily_calorie_goal,
                uh.allergies,
                uh.diseases,
                u.nick_name
            FROM sys_user_health uh
            LEFT JOIN sys_user u ON uh.user_id = u.user_id
            WHERE u.status = '0'
            """
            
            with self.mysql_connection.cursor() as cursor:
                cursor.execute(query)
                results = cursor.fetchall()
            
            df = pd.DataFrame(results)
            # 处理缺失值
            df = df.fillna({
                'height': 170,
                'weight': 65,
                'age': 25,
                'gender': '0',
                'activity_level': '2',
                'health_goal': '0',
                'daily_calorie_goal': 2000
            })
            
            logger.info(f"加载用户健康数据: {len(df)} 条记录")
            return df
            
        except Exception as e:
            logger.error(f"加载用户健康数据失败: {e}")
            return pd.DataFrame()
    
    def load_diet_records(self, days: int = 30) -> pd.DataFrame:
        """加载饮食记录"""
        try:
            # 计算日期范围
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
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
                notes,
                create_time
            FROM diet_record
            WHERE record_date >= %s AND record_date <= %s
            ORDER BY record_date DESC, user_id
            """
            
            with self.mysql_connection.cursor() as cursor:
                cursor.execute(query, (start_date.date(), end_date.date()))
                results = cursor.fetchall()
            
            df = pd.DataFrame(results)
            logger.info(f"加载饮食记录: {len(df)} 条记录")
            return df
            
        except Exception as e:
            logger.error(f"加载饮食记录失败: {e}")
            return pd.DataFrame()
    
    def load_detailed_diet_records(self, record_ids: List[str] = None) -> Dict[str, Any]:
        """从MongoDB加载详细饮食记录"""
        try:
            if not self.mongo_db:
                logger.warning("MongoDB未连接，无法加载详细记录")
                return {}
            
            collection = self.mongo_db.diet_record_details
            
            if record_ids:
                # 加载指定记录
                query = {"record_id": {"$in": record_ids}}
            else:
                # 加载最近的记录
                query = {}
            
            cursor = collection.find(query).limit(1000)
            details = {}
            
            for doc in cursor:
                record_id = doc.get('record_id')
                if record_id:
                    details[record_id] = {
                        'foods': doc.get('foods', []),
                        'total_nutrition': doc.get('total_nutrition', {}),
                        'images': doc.get('images', []),
                        'analysis': doc.get('analysis', {})
                    }
            
            logger.info(f"加载详细饮食记录: {len(details)} 条")
            return details
            
        except Exception as e:
            logger.error(f"加载详细饮食记录失败: {e}")
            return {}
    
    def generate_interaction_data(self) -> pd.DataFrame:
        """生成用户-食物交互数据用于协同过滤"""
        try:
            # 从饮食记录中提取交互数据
            diet_records = self.load_diet_records(180)  # 最近6个月
            
            if diet_records.empty:
                return self._generate_mock_interactions()
            
            # 获取详细记录
            mongo_doc_ids = diet_records['mongo_doc_id'].dropna().tolist()
            detailed_records = self.load_detailed_diet_records(mongo_doc_ids)
            
            interactions = []
            
            for _, record in diet_records.iterrows():
                user_id = record['user_id']
                mongo_doc_id = record['mongo_doc_id']
                record_date = record['record_date']
                meal_type = record['meal_type']
                
                # 如果有详细记录，提取食物信息
                if mongo_doc_id in detailed_records:
                    foods = detailed_records[mongo_doc_id].get('foods', [])
                    for food in foods:
                        food_id = food.get('food_id')
                        quantity = food.get('quantity', 100)
                        
                        if food_id:
                            # 计算评分（基于数量和营养匹配度）
                            rating = self._calculate_implicit_rating(food, record, quantity)
                            
                            interactions.append({
                                'user_id': user_id,
                                'food_id': food_id,
                                'rating': rating,
                                'timestamp': record_date,
                                'meal_type': meal_type,
                                'quantity': quantity
                            })
                else:
                    # 如果没有详细记录，基于热量估算食物
                    estimated_foods = self._estimate_foods_from_calories(
                        record['total_calories'], meal_type
                    )
                    for food_id, estimated_rating in estimated_foods:
                        interactions.append({
                            'user_id': user_id,
                            'food_id': food_id,
                            'rating': estimated_rating,
                            'timestamp': record_date,
                            'meal_type': meal_type,
                            'quantity': 100
                        })
            
            df = pd.DataFrame(interactions)
            
            if df.empty:
                return self._generate_mock_interactions()
            
            logger.info(f"生成交互数据: {len(df)} 条交互记录")
            return df
            
        except Exception as e:
            logger.error(f"生成交互数据失败: {e}")
            return self._generate_mock_interactions()
    
    def _calculate_implicit_rating(self, food: Dict, record: Dict, quantity: float) -> float:
        """计算隐式评分"""
        try:
            # 基础评分（3.0-5.0）
            base_rating = 3.0
            
            # 根据食物数量调整（数量多表示喜欢）
            if quantity > 150:
                base_rating += 1.0
            elif quantity > 100:
                base_rating += 0.5
            elif quantity < 50:
                base_rating -= 0.5
            
            # 根据营养匹配度调整
            # （这里简化处理，实际可以更复杂）
            if record.get('total_calories', 0) > 0:
                calorie_ratio = quantity * food.get('calories_per_100g', 100) / 100 / record['total_calories']
                if 0.1 <= calorie_ratio <= 0.4:  # 合理比例
                    base_rating += 0.5
            
            # 限制评分范围
            return max(1.0, min(5.0, base_rating))
            
        except Exception:
            return 3.0
    
    def _estimate_foods_from_calories(self, total_calories: float, meal_type: int) -> List[Tuple[int, float]]:
        """根据热量估算可能的食物"""
        # 这里使用简化的估算方法
        # 实际应用中可以基于营养数据库进行更精确的估算
        
        estimated_foods = []
        
        # 根据餐次和热量范围估算
        if meal_type == 0:  # 早餐
            if 200 <= total_calories <= 400:
                estimated_foods = [(1, 4.0), (2, 3.5), (40, 4.5)]  # 米饭、燕麦、鸡蛋
            elif total_calories > 400:
                estimated_foods = [(1, 3.5), (3, 4.0), (40, 4.0), (41, 3.5)]  # 更丰富的早餐
        elif meal_type == 1:  # 午餐
            if 400 <= total_calories <= 800:
                estimated_foods = [(1, 4.0), (29, 4.5), (9, 3.5)]  # 米饭、鸡胸肉、西兰花
            elif total_calories > 800:
                estimated_foods = [(1, 3.5), (30, 4.0), (29, 4.0), (11, 3.5)]  # 丰盛午餐
        elif meal_type == 2:  # 晚餐
            if 300 <= total_calories <= 600:
                estimated_foods = [(34, 4.5), (9, 4.0), (10, 3.5)]  # 鱼类、蔬菜
            elif total_calories > 600:
                estimated_foods = [(1, 3.0), (30, 4.0), (9, 4.0)]  # 丰盛晚餐
        
        return estimated_foods
    
    def _generate_mock_interactions(self) -> pd.DataFrame:
        """生成模拟交互数据"""
        logger.info("生成模拟交互数据")
        
        # 使用测试用户和食物
        user_ids = list(range(101, 151))  # 测试用户ID 101-150
        food_ids = list(range(1, 56))     # 食物ID 1-55
        
        interactions = []
        
        # 为每个用户生成一些交互记录
        for user_id in user_ids:
            # 每个用户随机选择10-30种食物进行评分
            n_interactions = np.random.randint(10, 31)
            selected_foods = np.random.choice(food_ids, n_interactions, replace=False)
            
            for food_id in selected_foods:
                # 生成评分（1-5）
                # 大部分评分集中在3-5，符合真实情况
                rating = np.random.choice([3, 4, 5], p=[0.2, 0.5, 0.3])
                
                # 随机时间戳（最近30天）
                days_ago = np.random.randint(0, 30)
                timestamp = datetime.now() - timedelta(days=days_ago)
                
                # 随机餐次
                meal_type = np.random.randint(0, 4)
                
                interactions.append({
                    'user_id': user_id,
                    'food_id': int(food_id),
                    'rating': float(rating),
                    'timestamp': timestamp,
                    'meal_type': meal_type,
                    'quantity': np.random.randint(50, 200)
                })
        
        df = pd.DataFrame(interactions)
        logger.info(f"生成模拟交互数据: {len(df)} 条记录")
        return df
    
    def prepare_training_data(self, days: int = 180) -> Dict[str, pd.DataFrame]:
        """准备训练数据"""
        logger.info("开始准备训练数据...")
        
        data = {}
        
        try:
            # 连接数据库
            if not self.connect_databases():
                logger.warning("数据库连接失败，使用模拟数据")
                return self._prepare_mock_training_data()
            
            # 加载各类数据
            data['food_df'] = self.load_food_data()
            data['nutrition_df'] = self.load_nutrition_data()
            data['user_health_df'] = self.load_user_health_data()
            data['diet_records_df'] = self.load_diet_records(days)
            data['interactions_df'] = self.generate_interaction_data()
            
            # 数据验证
            if any(df.empty for df in data.values()):
                logger.warning("部分数据为空，补充模拟数据")
                mock_data = self._prepare_mock_training_data()
                for key, df in data.items():
                    if df.empty and key in mock_data:
                        data[key] = mock_data[key]
            
            logger.info("训练数据准备完成")
            return data
            
        except Exception as e:
            logger.error(f"准备训练数据失败: {e}")
            return self._prepare_mock_training_data()
        
        finally:
            self.close_connections()
    
    def _prepare_mock_training_data(self) -> Dict[str, pd.DataFrame]:
        """准备模拟训练数据"""
        logger.info("生成模拟训练数据")
        
        # 模拟食物数据
        food_data = []
        categories = ['谷物类', '蔬菜类', '水果类', '肉类', '海鲜类', '蛋奶类', '豆类坚果', '饮品类']
        
        for i in range(1, 56):
            food_data.append({
                'food_id': i,
                'food_name': f'食物{i}',
                'food_code': f'FOOD{i:03d}',
                'category_id': (i % 8) + 1,
                'category_name': categories[i % 8],
                'description': f'这是食物{i}的描述，营养丰富，适合日常食用',
                'unit': 'g',
                'standard_weight': 100
            })
        
        # 模拟营养数据
        nutrition_data = []
        for i in range(1, 56):
            nutrition_data.append({
                'food_id': i,
                'calories': np.random.randint(20, 400),
                'protein': np.random.uniform(0.5, 30),
                'fat': np.random.uniform(0.1, 25),
                'carbohydrate': np.random.uniform(0, 80),
                'fiber': np.random.uniform(0, 15),
                'sugar': np.random.uniform(0, 20),
                'sodium': np.random.uniform(0, 1000)
            })
        
        # 模拟用户健康数据
        user_health_data = []
        for user_id in range(101, 151):
            user_health_data.append({
                'user_id': user_id,
                'height': np.random.randint(150, 190),
                'weight': np.random.randint(45, 100),
                'age': np.random.randint(18, 65),
                'gender': np.random.choice(['0', '1']),
                'activity_level': np.random.randint(0, 5),
                'health_goal': np.random.randint(0, 3),
                'daily_calorie_goal': np.random.randint(1500, 3000),
                'nick_name': f'用户{user_id}'
            })
        
        # 模拟饮食记录
        diet_records_data = []
        for user_id in range(101, 151):
            for day in range(30):  # 30天记录
                date = datetime.now() - timedelta(days=day)
                for meal in range(3):  # 一日三餐
                    diet_records_data.append({
                        'record_id': len(diet_records_data) + 1,
                        'user_id': user_id,
                        'record_date': date.date(),
                        'meal_type': meal,
                        'total_calories': np.random.randint(200, 800),
                        'total_protein': np.random.uniform(5, 50),
                        'total_fat': np.random.uniform(2, 30),
                        'total_carbohydrate': np.random.uniform(10, 100),
                        'mongo_doc_id': None,
                        'notes': '',
                        'create_time': date
                    })
        
        return {
            'food_df': pd.DataFrame(food_data),
            'nutrition_df': pd.DataFrame(nutrition_data),
            'user_health_df': pd.DataFrame(user_health_data),
            'diet_records_df': pd.DataFrame(diet_records_data),
            'interactions_df': self._generate_mock_interactions()
        }

# 使用示例
if __name__ == "__main__":
    # 配置日志
    logging.basicConfig(level=logging.INFO)
    
    # 创建数据加载器
    loader = EnhancedDataLoader()
    
    # 准备训练数据
    training_data = loader.prepare_training_data()
    
    # 打印数据概况
    for key, df in training_data.items():
        print(f"{key}: {len(df)} 条记录")
        if not df.empty:
            print(f"  列名: {list(df.columns)}")
        print()
