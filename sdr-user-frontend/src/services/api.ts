// API服务配置
import axios, { AxiosResponse } from 'axios';
import { env, API_ENDPOINTS, buildApiUrl } from '../config/environment';
import type { 
  RuoYiResponse, 
  AuthResponse, 
  SystemStatusResponse,
  HealthStatus,
  DashboardData,
  DietRecord,
  FoodInfo,
  RecognitionResult,
  CaptchaResponse,
  UploadResponse
} from '../types/api';

// 系统配置
const API_CONFIG = {
  baseURL: env.apiBaseURL,
  timeout: env.apiTimeout,
  retryAttempts: 3, // 重试次数
  retryDelay: 1000, // 重试延迟
  enableCache: env.enableApiCache,
  debug: env.debug
};

// 创建axios实例
const api = axios.create({
  baseURL: API_CONFIG.baseURL,
  timeout: API_CONFIG.timeout,
  withCredentials: true, // 支持跨域cookie
  headers: {
    'Content-Type': 'application/json',
  }
});

// 请求重试配置
let retryCount = 0;

// 请求拦截器
api.interceptors.request.use(
  (config: any) => {
    // 添加认证token（从Cookies读取，与authService保持一致）
    const token = document.cookie.split('; ').find(row => row.startsWith('Admin-Token='))?.split('=')[1];
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // 添加请求ID用于追踪
    config.headers['X-Request-ID'] = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // 添加时间戳防止缓存
    if (config.method === 'get') {
      config.params = {
        ...config.params,
        _t: Date.now()
      };
    }
    
    console.log('🚀 API Request:', {
      method: config.method?.toUpperCase(),
      url: config.url,
      headers: config.headers,
      data: config.data
    });
    
    return config;
  },
  (error: any) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
api.interceptors.response.use(
  (response: AxiosResponse) => {
    const requestId = response.config.headers?.['X-Request-ID'];
    console.log('✅ API Response:', {
      requestId,
      url: response.config.url,
      status: response.status,
      data: response.data
    });
    
    // 重置重试计数
    retryCount = 0;
    
    // 若依框架的响应格式处理
    if (response.data && typeof response.data === 'object') {
      // 成功响应
      if (response.data.code === 200 || response.data.code === undefined) {
        return response.data;
      }
      // 业务错误
      else {
        const error = new Error(response.data.msg || '请求失败') as any;
        error.code = response.data.code;
        error.requestId = requestId;
        throw error;
      }
    }
    
    return response.data;
  },
  async (error: any) => {
    const requestId = error.config?.headers?.['X-Request-ID'];
    console.error('❌ Response Error:', {
      requestId,
      url: error.config?.url,
      status: error.response?.status,
      message: error.message
    });
    
    // 网络错误重试逻辑
    if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
      if (retryCount < API_CONFIG.retryAttempts) {
        retryCount++;
        console.log(`🔄 重试请求 ${retryCount}/${API_CONFIG.retryAttempts}:`, error.config?.url);
        
        // 延迟后重试
        await new Promise(resolve => setTimeout(resolve, API_CONFIG.retryDelay * retryCount));
        return api.request(error.config);
      }
    }
    
    // HTTP状态码错误处理
    if (error.response) {
      const { status, data } = error.response;
      
      switch (status) {
        case 401:
          // 未授权，清除token并跳转到登录页
          localStorage.removeItem('token');
          sessionStorage.removeItem('token');
          // 避免在登录页面重复跳转
          if (!window.location.pathname.includes('/login')) {
            window.location.href = '/login';
          }
          throw new Error('登录已过期，请重新登录');
          
        case 403:
          throw new Error('没有权限访问此资源');
          
        case 404:
          throw new Error('请求的资源不存在');
          
        case 429:
          throw new Error('请求过于频繁，请稍后再试');
          
        case 500:
          throw new Error('服务器内部错误，请联系管理员');
          
        case 502:
        case 503:
        case 504:
          throw new Error('服务暂时不可用，请稍后再试');
          
        default:
          throw new Error(data?.msg || `请求失败 (HTTP ${status})`);
      }
    } else if (error.request) {
      // 网络连接错误
      console.error('❌ 网络请求详细信息:', {
        config: error.config,
        request: error.request,
        code: error.code,
        errno: error.errno,
        syscall: error.syscall,
        address: error.address,
        port: error.port
      });
      throw new Error(`网络连接失败: ${error.code || error.message} - 目标: ${error.config?.url}`);
    } else {
      // 其他错误
      throw new Error(error.message || '请求处理失败');
    }
  }
);

