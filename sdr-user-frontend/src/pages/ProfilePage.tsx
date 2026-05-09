import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../components/AuthGuard';
import { Card } from '../components/ui/Card';
import {
  Target,
  Users,
  Calendar,
  LogOut,
  ChevronRight,
  Apple,
} from 'lucide-react';

const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const { userInfo, logout } = useAuth();

  const getUserDisplayName = () => {
    if (userInfo?.user) return userInfo.user.nickName || userInfo.user.userName || '用户';
    if (userInfo) return userInfo.nickName || userInfo.username || '用户';
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      try {
        const parsed = JSON.parse(storedUserInfo);
        return parsed.user?.nickName || parsed.user?.userName || parsed.nickName || parsed.userName || '用户';
      } catch { return '用户'; }
    }
    return '用户';
  };

  const getUserAvatar = () => {
    if (userInfo?.user?.avatar) return userInfo.user.avatar;
    if (userInfo?.avatar) return userInfo.avatar;
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      try {
        const parsed = JSON.parse(storedUserInfo);
        return parsed.user?.avatar || parsed.avatar || null;
      } catch { return null; }
    }
    return null;
  };

  const menuGroups = [
    {
      items: [
        { icon: Target, label: '健康目标', desc: '设置身体指标与营养目标', path: '/health-goal', color: 'text-blue-600', bg: 'bg-blue-50' },
        { icon: Calendar, label: '饮食打卡', desc: '每日三餐打卡记录', path: '/checkin', color: 'text-orange-600', bg: 'bg-orange-50' },
        { icon: Apple, label: '食物库', desc: '查询食物营养成分', path: '/food-database', color: 'text-green-600', bg: 'bg-green-50' },
      ]
    },
    {
      items: [
        { icon: Users, label: '饮食社区', desc: '与健康达人交流分享', path: '/community', color: 'text-purple-600', bg: 'bg-purple-50' },
        { icon: Calendar, label: '饮食历史', desc: '查看历史饮食记录', path: '/diet-history', color: 'text-teal-600', bg: 'bg-teal-50' },
      ]
    },
  ];

  return (
    <div className="space-y-6 animate-fadeIn">
      <div className="relative overflow-hidden rounded-2xl bg-black text-white shadow-xl">
        <div className="relative p-8 flex items-center gap-5">
          <div className="relative w-20 h-20 bg-gray-200 rounded-2xl flex items-center justify-center text-gray-700 text-3xl font-bold shadow-lg overflow-hidden">
            {getUserDisplayName().charAt(0).toUpperCase()}
            {getUserAvatar() && String(getUserAvatar()).trim() !== '' && String(getUserAvatar()) !== 'null' && (
              <img 
                src={getUserAvatar()} 
                alt="avatar" 
                className="absolute inset-0 w-full h-full object-cover"
                onError={(e) => { e.currentTarget.style.display = 'none'; }}
              />
            )}
          </div>
          <div>
            <h2 className="text-2xl font-bold text-white">{getUserDisplayName()}</h2>
            <p className="text-gray-400 text-sm mt-1">健康生活，从每一餐开始</p>
          </div>
        </div>
      </div>

      {menuGroups.map((group, gi) => (
        <Card key={gi} className="border-0 shadow-sm overflow-hidden" hoverEffect={false}>
          <div className="divide-y divide-gray-50">
            {group.items.map((item, ii) => {
              const Icon = item.icon;
              return (
                <button
                  key={ii}
                  onClick={() => navigate(item.path)}
                  className="w-full flex items-center gap-4 p-5 hover:bg-gray-50/80 transition-colors text-left"
                >
                  <div className={`w-12 h-12 rounded-xl ${item.bg} flex items-center justify-center flex-shrink-0`}>
                    <Icon className={`w-6 h-6 ${item.color}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-base font-semibold text-gray-900">{item.label}</div>
                    <div className="text-sm text-gray-600 mt-0.5">{item.desc}</div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400 flex-shrink-0" />
                </button>
              );
            })}
          </div>
        </Card>
      ))}

      <button
        onClick={() => {
          if (window.confirm('确定要退出登录吗？')) logout();
        }}
        className="w-full flex items-center justify-center gap-2 py-4 rounded-2xl bg-white shadow-sm text-red-600 font-semibold text-base hover:bg-red-50 transition-colors"
      >
        <LogOut className="w-5 h-5" />
        退出登录
      </button>

      <div className="text-center py-2">
        <p className="text-sm text-gray-500">SDR 智能饮食推荐系统 v1.0</p>
      </div>
    </div>
  );
};

export default ProfilePage;
