#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
修复ML训练状态管理问题
"""

import os
import json
import logging
import time
import threading
from datetime import datetime
from typing import Dict, List

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class TrainingStatusManager:
    """训练状态管理器"""
    
    def __init__(self):
        self.status_file = "./models/training_status.json"
        self.training_state = {
            'is_training': False,
            'models': [],
            'overall_progress': 0,
            'completed_models': 0,
            'total_models': 0,
            'start_time': None,
            'end_time': None,
            'training_thread': None
        }
        self.load_status()
    
    def load_status(self):
        """加载训练状态"""
        try:
            if os.path.exists(self.status_file):
                with open(self.status_file, 'r', encoding='utf-8') as f:
                    saved_state = json.load(f)
                    # 只加载持久化的状态，不包括线程对象
                    for key, value in saved_state.items():
                        if key != 'training_thread':
                            self.training_state[key] = value
                logger.info("训练状态已加载")
        except Exception as e:
            logger.error(f"加载训练状态失败: {e}")
    
    def save_status(self):
        """保存训练状态"""
        try:
            # 创建可序列化的状态副本
            serializable_state = {k: v for k, v in self.training_state.items() 
                                if k != 'training_thread'}
            
            os.makedirs(os.path.dirname(self.status_file), exist_ok=True)
            with open(self.status_file, 'w', encoding='utf-8') as f:
                json.dump(serializable_state, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"保存训练状态失败: {e}")
    
    def start_training(self, model_types: List[str]):
        """开始训练"""
        if self.training_state['is_training']:
            logger.warning("训练已在进行中")
            return False
        
        logger.info(f"开始训练模型: {model_types}")
        
        # 重置状态
        self.training_state.update({
            'is_training': True,
            'models': [],
            'overall_progress': 0,
            'completed_models': 0,
            'total_models': len(model_types),
            'start_time': datetime.now().isoformat(),
            'end_time': None
        })
        
        # 初始化模型状态
        for model_type in model_types:
            self.training_state['models'].append({
                'name': model_type,
                'progress': 0,
                'status': 'pending',
                'current_step': '准备开始...',
                'elapsed_time': 0,
                'start_time': None,
                'end_time': None,
                'error': None
            })
        
        # 保存初始状态
        self.save_status()
        
        # 启动训练线程
        training_thread = threading.Thread(
            target=self._simulate_training,
            args=(model_types,),
            daemon=True
        )
        training_thread.start()
        self.training_state['training_thread'] = training_thread
        
        return True
    
    def stop_training(self):
        """停止训练"""
        logger.info("停止训练")
        self.training_state['is_training'] = False
        self.training_state['end_time'] = datetime.now().isoformat()
        self.save_status()
    
    def get_status(self) -> Dict:
        """获取训练状态"""
        return {
            'is_training': self.training_state['is_training'],
            'overall_progress': self.training_state['overall_progress'],
            'completed_models': self.training_state['completed_models'],
            'total_models': self.training_state['total_models'],
            'models': self.training_state['models'].copy(),
            'start_time': self.training_state['start_time'],
            'end_time': self.training_state['end_time'],
            'total_elapsed_time': self._calculate_total_elapsed_time()
        }
    
    def _calculate_total_elapsed_time(self) -> int:
        """计算总耗时（秒）"""
        if not self.training_state['start_time']:
            return 0
        
        start_time = datetime.fromisoformat(self.training_state['start_time'])
        
        if self.training_state['end_time']:
            end_time = datetime.fromisoformat(self.training_state['end_time'])
            return int((end_time - start_time).total_seconds())
        else:
            return int((datetime.now() - start_time).total_seconds())
    
    def _simulate_training(self, model_types: List[str]):
        """模拟训练过程"""
        try:
            for i, model_type in enumerate(model_types):
                if not self.training_state['is_training']:
                    break
                
                model_state = self.training_state['models'][i]
                logger.info(f"开始训练模型: {model_type}")
                
                # 更新模型状态
                model_state.update({
                    'status': 'training',
                    'start_time': datetime.now().isoformat(),
                    'current_step': '数据加载中...'
                })
                self.save_status()
                
                # 模拟训练过程
                training_steps = [
                    ('数据预处理...', 20),
                    ('特征工程...', 40),
                    ('模型训练...', 80),
                    ('模型验证...', 95),
                    ('保存模型...', 100)
                ]
                
                for step_name, target_progress in training_steps:
                    if not self.training_state['is_training']:
                        break
                    
                    # 更新进度
                    model_state['current_step'] = step_name
                    
                    # 逐步增加进度
                    while model_state['progress'] < target_progress and self.training_state['is_training']:
                        model_state['progress'] = min(model_state['progress'] + 5, target_progress)
                        model_state['elapsed_time'] = self._calculate_model_elapsed_time(model_state)
                        
                        # 更新总体进度
                        self._update_overall_progress()
                        self.save_status()
                        
                        time.sleep(1)  # 每秒更新一次
                
                # 模型训练完成
                if self.training_state['is_training']:
                    model_state.update({
                        'status': 'completed',
                        'progress': 100,
                        'current_step': '训练完成',
                        'end_time': datetime.now().isoformat()
                    })
                    
                    self.training_state['completed_models'] += 1
                    self._update_overall_progress()
                    self.save_status()
                    
                    logger.info(f"模型训练完成: {model_type}")
            
            # 检查是否所有模型都完成
            if (self.training_state['completed_models'] >= self.training_state['total_models'] 
                and self.training_state['is_training']):
                
                logger.info("所有模型训练完成，正在停止训练...")
                self.stop_training()
                
        except Exception as e:
            logger.error(f"训练过程出错: {e}")
            
            # 标记错误状态
            for model in self.training_state['models']:
                if model['status'] == 'training':
                    model.update({
                        'status': 'error',
                        'error': str(e),
                        'end_time': datetime.now().isoformat()
                    })
            
            self.stop_training()
    
    def _calculate_model_elapsed_time(self, model_state: Dict) -> int:
        """计算模型训练耗时"""
        if not model_state.get('start_time'):
            return 0
        
        start_time = datetime.fromisoformat(model_state['start_time'])
        return int((datetime.now() - start_time).total_seconds())
    
    def _update_overall_progress(self):
        """更新总体进度"""
        if self.training_state['total_models'] == 0:
            self.training_state['overall_progress'] = 0
            return
        
        total_progress = sum(model['progress'] for model in self.training_state['models'])
        self.training_state['overall_progress'] = int(total_progress / self.training_state['total_models'])


def fix_training_status():
    """修复训练状态"""
    logger.info("开始修复训练状态...")
    
    # 创建状态管理器
    status_manager = TrainingStatusManager()
    
    # 检查当前状态
    current_status = status_manager.get_status()
    
    if current_status['is_training']:
        logger.info("检测到训练状态为进行中，正在重置...")
        
        # 强制停止训练
        status_manager.stop_training()
        
        # 清理状态
        status_manager.training_state.update({
            'is_training': False,
            'models': [],
            'overall_progress': 0,
            'completed_models': 0,
            'total_models': 0,
            'start_time': None,
            'end_time': None
        })
        
        status_manager.save_status()
        logger.info("训练状态已重置")
    else:
        logger.info("训练状态正常")
    
    return status_manager


if __name__ == "__main__":
    try:
        # 修复训练状态
        status_manager = fix_training_status()
        
        # 测试训练流程
        logger.info("测试训练流程...")
        test_models = ['collaborative_filtering', 'content_based', 'deep_learning']
        
        if status_manager.start_training(test_models):
            logger.info("测试训练已启动")
            
            # 监控训练进度
            while True:
                status = status_manager.get_status()
                logger.info(f"训练进度: {status['overall_progress']}%, "
                          f"完成模型: {status['completed_models']}/{status['total_models']}")
                
                if not status['is_training']:
                    logger.info("训练已完成")
                    break
                
                time.sleep(2)
        else:
            logger.error("启动训练失败")
            
    except KeyboardInterrupt:
        logger.info("用户中断，停止训练...")
        if 'status_manager' in locals():
            status_manager.stop_training()
    except Exception as e:
        logger.error(f"修复过程出错: {e}")
