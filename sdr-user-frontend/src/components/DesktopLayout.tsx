import React, { useState, useEffect } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  Home,
  UtensilsCrossed,
  Apple,
  Brain,
  BarChart3,
  Users,
  Target,
  Calendar,
  User,
  LogOut,
  Menu,
  X,
  Heart,
  Activity,
} from 'lucide-react';
import NotificationCenter from './NotificationCenter';
import { useAuth } from './AuthGuard';
import { cn } from '../lib/utils';

const navItems = [
  { path: '/', label: '首页', icon: Home },
  { path: '/diet-log', label: '饮食管理', icon: UtensilsCrossed },
  { path: '/checkin', label: '打卡', icon: Calendar },
  { path: '/smart-recommendation', label: '智能推荐', icon: Target, highlight: true },
  { path: '/food-database', label: '食物库', icon: Apple },
  { path: '/health-goal', label: '健康目标', icon: Brain },
  { path: '/health-report', label: '健康报告', icon: BarChart3 },
  { path: '/community', label: '社区', icon: Users },
];

const DesktopLayout: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { userInfo, logout } = useAuth();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isDesktop, setIsDesktop] = useState(window.innerWidth >= 768);

  useEffect(() => {
    const handleResize = () => setIsDesktop(window.innerWidth >= 768);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const mainMarginLeft = isDesktop ? (sidebarCollapsed ? 72 : 240) : 0;

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

  const handleNavClick = (path: string) => {
    navigate(path);
    setMobileMenuOpen(false);
  };

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Desktop Sidebar */}
      <aside
        className="hidden md:flex flex-col fixed left-0 top-0 bottom-0 z-40 bg-white border-r border-gray-200 transition-all duration-300"
        style={{ width: sidebarCollapsed ? 72 : 240 }}
      >
        {/* Logo */}
        <div className={cn(
          "flex items-center h-16 border-b border-gray-100 px-4",
          sidebarCollapsed ? "justify-center" : "gap-3"
        )}>
          <div className="w-9 h-9 bg-emerald-600 rounded-xl flex items-center justify-center shadow-sm flex-shrink-0">
            <Heart className="w-5 h-5 text-white" />
          </div>
          {!sidebarCollapsed && (
            <span className="text-lg font-bold text-gray-900 whitespace-nowrap">SDR 健康</span>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto py-4 px-3">
          <ul className="space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <li key={item.path}>
                  <button
                    onClick={() => handleNavClick(item.path)}
                    className={cn(
                      "w-full flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all duration-200",
                      active
                        ? "bg-emerald-50 text-emerald-700"
                        : "text-gray-600 hover:bg-gray-50 hover:text-gray-900",
                      sidebarCollapsed && "justify-center px-0",
                      item.highlight && !active && "text-emerald-600"
                    )}
                    title={sidebarCollapsed ? item.label : undefined}
                  >
                    <Icon className={cn("w-5 h-5 flex-shrink-0", active && "text-emerald-600")} />
                    {!sidebarCollapsed && <span>{item.label}</span>}
                    {!sidebarCollapsed && item.highlight && (
                      <span className="ml-auto text-[10px] px-1.5 py-0.5 bg-emerald-100 text-emerald-700 rounded-md font-semibold">推荐</span>
                    )}
                  </button>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* Collapse Toggle */}
        <div className="border-t border-gray-100 p-3">
          <button
            onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
            className="w-full flex items-center justify-center gap-2 py-2 rounded-lg text-gray-500 hover:bg-gray-50 hover:text-gray-700 transition-colors text-sm"
          >
            {sidebarCollapsed ? <Menu className="w-4 h-4" /> : <><X className="w-4 h-4" /><span>收起</span></>}
          </button>
        </div>
      </aside>

      {/* Mobile Overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 bg-black/40 z-50 md:hidden" onClick={() => setMobileMenuOpen(false)} />
      )}

      {/* Mobile Sidebar */}
      <div className={cn(
        "fixed left-0 top-0 bottom-0 w-[280px] bg-white z-50 transition-transform duration-300 md:hidden shadow-xl",
        mobileMenuOpen ? "translate-x-0" : "-translate-x-full"
      )}>
        <div className="flex items-center justify-between h-16 border-b border-gray-100 px-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-emerald-600 rounded-xl flex items-center justify-center shadow-sm">
              <Heart className="w-5 h-5 text-white" />
            </div>
            <span className="text-lg font-bold text-gray-900">SDR 健康</span>
          </div>
          <button onClick={() => setMobileMenuOpen(false)} className="p-2 text-gray-500 hover:text-gray-700">
            <X className="w-5 h-5" />
          </button>
        </div>
        <nav className="py-4 px-3">
          <ul className="space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <li key={item.path}>
                  <button
                    onClick={() => handleNavClick(item.path)}
                    className={cn(
                      "w-full flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all",
                      active
                        ? "bg-emerald-50 text-emerald-700"
                        : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                    )}
                  >
                    <Icon className={cn("w-5 h-5", active && "text-emerald-600")} />
                    <span>{item.label}</span>
                  </button>
                </li>
              );
            })}
          </ul>
        </nav>
      </div>

      {/* Main Content Area */}
      <div
        className="flex-1 flex flex-col min-h-screen min-w-0 transition-all duration-300"
        style={{ marginLeft: mainMarginLeft }}
      >
        {/* Top Header */}
        <header className="sticky top-0 z-30 bg-white border-b border-gray-200">
          <div className="flex items-center justify-between h-16 px-4 md:px-8">
            {/* Left: Mobile menu + Breadcrumb */}
            <div className="flex items-center gap-3">
              <button
                onClick={() => setMobileMenuOpen(true)}
                className="md:hidden p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg"
              >
                <Menu className="w-5 h-5" />
              </button>
              <div className="hidden sm:block">
                <h2 className="text-base font-semibold text-gray-900">
                  {navItems.find(i => isActive(i.path))?.label || '首页'}
                </h2>
              </div>
            </div>

            {/* Right: Notifications + User */}
            <div className="flex items-center gap-3">
              <NotificationCenter />
              <div className="h-5 w-px bg-gray-200" />
              <button
                onClick={() => navigate('/profile')}
                className="flex items-center gap-2.5 pl-2 pr-3 py-1.5 rounded-xl hover:bg-gray-100 transition-colors"
              >
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold shadow-sm"
                  style={{ backgroundColor: '#16a34a', color: '#ffffff' }}
                >
                  {getUserDisplayName().charAt(0).toUpperCase()}
                </div>
                <span className="hidden sm:block text-sm font-semibold text-gray-800">{getUserDisplayName()}</span>
              </button>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 p-4 lg:p-8">
          <div className="max-w-6xl mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

export default DesktopLayout;
