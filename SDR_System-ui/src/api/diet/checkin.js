import request from '@/utils/request'

// 查询饮食打卡记录列表
export function listCheckin(query) {
    return request({
        url: '/diet/checkin/list',
        method: 'get',
        params: query
    })
}

// 查询饮食打卡记录详细
export function getCheckin(checkinId) {
    return request({
        url: '/diet/checkin/' + checkinId,
        method: 'get'
    })
}

// 删除饮食打卡记录
export function delCheckin(checkinId) {
    return request({
        url: '/diet/checkin/' + checkinId,
        method: 'delete'
    })
}

// 导出饮食打卡记录
export function exportCheckin(query) {
    return request({
        url: '/diet/checkin/export',
        method: 'post',
        params: query,
        responseType: 'blob'
    })
}
