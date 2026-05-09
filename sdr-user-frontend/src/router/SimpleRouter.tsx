import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { isAuthenticated } from '../utils/auth';
import DesktopLayout from '../components/DesktopLayout';
import LoginPage from '../pages/LoginPage';
import NewHomePage from '../pages/NewHomePage';
import SimpleDietLogPage from '../pages/SimpleDietLogPage';
import SimpleFoodDatabasePage from '../pages/SimpleFoodDatabasePage';
import SmartRecommendationPage from '../pages/SmartRecommendationPage';

import HealthGoalPage from '../pages/HealthGoalPage';
import CheckinPage from '../pages/CheckinPage';
import CommunityPage from '../pages/CommunityPage';
import HealthReportPage from '../pages/HealthReportPage';
import ProfilePage from '../pages/ProfilePage';
import SettingsPage from '../pages/SettingsPage';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
};

const SimpleRouter: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route
          path="/"
          element={
            <ProtectedRoute>
              <DesktopLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<NewHomePage />} />
          <Route path="diet-log" element={<SimpleDietLogPage />} />
          <Route path="food-database" element={<SimpleFoodDatabasePage />} />
          <Route path="smart-recommendation" element={<SmartRecommendationPage />} />
          <Route path="diet-history" element={<Navigate to="/diet-log" replace />} />
          <Route path="health-goal" element={<HealthGoalPage />} />
          <Route path="checkin" element={<CheckinPage />} />
          <Route path="community" element={<CommunityPage />} />
          <Route path="health-report" element={<HealthReportPage />} />
          <Route path="settings" element={<SettingsPage />} />
          <Route path="profile" element={<ProfilePage />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default SimpleRouter;
