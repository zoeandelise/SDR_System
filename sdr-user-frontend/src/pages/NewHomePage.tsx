import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api, { dashboardApi } from '../services/api';
import FoodDetailModal from '../components/FoodDetailModal';
import { useToast } from '../components/ui/Toast';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { ChevronRight, Flame, Wheat, Droplets, Lightbulb, ArrowRight } from 'lucide-react';

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

const healthTips = [
  '保持充足的水分摄入（约2000ml/天）有助于提升新陈代谢，加速脂肪燃烧。',
  '每餐先吃蔬菜再吃主食，可以有效降低餐后血糖波动。',
  '蛋白质摄入建议分散到每餐，每餐20-30g更有利于肌肉合成。',
  '晚餐建议在睡前3小时完成，有助于消化和睡眠质量。',
  '每周至少安排1天"欺骗餐"，适度放松有助于长期坚持健康饮食。',
  '深色蔬菜的营养密度通常高于浅色蔬菜，建议每餐至少一种深色蔬菜。',
];

const NewHomePage: React.FC = () => {
  const navigate = useNavigate();
  const { showToast } = useToast();
  const [data, setData] = useState<DashboardData | null>(null);
  const [pendingPlans, setPendingPlans] = useState<any[]>([]);
  const [executingPlan, setExecutingPlan] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedFood, setSelectedFood] = useState<string | null>(null);
  const [tipIndex, setTipIndex] = useState(0);

  useEffect(() => {
    loadDashboardData();
    setTipIndex(Math.floor(Math.random() * healthTips.length));
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [dashRes, planRes]: any = await Promise.all([
        dashboardApi.getDashboardData(),
        api.get('/api/user/diet/my-recommendations', { params: { days: 1 } }).catch(() => ({ code: 500, data: [] }))
      ]);

      if (dashRes.code === 200 && dashRes.data) {
        setData(dashRes.data);
      } else {
        throw new Error(dashRes.msg || '加载失败');
      }

      if (planRes.code === 200 && planRes.data) {
        const unapplied = planRes.data.filter((r: any) => r.isAccepted === '2');
        setPendingPlans(unapplied);
      } else {
        setPendingPlans([]);
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

  const handleExecutePlan = async (recommendationId: number) => {
    try {
      setExecutingPlan(recommendationId);
      const response: any = await api.post('/api/user/diet/plan/execute', { recommendationId });
      if (response.code === 200) {
        showToast('success', '打卡成功！热量已计入今日摄入。');
        await loadDashboardData();
      } else {
        showToast('error', response.msg || '打卡失败');
      }
    } catch (err: any) {
      showToast('error', err.response?.data?.msg || err.message || '打卡失败');
    } finally {
      setExecutingPlan(null);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin mx-auto" />
          <p className="mt-4 text-sm text-gray-600">加载中...</p>
        </div>
      </div>
    );
  }

  const nutrition = data?.todayNutrition;
  const profile = data?.userProfile;
  const caloriePercent = Math.min(((nutrition?.totalCalories || 0) / (profile?.dailyCalorieGoal || 2000)) * 100, 100);
  const proteinPercent = Math.min(((nutrition?.totalProtein || 0) / (profile?.dailyProteinGoal || 80)) * 100, 100);
  const carbPercent = Math.min(((nutrition?.totalCarbohydrate || 0) / (profile?.dailyCarbGoal || 250)) * 100, 100);
  const fatPercent = Math.min(((nutrition?.totalFat || 0) / (profile?.dailyFatGoal || 55)) * 100, 100);

  return (
    <div className="space-y-6 animate-fadeIn">
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex items-center justify-between">
          <span className="text-sm text-red-800">{error}</span>
          <button onClick={() => setError('')} className="text-red-500 hover:text-red-700 font-bold">×</button>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="md:col-span-2 relative overflow-hidden rounded-2xl bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 shadow-lg border border-emerald-100">
        <div className="absolute top-0 right-0 w-48 h-48 bg-emerald-200/40 rounded-full blur-3xl -mr-16 -mt-16" />
        <div className="absolute bottom-0 left-0 w-32 h-32 bg-teal-200/30 rounded-full blur-2xl -ml-8 -mb-8" />
        <div className="absolute top-1/2 left-1/2 w-64 h-64 bg-cyan-100/20 rounded-full blur-3xl -translate-x-1/2 -translate-y-1/2" />
        <div className="relative p-6">
          <div className="flex items-start justify-between">
            <div>
              <p className="text-emerald-700 text-base font-medium">
                {new Date().getHours() < 12 ? '早上好' : new Date().getHours() < 18 ? '下午好' : '晚上好'}，
              </p>
              <h2 className="text-3xl font-bold mt-1 text-gray-900">{profile?.userName || '用户'}</h2>
            </div>
            <div className="flex gap-3">
              <div className="bg-white/80 backdrop-blur rounded-xl px-5 py-3 text-center shadow-sm border border-emerald-100">
                <div className="text-xs text-emerald-600 font-semibold">连续</div>
                <div className="text-2xl font-bold text-gray-900">{profile?.continuousDays || 0}<span className="text-sm font-normal ml-1 text-gray-600">天</span></div>
              </div>
              <div className="bg-white/80 backdrop-blur rounded-xl px-5 py-3 text-center shadow-sm border border-emerald-100">
                <div className="text-xs text-emerald-600 font-semibold">评分</div>
                <div className="text-2xl font-bold text-gray-900">{profile?.healthScore || 0}</div>
              </div>
            </div>
          </div>

          <div className="mt-6 bg-white/70 backdrop-blur rounded-2xl p-5 border border-emerald-100">
            <div className="flex items-center justify-between mb-1">
              <span className="text-sm text-gray-700 font-semibold">今日热量摄入</span>
              <span className="text-xs text-gray-500 font-medium">
                目标 {profile?.dailyCalorieGoal || 2000} kcal
              </span>
            </div>
            <div className="flex items-baseline gap-2 mb-3">
              <span className="text-3xl font-black text-emerald-600">
                {nutrition?.totalCalories || 0}
              </span>
              <span className="text-sm text-gray-500">
                / {profile?.dailyCalorieGoal || 2000} kcal
              </span>
              {(nutrition?.totalCalories || 0) > 0 && (
                <span className={`text-xs px-2 py-0.5 rounded-md font-bold ${caloriePercent >= 100 ? 'bg-red-100 text-red-600' : caloriePercent >= 80 ? 'bg-amber-100 text-amber-700' : 'bg-emerald-100 text-emerald-700'}`}>
                  {caloriePercent >= 100 ? '已超标' : `还剩 ${Math.round((profile?.dailyCalorieGoal || 2000) - (nutrition?.totalCalories || 0))} kcal`}
                </span>
              )}
            </div>
            <div
              className="w-full h-4 rounded-full overflow-hidden border border-gray-200 shadow-inner"
              style={{ backgroundColor: '#e5e7eb' }}
            >
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{
                  width: `${Math.min(Math.max(caloriePercent, 0), 100)}%`,
                  backgroundColor: caloriePercent >= 100 ? '#ef4444' : caloriePercent >= 80 ? '#f59e0b' : '#10b981',
                  minWidth: caloriePercent > 0 ? 8 : undefined,
                }}
              />
            </div>
            <div className="flex justify-between text-[10px] text-gray-400 mt-1 font-medium">
              <span>0</span>
              <span>{Math.round((profile?.dailyCalorieGoal || 2000) / 2)}</span>
              <span>{profile?.dailyCalorieGoal || 2000}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <NutritionPill
          icon={<Flame className="w-5 h-5" />}
          label="蛋白质"
          current={nutrition?.totalProtein || 0}
          target={profile?.dailyProteinGoal || 80}
          unit="g"
          percent={proteinPercent}
          color="#2563eb"
          bgColor="bg-blue-50"
          textColor="text-blue-700"
        />
        <NutritionPill
          icon={<Wheat className="w-5 h-5" />}
          label="碳水"
          current={nutrition?.totalCarbohydrate || 0}
          target={profile?.dailyCarbGoal || 250}
          unit="g"
          percent={carbPercent}
          color="#f97316"
          bgColor="bg-amber-50"
          textColor="text-amber-700"
        />
        <NutritionPill
          icon={<Droplets className="w-5 h-5" />}
          label="脂肪"
          current={nutrition?.totalFat || 0}
          target={profile?.dailyFatGoal || 55}
          unit="g"
          percent={fatPercent}
          color="#7c3aed"
          bgColor="bg-purple-50"
          textColor="text-purple-700"
        />
      </div>
      </div>

      <div>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-bold text-gray-900">今日饮食</h3>
          <button onClick={() => navigate('/diet-log')} className="text-sm text-emerald-600 font-semibold hover:text-emerald-700 flex items-center gap-1">
            记录饮食 <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {(data?.todayRecords && data.todayRecords.length > 0) || pendingPlans.length > 0 ? (
          <div className="space-y-3">
            {pendingPlans.map((plan, index) => {
              const foods = plan.recommendedFoods || '';
              const bk = foods.includes('早餐') ? foods.substring(foods.indexOf('早餐:'), foods.includes('午餐') ? foods.indexOf('午餐') : foods.length).replace('早餐:', '').trim() : '';
              const lh = foods.includes('午餐') ? foods.substring(foods.indexOf('午餐:'), foods.includes('晚餐') ? foods.indexOf('晚餐') : foods.length).replace('午餐:', '').trim() : '';
              const dn = foods.includes('晚餐') ? foods.substring(foods.indexOf('晚餐:')).replace('晚餐:', '').trim() : '';
              return (
              <Card key={`plan-${index}`} className="border border-gray-200 shadow-sm bg-white" hoverEffect={false}>
                <div className="flex items-center gap-4 p-4">
                  <div className="w-12 h-12 rounded-xl bg-black flex items-center justify-center text-2xl flex-shrink-0 shadow-inner">
                    🧠
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="font-extrabold text-black text-base">全天智能饮食方案</span>
                      <span className="text-[10px] px-2 py-0.5 bg-black text-white rounded-md font-bold">
                        未打卡
                      </span>
                    </div>
                    <div className="text-xs font-medium text-gray-500 space-y-1">
                      {bk && <div className="truncate"><span className="font-bold text-gray-800">早:</span> {bk}</div>}
                      {lh && <div className="truncate"><span className="font-bold text-gray-800">午:</span> {lh}</div>}
                      {dn && <div className="truncate"><span className="font-bold text-gray-800">晚:</span> {dn}</div>}
                    </div>
                  </div>
                  <div className="flex-shrink-0">
                    <Button 
                      size="sm" 
                      onClick={() => navigate('/checkin')}
                      className="bg-black hover:bg-gray-800 text-white shadow-md transition-all rounded-xl font-bold px-4 py-2"
                    >
                      去打卡
                    </Button>
                  </div>
                </div>
              </Card>
            )})}
            {data?.todayRecords?.map((record, index) => (
              <Card key={index} className="border-0 shadow-sm hover:shadow-md transition-shadow" hoverEffect={false}>
                <div className="flex items-center gap-4 p-4">
                  <div className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center text-2xl flex-shrink-0">
                    {mealTypeEmojis[record.mealType]}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-gray-900 text-base">{mealTypeNames[record.mealType]}</span>
                      <span className="text-xs px-2 py-0.5 bg-emerald-100 text-emerald-700 rounded-md font-semibold">已记录</span>
                    </div>
                    <div className="text-sm text-gray-600 mt-1 truncate">
                      {record.notes?.split(/[,，、]/).map((food: string) => {
                        const clean = food.trim().replace(/^(早餐|午餐|晚餐|加餐)[::：]\s*/, '');
                        return clean;
                      }).filter(Boolean).join(' · ')}
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <div className="text-base font-bold text-gray-900">{record.totalCalories}</div>
                    <div className="text-sm text-gray-600">kcal</div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <Card className="border-0 shadow-sm" hoverEffect={false}>
            <div className="p-8 text-center">
              <div className="text-5xl mb-4">
                {new Date().getHours() < 10 ? '🌅' : new Date().getHours() < 14 ? '☀️' : new Date().getHours() < 18 ? '🌤️' : '🌙'}
              </div>
              <p className="text-base text-gray-600 mb-4">
                {new Date().getHours() < 10 ? '早餐时间到了，开始记录吧' :
                 new Date().getHours() < 14 ? '午餐时间，别忘了记录' :
                 new Date().getHours() < 18 ? '下午茶时间' : '晚餐时间，记录今天的最后一餐'}
              </p>
              <Button size="sm" onClick={() => navigate('/diet-log')}>📝 记录饮食</Button>
            </div>
          </Card>
        )}
      </div>

      <Card className="border border-indigo-200 bg-indigo-50" hoverEffect={false}>
        <div className="p-6">
          <div className="flex items-center gap-2 mb-3">
            <Lightbulb className="w-5 h-5 text-indigo-700" />
            <span className="text-base font-bold text-indigo-800">每日健康贴士</span>
          </div>
          <p className="text-base text-gray-800 leading-relaxed">{healthTips[tipIndex]}</p>
          <button
            onClick={() => setTipIndex((tipIndex + 1) % healthTips.length)}
            className="mt-4 text-sm text-indigo-700 font-semibold hover:text-indigo-900 transition-colors flex items-center gap-1"
          >
            换一条 <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </Card>

      {selectedFood && (
        <FoodDetailModal foodName={selectedFood} onClose={() => setSelectedFood(null)} />
      )}
    </div>
  );
};

const NutritionPill: React.FC<{
  icon: React.ReactNode;
  label: string;
  current: number;
  target: number;
  unit: string;
  percent: number;
  color: string;
  bgColor: string;
  textColor: string;
}> = ({ icon, label, current, target, unit, percent, color, bgColor, textColor }) => (
  <div className={`${bgColor} rounded-2xl p-4`}>
    <div className="flex items-center gap-2 mb-2">
      <div className={`${textColor} p-1.5 rounded-lg bg-white/60 shadow-sm flex items-center justify-center`}>{icon}</div>
      <span className={`text-sm font-bold ${textColor}`}>{label}</span>
    </div>
    <div className="flex items-baseline gap-1">
      <span className="text-xl font-bold text-gray-900">{Math.round(current)}</span>
      <span className="text-sm text-gray-600">/ {target}{unit}</span>
    </div>
    <div className="w-full h-2 bg-gray-300 rounded-full mt-3 overflow-hidden shadow-inner">
      <div
        className="h-full rounded-full transition-all duration-700 shadow-sm"
        style={{ width: `${percent}%`, backgroundColor: color }}
      />
    </div>
  </div>
);

export default NewHomePage;
