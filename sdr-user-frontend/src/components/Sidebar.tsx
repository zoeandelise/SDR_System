import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  Home,
  Calendar,
  BarChart3,
  Target,
  Settings,
  Apple,
  Users,
  TrendingUp,
  X,
  Flame
} from 'lucide-react';
import { Button } from './ui/Button';
import { cn } from '../lib/utils';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

interface NavItem {
  icon: React.ReactNode;
  label: string;
  href: string;
  badge?: string;
  isActive?: boolean;
}

const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  const location = useLocation();

  const navigationItems: NavItem[] = [
    { icon: <Home className="h-5 w-5" />, label: '首页', href: '/' },
    { icon: <Flame className="h-5 w-5" />, label: '打卡', href: '/checkin', badge: '热' },
    { icon: <Calendar className="h-5 w-5" />, label: '饮食记录', href: '/diet-log' },
    { icon: <Apple className="h-5 w-5" />, label: '食物库', href: '/food-database' },
    { icon: <Target className="h-5 w-5" />, label: '营养目标', href: '/nutrition-goals' },
    { icon: <BarChart3 className="h-5 w-5" />, label: '健康报告', href: '/health-report' },
    { icon: <Users className="h-5 w-5" />, label: '社区', href: '/community' },
  ];

  const quickStats = [
    { label: '今日卡路里', value: '1,847', target: '2,000', color: 'text-primary-600' },
    { label: '蛋白质', value: '67g', target: '80g', color: 'text-blue-600' },
    { label: '碳水化合物', value: '231g', target: '250g', color: 'text-orange-600' },
    { label: '脂肪', value: '45g', target: '55g', color: 'text-purple-600' },
  ];

  return (
    <>
      {/* Overlay for mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/20 backdrop-blur-sm z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div className={cn(
        "fixed left-0 top-0 h-full w-80 bg-white border-r border-gray-200 transform transition-transform duration-300 ease-in-out z-50 lg:translate-x-0 lg:static lg:z-auto",
        isOpen ? "translate-x-0" : "-translate-x-full"
      )}>
        <div className="flex flex-col h-full">
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-100">
            <h2 className="text-lg font-semibold text-gray-900">菜单</h2>
            <Button
              variant="ghost"
              size="icon"
              onClick={onClose}
              className="lg:hidden"
            >
              <X className="h-5 w-5" />
            </Button>
          </div>

          {/* Quick Stats */}
          <div className="p-6 border-b border-gray-100">
            <h3 className="text-sm font-medium text-gray-500 mb-4 flex items-center">
              <TrendingUp className="h-4 w-4 mr-2" />
              今日营养摄入
            </h3>
            <div className="space-y-3">
              {quickStats.map((stat, index) => (
                <div key={index} className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">{stat.label}</span>
                  <div className="text-right">
                    <span className={cn("text-sm font-medium", stat.color)}>
                      {stat.value}
                    </span>
                    <span className="text-xs text-gray-400 ml-1">
                      / {stat.target}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-6">
            <ul className="space-y-2">
              {navigationItems.map((item, index) => (
                <li key={index}>
                  <Link
                    to={item.href}
                    onClick={onClose}
                    className={cn(
                      "nav-item",
                      location.pathname === item.href && "active"
                    )}
                  >
                    {item.icon}
                    <span className="ml-3 flex-1">{item.label}</span>
                    {item.badge && (
                      <span className="bg-primary-100 text-primary-700 text-xs px-2 py-1 rounded-full">
                        {item.badge}
                      </span>
                    )}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>

          {/* Footer */}
          <div className="p-6 border-t border-gray-100">
            <Link to="/settings" className="nav-item" onClick={onClose}>
              <Settings className="h-5 w-5" />
              <span className="ml-3">设置</span>
            </Link>
          </div>
        </div>
      </div>
    </>
  );
};

export default Sidebar;
