"""
ML训练模块重构后集成测试脚本
测试核心功能：协同过滤 + 内容推荐 + 混合推荐
"""

import requests
import time
import json
from colorama import init, Fore, Style

# 初始化colorama（彩色输出）
init(autoreset=True)

# 测试配置
ML_SERVICE_URL = "http://localhost:8001"
BACKEND_URL = "http://localhost:8080"

class MLSystemTester:
    """ML系统测试器"""
    
    def __init__(self):
        self.test_results = []
        self.passed_tests = 0
        self.failed_tests = 0
    
    def print_header(self, title):
        """打印测试标题"""
        print("\n" + "=" * 60)
        print(f"{Fore.CYAN}{title}")
        print("=" * 60)
    
    def print_success(self, message):
        """打印成功信息"""
        print(f"{Fore.GREEN}✓ {message}")
        self.passed_tests += 1
    
    def print_error(self, message):
        """打印错误信息"""
        print(f"{Fore.RED}✗ {message}")
        self.failed_tests += 1
    
    def print_info(self, message):
        """打印信息"""
        print(f"{Fore.YELLOW}ℹ {message}")
    
    def test_ml_service_health(self):
        """测试1: ML服务健康检查"""
        self.print_header("测试1: ML服务健康检查")
        
        try:
            response = requests.get(f"{ML_SERVICE_URL}/health", timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                self.print_success(f"ML服务运行正常: {data['service']}")
                
                # 检查组件
                components = data.get('components', {})
                if components.get('data_loader'):
                    self.print_success("数据加载器已就绪")
                if components.get('model_manager'):
                    self.print_success("模型管理器已就绪")
                
                # 检查可用模型
                models_available = data.get('models_available', [])
                self.print_info(f"可用模型: {', '.join(models_available)}")
                
                # 验证：不应该包含deep_learning
                if 'deep_learning' in models_available:
                    self.print_error("❌ 发现deep_learning模型（应该已被移除）")
                else:
                    self.print_success("✓ 已正确移除deep_learning模型")
                
                # 验证创新点说明
                if '营养学约束' in data.get('note', ''):
                    self.print_success("✓ 正确体现创新点：协同过滤与营养学约束结合")
                
                return True
            else:
                self.print_error(f"ML服务返回错误状态: {response.status_code}")
                return False
                
        except requests.exceptions.ConnectionError:
            self.print_error("无法连接到ML服务，请确保服务已启动")
            return False
        except Exception as e:
            self.print_error(f"健康检查失败: {e}")
            return False
    
    def test_backend_ml_status(self):
        """测试2: 后端ML状态接口"""
        self.print_header("测试2: 后端ML状态接口")
        
        try:
            response = requests.get(f"{BACKEND_URL}/diet/ml/status", timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('code') == 200:
                    self.print_success("后端ML状态接口正常")
                    
                    status_data = data.get('data', {})
                    service_status = status_data.get('serviceStatus', 'unknown')
                    self.print_info(f"服务状态: {service_status}")
                    
                    # 检查模型加载状态
                    models_loaded = status_data.get('modelsLoaded', {})
                    loaded_count = sum(1 for v in models_loaded.values() if v)
                    self.print_info(f"已加载模型: {loaded_count}/2")
                    
                    return True
                else:
                    self.print_error(f"接口返回错误: {data.get('msg')}")
                    return False
            else:
                self.print_error(f"后端返回错误状态: {response.status_code}")
                return False
                
        except requests.exceptions.ConnectionError:
            self.print_error("无法连接到后端服务，请确保服务已启动")
            return False
        except Exception as e:
            self.print_error(f"后端状态检查失败: {e}")
            return False
    
    def test_training_workflow(self):
        """测试3: 训练工作流程"""
        self.print_header("测试3: 训练工作流程（仅协同过滤）")
        
        try:
            # 启动训练
            self.print_info("启动协同过滤模型训练...")
            
            train_data = {
                "modelTypes": ["collaborative_filtering"],
                "trainingDays": 180
            }
            
            response = requests.post(
                f"{BACKEND_URL}/diet/ml/model/train",
                json=train_data,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('code') == 200:
                    self.print_success("训练任务已启动")
                    
                    # 轮询训练进度
                    self.print_info("开始监控训练进度...")
                    
                    max_wait = 120  # 最多等待120秒
                    elapsed = 0
                    
                    while elapsed < max_wait:
                        time.sleep(2)
                        elapsed += 2
                        
                        # 查询进度
                        progress_response = requests.get(
                            f"{BACKEND_URL}/diet/ml/training/progress",
                            timeout=5
                        )
                        
                        if progress_response.status_code == 200:
                            progress_data = progress_response.json()
                            
                            if progress_data.get('code') == 200:
                                data = progress_data.get('data', {})
                                models = data.get('models', [])
                                
                                if models:
                                    model = models[0]
                                    progress = model.get('progress', 0)
                                    status = model.get('status', '')
                                    step = model.get('currentStep', '')
                                    
                                    print(f"  进度: {progress}% - {step}")
                                    
                                    # 检查是否完成
                                    if status == 'completed' or progress >= 100:
                                        self.print_success(f"训练完成! 准确率: {model.get('accuracy', 'N/A')}")
                                        return True
                                    
                                    # 检查是否失败
                                    if status == 'failed':
                                        self.print_error(f"训练失败: {step}")
                                        return False
                    
                    self.print_error("训练超时（超过120秒）")
                    return False
                else:
                    self.print_error(f"启动训练失败: {result.get('msg')}")
                    return False
            else:
                self.print_error(f"训练请求失败: {response.status_code}")
                return False
                
        except Exception as e:
            self.print_error(f"训练流程测试失败: {e}")
            return False
    
    def test_model_count(self):
        """测试4: 验证模型数量（应该是2个，不是3个）"""
        self.print_header("测试4: 验证模型数量")
        
        try:
            response = requests.get(f"{ML_SERVICE_URL}/api/models/status", timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                models = data.get('models', {})
                
                model_count = len(models)
                self.print_info(f"检测到 {model_count} 个模型")
                
                # 验证模型列表
                expected_models = ['collaborative_filtering', 'content_based', 'hybrid']
                actual_models = list(models.keys())
                
                # 不应该包含deep_learning
                if 'deep_learning' in actual_models:
                    self.print_error("❌ 发现deep_learning模型（应该已被移除）")
                    return False
                else:
                    self.print_success("✓ 已正确移除deep_learning模型")
                
                # 应该包含expected_models
                for model_type in expected_models:
                    if model_type in actual_models:
                        self.print_success(f"✓ 包含模型: {model_type}")
                    else:
                        self.print_error(f"✗ 缺少模型: {model_type}")
                
                return 'deep_learning' not in actual_models
            else:
                self.print_error(f"模型状态查询失败: {response.status_code}")
                return False
                
        except Exception as e:
            self.print_error(f"模型数量验证失败: {e}")
            return False
    
    def test_no_simulate_mode(self):
        """测试5: 验证已移除模拟训练"""
        self.print_header("测试5: 验证已移除模拟训练")
        
        # 检查后端配置（尝试访问已删除的配置接口）
        try:
            response = requests.get(f"{BACKEND_URL}/diet/ml/training/config", timeout=5)
            
            if response.status_code == 404:
                self.print_success("✓ 训练配置接口已删除（正确）")
                return True
            else:
                self.print_error("❌ 训练配置接口仍然存在（应该已删除）")
                return False
                
        except requests.exceptions.ConnectionError:
            self.print_error("无法连接到后端服务")
            return False
        except Exception as e:
            # 404错误也算成功
            if "404" in str(e):
                self.print_success("✓ 训练配置接口已删除（正确）")
                return True
            self.print_error(f"验证失败: {e}")
            return False
    
    def run_all_tests(self):
        """运行所有测试"""
        print("\n")
        print(f"{Fore.MAGENTA}{'=' * 60}")
        print(f"{Fore.MAGENTA}ML训练模块重构集成测试")
        print(f"{Fore.MAGENTA}{'=' * 60}")
        print()
        
        # 运行测试
        tests = [
            ("ML服务健康检查", self.test_ml_service_health),
            ("后端ML状态接口", self.test_backend_ml_status),
            ("模型数量验证", self.test_model_count),
            ("验证已移除模拟训练", self.test_no_simulate_mode),
            # 训练流程测试可选（因为会花费较长时间）
            # ("训练工作流程", self.test_training_workflow),
        ]
        
        for test_name, test_func in tests:
            try:
                result = test_func()
                self.test_results.append({
                    'test': test_name,
                    'passed': result
                })
            except Exception as e:
                print(f"{Fore.RED}测试异常: {test_name} - {e}")
                self.test_results.append({
                    'test': test_name,
                    'passed': False
                })
        
        # 打印总结
        self.print_summary()
    
    def print_summary(self):
        """打印测试总结"""
        print("\n")
        print(f"{Fore.MAGENTA}{'=' * 60}")
        print(f"{Fore.MAGENTA}测试总结")
        print(f"{Fore.MAGENTA}{'=' * 60}")
        
        total_tests = len(self.test_results)
        passed = sum(1 for r in self.test_results if r['passed'])
        failed = total_tests - passed
        
        print(f"\n总测试数: {total_tests}")
        print(f"{Fore.GREEN}通过: {passed}")
        print(f"{Fore.RED}失败: {failed}")
        print(f"通过率: {(passed/total_tests*100):.1f}%\n")
        
        # 详细结果
        for result in self.test_results:
            status = f"{Fore.GREEN}✓ PASS" if result['passed'] else f"{Fore.RED}✗ FAIL"
            print(f"{status} - {result['test']}")
        
        print("\n" + "=" * 60)
        
        if failed == 0:
            print(f"{Fore.GREEN}🎉 所有测试通过！重构成功！")
        else:
            print(f"{Fore.YELLOW}⚠️ 有 {failed} 个测试失败，请检查")
        
        print("=" * 60 + "\n")


def main():
    """主测试函数"""
    print(f"{Fore.CYAN}")
    print("""
╔═══════════════════════════════════════════════════════════╗
║   ML训练模块重构后集成测试                                  ║
║   测试核心功能：协同过滤 + 内容推荐 + 混合推荐              ║
╚═══════════════════════════════════════════════════════════╝
    """)
    
    print(f"{Style.RESET_ALL}")
    print("开始测试前请确保：")
    print("  1. ML服务已启动 (端口8001)")
    print("  2. 后端服务已启动 (端口8080)")
    print()
    
    input("按回车键开始测试...")
    
    # 运行测试
    tester = MLSystemTester()
    tester.run_all_tests()
    
    # 可选：询问是否运行完整训练测试
    print("\n")
    print(f"{Fore.YELLOW}注意: 完整训练测试需要约2-3分钟")
    run_training = input("是否运行完整训练流程测试？(y/n): ")
    
    if run_training.lower() == 'y':
        tester.print_header("额外测试: 完整训练流程")
        result = tester.test_training_workflow()
        tester.test_results.append({
            'test': '完整训练流程',
            'passed': result
        })
        tester.print_summary()


if __name__ == "__main__":
    # 尝试导入colorama，如果没有则使用普通输出
    try:
        from colorama import init, Fore, Style
        init(autoreset=True)
    except ImportError:
        print("提示: 安装colorama可获得彩色输出")
        print("  pip install colorama")
        print()
        
        # 定义空的Fore和Style用于兼容
        class Fore:
            GREEN = RED = YELLOW = CYAN = MAGENTA = ""
        
        class Style:
            RESET_ALL = ""
    
    main()