// =================== 仪表板API ===================

export const dashboardApi = {
  // 获取仪表板数据
  getDashboardData: (): Promise<RuoYiResponse<DashboardData>> => 
    api.get(API_ENDPOINTS.diet.dashboard),
  
  // 获取今日营养摄入
  getTodayNutrition: (): Promise<RuoYiResponse<any>> => 
    api.get(API_ENDPOINTS.diet.todayNutrition),
};

// =================== 饮食记录API ===================

export const dietRecordApi = {
  // 获取饮食记录列表
  getRecords: (params: any = {}): Promise<RuoYiResponse<DietRecord[]>> => {
    // 数据转换：前端日期格式转换为后端期望格式
    const transformedParams = { ...params };
    if (params.date) {
      transformedParams.startDate = params.date;
      transformedParams.endDate = params.date;
      delete transformedParams.date;
    }
    return api.get(API_ENDPOINTS.diet.records, { params: transformedParams });
  },
  
  // 添加饮食记录
  addRecord: (data: Partial<DietRecord>): Promise<RuoYiResponse<DietRecord>> => {
    // 数据转换：前端格式转换为后端期望格式
    const transformedData = transformDietRecordForBackend(data);
    return api.post(API_ENDPOINTS.diet.records, transformedData);
  },
  
  // 更新饮食记录
  updateRecord: (recordId: number, data: Partial<DietRecord>): Promise<RuoYiResponse<DietRecord>> => {
    const transformedData = transformDietRecordForBackend(data);
    return api.put(`${API_ENDPOINTS.diet.records}/${recordId}`, transformedData);
  },
  
  // 删除饮食记录
  deleteRecord: (recordId: number): Promise<RuoYiResponse<void>> => 
    api.delete(`${API_ENDPOINTS.diet.records}/${recordId}`),
  
  // 获取统计报告
  getStatistics: (startDate: string, endDate: string): Promise<RuoYiResponse<any>> => 
    api.get(API_ENDPOINTS.diet.statistics, {
      params: { startDate, endDate }
    }),
  
  // 获取健康趋势
  getHealthTrends: (days: number = 30): Promise<RuoYiResponse<any>> => 
    api.get(API_ENDPOINTS.diet.trends, {
      params: { days }
    }),
};

// =================== 食物数据库API ===================

export const foodApi = {
  // 搜索食物
  searchFoods: async (keyword: string): Promise<RuoYiResponse<FoodInfo[]>> => {
    const response = await api.get(API_ENDPOINTS.foods.search, {
      params: { keyword }
    }) as RuoYiResponse<any[]>;
    
    // 数据转换
    if (response.data && Array.isArray(response.data)) {
      response.data = response.data.map(transformFoodInfoFromBackend);
    }
    
    return response as RuoYiResponse<FoodInfo[]>;
  },
  
  // 根据分类获取食物
  getFoodsByCategory: async (categoryId: number): Promise<RuoYiResponse<FoodInfo[]>> => {
    const response = await api.get(`${API_ENDPOINTS.foods.category}/${categoryId}`) as RuoYiResponse<any[]>;
    
    // 数据转换
    if (response.data && Array.isArray(response.data)) {
      response.data = response.data.map(transformFoodInfoFromBackend);
    }
    
    return response as RuoYiResponse<FoodInfo[]>;
  },
  
  // 获取所有食物
  getAllFoods: async (params: any = {}): Promise<RuoYiResponse<FoodInfo[]>> => {
    const response = await api.get(API_ENDPOINTS.foods.list, { params }) as RuoYiResponse<any[]>;
    
    // 数据转换
    if (response.data && Array.isArray(response.data)) {
      response.data = response.data.map(transformFoodInfoFromBackend);
    }
    
    return response as RuoYiResponse<FoodInfo[]>;
  },
  
  // 获取食物详情
  getFoodDetail: async (foodId: number): Promise<RuoYiResponse<FoodInfo>> => {
    const response = await api.get(`${API_ENDPOINTS.foods.detail}/${foodId}`) as RuoYiResponse<any>;
    
    // 数据转换
    if (response.data) {
      response.data = transformFoodInfoFromBackend(response.data);
    }
    
    return response as RuoYiResponse<FoodInfo>;
  },
};

