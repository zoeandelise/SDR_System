// 环境配置文件
// 统一管理应用的环境变量和配置

export interface EnvironmentConfig {
  apiBaseURL: string;
  mlApiBaseURL: string;
  environment: 'development' | 'production' | 'test';
  apiTimeout: number;
  enableApiCache: boolean;
  enableOfflineMode: boolean;
  debug: boolean;
}

// 默认配置
const defaultConfig: EnvironmentConfig = {
  apiBaseURL: '', // 在开发环境使用空baseURL，让代理处理
  mlApiBaseURL: 'http://localhost:8001',
  environment: 'development',
  apiTimeout: 15000,
  enableApiCache: true,
  enableOfflineMode: true,
  debug: true
};

// 获取环境配置
export const getEnvironmentConfig = (): EnvironmentConfig => {
  return {
    apiBaseURL: process.env.REACT_APP_API_BASE_URL || defaultConfig.apiBaseURL,
    mlApiBaseURL: process.env.REACT_APP_ML_API_BASE_URL || defaultConfig.mlApiBaseURL,
    environment: (process.env.REACT_APP_ENV as any) || defaultConfig.environment,
    apiTimeout: parseInt(process.env.REACT_APP_API_TIMEOUT || '') || defaultConfig.apiTimeout,
    enableApiCache: process.env.REACT_APP_ENABLE_API_CACHE === 'true' || defaultConfig.enableApiCache,
    enableOfflineMode: process.env.REACT_APP_ENABLE_OFFLINE_MODE === 'true' || defaultConfig.enableOfflineMode,
    debug: process.env.REACT_APP_DEBUG === 'true' || defaultConfig.debug
  };
};

// 导出配置实例
export const env = getEnvironmentConfig();

// API端点映射
export const API_ENDPOINTS = {
  // 认证相关
  auth: {
    login: '/login',
    logout: '/logout',
    register: '/register',
    getUserInfo: '/getInfo',
    captcha: '/captchaImage'
  },

  // 用户饮食相关
  diet: {
    dashboard: '/api/user/diet/dashboard',
    todayNutrition: '/api/user/diet/nutrition/today',
    records: '/api/user/diet/records',
    statistics: '/api/user/diet/statistics',
    trends: '/api/user/diet/trends',
    checkin: '/api/user/diet/checkin',
    checkinStatus: '/api/user/diet/checkin/status',
    checkinRanking: '/api/user/diet/checkin/ranking',
  },

  // 食物数据库
  foods: {
    search: '/api/user/diet/foods/search',
    list: '/api/user/diet/foods',
    detail: '/api/user/diet/foods',
    category: '/api/user/diet/foods/category'
  },

  // AI识别
  ai: {
    recognize: '/api/user/diet/recognize'
  },

  // 通用接口
  common: {
    upload: '/common/upload',
    health: '/actuator/health',
    systemInfo: '/api/system/info'
  }
};

// 构建完整URL
export const buildApiUrl = (endpoint: string, baseUrl?: string): string => {
  const base = baseUrl || env.apiBaseURL;
  return `${base}${endpoint}`;
};

// 打印配置信息（仅在开发环境）
if (env.debug && env.environment === 'development') {
  console.log('🔧 Environment Config:', env);
  console.log('🔌 API Endpoints:', API_ENDPOINTS);
}

export default env;
