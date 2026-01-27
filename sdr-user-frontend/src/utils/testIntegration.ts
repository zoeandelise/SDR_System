// 前后端集成测试工具
// 用于验证API对接是否正常工作

import { authApi, dietRecordApi, foodApi, aiApi, commonApi, monitoringApi } from '../services/api';
import { dataSyncManager, smartApiCaller } from '../services/dataSync';
import { env } from '../config/environment';

interface TestResult {
  name: string;
  status: 'success' | 'error' | 'warning';
  message: string;
  data?: any;
  duration: number;
}

interface TestSuite {
  name: string;
  results: TestResult[];
  totalTests: number;
  passedTests: number;
  failedTests: number;
  warningTests: number;
  totalDuration: number;
}

class IntegrationTester {
  private results: TestResult[] = [];

  // 执行单个测试
  private async runTest(
    name: string, 
    testFn: () => Promise<any>, 
    expectError: boolean = false
  ): Promise<TestResult> {
    const startTime = Date.now();
    
    try {
      const result = await testFn();
      const duration = Date.now() - startTime;
      
      if (expectError) {
        return {
          name,
          status: 'warning',
          message: '期望失败但成功了',
          data: result,
          duration
        };
      }
      
      return {
        name,
        status: 'success',
        message: '测试通过',
        data: result,
        duration
      };
    } catch (error: any) {
      const duration = Date.now() - startTime;
      
      if (expectError) {
        return {
          name,
          status: 'success',
          message: '期望的错误',
          data: error.message,
          duration
        };
      }
      
      return {
        name,
        status: 'error',
        message: error.message || '测试失败',
        data: error,
        duration
      };
    }
  }

  // 环境检查测试
  async testEnvironment(): Promise<TestResult[]> {
    console.log('🔧 开始环境检查测试...');
    
    const tests = [
      await this.runTest('环境配置加载', async () => {
        if (!env.apiBaseURL) throw new Error('API基础URL未配置');
        if (!env.mlApiBaseURL) throw new Error('ML API基础URL未配置');
        return { config: env };
      }),
      
      await this.runTest('本地存储可用性', async () => {
        const testKey = 'integration_test';
        const testValue = 'test_data';
        localStorage.setItem(testKey, testValue);
        const retrieved = localStorage.getItem(testKey);
        localStorage.removeItem(testKey);
        
        if (retrieved !== testValue) {
          throw new Error('本地存储不可用');
        }
        return { localStorage: 'available' };
      }),
      
      await this.runTest('网络连接检查', async () => {
        if (!navigator.onLine) {
          throw new Error('当前处于离线状态');
        }
        return { online: navigator.onLine };
      })
    ];
    
    return tests;
  }

  // 系统监控测试
  async testSystemMonitoring(): Promise<TestResult[]> {
    console.log('🏥 开始系统监控测试...');
    
    const tests = [
      await this.runTest('后端健康检查', async () => {
        const health = await monitoringApi.checkBackendHealth();
        return health;
      }),
      
      await this.runTest('ML服务健康检查', async () => {
        const health = await monitoringApi.checkMLServiceHealth();
        return health;
      }),
      
      await this.runTest('系统状态概览', async () => {
        const status = await monitoringApi.getSystemStatus();
        return status;
      })
    ];
    
    return tests;
  }

  // 用户认证测试
  async testAuthentication(): Promise<TestResult[]> {
    console.log('🔐 开始用户认证测试...');
    
    const tests = [
      await this.runTest('获取验证码', async () => {
        const captcha = await commonApi.getCaptcha();
        if (!captcha || !captcha.data || !captcha.data.uuid) {
          throw new Error('验证码获取失败');
        }
        return captcha;
      }),
      
      // 注意：实际测试中不应使用真实的用户凭据
      await this.runTest('登录测试（期望失败）', async () => {
        try {
          await authApi.login('test_user', 'invalid_password');
          throw new Error('应该登录失败');
        } catch (error: any) {
          if (error.message === '应该登录失败') throw error;
          return { loginFailed: true, reason: error.message };
        }
      }),
      
      await this.runTest('获取用户信息（无Token）', async () => {
        // 临时清除token
        const token = localStorage.getItem('token');
        localStorage.removeItem('token');
        
        try {
          const result = await authApi.getUserInfo();
          return result;
        } catch (error: any) {
          return { noTokenError: true, reason: error.message };
        } finally {
          // 恢复token
          if (token) {
            localStorage.setItem('token', token);
          }
        }
      })
    ];
    
    return tests;
  }

