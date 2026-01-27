import request from '@/utils/request'

// 查询饮食记录列表
export function listRecord(query) {
  return request({
    url: '/diet/record/list',
    method: 'get',
    params: query
  })
}

// 查询饮食记录详细
export function getRecord(recordId) {
  return request({
    url: '/diet/record/' + recordId,
    method: 'get'
  })
}

// 新增饮食记录
export function addRecord(data) {
  return request({
    url: '/diet/record',
    method: 'post',
    data: data
  })
}

// 修改饮食记录
export function updateRecord(data) {
  return request({
    url: '/diet/record',
    method: 'put',
    data: data
  })
}

// 删除饮食记录
export function delRecord(recordIds) {
  return request({
    url: '/diet/record/' + recordIds,
    method: 'delete'
  })
}

// AI食物识别（上传图片）
export function recognizeFood(formData) {
  return request({
    url: '/diet/record/recognize',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// AI食物识别（图片URL）
export function recognizeFoodByUrl(imageUrl) {
  return request({
    url: '/diet/record/recognize/url',
    method: 'post',
    params: { imageUrl }
  })
}

// 查询用户指定日期的饮食记录
export function getDailyRecords(date) {
  return request({
    url: '/diet/record/daily',
    method: 'get',
    params: { date }
  })
}

// 查询用户指定日期范围的饮食记录
export function getRecordsByRange(startDate, endDate) {
  return request({
    url: '/diet/record/range',
    method: 'get',
    params: { startDate, endDate }
  })
}

// 获取用户营养摄入统计
export function getNutritionSummary(startDate, endDate) {
  return request({
    url: '/diet/record/nutrition/summary',
    method: 'get',
    params: { startDate, endDate }
  })
}

// 新增饮食记录（包含详细信息）
export function addRecordWithDetail(data) {
  return request({
    url: '/diet/record/detail',
    method: 'post',
    data: data
  })
}

// 获取饮食记录详细信息
export function getRecordDetail(recordId) {
  return request({
    url: '/diet/record/detail/' + recordId,
    method: 'get'
  })
}

// 更新饮食记录的营养汇总信息
export function calculateNutrition(recordId) {
  return request({
    url: '/diet/record/nutrition/calculate/' + recordId,
    method: 'put'
  })
}

// 获取用户饮食统计报告
export function getStatisticsReport(startDate, endDate) {
  return request({
    url: '/diet/record/statistics',
    method: 'get',
    params: { startDate, endDate }
  })
}

// 基于食物ID列表创建饮食记录
export function createByFoods(data) {
  return request({
    url: '/diet/record/create-by-foods',
    method: 'post',
    data: data
  })
}

// 批量导入饮食记录
export function importRecords(formData) {
  return request({
    url: '/diet/record/import',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 获取饮食记录导入模板
export function downloadTemplate() {
  return request({
    url: '/diet/record/importTemplate',
    method: 'post',
    responseType: 'blob'
  })
}