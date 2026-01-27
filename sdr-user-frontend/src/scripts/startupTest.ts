// 系统启动测试脚本
// 在应用启动时执行基础检查，确保系统正常运行

import { runQuickTest } from '../utils/testIntegration';
import { env } from '../config/environment';

// 启动时执行的检查
export const performStartupChecks = async (): Promise<boolean> => {
  console.log('🚀 正在启动智能饮食助手...');
  
  // 如果不在调试模式，跳过测试
  if (!env.debug) {
    console.log('📱 生产模式启动');
    return true;
  }
  
  console.log('🔧 开发模式启动，执行系统检查...');
  
  try {
    // 执行快速测试
    const success = await runQuickTest();
    
    if (success) {
      console.log('✅ 系统检查完成，所有服务正常');
      return true;
    } else {
      console.log('⚠️ 部分服务异常，但系统仍可使用离线模式');
      return true; // 即使有问题也允许启动
    }
  } catch (error: any) {
    console.error('❌ 启动检查失败:', error.message);
    console.log('🔄 系统将以离线模式启动');
    return true; // 启动检查失败也允许启动
  }
};

// 在开发环境自动执行
if (env.debug && env.environment === 'development') {
  // 延迟执行，确保其他模块已加载
  setTimeout(() => {
    performStartupChecks().then(() => {
      console.log('🎯 系统启动检查完成');
    });
  }, 2000);
}

export default performStartupChecks;
