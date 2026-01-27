import React, { useState, useEffect } from 'react';
import DashboardCards from '../components/DashboardCards';
import { useAuth } from '../components/AuthGuard';
import { dashboardApi } from '../services/api';

const HomePage: React.FC = () => {
  const { userInfo } = useAuth();
  const [dashboardData, setDashboardData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // 获取用户显示名称
  const getUserDisplayName = () => {
    if (userInfo?.username) {
      return userInfo.username;
    }
    
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      try {
        const parsed = JSON.parse(storedUserInfo);
        return parsed.nickName || parsed.userName || '用户';
      } catch (e) {
        return '用户';
      }
    }
    
    return '用户';
  };

  // 获取仪表板数据
  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const response = await dashboardApi.getDashboardData();
      if (response.data) {
        setDashboardData(response.data);
      }
    } catch (error) {
      console.error('获取仪表板数据失败:', error);
      // 使用默认数据
      setDashboardData({
        consecutiveDays: 28,
        weightLoss: 3.2,
        healthScore: 85
      });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-primary-500 to-primary-600 rounded-2xl p-8 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">欢迎回来，{getUserDisplayName()}！</h1>
            <p className="text-primary-100 text-lg">
              {loading ? '正在加载您的健康数据...' : 
               `今天是您健康饮食计划的第 ${dashboardData?.consecutiveDays || 28} 天，坚持就是胜利！`}
            </p>
          </div>
          <div className="hidden md:block">
            <div className="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center">
              <span className="text-4xl">🎯</span>
            </div>
          </div>
        </div>
        
        <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-white/10 rounded-xl p-4">
            <h3 className="font-medium text-primary-100">连续打卡</h3>
            <p className="text-2xl font-bold">
              {loading ? '...' : `${dashboardData?.consecutiveDays || 28} 天`}
            </p>
          </div>
          <div className="bg-white/10 rounded-xl p-4">
            <h3 className="font-medium text-primary-100">累计减重</h3>
            <p className="text-2xl font-bold">
              {loading ? '...' : `${dashboardData?.weightLoss || 3.2} kg`}
            </p>
          </div>
          <div className="bg-white/10 rounded-xl p-4">
            <h3 className="font-medium text-primary-100">健康评分</h3>
            <p className="text-2xl font-bold">
              {loading ? '...' : `${dashboardData?.healthScore || 85} 分`}
            </p>
          </div>
        </div>
      </div>

      {/* Dashboard Cards */}
      <DashboardCards />

      {/* Additional Content Sections */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recommended Recipes */}
        <div className="bg-white rounded-2xl shadow-soft p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">为您推荐</h2>
          <div className="space-y-4">
            {[
              { name: '番茄鸡蛋面', time: '15分钟', calories: '420卡', image: '🍝' },
              { name: '蔬菜沙拉', time: '10分钟', calories: '180卡', image: '🥗' },
              { name: '烤三文鱼', time: '25分钟', calories: '350卡', image: '🐟' }
            ].map((recipe, index) => (
              <div key={index} className="flex items-center space-x-4 p-3 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors cursor-pointer">
                <div className="text-3xl">{recipe.image}</div>
                <div className="flex-1">
                  <h3 className="font-medium text-gray-900">{recipe.name}</h3>
                  <p className="text-sm text-gray-500">{recipe.time} • {recipe.calories}</p>
                </div>
                <button className="text-primary-600 hover:text-primary-700 font-medium text-sm">
                  查看
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Health Tips */}
        <div className="bg-white rounded-2xl shadow-soft p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">健康小贴士</h2>
          <div className="space-y-4">
            <div className="p-4 bg-gradient-to-r from-blue-50 to-blue-100 rounded-xl">
              <h3 className="font-medium text-blue-900 mb-2">💧 多喝水</h3>
              <p className="text-sm text-blue-700">
                每天建议饮水 2-2.5 升，有助于新陈代谢和排毒。
              </p>
            </div>
            <div className="p-4 bg-gradient-to-r from-green-50 to-green-100 rounded-xl">
              <h3 className="font-medium text-green-900 mb-2">🥬 多吃蔬菜</h3>
              <p className="text-sm text-green-700">
                每餐至少包含一种深色蔬菜，补充维生素和纤维。
              </p>
            </div>
            <div className="p-4 bg-gradient-to-r from-orange-50 to-orange-100 rounded-xl">
              <h3 className="font-medium text-orange-900 mb-2">🏃 适量运动</h3>
              <p className="text-sm text-orange-700">
                每周至少 150 分钟中等强度运动，保持身体活力。
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
