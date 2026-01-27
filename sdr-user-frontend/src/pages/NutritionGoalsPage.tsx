import React, { useState } from 'react';
import { Target, Save, RotateCcw, TrendingUp, Activity, User, Calendar } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

const NutritionGoalsPage: React.FC = () => {
  const [goals, setGoals] = useState({
    calories: 2000,
    protein: 80,
    carbs: 250,
    fat: 55,
    fiber: 25,
    water: 2.5,
    weight: 70,
    targetWeight: 65
  });

  const [activityLevel, setActivityLevel] = useState('moderate');
  const [goalType, setGoalType] = useState('maintain');

  const activityLevels = [
    { id: 'sedentary', name: '久坐不动', multiplier: 1.2, description: '很少或不运动' },
    { id: 'light', name: '轻度活动', multiplier: 1.375, description: '每周1-3次轻度运动' },
    { id: 'moderate', name: '中度活动', multiplier: 1.55, description: '每周3-5次中等运动' },
    { id: 'active', name: '高度活动', multiplier: 1.725, description: '每周6-7次高强度运动' },
    { id: 'very_active', name: '极度活动', multiplier: 1.9, description: '每天高强度运动或体力工作' }
  ];

  const goalTypes = [
    { id: 'lose', name: '减重', color: 'text-red-600', bg: 'bg-red-50', description: '每周减重0.5-1kg' },
    { id: 'maintain', name: '维持', color: 'text-green-600', bg: 'bg-green-50', description: '保持当前体重' },
    { id: 'gain', name: '增重', color: 'text-blue-600', bg: 'bg-blue-50', description: '每周增重0.3-0.5kg' }
  ];

  const handleGoalChange = (key: string, value: number) => {
    setGoals(prev => ({ ...prev, [key]: value }));
  };

  const calculateBMR = () => {
    // 使用Mifflin-St Jeor公式计算基础代谢率
    const bmr = 10 * goals.weight + 6.25 * 170 - 5 * 28 + 5; // 假设身高170cm，年龄28岁
    const activityMultiplier = activityLevels.find(level => level.id === activityLevel)?.multiplier || 1.55;
    return Math.round(bmr * activityMultiplier);
  };

  const getRecommendedCalories = () => {
    const baseCal = calculateBMR();
    switch (goalType) {
      case 'lose': return baseCal - 500;
      case 'gain': return baseCal + 300;
      default: return baseCal;
    }
  };

  const saveGoals = () => {
    // 这里可以调用API保存目标
    alert('营养目标已保存！');
  };

  const resetToRecommended = () => {
    const recommendedCal = getRecommendedCalories();
    setGoals(prev => ({
      ...prev,
      calories: recommendedCal,
      protein: Math.round(recommendedCal * 0.15 / 4),
      carbs: Math.round(recommendedCal * 0.55 / 4),
      fat: Math.round(recommendedCal * 0.30 / 9)
    }));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <Target className="h-6 w-6 text-primary-600" />
          营养目标设置
        </h1>
        <p className="text-gray-600 mt-1">根据您的个人情况设置合适的营养目标</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* 基本信息 */}
        <div className="lg:col-span-1 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5" />
                基本信息
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">目标类型</label>
                <div className="space-y-2">
                  {goalTypes.map((type) => (
                    <button
                      key={type.id}
                      onClick={() => setGoalType(type.id)}
                      className={`w-full p-3 rounded-lg border-2 transition-all ${
                        goalType === type.id
                          ? 'border-primary-500 bg-primary-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className={`font-medium ${type.color}`}>{type.name}</span>
                        <span className="text-xs text-gray-500">{type.description}</span>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">活动水平</label>
                <select
                  value={activityLevel}
                  onChange={(e) => setActivityLevel(e.target.value)}
                  className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  {activityLevels.map((level) => (
                    <option key={level.id} value={level.id}>
                      {level.name} - {level.description}
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">当前体重 (kg)</label>
                  <input
                    type="number"
                    value={goals.weight}
                    onChange={(e) => handleGoalChange('weight', Number(e.target.value))}
                    className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">目标体重 (kg)</label>
                  <input
                    type="number"
                    value={goals.targetWeight}
                    onChange={(e) => handleGoalChange('targetWeight', Number(e.target.value))}
                    className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500"
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5" />
                推荐值
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-gray-600">基础代谢率:</span>
                  <span className="font-medium">{calculateBMR()} 卡</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">推荐卡路里:</span>
                  <span className="font-medium">{getRecommendedCalories()} 卡</span>
                </div>
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={resetToRecommended}
                  className="w-full"
                >
                  <RotateCcw className="h-4 w-4 mr-2" />
                  使用推荐值
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* 营养目标设置 */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Activity className="h-5 w-5" />
                营养目标设置
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* 卡路里 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    每日卡路里目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={goals.calories}
                      onChange={(e) => handleGoalChange('calories', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">卡</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-red-500 h-2 rounded-full"
                      style={{ width: `${Math.min((1847 / goals.calories) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 1847 卡 / 目标: {goals.calories} 卡</p>
                </div>

                {/* 蛋白质 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    蛋白质目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={goals.protein}
                      onChange={(e) => handleGoalChange('protein', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">g</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-blue-500 h-2 rounded-full"
                      style={{ width: `${Math.min((67 / goals.protein) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 67g / 目标: {goals.protein}g</p>
                </div>

                {/* 碳水化合物 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    碳水化合物目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={goals.carbs}
                      onChange={(e) => handleGoalChange('carbs', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">g</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-orange-500 h-2 rounded-full"
                      style={{ width: `${Math.min((231 / goals.carbs) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 231g / 目标: {goals.carbs}g</p>
                </div>

                {/* 脂肪 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    脂肪目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={goals.fat}
                      onChange={(e) => handleGoalChange('fat', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">g</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-purple-500 h-2 rounded-full"
                      style={{ width: `${Math.min((45 / goals.fat) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 45g / 目标: {goals.fat}g</p>
                </div>

                {/* 纤维 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    膳食纤维目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={goals.fiber}
                      onChange={(e) => handleGoalChange('fiber', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">g</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-green-500 h-2 rounded-full"
                      style={{ width: `${Math.min((18 / goals.fiber) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 18g / 目标: {goals.fiber}g</p>
                </div>

                {/* 水分 */}
                <div className="space-y-3">
                  <label className="block text-sm font-medium text-gray-700">
                    每日饮水目标
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      step="0.1"
                      value={goals.water}
                      onChange={(e) => handleGoalChange('water', Number(e.target.value))}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 pr-12"
                    />
                    <span className="absolute right-3 top-3 text-gray-500">L</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-cyan-500 h-2 rounded-full"
                      style={{ width: `${Math.min((1.8 / goals.water) * 100, 100)}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500">当前: 1.8L / 目标: {goals.water}L</p>
                </div>
              </div>

              <div className="flex gap-4 mt-8">
                <Button onClick={saveGoals} className="flex-1">
                  <Save className="h-4 w-4 mr-2" />
                  保存目标
                </Button>
                <Button variant="outline" onClick={resetToRecommended}>
                  <RotateCcw className="h-4 w-4 mr-2" />
                  重置为推荐值
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* 目标预览 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Calendar className="h-5 w-5" />
            目标预览
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center p-4 bg-red-50 rounded-lg">
              <div className="text-2xl font-bold text-red-600">{goals.calories}</div>
              <div className="text-sm text-red-700">卡路里/天</div>
            </div>
            <div className="text-center p-4 bg-blue-50 rounded-lg">
              <div className="text-2xl font-bold text-blue-600">{goals.protein}g</div>
              <div className="text-sm text-blue-700">蛋白质/天</div>
            </div>
            <div className="text-center p-4 bg-orange-50 rounded-lg">
              <div className="text-2xl font-bold text-orange-600">{goals.carbs}g</div>
              <div className="text-sm text-orange-700">碳水/天</div>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-lg">
              <div className="text-2xl font-bold text-purple-600">{goals.fat}g</div>
              <div className="text-sm text-purple-700">脂肪/天</div>
            </div>
          </div>
          
          <div className="mt-4 p-4 bg-gray-50 rounded-lg">
            <h4 className="font-medium text-gray-900 mb-2">预计效果</h4>
            <p className="text-sm text-gray-600">
              根据您的目标设置，预计每周体重变化: 
              <span className="font-medium ml-1">
                {goalType === 'lose' ? '-0.5kg' : goalType === 'gain' ? '+0.3kg' : '维持'}
              </span>
            </p>
            <p className="text-sm text-gray-600 mt-1">
              达到目标体重 {goals.targetWeight}kg 预计需要: 
              <span className="font-medium ml-1">
                {Math.abs(goals.targetWeight - goals.weight) / (goalType === 'lose' ? 0.5 : goalType === 'gain' ? 0.3 : 1)} 周
              </span>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default NutritionGoalsPage;
