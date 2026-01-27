// API响应类型定义

// 若依框架标准响应格式
export interface RuoYiResponse<T = any> {
  code: number;
  msg: string;
  data: T;
}

// 用户信息类型
export interface UserInfo {
  userId: number;
  userName: string;
  nickName?: string;
  email?: string;
  avatar?: string;
  deptId?: number;
  deptName?: string;
  roles?: string[];
  permissions?: string[];
}

// 用户认证响应
export interface AuthResponse {
  user: UserInfo;
  roles: string[];
  permissions: string[];
  token?: string;
}

// 系统健康状态
export interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'error';
  error?: string;
  data?: any;
}

// 系统状态响应
export interface SystemStatusResponse {
  backend: HealthStatus;
  mlService: HealthStatus;
  timestamp: string;
}

// 饮食记录类型 - 匹配后端DietRecord实体
export interface DietRecord {
  recordId?: number;
  userId?: number;
  recordDate?: string;
  mealType: string; // 后端使用字符串：0早餐 1午餐 2晚餐 3加餐
  totalCalories?: number;
  totalProtein?: number;
  totalFat?: number;
  totalCarbohydrate?: number;
  mongoDocId?: string;
  imageUrls?: string;
  notes?: string;
  userName?: string;
  mealTypeName?: string;
  createTime?: string;
  updateTime?: string;
  // 前端兼容字段
  foodName?: string;
  amount?: number;
  unit?: string;
  calories?: number;
  protein?: number;
  fat?: number;
  carbohydrate?: number;
  recordTime?: string;
}

// 营养统计
export interface NutritionStats {
  totalCalories: number;
  totalProtein: number;
  totalFat: number;
  totalCarbohydrate: number;
  targetCalories?: number;
  targetProtein?: number;
  targetFat?: number;
  targetCarbohydrate?: number;
}

// 仪表板数据
export interface DashboardData {
  todayNutrition: NutritionStats;
  weekStats: any;
  todayRecords: DietRecord[];
  userProfile: any;
}

// 食物信息 - 匹配后端DietFoodInfo实体
export interface FoodInfo {
  foodId: number;
  foodName: string;
  foodCode?: string;
  categoryId?: number;
  categoryName?: string;
  brand?: string;
  description?: string;
  imageUrl?: string;
  unit?: string;
  standardWeight?: number;
  status?: string;
  category?: string;
  // 营养信息 (每100g)
  caloriesPer100g?: number;
  proteinPer100g?: number;
  fatPer100g?: number;
  carbohydratePer100g?: number;
  // 前端兼容字段
  calories?: number;
  protein?: number;
  fat?: number;
  carbohydrate?: number;
}

// ML推荐结果
export interface RecommendationResult {
  recommendedFoods: FoodInfo[];
  reason: string;
  score: number;
  mealType: string;
  targetNutrition: NutritionStats;
}

// AI识别结果
export interface RecognitionResult {
  foodName: string;
  confidence: number;
  nutrition: {
    calories: number;
    protein: number;
    fat: number;
    carbohydrate: number;
  };
  suggestions: string[];
}

// 分页响应
export interface PageResponse<T> {
  rows: T[];
  total: number;
  code: number;
  msg: string;
}

// 错误响应
export interface ApiError {
  code: number;
  message: string;
  details?: string;
  timestamp: string;
  path?: string;
}

// 文件上传响应
export interface UploadResponse {
  fileName: string;
  newFileName: string;
  originalFilename: string;
  url: string;
  size: number;
}

// 验证码响应
export interface CaptchaResponse {
  uuid: string;
  img: string;
}

// 不需要默认导出，所有类型都已通过export导出
