#!/usr/bin/env python3
"""
机器学习推荐服务启动脚本
"""

import os
import sys
import logging
import uvicorn
from pathlib import Path

# 设置项目根目录
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('logs/ml_service.log', encoding='utf-8')
    ]
)

logger = logging.getLogger(__name__)

def check_dependencies():
    """检查依赖包"""
    required_packages = [
        'fastapi', 'uvicorn', 'pandas', 'numpy', 'scikit-learn',
        'pymongo', 'pymysql', 'redis', 'surprise', 'torch'
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    if missing_packages:
        logger.error(f"缺少以下依赖包: {missing_packages}")
        logger.info("请运行: pip install -r requirements.txt")
        return False
    
    return True

def create_directories():
    """创建必要的目录"""
    directories = [
        'models/saved',
        'models/training_results',
        'logs',
        'data/cache'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        logger.info(f"目录已准备: {directory}")

def check_environment():
    """检查环境配置"""
    # 检查环境变量文件
    env_files = ['.env', 'config.env']
    env_found = any(os.path.exists(f) for f in env_files)
    
    if not env_found:
        logger.warning("未找到环境配置文件")
        logger.info("建议复制 config.env.example 为 config.env 并配置相应参数")
    
    # 检查数据库连接（这里简化，实际应该测试连接）
    logger.info("环境检查完成")

def main():
    """主函数"""
    logger.info("=" * 50)
    logger.info("启动机器学习推荐服务")
    logger.info("=" * 50)
    
    try:
        # 1. 检查依赖
        logger.info("1. 检查依赖包...")
        if not check_dependencies():
            sys.exit(1)
        
        # 2. 创建目录
        logger.info("2. 创建必要目录...")
        create_directories()
        
        # 3. 检查环境
        logger.info("3. 检查环境配置...")
        check_environment()
        
        # 4. 启动服务
        logger.info("4. 启动ML服务...")
        logger.info("服务地址: http://localhost:8001")
        logger.info("API文档: http://localhost:8001/docs")
        logger.info("健康检查: http://localhost:8001/health")
        
        # 启动uvicorn服务
        uvicorn.run(
            "app:app",
            host="0.0.0.0",
            port=8001,
            reload=True,
            log_level="info",
            access_log=True
        )
        
    except KeyboardInterrupt:
        logger.info("服务已停止")
    except Exception as e:
        logger.error(f"启动服务失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
