import request from '@/utils/request'

// 获取所有用户饮食记录概览（用于用户列表页面）
export function getAllUsersRecordsOverview(query) {
  return request({
    url: '/diet/admin/users',
    method: 'get',
    params: query
  })
}

// 获取饮食记录数据概览（用于统计报表）
export function getDietRecordsOverview(query) {
  return request({
    url: '/admin/diet/records/overview',
    method: 'get',
    params: query
  })
}

// 获取指定用户的详细饮食记录
export function getUserDietRecords(userId, query) {
  return request({
    url: `/admin/diet/records/user/${userId}`,
    method: 'get',
    params: query
  })
}

// 获取指定用户的健康目标
export function getUserDietGoals(userId) {
  return request({
    url: `/admin/diet/goals/user/${userId}`,
    method: 'get'
  })
}

// 获取指定用户的推荐记录
export function getUserRecommendations(userId) {
  return request({
    url: `/admin/diet/recommendations/user/${userId}`,
    method: 'get'
  })
}

// 获取用户健康画像详情
export function getUserProfile(userId) {
  return request({
    url: `/admin/diet/profile/user/${userId}`,
    method: 'get'
  })
}

// 导出用户饮食数据
export function exportUserDietData(userId, query) {
  return request({
    url: `/admin/diet/export/user/${userId}`,
    method: 'post',
    params: query,
    responseType: 'blob'
  })
}

// 批量删除用户饮食记录
export function deleteUserDietRecords(recordIds) {
  return request({
    url: `/admin/diet/records/${recordIds}`,
    method: 'delete'
  })
}

// 获取系统饮食数据统计
export function getSystemStatistics() {
  return request({
    url: '/admin/diet/statistics',
    method: 'get'
  })
}

// 管理员专用营养分析接口（可查看指定用户数据）
export function getAdminNutritionAnalysis(query) {
  return request({
    url: '/diet/analysis/nutrition',
    method: 'get',
    params: query
  })
}
