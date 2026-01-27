#!/usr/bin/env python3
"""
智能饮食推荐系统 - 系统集成测试脚本
测试各个服务之间的连通性和API接口
"""

import requests
import json
import time
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Any
import urllib3

# 禁用SSL警告
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class SystemIntegrationTester:
    def __init__(self):
        self.services = {
            'backend': 'http://localhost:8080',
            'ml_service': 'http://localhost:8001',
            'admin_frontend': 'http://localhost:81',
            'user_frontend': 'http://localhost:3000'
        }
        
        self.test_results = {}
        self.session = requests.Session()
        self.session.timeout = 10
        
    def print_header(self, title: str):
        """打印测试标题"""
        print(f"\n{'='*60}")
        print(f"  {title}")
        print(f"{'='*60}")
    
    def print_result(self, test_name: str, success: bool, message: str = ""):
        """打印测试结果"""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}")
        if message:
            print(f"     {message}")
    
    def test_service_health(self, service_name: str, url: str) -> Dict[str, Any]:
        """测试服务健康状态"""
        health_endpoints = {
            'backend': '/actuator/health',
            'ml_service': '/health',
            'admin_frontend': '/',
            'user_frontend': '/'
        }
        
        endpoint = health_endpoints.get(service_name, '/')
        test_url = f"{url}{endpoint}"
        
        try:
            response = self.session.get(test_url, timeout=5)
            
            if service_name in ['admin_frontend', 'user_frontend']:
                # 前端服务检查HTTP状态码
                success = response.status_code == 200
                message = f"HTTP {response.status_code}"
            else:
                # 后端服务检查JSON响应
                success = response.status_code == 200
                if success and response.headers.get('content-type', '').startswith('application/json'):
                    data = response.json()
                    if service_name == 'backend':
                        success = data.get('status') == 'UP'
                    elif service_name == 'ml_service':
                        success = data.get('status') == 'healthy'
                message = f"HTTP {response.status_code} - {response.text[:100]}"
            
            return {
                'success': success,
                'status_code': response.status_code,
                'message': message,
                'response_time': response.elapsed.total_seconds()
            }
            
        except requests.exceptions.Timeout:
            return {
                'success': False,
                'status_code': 0,
                'message': '请求超时',
                'response_time': 0
            }
        except requests.exceptions.ConnectionError:
            return {
                'success': False,
                'status_code': 0,
                'message': '连接失败 - 服务可能未启动',
                'response_time': 0
            }
        except Exception as e:
            return {
                'success': False,
                'status_code': 0,
                'message': f'测试异常: {str(e)}',
                'response_time': 0
            }
    
    def test_api_endpoints(self) -> Dict[str, Any]:
        """测试API接口"""
        backend_url = self.services['backend']
        
        # 测试公开API接口
        test_apis = [
            {
                'name': '获取验证码',
                'url': f'{backend_url}/captchaImage',
                'method': 'GET',
                'expected_status': 200
            },
            {
                'name': '系统信息',
                'url': f'{backend_url}/actuator/info',
                'method': 'GET',
                'expected_status': [200, 404]  # 可能未配置
            }
        ]
        
        results = []
        for api in test_apis:
            try:
                if api['method'] == 'GET':
                    response = self.session.get(api['url'], timeout=5)
                else:
                    response = self.session.post(api['url'], timeout=5)
                
                expected = api['expected_status']
                if isinstance(expected, list):
                    success = response.status_code in expected
                else:
                    success = response.status_code == expected
                
                results.append({
                    'name': api['name'],
                    'success': success,
                    'status_code': response.status_code,
                    'response_time': response.elapsed.total_seconds()
                })
                
            except Exception as e:
                results.append({
                    'name': api['name'],
                    'success': False,
                    'status_code': 0,
                    'error': str(e)
                })
        
        return {'api_tests': results}
    
    def test_ml_service_apis(self) -> Dict[str, Any]:
        """测试ML服务API"""
        ml_url = self.services['ml_service']
        
        test_apis = [
            {
                'name': 'ML服务健康检查',
                'url': f'{ml_url}/health',
                'method': 'GET'
            },
            {
                'name': 'ML服务状态',
                'url': f'{ml_url}/status',
                'method': 'GET'
            },
            {
                'name': 'API文档',
                'url': f'{ml_url}/docs',
                'method': 'GET'
            }
        ]
        
        results = []
        for api in test_apis:
            try:
                response = self.session.get(api['url'], timeout=5)
                success = response.status_code == 200
                
                results.append({
                    'name': api['name'],
                    'success': success,
                    'status_code': response.status_code,
                    'response_time': response.elapsed.total_seconds()
                })
                
            except Exception as e:
                results.append({
                    'name': api['name'],
                    'success': False,
                    'status_code': 0,
                    'error': str(e)
                })
        
        return {'ml_api_tests': results}
    
    def test_cross_origin_requests(self) -> Dict[str, Any]:
        """测试跨域请求"""
        backend_url = self.services['backend']
        
        # 模拟从前端发起的跨域请求
        headers = {
            'Origin': 'http://localhost:3000',
            'Access-Control-Request-Method': 'GET',
            'Access-Control-Request-Headers': 'Content-Type,Authorization'
        }
        
        try:
            # 发送预检请求
            response = self.session.options(f'{backend_url}/captchaImage', headers=headers)
            
            cors_success = (
                'Access-Control-Allow-Origin' in response.headers and
                response.status_code in [200, 204]
            )
            
            return {
                'cors_test': {
                    'success': cors_success,
                    'status_code': response.status_code,
                    'headers': dict(response.headers)
                }
            }
            
        except Exception as e:
            return {
                'cors_test': {
                    'success': False,
                    'error': str(e)
                }
            }
    
    def test_database_connectivity(self) -> Dict[str, Any]:
        """测试数据库连接（通过后端API）"""
        backend_url = self.services['backend']
        
        try:
            # 通过健康检查接口间接测试数据库连接
            response = self.session.get(f'{backend_url}/actuator/health', timeout=5)
            
            if response.status_code == 200:
                health_data = response.json()
                db_status = health_data.get('components', {}).get('db', {}).get('status')
                
                return {
                    'database_test': {
                        'success': db_status == 'UP',
                        'status': db_status,
                        'details': health_data.get('components', {}).get('db', {})
                    }
                }
            else:
                return {
                    'database_test': {
                        'success': False,
                        'error': f'健康检查失败: HTTP {response.status_code}'
                    }
                }
                
        except Exception as e:
            return {
                'database_test': {
                    'success': False,
                    'error': str(e)
                }
            }
    
    def run_all_tests(self):
        """运行所有测试"""
        print("🚀 智能饮食推荐系统 - 系统集成测试")
        print("=" * 60)
        
        # 1. 测试服务健康状态
        self.print_header("服务健康检查")
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            health_futures = {
                executor.submit(self.test_service_health, name, url): name
                for name, url in self.services.items()
            }
            
            for future in as_completed(health_futures):
                service_name = health_futures[future]
                result = future.result()
                
                self.test_results[f'{service_name}_health'] = result
                self.print_result(
                    f"{service_name} 服务",
                    result['success'],
                    f"{result['message']} ({result['response_time']:.2f}s)"
                )
        
        # 2. 测试API接口
        self.print_header("API接口测试")
        
        api_results = self.test_api_endpoints()
        for test in api_results['api_tests']:
            self.print_result(
                test['name'],
                test['success'],
                f"HTTP {test['status_code']} ({test.get('response_time', 0):.2f}s)"
            )
        
        # 3. 测试ML服务API
        self.print_header("ML服务API测试")
        
        ml_results = self.test_ml_service_apis()
        for test in ml_results['ml_api_tests']:
            self.print_result(
                test['name'],
                test['success'],
                f"HTTP {test['status_code']} ({test.get('response_time', 0):.2f}s)"
            )
        
        # 4. 测试跨域请求
        self.print_header("跨域请求测试")
        
        cors_results = self.test_cross_origin_requests()
        cors_test = cors_results['cors_test']
        self.print_result(
            "CORS配置",
            cors_test['success'],
            f"HTTP {cors_test.get('status_code', 0)}"
        )
        
        # 5. 测试数据库连接
        self.print_header("数据库连接测试")
        
        db_results = self.test_database_connectivity()
        db_test = db_results['database_test']
        self.print_result(
            "数据库连接",
            db_test['success'],
            db_test.get('status', db_test.get('error', ''))
        )
        
        # 6. 生成测试报告
        self.generate_report()
    
    def generate_report(self):
        """生成测试报告"""
        self.print_header("测试报告摘要")
        
        total_tests = 0
        passed_tests = 0
        
        # 统计服务健康检查
        for service in self.services:
            total_tests += 1
            if self.test_results.get(f'{service}_health', {}).get('success', False):
                passed_tests += 1
        
        # 计算成功率
        success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        print(f"总测试数: {total_tests}")
        print(f"通过测试: {passed_tests}")
        print(f"失败测试: {total_tests - passed_tests}")
        print(f"成功率: {success_rate:.1f}%")
        
        if success_rate >= 75:
            print("\n🎉 系统集成测试基本通过！")
            if success_rate < 100:
                print("⚠️  部分服务存在问题，请检查日志")
        else:
            print("\n❌ 系统集成测试失败！")
            print("🔧 请检查服务启动状态和配置")
        
        # 生成建议
        self.print_header("改进建议")
        
        suggestions = []
        
        # 检查服务状态
        for service in self.services:
            health_result = self.test_results.get(f'{service}_health', {})
            if not health_result.get('success', False):
                suggestions.append(f"• 检查 {service} 服务是否正常启动")
        
        # 检查响应时间
        slow_services = []
        for service in self.services:
            health_result = self.test_results.get(f'{service}_health', {})
            if health_result.get('response_time', 0) > 2:
                slow_services.append(service)
        
        if slow_services:
            suggestions.append(f"• 优化服务响应时间: {', '.join(slow_services)}")
        
        if not suggestions:
            suggestions.append("• 系统运行良好，无需改进")
        
        for suggestion in suggestions:
            print(suggestion)
        
        print("\n" + "=" * 60)
        print("测试完成！")

def main():
    """主函数"""
    tester = SystemIntegrationTester()
    
    try:
        tester.run_all_tests()
    except KeyboardInterrupt:
        print("\n\n⏹️  测试被用户中断")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ 测试过程中发生错误: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
