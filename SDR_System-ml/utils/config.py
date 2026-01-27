"""
Configuration Module (V2.0 - MySQL Only)
MongoDB and Redis removed
"""

import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuration Class"""
    
    # Application Config
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", "8001"))
    
    # Database Config (MySQL Only)
    MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
    MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
    MYSQL_USER = os.getenv("MYSQL_USER", "root")
    MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "1234")
    MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "smart_diet_dev")
    
    # ML模型配置
    MODEL_PATH = os.getenv("MODEL_PATH", "./models/saved/")
    BATCH_SIZE = int(os.getenv("BATCH_SIZE", "64"))
    LEARNING_RATE = float(os.getenv("LEARNING_RATE", "0.001"))
    N_EPOCHS = int(os.getenv("N_EPOCHS", "100"))
    
    # 推荐算法配置
    CF_N_FACTORS = int(os.getenv("CF_N_FACTORS", "50"))
    CF_N_EPOCHS = int(os.getenv("CF_N_EPOCHS", "20"))
    CF_LR = float(os.getenv("CF_LR", "0.005"))
    CF_REG = float(os.getenv("CF_REG", "0.02"))
    
    # 内容推荐配置
    CONTENT_MIN_SIMILARITY = float(os.getenv("CONTENT_MIN_SIMILARITY", "0.1"))
    CONTENT_MAX_RECOMMENDATIONS = int(os.getenv("CONTENT_MAX_RECOMMENDATIONS", "50"))
    
    # 性能配置
    MAX_WORKERS = int(os.getenv("MAX_WORKERS", "4"))
    REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", "30"))
    
    @staticmethod
    def get_mysql_url():
        """Get MySQL Connection URL"""
        return f"mysql+pymysql://{Config.MYSQL_USER}:{Config.MYSQL_PASSWORD}@{Config.MYSQL_HOST}:{Config.MYSQL_PORT}/{Config.MYSQL_DATABASE}?charset=utf8mb4"
