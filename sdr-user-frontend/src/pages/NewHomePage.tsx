// 全新设计的首页 - 简洁现代
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { dashboardApi } from '../services/api';
import api from '../services/api';
import FoodDetailModal from '../components/FoodDetailModal';
import Navbar from '../components/Navbar';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

interface DashboardData {
  todayNutrition: {
    totalCalories: number;
    totalProtein: number;
    totalFat: number;
    totalCarbohydrate: number;
  };
  todayRecords: Array<{
    recordId: number;
    mealType: string;
    notes: string;
    totalCalories: number;
  }>;
  userProfile: {
    userName: string;
    continuousDays: number;
    totalWeightLoss: number;
    healthScore: number;
    dailyCalorieGoal?: number;
    dailyProteinGoal?: number;
    dailyCarbGoal?: number;
    dailyFatGoal?: number;
  };
}

const NewHomePage: React.FC = () => {
  const navigate = useNavigate();
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showQuickStart, setShowQuickStart] = useState(false);
  const [generatingPlan, setGeneratingPlan] = useState(false);
  const [showPlanDialog, setShowPlanDialog] = useState(false);
  const [dailyPlan, setDailyPlan] = useState<any>(null);
  const [selectedFood, setSelectedFood] = useState<string | null>(null);

  useEffect(() => {
    loadDashboardData();
    checkIfNeedQuickStart();
  }, []);

  // 检查是否需要显示快速开始
  const checkIfNeedQuickStart = () => {
    setTimeout(() => {
      if (data?.todayRecords?.length === 0) {
        setShowQuickStart(true);
      }
    }, 2000);
  };

  // 快速生成今日方案
  const handleQuickGeneratePlan = async () => {
    try {
      setGeneratingPlan(true);

      const response: any = await api.post('/api/user/diet/daily-plan', {});

      if (response.code === 200) {
        setShowQuickStart(false);
        setDailyPlan(response.data);
        setShowPlanDialog(true);
      }
    } catch (error: any) {
      console.error('生成方案失败:', error);
    } finally {
      setGeneratingPlan(false);
    }
  };

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      setError('');
      const response: any = await dashboardApi.getDashboardData();

      if (response.code === 200 && response.data) {
        setData(response.data);
      } else {
        throw new Error(response.msg || '加载失败');
      }
    } catch (err: any) {
      console.error('加载仪表板数据失败:', err);
      setError(err.message || '加载数据失败');
    } finally {
      setLoading(false);
    }
  };

  const mealTypeNames: { [key: string]: string } = {
    '0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'
  };

  const mealTypeEmojis: { [key: string]: string } = {
    '0': '🍳', '1': '🍱', '2': '🍲', '3': '🍎'
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-50 to-blue-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
          <p className="mt-4 text-gray-600 animate-pulse">正在加载您的健康数据...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50/50">
      <Navbar onMenuClick={() => { }} />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fadeIn">
        {/* 错误提示 */}
        {error && (
          <div className="mb-6 bg-red-50 border border-red-200 rounded-xl p-4 flex items-center justify-between shadow-sm">
            <div className="flex items-center">
              <span className="text-red-600 mr-2 text-xl">⚠️</span>
              <span className="text-red-700 font-medium">{error}</span>
            </div>
            <button
              onClick={() => setError('')}
              className="text-red-600 hover:text-red-800 p-1 hover:bg-red-100 rounded-lg transition-colors"
            >
              ×
            </button>
          </div>
        )}

        {/* 欢迎 Banner */}
        <div className="mb-8 relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary-600 to-teal-600 shadow-xl text-white">
          <div className="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
          <div className="absolute bottom-0 left-0 -mb-10 -ml-10 w-48 h-48 bg-yellow-400/20 rounded-full blur-3xl"></div>

          <div className="relative p-8 md:p-10 flex flex-col md:flex-row items-center justify-between">
            <div>
              <h2 className="text-3xl md:text-4xl font-bold mb-2 tracking-tight">
                欢迎回来，{data?.userProfile?.userName || '用户'} 👋
              </h2>
              <p className="text-primary-100 text-lg mb-6 max-w-lg">
                今天是您坚持健康饮食的第 <span className="font-bold text-white text-2xl mx-1">{data?.userProfile?.continuousDays || 0}</span> 天，继续保持！
              </p>

              <div className="flex flex-wrap gap-4">
                <div className="bg-white/20 backdrop-blur-md rounded-xl px-5 py-3 border border-white/10">
                  <div className="text-primary-100 text-xs uppercase tracking-wider font-semibold mb-1">健康评分</div>
                  <div className="text-3xl font-bold">{data?.userProfile?.healthScore || 0}</div>
                </div>
                <div className="bg-white/20 backdrop-blur-md rounded-xl px-5 py-3 border border-white/10">
                  <div className="text-primary-100 text-xs uppercase tracking-wider font-semibold mb-1">累计减重</div>
                  <div className="text-3xl font-bold">{data?.userProfile?.totalWeightLoss || 0} <span className="text-sm font-normal text-primary-100">kg</span></div>
                </div>
              </div>
            </div>

            <div className="mt-8 md:mt-0 hidden md:block">
              <div className="text-9xl filter drop-shadow-2xl animate-float">🥗</div>
            </div>
          </div>
        </div>

        {/* 核心功能区：AI推荐 + 快速开始 */}
        <div className="mb-10 grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* AI 推荐卡片 */}
          <Card variant="gradient" className="from-indigo-500 to-purple-600 text-white border-0 overflow-hidden relative group cursor-pointer hover:scale-[1.02] transition-transform duration-300" onClick={() => navigate('/smart-recommendation')}>
            <div className="absolute inset-0 bg-white/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            <div className="relative z-10 flex items-center justify-between p-2">
              <div>
                <div className="inline-flex items-center px-3 py-1 rounded-full bg-white/20 text-xs font-bold mb-3 backdrop-blur-sm border border-white/10">
                  ✨ 核心功能
                </div>
                <h3 className="text-2xl font-bold mb-2">AI 智能膳食推荐</h3>
                <p className="text-indigo-100 mb-6 max-w-sm">基于协同过滤算法，为您量身定制今日三餐，兼顾口味与营养。</p>
                <div className="flex gap-2">
                  <Button size="sm" className="bg-white text-indigo-600 hover:bg-indigo-50 shadow-none border-0">
                    立即体验
                  </Button>
                </div>
              </div>
              <div className="text-8xl opacity-80 group-hover:scale-110 transition-transform duration-500">🤖</div>
            </div>
          </Card>

          {/* 快速开始 / 提示卡片 */}
          {showQuickStart && data?.todayRecords?.length === 0 ? (
            <Card variant="gradient" className="from-orange-400 to-pink-500 text-white border-0">
              <div className="flex items-center justify-between h-full">
                <div>
                  <h3 className="text-2xl font-bold mb-2">今天吃什么？</h3>
                  <p className="text-orange-50 mb-4">还没有记录饮食，让 AI 帮您规划或手动记录。</p>
                  <div className="flex gap-3">
                    <Button
                      size="sm"
                      onClick={(e) => { e.stopPropagation(); handleQuickGeneratePlan(); }}
                      disabled={generatingPlan}
                      className="bg-white text-orange-600 hover:bg-orange-50 border-0"
                    >
                      {generatingPlan ? '生成中...' : '🎲 一键生成'}
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => navigate('/diet-log')}
                      className="text-white hover:bg-white/20"
                    >
                      📝 手动记录
                    </Button>
                  </div>
                </div>
                <div className="text-7xl animate-pulse">🍽️</div>
              </div>
            </Card>
          ) : (
            <div className="grid grid-cols-2 gap-4 h-full">
              <Card
                className="bg-blue-50 border-blue-100 hover:border-blue-300 cursor-pointer group"
                onClick={() => navigate('/diet-log')}
              >
                <div className="h-full flex flex-col justify-center items-center text-center p-4">
                  <div className="w-12 h-12 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center text-2xl mb-3 group-hover:scale-110 transition-transform">📝</div>
                  <h4 className="font-bold text-gray-900">饮食记录</h4>
                  <p className="text-xs text-gray-500 mt-1">记录今日每一餐</p>
                </div>
              </Card>
              <Card
                className="bg-amber-50 border-amber-100 hover:border-amber-300 cursor-pointer group"
                onClick={() => navigate('/food-database')}
              >
                <div className="h-full flex flex-col justify-center items-center text-center p-4">
                  <div className="w-12 h-12 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center text-2xl mb-3 group-hover:scale-110 transition-transform">🔍</div>
                  <h4 className="font-bold text-gray-900">食物库</h4>
                  <p className="text-xs text-gray-500 mt-1">查询营养成分</p>
                </div>
              </Card>
            </div>
          )}
        </div>

        {/* 营养摄入仪表盘 */}
        <div className="mb-10">
          <h3 className="text-xl font-bold text-gray-800 mb-6 flex items-center">
            <span className="w-1.5 h-6 bg-primary-500 rounded-full mr-3"></span>
            今日营养摄入
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <NutritionCard
              title="卡路里"
              icon="🔥"
              current={data?.todayNutrition?.totalCalories || 0}
              target={data?.userProfile?.dailyCalorieGoal || 2000}
              unit="kcal"
              color="text-orange-500"
              progressColor="bg-gradient-to-r from-orange-400 to-red-500"
            />
            <NutritionCard
              title="蛋白质"
              icon="💪"
              current={data?.todayNutrition?.totalProtein || 0}
              target={data?.userProfile?.dailyProteinGoal || 80}
              unit="g"
              color="text-blue-500"
              progressColor="bg-gradient-to-r from-blue-400 to-indigo-500"
            />
            <NutritionCard
              title="碳水化合物"
              icon="🌾"
              current={data?.todayNutrition?.totalCarbohydrate || 0}
              target={data?.userProfile?.dailyCarbGoal || 250}
              unit="g"
              color="text-yellow-500"
              progressColor="bg-gradient-to-r from-yellow-400 to-amber-500"
            />
            <NutritionCard
              title="脂肪"
              icon="🧈"
              current={data?.todayNutrition?.totalFat || 0}
              target={data?.userProfile?.dailyFatGoal || 55}
              unit="g"
              color="text-purple-500"
              progressColor="bg-gradient-to-r from-purple-400 to-pink-500"
            />
          </div>
        </div>

        {/* 今日记录列表 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2">
            <Card className="h-full">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-gray-900">饮食时间轴</h3>
                <Button variant="ghost" size="sm" onClick={() => navigate('/diet-history')}>
                  查看历史 →
                </Button>
              </div>

              {data?.todayRecords && data.todayRecords.length > 0 ? (
                <div className="space-y-4 relative before:absolute before:left-6 before:top-2 before:bottom-2 before:w-0.5 before:bg-gray-100">
                  {data.todayRecords.map((record, index) => (
                    <div key={index} className="relative pl-14 group">
                      <div className="absolute left-3 top-3 w-6 h-6 bg-white border-4 border-primary-100 rounded-full z-10 group-hover:border-primary-400 transition-colors"></div>
                      <div className="bg-gray-50 rounded-xl p-4 hover:bg-white hover:shadow-md transition-all border border-gray-100 group-hover:border-primary-100 cursor-pointer" onClick={() => navigate('/diet-log')}>
                        <div className="flex justify-between items-start">
                          <div>
                            <div className="flex items-center gap-2 mb-1">
                              <span className="text-xl">{mealTypeEmojis[record.mealType]}</span>
                              <span className="font-bold text-gray-900">{mealTypeNames[record.mealType]}</span>
                              <span className="text-xs px-2 py-0.5 bg-gray-200 text-gray-600 rounded-full">已记录</span>
                            </div>
                            <div className="text-gray-600 font-medium flex flex-wrap gap-1">
                              {record.notes?.split(/[,，、]/).map((food: string, idx: number) => {
                                const cleanFood = food.trim().replace(/^(早餐|午餐|晚餐|加餐)[::：]\s*/, '');
                                if (!cleanFood) return null;
                                // 估算分量
                                const name = cleanFood;
                                let portion = 100;
                                if (name.includes('饭') || name.includes('面') || name.includes('粥')) portion = 200;
                                else if (name.includes('汤') || name.includes('水') || name.includes('奶') || name.includes('茶')) portion = 250;
                                else if (name.includes('菜') || name.includes('瓜') || name.includes('萝卜')) portion = 150;
                                else if (name.includes('肉') || name.includes('鱼') || name.includes('鸡')) portion = 100;
                                else if (name.includes('蛋')) portion = 50;
                                return (
                                  <span key={idx} className="bg-gray-100 px-2 py-0.5 rounded text-sm">
                                    {cleanFood}<span className="text-gray-400 ml-1 text-xs">{portion}g</span>
                                  </span>
                                );
                              })}
                            </div>
                          </div>
                          <div className="text-right">
                            <span className="text-lg font-bold text-primary-600">{record.totalCalories}</span>
                            <span className="text-xs text-gray-400 block">kcal</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-8">
                  {/* 当前时段建议 */}
                  <div className="text-center mb-6">
                    <div className="text-5xl mb-3">
                      {new Date().getHours() < 10 ? '🌅' : new Date().getHours() < 14 ? '☀️' : new Date().getHours() < 18 ? '🌤️' : '🌙'}
                    </div>
                    <h4 className="text-lg font-bold text-gray-800 mb-1">
                      {new Date().getHours() < 10 ? '早餐时间' : new Date().getHours() < 14 ? '午餐时间' : new Date().getHours() < 18 ? '下午茶时间' : '晚餐时间'}
                    </h4>
                    <p className="text-gray-500 text-sm">今天还没有记录，来添加第一餐吧！</p>
                  </div>

                  {/* 操作按钮 */}
                  <div className="flex gap-3 justify-center">
                    <Button onClick={() => navigate('/diet-log')}>
                      📝 手动记录饮食
                    </Button>
                    <Button variant="outline" onClick={() => navigate('/smart-recommendation')}>
                      🤖 获取 AI 推荐
                    </Button>
                  </div>
                </div>
              )}
            </Card>
          </div>

          <div className="lg:col-span-1 space-y-4">
            {/* 健康贴士卡片 */}
            <Card className="bg-gradient-to-b from-blue-50 to-white border-blue-100">
              <h3 className="text-lg font-bold text-gray-900 mb-4">健康贴士</h3>
              <div className="bg-white rounded-xl p-4 shadow-sm border border-blue-100 mb-4">
                <div className="text-blue-500 font-bold mb-1 text-sm">💡 每日一贴</div>
                <p className="text-gray-600 text-sm leading-relaxed">
                  保持充足的水分摄入（约2000ml/天）有助于提升新陈代谢，加速脂肪燃烧。
                </p>
              </div>

              {/* 更多功能入口 */}
              <div className="space-y-2">
                <Button variant="ghost" className="w-full justify-start text-gray-600 hover:text-primary-600 hover:bg-white" onClick={() => navigate('/health-goal')}>
                  <span className="mr-2">🎯</span> 调整健康目标
                </Button>
                <Button variant="ghost" className="w-full justify-start text-gray-600 hover:text-primary-600 hover:bg-white" onClick={() => navigate('/settings')}>
                  <span className="mr-2">⚙️</span> 个人设置
                </Button>
              </div>
            </Card>
          </div>
        </div>

        {/* 方案弹窗 */}
        {showPlanDialog && dailyPlan && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fadeIn">
            <div className="bg-white rounded-3xl max-w-3xl w-full p-8 max-h-[90vh] overflow-y-auto shadow-2xl scale-100 animate-slideUp">
              <div className="text-center mb-8">
                <div className="inline-block p-3 bg-green-100 rounded-full mb-4">
                  <span className="text-4xl block">🎉</span>
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-2">今日饮食方案已生成</h3>
                <p className="text-gray-500">AI 已为您规划好个性化营养菜单</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                {['breakfast', 'lunch', 'dinner'].map((meal, idx) => (
                  <div key={meal} className={`rounded-xl p-5 border ${meal === 'breakfast' ? 'bg-orange-50 border-orange-100' :
                    meal === 'lunch' ? 'bg-green-50 border-green-100' :
                      'bg-blue-50 border-blue-100'
                    }`}>
                    <div className="text-center mb-3">
                      <span className="text-3xl block mb-2">{['🍳', '🍱', '🍲'][idx]}</span>
                      <h4 className="font-bold text-gray-800">{['早餐', '午餐', '晚餐'][idx]}</h4>
                    </div>
                    <div className="space-y-2">
                      {dailyPlan[meal]?.map((food: any, i: number) => (
                        <div key={i} className="text-center py-2 bg-white/80 rounded-lg text-sm font-medium text-gray-700 shadow-sm">
                          {food.food_name}
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>

              <div className="flex gap-4">
                <Button variant="outline" className="flex-1" onClick={() => setShowPlanDialog(false)}>
                  稍后再看
                </Button>
                <Button className="flex-1" onClick={() => { setShowPlanDialog(false); navigate('/smart-recommendation'); }}>
                  查看详情并应用
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* 食物详情弹窗 */}
        {selectedFood && (
          <FoodDetailModal
            foodName={selectedFood}
            onClose={() => setSelectedFood(null)}
          />
        )}
      </div>
    </div >
  );
};

// 辅助组件：营养卡片
const NutritionCard: React.FC<{
  title: string; icon: string; current: number; target: number; unit: string; color: string; progressColor: string;
}> = ({ title, icon, current, target, unit, color, progressColor }) => {
  const percentage = Math.min((current / target) * 100, 100);

  return (
    <Card className="border-gray-100 shadow-sm hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <div>
          <p className="text-gray-500 text-sm font-medium mb-1">{title}</p>
          <h4 className="text-2xl font-bold text-gray-900">
            {current} <span className="text-sm text-gray-400 font-normal">/ {target}{unit}</span>
          </h4>
        </div>
        <span className="text-2xl bg-gray-50 p-2 rounded-lg">{icon}</span>
      </div>
      <div className="relative h-2.5 bg-gray-100 rounded-full overflow-hidden">
        <div
          className={`absolute top-0 left-0 h-full rounded-full ${progressColor} transition-all duration-1000 ease-out`}
          style={{ width: `${percentage}%` }}
        ></div>
      </div>
      <div className="mt-2 text-xs text-right text-gray-500">
        已摄入 <span className={`font-bold ${color}`}>{Math.round(percentage)}%</span>
      </div>
    </Card>
  );
};

export default NewHomePage;

