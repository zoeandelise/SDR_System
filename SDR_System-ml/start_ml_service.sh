#!/bin/bash
# =========================================
# 智能饮食推荐ML服务启动脚本 (Linux/Mac)
# V2.0 - 统一服务版本
# =========================================

echo ""
echo "========================================"
echo "  智能饮食推荐ML服务 v2.0"
echo "  启动中..."
echo "========================================"
echo ""

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未检测到Python环境！"
    echo "请先安装Python 3.8或更高版本"
    exit 1
fi

echo "[1/4] 检查Python环境... OK"

# 检查依赖
echo "[2/4] 检查依赖包..."
python3 -c "import fastapi" &> /dev/null
if [ $? -ne 0 ]; then
    echo "[警告] FastAPI未安装，正在安装依赖..."
    pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
    if [ $? -ne 0 ]; then
        echo "[错误] 依赖安装失败！"
        exit 1
    fi
fi
echo "[2/4] 依赖检查... OK"

# 检查配置文件
echo "[3/4] 检查配置文件..."
if [ ! -f "config.env" ]; then
    echo "[警告] 配置文件不存在，复制示例配置..."
    cp config.env.example config.env
fi
echo "[3/4] 配置检查... OK"

# 创建必要的目录
echo "[4/4] 初始化目录..."
mkdir -p logs
mkdir -p models/saved
mkdir -p models/trained
mkdir -p models/training_results
echo "[4/4] 目录初始化... OK"

echo ""
echo "========================================"
echo "  启动ML服务..."
echo "  服务地址: http://localhost:8001"
echo "  API文档: http://localhost:8001/docs"
echo "========================================"
echo ""

# 启动服务
python3 main_service.py

