import request from '@/utils/request'

/**
 * 机器学习推荐系统API
 */

// 获取ML服务状态
export function getMLStatus() {
  return request({
    url: '/diet/ml/status',
    method: 'get'
  })
}

// 刷新ML服务状态（主动检查ML服务）
export function refreshMLStatus() {
  return request({
    url: '/diet/ml/status/refresh',
    method: 'post'
  })
}

// 获取用户画像
export function getUserProfile(userId, daysBack = 30) {
  return request({
    url: '/diet/ml/user/profile',
    method: 'get',
    params: {
      userId,
      daysBack
    }
  })
}

// 训练ML模型
export function trainMLModels(data) {
  return request({
    url: '/diet/ml/model/train',
    method: 'post',
    data: data
  })
}

// 获取推荐效果分析
export function getMLAnalytics() {
  return request({
    url: '/diet/ml/analytics',
    method: 'get'
  })
}

// 获取智能推荐
export function getIntelligentRecommendation(data) {
  return request({
    url: '/diet/ml/recommend',
    method: 'post',
    data: data
  })
}

// 测试ML推荐
export function testMLRecommendation(data) {
  return request({
    url: '/diet/ml/recommend',
    method: 'post',
    data: data
  })
}

// 推荐算法对比
export function compareMLAlgorithms(data) {
  return request({
    url: '/diet/ml/test/compare',
    method: 'post',
    data: data
  })
}

// 提交推荐反馈
export function submitRecommendationFeedback(data) {
  return request({
    url: '/diet/ml/feedback',
    method: 'post',
    data: data
  })
}

// 获取ML服务统计
export function getMLServiceStats() {
  return request({
    url: '/diet/ml/stats',
    method: 'get'
  })
}

// 获取训练进度
export function getTrainingProgress() {
  return request({
    url: '/diet/ml/training/progress',
    method: 'get'
  })
}

// 停止训练
export function stopTraining() {
  return request({
    url: '/diet/ml/training/stop',
    method: 'post'
  })
}
