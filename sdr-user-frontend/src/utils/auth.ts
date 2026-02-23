// 认证工具函数 - 基于若依框架
import Cookies from 'js-cookie';

const TokenKey = 'Admin-Token';
const TokenKeyBackup = 'Admin-Token-Backup'; // localStorage 备份

// 获取Token（优先从 Cookie，其次从 localStorage）
export function getToken(): string | undefined {
  // 先尝试从 Cookie 获取
  const cookieToken = Cookies.get(TokenKey);
  if (cookieToken) {
    return cookieToken;
  }
  
  // Cookie 中没有，尝试从 localStorage 恢复
  const backupToken = localStorage.getItem(TokenKeyBackup);
  if (backupToken) {
    // 恢复到 Cookie
    Cookies.set(TokenKey, backupToken, { 
      path: '/',
      sameSite: 'lax'
    });
    return backupToken;
  }
  
  return undefined;
}

// 设置Token（同时存储到 Cookie 和 localStorage）
export function setToken(token: string): void {
  // 存储到 Cookie
  Cookies.set(TokenKey, token, { 
    path: '/',
    sameSite: 'lax'  // 允许跨站请求携带 Cookie
  });
  
  // 同时备份到 localStorage（防止 Cookie 丢失）
  localStorage.setItem(TokenKeyBackup, token);
}

// 移除Token（清除所有存储）
export function removeToken(): void {
  Cookies.remove(TokenKey, { path: '/' });
  localStorage.removeItem(TokenKeyBackup);
}

// 检查是否已登录
export function isAuthenticated(): boolean {
  const token = getToken();
  return !!token;
}

// 清除所有认证信息
export function clearAuth(): void {
  removeToken();
  localStorage.removeItem('userInfo');
  localStorage.removeItem(TokenKeyBackup);
  sessionStorage.removeItem('userInfo');
}

// 获取用户信息
export function getUserInfo(): any {
  const userInfoStr = localStorage.getItem('userInfo');
  if (userInfoStr) {
    try {
      return JSON.parse(userInfoStr);
    } catch (e) {
      console.error('解析用户信息失败:', e);
      return null;
    }
  }
  return null;
}

// 设置用户信息
export function setUserInfo(userInfo: any): void {
  localStorage.setItem('userInfo', JSON.stringify(userInfo));
}

// 移除用户信息
export function removeUserInfo(): void {
  localStorage.removeItem('userInfo');
  sessionStorage.removeItem('userInfo');
}
