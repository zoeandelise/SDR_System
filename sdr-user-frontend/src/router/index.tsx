import React from 'react';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Layout from '../components/Layout';
import AuthGuard from '../components/AuthGuard';
import LoginPage from '../pages/LoginPage';
import HomePage from '../pages/NewHomePage';  // 使用 NewHomePage 替代
import DietLogPage from '../pages/SimpleDietLogPage';  // 使用 SimpleDietLogPage 替代
import FoodDatabasePage from '../pages/SimpleFoodDatabasePage';  // 使用 SimpleFoodDatabasePage 替代
import NutritionGoalsPage from '../pages/NutritionGoalsPage';
import HealthReportPage from '../pages/HealthReportPage';
import RecipesPage from '../pages/RecipesPage';
import CommunityPage from '../pages/CommunityPage';
import FavoritesPage from '../pages/FavoritesPage';
import SettingsPage from '../pages/SettingsPage';

const router = createBrowserRouter([
  // 登录页面（公开访问，不需要AuthGuard）
  {
    path: '/login',
    element: (
      <AuthGuard requireAuth={false}>
        <LoginPage />
      </AuthGuard>
    )
  },
  // 主应用（需要认证）
  {
    path: '/',
    element: (
      <AuthGuard requireAuth={true}>
        <Layout />
      </AuthGuard>
    ),
    children: [
      {
        index: true,
        element: <HomePage />
      },
      {
        path: 'diet-log',
        element: <DietLogPage />
      },
      {
        path: 'food-database',
        element: <FoodDatabasePage />
      },
      {
        path: 'nutrition-goals',
        element: <NutritionGoalsPage />
      },
      {
        path: 'health-report',
        element: <HealthReportPage />
      },
      {
        path: 'recipes',
        element: <RecipesPage />
      },
      {
        path: 'community',
        element: <CommunityPage />
      },
      {
        path: 'favorites',
        element: <FavoritesPage />
      },
      {
        path: 'settings',
        element: <SettingsPage />
      }
    ]
  }
]);

const AppRouter: React.FC = () => {
  return <RouterProvider router={router} />;
};

export default AppRouter;
