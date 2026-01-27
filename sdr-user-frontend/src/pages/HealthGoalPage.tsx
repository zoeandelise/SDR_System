// 健康目标页面 - 用户端
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

interface HealthGoal {
  goalId?: number;
  userId: number;
  // 基本信息
  gender?: string;
  age?: number;
  height?: number;
  weight?: number;
  occupation?: string;
  // 健康信息
  diseases?: string;
  allergies?: string;
  dietPreferences?: string;
  // 营养目标
  dailyCalorieGoal: number;
  dailyProteinGoal: number;
  dailyCarbGoal: number;
  dailyFatGoal: number;
  targetWeight?: number;
  healthGoal: string; // 0=减脂, 1=增肌, 2=保持
}

interface RecommendationPlan {
  recommendationId: number;
  recommendationDate: string;
  recommendedFoods: string;
  isAccepted: string;
}

const HealthGoalPage: React.FC = () => {
  const navigate = useNavigate();
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
    dailyProteinGoal: 80,
    dailyCarbGoal: 250,
    dailyFatGoal: 60,
    healthGoal: '1'
  });
  const [recommendations, setRecommendations] = useState<RecommendationPlan[]>([]);
  const [loading, setLoading] = useState(false);
  const [editing, setEditing] = useState(false);

  // 预定义选项
  const diseaseOptions = ['高血压', '糖尿病', '痛风', '高血脂', '心脏病'];
  const allergyOptions = ['海鲜', '花生', '牛奶', '鸡蛋', '坚果', '小麦'];
  const preferenceOptions = ['清淡', '素食', '低脂', '低糖', '高蛋白', '辣'];

  useEffect(() => {
    loadHealthGoal();
    loadRecommendations();
  }, []);

  const loadHealthGoal = async () => {
    try {

      const response: any = await api.get('/diet/health/my');

      if (response.code === 200 && response.data) {
        const h = response.data.data;
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
          dailyProteinGoal: h.dailyProteinGoal || h.daily_protein_goal || 80,
          dailyCarbGoal: h.dailyCarbGoal || h.daily_carb_goal || 250,
          dailyFatGoal: h.dailyFatGoal || h.daily_fat_goal || 60,
          targetWeight: h.targetWeight || h.target_weight,
          healthGoal: h.healthGoal || h.health_goal || '1'
        });
      }
    } catch (error) {
      console.error('加载健康目标失败:', error);
    }
  };

  const loadRecommendations = async () => {
    try {

      const response: any = await api.get('/api/user/diet/my-recommendations', {
        params: { days: 30 }
      });

      if (response.code === 200 && response.data) {
        setRecommendations(response.data.data.filter((r: any) => r.mealType === '9'));
      }
    } catch (error) {
      console.error('加载推荐方案失败:', error);
    }
  };

  const handleSaveGoal = async () => {
    try {
      setLoading(true);


      // 保存完整健康信息
      const response: any = await api.post('/api/user/diet/update-health-goal', goal);

      if (response.code === 200) {
        alert('✅ 健康信息已保存！AI正在根据您的信息重新生成推荐方案...');
        setEditing(false);
        loadHealthGoal();

        // 自动触发AI重新推荐
        triggerAIRecommendation();
      }
    } catch (error: any) {
      alert('❌ 保存失败：' + (error.response?.data?.msg || error.message));
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

  // 自动触发AI推荐
  const triggerAIRecommendation = async () => {
    try {


      const response: any = await api.post('/api/user/diet/daily-plan', {});

      if (response.code === 200) {
        // 自动保存生成的方案
        const plan = response.data;
        await api.post('/api/user/diet/save-daily-plan', plan);

        alert('✅ AI已根据您的最新信息生成专属方案！');
        // 跳转到饮食历史的AI推荐Tab
        setTimeout(() => {
          navigate('/diet-history?tab=recommendations');
        }, 500);
      }
    } catch (error) {
      console.error('AI推荐失败:', error);
    }
  };

  const handleApplyRecommendation = async (recId: number) => {
    try {

      const response: any = await api.post('/api/user/diet/plan/execute',
        { recommendationId: recId }
      );

      if (response.code === 200) {
        alert('✅ 方案已应用到今日饮食记录');
        loadRecommendations();
      }
    } catch (error: any) {
      alert('❌ 应用失败');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <nav className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <button onClick={() => navigate('/')} className="flex items-center space-x-2 text-gray-700">
              <span>←</span><span>返回首页</span>
            </button>
            <h1 className="text-xl font-bold text-gray-900">🎯 健康目标</h1>
            <div className="w-20"></div>
          </div>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-4 py-8">
        {/* 顶部编辑按钮 */}
        <div className="flex justify-end mb-4">
          {!editing ? (
            <button
              onClick={() => setEditing(true)}
              className="px-8 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 font-bold shadow-lg"
            >
              ✏️ 编辑全部信息
            </button>
          ) : (
            <div className="space-x-3">
              <button
                onClick={() => setEditing(false)}
                className="px-6 py-3 border-2 border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 font-medium"
              >
                取消
              </button>
              <button
                onClick={handleSaveGoal}
                disabled={loading}
                className="px-8 py-3 bg-green-600 text-white rounded-xl hover:bg-green-700 disabled:opacity-50 font-bold shadow-lg"
              >
                {loading ? '💾 保存中...' : '💾 保存并重新生成AI方案'}
              </button>
            </div>
          )}
        </div>

        {/* 基本信息 */}
        <div className="bg-white rounded-2xl shadow-lg p-8 mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            <span className="mr-2">👤</span>
            基本信息
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">性别</label>
              {editing ? (
                <select
                  value={goal.gender}
                  onChange={(e) => setGoal({ ...goal, gender: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                >
                  <option value="0">男</option>
                  <option value="1">女</option>
                </select>
              ) : (
                <div className="text-lg font-semibold">{goal.gender === '0' ? '男' : '女'}</div>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">年龄</label>
              {editing ? (
                <input type="number" value={goal.age} onChange={(e) => setGoal({ ...goal, age: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />
              ) : (
                <div className="text-lg font-semibold">{goal.age} 岁</div>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">身高(cm)</label>
              {editing ? (
                <input type="number" value={goal.height} onChange={(e) => setGoal({ ...goal, height: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />
              ) : (
                <div className="text-lg font-semibold">{goal.height} cm</div>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">体重(kg)</label>
              {editing ? (
                <input type="number" value={goal.weight} onChange={(e) => setGoal({ ...goal, weight: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />
              ) : (
                <div className="text-lg font-semibold">{goal.weight} kg</div>
              )}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">目标体重(kg)</label>
              {editing ? (
                <input type="number" value={goal.targetWeight} onChange={(e) => setGoal({ ...goal, targetWeight: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500" />
              ) : (
                <div className="text-lg font-semibold">{goal.targetWeight || '-'} kg</div>
              )}
            </div>
          </div>
        </div>

        {/* 健康信息 */}
        <div className="bg-white rounded-2xl shadow-lg p-8 mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            <span className="mr-2">⚕️</span>
            健康信息
          </h2>
          <div className="space-y-6">
            {/* 疾病史 */}
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
                    placeholder="其他疾病（手动输入，逗号分隔）"
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

            {/* 过敏源 */}
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
                    placeholder="其他过敏源（手动输入，逗号分隔）"
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

            {/* 饮食偏好 */}
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
                    placeholder="其他偏好（手动输入，逗号分隔）"
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

        {/* 健康目标设定 */}
        <div className="bg-white rounded-2xl shadow-lg p-8 mb-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            <span className="mr-2">🎯</span>
            健康目标设定
          </h2>

          {/* 目标选择 */}
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
                  <div className="text-xs text-gray-500 mt-1">
                    {val === '0' ? '控制热量摄入' : val === '1' ? '增加蛋白质' : '均衡饮食'}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* 营养目标设置 */}
          <h3 className="text-xl font-bold text-gray-900 mb-6">每日营养目标</h3>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">热量目标 (kcal)</label>
              {editing ? (
                <input
                  type="number"
                  value={goal.dailyCalorieGoal}
                  onChange={(e) => setGoal({ ...goal, dailyCalorieGoal: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              ) : (
                <div className="text-3xl font-bold text-orange-600">{goal.dailyCalorieGoal}</div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">蛋白质 (g)</label>
              {editing ? (
                <input
                  type="number"
                  value={goal.dailyProteinGoal}
                  onChange={(e) => setGoal({ ...goal, dailyProteinGoal: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              ) : (
                <div className="text-3xl font-bold text-blue-600">{goal.dailyProteinGoal}</div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">碳水化合物 (g)</label>
              {editing ? (
                <input
                  type="number"
                  value={goal.dailyCarbGoal}
                  onChange={(e) => setGoal({ ...goal, dailyCarbGoal: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              ) : (
                <div className="text-3xl font-bold text-yellow-600">{goal.dailyCarbGoal}</div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">脂肪 (g)</label>
              {editing ? (
                <input
                  type="number"
                  value={goal.dailyFatGoal}
                  onChange={(e) => setGoal({ ...goal, dailyFatGoal: parseInt(e.target.value) })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              ) : (
                <div className="text-3xl font-bold text-purple-600">{goal.dailyFatGoal}</div>
              )}
            </div>
          </div>
        </div>

        {/* AI推荐方案 */}
        <div className="bg-white rounded-2xl shadow-lg p-8">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900">
              <span className="mr-2">🤖</span>
              AI智能推荐方案
            </h2>
            <button
              onClick={() => navigate('/smart-recommendation')}
              className="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
            >
              生成新方案 →
            </button>
          </div>

          {recommendations.length > 0 ? (
            <div className="space-y-4">
              {recommendations.map((rec, idx) => (
                <div key={idx} className="border-2 border-purple-200 rounded-xl overflow-hidden">
                  <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-6 py-4 text-white">
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-bold text-lg">
                          {rec.recommendationDate} • 全天饮食方案
                        </div>
                      </div>
                      <div>
                        {rec.isAccepted === '1' ? (
                          <span className="px-4 py-2 bg-green-500 rounded-full text-sm font-bold">
                            ✓ 已应用
                          </span>
                        ) : (
                          <button
                            onClick={() => handleApplyRecommendation(rec.recommendationId)}
                            className="px-6 py-2 bg-white text-purple-600 rounded-lg font-bold hover:bg-purple-50"
                          >
                            🚀 应用此方案
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="p-6 bg-purple-50">
                    <div className="text-gray-700 leading-relaxed">
                      {rec.recommendedFoods}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-16 text-gray-500">
              <span className="text-6xl block mb-4">🤖</span>
              <p className="mb-4">还没有AI推荐方案</p>
              <button
                onClick={() => navigate('/smart-recommendation')}
                className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
              >
                立即生成方案 →
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default HealthGoalPage;
