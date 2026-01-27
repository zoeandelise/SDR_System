import request from '@/utils/request'

// 获取今日概览数据
export function getTodayOverview(userId) {
  return request({
    url: '/diet/dashboard/today-overview',
    method: 'get',
    params: {
      userId: userId
    }
  })
}

// 获取今日餐次记录
export function getTodayMeals(userId) {
  return request({
    url: '/diet/dashboard/today-meals',
    method: 'get',
    params: {
      userId: userId
    }
  })
}

// 获取热量趋势数据
export function getCalorieTrend(startDate, endDate, userId) {
  return request({
    url: '/diet/dashboard/calorie-trend',
    method: 'get',
    params: {
      startDate: startDate,
      endDate: endDate,
      userId: userId
    }
  })
}

// 获取营养分布数据
export function getNutritionDistribution(date, userId) {
  return request({
    url: '/diet/dashboard/nutrition-distribution',
    method: 'get',
    params: {
      date: date,
      userId: userId
    }
  })
}

// 获取仪表盘快速统计
export function getQuickStats(userId) {
  return request({
    url: '/diet/dashboard/quick-stats',
    method: 'get',
    params: {
      userId: userId
    }
  })
}

// 获取用户健康目标进度
export function getGoalProgress(userId) {
  return request({
    url: '/diet/dashboard/goal-progress',
    method: 'get',
    params: {
      userId: userId
    }
  })
}

// 生成快速推荐
export function generateQuickRecommendation(userId) {
  return request({
    url: '/diet/dashboard/quick-recommendation',
    method: 'post',
    params: {
      userId: userId
    }
  })
}

// 获取最近推荐列表
export function getRecentRecommendations(userId, limit = 5) {
  return request({
    url: '/diet/dashboard/recent-recommendations',
    method: 'get',
    params: {
      userId: userId,
      limit: limit
    }
  })
}
