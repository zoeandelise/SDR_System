// 简化版食物库页面 - 展示55种真实食物
import React, { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { useNavigate, useLocation } from 'react-router-dom';
import { foodApi } from '../services/api';
import { Card, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

interface FoodInfo {
  foodId: number;
  foodName: string;
  categoryName: string;
  caloriesPer100g: number;
  proteinPer100g: number;
  fatPer100g: number;
  carbohydratePer100g: number;
}

const SimpleFoodDatabasePage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [foods, setFoods] = useState<FoodInfo[]>([]);
  const [filteredFoods, setFilteredFoods] = useState<FoodInfo[]>([]);
  const [searchKeyword, setSearchKeyword] = useState('');
  const [loading, setLoading] = useState(false);
  const [selectedFood, setSelectedFood] = useState<FoodInfo | null>(null);

  const preselectFoodId = (() => {
    try {
      const sp = new URLSearchParams(location.search);
      const raw = sp.get('foodId');
      const n = raw ? Number(raw) : NaN;
      return Number.isFinite(n) ? n : null;
    } catch {
      return null;
    }
  })();

  useEffect(() => {
    loadFoods();
  }, []);

  useEffect(() => {
    if (!preselectFoodId || foods.length === 0) return;
    const found = foods.find(f => f.foodId === preselectFoodId);
    if (found) {
      setSelectedFood(found);
    }
  }, [preselectFoodId, foods]);

  useEffect(() => {
    if (searchKeyword.trim()) {
      setFilteredFoods(foods.filter(f =>
        f.foodName.includes(searchKeyword) ||
        f.categoryName.includes(searchKeyword)
      ));
    } else {
      setFilteredFoods(foods);
    }
  }, [searchKeyword, foods]);

  const loadFoods = async () => {
    try {
      setLoading(true);
      const response: any = await foodApi.getAllFoods({});
      if (response.code === 200 && response.data) {
        setFoods(response.data);
        setFilteredFoods(response.data);
      }
    } catch (error) {
      console.error('加载食物失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const categoryColors: { [key: string]: string } = {
    '谷物类': 'bg-yellow-100 text-yellow-800 border-yellow-200',
    '蔬菜类': 'bg-green-100 text-green-800 border-green-200',
    '水果类': 'bg-red-100 text-red-800 border-red-200',
    '肉类': 'bg-orange-100 text-orange-800 border-orange-200',
    '海鲜类': 'bg-blue-100 text-blue-800 border-blue-200',
    '蛋奶类': 'bg-purple-100 text-purple-800 border-purple-200',
    '豆类坚果': 'bg-amber-100 text-amber-800 border-amber-200',
    '饮品类': 'bg-cyan-100 text-cyan-800 border-cyan-200'
  };

  return (
    <div className="animate-fadeIn">

      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">食物营养库</h1>
        <p className="text-gray-500">查阅 50+ 种常见食物的精准营养数据，吃得更明白</p>
      </div>

      {/* 搜索栏 */}
      <div className="max-w-2xl mx-auto mb-10">
        <div className="relative group">
          <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
            <span className="text-gray-400 text-xl group-focus-within:text-primary-500 transition-colors">🔍</span>
          </div>
          <input
            type="text"
            placeholder="搜索食物名称（如：燕麦）或分类..."
            value={searchKeyword}
            onChange={(e) => setSearchKeyword(e.target.value)}
            className="w-full pl-12 pr-4 py-4 border-2 border-gray-100 rounded-2xl shadow-sm focus:ring-4 focus:ring-primary-100 focus:border-primary-500 transition-all outline-none text-lg bg-white"
          />
          <div className="absolute inset-y-0 right-0 pr-4 flex items-center">
            <span className="text-sm text-gray-600 bg-gray-50 px-2 py-1 rounded-md">
              {filteredFoods.length} 结果
            </span>
          </div>
        </div>
      </div>

      {loading ? (
        <div className="text-center py-20">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-primary-200 border-t-primary-600"></div>
          <p className="mt-4 text-gray-600 font-medium">数据加载中...</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filteredFoods.map((food) => (
            <Card
              key={food.foodId}
              onClick={() => setSelectedFood(food)}
              hoverEffect={true}
              className="cursor-pointer group h-full flex flex-col"
            >
              <div className="flex items-start justify-between mb-4">
                <h3 className="font-bold text-gray-900 text-lg group-hover:text-primary-600 transition-colors line-clamp-1">
                  {food.foodName}
                </h3>
                <span className={`text-[10px] uppercase font-bold px-2 py-1 rounded-md border ${categoryColors[food.categoryName] || 'bg-gray-100 text-gray-800 border-gray-200'}`}>
                  {food.categoryName}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2 text-xs mt-auto">
                <div className="bg-orange-50 rounded-lg p-2 text-center border border-orange-100">
                  <div className="text-orange-400 mb-0.5 scale-75 origin-center uppercase tracking-wide">热量</div>
                  <div className="font-bold text-gray-800 text-sm">{food.caloriesPer100g}</div>
                </div>
                <div className="bg-blue-50 rounded-lg p-2 text-center border border-blue-100">
                  <div className="text-blue-400 mb-0.5 scale-75 origin-center uppercase tracking-wide">蛋白</div>
                  <div className="font-bold text-gray-800 text-sm">{food.proteinPer100g}g</div>
                </div>
                <div className="bg-yellow-50 rounded-lg p-2 text-center border border-yellow-100">
                  <div className="text-yellow-600 mb-0.5 scale-75 origin-center uppercase tracking-wide">碳水</div>
                  <div className="font-bold text-gray-800 text-sm">{food.carbohydratePer100g}g</div>
                </div>
                <div className="bg-purple-50 rounded-lg p-2 text-center border border-purple-100">
                  <div className="text-purple-400 mb-0.5 scale-75 origin-center uppercase tracking-wide">脂肪</div>
                  <div className="font-bold text-gray-800 text-sm">{food.fatPer100g}g</div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {selectedFood && typeof document !== 'undefined' && createPortal(
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[9999] p-4 animate-fadeIn" onClick={() => setSelectedFood(null)}>
          <div className="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl animate-scaleIn relative overflow-hidden" onClick={e => e.stopPropagation()}>
            <div className="absolute top-0 left-0 right-0 h-28 bg-gradient-to-br from-emerald-500 to-teal-500 opacity-10"></div>
            <div className="relative z-10">
              <div className="flex justify-between items-start mb-6">
                <div>
                  <span className={`inline-block px-2 py-1 rounded-md text-xs font-bold border mb-2 ${categoryColors[selectedFood.categoryName] || 'bg-gray-100 text-gray-800 border-gray-200'}`}>
                    {selectedFood.categoryName}
                  </span>
                  <h3 className="text-2xl font-black text-gray-900 leading-tight">{selectedFood.foodName}</h3>
                </div>
                <button
                  onClick={() => setSelectedFood(null)}
                  className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 hover:bg-gray-200 transition-colors"
                >
                  ✕
                </button>
              </div>

              <div className="space-y-4">
                <div className="bg-gray-50 rounded-2xl p-5 border border-gray-100 text-center">
                  <div className="text-sm text-gray-500 mb-1 font-semibold">能量密度</div>
                  <div className="text-4xl font-black text-emerald-600 inline-block">
                    {selectedFood.caloriesPer100g}
                    <span className="text-base font-normal text-gray-500 ml-1">kcal</span>
                  </div>
                  <div className="text-xs text-gray-500 mt-1">每 100 克</div>
                </div>

                <div className="grid grid-cols-3 gap-3">
                  <div className="bg-blue-50 rounded-xl p-3 text-center border border-blue-100">
                    <div className="text-xs text-blue-600 font-bold mb-1">蛋白质</div>
                    <div className="text-xl font-bold text-gray-900">{selectedFood.proteinPer100g}<span className="text-xs font-normal">g</span></div>
                  </div>
                  <div className="bg-yellow-50 rounded-xl p-3 text-center border border-yellow-100">
                    <div className="text-xs text-yellow-600 font-bold mb-1">碳水</div>
                    <div className="text-xl font-bold text-gray-900">{selectedFood.carbohydratePer100g}<span className="text-xs font-normal">g</span></div>
                  </div>
                  <div className="bg-purple-50 rounded-xl p-3 text-center border border-purple-100">
                    <div className="text-xs text-purple-600 font-bold mb-1">脂肪</div>
                    <div className="text-xl font-bold text-gray-900">{selectedFood.fatPer100g}<span className="text-xs font-normal">g</span></div>
                  </div>
                </div>

                <div className="bg-emerald-50 rounded-xl p-4 border border-emerald-100">
                  <div className="text-xs text-emerald-700 font-bold mb-2">营养占比</div>
                  <div className="space-y-2">
                    {(() => {
                      const total = selectedFood.proteinPer100g + selectedFood.carbohydratePer100g + selectedFood.fatPer100g;
                      if (total === 0) return null;
                      const pPct = Math.round(selectedFood.proteinPer100g / total * 100);
                      const cPct = Math.round(selectedFood.carbohydratePer100g / total * 100);
                      const fPct = 100 - pPct - cPct;
                      return (
                        <div className="flex h-3 rounded-full overflow-hidden bg-gray-200">
                          <div className="bg-blue-400" style={{ width: `${pPct}%` }} title={`蛋白质 ${pPct}%`} />
                          <div className="bg-yellow-400" style={{ width: `${cPct}%` }} title={`碳水 ${cPct}%`} />
                          <div className="bg-purple-400" style={{ width: `${fPct}%` }} title={`脂肪 ${fPct}%`} />
                        </div>
                      );
                    })()}
                    <div className="flex justify-between text-[10px] font-semibold text-gray-500">
                      <span className="text-blue-600">蛋白</span>
                      <span className="text-yellow-600">碳水</span>
                      <span className="text-purple-600">脂肪</span>
                    </div>
                  </div>
                </div>
              </div>

              <Button
                onClick={() => setSelectedFood(null)}
                className="mt-6 w-full shadow-lg hover:shadow-emerald-500/30"
                size="lg"
              >
                我知道了
              </Button>
            </div>
          </div>
        </div>,
        document.body
      )}
    </div>
  );
};

export default SimpleFoodDatabasePage;

