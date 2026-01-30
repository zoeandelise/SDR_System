// 简化版路由配置 - 只包含核心功能
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { isAuthenticated } from '../utils/auth';

// 新页面组件
import LoginPage from '../pages/LoginPage';
import NewHomePage from '../pages/NewHomePage';
import SimpleDietLogPage from '../pages/SimpleDietLogPage';
import SimpleFoodDatabasePage from '../pages/SimpleFoodDatabasePage';
import SmartRecommendationPage from '../pages/SmartRecommendationPage';
import DietHistoryPage from '../pages/DietHistoryPage';
import HealthGoalPage from '../pages/HealthGoalPage';

// 路由守卫组件
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  if (!isAuthenticated()) {
    return <Navigate to="/auth/login" replace />;
  }
  return <>{children}</>;
};

const SimpleRouter: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* 登录页（公开） */}
        <Route path="/auth/login" element={<LoginPage />} />

        {/* 首页（需要登录） */}
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <NewHomePage />
            </ProtectedRoute>
          }
        />

        {/* 饮食记录（需要登录） */}
        <Route
          path="/diet-log"
          element={
            <ProtectedRoute>
              <SimpleDietLogPage />
            </ProtectedRoute>
          }
        />

        {/* 食物库（需要登录） */}
        <Route
          path="/food-database"
          element={
            <ProtectedRoute>
              <SimpleFoodDatabasePage />
            </ProtectedRoute>
          }
        />

        {/* AI智能推荐（需要登录）⭐ 核心功能 */}
        <Route
          path="/smart-recommendation"
          element={
            <ProtectedRoute>
              <SmartRecommendationPage />
            </ProtectedRoute>
          }
        />

        {/* 饮食历史（需要登录） */}
        <Route
          path="/diet-history"
          element={
            <ProtectedRoute>
              <DietHistoryPage />
            </ProtectedRoute>
          }
        />

        {/* 健康目标（需要登录） */}
        <Route
          path="/health-goal"
          element={
            <ProtectedRoute>
              <HealthGoalPage />
            </ProtectedRoute>
          }
        />

        {/* 其他路径重定向到首页 */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default SimpleRouter;

