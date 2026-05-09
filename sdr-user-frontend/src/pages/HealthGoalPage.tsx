import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';

interface HealthGoal {
  goalId?: number;
  userId: number;
  gender?: string;
  age?: number;
  height?: number;
  weight?: number;
  occupation?: string;
  diseases?: string;
  allergies?: string;
  dietPreferences?: string;
  dailyCalorieGoal: number;
  dailyProteinGoal: number;
  dailyCarbGoal: number;
  dailyFatGoal: number;
  targetWeight?: number;
  healthGoal: string;
  portionPreference?: string;
}


const HealthGoalPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const [goal, setGoal] = useState<HealthGoal>({
    userId: 1,
    gender: '0',
    age: 25,
    height: 170,
    weight: 65,
    occupation: '',
    diseases: '',
    allergies: '',
    dietPreferences: '',
    dailyCalorieGoal: 2000,
    dailyProteinGoal: 100,
    dailyCarbGoal: 250,
    dailyFatGoal: 67,
    healthGoal: '1',
    portionPreference: 'normal'
  });
  const [loading, setLoading] = useState(false);

  // 如果是携带新用户标识进来的，直接开启变更为编辑模式
  const isNewUserRef = React.useRef((location.state as any)?.showNewUserWelcome);
  const [editing, setEditing] = useState(!!isNewUserRef.current);

  const [todayWeight, setTodayWeight] = useState<string>('');
  const [weightHistory, setWeightHistory] = useState<any[]>([]);
  const [weightTrend, setWeightTrend] = useState<any>(null);
  const [recordingWeight, setRecordingWeight] = useState(false);
  const { showToast } = useToast();

  const diseaseOptions = ['高血压', '糖尿病', '痛风', '高血脂', '心脏病'];
  const allergyOptions = ['海鲜', '花生', '牛奶', '鸡蛋', '坚果', '小麦'];
  const preferenceOptions = ['清淡', '素食', '低脂', '低糖', '高蛋白', '辣'];

  useEffect(() => {
    // 首次进来如果带有新用户标记，提醒
    if (isNewUserRef.current) {
      showToast('success', '欢迎来到 SDR 健康系统！为了定制专属 AI 饮食计划，请先补全您的各项身体指标。');
      // 避免重复提示
      navigate(location.pathname, { replace: true, state: {} });
    }

    loadHealthGoal();
    loadWeightTrend();
    loadWeightHistory();
  }, []);

  const loadHealthGoal = async () => {
    try {
      const response: any = await api.get('/diet/health/my');
      if (response.code === 200 && response.data) {
        const h = response.data;
        setGoal({
          userId: h.userId || 1,
          gender: h.gender || '0',
          age: h.age || 25,
          height: h.height || 170,
          weight: h.weight || 65,
          occupation: h.occupation || '',
          diseases: h.diseases || '',
          allergies: h.allergies || '',
          dietPreferences: h.dietPreferences || h.diet_preferences || '',
          dailyCalorieGoal: h.dailyCalorieGoal || h.daily_calorie_goal || 2000,
          dailyProteinGoal: h.dailyProteinGoal || h.daily_protein_goal || 100,
          dailyCarbGoal: h.dailyCarbGoal || h.daily_carb_goal || 250,
          dailyFatGoal: h.dailyFatGoal || h.daily_fat_goal || 67,
          targetWeight: h.targetWeight || h.target_weight,
          healthGoal: h.healthGoal || h.health_goal || '1'
        });
      }
    } catch (error) {
      console.error('加载健康目标失败:', error);
    }
  };


  const loadWeightTrend = async () => {
    try {
      const response: any = await api.get('/api/user/diet/weight/trend');
      if (response.code === 200) {
        setWeightTrend(response.data);
      }
    } catch (error) {
      console.error('加载体重趋势失败:', error);
    }
  };

  const loadWeightHistory = async () => {
    try {
      const response: any = await api.get('/api/user/diet/weight/history', {
        params: { days: 30 }
      });
      if (response.code === 200) {
        setWeightHistory(response.data || []);
      }
    } catch (error) {
      console.error('加载体重历史失败:', error);
    }
  };

  const handleRecordWeight = async () => {
    if (!todayWeight || parseFloat(todayWeight) <= 0) {
      showToast('warning', '请输入有效的体重');
      return;
    }

    try {
      setRecordingWeight(true);
      const response: any = await api.post('/api/user/diet/weight', {
        weight: parseFloat(todayWeight)
      });

      if (response.code === 200) {
        showToast('success', '体重记录成功！');
        setTodayWeight('');
        loadWeightTrend();
        loadWeightHistory();
        setGoal(prev => ({ ...prev, weight: parseFloat(todayWeight) }));
      } else {
        throw new Error(response.msg);
      }
    } catch (error: any) {
      showToast('error', '记录失败：' + (error.message || '未知错误'));
    } finally {
      setRecordingWeight(false);
    }
  };

  const handleSaveGoal = async () => {
    try {
      setLoading(true);
      const response: any = await api.post('/diet/health/my', goal);
      if (response.code === 200) {
        showToast('success', '健康信息保存成功！即将为您开启智能推荐之旅...');
        setEditing(false);
        loadHealthGoal();

        // 延迟跳转以让用户看清成功提示
        setTimeout(() => {
          navigate('/smart-recommendation');
        }, 1200);
      }
    } catch (error: any) {
      showToast('error', '保存失败：' + (error.response?.data?.msg || error.message));
    } finally {
      setLoading(false);
    }
  };

  const toggleTag = (field: 'diseases' | 'allergies' | 'dietPreferences', tag: string) => {
    const currentStr = goal[field] || '';
    const tags = currentStr ? currentStr.split(',') : [];

    let newTags;
    if (tags.includes(tag)) {
      newTags = tags.filter(t => t !== tag);
    } else {
      newTags = [...tags, tag];
    }

    setGoal({ ...goal, [field]: newTags.join(',') });
  };


  return (
    <div className="animate-fadeIn space-y-6">

        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
          <div>
            <h1 className="text-2xl font-extrabold text-gray-900 flex items-center gap-2">
              设置您的健康蓝图 <span className="text-2xl animate-bounce-slow">✨</span>
            </h1>
            <p className="text-gray-600 font-medium mt-1">定制专属计划，开启健康生活新篇章</p>
          </div>

          <div>
            {!editing ? (
              <button
                onClick={() => setEditing(true)}
                className="group relative px-6 py-3 bg-blue-600 text-white rounded-xl font-bold shadow-[0_4px_14px_0_rgba(37,99,235,0.39)] hover:shadow-[0_6px_20px_rgba(37,99,235,0.23)] hover:-translate-y-0.5 transition-all duration-300 overflow-hidden"
              >
                <span className="relative z-10 flex items-center gap-2">
                  <span>✏️</span> 编辑全部信息
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              </button>
            ) : (
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setEditing(false)}
                  className="px-6 py-3 bg-white border border-gray-200 text-gray-600 rounded-xl hover:bg-gray-50 hover:text-gray-900 hover:border-gray-300 font-medium transition-all shadow-sm"
                >
                  取消
                </button>
                <button
                  onClick={handleSaveGoal}
                  disabled={loading}
                  className="px-6 py-3 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl hover:shadow-lg hover:shadow-green-200 hover:-translate-y-0.5 disabled:opacity-70 disabled:cursor-not-allowed font-bold shadow-md transition-all flex items-center gap-2"
                >
                  {loading ? (
                    <>
                      <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <span>保存中...</span>
                    </>
                  ) : (
                    <>
                      <span>💾</span> 保存并生成方案
                    </>
                  )}
                </button>
              </div>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-1 bg-white rounded-2xl border border-gray-200 shadow-sm p-6 relative overflow-hidden group hover:shadow-md transition-all duration-300">
            <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50 rounded-full blur-3xl transform translate-x-10 -translate-y-10 group-hover:scale-125 transition-transform duration-700"></div>

            <div className="relative z-10 h-full flex flex-col justify-between space-y-6">
              <div>
                <h2 className="text-xl font-bold flex items-center gap-2 mb-1 text-gray-800">
                  <span className="bg-blue-100 text-blue-600 p-1.5 rounded-lg text-lg">⚖️</span> 今日体重
                </h2>
                <p className="text-gray-500 text-sm font-bold pl-9">定期记录，看见改变</p>
              </div>

              <div className="flex flex-col items-center justify-center py-4">
                <div className="relative group/input">
                  <input
                    type="number"
                    step="0.1"
                    placeholder="0.0"
                    value={todayWeight}
                    onChange={(e) => setTodayWeight(e.target.value)}
                    className="w-40 bg-transparent text-6xl font-black text-center text-gray-800 placeholder-gray-300 focus:outline-none border-b-2 border-gray-200 focus:border-blue-500 transition-all pb-2"
                  />
                  <span className="absolute bottom-4 -right-8 text-xl text-gray-600 font-bold">kg</span>
                </div>
              </div>

              <button
                onClick={handleRecordWeight}
                disabled={recordingWeight}
                className="w-full py-3.5 bg-blue-600 text-white font-bold rounded-xl hover:bg-blue-700 focus:ring-4 focus:ring-blue-100 transition-all shadow-md active:scale-95 disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2 group-active:translate-y-0.5"
              >
                {recordingWeight ? (
                  <>
                    <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span>保存中...</span>
                  </>
                ) : (
                  <><span>📝</span> 确认记录</>
                )}
              </button>
            </div>
          </div>

          <div className="md:col-span-2 bg-white rounded-2xl shadow-sm border border-gray-200 p-6 flex flex-col justify-between relative overflow-hidden">
            <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-blue-50 to-transparent rounded-full -z-10 translate-x-1/3 -translate-y-1/3"></div>

            {weightTrend ? (
              <div className="h-full flex flex-col justify-between">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-bold text-gray-800 flex items-center gap-2">
                    <span className="w-1.5 h-6 bg-blue-500 rounded-full"></span>
                    趋势概览
                  </h3>
                  <div className="px-3 py-1 bg-blue-50 text-blue-600 text-xs font-bold rounded-full border border-blue-100">
                    近30天数据
                  </div>
                </div>

                <div className="grid grid-cols-4 gap-4 mb-6">
                  <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow text-center group">
                    <div className="text-gray-500 font-medium text-xs mb-1 group-hover:text-blue-600 transition-colors">初始体重</div>
                    <div className="text-2xl font-black text-gray-900">{weightTrend.firstWeight || weightTrend.initialWeight || '-'} <span className="text-xs text-gray-500 font-medium">kg</span></div>
                  </div>
                  <div className="bg-gradient-to-br from-blue-50 to-white p-4 rounded-2xl shadow-sm border border-blue-100 hover:shadow-md transition-shadow text-center group relative overflow-hidden">
                    <div className="absolute top-0 right-0 w-8 h-8 bg-blue-100 rounded-bl-xl -mr-2 -mt-2"></div>
                    <div className="text-blue-500 text-xs mb-1 font-bold">当前体重</div>
                    <div className="text-2xl font-bold text-blue-700">{weightTrend.latestWeight || goal.weight || '-'} <span className="text-sm font-normal">kg</span></div>
                  </div>
                  <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow text-center group">
                    <div className="text-gray-500 font-medium text-xs mb-1 group-hover:text-green-600 transition-colors">目标体重</div>
                    <div className="text-2xl font-black text-gray-900">{weightTrend.targetWeight || '-'} <span className="text-xs text-gray-500 font-medium">kg</span></div>
                  </div>
                  <div className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-shadow text-center group">
                    <div className="text-gray-500 font-medium text-xs mb-1 group-hover:text-purple-600 transition-colors">累计变化</div>
                    <div className={`text-2xl font-black ${(weightTrend.totalChange || 0) <= 0 ? 'text-green-600' : 'text-orange-600'}`}>
                      {Math.abs(weightTrend.totalChange || 0)} <span className="text-xs font-medium">kg</span>
                      <span className="text-xs ml-1 block mt-1">{(weightTrend.totalChange || 0) <= 0 ? '↓ 下降' : '↑ 上升'}</span>
                    </div>
                  </div>
                </div>

                {weightHistory.length > 0 && (
                  <div className="mt-auto">
                    <div className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3 pl-1">Recent History</div>
                    <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
                      {weightHistory.slice(0, 6).map((record: any, idx: number) => (
                        <div key={idx} className="flex-shrink-0 bg-white border border-gray-100 px-4 py-2 rounded-xl text-center shadow-sm hover:border-blue-200 transition-colors min-w-[80px]">
                          <div className="text-[10px] text-gray-400 font-medium mb-0.5">{record.record_date?.slice(5)}</div>
                          <div className="text-sm font-bold text-gray-700">{record.weight}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <div className="h-40 flex items-center justify-center text-gray-400">
                <div className="text-center">
                  <div className="text-3xl mb-2">📊</div>
                  <div>暂无趋势数据</div>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-300">
            <h2 className="text-xl font-bold text-gray-800 mb-6 flex items-center gap-2">
              <span className="bg-blue-100 text-blue-600 p-1.5 rounded-lg text-lg">👤</span>
              基本信息
            </h2>
            <div className="grid grid-cols-2 gap-y-6 gap-x-4">
              <div className="col-span-1">
                <label className="text-xs text-gray-500 font-bold uppercase tracking-wide mb-1.5 block">性别</label>
                {editing ? (
                  <select
                    value={goal.gender}
                    onChange={(e) => setGoal({ ...goal, gender: e.target.value })}
                    className="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-gray-700 outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-300 transition-all text-sm"
                  >
                    <option value="0">男</option>
                    <option value="1">女</option>
                  </select>
                ) : (
                  <div className="font-bold text-gray-700 flex items-center gap-2 text-lg">
                    {goal.gender === '0' ? <span className="text-blue-500 bg-blue-50 px-2 py-0.5 rounded-lg">♂️ 男</span> : <span className="text-pink-500 bg-pink-50 px-2 py-0.5 rounded-lg">♀️ 女</span>}
                  </div>
                )}
              </div>
              <div className="col-span-1">
                <label className="text-xs text-gray-500 font-bold uppercase tracking-wide mb-1.5 block">年龄</label>
                {editing ? (
                  <div className="relative">
                    <input type="number" value={goal.age} onChange={(e) => setGoal({ ...goal, age: parseInt(e.target.value) })}
                      className="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-gray-700 outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-300 transition-all text-sm" />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs">岁</span>
                  </div>
                ) : (
                  <div className="font-bold text-gray-700 text-lg">{goal.age} <span className="text-sm font-normal text-gray-400">岁</span></div>
                )}
              </div>
              <div className="col-span-1">
                <label className="text-xs text-gray-500 font-bold uppercase tracking-wide mb-1.5 block">身高</label>
                {editing ? (
                  <div className="relative">
                    <input type="number" value={goal.height} onChange={(e) => setGoal({ ...goal, height: parseInt(e.target.value) })}
                      className="w-full bg-gray-50 border border-gray-200 rounded-xl px-3 py-2 text-gray-700 outline-none focus:ring-2 focus:ring-blue-100 focus:border-blue-300 transition-all text-sm" />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs">cm</span>
                  </div>
                ) : (
                  <div className="font-bold text-gray-700 text-lg">{goal.height} <span className="text-sm font-normal text-gray-400">cm</span></div>
                )}
              </div>

            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">
              <span className="mr-2">⚕️</span>
              健康信息
            </h2>
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">疾病史</label>
                {editing ? (
                  <div className="space-y-2">
                    <div className="flex flex-wrap gap-2">
                      {diseaseOptions.map(tag => (
                        <button
                          key={tag}
                          onClick={() => toggleTag('diseases', tag)}
                          className={`px-3 py-1 rounded-full text-sm border transition-colors ${(goal.diseases || '').split(',').includes(tag)
                            ? 'bg-red-100 border-red-300 text-red-700'
                            : 'bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100'
                            }`}
                        >
                          {tag}
                        </button>
                      ))}
                    </div>
                    <input
                      type="text"
                      value={goal.diseases}
                      onChange={(e) => setGoal({ ...goal, diseases: e.target.value })}
                      placeholder=""
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm"
                    />
                  </div>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {goal.diseases ? (
                      goal.diseases.split(',').map((tag, i) => (
                        <span key={i} className="px-3 py-1 bg-red-50 text-red-700 rounded-full text-sm border border-red-100">
                          {tag}
                        </span>
                      ))
                    ) : <span className="text-gray-400">无</span>}
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">过敏源</label>
                {editing ? (
                  <div className="space-y-2">
                    <div className="flex flex-wrap gap-2">
                      {allergyOptions.map(tag => (
                        <button
                          key={tag}
                          onClick={() => toggleTag('allergies', tag)}
                          className={`px-3 py-1 rounded-full text-sm border transition-colors ${(goal.allergies || '').split(',').includes(tag)
                            ? 'bg-orange-100 border-orange-300 text-orange-700'
                            : 'bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100'
                            }`}
                        >
                          {tag}
                        </button>
                      ))}
                    </div>
                    <input
                      type="text"
                      value={goal.allergies}
                      onChange={(e) => setGoal({ ...goal, allergies: e.target.value })}
                      placeholder=""
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm"
                    />
                  </div>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {goal.allergies ? (
                      goal.allergies.split(',').map((tag, i) => (
                        <span key={i} className="px-3 py-1 bg-orange-50 text-orange-700 rounded-full text-sm border border-orange-100">
                          {tag}
                        </span>
                      ))
                    ) : <span className="text-gray-400">无</span>}
                  </div>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">饮食偏好</label>
                {editing ? (
                  <div className="space-y-2">
                    <div className="flex flex-wrap gap-2">
                      {preferenceOptions.map(tag => (
                        <button
                          key={tag}
                          onClick={() => toggleTag('dietPreferences', tag)}
                          className={`px-3 py-1 rounded-full text-sm border transition-colors ${(goal.dietPreferences || '').split(',').includes(tag)
                            ? 'bg-green-100 border-green-300 text-green-700'
                            : 'bg-gray-50 border-gray-200 text-gray-600 hover:bg-gray-100'
                            }`}
                        >
                          {tag}
                        </button>
                      ))}
                    </div>
                    <input
                      type="text"
                      value={goal.dietPreferences}
                      onChange={(e) => setGoal({ ...goal, dietPreferences: e.target.value })}
                      placeholder=""
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm"
                    />
                  </div>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {goal.dietPreferences ? (
                      goal.dietPreferences.split(',').map((tag, i) => (
                        <span key={i} className="px-3 py-1 bg-green-50 text-green-700 rounded-full text-sm border border-green-100">
                          {tag}
                        </span>
                      ))
                    ) : <span className="text-gray-400">无</span>}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl shadow-lg p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            <span className="mr-2">🎯</span>
            健康目标设定
          </h2>

          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-3">我的目标</label>
            <div className="grid grid-cols-3 gap-4">
              {['0', '1', '2'].map((val) => (
                <button
                  key={val}
                  onClick={() => editing && setGoal({ ...goal, healthGoal: val })}
                  disabled={!editing}
                  className={`p-4 rounded-xl border-2 transition-all ${goal.healthGoal === val
                    ? 'border-blue-500 bg-blue-50'
                    : 'border-gray-200 hover:border-gray-300'
                    } ${!editing ? 'cursor-not-allowed opacity-60' : 'cursor-pointer'}`}
                >
                  <div className="text-2xl mb-2">
                    {val === '0' ? '🔥' : val === '1' ? '💪' : '⚖️'}
                  </div>
                  <div className="font-bold text-gray-900">
                    {val === '0' ? '减脂' : val === '1' ? '增肌' : '保持'}
                  </div>
                  <div className="text-xs font-medium text-gray-600 mt-1">
                    {val === '0' ? '控制热量摄入' : val === '1' ? '增加蛋白质' : '均衡饮食'}
                  </div>
                </button>
              ))}
            </div>
          </div>

          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-3">我的食量</label>
            <div className="grid grid-cols-3 gap-4">
              {[
                { val: 'small', emoji: '🍃', label: '小食量', desc: '约70%标准分量' },
                { val: 'normal', emoji: '🍽️', label: '正常食量', desc: '100%标准分量' },
                { val: 'large', emoji: '🍖', label: '大食量', desc: '约130%标准分量' }
              ].map((opt) => (
                <button
                  key={opt.val}
                  onClick={() => editing && setGoal({ ...goal, portionPreference: opt.val })}
                  disabled={!editing}
                  className={`p-4 rounded-xl border-2 transition-all ${(goal.portionPreference || 'normal') === opt.val
                    ? 'border-green-500 bg-green-50'
                    : 'border-gray-200 hover:border-gray-300'
                    } ${!editing ? 'cursor-not-allowed opacity-60' : 'cursor-pointer'}`}
                >
                  <div className="text-2xl mb-2">{opt.emoji}</div>
                  <div className="font-bold text-gray-900">{opt.label}</div>
                  <div className="text-xs font-medium text-gray-600 mt-1">{opt.desc}</div>
                </button>
              ))}
            </div>
          </div>
        </div>
    </div>
  );
};

export default HealthGoalPage;
