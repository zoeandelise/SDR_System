"""
用户画像和特征工程模块
"""

import pandas as pd
import numpy as np
from typing import Dict, List, Any, Optional
from datetime import datetime, timedelta
import json
import logging
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

logger = logging.getLogger(__name__)

class UserProfileService:
    """用户画像服务"""
    
    def __init__(self, data_loader):
        self.data_loader = data_loader
        self.scaler = StandardScaler()
        self.label_encoders = {}
        self.user_clusters = None
        
    async def build_user_profile(self, user_id: int, include_history: bool = True, days_back: int = 30) -> Dict[str, Any]:
        """构建用户画像"""
        try:
            # 检查缓存
            cache_key = f"user_profile_{user_id}_{days_back}"
            cached_profile = self.data_loader.get_cached_data(cache_key)
            if cached_profile:
                logger.info(f"从缓存获取用户 {user_id} 的画像")
                return cached_profile
            
            # 获取基础数据
            user_info = self.data_loader.get_user_basic_info(user_id)
            if user_info.empty:
                raise ValueError(f"用户 {user_id} 不存在")
            
            user_row = user_info.iloc[0]
            
            # 构建基础画像
            profile = {
                'user_id': user_id,
                'basic_info': self._extract_basic_info(user_row),
                'health_profile': self._build_health_profile(user_row),
                'generated_at': datetime.now().isoformat()
            }
            
            if include_history:
                # 获取历史数据
                diet_records = self.data_loader.get_diet_records(user_id, days_back)
                preferences = self.data_loader.get_user_preferences(user_id)
                recommendations = self.data_loader.get_recommendations_history(user_id, days_back)
                
                # 构建行为画像
                profile['dietary_behavior'] = self._analyze_dietary_behavior(diet_records)
                profile['preferences'] = self._extract_preferences(preferences, diet_records)
                profile['recommendation_feedback'] = self._analyze_recommendation_feedback(recommendations)
                profile['nutrition_patterns'] = self._analyze_nutrition_patterns(diet_records)
                profile['temporal_patterns'] = self._analyze_temporal_patterns(diet_records)
                
                # 计算用户画像特征向量
                profile['feature_vector'] = self._compute_feature_vector(profile)
                
                # 用户分群
                profile['user_segment'] = self._get_user_segment(profile['feature_vector'])
            
            # 缓存画像
            self.data_loader.cache_data(cache_key, profile, ttl=1800)  # 缓存30分钟
            
            return profile
            
        except Exception as e:
            logger.error(f"构建用户画像失败: {e}")
            raise
    
    def _extract_basic_info(self, user_row: pd.Series) -> Dict[str, Any]:
        """提取基础信息"""
        return {
            'age': int(user_row.get('age', 0)) if pd.notna(user_row.get('age')) else None,
            'gender': user_row.get('gender', ''),
            'height': float(user_row.get('height', 0)) if pd.notna(user_row.get('height')) else None,
            'weight': float(user_row.get('weight', 0)) if pd.notna(user_row.get('weight')) else None,
            'bmi': self._calculate_bmi(user_row.get('height'), user_row.get('weight')),
            'activity_level': user_row.get('activity_level', '2'),
            'health_goal': user_row.get('health_goal', '0'),
            'daily_calorie_goal': int(user_row.get('daily_calorie_goal', 2000)) if pd.notna(user_row.get('daily_calorie_goal')) else 2000,
            'allergies': user_row.get('allergies', ''),
            'diseases': user_row.get('diseases', '')
        }
    
    def _calculate_bmi(self, height: float, weight: float) -> Optional[float]:
        """计算BMI"""
        if pd.notna(height) and pd.notna(weight) and height > 0:
            height_m = height / 100  # 转换为米
            return round(weight / (height_m ** 2), 2)
        return None
    
    def _build_health_profile(self, user_row: pd.Series) -> Dict[str, Any]:
        """构建健康画像"""
        bmi = self._calculate_bmi(user_row.get('height'), user_row.get('weight'))
        
        # BMI分类
        bmi_category = "正常"
        if bmi:
            if bmi < 18.5:
                bmi_category = "偏瘦"
            elif bmi >= 25:
                bmi_category = "超重"
            elif bmi >= 30:
                bmi_category = "肥胖"
        
        # 基础代谢率计算 (Harris-Benedict公式)
        bmr = self._calculate_bmr(
            user_row.get('gender'),
            user_row.get('weight'),
            user_row.get('height'),
            user_row.get('age')
        )
        
        return {
            'bmi': bmi,
            'bmi_category': bmi_category,
            'bmr': bmr,
            'daily_calorie_need': bmr * self._get_activity_multiplier(user_row.get('activity_level', '2')),
            'health_risk_factors': self._identify_health_risks(user_row),
            'dietary_restrictions': self._parse_dietary_restrictions(user_row.get('allergies', ''), user_row.get('diseases', ''))
        }
    
    def _calculate_bmr(self, gender: str, weight: float, height: float, age: int) -> float:
        """计算基础代谢率"""
        if pd.isna(weight) or pd.isna(height) or pd.isna(age):
            return 1800.0  # 默认值
        
        if gender == '0':  # 男性
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        else:  # 女性
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
    
    def _get_activity_multiplier(self, activity_level: str) -> float:
        """获取活动水平系数"""
        multipliers = {
            '0': 1.2,   # 久坐
            '1': 1.375, # 轻度活动
            '2': 1.55,  # 中度活动
            '3': 1.725, # 重度活动
            '4': 1.9    # 极重度活动
        }
        return multipliers.get(activity_level, 1.55)
    
    def _analyze_dietary_behavior(self, diet_records: pd.DataFrame) -> Dict[str, Any]:
        """分析饮食行为"""
        if diet_records.empty:
            return self._get_default_dietary_behavior()
        
        # 基础统计
        total_records = len(diet_records)
        avg_daily_calories = diet_records['total_calories'].mean()
        meal_frequency = diet_records['meal_type'].value_counts().to_dict()
        
        # 营养平衡分析
        nutrition_balance = self._analyze_nutrition_balance(diet_records)
        
        # 饮食规律性
        regularity_score = self._calculate_dietary_regularity(diet_records)
        
        # 食物多样性
        diversity_score = self._calculate_dietary_diversity(diet_records)
        
        return {
            'total_records': total_records,
            'avg_daily_calories': round(avg_daily_calories, 2) if pd.notna(avg_daily_calories) else 0,
            'meal_frequency': meal_frequency,
            'nutrition_balance': nutrition_balance,
            'regularity_score': regularity_score,
            'diversity_score': diversity_score,
            'most_frequent_foods': self._get_frequent_foods(diet_records),
            'typical_meal_times': self._analyze_meal_timing(diet_records)
        }
    
    def _analyze_nutrition_balance(self, diet_records: pd.DataFrame) -> Dict[str, float]:
        """分析营养平衡"""
        total_calories = diet_records['total_calories'].sum()
        total_protein = diet_records['total_protein'].sum()
        total_fat = diet_records['total_fat'].sum()
        total_carbs = diet_records['total_carbohydrate'].sum()
        
        if total_calories == 0:
            return {'protein_ratio': 0, 'fat_ratio': 0, 'carb_ratio': 0, 'balance_score': 0}
        
        # 计算营养素比例
        protein_ratio = (total_protein * 4) / total_calories  # 蛋白质 1g = 4kcal
        fat_ratio = (total_fat * 9) / total_calories  # 脂肪 1g = 9kcal
        carb_ratio = (total_carbs * 4) / total_calories  # 碳水 1g = 4kcal
        
        # 平衡评分 (理想比例: 蛋白质15%, 脂肪30%, 碳水55%)
        protein_score = 1 - abs(protein_ratio - 0.15) / 0.15
        fat_score = 1 - abs(fat_ratio - 0.30) / 0.30
        carb_score = 1 - abs(carb_ratio - 0.55) / 0.55
        
        balance_score = (protein_score + fat_score + carb_score) / 3
        balance_score = max(0, min(1, balance_score))  # 限制在0-1之间
        
        return {
            'protein_ratio': round(protein_ratio, 3),
            'fat_ratio': round(fat_ratio, 3),
            'carb_ratio': round(carb_ratio, 3),
            'balance_score': round(balance_score, 3)
        }
    
    def _calculate_dietary_regularity(self, diet_records: pd.DataFrame) -> float:
        """计算饮食规律性评分"""
        if diet_records.empty:
            return 0.0
        
        # 按日期分组，计算每天的记录数
        daily_records = diet_records.groupby('record_date').size()
        
        # 规律性评分：基于标准差，越小越规律
        regularity = 1 - min(1, daily_records.std() / daily_records.mean()) if daily_records.mean() > 0 else 0
        
        return round(regularity, 3)
    
    def _calculate_dietary_diversity(self, diet_records: pd.DataFrame) -> float:
        """计算饮食多样性评分"""
        if diet_records.empty:
            return 0.0
        
        # 基于备注中的食物名称计算多样性（简化处理）
        food_notes = diet_records['notes'].dropna()
        unique_foods = set()
        
        for note in food_notes:
            # 简单的食物名称提取
            foods = str(note).split('、')
            unique_foods.update([food.strip() for food in foods])
        
        # 多样性评分：独特食物数量 / 总记录数
        diversity = len(unique_foods) / len(diet_records) if len(diet_records) > 0 else 0
        diversity = min(1.0, diversity)  # 最高1分
        
        return round(diversity, 3)
    
    def _get_frequent_foods(self, diet_records: pd.DataFrame, top_k: int = 10) -> List[Dict[str, Any]]:
        """获取常吃食物"""
        if diet_records.empty:
            return []
        
        # 从备注中提取食物（简化处理）
        food_counts = {}
        for note in diet_records['notes'].dropna():
            foods = str(note).split('、')
            for food in foods:
                food = food.strip()
                if food:
                    food_counts[food] = food_counts.get(food, 0) + 1
        
        # 排序并返回top-k
        sorted_foods = sorted(food_counts.items(), key=lambda x: x[1], reverse=True)
        
        return [
            {'food_name': food, 'frequency': count, 'preference_score': min(5.0, count * 0.5)}
            for food, count in sorted_foods[:top_k]
        ]
    
    def _analyze_meal_timing(self, diet_records: pd.DataFrame) -> Dict[str, Any]:
        """分析用餐时间模式"""
        if diet_records.empty:
            return {}
        
        # 按餐次类型分析时间模式
        meal_timing = {}
        meal_names = {'0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'}
        
        for meal_type, meal_name in meal_names.items():
            meal_records = diet_records[diet_records['meal_type'] == meal_type]
            if not meal_records.empty:
                # 分析这个餐次的频率和时间模式
                meal_timing[meal_name] = {
                    'frequency': len(meal_records),
                    'avg_calories': round(meal_records['total_calories'].mean(), 2),
                    'typical_time': self._estimate_meal_time(meal_type)  # 基于餐次类型估算
                }
        
        return meal_timing
    
    def _estimate_meal_time(self, meal_type: str) -> str:
        """估算用餐时间"""
        typical_times = {
            '0': '7:30',   # 早餐
            '1': '12:00',  # 午餐
            '2': '18:30',  # 晚餐
            '3': '15:00'   # 加餐
        }
        return typical_times.get(meal_type, '12:00')
    
    def _extract_preferences(self, preferences_df: pd.DataFrame, diet_records: pd.DataFrame) -> Dict[str, Any]:
        """提取用户偏好"""
        preferences = {
            'preferred_foods': [],
            'disliked_foods': [],
            'cuisine_preferences': [],
            'dietary_restrictions': [],
            'meal_frequency': 3,
            'snack_preference': '1',
            'spice_level': '2'
        }
        
        # 从用户偏好表获取
        if not preferences_df.empty:
            pref_row = preferences_df.iloc[0]
            try:
                if pd.notna(pref_row.get('preferred_foods')):
                    preferences['preferred_foods'] = json.loads(pref_row['preferred_foods'])
                if pd.notna(pref_row.get('disliked_foods')):
                    preferences['disliked_foods'] = json.loads(pref_row['disliked_foods'])
                if pd.notna(pref_row.get('cuisine_preferences')):
                    preferences['cuisine_preferences'] = pref_row['cuisine_preferences'].split(',')
                    
                preferences['meal_frequency'] = int(pref_row.get('meal_frequency', 3))
                preferences['snack_preference'] = pref_row.get('snack_preference', '1')
                preferences['spice_level'] = pref_row.get('spice_level', '2')
                
            except (json.JSONDecodeError, ValueError) as e:
                logger.warning(f"解析用户偏好数据失败: {e}")
        
        # 从饮食记录中推断偏好
        if not diet_records.empty:
            inferred_preferences = self._infer_preferences_from_records(diet_records)
            preferences['inferred_preferences'] = inferred_preferences
        
        return preferences
    
    def _infer_preferences_from_records(self, diet_records: pd.DataFrame) -> Dict[str, Any]:
        """从饮食记录推断偏好"""
        # 分析热量偏好
        avg_calories = diet_records['total_calories'].mean()
        calorie_preference = "适中"
        if avg_calories < 1500:
            calorie_preference = "低热量"
        elif avg_calories > 2500:
            calorie_preference = "高热量"
        
        # 分析营养偏好
        nutrition_preference = self._analyze_nutrition_preference(diet_records)
        
        # 分析餐次偏好
        meal_distribution = diet_records['meal_type'].value_counts(normalize=True)
        most_frequent_meal = meal_distribution.index[0] if not meal_distribution.empty else '1'
        
        return {
            'calorie_preference': calorie_preference,
            'nutrition_preference': nutrition_preference,
            'preferred_meal_type': most_frequent_meal,
            'meal_distribution': meal_distribution.to_dict()
        }
    
    def _analyze_nutrition_preference(self, diet_records: pd.DataFrame) -> Dict[str, str]:
        """分析营养偏好"""
        total_calories = diet_records['total_calories'].sum()
        if total_calories == 0:
            return {'protein': '适中', 'fat': '适中', 'carbohydrate': '适中'}
        
        # 计算营养素比例
        protein_ratio = (diet_records['total_protein'].sum() * 4) / total_calories
        fat_ratio = (diet_records['total_fat'].sum() * 9) / total_calories
        carb_ratio = (diet_records['total_carbohydrate'].sum() * 4) / total_calories
        
        def categorize_ratio(ratio: float, ideal: float) -> str:
            if ratio < ideal * 0.8:
                return "偏低"
            elif ratio > ideal * 1.2:
                return "偏高"
            else:
                return "适中"
        
        return {
            'protein': categorize_ratio(protein_ratio, 0.15),
            'fat': categorize_ratio(fat_ratio, 0.30),
            'carbohydrate': categorize_ratio(carb_ratio, 0.55)
        }
    
    def _analyze_temporal_patterns(self, diet_records: pd.DataFrame) -> Dict[str, Any]:
        """分析时间模式"""
        if diet_records.empty:
            return {}
        
        # 转换日期列
        diet_records['record_date'] = pd.to_datetime(diet_records['record_date'])
        diet_records['weekday'] = diet_records['record_date'].dt.dayofweek
        diet_records['month'] = diet_records['record_date'].dt.month
        
        # 工作日vs周末模式
        weekday_records = diet_records[diet_records['weekday'] < 5]  # 周一到周五
        weekend_records = diet_records[diet_records['weekday'] >= 5]  # 周末
        
        # 季节性模式
        seasonal_patterns = self._analyze_seasonal_patterns(diet_records)
        
        return {
            'weekday_pattern': {
                'avg_calories': round(weekday_records['total_calories'].mean(), 2) if not weekday_records.empty else 0,
                'meal_frequency': len(weekday_records) / max(1, weekday_records['record_date'].nunique())
            },
            'weekend_pattern': {
                'avg_calories': round(weekend_records['total_calories'].mean(), 2) if not weekend_records.empty else 0,
                'meal_frequency': len(weekend_records) / max(1, weekend_records['record_date'].nunique())
            },
            'seasonal_patterns': seasonal_patterns,
            'most_active_days': diet_records['weekday'].value_counts().head(3).index.tolist()
        }
    
    def _analyze_seasonal_patterns(self, diet_records: pd.DataFrame) -> Dict[str, float]:
        """分析季节性饮食模式"""
        seasonal_calories = diet_records.groupby('month')['total_calories'].mean()
        
        # 简化的季节分类
        seasons = {
            'spring': [3, 4, 5],    # 春季
            'summer': [6, 7, 8],    # 夏季
            'autumn': [9, 10, 11],  # 秋季
            'winter': [12, 1, 2]    # 冬季
        }
        
        seasonal_avg = {}
        for season, months in seasons.items():
            season_data = seasonal_calories[seasonal_calories.index.isin(months)]
            seasonal_avg[season] = round(season_data.mean(), 2) if not season_data.empty else 0
        
        return seasonal_avg
    
    def _compute_feature_vector(self, profile: Dict[str, Any]) -> List[float]:
        """计算用户特征向量"""
        features = []
        
        # 基础特征
        basic = profile['basic_info']
        features.extend([
            basic.get('age', 0) / 100,  # 归一化年龄
            1 if basic.get('gender') == '0' else 0,  # 性别 (男=1, 女=0)
            basic.get('bmi', 22) / 40,  # 归一化BMI
            int(basic.get('activity_level', '2')) / 4,  # 归一化活动水平
            int(basic.get('health_goal', '0')) / 3,  # 归一化健康目标
        ])
        
        # 行为特征
        behavior = profile.get('dietary_behavior', {})
        features.extend([
            behavior.get('avg_daily_calories', 2000) / 3000,  # 归一化热量
            behavior.get('regularity_score', 0.5),
            behavior.get('diversity_score', 0.5),
            behavior.get('nutrition_balance', {}).get('balance_score', 0.5)
        ])
        
        # 偏好特征
        preferences = profile.get('preferences', {})
        meal_freq = preferences.get('meal_frequency', 3)
        features.extend([
            meal_freq / 5,  # 归一化用餐频率
            int(preferences.get('snack_preference', '1')) / 2,
            int(preferences.get('spice_level', '2')) / 3
        ])
        
        return features
    
    def _get_user_segment(self, feature_vector: List[float]) -> str:
        """获取用户分群"""
        # 这里简化处理，实际应该基于聚类算法
        if not feature_vector or len(feature_vector) < 5:
            return "普通用户"
        
        # 基于特征简单分类
        bmi_score = feature_vector[2] * 40  # 还原BMI
        activity_score = feature_vector[3] * 4  # 还原活动水平
        balance_score = feature_vector[-1]  # 营养平衡分
        
        if bmi_score < 18.5:
            return "体重不足用户"
        elif bmi_score > 25:
            return "超重用户"
        elif activity_score >= 3:
            return "高活跃用户"
        elif balance_score > 0.8:
            return "营养意识用户"
        else:
            return "普通用户"
    
    def _get_default_dietary_behavior(self) -> Dict[str, Any]:
        """获取默认饮食行为数据"""
        return {
            'total_records': 0,
            'avg_daily_calories': 0,
            'meal_frequency': {},
            'nutrition_balance': {'protein_ratio': 0, 'fat_ratio': 0, 'carb_ratio': 0, 'balance_score': 0},
            'regularity_score': 0,
            'diversity_score': 0,
            'most_frequent_foods': [],
            'typical_meal_times': {}
        }
    
    def _identify_health_risks(self, user_row: pd.Series) -> List[str]:
        """识别健康风险因素"""
        risks = []
        
        # BMI风险
        bmi = self._calculate_bmi(user_row.get('height'), user_row.get('weight'))
        if bmi:
            if bmi < 18.5:
                risks.append("体重不足")
            elif bmi >= 30:
                risks.append("肥胖风险")
            elif bmi >= 25:
                risks.append("超重风险")
        
        # 疾病风险
        diseases = str(user_row.get('diseases', '')).lower()
        if '糖尿病' in diseases or 'diabetes' in diseases:
            risks.append("糖尿病")
        if '高血压' in diseases or 'hypertension' in diseases:
            risks.append("高血压")
        if '心脏病' in diseases or 'heart' in diseases:
            risks.append("心血管疾病")
        
        return risks
    
    def _parse_dietary_restrictions(self, allergies: str, diseases: str) -> List[str]:
        """解析饮食限制"""
        restrictions = []
        
        # 过敏限制
        allergy_text = str(allergies).lower()
        if '牛奶' in allergy_text or 'milk' in allergy_text:
            restrictions.append("无乳糖")
        if '麸质' in allergy_text or 'gluten' in allergy_text:
            restrictions.append("无麸质")
        if '坚果' in allergy_text or 'nut' in allergy_text:
            restrictions.append("无坚果")
        
        # 疾病限制
        disease_text = str(diseases).lower()
        if '糖尿病' in disease_text:
            restrictions.append("低糖")
        if '高血压' in disease_text:
            restrictions.append("低钠")
        if '肾病' in disease_text:
            restrictions.append("低蛋白")
        
        return restrictions
    
    def _analyze_recommendation_feedback(self, recommendations: pd.DataFrame) -> Dict[str, Any]:
        """分析推荐反馈"""
        if recommendations.empty:
            return {'acceptance_rate': 0, 'avg_score': 0, 'total_recommendations': 0}
        
        total_recs = len(recommendations)
        accepted_recs = len(recommendations[recommendations['is_accepted'] == '1'])
        acceptance_rate = accepted_recs / total_recs if total_recs > 0 else 0
        
        avg_score = recommendations['score'].mean() if 'score' in recommendations.columns else 0
        
        return {
            'total_recommendations': total_recs,
            'accepted_recommendations': accepted_recs,
            'acceptance_rate': round(acceptance_rate, 3),
            'avg_score': round(avg_score, 2) if pd.notna(avg_score) else 0,
            'recent_feedback_trend': self._calculate_feedback_trend(recommendations)
        }
    
    def _calculate_feedback_trend(self, recommendations: pd.DataFrame) -> str:
        """计算反馈趋势"""
        if len(recommendations) < 5:
            return "数据不足"
        
        # 按时间排序，比较最近和之前的接受率
        recommendations = recommendations.sort_values('create_time')
        mid_point = len(recommendations) // 2
        
        early_acceptance = (recommendations.iloc[:mid_point]['is_accepted'] == '1').mean()
        recent_acceptance = (recommendations.iloc[mid_point:]['is_accepted'] == '1').mean()
        
        if recent_acceptance > early_acceptance + 0.1:
            return "改善中"
        elif recent_acceptance < early_acceptance - 0.1:
            return "下降中"
        else:
            return "稳定"
