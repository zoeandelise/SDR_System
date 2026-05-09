import request from '@/utils/request'

// 查询推荐方案列表
export function listRecommendation(query) {
  return request({
    url: '/diet/recommendation/list',
    method: 'get',
    params: query
  })
}

// 查询推荐方案详细
export function getRecommendation(recommendationId) {
  return request({
    url: '/diet/recommendation/' + recommendationId,
    method: 'get'
  })
}

// 新增推荐方案
export function addRecommendation(data) {
  return request({
    url: '/diet/recommendation',
    method: 'post',
    data: data
  })
}

// 修改推荐方案
export function updateRecommendation(data) {
  return request({
    url: '/diet/recommendation',
    method: 'put',
    data: data
  })
}

// 删除推荐方案
export function delRecommendation(recommendationId) {
  return request({
    url: '/diet/recommendation/' + recommendationId,
    method: 'delete'
  })
}

