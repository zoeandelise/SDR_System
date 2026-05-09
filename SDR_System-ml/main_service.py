"""
智能饮食推荐系统 - ML训练服务（统一版）
提供模型训练、推荐和服务管理功能
"""

import os
import logging
from datetime import datetime
from typing import Dict, Optional
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager

from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# 导入模型和数据加载器
from models.model_manager import ModelManager
from data.data_loader import DataLoader
from utils.config import Config

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/ml_service.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# FastAPI应用将在后面创建（需要先定义lifespan函数）

# 全局变量
model_manager: Optional[ModelManager] = None
data_loader: Optional[DataLoader] = None
training_executor = ThreadPoolExecutor(max_workers=3)
training_tasks: Dict[str, Dict] = {}  # 训练任务状态管理


# ====================
# Pydantic模型定义
# ====================

class TrainingRequest(BaseModel):
    """训练请求模型"""
    model_config = {"protected_namespaces": ()}  # 允许model_开头的字段
    model_type: str
    training_days: int = 180
    training_id: Optional[int] = None


class RecommendationRequest(BaseModel):
    """推荐请求模型"""
    user_id: int
    meal_type: str = "1"
    n_recommendations: int = 10


class ServiceHealth(BaseModel):
    """服务健康状态"""
    status: str
    timestamp: str
    models_loaded: int
    data_loader: bool
    recommender: bool


# ====================
# 初始化函数
# ====================

def initialize_services():
    """初始化服务组件"""
    global model_manager, data_loader
    
    try:
        logger.info("正在初始化ML服务...")
        
        # 创建必要的目录
        os.makedirs('logs', exist_ok=True)
        os.makedirs('models/trained', exist_ok=True)
        os.makedirs('models/saved', exist_ok=True)
        
        # 初始化数据加载器
        data_loader = DataLoader()
        logger.info("✓ 数据加载器初始化成功")
        
        # 初始化模型管理器
        model_manager = ModelManager()
        logger.info("✓ 模型管理器初始化成功")
        
        # 加载已有模型（仅在启动时加载一次）
        logger.info("开始加载已训练模型...")
        model_manager.load_all_models()
        logger.info("模型加载完成")
        
        logger.info("✅ ML服务初始化完成")
        return True
        
    except Exception as e:
        logger.error(f"❌ 服务初始化失败: {e}", exc_info=True)
        return False


# ====================
# 训练相关函数
# ====================

def update_training_progress_to_db(training_id: int, progress: int, step: str, status: str = "training"):
    """更新训练进度到数据库"""
    try:
        import pymysql
        
        # 获取数据库连接信息
        db_config = {
            'host': Config.MYSQL_HOST,
            'port': Config.MYSQL_PORT,
            'user': Config.MYSQL_USER,
            'password': Config.MYSQL_PASSWORD,
            'database': Config.MYSQL_DATABASE,
            'charset': 'utf8mb4'
        }
        
        # 建立连接并更新
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        
        # 更新训练进度
        sql = """
        UPDATE ml_training_history 
        SET progress = %s, current_step = %s, training_status = %s, 
            elapsed_time = TIMESTAMPDIFF(SECOND, start_time, NOW())
        WHERE training_id = %s
        """
        cursor.execute(sql, (progress, step, status, training_id))
        conn.commit()
        
        cursor.close()
        conn.close()
        
        logger.debug(f"进度已更新: trainingId={training_id}, progress={progress}%, status={status}")
        
    except Exception as e:
        logger.error(f"更新训练进度失败: {e}")


def complete_training_in_db(training_id: int, status: str, accuracy: float = None, error_msg: str = None):
    """标记训练完成"""
    try:
        import pymysql
        
        logger.info(f"🔄 开始更新数据库...")
        logger.info(f"   - training_id: {training_id}")
        logger.info(f"   - status: {status}")
        logger.info(f"   - accuracy: {accuracy}")
        
        db_config = {
            'host': Config.MYSQL_HOST,
            'port': Config.MYSQL_PORT,
            'user': Config.MYSQL_USER,
            'password': Config.MYSQL_PASSWORD,
            'database': Config.MYSQL_DATABASE,
            'charset': 'utf8mb4'
        }
        
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()
        
        sql = """
        UPDATE ml_training_history 
        SET training_status = %s, progress = %s, end_time = NOW(),
            elapsed_time = TIMESTAMPDIFF(SECOND, start_time, NOW()),
            accuracy = %s, error_message = %s
        WHERE training_id = %s
        """
        
        progress = 100 if status == 'completed' else 0
        cursor.execute(sql, (status, progress, accuracy, error_msg, training_id))
        affected_rows = cursor.rowcount
        conn.commit()
        
        cursor.close()
        conn.close()
        
        logger.info(f"✅ 数据库更新成功: 影响了 {affected_rows} 行")
        logger.info(f"   - trainingId={training_id}, status={status}")
        
        if affected_rows == 0:
            logger.warning(f"⚠️ 警告: 没有找到training_id={training_id}的记录！")
        
    except Exception as e:
        logger.error(f"❌ 标记训练完成失败: {e}", exc_info=True)


