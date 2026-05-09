import React, { useState, useEffect, useCallback } from 'react';
import api from '../services/api';

interface MealStatus { breakfast: boolean; lunch: boolean; dinner: boolean; }
interface CalendarDay { date: string; count: number; }
interface CheckinStatus {
  meals: MealStatus;
  checkedToday: boolean;
  todayCount: number;
  streak: number;
  totalDays: number;
  checkinCalendar: CalendarDay[];
}

const MEALS = [
  { key: 'breakfast', emoji: '🌅', title: '早餐', desc: '开启活力一天' },
  { key: 'lunch', emoji: '☀️', title: '午餐', desc: '补充能量时刻' },
  { key: 'dinner', emoji: '🌙', title: '晚餐', desc: '舒缓身心' },
] as const;

const MOODS = [
  { key: 'great', emoji: '😄', label: '超棒' },
  { key: 'good', emoji: '😊', label: '不错' },
  { key: 'normal', emoji: '😐', label: '一般' },
  { key: 'bad', emoji: '😔', label: '不太好' },
];

const CheckinPage: React.FC = () => {
  const [status, setStatus] = useState<CheckinStatus | null>(null);
  const [ranking, setRanking] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [pendingPlan, setPendingPlan] = useState<any>(null);
  const [checkinLoading, setCheckinLoading] = useState<string | null>(null);
  const [mood, setMood] = useState('good');
  const [note, setNote] = useState('');
  const [showSuccess, setShowSuccess] = useState('');

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [statusRes, rankRes, planRes]: any[] = await Promise.all([
        api.get('/api/user/diet/checkin/status'),
        api.get('/api/user/diet/checkin/ranking'),
        api.get('/api/user/diet/my-recommendations', { params: { days: 1 } })
      ]);
      if (statusRes.code === 200) setStatus(statusRes.data);
      if (rankRes.code === 200) setRanking(rankRes.data || []);
      if (planRes.code === 200 && planRes.data?.length > 0) {
        const plan = planRes.data.find((p: any) => p.isAccepted === '2');
        if (plan) setPendingPlan(plan);
      }
    } catch (e) {
      console.error('加载打卡数据失败', e);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const handleCheckin = async (mealType: string) => {
    try {
      setCheckinLoading(mealType);
      
      // 如果有待执行的AI方案，先按餐次执行
      if (pendingPlan) {
         const mealCode = mealType === 'breakfast' ? '0' : mealType === 'lunch' ? '1' : '2';
         try {
            await api.post('/api/user/diet/plan/execute', { 
                recommendationId: pendingPlan.recognitionId,
                mealType: mealCode
            });
         } catch(e) {
            console.error('执行计划失败', e);
         }
      }
      
      const res: any = await api.post('/api/user/diet/checkin', { mealType, mood, note });
      if (res.code === 200) {
        const mealTitle = mealType === 'breakfast' ? '早餐' : mealType === 'lunch' ? '午餐' : '晚餐';
        setShowSuccess(mealTitle);
        setTimeout(() => setShowSuccess(''), 3000);
        await loadData();
      }
    } catch (e: any) {
      alert('打卡失败：' + (e.message || '未知错误'));
    } finally {
      setCheckinLoading(null);
    }
  };

  const currentCount = status?.todayCount || 0;
  const progress = (currentCount / 3) * 100;

  const getMealRecommendation = (mealKey: string) => {
    if (!pendingPlan?.recommendedFoods) return null;
    const foodsStr = pendingPlan.recommendedFoods;
    if (mealKey === 'breakfast' && foodsStr.includes('早餐')) {
      const s = foodsStr.substring(foodsStr.indexOf('早餐:'), foodsStr.includes('午餐') ? foodsStr.indexOf('午餐') : foodsStr.length);
      return s.replace('早餐:', '').trim();
    }
    if (mealKey === 'lunch' && foodsStr.includes('午餐')) {
      const s = foodsStr.substring(foodsStr.indexOf('午餐:'), foodsStr.includes('晚餐') ? foodsStr.indexOf('晚餐') : foodsStr.length);
      return s.replace('午餐:', '').trim();
    }
    if (mealKey === 'dinner' && foodsStr.includes('晚餐')) {
      const s = foodsStr.substring(foodsStr.indexOf('晚餐:'));
      return s.replace('晚餐:', '').trim();
    }
    return null;
  };

  const renderCalendar = () => {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    const countMap = new Map<string, number>();
    status?.checkinCalendar?.forEach(d => countMap.set(d.date, d.count));

    const cells: React.ReactNode[] = [];
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

    weekDays.forEach(d => cells.push(
      <div key={'h-' + d} className="text-center text-[10px] sm:text-xs font-bold text-gray-400 py-2">{d}</div>
    ));
    for (let i = 0; i < firstDay; i++) cells.push(<div key={'e-' + i} />);

    for (let d = 1; d <= daysInMonth; d++) {
      const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const cnt = countMap.get(dateStr) || 0;
      const isToday = d === now.getDate();

      let bgClass = 'bg-transparent text-gray-500 hover:bg-gray-100';
      if (cnt === 3) bgClass = 'bg-green-500 text-white font-bold shadow-sm';
      else if (cnt === 2) bgClass = 'bg-green-200 text-green-900 font-bold';
      else if (cnt === 1) bgClass = 'bg-green-50 text-green-800 font-bold';

      const todayRing = isToday ? 'border-2 border-black font-bold' : 'border border-transparent';

      cells.push(
        <div key={d} className="flex items-center justify-center p-1">
          <div className={`w-8 h-8 sm:w-10 sm:h-10 flex items-center justify-center rounded-full text-xs sm:text-sm transition-all ${bgClass} ${todayRing}`}>
            {d}
          </div>
        </div>
      );
    }

    return (
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, minmax(0, 1fr))', rowGap: '4px' }}>
        {cells}
      </div>
    );
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <h2 className="text-xl font-bold text-gray-500 animate-pulse tracking-widest">LOADING...</h2>
      </div>
    );
  }

  return (
    <div className="animate-fadeIn space-y-6">

        {showSuccess && (
          <div className="fixed top-8 left-1/2 -translate-x-1/2 z-50 bg-black text-white px-6 py-3 rounded-xl shadow-2xl text-sm font-bold flex items-center gap-2">
            ✓ {showSuccess} 打卡成功
          </div>
        )}

        {/* 顶部概览卡片 (防塌陷布局) */}
        <div className="bg-white rounded-3xl p-6 sm:p-10 shadow-sm border border-gray-100 flex flex-col md:flex-row justify-between break-all md:break-normal gap-8">
          <div className="flex-1 min-w-[200px] flex flex-col justify-center">
            <h1 className="text-2xl sm:text-3xl font-extrabold text-black mb-2 flex flex-wrap items-center gap-3" style={{ whiteSpace: 'nowrap' }}>
              <span>今日目标</span>
              {currentCount === 3 && <span className="text-xs bg-green-100 text-green-700 px-3 py-1 rounded-full uppercase tracking-wider">Completed</span>}
            </h1>
            <p className="text-gray-500 text-sm sm:text-base font-medium mb-6">您已完成 {currentCount} 顿饮食打卡</p>

            <div className="w-full max-w-sm h-2 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-black rounded-full"
                style={{ width: `${progress}%`, transition: 'width 0.5s ease-out' }}
              />
            </div>
          </div>

          <div className="flex flex-row gap-8 shrink-0 pb-2 items-center">
            <div>
              <div className="text-xs text-gray-400 font-bold uppercase tracking-widest mb-1">连续打卡</div>
              <div className="text-4xl font-black text-black" style={{ whiteSpace: 'nowrap' }}>{status?.streak || 0} <span className="text-sm text-gray-400">天</span></div>
            </div>
            <div className="w-px h-12 bg-gray-100 hidden md:block"></div>
            <div>
              <div className="text-xs text-gray-400 font-bold uppercase tracking-widest mb-1">累计天数</div>
              <div className="text-4xl font-black text-black" style={{ whiteSpace: 'nowrap' }}>{status?.totalDays || 0} <span className="text-sm text-gray-400">天</span></div>
            </div>
          </div>
        </div>

        {/* 三餐打卡卡片 (安全的基础类) */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {MEALS.map(meal => {
            const checked = status?.meals?.[meal.key as keyof MealStatus] || false;
            const isLoading = checkinLoading === meal.key;

            return (
              <div key={meal.key} className={`flex flex-col p-6 sm:p-8 rounded-3xl border ${checked ? 'bg-green-50/50 border-green-200' : 'bg-white border-gray-200 shadow-sm hover:border-gray-300 hover:shadow-md'
                }`}>

                <div className="flex justify-between items-center mb-6">
                  <div className="text-5xl">{meal.emoji}</div>
                  {checked && (
                    <div className="w-8 h-8 rounded-full bg-green-500 text-white flex items-center justify-center font-bold">
                      ✓
                    </div>
                  )}
                </div>

                <h3 className="text-xl font-extrabold text-black mb-2">{meal.title}</h3>
                <p className={`text-sm font-medium mb-8 flex-1 ${checked ? 'text-green-700' : 'text-gray-500'}`}>
                  {checked 
                    ? '已记录您的营养摄入' 
                    : (getMealRecommendation(meal.key) ? (
                         <span className="text-amber-600 font-bold">
                           智能计划：{getMealRecommendation(meal.key)?.split(/[,，、]/).join(' · ')}
                         </span>
                       ) : meal.desc)
                  }
                </p>

                {!checked ? (
                  <button
                    onClick={() => handleCheckin(meal.key)}
                    disabled={isLoading}
                    className="w-full py-4 rounded-xl text-base font-bold text-white bg-black hover:bg-gray-800 disabled:opacity-50 transition-all flex items-center justify-center shadow-md cursor-pointer"
                    style={{ backgroundColor: '#000', color: '#fff' }}
                  >
                    {isLoading ? '记载中...' : '标记已吃'}
                  </button>
                ) : (
                  <div className="w-full py-4 rounded-xl text-base font-bold text-green-800 bg-green-100 text-center">
                    打卡完成
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* 随餐手记 */}
        {status && currentCount < 3 && (
          <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-sm border border-gray-100">
            <h3 className="text-lg font-extrabold text-black mb-5">随餐手记</h3>

            <div className="flex flex-wrap gap-3 mb-6">
              {MOODS.map(m => (
                <button key={m.key} onClick={() => setMood(m.key)} className={`px-5 py-3 rounded-xl text-sm font-bold transition-all border ${mood === m.key
                  ? 'bg-black border-black text-white shadow-md'
                  : 'bg-white border-gray-200 text-gray-500 hover:border-gray-400'
                  }`}>
                  <span className="mr-2 text-lg">{m.emoji}</span>{m.label}
                </button>
              ))}
            </div>

            <input
              type="text" placeholder="记录一下刚才吃的美食或者心得体会..."
              value={note} onChange={e => setNote(e.target.value)}
              className="w-full bg-gray-50 border border-gray-200 focus:bg-white focus:border-black rounded-xl px-5 py-4 text-base font-medium text-black transition-all outline-none placeholder-gray-400"
            />
          </div>
        )}

        {/* 底部功能区：热力图 & 排行榜 */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">

          <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-sm border border-gray-100">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-lg font-extrabold text-black">{new Date().getFullYear()}年{new Date().getMonth() + 1}月</h3>
              <div className="flex items-center gap-4 text-xs font-bold text-gray-400">
                <span className="flex items-center gap-1.5"><div className="w-3 h-3 rounded-md bg-green-200"></div> 轻度</span>
                <span className="flex items-center gap-1.5"><div className="w-3 h-3 rounded-md bg-green-500"></div> 圆满</span>
              </div>
            </div>
            {renderCalendar()}
          </div>

          <div className="bg-white rounded-3xl p-6 sm:p-8 shadow-sm border border-gray-100 flex flex-col">
            <div className="flex justify-between items-center border-b border-gray-100 pb-4 mb-4">
              <h3 className="text-lg font-extrabold text-black">打卡坚持榜</h3>
              <span className="text-xs font-bold text-gray-500 bg-gray-100 px-3 py-1.5 rounded-lg">TOP 20</span>
            </div>

            {ranking.length === 0 ? (
              <div className="flex-1 flex flex-col items-center justify-center text-gray-400 py-10">
                <span className="text-sm font-bold">暂无排名数据</span>
              </div>
            ) : (
              <div className="flex-1 overflow-y-auto pr-2" style={{ maxHeight: '280px' }}>
                <div className="space-y-2">
                  {ranking.map((item: any, idx: number) => {
                    const isTop1 = idx === 0;
                    return (
                      <div key={item.userId} className={`flex items-center p-3 rounded-2xl transition-colors ${isTop1 ? 'bg-gray-50 text-black border border-gray-100' : 'text-gray-600 hover:bg-gray-50'}`}>
                        <div className={`w-10 h-10 flex items-center justify-center rounded-full text-sm font-bold ${isTop1 ? 'bg-black text-white' : 'bg-gray-100 text-gray-500'}`}>
                          {idx + 1}
                        </div>
                        <div className="flex-1 ml-4 overflow-hidden">
                          <div className={`text-base truncate ${isTop1 ? 'font-extrabold' : 'font-bold'}`}>{item.userName}</div>
                          <div className="text-xs text-gray-400 mt-0.5 font-medium">累计 {item.totalDays} 天</div>
                        </div>
                        <div className="text-right pl-4">
                          <div className={`text-xl font-black ${isTop1 ? 'text-black' : 'text-gray-800'}`}>{item.streak}</div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>
    </div>
  );
};

export default CheckinPage;
