<template>
  <div v-if="hasPermission">
    <slot></slot>
  </div>
</template>

<script>
import { hasPermission, hasRole, hasAnyPermission, hasAnyRole } from '@/utils/permission'

export default {
  name: 'Permission',
  props: {
    // 权限字符串或数组
    permission: {
      type: [String, Array],
      default: null
    },
    // 角色字符串或数组
    role: {
      type: [String, Array],
      default: null
    },
    // 权限检查模式：'all' 需要全部权限，'any' 需要任一权限
    mode: {
      type: String,
      default: 'any',
      validator: value => ['all', 'any'].includes(value)
    }
  },
  computed: {
    hasPermission() {
      // 如果没有设置权限和角色要求，则显示
      if (!this.permission && !this.role) {
        return true
      }
      
      let hasPermissionResult = true
      let hasRoleResult = true
      
      // 检查权限
      if (this.permission) {
        if (Array.isArray(this.permission)) {
          if (this.mode === 'all') {
            hasPermissionResult = this.permission.every(perm => hasPermission(perm))
          } else {
            hasPermissionResult = hasAnyPermission(this.permission)
          }
        } else {
          hasPermissionResult = hasPermission(this.permission)
        }
      }
      
      // 检查角色
      if (this.role) {
        if (Array.isArray(this.role)) {
          if (this.mode === 'all') {
            hasRoleResult = this.role.every(r => hasRole(r))
          } else {
            hasRoleResult = hasAnyRole(this.role)
          }
        } else {
          hasRoleResult = hasRole(this.role)
        }
      }
      
      // 如果同时设置了权限和角色，需要同时满足
      if (this.permission && this.role) {
        return hasPermissionResult && hasRoleResult
      }
      
      // 只设置了权限
      if (this.permission) {
        return hasPermissionResult
      }
      
      // 只设置了角色
      if (this.role) {
        return hasRoleResult
      }
      
      return true
    }
  }
}
</script>
