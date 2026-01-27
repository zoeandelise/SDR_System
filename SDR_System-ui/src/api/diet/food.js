import request from '@/utils/request'

// 查询食物列表
export function listFood(query) {
  return request({
    url: '/diet/food/list',
    method: 'get',
    params: query
  })
}

// 查询食物详细
export function getFood(foodId) {
  return request({
    url: '/diet/food/' + foodId,
    method: 'get'
  })
}

// 新增食物
export function addFood(data) {
  return request({
    url: '/diet/food',
    method: 'post',
    data: data
  })
}

// 修改食物
export function updateFood(data) {
  return request({
    url: '/diet/food',
    method: 'put',
    data: data
  })
}

// 删除食物
export function delFood(foodId) {
  return request({
    url: '/diet/food/' + foodId,
    method: 'delete'
  })
}

// 搜索食物
export function searchFood(keyword) {
  return request({
    url: '/diet/food/search',
    method: 'get',
    params: { keyword }
  })
}

// 获取食物营养信息
export function getFoodNutrition(foodId, weight) {
  return request({
    url: '/diet/food/nutrition',
    method: 'get',
    params: { foodId, weight }
  })
}