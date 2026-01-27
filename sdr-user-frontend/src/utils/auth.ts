// 认证工具函数 - 基于若依框架
import Cookies from 'js-cookie';

const TokenKey = 'Admin-Token';

// 获取Token
export function getToken(): string | undefined {
  return Cookies.get(TokenKey);
}

// 设置Token
export function setToken(token: string): void {
  Cookies.set(TokenKey, token);
}

// 移除Token
export function removeToken(): void {
  Cookies.remove(TokenKey);
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