// =================== AI识别API ===================

export const aiApi = {
  // AI食物识别
  recognizeFood: (imageFile: File): Promise<RuoYiResponse<RecognitionResult>> => {
    const formData = new FormData();
    formData.append('image', imageFile);
    
    return api.post(API_ENDPOINTS.ai.recognize, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      }
    });
  },
};

// =================== 用户认证API ===================

export const authApi = {
  // 登录
  login: (username: string, password: string): Promise<RuoYiResponse<AuthResponse>> => 
    api.post(API_ENDPOINTS.auth.login, {
      username,
      password
    }),
  
  // 登出
  logout: (): Promise<RuoYiResponse<void>> => 
    api.post(API_ENDPOINTS.auth.logout),
  
  // 获取用户信息
  getUserInfo: (): Promise<RuoYiResponse<AuthResponse>> => 
    api.get(API_ENDPOINTS.auth.getUserInfo),
  
  // 注册
  register: (userData: any): Promise<RuoYiResponse<void>> => 
    api.post(API_ENDPOINTS.auth.register, userData),
};

// =================== 通用API ===================

export const commonApi = {
  // 文件上传
  uploadFile: (file: File): Promise<RuoYiResponse<UploadResponse>> => {
    const formData = new FormData();
    formData.append('file', file);
    
    return api.post(API_ENDPOINTS.common.upload, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      }
    });
  },
  
  // 获取验证码
  getCaptcha: (): Promise<RuoYiResponse<CaptchaResponse>> => 
    api.get(API_ENDPOINTS.auth.captcha),
  
  // 系统健康检查
  healthCheck: (): Promise<RuoYiResponse<any>> => 
    api.get(API_ENDPOINTS.common.health),
  
  // 获取系统信息
  getSystemInfo: (): Promise<RuoYiResponse<any>> => 
    api.get(API_ENDPOINTS.common.systemInfo),
};

// =================== 系统监控API ===================

export const monitoringApi = {
  // 检查后端服务状态
  checkBackendHealth: async (): Promise<HealthStatus> => {
    try {
      const response = await api.get(API_ENDPOINTS.common.health, { timeout: 5000 });
      return { status: 'healthy', data: response };
    } catch (error: any) {
      return { status: 'unhealthy', error: error.message };
    }
  },
  
  // 检查ML服务状态
  checkMLServiceHealth: async (): Promise<HealthStatus> => {
    try {
      const response = await axios.get(`${env.mlApiBaseURL}/health`, { timeout: 5000 });
      return { status: 'healthy', data: response.data };
    } catch (error: any) {
      return { status: 'unhealthy', error: error.message };
    }
  },
  
  // 获取系统状态概览
  getSystemStatus: async (): Promise<SystemStatusResponse> => {
    const results = await Promise.allSettled([
      monitoringApi.checkBackendHealth(),
      monitoringApi.checkMLServiceHealth()
    ]);
    
    const processResult = (result: PromiseSettledResult<HealthStatus>): HealthStatus => {
      if (result.status === 'fulfilled') {
        const value = result.value;
        // 确保返回的状态值是正确的类型
        return {
          status: value.status === 'healthy' ? 'healthy' : 
                 value.status === 'unhealthy' ? 'unhealthy' : 'error',
          error: value.error,
          data: value.data
        };
      } else {
        return { 
          status: 'error' as const, 
          error: (result.reason as Error)?.message || '检查失败' 
        };
      }
    };
    
    return {
      backend: processResult(results[0]),
      mlService: processResult(results[1]),
      timestamp: new Date().toISOString()
    };
  }
};

