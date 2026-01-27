// 食物详情弹窗组件 - 显示功效和搭配推荐
import React, { useState, useEffect } from 'react';
import api from '../services/api';

interface FoodDetailModalProps {
  foodName: string;
  onClose: () => void;
}

const FoodDetailModal: React.FC<FoodDetailModalProps> = ({ foodName, onClose }) => {
  const [foodData, setFoodData] = useState<any>(null);
  const [foodInfo, setFoodInfo] = useState<any>(null);
  const [pairings, setPairings] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFoodDetail();
  }, [foodName]);

  const loadFoodDetail = async () => {
    try {
      const token = document.cookie.split('; ').find(row => row.startsWith('Admin-Token='))?.split('=')[1];

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

      // 查询食物营养数据
      const nutritionResponse: any = await api.get('/api/user/diet/foods');

      if (nutritionResponse.code === 200 && nutritionResponse.data) {
        const food = nutritionResponse.data.data.find((f: any) => f.foodName === cleanFoodName);
        if (food) {
          setFoodData(food);
          generatePairings(food);

          // 查询食物详细信息（功效等）
          const infoResponse: any = await api.get(`/api/user/diet/food-info/${food.foodId}`);

          if (infoResponse.code === 200 && infoResponse.data) {
            setFoodInfo(infoResponse.data);
          }
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
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-2xl p-8">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
        </div>
      </div>
    );
  }

  if (!foodData) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" onClick={onClose}>
        <div className="bg-white rounded-2xl p-8">
          <p className="text-gray-600">未找到食物信息</p>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="bg-white rounded-3xl max-w-2xl w-full shadow-2xl overflow-hidden" onClick={(e) => e.stopPropagation()}>
        {/* 头部渐变背景 */}
        <div className="bg-gradient-to-r from-green-500 to-emerald-600 px-8 py-6 text-white relative">
          <button
            onClick={onClose}
            className="absolute top-4 right-4 w-8 h-8 bg-white bg-opacity-30 rounded-full hover:bg-opacity-50 flex items-center justify-center"
          >
            ×
          </button>
          <h2 className="text-3xl font-bold mb-2">{foodName}</h2>
          <p className="text-green-100 text-sm">{foodData.categoryName}</p>
        </div>

        <div className="p-8">
          {/* 营养成分卡片 */}
          <div className="grid grid-cols-4 gap-4 mb-6">
            <div className="bg-orange-50 rounded-xl p-4 text-center">
              <div className="text-2xl font-bold text-orange-600">{foodData.caloriesPer100g}</div>
              <div className="text-xs text-gray-600 mt-1">热量(kcal/100g)</div>
            </div>
            <div className="bg-blue-50 rounded-xl p-4 text-center">
              <div className="text-2xl font-bold text-blue-600">{foodData.proteinPer100g}</div>
              <div className="text-xs text-gray-600 mt-1">蛋白质(g)</div>
            </div>
            <div className="bg-yellow-50 rounded-xl p-4 text-center">
              <div className="text-2xl font-bold text-yellow-600">{foodData.carbohydratePer100g}</div>
              <div className="text-xs text-gray-600 mt-1">碳水(g)</div>
            </div>
            <div className="bg-purple-50 rounded-xl p-4 text-center">
              <div className="text-2xl font-bold text-purple-600">{foodData.fatPer100g}</div>
              <div className="text-xs text-gray-600 mt-1">脂肪(g)</div>
            </div>
          </div>

          {/* 食物简介 */}
          {foodInfo?.description && (
            <div className="mb-6 p-4 bg-blue-50 rounded-xl border-l-4 border-blue-500">
              <p className="text-gray-700 leading-relaxed">{foodInfo.description}</p>
            </div>
          )}

          {/* 健康功效 */}
          <div className="mb-6">
            <h3 className="text-lg font-bold text-gray-900 mb-3 flex items-center">
              <span className="mr-2">💊</span>
              健康功效
            </h3>
            <div className="space-y-2">
              {getFoodBenefits(foodData).map((benefit, idx) => (
                <div key={idx} className="flex items-start space-x-2 p-3 bg-green-50 rounded-lg">
                  <span className="text-green-600 mt-0.5">✓</span>
                  <span className="text-gray-700 text-sm">{benefit}</span>
                </div>
              ))}

              {/* 从diet_food_info读取的适用人群 */}
              {foodInfo?.suitableFor && (
                <div className="p-3 bg-green-100 rounded-lg border-l-4 border-green-500">
                  <div className="font-medium text-green-900 mb-1">✓ 适合人群</div>
                  <div className="text-sm text-green-700">{foodInfo.suitableFor}</div>
                </div>
              )}

              {foodInfo?.unsuitableFor && (
                <div className="p-3 bg-red-50 rounded-lg border-l-4 border-red-400">
                  <div className="font-medium text-red-900 mb-1">⚠️ 不适合人群</div>
                  <div className="text-sm text-red-700">{foodInfo.unsuitableFor}</div>
                </div>
              )}
            </div>
          </div>

          {/* AI搭配推荐 */}
          <div className="mb-6">
            <h3 className="text-lg font-bold text-gray-900 mb-3 flex items-center">
              <span className="mr-2">🤖</span>
              AI智能搭配推荐
            </h3>
            <div className="grid grid-cols-3 gap-3">
              {pairings.map((pairing, idx) => (
                <div key={idx} className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl p-4 border border-purple-200 hover:shadow-md transition-shadow">
                  <div className="text-sm font-medium text-gray-900 text-center">
                    {pairing}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* 健康提示 */}
          {getHealthTips(foodData).length > 0 && (
            <div className="mb-6">
              <h3 className="text-lg font-bold text-gray-900 mb-3 flex items-center">
                <span className="mr-2">⚕️</span>
                健康提示
              </h3>
              <div className="space-y-2">
                {getHealthTips(foodData).map((tip, idx) => (
                  <div key={idx} className="flex items-start space-x-2 p-3 bg-yellow-50 rounded-lg border-l-4 border-yellow-400">
                    <span className="text-yellow-600">⚠️</span>
                    <span className="text-gray-700 text-sm">{tip}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* 详细信息 */}
          {foodData.giValue && (
            <div className="grid grid-cols-3 gap-4 p-4 bg-gray-50 rounded-xl">
              <div className="text-center">
                <div className="text-sm text-gray-600 mb-1">GI值</div>
                <div className="text-xl font-bold text-gray-900">{foodData.giValue}</div>
              </div>
              <div className="text-center">
                <div className="text-sm text-gray-600 mb-1">钠含量</div>
                <div className="text-xl font-bold text-gray-900">{foodData.sodiumPer100g || 0}mg</div>
              </div>
              <div className="text-center">
                <div className="text-sm text-gray-600 mb-1">嘌呤</div>
                <div className="text-xl font-bold text-gray-900">{foodData.purinePer100g || 0}mg</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default FoodDetailModal;

