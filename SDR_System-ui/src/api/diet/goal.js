import request from '@/utils/request'

// 查询健康目标列表
export function listGoal(query) {
  return request({
    url: '/diet/goal/list',
    method: 'get',
    params: query
  })
}

// 查询健康目标详细
export function getGoal(goalId) {
  return request({
    url: '/diet/goal/' + goalId,
    method: 'get'
  })
}

// 新增健康目标
export function addGoal(data) {
  return request({
    url: '/diet/goal',
    method: 'post',
    data: data
  })
}

// 修改健康目标
export function updateGoal(data) {
  return request({
    url: '/diet/goal',
    method: 'put',
    data: data
  })
}

// 删除健康目标
export function delGoal(goalId) {
  return request({
    url: '/diet/goal/' + goalId,
    method: 'delete'
  })
}

// 更新目标进度
export function updateGoalProgress(data) {
  return request({
    url: '/diet/goal/progress',
    method: 'put',
    data: data
  })
}

// 获取目标概览
export function getGoalSummary() {
  return request({
    url: '/diet/goal/summary',
    method: 'get'
  })
}

// 获取目标进度历史
export function getGoalProgressHistory(goalId) {
  return request({
    url: '/diet/goal/progress/history/' + goalId,
    method: 'get'
  })
}

// 完成目标
export function completeGoal(goalId) {
  return request({
    url: '/diet/goal/complete/' + goalId,
    method: 'put'
  })
}

// 暂停目标
export function pauseGoal(goalId) {
  return request({
    url: '/diet/goal/pause/' + goalId,
    method: 'put'
  })
}

// 恢复目标
export function resumeGoal(goalId) {
  return request({
    url: '/diet/goal/resume/' + goalId,
    method: 'put'
  })
}
