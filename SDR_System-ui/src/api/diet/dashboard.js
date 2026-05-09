import request from '@/utils/request'

// 获取全局真实核心数字概览
export function getGlobalOverview() {
  return request({
    url: '/diet/dashboard/global-overview',
    method: 'get'
  })
}

// 获取全站近十日流水折线数据
export function getGlobalTrend() {
  return request({
    url: '/diet/dashboard/global-trend',
    method: 'get'
  })
}

// 获取全网最高频上报TOP 5食物分布
export function getGlobalHotFoods() {
  return request({
    url: '/diet/dashboard/global-hot-foods',
    method: 'get'
  })
}

// 主页快速状态数字看板
export function getQuickStats() {
  return request({
    url: '/diet/dashboard/quick-stats',
    method: 'get'
  })
}