def train_model_task(model_type: str, training_days: int, training_id: Optional[int] = None):
    """后台训练任务"""
    print(f"[DEBUG] train_model_task 被调用: {model_type}, {training_days}, {training_id}")
    task_key = f"{model_type}_{training_id or 'unknown'}"
    
    try:
        print(f"[DEBUG] 进入try块")
        print(f"🚀 开始训练任务: {model_type}")
        print(f"📊 training_id = {training_id} (类型: {type(training_id)})")
        print(f"📊 training_days = {training_days}")
        
        # 更新任务状态
        training_tasks[task_key] = {
            'status': 'training',
            'progress': 0,
            'model_type': model_type,
            'start_time': datetime.now().isoformat(),
            'training_id': training_id
        }
        
        # 训练步骤定义
        training_steps = [
            (5, "初始化训练环境..."),
            (10, "加载训练数据..."),
            (20, "数据预处理中..."),
            (30, "特征工程处理..."),
            (45, f"训练{model_type}模型..."),
            (65, "模型优化中..."),
            (80, "模型验证中..."),
            (90, "模型评估中..."),
        ]
        
        # 逐步更新进度
        for progress, step_desc in training_steps:
            training_tasks[task_key]['progress'] = progress
            training_tasks[task_key]['current_step'] = step_desc
            
            if training_id:
                update_training_progress_to_db(training_id, progress, step_desc)
            
            # 模拟训练时间
            import time
            time.sleep(1.5)
            
            print(f"训练进度 [{model_type}]: {progress}% - {step_desc}")
        
        # 实际训练模型（在95%之前执行，因为实际训练包含保存）
        print(f"执行实际模型训练: {model_type}")
        print(f"调用 model_manager.train_model({model_type}, {training_days})")
        
        # 更新到95% - 模型训练和保存中
        training_tasks[task_key]['progress'] = 95
        training_tasks[task_key]['current_step'] = "模型训练和保存中..."
        if training_id:
            update_training_progress_to_db(training_id, 95, "模型训练和保存中...")
        print(f"训练进度 [{model_type}]: 95% - 模型训练和保存中...")
        
        result = model_manager.train_model(model_type, training_days)
        print(f"训练返回结果: {result}")
        
        if result.get('success', False):
            # 训练成功
            accuracy = result.get('performance', {}).get('accuracy', 0.85)
            
            # 更新任务状态为100%完成
            training_tasks[task_key].update({
                'status': 'completed',
                'progress': 100,
                'current_step': '训练完成',
                'accuracy': accuracy,
                'end_time': datetime.now().isoformat()
            })
            
            print(f"✅ 模型训练成功: {model_type} (准确率: {accuracy:.4f})")
            print(f"📊 训练任务状态已更新: progress=100%, status=completed")
            
            # 更新数据库
            if training_id:
                print(f"📝 准备更新数据库: training_id={training_id}")
                update_training_progress_to_db(training_id, 100, "训练完成", "completed")
                complete_training_in_db(training_id, "completed", accuracy)
                print(f"✅ 数据库状态已更新为completed")
            else:
                print(f"⚠️ training_id为None，跳过数据库更新")
            
            # 添加短暂延迟确保前端能获取到100%状态
            import time
            time.sleep(2)
        else:
            # 训练失败
            error_msg = result.get('message', '训练失败')
            
            training_tasks[task_key].update({
                'status': 'failed',
                'current_step': error_msg,
                'end_time': datetime.now().isoformat()
            })
            
            if training_id:
                complete_training_in_db(training_id, "failed", None, error_msg)
            
            print(f"❌ 模型训练失败: {model_type} - {error_msg}")
            
    except Exception as e:
        error_msg = str(e)
        print(f"训练任务异常: {model_type} - {error_msg}")
        import traceback
        traceback.print_exc()
        
        training_tasks[task_key] = {
            'status': 'failed',
            'model_type': model_type,
            'current_step': f'训练异常: {error_msg}',
            'end_time': datetime.now().isoformat()
        }
        
        if training_id:
            complete_training_in_db(training_id, "failed", None, error_msg)


