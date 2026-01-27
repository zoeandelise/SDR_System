import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { isAuthenticated, getUserInfo } from '../utils/auth';

interface AuthGuardProps {
  children: React.ReactNode;
  requireAuth?: boolean;
}

const AuthGuard: React.FC<AuthGuardProps> = ({ children, requireAuth = true }) => {
  const location = useLocation();

  // 如果不需要认证，直接返回children
  if (!requireAuth) {
    return <>{children}</>;
  }

  // 检查是否已登录
  if (!isAuthenticated()) {
    return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  }

  // 认证通过，返回子组件
  return <>{children}</>;
};

// 简化的权限检查Hook
export const useAuth = () => {
  const userInfo = getUserInfo();

  const isLoggedIn = (): boolean => {
    return isAuthenticated() && !!userInfo;
  };

  const logout = () => {
    import('../services/authService').then(({ logout: serviceLogout }) => {
      serviceLogout();
    });
  };

  return {
    userInfo,
    isLoggedIn,
    logout
  };
};

export default AuthGuard;