// =================== 连接状态管理 ===================

export class ConnectionManager {
  private isOnline: boolean;
  private listeners: Array<(status: string) => void>;

  constructor() {
    this.isOnline = navigator.onLine;
    this.listeners = [];
    this.setupEventListeners();
  }
  
  private setupEventListeners() {
    window.addEventListener('online', () => {
      this.isOnline = true;
      this.notifyListeners('online');
    });
    
    window.addEventListener('offline', () => {
      this.isOnline = false;
      this.notifyListeners('offline');
    });
  }
  
  addListener(callback: (status: string) => void) {
    this.listeners.push(callback);
  }
  
  removeListener(callback: (status: string) => void) {
    this.listeners = this.listeners.filter(listener => listener !== callback);
  }
  
  private notifyListeners(status: string) {
    this.listeners.forEach(callback => callback(status));
  }
  
  async testConnection(): Promise<boolean> {
    try {
      await api.get('/actuator/health', { timeout: 3000 });
      return true;
    } catch {
      return false;
    }
  }
}

// 创建连接管理器实例
export const connectionManager = new ConnectionManager();

// =================== API工具函数 ===================

// 批量请求处理
export const batchRequest = async (
  requests: Array<() => Promise<any>>, 
  options: { concurrent?: number; retryOnFailure?: boolean } = {}
): Promise<any[]> => {
  const { concurrent = 3, retryOnFailure = true } = options;
  const results: any[] = [];
  
  for (let i = 0; i < requests.length; i += concurrent) {
    const batch = requests.slice(i, i + concurrent);
    const batchPromises = batch.map(async (request) => {
      try {
        return await request();
      } catch (error: any) {
        if (retryOnFailure) {
          try {
            // 重试一次
            await new Promise(resolve => setTimeout(resolve, 1000));
            return await request();
          } catch (retryError: any) {
            return { error: retryError.message };
          }
        }
        return { error: error.message };
      }
    });
    
    const batchResults = await Promise.all(batchPromises);
    results.push(...batchResults);
  }
  
  return results;
};

// 缓存管理
export const apiCache = {
  cache: new Map<string, { data: any; expiry: number }>(),
  
  set(key: string, data: any, ttl: number = 5 * 60 * 1000) { // 默认5分钟缓存
    this.cache.set(key, {
      data,
      expiry: Date.now() + ttl
    });
  },
  
  get(key: string): any {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }
    
    return item.data;
  },
  
  clear() {
    this.cache.clear();
  }
};

// 带缓存的API请求
export const cachedRequest = async <T>(
  key: string, 
  requestFn: () => Promise<T>, 
  ttl?: number
): Promise<T> => {
  const cached = apiCache.get(key);
  if (cached) {
    console.log('📦 使用缓存数据:', key);
    return cached;
  }
  
  const data = await requestFn();
  apiCache.set(key, data, ttl);
  return data;
};

// =================== 数据转换工具函数 ===================