  // 食物数据库测试
  async testFoodDatabase(): Promise<TestResult[]> {
    console.log('🍎 开始食物数据库测试...');
    
    const tests = [
      await this.runTest('获取所有食物', async () => {
        const foods = await foodApi.getAllFoods();
        return {
          totalFoods: foods.data?.length || 0,
          sample: foods.data?.slice(0, 3) || []
        };
      }),
      
      await this.runTest('搜索食物', async () => {
        const foods = await foodApi.searchFoods('苹果');
        return {
          searchResults: foods.data?.length || 0,
          results: foods.data || []
        };
      }),
      
      await this.runTest('获取食物详情', async () => {
        // 先获取食物列表
        const foods = await foodApi.getAllFoods();
        if (!foods.data || foods.data.length === 0) {
          throw new Error('没有可用的食物数据');
        }
        
        const firstFood = foods.data[0];
        const detail = await foodApi.getFoodDetail(firstFood.foodId);
        return detail.data;
      })
    ];
    
    return tests;
  }

  // 饮食记录测试
  async testDietRecords(): Promise<TestResult[]> {
    console.log('📝 开始饮食记录测试...');
    
    const tests = [
      await this.runTest('获取饮食记录', async () => {
        const today = new Date().toISOString().split('T')[0];
        const records = await dietRecordApi.getRecords({ date: today });
        return {
          recordCount: records.data?.length || 0,
          records: records.data || []
        };
      }),
      
      await this.runTest('创建饮食记录', async () => {
        const testRecord = {
          foodName: '测试食物',
          mealType: 'breakfast',
          calories: 100,
          recordTime: new Date().toISOString(),
          notes: '集成测试记录'
        };
        
        const result = await dietRecordApi.addRecord(testRecord);
        return result;
      }),
      
      await this.runTest('获取营养统计', async () => {
        const today = new Date().toISOString().split('T')[0];
        const stats = await dietRecordApi.getStatistics(today, today);
        return stats.data || {};
      })
    ];
    
    return tests;
  }

  // 智能API测试
  async testSmartApi(): Promise<TestResult[]> {
    console.log('🤖 开始智能API测试...');
    
    const tests = [
      await this.runTest('数据同步管理器状态', async () => {
        const status = dataSyncManager.getSyncStatus();
        return status;
      }),
      
      await this.runTest('智能创建记录', async () => {
        const testData = {
          foodName: '智能API测试',
          mealType: 'snack',
          calories: 50,
          recordTime: new Date().toISOString()
        };
        
        const result = await smartApiCaller.smartCreate(
          '/api/user/diet/records',
          testData,
          'test_smart_api'
        );
        
        return result;
      })
    ];
    
    return tests;
  }

  // 数据转换测试
  async testDataTransformation(): Promise<TestResult[]> {
    console.log('🔄 开始数据转换测试...');
    
    const { transformDietRecordForBackend, transformDietRecordFromBackend } = await import('../services/api');
    
    const tests = [
      await this.runTest('前端到后端数据转换', async () => {
        const frontendData = {
          foodName: '测试食物',
          mealType: 'breakfast',
          calories: 200,
          protein: 10,
          fat: 5,
          carbohydrate: 30,
          recordTime: '2025-01-22T08:30:00.000Z'
        };
        
        const backendData = transformDietRecordForBackend(frontendData);
        
        // 验证转换结果
        if (backendData.mealType !== '0') {
          throw new Error(`餐次类型转换错误: ${backendData.mealType}`);
        }
        
        if (backendData.totalCalories !== 200) {
          throw new Error(`卡路里转换错误: ${backendData.totalCalories}`);
        }
        
        return { original: frontendData, transformed: backendData };
      }),
      
      await this.runTest('后端到前端数据转换', async () => {
        const backendData = {
          recordId: 1,
          userId: 1,
          recordDate: '2025-01-22',
          mealType: '1',
          totalCalories: 300,
          totalProtein: 15,
          totalFat: 8,
          totalCarbohydrate: 40,
          notes: '午餐记录'
        };
        
        const frontendData = transformDietRecordFromBackend(backendData);
        
        // 验证转换结果
        if (frontendData.mealType !== 'lunch') {
          throw new Error(`餐次类型转换错误: ${frontendData.mealType}`);
        }
        
        if (frontendData.calories !== 300) {
          throw new Error(`卡路里转换错误: ${frontendData.calories}`);
        }
        
        return { original: backendData, transformed: frontendData };
      })
    ];
    
    return tests;
  }

