import request from '@/utils/request'

// 获取用户档案
export function getUserProfile() {
  return request({
    url: '/diet/profile',
    method: 'get'
  })
}

// 更新用户档案
export function updateUserProfile(data) {
  return request({
    url: '/diet/profile',
    method: 'put',
    data: data
  })
}

// 获取健康指标
export function getHealthIndicators() {
  return request({
    url: '/diet/profile/health',
    method: 'get'
  })
}

// 添加健康指标
export function addHealthIndicator(data) {
  return request({
    url: '/diet/profile/health',
    method: 'post',
    data: data
  })
}

// 获取饮食习惯分析
export function getDietHabits() {
  return request({
    url: '/diet/profile/habits',
    method: 'get'
  })
}

// 获取个性化建议
export function getPersonalRecommendations() {
  return request({
    url: '/diet/profile/recommendations',
    method: 'get'
  })
}

// 获取用户营养摄入统计
export function getNutritionStats(query) {
  return request({
    url: '/diet/profile/nutrition-stats',
    method: 'get',
    params: query
  })
}

// 获取体重变化趋势
export function getWeightTrend(query) {
  return request({
    url: '/diet/profile/weight-trend',
    method: 'get',
    params: query
  })
}

// 计算BMR（基础代谢率）
export function calculateBMR(data) {
  return request({
    url: '/diet/profile/calculate-bmr',
    method: 'post',
    data: data
  })
}

// 计算每日热量需求
export function calculateDailyCalories(data) {
  return request({
    url: '/diet/profile/calculate-daily-calories',
    method: 'post',
    data: data
  })
}