// 将前端DietRecord格式转换为后端期望格式
export const transformDietRecordForBackend = (data: Partial<DietRecord>): any => {
  const transformed: any = {};
  
  // 基础字段映射
  if (data.recordId !== undefined) transformed.recordId = data.recordId;
  if (data.userId !== undefined) transformed.userId = data.userId;
  
  // 日期处理
  if (data.recordTime) {
    transformed.recordDate = data.recordTime.split('T')[0]; // 取日期部分
  } else if (data.recordDate) {
    transformed.recordDate = data.recordDate;
  } else {
    transformed.recordDate = new Date().toISOString().split('T')[0];
  }
  
  // 餐次类型转换（前端：字符串 -> 后端：数字字符串）
  if (data.mealType) {
    const mealTypeMap: { [key: string]: string } = {
      'breakfast': '0',
      'lunch': '1', 
      'dinner': '2',
      'snack': '3'
    };
    transformed.mealType = mealTypeMap[data.mealType] || data.mealType;
  }
  
  // 营养信息处理
  transformed.totalCalories = data.totalCalories || data.calories || 0;
  transformed.totalProtein = data.totalProtein || data.protein || 0;
  transformed.totalFat = data.totalFat || data.fat || 0;
  transformed.totalCarbohydrate = data.totalCarbohydrate || data.carbohydrate || 0;
  
  // 其他字段
  if (data.notes !== undefined) transformed.notes = data.notes;
  if (data.imageUrls !== undefined) transformed.imageUrls = data.imageUrls;
  if (data.mongoDocId !== undefined) transformed.mongoDocId = data.mongoDocId;
  
  // 如果有foodName，放在notes中
  if (data.foodName && !transformed.notes) {
    transformed.notes = data.foodName;
  }
  
  return transformed;
};

// 将后端DietRecord格式转换为前端期望格式
export const transformDietRecordFromBackend = (data: any): DietRecord => {
  const mealTypeMap: { [key: string]: string } = {
    '0': 'breakfast',
    '1': 'lunch',
    '2': 'dinner', 
    '3': 'snack'
  };
  
  return {
    recordId: data.recordId,
    userId: data.userId,
    recordDate: data.recordDate,
    recordTime: data.recordDate ? `${data.recordDate}T${new Date().toTimeString().split(' ')[0]}` : new Date().toISOString(),
    mealType: mealTypeMap[data.mealType] || data.mealType,
    mealTypeName: data.mealTypeName,
    totalCalories: data.totalCalories,
    totalProtein: data.totalProtein,
    totalFat: data.totalFat,
    totalCarbohydrate: data.totalCarbohydrate,
    // 兼容字段
    calories: data.totalCalories,
    protein: data.totalProtein,
    fat: data.totalFat,
    carbohydrate: data.totalCarbohydrate,
    foodName: data.notes || '未知食物',
    notes: data.notes,
    imageUrls: data.imageUrls,
    mongoDocId: data.mongoDocId,
    createTime: data.createTime,
    updateTime: data.updateTime,
    userName: data.userName
  };
};

// 将后端FoodInfo格式转换为前端期望格式
export const transformFoodInfoFromBackend = (data: any): FoodInfo => {
  return {
    foodId: data.foodId,
    foodName: data.foodName,
    foodCode: data.foodCode,
    categoryId: data.categoryId,
    categoryName: data.categoryName,
    brand: data.brand,
    description: data.description,
    imageUrl: data.imageUrl,
    unit: data.unit || '100g',
    standardWeight: data.standardWeight,
    status: data.status,
    category: data.category,
    // 营养信息
    caloriesPer100g: data.caloriesPer100g,
    proteinPer100g: data.proteinPer100g,
    fatPer100g: data.fatPer100g,
    carbohydratePer100g: data.carbohydratePer100g,
    // 兼容字段
    calories: data.caloriesPer100g,
    protein: data.proteinPer100g,
    fat: data.fatPer100g,
    carbohydrate: data.carbohydratePer100g
  };
};

// 错误信息本地化
export const localizeErrorMessage = (error: any): string => {
  if (typeof error === 'string') return error;
  
  const errorMap: { [key: string]: string } = {
    'Network Error': '网络连接失败，请检查网络连接',
    'timeout': '请求超时，请稍后重试',
    'Request failed with status code 401': '认证失败，请重新登录',
    'Request failed with status code 403': '权限不足，无法访问',
    'Request failed with status code 404': '请求的资源不存在',
    'Request failed with status code 500': '服务器内部错误，请稍后重试'
  };
  
  const message = error.message || error.toString();
  return errorMap[message] || message || '操作失败，请重试';
};

// 默认导出api实例
export default api;
