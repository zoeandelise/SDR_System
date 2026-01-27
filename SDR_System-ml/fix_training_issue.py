#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
一键修复ML训练状态问题
"""

import os
import sys
import json
import logging
import subprocess
import time
from datetime import datetime

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def check_training_status():
    """检查当前训练状态"""
    logger.info("检查训练状态...")
    
    status_file = "./models/training_status.json"
    
    if not os.path.exists(status_file):
        logger.info("没有发现训练状态文件")
        return None
    
    try:
        with open(status_file, 'r', encoding='utf-8') as f:
            status = json.load(f)
        
        logger.info(f"当前训练状态: {status.get('is_training', False)}")
        logger.info(f"完成模型: {status.get('completed_models', 0)}/{status.get('total_models', 0)}")
        logger.info(f"总体进度: {status.get('overall_progress', 0)}%")
        
        return status
        
    except Exception as e:
        logger.error(f"读取训练状态失败: {e}")
        return None

def reset_training_status():
    """重置训练状态"""
    logger.info("重置训练状态...")
    
    # 清理状态文件
    status_file = "./models/training_status.json"
    if os.path.exists(status_file):
        os.remove(status_file)
        logger.info("已删除训练状态文件")
    
    # 创建模型目录
    models_dir = "./models"
    if not os.path.exists(models_dir):
        os.makedirs(models_dir)
        logger.info("已创建模型目录")
    
    # 清理可能的锁文件
    lock_files = ["./training.lock", "./models/training.lock"]
    for lock_file in lock_files:
        if os.path.exists(lock_file):
            os.remove(lock_file)
            logger.info(f"已删除锁文件: {lock_file}")

def kill_training_processes():
    """终止可能的训练进程"""
    logger.info("检查并终止可能的训练进程...")
    
    try:
        # 查找Python训练进程
        result = subprocess.run(
            ['tasklist', '/FI', 'IMAGENAME eq python.exe', '/FO', 'CSV'],
            capture_output=True,
            text=True,
            shell=True
        )
        
        if result.returncode == 0:
            lines = result.stdout.strip().split('\n')
            if len(lines) > 1:  # 有标题行
                logger.info(f"发现 {len(lines) - 1} 个Python进程")
        
    except Exception as e:
        logger.warning(f"无法检查进程: {e}")

def backup_models():
    """备份现有模型"""
    logger.info("备份现有模型...")
    
    models_dir = "./models/saved"
    backup_dir = f"./models/backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    if os.path.exists(models_dir):
        try:
            os.makedirs(backup_dir, exist_ok=True)
            
            for file in os.listdir(models_dir):
                if file.endswith(('.pkl', '.pth', '.json')):
                    src = os.path.join(models_dir, file)
                    dst = os.path.join(backup_dir, file)
                    
                    # 简单的文件复制
                    with open(src, 'rb') as f_src:
                        with open(dst, 'wb') as f_dst:
                            f_dst.write(f_src.read())
            
            logger.info(f"模型已备份到: {backup_dir}")
            
        except Exception as e:
            logger.error(f"备份模型失败: {e}")
    else:
        logger.info("没有发现现有模型文件")

def restart_ml_service():
    """重启ML服务"""
    logger.info("准备重启ML服务...")
    
    # 检查服务是否运行
    try:
        import requests
        response = requests.get("http://localhost:8001/health", timeout=5)
        if response.status_code == 200:
            logger.info("ML服务正在运行")
            
            # 尝试停止训练
            try:
                stop_response = requests.post("http://localhost:8001/api/model/stop_training", timeout=10)
                if stop_response.status_code == 200:
                    logger.info("已通过API停止训练")
                else:
                    logger.warning(f"停止训练API返回: {stop_response.status_code}")
            except Exception as e:
                logger.warning(f"无法通过API停止训练: {e}")
        else:
            logger.info("ML服务可能未运行")
            
    except Exception as e:
        logger.info(f"无法连接到ML服务: {e}")

def test_training_fix():
    """测试训练修复"""
    logger.info("测试训练功能...")
    
    try:
        # 导入修复的训练管理器
        from fix_training_status import TrainingStatusManager
        
        # 创建状态管理器
        status_manager = TrainingStatusManager()
        
        # 获取状态
        status = status_manager.get_status()
        logger.info(f"训练状态管理器状态: {status['is_training']}")
        
        if status['is_training']:
            logger.info("强制停止训练...")
            status_manager.stop_training()
            time.sleep(2)
        
        # 测试启动训练
        logger.info("测试启动训练...")
        test_models = ['collaborative_filtering']
        
        if status_manager.start_training(test_models):
            logger.info("训练启动成功，等待3秒后停止...")
            time.sleep(3)
            
            # 检查进度
            current_status = status_manager.get_status()
            logger.info(f"测试训练进度: {current_status['overall_progress']}%")
            
            # 停止测试训练
            status_manager.stop_training()
            logger.info("测试训练已停止")
            
            return True
        else:
            logger.error("训练启动失败")
            return False
            
    except Exception as e:
        logger.error(f"测试训练修复失败: {e}")
        return False

def main():
    """主修复流程"""
    logger.info("=" * 50)
    logger.info("开始修复ML训练状态问题...")
    logger.info("=" * 50)
    
    try:
        # 1. 检查当前状态
        current_status = check_training_status()
        
        # 2. 备份现有模型
        backup_models()
        
        # 3. 终止可能的训练进程
        kill_training_processes()
        
        # 4. 重置训练状态
        reset_training_status()
        
        # 5. 重启ML服务
        restart_ml_service()
        
        # 6. 测试修复效果
        logger.info("等待5秒后测试修复效果...")
        time.sleep(5)
        
        if test_training_fix():
            logger.info("✅ 训练状态问题修复成功！")
            logger.info("现在可以正常进行模型训练了")
        else:
            logger.error("❌ 修复测试失败，可能需要手动检查")
        
        logger.info("=" * 50)
        logger.info("修复完成！建议重启整个ML服务以确保完全生效")
        logger.info("=" * 50)
        
        # 7. 提供使用建议
        print("\n📋 使用建议:")
        print("1. 重启ML服务: python app.py")
        print("2. 或者使用测试服务: python test_server.py") 
        print("3. 通过前端界面重新开始训练")
        print("4. 监控训练进度，确保能正常完成")
        
    except KeyboardInterrupt:
        logger.info("用户中断修复过程")
    except Exception as e:
        logger.error(f"修复过程出错: {e}")
        logger.error("请检查错误日志并手动修复")

if __name__ == "__main__":
    main()
