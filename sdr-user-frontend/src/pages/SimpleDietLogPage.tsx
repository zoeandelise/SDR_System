// 简化版饮食记录页面 - 完全可用
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api, { dietRecordApi } from '../services/api';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { useToast } from '../components/ui/Toast';
import FoodDetailModal from '../components/FoodDetailModal';

interface DietRecord {
  recordId: number;
  mealType: string;
  totalCalories: number;
  totalProtein: number;
  totalFat: number;
  totalCarbohydrate: number;
  notes: string;
  recordDate: string;
}

interface QuickFood {
  name: string;
  calories: number;
  protein: number;
  carb: number;
  fat: number;
}

const SimpleDietLogPage: React.FC = () => {
  const navigate = useNavigate();
  const { showToast, showConfirm } = useToast();
  const [records, setRecords] = useState<DietRecord[]>([]);
  const [recommendations, setRecommendations] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<'records' | 'recommendations'>('records');
  const [loading, setLoading] = useState(false);
  const [executingPlan, setExecutingPlan] = useState<number | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [foodSuggestions, setFoodSuggestions] = useState<any[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [allFoods, setAllFoods] = useState<any[]>([]);
  const [selectedFood, setSelectedFood] = useState<string | null>(null);

  // 新增记录表单
  const [newRecord, setNewRecord] = useState({
    mealType: '1',
    notes: '',
    totalCalories: 0,
    totalProtein: 0,
    totalFat: 0,
    totalCarbohydrate: 0
  });

  // 常用食物快速选择
  const quickFoods: QuickFood[] = [
    { name: '鸡胸肉沙拉 + 全麦面包', calories: 650, protein: 35, carb: 85, fat: 22 },
    { name: '燕麦粥 + 牛奶 + 香蕉', calories: 420, protein: 20, carb: 60, fat: 12 },
    { name: '糙米饭 + 西兰花 + 鸡胸肉', calories: 550, protein: 45, carb: 70, fat: 15 },
    { name: '三文鱼 + 蔬菜沙拉', calories: 480, protein: 38, carb: 25, fat: 28 },
    { name: '全麦三明治 + 酸奶', calories: 380, protein: 18, carb: 55, fat: 10 },
    { name: '水果沙拉 + 坚果', calories: 320, protein: 8, carb: 45, fat: 15 },
    { name: '豆腐 + 青菜 + 米饭', calories: 480, protein: 25, carb: 65, fat: 12 },
    { name: '牛肉 + 胡萝卜 + 土豆', calories: 620, protein: 42, carb: 58, fat: 24 }
  ];

  // 选择快速食物
  const handleSelectQuickFood = (food: QuickFood) => {
    setNewRecord({
      ...newRecord,
      notes: food.name,
      totalCalories: food.calories,
      totalProtein: food.protein,
      totalCarbohydrate: food.carb,
      totalFat: food.fat
    });
  };

  // 处理食物输入（智能联想）
  const handleFoodInput = (value: string) => {
    setNewRecord({ ...newRecord, notes: value });

    if (value.trim().length > 0) {
      // 搜索匹配的食物
      const matches = allFoods.filter(food =>
        food.foodName && food.foodName.includes(value)
      ).slice(0, 5);

      setFoodSuggestions(matches);
      setShowSuggestions(matches.length > 0);
    } else {
      setShowSuggestions(false);
    }
  };

  // 选择联想的食物
  const handleSelectSuggestion = (food: any) => {
    const portion = 100; // 默认100g
    setNewRecord({
      ...newRecord,
      notes: food.foodName,
      totalCalories: Math.round((food.caloriesPer100g || 0) * portion / 100),
      totalProtein: Math.round((food.proteinPer100g || 0) * portion / 100 * 10) / 10,
      totalCarbohydrate: Math.round((food.carbohydratePer100g || 0) * portion / 100 * 10) / 10,
      totalFat: Math.round((food.fatPer100g || 0) * portion / 100 * 10) / 10
    });
    setShowSuggestions(false);
  };

  useEffect(() => {
    loadRecords();
    loadRecommendations();
    loadAllFoods();

    const params = new URLSearchParams(window.location.search);
    if (params.get('tab') === 'recommendations') {
      setActiveTab('recommendations');
    }
  }, []);

  // 加载所有食物（用于自动联想）
  const loadAllFoods = async () => {
    try {
      const response: any = await api.get('/api/user/diet/foods');

      if (response.code === 200 && response.data) {
        setAllFoods(response.data);
      }
    } catch (error) {
      console.error('加载食物失败:', error);
    }
  };

  const loadRecords = async () => {
    try {
      setLoading(true);
      const response: any = await dietRecordApi.getRecords({});
      if (response.code === 200 && response.data) {
        setRecords(response.data);
      }
    } catch (error) {
      console.error('加载记录失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadRecommendations = async () => {
    try {
      const response: any = await api.get('/api/user/diet/my-recommendations', { params: { days: 7 } });
      if (response.code === 200 && response.data) {
        setRecommendations(response.data);
      }
    } catch (error) {
      console.error('加载推荐方案失败:', error);
    }
  };

  const handleExecutePlan = async (recommendationId: number) => {
    try {
      setExecutingPlan(recommendationId);
      const response: any = await api.post('/api/user/diet/plan/execute', { recommendationId });
      if (response.code === 200) {
        showToast('success', '打卡成功！已记录到今日饮食中');
        await loadRecords();
        await loadRecommendations();
      } else {
        showToast('error', response.msg || '执行失败');
      }
    } catch (err: any) {
      showToast('error', err.message || '执行失败');
    } finally {
      setExecutingPlan(null);
    }
  };

  const handleDeleteRecommendation = async (id: number) => {
    showConfirm('确定要删除这个推荐方案吗？', async () => {
      try {
        const res: any = await api.delete('/api/user/diet/recommendation/' + id);
        if (res.code === 200) {
          showToast('success', '删除成功');
          loadRecommendations();
        } else {
          showToast('error', res.msg || '删除失败');
        }
      } catch (err: any) {
        showToast('error', '删除失败');
      }
    });
  };

  const handleAddRecord = async () => {
    try {
      const response: any = await dietRecordApi.addRecord(newRecord);
      if (response.code === 200) {
        setShowAddForm(false);
        setNewRecord({ mealType: '1', notes: '', totalCalories: 0, totalProtein: 0, totalFat: 0, totalCarbohydrate: 0 });
        await loadRecords();
        showToast('success', '饮食记录添加成功');
      }
    } catch (error: any) {
      showToast('error', '添加失败：' + (error.message || '未知错误'));
    }
  };

  const handleDeleteRecord = async (recordId: number) => {
    showConfirm('确定要删除这条记录吗？', async () => {
      try {
        await dietRecordApi.deleteRecord(recordId);
        await loadRecords();
        showToast('success', '删除成功');
      } catch (error: any) {
        showToast('error', '删除失败：' + (error.message || '未知错误'));
      }
    });
  };

  const mealTypeNames: { [key: string]: string } = {
    '0': '早餐', '1': '午餐', '2': '晚餐', '3': '加餐'
  };

  const mealTypeEmojis: { [key: string]: string } = {
    '0': '🍳', '1': '🍱', '2': '🍲', '3': '🍎'
  };

  return (
    <div className="animate-fadeIn">

      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">饮食记录</h1>
          <p className="text-gray-700 text-sm">记录每一餐，掌控健康生活</p>
        </div>
        <Button onClick={() => setShowAddForm(true)}>
          + 记一笔
        </Button>
      </div>

      <div className="flex border-b border-gray-200 mb-6">
        <button
          className={`py-3 px-6 font-semibold text-sm border-b-2 transition-colors ${activeTab === 'records' ? 'border-primary-600 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
          onClick={() => setActiveTab('records')}
        >
          实际记录
        </button>
        <button
          className={`py-3 px-6 font-semibold text-sm border-b-2 transition-colors ${activeTab === 'recommendations' ? 'border-primary-600 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
          onClick={() => setActiveTab('recommendations')}
        >
          计划与方案
        </button>
      </div>

      {loading ? (
        <div className="text-center py-20">
          <div className="inline-block animate-spin rounded-full h-10 w-10 border-b-2 border-primary-600"></div>
          <p className="mt-4 text-gray-500">加载中...</p>
        </div>
      ) : activeTab === 'records' ? (
        records.length === 0 ? (
          <div className="py-8">
            <div className="text-center mb-6">
              <span className="text-6xl block mb-4">🍽️</span>
              <h3 className="text-xl font-bold text-gray-800 mb-2">开始记录今日饮食</h3>
            </div>
            <div className="text-center">
              <Button onClick={() => setShowAddForm(true)} size="lg">
                ✏️ 手动输入记录
              </Button>
            </div>
          </div>
        ) : (
          <div className="space-y-4">
            {records.map((record) => (
              <Card key={record.recordId} className="hover:shadow-md transition-shadow duration-300 border-l-4 border-l-primary-500">
                <div className="flex items-start justify-between p-1">
                  <div className="flex items-start space-x-4 flex-1">
                    <div className="w-12 h-12 rounded-full bg-primary-50 flex items-center justify-center text-2xl flex-shrink-0">
                      {mealTypeEmojis[record.mealType] || '🍽️'}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-1">
                        <span className="font-bold text-gray-900 text-lg">
                          {mealTypeNames[record.mealType] || '未知'}
                        </span>
                        <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">
                          {record.recordDate}
                        </span>
                      </div>
                      {/* 食物名称可点击，带分量 */}
                      <div className="text-gray-700 mb-3 font-medium flex flex-wrap gap-1">
                        {record.notes ? (
                          record.notes.split(/[,，、]/).map((food: string, foodIdx: number) => {
                            const cleanFood = food.trim().replace(/^(早餐|午餐|晚餐|加餐)[::：]\s*/, '');
                            if (cleanFood && cleanFood.length > 0) {
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
                                  className="bg-blue-50 text-blue-600 hover:bg-blue-100 px-2 py-1 rounded cursor-pointer inline-flex items-center gap-1"
                                  title="点击查看营养详情"
                                >
                                  {cleanFood}
                                  <span className="text-blue-400 text-xs">{portion}g</span>
                                </span>
                              );
                            }
                            return null;
                          })
                        ) : (
                          <span className="text-gray-600">无备注</span>
                        )}
                      </div>
                      <div className="flex flex-wrap gap-2 text-xs font-medium">
                        <span className="px-2 py-1 bg-orange-50 text-orange-700 rounded-md border border-orange-100">
                          🔥 {record.totalCalories} kcal
                        </span>
                        <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded-md border border-blue-100">
                          💪 {record.totalProtein}g 蛋白
                        </span>
                        <span className="px-2 py-1 bg-yellow-50 text-yellow-700 rounded-md border border-yellow-100">
                          🌾 {record.totalCarbohydrate}g 碳水
                        </span>
                        <span className="px-2 py-1 bg-purple-50 text-purple-700 rounded-md border border-purple-100">
                          🧈 {record.totalFat}g 脂肪
                        </span>
                      </div>
                    </div>
                  </div>
                  <button
                    onClick={() => handleDeleteRecord(record.recordId)}
                    className="text-gray-400 hover:text-red-500 transition-colors p-2"
                    title="删除记录"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </button>
                </div>
              </Card>
            ))}
          </div>
        )
      ) : (
        recommendations.length === 0 ? (
          <div className="py-8 text-center">
            <div className="text-6xl mb-4">📋</div>
            <h3 className="text-xl font-bold text-gray-800 mb-2">暂无计划方案</h3>
            <p className="text-gray-500 mb-6">您还没有保存任何智能推荐方案</p>
            <Button onClick={() => navigate('/smart-recommendation')} size="lg">
              去获取智能推荐
            </Button>
          </div>
        ) : (
          <div className="space-y-4">
            {recommendations.map((rec) => (
              <Card key={rec.recommendationId} className="border-0 shadow-sm hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between p-4">
                  <div className="flex items-start space-x-4 flex-1">
                    <div className="w-12 h-12 rounded-xl bg-purple-100 flex items-center justify-center text-2xl flex-shrink-0">
                      🤖
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <span className="font-bold text-gray-900 text-lg">
                          {rec.algorithmType || '智能推荐方案'}
                        </span>
                        <span className="text-xs px-2 py-0.5 bg-gray-100 text-gray-500 rounded-full">
                          {rec.recommendationDate}
                        </span>
                        {rec.isAccepted === '1' ? (
                          <span className="text-xs px-2 py-0.5 bg-emerald-100 text-emerald-700 rounded-md font-semibold">已打卡</span>
                        ) : (
                          <span className="text-xs px-2 py-0.5 bg-black text-white rounded-md font-bold shadow-sm">待打卡</span>
                        )}
                      </div>
                      <div className="text-gray-700 mb-4 font-medium leading-relaxed">
                        {rec.recommendedFoods?.split(/[,，、]/).map((food: string, foodIdx: number) => {
                          const cleanFood = food.trim().replace(/^(早餐|午餐|晚餐|加餐)[::：]\s*/, '');
                          if (cleanFood) {
                            return (
                              <span key={foodIdx} className="inline-block mr-2 mb-1 bg-gray-50 px-2 py-1 rounded">
                                {cleanFood}
                              </span>
                            );
                          }
                          return null;
                        })}
                      </div>
                      {rec.isAccepted !== '1' && (
                        <Button
                          size="sm"
                          onClick={() => navigate('/checkin')}
                          className="bg-black hover:bg-gray-800 text-white font-bold shadow-sm px-6 rounded-xl"
                        >
                          去打卡
                        </Button>
                      )}
                    </div>
                  </div>
                  <button
                    onClick={() => handleDeleteRecommendation(rec.recommendationId)}
                    className="text-gray-400 hover:text-red-500 transition-colors p-2"
                    title="删除方案"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </button>
                </div>
              </Card>
            ))}
          </div>
        )
      )}

      {showAddForm && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[60] p-4 animate-fadeIn">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl animate-slideUp max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-bold text-gray-900">添加饮食记录</h3>
              <button onClick={() => setShowAddForm(false)} className="text-gray-400 hover:text-gray-600">
                ✕
              </button>
            </div>

          <div className="space-y-5">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">餐次类型</label>
              <div className="grid grid-cols-4 gap-2">
                {[
                  { val: '0', label: '早餐', emoji: '🍳' },
                  { val: '1', label: '午餐', emoji: '🍱' },
                  { val: '2', label: '晚餐', emoji: '🍲' },
                  { val: '3', label: '加餐', emoji: '🍎' }
                ].map((opt) => (
                  <button
                    key={opt.val}
                    onClick={() => setNewRecord({ ...newRecord, mealType: opt.val })}
                    className={`py-2 rounded-lg text-sm font-medium transition-colors ${newRecord.mealType === opt.val
                      ? 'bg-primary-600 text-white shadow-md'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                      }`}
                  >
                    <span className="mr-1">{opt.emoji}</span> {opt.label}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                食物描述
                <span className="text-xs font-normal text-gray-500 ml-2">（支持自动联想）</span>
              </label>

              {/* 智能输入框 */}
              <div className="relative z-20">
                <input
                  type="text"
                  value={newRecord.notes}
                  onChange={(e) => handleFoodInput(e.target.value)}
                  onFocus={() => newRecord.notes && setShowSuggestions(foodSuggestions.length > 0)}
                  onBlur={() => setTimeout(() => setShowSuggestions(false), 200)}
                  placeholder="例如：燕麦粥、鸡胸肉沙拉..."
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-shadow outline-none"
                />

                {/* 自动联想下拉 */}
                {showSuggestions && foodSuggestions.length > 0 && (
                  <div className="absolute top-full left-0 w-full mt-1 bg-white border border-gray-100 rounded-xl shadow-xl max-h-60 overflow-auto py-1">
                    {foodSuggestions.map((food, idx) => (
                      <div
                        key={idx}
                        onClick={() => handleSelectSuggestion(food)}
                        className="px-4 py-3 hover:bg-primary-50 cursor-pointer border-b border-gray-50 last:border-b-0"
                      >
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium text-gray-900">{food.foodName}</div>
                            <div className="text-xs text-gray-500 mt-0.5">
                              {food.caloriesPer100g}卡 / 100g
                            </div>
                          </div>
                          <span className="text-xs text-primary-600 font-bold bg-primary-50 px-2 py-1 rounded">
                            自动填充
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* 快速选择标签 */}
              <div className="mt-3 overflow-x-auto pb-2 -mx-1 px-1">
                <div className="flex gap-2">
                  {quickFoods.slice(0, 4).map((food, idx) => (
                    <button
                      key={idx}
                      onClick={() => handleSelectQuickFood(food)}
                      className="flex-shrink-0 text-xs px-3 py-1.5 bg-gray-50 hover:bg-primary-50 hover:text-primary-700 text-gray-600 rounded-full border border-gray-200 transition-colors whitespace-nowrap"
                    >
                      ⚡ {food.name.split(' ')[0]}...
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
              <label className="block text-sm font-semibold text-gray-700 mb-3">营养成分 (可选)</label>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-xs text-gray-500 mb-1">热量 (kcal)</div>
                  <input
                    type="number"
                    value={newRecord.totalCalories}
                    onChange={(e) => setNewRecord({ ...newRecord, totalCalories: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-sm"
                  />
                </div>
                <div>
                  <div className="text-xs text-gray-500 mb-1">蛋白质 (g)</div>
                  <input
                    type="number"
                    value={newRecord.totalProtein}
                    onChange={(e) => setNewRecord({ ...newRecord, totalProtein: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-sm"
                  />
                </div>
                <div>
                  <div className="text-xs text-gray-500 mb-1">碳水 (g)</div>
                  <input
                    type="number"
                    value={newRecord.totalCarbohydrate}
                    onChange={(e) => setNewRecord({ ...newRecord, totalCarbohydrate: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-sm"
                  />
                </div>
                <div>
                  <div className="text-xs text-gray-500 mb-1">脂肪 (g)</div>
                  <input
                    type="number"
                    value={newRecord.totalFat}
                    onChange={(e) => setNewRecord({ ...newRecord, totalFat: Number(e.target.value) })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-sm"
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="flex gap-3 mt-8">
            <Button
              variant="ghost"
              onClick={() => setShowAddForm(false)}
              className="flex-1"
            >
              取消
            </Button>
            <Button
              onClick={handleAddRecord}
              className="flex-1"
            >
              保存记录
            </Button>
          </div>
        </div>
      </div>
    )}

      {selectedFood && (
        <FoodDetailModal
          foodName={selectedFood}
          onClose={() => setSelectedFood(null)}
        />
      )}
    </div>
  );
};

export default SimpleDietLogPage;

