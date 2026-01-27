import store from '@/store'

/**
 * 权限管理工具类
 * 用于检查用户权限和角色
 */

/**
 * 检查用户是否有指定权限
 * @param {String} permission 权限字符串
 * @returns {Boolean}
 */
export function hasPermission(permission) {
  const permissions = store.getters && store.getters.permissions
  return permissions && permissions.includes(permission)
}

/**
 * 检查用户是否有指定角色
 * @param {String} role 角色字符串
 * @returns {Boolean}
 */
export function hasRole(role) {
  const roles = store.getters && store.getters.roles
  return roles && roles.includes(role)
}

/**
 * 检查用户是否有任一指定权限
 * @param {Array} permissions 权限数组
 * @returns {Boolean}
 */
export function hasAnyPermission(permissions) {
  if (!permissions || permissions.length === 0) {
    return true
  }
  const userPermissions = store.getters && store.getters.permissions
  return permissions.some(permission => userPermissions && userPermissions.includes(permission))
}

/**
 * 检查用户是否有任一指定角色
 * @param {Array} roles 角色数组
 * @returns {Boolean}
 */
export function hasAnyRole(roles) {
  if (!roles || roles.length === 0) {
    return true
  }
  const userRoles = store.getters && store.getters.roles
  return roles.some(role => userRoles && userRoles.includes(role))
}

/**
 * 检查用户是否为管理员
 * @returns {Boolean}
 */
export function isAdmin() {
  const roles = store.getters && store.getters.roles
  return roles && (roles.includes('admin') || roles.includes('administrator'))
}

/**
 * 检查用户是否为超级管理员
 * @returns {Boolean}
 */
export function isSuperAdmin() {
  const userId = store.getters && store.getters.userId
  return userId === 1 // 假设用户ID为1的是超级管理员
}

/**
 * 检查是否可以访问指定用户的数据
 * @param {Number} targetUserId 目标用户ID
 * @returns {Boolean}
 */
export function canAccessUserData(targetUserId) {
  const currentUserId = store.getters && store.getters.userId
  
  // 管理员可以访问所有用户数据
  if (isAdmin()) {
    return true
  }
  
  // 普通用户只能访问自己的数据
  return currentUserId === targetUserId
}

/**
 * 检查是否可以修改指定用户的数据
 * @param {Number} targetUserId 目标用户ID
 * @returns {Boolean}
 */
export function canModifyUserData(targetUserId) {
  const currentUserId = store.getters && store.getters.userId
  
  // 超级管理员可以修改所有用户数据
  if (isSuperAdmin()) {
    return true
  }
  
  // 管理员可以修改普通用户数据，但不能修改其他管理员数据
  if (isAdmin()) {
    // 这里需要检查目标用户是否为管理员
    // 简化处理：管理员可以修改所有数据
    return true
  }
  
  // 普通用户只能修改自己的数据
  return currentUserId === targetUserId
}

/**
 * 获取用户角色显示名称
 * @param {String} role 角色代码
 * @returns {String}
 */
export function getRoleDisplayName(role) {
  const roleMap = {
    'admin': '系统管理员',
    'manager': '业务管理员',
    'user': '普通用户'
  }
  return roleMap[role] || role
}

/**
 * 获取权限显示名称
 * @param {String} permission 权限代码
 * @returns {String}
 */
export function getPermissionDisplayName(permission) {
  const permissionMap = {
    'system:user:view': '查看用户',
    'system:user:add': '新增用户',
    'system:user:edit': '编辑用户',
    'system:user:remove': '删除用户',
    'diet:record:view': '查看饮食记录',
    'diet:record:add': '新增饮食记录',
    'diet:record:edit': '编辑饮食记录',
    'diet:record:remove': '删除饮食记录',
    'diet:food:view': '查看食物信息',
    'diet:food:add': '新增食物信息',
    'diet:food:edit': '编辑食物信息',
    'diet:food:remove': '删除食物信息',
    'system:config:view': '查看系统配置',
    'system:config:edit': '编辑系统配置',
    'monitor:online:view': '查看在线用户',
    'monitor:job:view': '查看定时任务',
    'monitor:job:edit': '编辑定时任务'
  }
  return permissionMap[permission] || permission
}

/**
 * 数据权限过滤
 * 根据用户角色过滤数据
 * @param {Array} data 原始数据
 * @param {String} userIdField 用户ID字段名
 * @returns {Array}
 */
