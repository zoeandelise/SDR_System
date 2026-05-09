// 食物详情弹窗组件 - 显示功效和搭配推荐
import React, { useState, useEffect } from 'react';
import api from '../services/api';

interface FoodDetailModalProps {
  foodName: string;
  onClose: () => void;
}

const FoodDetailModal = ({ foodName, onClose }: FoodDetailModalProps) => {
  const [foodData, setFoodData] = useState<any>(null);
  const [foodInfo, setFoodInfo] = useState<any>(null);
  const [pairings, setPairings] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFoodDetail();
  }, [foodName]);

  const loadFoodDetail = async () => {
    try {
      // 从notes中提取第一个食物名称（去除"早餐:"等前缀）
      let cleanFoodName = foodName;
      if (foodName.includes(':')) {
        // "早餐: 奶酪, 花生, 杏仁" → 取冒号后第一个食物
        const parts = foodName.split(':');
        if (parts.length > 1) {
          const foods = parts[1].trim().split(',');
          cleanFoodName = foods[0].trim();
        }
      } else if (foodName.includes(',')) {
        // "奶酪, 花生, 杏仁" → 取第一个
        cleanFoodName = foodName.split(',')[0].trim();
      }

      // 使用模糊搜索 API 查询食物
      const searchResponse: any = await api.get('/api/user/diet/foods/search', {
        params: { keyword: cleanFoodName }
      });

      let food = null;

      if (searchResponse.code === 200 && searchResponse.data) {
        const foods = searchResponse.data.data || searchResponse.data;

        // 优先查找精确匹配
        food = foods.find((f: any) => f.foodName === cleanFoodName);

        // 如果没有精确匹配，使用第一个搜索结果（模糊匹配）
        if (!food && foods.length > 0) {
          food = foods[0];
        }
      }

      // 如果模糊搜索没有结果，尝试部分匹配
      if (!food) {
        const allFoodsResponse: any = await api.get('/api/user/diet/foods');
        if (allFoodsResponse.code === 200 && allFoodsResponse.data) {
          const allFoods = allFoodsResponse.data.data || allFoodsResponse.data;
          // 查找食物名称包含搜索关键词的结果
          food = allFoods.find((f: any) =>
            f.foodName && (f.foodName.includes(cleanFoodName) || cleanFoodName.includes(f.foodName))
          );
        }
      }

      if (food) {
        setFoodData(food);
        generatePairings(food);

        // 查询食物详细信息（功效等）
        try {
          const infoResponse: any = await api.get(`/api/user/diet/foods/${food.foodId}`);
          if (infoResponse.code === 200 && infoResponse.data) {
            setFoodInfo(infoResponse.data);
          }
        } catch (e) {
          // 详细信息获取失败不影响主体显示
          console.log('食物详细信息加载失败，使用基本信息');
        }
      }
    } catch (error) {
      console.error('加载食物详情失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const generatePairings = (food: any) => {
    // 根据食物类别智能推荐搭配
    const category = food.categoryName;
    const suggestions: string[] = [];

    if (category?.includes('谷物')) {
      suggestions.push('牛奶（补充蛋白质）', '鸡蛋（均衡营养）', '水果（补充维生素）');
    } else if (category?.includes('肉类')) {
      suggestions.push('蔬菜（补充纤维）', '糙米（低GI碳水）', '橄榄油（健康脂肪）');
    } else if (category?.includes('蔬菜')) {
      suggestions.push('瘦肉（补充蛋白）', '坚果（健康脂肪）', '全麦（复合碳水）');
    } else if (category?.includes('豆类')) {
      suggestions.push('谷物（蛋白质互补）', '蔬菜（均衡搭配）', '核桃（Omega-3）');
    } else if (category?.includes('蛋奶')) {
      suggestions.push('全麦面包（碳水）', '水果（维生素）', '坚果（健康脂肪）');
    } else {
      suggestions.push('均衡饮食', '多样化搭配', '注意份量');
    }

    setPairings(suggestions);
  };

  const getFoodBenefits = (food: any) => {
    const benefits = [];

    // 根据营养成分生成功效
    if (food.proteinPer100g > 20) {
      benefits.push('🏋️ 高蛋白：促进肌肉生长和修复');
    }
    if (food.caloriesPer100g < 100) {
      benefits.push('🌿 低热量：适合控制体重');
    }
    if (food.fatPer100g < 5) {
      benefits.push('💚 低脂肪：有助于心血管健康');
    }
    if (food.carbohydratePer100g > 50) {
      benefits.push('⚡ 富含碳水：提供持久能量');
    }

    // 根据GI值
    if (food.giValue && food.giValue < 55) {
      benefits.push('📊 低GI食物：血糖波动小，饱腹感持久');
    }

    // 根据钠含量
    if (food.sodiumPer100g && food.sodiumPer100g < 100) {
      benefits.push('🧂 低钠：适合高血压人群');
    }

    return benefits.length > 0 ? benefits : ['🍽️ 营养均衡的健康食物'];
  };

  const getHealthTips = (food: any) => {
    const tips = [];

    if (food.giValue && food.giValue > 70) {
      tips.push('⚠️ 高GI食物，建议搭配蛋白质和脂肪一起食用');
    }
    if (food.sodiumPer100g && food.sodiumPer100g > 300) {
      tips.push('⚠️ 钠含量较高，高血压患者注意控制摄入');
    }
    if (food.purinePer100g && food.purinePer100g > 100) {
      tips.push('⚠️ 嘌呤含量高，痛风患者应避免');
    }

    return tips;
  };

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[9999]">
        <div className="bg-white rounded-2xl p-8 shadow-2xl">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin mx-auto" />
        </div>
      </div>
    );
  }

  if (!foodData) {
    return (
      <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 animate-fadeIn" onClick={onClose}>
        <div className="bg-white rounded-2xl p-8 shadow-2xl" onClick={e => e.stopPropagation()}>
          <p className="text-gray-600 text-center">未找到食物信息</p>
          <button onClick={onClose} className="mt-4 w-full text-center text-sm text-emerald-600 font-semibold hover:text-emerald-700">关闭</button>
        </div>
      </div>
    );
  }

  const totalNutrient = (foodData.proteinPer100g || 0) + (foodData.carbohydratePer100g || 0) + (foodData.fatPer100g || 0);
  const pPct = totalNutrient > 0 ? Math.round((foodData.proteinPer100g || 0) / totalNutrient * 100) : 0;
  const cPct = totalNutrient > 0 ? Math.round((foodData.carbohydratePer100g || 0) / totalNutrient * 100) : 0;
  const fPct = totalNutrient > 0 ? 100 - pPct - cPct : 0;

  const modal = (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 animate-fadeIn" onClick={onClose}>
      <div className="bg-white rounded-3xl max-w-md w-full shadow-2xl animate-scaleIn relative overflow-hidden max-h-[90vh] flex flex-col" onClick={e => e.stopPropagation()}>
        {/* 头部渐变背景 */}
        <div className="bg-gradient-to-br from-emerald-500 to-teal-600 px-6 py-5 text-white relative flex-shrink-0">
          <button
            onClick={onClose}
            className="absolute top-3 right-3 w-8 h-8 bg-white/30 rounded-full hover:bg-white/50 flex items-center justify-center transition-colors"
          >
            ✕
          </button>
          <span className="inline-block px-2 py-0.5 bg-white/20 rounded-md text-xs font-bold mb-2">{foodData.categoryName}</span>
          <h2 className="text-2xl font-black leading-tight">{foodName}</h2>
        </div>

        <div className="p-6 overflow-y-auto flex-1 space-y-5">
          {/* 能量密度 + 三大营养素 */}
          <div className="bg-gray-50 rounded-2xl p-5 border border-gray-100 text-center">
            <div className="text-sm text-gray-500 mb-1 font-semibold">能量密度</div>
            <div className="text-4xl font-black text-emerald-600 inline-block">
              {foodData.caloriesPer100g}
              <span className="text-base font-normal text-gray-500 ml-1">kcal</span>
            </div>
            <div className="text-xs text-gray-500 mt-1">每 100 克</div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="bg-blue-50 rounded-xl p-3 text-center border border-blue-100">
              <div className="text-xs text-blue-600 font-bold mb-1">蛋白质</div>
              <div className="text-xl font-bold text-gray-900">{foodData.proteinPer100g}<span className="text-xs font-normal">g</span></div>
            </div>
            <div className="bg-yellow-50 rounded-xl p-3 text-center border border-yellow-100">
              <div className="text-xs text-yellow-600 font-bold mb-1">碳水</div>
              <div className="text-xl font-bold text-gray-900">{foodData.carbohydratePer100g}<span className="text-xs font-normal">g</span></div>
            </div>
            <div className="bg-purple-50 rounded-xl p-3 text-center border border-purple-100">
              <div className="text-xs text-purple-600 font-bold mb-1">脂肪</div>
              <div className="text-xl font-bold text-gray-900">{foodData.fatPer100g}<span className="text-xs font-normal">g</span></div>
            </div>
          </div>

          {/* 营养占比条 */}
          {totalNutrient > 0 && (
            <div className="bg-emerald-50 rounded-xl p-4 border border-emerald-100">
              <div className="text-xs text-emerald-700 font-bold mb-2">营养占比</div>
              <div className="flex h-3 rounded-full overflow-hidden bg-gray-200">
                <div className="bg-blue-400" style={{ width: `${pPct}%` }} title={`蛋白质 ${pPct}%`} />
                <div className="bg-yellow-400" style={{ width: `${cPct}%` }} title={`碳水 ${cPct}%`} />
                <div className="bg-purple-400" style={{ width: `${fPct}%` }} title={`脂肪 ${fPct}%`} />
              </div>
              <div className="flex justify-between text-[10px] font-semibold text-gray-500 mt-1">
                <span className="text-blue-600">蛋白 {pPct}%</span>
                <span className="text-yellow-600">碳水 {cPct}%</span>
                <span className="text-purple-600">脂肪 {fPct}%</span>
              </div>
            </div>
          )}

          {/* 食物简介 */}
          {foodInfo?.description && (
            <div className="p-4 bg-blue-50 rounded-xl border-l-4 border-blue-500">
              <p className="text-gray-700 text-sm leading-relaxed">{foodInfo.description}</p>
            </div>
          )}

          {/* 健康功效 */}
          <div>
            <h3 className="text-base font-bold text-gray-900 mb-3 flex items-center">
              💊 健康功效
            </h3>
            <div className="space-y-2">
              {getFoodBenefits(foodData).map((benefit, idx) => (
                <div key={idx} className="flex items-start space-x-2 p-2.5 bg-green-50 rounded-lg">
                  <span className="text-green-600 mt-0.5 text-sm">✓</span>
                  <span className="text-gray-700 text-sm">{benefit}</span>
                </div>
              ))}

              {foodInfo?.suitableFor && (
                <div className="p-2.5 bg-green-100 rounded-lg border-l-4 border-green-500">
                  <div className="font-medium text-green-900 text-sm mb-0.5">✓ 适合人群</div>
                  <div className="text-xs text-green-700">{foodInfo.suitableFor}</div>
                </div>
              )}

              {foodInfo?.unsuitableFor && (
                <div className="p-2.5 bg-red-50 rounded-lg border-l-4 border-red-400">
                  <div className="font-medium text-red-900 text-sm mb-0.5">⚠️ 不适合人群</div>
                  <div className="text-xs text-red-700">{foodInfo.unsuitableFor}</div>
                </div>
              )}
            </div>
          </div>

          {/* AI搭配推荐 */}
          <div>
            <h3 className="text-base font-bold text-gray-900 mb-3 flex items-center">
              🤖 AI智能搭配推荐
            </h3>
            <div className="grid grid-cols-3 gap-2">
              {pairings.map((pairing, idx) => (
                <div key={idx} className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl p-3 border border-purple-200 hover:shadow-md transition-shadow">
                  <div className="text-xs font-medium text-gray-900 text-center">
                    {pairing}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* 健康提示 */}
          {getHealthTips(foodData).length > 0 && (
            <div>
              <h3 className="text-base font-bold text-gray-900 mb-3 flex items-center">
                ⚕️ 健康提示
              </h3>
              <div className="space-y-2">
                {getHealthTips(foodData).map((tip, idx) => (
                  <div key={idx} className="flex items-start space-x-2 p-2.5 bg-yellow-50 rounded-lg border-l-4 border-yellow-400">
                    <span className="text-yellow-600 text-sm">⚠️</span>
                    <span className="text-gray-700 text-sm">{tip}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* 详细信息 */}
          {foodData.giValue && (
            <div className="grid grid-cols-3 gap-3 p-4 bg-gray-50 rounded-xl">
              <div className="text-center">
                <div className="text-xs text-gray-500 mb-1">GI值</div>
                <div className="text-lg font-bold text-gray-900">{foodData.giValue}</div>
              </div>
              <div className="text-center">
                <div className="text-xs text-gray-500 mb-1">钠含量</div>
                <div className="text-lg font-bold text-gray-900">{foodData.sodiumPer100g || 0}mg</div>
              </div>
              <div className="text-center">
                <div className="text-xs text-gray-500 mb-1">嘌呤</div>
                <div className="text-lg font-bold text-gray-900">{foodData.purinePer100g || 0}mg</div>
              </div>
            </div>
          )}
        </div>

        {/* 底部关闭按钮 */}
        <div className="p-4 border-t border-gray-100 flex-shrink-0">
          <button
            onClick={onClose}
            className="w-full py-3 rounded-xl bg-emerald-600 text-white font-bold hover:bg-emerald-700 transition-colors shadow-lg hover:shadow-emerald-500/30"
          >
            我知道了
          </button>
        </div>
      </div>
    </div>
  );

  return modal;
};

export default FoodDetailModal;

