import request from '@/utils/request'

// 查询收藏夹列表
export function listFavorites(query) {
  return request({
    url: '/diet/favorites/list',
    method: 'get',
    params: query
  })
}

// 查询收藏夹详细
export function getFavorites(favoriteId) {
  return request({
    url: '/diet/favorites/' + favoriteId,
    method: 'get'
  })
}

// 新增收藏夹
export function addFavorites(data) {
  return request({
    url: '/diet/favorites',
    method: 'post',
    data: data
  })
}

// 修改收藏夹
export function updateFavorites(data) {
  return request({
    url: '/diet/favorites',
    method: 'put',
    data: data
  })
}

// 删除收藏夹
export function delFavorites(favoriteId) {
  return request({
    url: '/diet/favorites/' + favoriteId,
    method: 'delete'
  })
}

// 获取当前用户收藏列表
export function getMyFavorites(favoriteType) {
  return request({
    url: '/diet/favorites/my',
    method: 'get',
    params: { favoriteType }
  })
}

// 检查是否已收藏
export function checkFavorite(favoriteType, targetId) {
  return request({
    url: '/diet/favorites/check',
    method: 'get',
    params: { favoriteType, targetId }
  })
}

// 添加收藏
export function addFavorite(data) {
  return request({
    url: '/diet/favorites/add',
    method: 'post',
    data: data
  })
}

// 取消收藏
export function removeFavorite(favoriteType, targetId) {
  return request({
    url: '/diet/favorites/remove',
    method: 'delete',
    params: { favoriteType, targetId }
  })
}

// 获取收藏数量统计
export function getFavoriteCount(favoriteType) {
  return request({
    url: '/diet/favorites/count',
    method: 'get',
    params: { favoriteType }
  })
}