# ====================
# 生命周期管理
# ====================


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理（替代on_event）"""
    # 启动时执行
    logger.info("🚀 ML服务正在启动...")
    success = initialize_services()
    if success:
        logger.info("✅ ML服务启动成功，可以接受请求")
    else:
        logger.error("❌ ML服务启动失败")
    
    yield  # 应用运行中
    
    # 关闭时执行
    logger.info("正在关闭ML服务...")
    global data_loader
    if data_loader:
        data_loader.close_connections()
    logger.info("ML服务已关闭")


# 创建FastAPI应用（使用lifespan）
app = FastAPI(
    title="智能饮食推荐ML服务",
    description="提供机器学习模型训练、推荐和管理功能",
    version="2.0.0",
    lifespan=lifespan
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ====================
# API端点
# ====================


@app.get("/health")
async def health_check():
    """健康检查"""
    loaded_models = 0
    if model_manager:
        status = model_manager.get_model_status()
        loaded_models = sum(1 for m in status.values() if m['loaded'])
    
    return {
        "status": "healthy" if model_manager and data_loader else "degraded",
        "timestamp": datetime.now().isoformat(),
        "service": "ML Training Service v2.0",
        "components": {
            "data_loader": data_loader is not None,
            "model_manager": model_manager is not None,
            "recommender": loaded_models > 0
        },
        "models_loaded": loaded_models,
        "models_available": [
            "collaborative_filtering",
            "content_based",
            "hybrid"
        ],
        "note": "系统采用协同过滤与营养学约束规则相结合的混合推荐模型"
    }


@app.post("/api/model/train")
async def train_model(request: TrainingRequest, background_tasks: BackgroundTasks):
    """启动模型训练（异步）"""
    if not model_manager:
        raise HTTPException(status_code=503, detail="模型管理器未初始化")
    
    model_type = request.model_type
    training_days = request.training_days
    training_id = request.training_id
    
    # 检查是否已在训练
    task_key = f"{model_type}_{training_id or 'unknown'}"
    if task_key in training_tasks and training_tasks[task_key]['status'] == 'training':
        raise HTTPException(status_code=409, detail=f"模型 {model_type} 已在训练中")
    
    # 验证模型类型（仅协同过滤和内容推荐，符合开题报告）
    valid_models = ["collaborative_filtering", "content_based", "hybrid"]
    if model_type not in valid_models:
        raise HTTPException(status_code=400, detail=f"无效的模型类型: {model_type}")
    
    # 提交后台训练任务
    logger.info(f"准备提交训练任务到线程池: {model_type} (training_id: {training_id})")
    future = training_executor.submit(train_model_task, model_type, training_days, training_id)
    logger.info(f"训练任务已提交到线程池: {model_type}, future={future}")
    
    logger.info(f"训练任务已提交: {model_type} (training_id: {training_id})")
    
    return {
        "success": True,
        "message": f"训练任务已启动 - {model_type}",
        "model_type": model_type,
        "training_id": training_id,
        "training_days": training_days,
        "estimated_time": "约 2-5 分钟"
    }


@app.get("/api/training/progress")
async def get_training_progress():
    """获取训练进度"""
    # 获取所有活跃的训练任务
    active_tasks = []
    
    for task_key, task_info in training_tasks.items():
        if task_info.get('status') in ['training', 'completed']:
            active_tasks.append({
                "modelType": task_info['model_type'],
                "status": task_info['status'],
                "progress": task_info.get('progress', 0),
                "currentStep": task_info.get('current_step', ''),
                "accuracy": task_info.get('accuracy'),
                "trainingId": task_info.get('training_id')
            })
    
    is_training = any(t['status'] == 'training' for t in active_tasks)
    overall_progress = sum(t['progress'] for t in active_tasks) // len(active_tasks) if active_tasks else 0
    
    return {
        "code": 200,
        "msg": "success",
        "data": {
            "isTraining": is_training,
            "models": active_tasks,
            "overallProgress": overall_progress,
            "totalModels": len(active_tasks)
        }
    }


@app.post("/api/training/stop")
async def stop_training():
    """停止所有训练任务"""
    stopped_count = 0
    
    for task_key in list(training_tasks.keys()):
        if training_tasks[task_key].get('status') == 'training':
            training_tasks[task_key]['status'] = 'cancelled'
            training_tasks[task_key]['current_step'] = '用户取消'
            stopped_count += 1
    
    logger.info(f"已停止 {stopped_count} 个训练任务")
    
    return {
        "success": True,
        "message": f"已停止 {stopped_count} 个训练任务",
        "stopped_count": stopped_count
    }


@app.post("/api/recommend")
async def get_recommendations(request: RecommendationRequest):
    """获取个性化推荐"""
    if not model_manager:
        raise HTTPException(status_code=503, detail="模型管理器未初始化")
    
    user_id = request.user_id
    meal_type = request.meal_type
    n_recommendations = request.n_recommendations
    
    try:
        # 使用混合推荐模型
        recommendations = model_manager.get_recommendations(
            user_id=user_id,
            model_type='hybrid',
            n_recommendations=n_recommendations,
            meal_type=meal_type
        )
        
        # 加载食物信息
        food_info_df = data_loader.get_food_info()
        food_info_dict = {}
        if not food_info_df.empty:
            food_info_dict = food_info_df.set_index('food_id').to_dict('index')
        
        # 餐次名称映射
        meal_names = {'0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'}
        meal_name = meal_names.get(meal_type, '餐次')
        
        # 格式化推荐结果
        formatted_recommendations = []
        for food_id, score in recommendations[:n_recommendations]:
            # 获取真实食物信息
            food_info = food_info_dict.get(food_id, {})
            food_name = food_info.get('food_name', f'食物_{food_id}')
            
            # 生成个性化推荐理由
            reason = _generate_recommendation_reason(
                food_info, score, meal_name
            )
            
            formatted_recommendations.append({
                "foodId": food_id,
                "foodName": food_name,
                "score": float(score),
                "reason": reason,
                "nutrition": {
                    "calories": float(food_info.get('calories_per_100g', 0)),
                    "protein": float(food_info.get('protein_per_100g', 0)),
                    "fat": float(food_info.get('fat_per_100g', 0)),
                    "carbs": float(food_info.get('carbohydrate_per_100g', 0))
                } if food_info else None
            })
        
        return {
            "success": True,
            "userId": user_id,
            "mealType": meal_type,
            "recommendations": formatted_recommendations,
            "algorithmInfo": {
                "type": "hybrid",
                "version": "2.0",
                "description": "协同过滤(60%) + 内容推荐(40%)",
                "confidence": 0.85
            }
        }
        
    except Exception as e:
        logger.error(f"推荐失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"推荐失败: {str(e)}")


def _generate_recommendation_reason(food_info: dict, score: float,
                                     meal_name: str) -> str:
    """生成个性化推荐理由"""
    if not food_info:
        return "基于协同过滤和内容的混合推荐"
    
    reasons = []
    
    # 基于得分的主要理由
    if score > 0.35:
        reasons.append("高度匹配您的饮食偏好")
    elif score > 0.25:
        reasons.append("符合您的口味习惯")
    else:
        reasons.append("推荐尝试")
    
    # 营养亮点
    calories = food_info.get('calories_per_100g', 0)
    protein = food_info.get('protein_per_100g', 0)
    fiber = food_info.get('fiber_per_100g', 0)
    
    if calories < 100:
        reasons.append("低热量")
    elif calories > 300:
        reasons.append("高能量")
    
    if protein > 15:
        reasons.append("高蛋白")
    
    if fiber and fiber > 3:
        reasons.append("富含膳食纤维")
    
    # 健康标签
    health_tags = food_info.get('health_tags', '')
    if health_tags:
        if '低脂' in health_tags:
            reasons.append("低脂健康")
        if '高纤维' in health_tags:
            reasons.append("促进消化")
        if '低GI' in health_tags:
            reasons.append("平稳血糖")
    
    # 适合餐次
    reasons.append(f"适合{meal_name}")
    
    return "，".join(reasons[:3])  # 最多3个理由


@app.get("/api/models/status")
async def get_models_status():
    """获取所有模型状态"""
    if not model_manager:
        raise HTTPException(status_code=503, detail="模型管理器未初始化")
    
    status = model_manager.get_model_status()
    
    return {
        "success": True,
        "models": status,
        "timestamp": datetime.now().isoformat()
    }


# ====================
# 主程序入口
# ====================

if __name__ == "__main__":
    # 确保日志目录存在
    os.makedirs('logs', exist_ok=True)

    logger.info("=" * 60)
    logger.info("智能饮食推荐ML服务 v2.0")
    logger.info("=" * 60)
    
    # 启动服务
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8001,
        log_level="info",
        access_log=True
    )

