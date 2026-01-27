import request from '@/utils/request'

// 获取营养分析数据
export function getNutritionAnalysis(query) {
  return request({
    url: '/diet/analysis/nutrition',
    method: 'get',
    params: query
  })
}

// 获取营养建议
export function getNutritionAdvice(query) {
  return request({
    url: '/diet/analysis/advice',
    method: 'get',
    params: query
  })
}

// 导出分析报告
export function exportAnalysisReport(query) {
  return request({
    url: '/diet/analysis/export',
    method: 'get',
    params: query,
    responseType: 'blob'
  })
}

// 获取食物摄入统计
export function getFoodIntakeStats(query) {
  return request({
    url: '/diet/analysis/food-stats',
    method: 'get',
    params: query
  })
}

// 获取餐次分析
export function getMealAnalysis(query) {
  return request({
    url: '/diet/analysis/meal',
    method: 'get',
    params: query
  })
}

// 获取营养素趋势
export function getNutrientTrend(query) {
  return request({
    url: '/diet/analysis/nutrient-trend',
    method: 'get',
    params: query
  })
}
