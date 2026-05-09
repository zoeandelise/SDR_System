import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Flame,
  Droplets,
  Activity,
  TrendingUp,
  Calendar,
  Clock,
  Target,
  Award,
  QrCode,
  Brain
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/Card';
import { Button } from './ui/Button';
import { dashboardApi } from '../services/api';

const DashboardCards: React.FC = () => {
  const navigate = useNavigate();
  const [showNotification, setShowNotification] = useState(false);
  const [dashboardData, setDashboardData] = useState<any>(null);
  const [, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // 获取仪表板数据
  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setLoading(true);
        setError(null);

        // 尝试从后端获取数据
        const response = await dashboardApi.getDashboardData();
        console.log('Dashboard API Response:', response);

        if (response && response.data) {
          setDashboardData(response.data);
        } else {
          // 如果API调用失败，使用默认数据
          setDashboardData(getDefaultDashboardData());
        }
      } catch (err) {
        console.warn('API调用失败，使用默认数据:', err);
        setError('连接后端服务失败，正在使用演示数据');
        // 使用默认数据确保界面正常显示
        setDashboardData(getDefaultDashboardData());
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  // 默认仪表板数据
  const getDefaultDashboardData = () => ({
    todayNutrition: {
      totalCalories: { toFixed: () => '1847' },
      totalProtein: { toFixed: () => '67' },
      totalFat: { toFixed: () => '45' },
      totalCarbohydrate: { toFixed: () => '231' },
      totalFiber: { toFixed: () => '18' }
    },
    userProfile: {
      userName: '张小明',
      continuousDays: 28,
      totalWeightLoss: 3.2,
      healthScore: 85
    },
    todayRecords: [
      { mealType: '早餐', totalCalories: { toFixed: () => '420' }, notes: '燕麦粥 + 牛奶 + 香蕉' },
      { mealType: '午餐', totalCalories: { toFixed: () => '650' }, notes: '鸡胸肉沙拉 + 全麦面包' },
      { mealType: '下午茶', totalCalories: { toFixed: () => '180' }, notes: '苹果 + 混合坚果' }
    ]
  });

  // 动态生成营养卡片数据
  const getNutritionCards = () => {
    const nutrition = dashboardData?.todayNutrition;

    if (!nutrition || nutrition.totalCalories === null) {
      // 使用默认数据
      return [
        {
          title: '今日卡路里',
          value: '1,847',
          target: '2,000',
          percentage: 92,
          icon: <Flame className="h-6 w-6" />,
          color: 'text-red-500',
          bgColor: 'bg-red-50',
          description: '距离目标还差 153 卡路里'
        },
        {
          title: '水分摄入',
          value: '1.8L',
          target: '2.5L',
          percentage: 72,
          icon: <Droplets className="h-6 w-6" />,
          color: 'text-blue-500',
          bgColor: 'bg-blue-50',
          description: '建议再喝 700ml 水'
        },
        {
          title: '运动消耗',
          value: '420',
          target: '500',
          percentage: 84,
          icon: <Activity className="h-6 w-6" />,
          color: 'text-green-500',
          bgColor: 'bg-green-50',
          description: '今日运动 45 分钟'
        },
        {
          title: '健康评分',
          value: '85',
          target: '100',
          percentage: 85,
          icon: <Award className="h-6 w-6" />,
          color: 'text-purple-500',
          bgColor: 'bg-purple-50',
          description: '本周平均分 82'
        }
      ];
    }

    // 处理真实的后端数据
    const calories = parseFloat(nutrition.totalCalories?.toFixed ? nutrition.totalCalories.toFixed(0) : nutrition.totalCalories || '1847');
    const caloriesTarget = 2000;
    const caloriesPercentage = Math.round((calories / caloriesTarget) * 100);

    return [
      {
        title: '今日卡路里',
        value: calories.toLocaleString(),
        target: caloriesTarget.toLocaleString(),
        percentage: Math.min(caloriesPercentage, 100),
        icon: <Flame className="h-6 w-6" />,
        color: 'text-red-500',
        bgColor: 'bg-red-50',
        description: caloriesPercentage >= 100
          ? '今日目标已达成！'
          : `距离目标还差 ${caloriesTarget - calories} 卡路里`
      },
      {
        title: '蛋白质',
        value: `${nutrition.totalProtein?.toFixed ? nutrition.totalProtein.toFixed(1) : nutrition.totalProtein || '67'}g`,
        target: '100g',
        percentage: Math.round(((nutrition.totalProtein?.toFixed ? parseFloat(nutrition.totalProtein.toFixed(1)) : parseFloat(nutrition.totalProtein || '67')) / 100) * 100),
        icon: <Target className="h-6 w-6" />,
        color: 'text-orange-500',
        bgColor: 'bg-orange-50',
        description: '蛋白质摄入良好'
      },
      {
        title: '水分摄入',
        value: '1.8L',
        target: '2.5L',
        percentage: 72,
        icon: <Droplets className="h-6 w-6" />,
        color: 'text-blue-500',
        bgColor: 'bg-blue-50',
        description: '建议再喝 700ml 水'
      },
      {
        title: '健康评分',
        value: dashboardData.userProfile?.healthScore || '85',
        target: '100',
        percentage: dashboardData.userProfile?.healthScore || 85,
        icon: <Award className="h-6 w-6" />,
        color: 'text-purple-500',
        bgColor: 'bg-purple-50',
        description: '评分持续上升中'
      }
    ];
  };

  const quickActions = [
    {
      title: '记录饮食',
      description: '快速记录今日餐食',
      icon: <Calendar className="h-8 w-8" />,
      color: 'from-primary-500 to-primary-600',
      action: () => navigate('/diet-log')
    },
    {
      title: '扫码识别',
      description: '扫描食物条码获取营养信息',
      icon: <QrCode className="h-8 w-8" />,
      color: 'from-blue-500 to-blue-600',
      action: () => {
        setShowNotification(true);
        setTimeout(() => setShowNotification(false), 3000);
      }
    },
    {
      title: '智能推荐',
      description: '基于您的偏好推荐今日饮食方案',
      icon: <Brain className="h-8 w-8" />,
      color: 'from-orange-500 to-orange-600',
      action: () => navigate('/smart-recommendation')
    }
  ];

  // 动态生成最近餐食数据
  const getRecentMeals = () => {
    if (dashboardData?.todayRecords && dashboardData.todayRecords.length > 0) {
      return dashboardData.todayRecords.map((record: any, index: number) => ({
        time: ['08:30', '12:15', '15:30', '18:30'][index] || '18:30',
        meal: record.mealType || '未知餐次',
        food: record.notes || '暂无详情',
        calories: record.totalCalories?.toFixed ? parseInt(record.totalCalories.toFixed(0)) : parseInt(record.totalCalories || '0'),
        image: ['🥣', '🥗', '🍎', '🍽️'][index] || '🍽️'
      }));
    }

    // 默认数据
    return [
      {
        time: '08:30',
        meal: '早餐',
        food: '燕麦粥 + 牛奶 + 香蕉',
        calories: 420,
        image: '🥣'
      },
      {
        time: '12:15',
        meal: '午餐',
        food: '鸡胸肉沙拉 + 全麦面包',
        calories: 650,
        image: '🥗'
      },
      {
        time: '15:30',
        meal: '下午茶',
        food: '苹果 + 坚果',
        calories: 180,
        image: '🍎'
      }
    ];
  };

  return (
    <div className="space-y-8">
      {/* Notification */}
      {showNotification && (
        <div className="fixed top-4 right-4 bg-blue-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 transform transition-all duration-300">
          📱 扫码功能即将推出！敬请期待
        </div>
      )}
      {/* API连接状态通知 */}
      {error && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <div className="flex items-center">
            <Target className="h-5 w-5 text-yellow-500 mr-2" />
            <span className="text-yellow-800">{error}</span>
            <button
              onClick={() => setError(null)}
              className="ml-auto text-yellow-500 hover:text-yellow-700"
            >
              ×
            </button>
          </div>
        </div>
      )}

      {/* Nutrition Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {getNutritionCards().map((card, index) => (
          <Card key={index} className="relative overflow-hidden">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
              <CardTitle className="text-sm font-medium text-gray-600">
                {card.title}
              </CardTitle>
              <div className={`p-2 rounded-lg ${card.bgColor}`}>
                <div className={card.color}>
                  {card.icon}
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-baseline space-x-2">
                <div className="text-2xl font-bold text-gray-900">
                  {card.value}
                </div>
                <div className="text-sm text-gray-500">
                  / {card.target}
                </div>
              </div>
              <div className="mt-2">
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-gradient-to-r from-primary-500 to-primary-600 h-2 rounded-full transition-all duration-500"
                    style={{ width: `${card.percentage}%` }}
                  ></div>
                </div>
                <p className="text-xs text-gray-500 mt-2">{card.description}</p>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Clock className="h-5 w-5 mr-2 text-primary-600" />
            快捷操作
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {quickActions.map((action, index) => (
              <Button
                key={index}
                variant="ghost"
                onClick={action.action}
                className="h-auto p-6 flex flex-col items-center space-y-3 hover:bg-gray-50 border border-gray-200 rounded-xl hover:border-primary-200 transition-all duration-200 transform hover:scale-105"
              >
                <div className={`w-16 h-16 rounded-full bg-gradient-to-br ${action.color} flex items-center justify-center text-white shadow-lg`}>
                  {action.icon}
                </div>
                <div className="text-center">
                  <h3 className="font-medium text-gray-900">{action.title}</h3>
                  <p className="text-sm text-gray-500 mt-1">{action.description}</p>
                </div>
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Recent Meals */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>今日饮食记录</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {getRecentMeals().map((meal: any, index: number) => (
                  <div key={index} className="flex items-center space-x-4 p-4 bg-gray-50 rounded-xl">
                    <div className="text-3xl">{meal.image}</div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <span className="text-sm font-medium text-gray-900">{meal.meal}</span>
                        <span className="text-xs text-gray-500">{meal.time}</span>
                      </div>
                      <p className="text-sm text-gray-600 mt-1">{meal.food}</p>
                    </div>
                    <div className="text-right">
                      <span className="text-sm font-medium text-gray-900">{meal.calories}</span>
                      <p className="text-xs text-gray-500">卡路里</p>
                    </div>
                  </div>
                ))}
              </div>
              <Button
                className="w-full mt-4"
                variant="outline"
                onClick={() => navigate('/diet-log')}
              >
                查看完整记录
              </Button>
            </CardContent>
          </Card>
        </div>

        <div>
          <Card>
            <CardHeader>
              <CardTitle>本周趋势</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                <div className="text-center">
                  <div className="text-3xl font-bold text-primary-600">7.2kg</div>
                  <p className="text-sm text-gray-500">当前体重</p>
                  <div className="flex items-center justify-center mt-2">
                    <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                    <span className="text-sm text-green-600">比上周减少 0.3kg</span>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">平均卡路里</span>
                    <span className="text-sm font-medium">1,920</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">运动天数</span>
                    <span className="text-sm font-medium">5 / 7 天</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">水分达标</span>
                    <span className="text-sm font-medium">6 / 7 天</span>
                  </div>
                </div>

                <Button
                  className="w-full"
                  size="sm"
                  onClick={() => navigate('/health-report')}
                >
                  查看详细报告
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default DashboardCards;
