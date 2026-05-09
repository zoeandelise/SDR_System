import React, { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Home, UtensilsCrossed, Brain, BarChart3, User } from 'lucide-react';
import NotificationCenter from './NotificationCenter';
import { useAuth } from './AuthGuard';
import { cn } from '../lib/utils';

const tabs = [
  { path: '/', label: '首页', icon: Home },
  { path: '/diet-log', label: '记录', icon: UtensilsCrossed },
  { path: '/smart-recommendation', label: '推荐', icon: Brain, highlight: true },
  { path: '/health-report', label: '报告', icon: BarChart3 },
  { path: '/profile', label: '我的', icon: User },
];

const TabLayout: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { userInfo, logout } = useAuth();
  const [showUserMenu, setShowUserMenu] = useState(false);

  const getUserDisplayName = () => {
    if (userInfo) return userInfo.username || '用户';
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      try {
        const parsed = JSON.parse(storedUserInfo);
        return parsed.nickName || parsed.userName || '用户';
      } catch { return '用户'; }
    }
    return '用户';
  };

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-xl border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 h-14 flex items-center justify-between">
          <div
            className="flex items-center gap-2 cursor-pointer"
            onClick={() => navigate('/')}
          >
            <div className="w-8 h-8 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-xl flex items-center justify-center shadow-sm">
              <span className="text-white text-sm font-bold">S</span>
            </div>
            <h1 className="text-lg font-bold text-gray-900 tracking-tight">SDR 健康</h1>
          </div>

          <div className="flex items-center gap-2">
            <NotificationCenter />
            <div className="relative">
              <button
                onClick={() => setShowUserMenu(!showUserMenu)}
                className="w-8 h-8 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-sm"
              >
                {getUserDisplayName().charAt(0).toUpperCase()}
              </button>
              {showUserMenu && (
                <>
                  <div className="fixed inset-0 z-40" onClick={() => setShowUserMenu(false)} />
                  <div className="absolute right-0 top-full mt-2 w-44 bg-white rounded-xl shadow-lg border border-gray-100 py-1 z-50">
                    <div className="px-4 py-2.5 border-b border-gray-50">
                      <p className="text-sm font-semibold text-gray-900">{getUserDisplayName()}</p>
                      <p className="text-xs text-gray-400">健康用户</p>
                    </div>
                    <button
                      onClick={() => { logout(); setShowUserMenu(false); }}
                      className="w-full px-4 py-2.5 text-left text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
                    >
                      退出登录
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      </header>

      <main className="flex-1 pb-20">
        <Outlet />
      </main>

      <nav className="fixed bottom-0 left-0 right-0 z-40 bg-white/90 backdrop-blur-xl border-t border-gray-100 safe-area-bottom">
        <div className="max-w-7xl mx-auto flex items-center justify-around h-16">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const active = isActive(tab.path);
            const isHighlight = tab.highlight;

            if (isHighlight) {
              return (
                <button
                  key={tab.path}
                  onClick={() => navigate(tab.path)}
                  className={cn(
                    "flex flex-col items-center justify-center -mt-5 transition-all",
                    active && "scale-105"
                  )}
                >
                  <div className={cn(
                    "w-14 h-14 rounded-2xl flex items-center justify-center shadow-lg transition-all",
                    active
                      ? "bg-gradient-to-br from-emerald-500 to-teal-600 shadow-emerald-500/30"
                      : "bg-gradient-to-br from-emerald-400 to-teal-500 shadow-emerald-400/20 hover:shadow-emerald-400/40"
                  )}>
                    <Icon className="w-6 h-6 text-white" />
                  </div>
                  <span className={cn(
                    "text-[10px] mt-1 font-semibold",
                    active ? "text-emerald-600" : "text-gray-400"
                  )}>
                    {tab.label}
                  </span>
                </button>
              );
            }

            return (
              <button
                key={tab.path}
                onClick={() => navigate(tab.path)}
                className="flex flex-col items-center justify-center gap-0.5 py-1 px-3 transition-all"
              >
                <Icon className={cn(
                  "w-5 h-5 transition-colors",
                  active ? "text-emerald-600" : "text-gray-400"
                )} />
                <span className={cn(
                  "text-[10px] font-semibold transition-colors",
                  active ? "text-emerald-600" : "text-gray-400"
                )}>
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
};

export default TabLayout;
