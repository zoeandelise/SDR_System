#!/usr/bin/env python3
"""
启动简化版ML推荐服务
"""

import os
import sys
import subprocess
import logging

def main():
    print("=" * 50)
    print("启动机器学习推荐服务")
    print("=" * 50)
    
    # 配置日志
    logging.basicConfig(level=logging.INFO)
    
    # 首先检查基础依赖
    print("1. 检查Python依赖...")
    required_packages = ['flask', 'pandas', 'numpy', 'scikit-learn', 'joblib']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"   ✓ {package}")
        except ImportError:
            print(f"   ✗ {package} (缺失)")
            missing_packages.append(package)
    
    # 如果有缺失的包，尝试安装
    if missing_packages:
        print(f"\n2. 安装缺失的依赖: {', '.join(missing_packages)}")
        try:
            cmd = [sys.executable, '-m', 'pip', 'install'] + missing_packages
            subprocess.run(cmd, check=True)
            print("   ✓ 依赖安装完成")
        except Exception as e:
            print(f"   ✗ 自动安装失败: {e}")
            print(f"   请手动执行: pip install {' '.join(missing_packages)}")
            return
    else:
        print("   ✓ 所有依赖已满足")
    
    # 启动服务
    print("\n3. 启动ML推荐服务...")
    print("   服务地址: http://localhost:8001")
    print("   健康检查: http://localhost:8001/health")
    print("   按 Ctrl+C 停止服务")
    print("-" * 50)
    
    try:
        # 切换到脚本目录
        script_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(script_dir)
        
        # 启动简化版应用
        subprocess.run([sys.executable, 'simple_app.py'], check=True)
    except KeyboardInterrupt:
        print("\n   服务已停止")
    except FileNotFoundError:
        print("   ✗ 找不到 simple_app.py 文件")
    except Exception as e:
        print(f"   ✗ 服务启动失败: {e}")
        print("\n4. 尝试最小化服务...")
        start_minimal_service()

def start_minimal_service():
    """启动最小化服务"""
    try:
        from flask import Flask, jsonify
        
        app = Flask(__name__)
        
        @app.route('/health')
        def health():
            return jsonify({
                'status': 'minimal',
                'service': 'ML Recommendation System',
                'message': '最小化服务模式'
            })
        
        @app.route('/status')
        def status():
            return jsonify({
                'service_status': {
                    'service_status': 'minimal',
                    'models_loaded': 0,
                    'total_models': 4
                }
            })
        
        print("   ✓ 最小化服务启动成功")
        app.run(host='0.0.0.0', port=8001, debug=False)
        
    except Exception as e:
        print(f"   ✗ 最小化服务也失败了: {e}")

if __name__ == '__main__':
    main()
