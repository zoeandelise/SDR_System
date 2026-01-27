#!/usr/bin/env python3
"""
测试所有ML API端点的脚本
"""
import requests
import json
import time

ML_SERVICE_URL = "http://localhost:8002"

def test_api(method, endpoint, data=None):
    """测试单个API端点"""
    url = f"{ML_SERVICE_URL}{endpoint}"
    try:
        if method == "GET":
            response = requests.get(url)
        elif method == "POST":
            headers = {"Content-Type": "application/json"}
            response = requests.post(url, json=data, headers=headers)
        
        print(f"✅ {method} {endpoint}: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            if endpoint == "/health":
                print(f"   服务状态: {result.get('service_status')}")
                print(f"   模型加载: {list(result.get('models_loaded', {}).keys())}")
            elif endpoint == "/api/model/status":
                print(f"   服务状态: {result.get('service_status')}")
                print(f"   训练中: {result.get('is_training')}")
            elif endpoint == "/api/analytics/recommendation-stats":
                print(f"   总推荐数: {result.get('total_recommendations')}")
                print(f"   接受率: {result.get('acceptance_rate')}")
            elif endpoint == "/api/training/progress":
                print(f"   训练中: {result.get('isTraining')}")
                print(f"   总体进度: {result.get('overallProgress')}%")
        
        return response.status_code == 200
    except Exception as e:
        print(f"❌ {method} {endpoint}: {e}")
        return False

def main():
    print("=== ML服务API测试 ===")
    print(f"测试服务: {ML_SERVICE_URL}")
    print()
    
    # 测试所有API端点
    tests = [
        ("GET", "/health"),
        ("GET", "/api/model/status"),
        ("GET", "/api/analytics/recommendation-stats"),
        ("GET", "/api/training/progress"),
        ("POST", "/api/model/train", {"model_types": ["collaborative_filtering", "content_based"]}),
        ("POST", "/api/model/stop_training", {})
    ]
    
    success_count = 0
    for method, endpoint, *data in tests:
        request_data = data[0] if data else None
        success = test_api(method, endpoint, request_data)
        if success:
            success_count += 1
        print()
        time.sleep(0.5)  # 避免请求过快
    
    print(f"=== 测试结果 ===")
    print(f"成功: {success_count}/{len(tests)}")
    print(f"成功率: {success_count/len(tests)*100:.1f}%")
    
    if success_count == len(tests):
        print("🎉 所有API测试通过！ML服务运行正常。")
    else:
        print("⚠️  部分API测试失败，请检查服务状态。")

if __name__ == "__main__":
    main()