  // 运行完整测试套件
  async runFullTestSuite(): Promise<TestSuite> {
    console.log('🚀 开始完整集成测试...');
    const startTime = Date.now();
    
    const allResults: TestResult[] = [];
    
    // 依次执行各个测试模块
    const testModules = [
      { name: '环境检查', fn: () => this.testEnvironment() },
      { name: '系统监控', fn: () => this.testSystemMonitoring() },
      { name: '用户认证', fn: () => this.testAuthentication() },
      { name: '食物数据库', fn: () => this.testFoodDatabase() },
      { name: '饮食记录', fn: () => this.testDietRecords() },
      { name: '智能API', fn: () => this.testSmartApi() },
      { name: '数据转换', fn: () => this.testDataTransformation() }
    ];
    
    for (const module of testModules) {
      try {
        console.log(`\n📋 执行 ${module.name} 测试...`);
        const results = await module.fn();
        allResults.push(...results);
      } catch (error: any) {
        console.error(`❌ ${module.name} 测试模块失败:`, error);
        allResults.push({
          name: `${module.name} 模块`,
          status: 'error',
          message: error.message || '模块执行失败',
          duration: 0
        });
      }
    }
    
    const totalDuration = Date.now() - startTime;
    
    // 统计结果
    const passedTests = allResults.filter(r => r.status === 'success').length;
    const failedTests = allResults.filter(r => r.status === 'error').length;
    const warningTests = allResults.filter(r => r.status === 'warning').length;
    
    const testSuite: TestSuite = {
      name: '前后端集成测试',
      results: allResults,
      totalTests: allResults.length,
      passedTests,
      failedTests,
      warningTests,
      totalDuration
    };
    
    // 打印测试报告
    this.printTestReport(testSuite);
    
    return testSuite;
  }

  // 打印测试报告
  private printTestReport(suite: TestSuite) {
    console.log('\n📊 测试报告');
    console.log('═'.repeat(60));
    console.log(`测试套件: ${suite.name}`);
    console.log(`总测试数: ${suite.totalTests}`);
    console.log(`✅ 通过: ${suite.passedTests}`);
    console.log(`❌ 失败: ${suite.failedTests}`);
    console.log(`⚠️ 警告: ${suite.warningTests}`);
    console.log(`⏱️ 总耗时: ${suite.totalDuration}ms`);
    console.log('═'.repeat(60));
    
    // 详细结果
    suite.results.forEach((result, index) => {
      const icon = result.status === 'success' ? '✅' : 
                  result.status === 'error' ? '❌' : '⚠️';
      console.log(`${icon} ${index + 1}. ${result.name} (${result.duration}ms)`);
      
      if (result.status !== 'success') {
        console.log(`   📝 ${result.message}`);
      }
      
      if (env.debug && result.data) {
        console.log(`   📊 数据:`, result.data);
      }
    });
    
    console.log('═'.repeat(60));
    
    const successRate = ((suite.passedTests / suite.totalTests) * 100).toFixed(1);
    console.log(`🎯 成功率: ${successRate}%`);
    
    if (suite.failedTests === 0) {
      console.log('🎉 所有测试通过！前后端对接正常工作。');
    } else {
      console.log('🔧 部分测试失败，请检查后端服务和网络连接。');
    }
  }
}

// 导出测试工具
export const integrationTester = new IntegrationTester();

// 快速测试函数
export const runQuickTest = async (): Promise<boolean> => {
  console.log('⚡ 运行快速集成测试...');
  
  try {
    const tester = new IntegrationTester();
    const envTests = await tester.testEnvironment();
    const monitorTests = await tester.testSystemMonitoring();
    
    const allTests = [...envTests, ...monitorTests];
    const failedTests = allTests.filter(t => t.status === 'error');
    
    if (failedTests.length === 0) {
      console.log('✅ 快速测试通过，系统基本功能正常');
      return true;
    } else {
      console.log(`❌ 快速测试发现 ${failedTests.length} 个问题`);
      failedTests.forEach(test => {
        console.log(`   - ${test.name}: ${test.message}`);
      });
      return false;
    }
  } catch (error: any) {
    console.error('❌ 快速测试失败:', error.message);
    return false;
  }
};

export default integrationTester;
