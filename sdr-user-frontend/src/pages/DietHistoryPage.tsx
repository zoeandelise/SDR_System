// 饮食历史记录页面 - 查看所有历史记录和推荐方案
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api, { dietRecordApi } from '../services/api';
import FoodDetailModal from '../components/FoodDetailModal';
import { useToast } from '../components/ui/Toast';

const DietHistoryPage: React.FC = () => {
  const navigate = useNavigate();
  const { showToast, showConfirm } = useToast();
  const [records, setRecords] = useState<any[]>([]);
  const [recommendations, setRecommendations] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [days, setDays] = useState(7);
  const [activeTab, setActiveTab] = useState<'records' | 'recommendations'>('records');
  const [executing, setExecuting] = useState<number | null>(null);
  const [deleting, setDeleting] = useState<number | null>(null);
  const [selectedFood, setSelectedFood] = useState<string | null>(null);

  useEffect(() => {
    loadRecords();
    loadRecommendations();

    // 检查URL参数，如果有tab=recommendations则切换到AI推荐Tab
    const params = new URLSearchParams(window.location.search);
    if (params.get('tab') === 'recommendations') {
      setActiveTab('recommendations');
    }
  }, [days]);

  const loadRecords = async () => {
    try {
      setLoading(true);
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - days);

      const response: any = await dietRecordApi.getRecords({
        startDate: startDate.toISOString().split('T')[0],
        endDate: endDate.toISOString().split('T')[0]
      });

      if (response.code === 200 && response.data) {
        setRecords(response.data);
      }
    } catch (error) {
      console.error('加载历史记录失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadRecommendations = async () => {
    try {
      // 直接从数据库查询推荐记录
      const response: any = await api.get('/api/user/diet/my-recommendations', {
        params: { days: days }
      });

      if (response.code === 200 && response.data) {
        setRecommendations(response.data);
      }
    } catch (error) {
      console.error('加载推荐方案失败:', error);
    }
  };

  // 按日期分组
  const groupByDate = (records: any[]) => {
    const groups: { [key: string]: any[] } = {};
    records.forEach(record => {
      const date = record.recordDate;
      if (!groups[date]) {
        groups[date] = [];
      }
      groups[date].push(record);
    });
    return groups;
  };

  const groupedRecords = groupByDate(records);
  const dates = Object.keys(groupedRecords).sort().reverse();

  const mealTypeNames: { [key: string]: string } = {
    '0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'
  };

  const mealTypeEmojis: { [key: string]: string } = {
    '0': '🍳', '1': '🍱', '2': '🍲', '3': '🍎'
  };

  // 执行推荐方案
  const handleExecutePlan = async (recommendationId: number) => {
    try {
      setExecuting(recommendationId);

      const response: any = await api.post(
        '/api/user/diet/plan/execute',
        { recommendationId }
      );

      if (response.code === 200) {
        showToast('success', '方案已执行！已添加到今日饮食记录');
        loadRecommendations();
      }
    } catch (error: any) {
      showToast('error', '执行失败：' + (error.response?.data?.msg || error.message));
    } finally {
      setExecuting(null);
    }
  };

  // 删除推荐方案
  const handleDeleteRecommendation = async (recommendationId: number) => {
    showConfirm('确定要删除这个 AI 推荐方案吗？', async () => {
      try {
        setDeleting(recommendationId);

        const response: any = await api.delete(`/api/user/diet/recommendation/${recommendationId}`);

        if (response.code === 200) {
          showToast('success', '删除成功');
          loadRecommendations();
        } else {
          throw new Error(response.msg || '删除失败');
        }
      } catch (error: any) {
        showToast('error', '删除失败：' + (error.message || '未知错误'));
      } finally {
        setDeleting(null);
      }
    });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <button onClick={() => navigate('/')} className="flex items-center space-x-2 text-gray-700">
              <span>←</span><span>返回首页</span>
            </button>
            <h1 className="text-xl font-bold text-gray-900">📚 饮食历史</h1>
            <div className="w-20"></div>
          </div>
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-4 py-8 pb-24">
        {/* Tab切换 */}
        <div className="mb-6 flex space-x-3">
          <button
            onClick={() => setActiveTab('records')}
            className={`px-6 py-3 rounded-xl font-semibold transition-all ${activeTab === 'records'
              ? 'bg-blue-600 text-white shadow-lg'
              : 'bg-white text-gray-700 hover:bg-gray-50 border border-gray-200'
              }`}
          >
            📝 饮食记录
          </button>
          <button
            onClick={() => setActiveTab('recommendations')}
            className={`px-6 py-3 rounded-xl font-semibold transition-all ${activeTab === 'recommendations'
              ? 'bg-purple-600 text-white shadow-lg'
              : 'bg-white text-gray-700 hover:bg-gray-50 border border-gray-200'
              }`}
          >
            🤖 AI推荐方案 {recommendations.length > 0 && `(${recommendations.length})`}
          </button>
        </div>

        {/* 时间范围选择 */}
        <div className="mb-6 flex space-x-3">
          {[7, 30, 90].map((d) => (
            <button
              key={d}
              onClick={() => setDays(d)}
              className={`px-6 py-3 rounded-xl font-semibold transition-all ${days === d
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-white text-gray-700 hover:bg-gray-50 border border-gray-200'
                }`}
            >
              近{d}天
            </button>
          ))}
        </div>

        {loading ? (
          <div className="text-center py-16">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : activeTab === 'recommendations' ? (
          /* 推荐方案列表 */
          recommendations.length > 0 ? (
            <div className="space-y-4">
              {recommendations.map((rec, idx) => {
                // 解析推荐食物
                const foods = rec.recommendedFoods?.split(', ') || [];
                const isExecuted = rec.isAccepted === '1';

                return (
                  <div key={idx} className="bg-white rounded-2xl shadow-lg border-2 border-purple-200 overflow-hidden">
                    {/* 标题栏 */}
                    <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-6 py-4">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                          <span className="text-4xl">🤖</span>
                          <div>
                            <div className="font-bold text-xl text-white">
                              {rec.mealType === '9' ? '全天饮食方案' : '单餐推荐'}
                            </div>
                            <div className="text-sm text-purple-100 mt-1">
                              {rec.recommendationDate} • {rec.algorithmType}
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          {isExecuted ? (
                            <span className="px-4 py-2 bg-green-500 text-white rounded-full text-sm font-bold">
                              ✓ 已执行
                            </span>
                          ) : (
                            <button
                              onClick={() => handleExecutePlan(rec.recommendationId)}
                              disabled={executing === rec.recommendationId}
                              className="px-6 py-3 bg-white text-purple-600 rounded-xl font-bold hover:bg-purple-50 shadow-lg disabled:opacity-50"
                            >
                              {executing === rec.recommendationId ? '执行中...' : '🚀 一键执行'}
                            </button>
                          )}
                          <button
                            onClick={() => handleDeleteRecommendation(rec.recommendationId)}
                            disabled={deleting === rec.recommendationId}
                            className="px-4 py-3 bg-red-500/20 text-white rounded-xl hover:bg-red-500/40 transition-colors disabled:opacity-50"
                            title="删除此方案"
                          >
                            {deleting === rec.recommendationId ? '⏳' : '🗑️'}
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* 方案内容（食物可点击） */}
                    <div className="p-6">
                      <div className="prose max-w-none">
                        <div className="text-gray-700 leading-relaxed text-base">
                          {/* 解析食物列表，让每个食物可点击 */}
                          {rec.recommendedFoods?.split(',').map((food: string, idx: number) => {
                            const cleanFood = food.trim().replace(/^(早餐|午餐|晚餐):\s*/, '');
                            if (cleanFood && cleanFood.length > 0 && cleanFood !== '早餐' && cleanFood !== '午餐' && cleanFood !== '晚餐') {
                              return (
                                <span key={idx}>
                                  <span
                                    className="text-blue-600 hover:text-blue-700 cursor-pointer hover:underline font-medium inline-flex items-center"
                                    onClick={() => setSelectedFood(cleanFood)}
                                  >
                                    {cleanFood}
                                    <span className="text-xs ml-1">🔍</span>
                                  </span>
                                  {idx < rec.recommendedFoods.split(',').length - 1 && ', '}
                                </span>
                              );
                            } else if (food.includes(':')) {
                              // 显示餐次标题
                              return <span key={idx} className="font-bold text-gray-900">{food.trim()}</span>;
                            }
                            return null;
                          })}
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-16 bg-white rounded-xl">
              <span className="text-6xl block mb-4">🤖</span>
              <p className="text-gray-600">最近{days}天没有AI推荐方案</p>
            </div>
          )
        ) : dates.length > 0 ? (
          <div className="space-y-6">
            {dates.map((date) => {
              const dayRecords = groupedRecords[date];
              const dayTotal = dayRecords.reduce((sum, r) => sum + (r.totalCalories || 0), 0);

              return (
                <div key={date} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                  {/* 日期标题 */}
                  <div className="bg-gradient-to-r from-blue-500 to-cyan-500 text-white px-6 py-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="text-lg font-bold">{date}</div>
                        <div className="text-sm text-blue-100">共{dayRecords.length}条记录</div>
                      </div>
                      <div className="text-right">
                        <div className="text-2xl font-bold">{dayTotal}</div>
                        <div className="text-sm text-blue-100">总热量</div>
                      </div>
                    </div>
                  </div>

                  {/* 记录列表 */}
                  <div className="p-4 space-y-3">
                    {dayRecords.map((record, idx) => (
                      <div
                        key={idx}
                        className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-3">
                            <span className="text-3xl">
                              {mealTypeEmojis[record.mealType] || '🍽️'}
                            </span>
                            <div>
                              <div className="font-medium text-gray-900">
                                {mealTypeNames[record.mealType] || '未知'}
                              </div>
                              {/* 食物列表可点击，带分量 */}
                              <div className="text-sm text-gray-500 flex flex-wrap gap-1 mt-1">
                                {record.notes ? (
                                  record.notes.split(/[,，、]/).map((food: string, foodIdx: number) => {
                                    const cleanFood = food.trim().replace(/^(早餐|午餐|晚餐|加餐)[:：]\s*/, '');
                                    if (cleanFood && cleanFood.length > 0) {
                                      // 估算分量
                                      let portion = 100;
                                      if (cleanFood.includes('饭') || cleanFood.includes('面') || cleanFood.includes('粥')) portion = 200;
                                      else if (cleanFood.includes('汤') || cleanFood.includes('水') || cleanFood.includes('奶') || cleanFood.includes('茶')) portion = 250;
                                      else if (cleanFood.includes('菜') || cleanFood.includes('瓜') || cleanFood.includes('萝卜')) portion = 150;
                                      else if (cleanFood.includes('肉') || cleanFood.includes('鱼') || cleanFood.includes('鸡')) portion = 100;
                                      else if (cleanFood.includes('蛋')) portion = 50;
                                      return (
                                        <span
                                          key={foodIdx}
                                          onClick={() => setSelectedFood(cleanFood)}
                                          className="bg-blue-50 text-blue-600 hover:bg-blue-100 px-2 py-0.5 rounded cursor-pointer text-xs"
                                          title="点击查看营养详情"
                                        >
                                          {cleanFood}
                                          <span className="text-blue-400 ml-1">{portion}g</span>
                                        </span>
                                      );
                                    }
                                    return null;
                                  })
                                ) : (
                                  <span className="text-gray-400">无备注</span>
                                )}
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center space-x-4">
                            <div className="text-right">
                              <div className="text-lg font-bold text-gray-900">
                                {record.totalCalories}
                              </div>
                              <div className="text-xs text-gray-500">卡路里</div>
                            </div>
                            <div className="flex gap-2 text-xs">
                              <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded">
                                蛋白{record.totalProtein}g
                              </span>
                              <span className="px-2 py-1 bg-yellow-100 text-yellow-700 rounded">
                                碳水{record.totalCarbohydrate}g
                              </span>
                              <span className="px-2 py-1 bg-purple-100 text-purple-700 rounded">
                                脂肪{record.totalFat}g
                              </span>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-16 bg-white rounded-xl">
            <span className="text-6xl block mb-4">📚</span>
            <p className="text-gray-600">最近{days}天没有饮食记录</p>
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
    </div>
  );
};

export default DietHistoryPage;