export function filterDataByPermission(data, userIdField = 'userId') {
  if (!data || !Array.isArray(data)) {
    return data
  }
  
  // 管理员可以查看所有数据
  if (isAdmin()) {
    return data
  }
  
  // 普通用户只能查看自己的数据
  const currentUserId = store.getters && store.getters.userId
  return data.filter(item => item[userIdField] === currentUserId)
}

/**
 * 检查菜单权限
 * @param {Object} menu 菜单对象
 * @returns {Boolean}
 */
export function checkMenuPermission(menu) {
  if (!menu) {
    return false
  }
  
  // 如果没有设置权限要求，则允许访问
  if (!menu.perms && !menu.roles) {
    return true
  }
  
  // 检查权限
  if (menu.perms && !hasPermission(menu.perms)) {
    return false
  }
  
  // 检查角色
  if (menu.roles && !hasAnyRole(menu.roles)) {
    return false
  }
  
  return true
}

/**
 * 过滤菜单权限
 * @param {Array} menus 菜单数组
 * @returns {Array}
 */
export function filterMenusByPermission(menus) {
  if (!menus || !Array.isArray(menus)) {
    return []
  }
  
  return menus.filter(menu => {
    // 检查当前菜单权限
    if (!checkMenuPermission(menu)) {
      return false
    }
    
    // 递归检查子菜单
    if (menu.children && menu.children.length > 0) {
      menu.children = filterMenusByPermission(menu.children)
      // 如果子菜单全部被过滤掉，则隐藏父菜单
      return menu.children.length > 0
    }
    
    return true
  })
}

/**
 * 权限指令 - 用于模板中的权限控制
 */
export const permissionDirective = {
  inserted(el, binding) {
    const { value } = binding
    const permissions = store.getters && store.getters.permissions
    
    if (value) {
      const hasPermissions = permissions.includes(value)
      if (!hasPermissions) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    }
  }
}

/**
 * 角色指令 - 用于模板中的角色控制
 */
export const roleDirective = {
  inserted(el, binding) {
    const { value } = binding
    const roles = store.getters && store.getters.roles
    
    if (value) {
      const hasRoles = roles.includes(value)
      if (!hasRoles) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    }
  }
}

/**
 * 权限配置常量
 */
export const PERMISSIONS = {
  // 用户管理
  USER_VIEW: 'system:user:view',
  USER_ADD: 'system:user:add',
  USER_EDIT: 'system:user:edit',
  USER_DELETE: 'system:user:remove',
  USER_EXPORT: 'system:user:export',
  USER_IMPORT: 'system:user:import',
  
  // 饮食记录管理
  DIET_RECORD_VIEW: 'diet:record:view',
  DIET_RECORD_ADD: 'diet:record:add',
  DIET_RECORD_EDIT: 'diet:record:edit',
  DIET_RECORD_DELETE: 'diet:record:remove',
  DIET_RECORD_EXPORT: 'diet:record:export',
  
  // 食物信息管理
  FOOD_INFO_VIEW: 'diet:food:view',
  FOOD_INFO_ADD: 'diet:food:add',
  FOOD_INFO_EDIT: 'diet:food:edit',
  FOOD_INFO_DELETE: 'diet:food:remove',
  
  // 系统配置
  SYSTEM_CONFIG_VIEW: 'system:config:view',
  SYSTEM_CONFIG_EDIT: 'system:config:edit',
  
  // 系统监控
  MONITOR_ONLINE: 'monitor:online:view',
  MONITOR_JOB: 'monitor:job:view',
  MONITOR_JOB_EDIT: 'monitor:job:edit',
  MONITOR_DRUID: 'monitor:druid:view',
  MONITOR_SERVER: 'monitor:server:view',
  MONITOR_CACHE: 'monitor:cache:view'
}

/**
 * 角色配置常量
 */
export const ROLES = {
  ADMIN: 'admin',
  MANAGER: 'manager',
  USER: 'user'
}

export default {
  hasPermission,
  hasRole,
  hasAnyPermission,
  hasAnyRole,
  isAdmin,
  isSuperAdmin,
  canAccessUserData,
  canModifyUserData,
  getRoleDisplayName,
  getPermissionDisplayName,
  filterDataByPermission,
  checkMenuPermission,
  filterMenusByPermission,
  PERMISSIONS,
  ROLES
}