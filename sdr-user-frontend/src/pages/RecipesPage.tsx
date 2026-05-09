import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Search, Clock, Heart } from 'lucide-react';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import api from '../services/api';

interface Recipe {
  id: number;
  title: string;
  mealType: string;
  cookingTime: string;
  servings: number;
  calories: number;
  protein: number;
  foods: string;
  tags: string;
  rating: number;
  favoriteCount: number;
  isFavorited: boolean;
  description: string;
}

const normalizeMealType = (raw: any) => {
  if (raw === 'breakfast' || raw === 'lunch' || raw === 'dinner') return raw;
  if (raw === 0 || raw === '0') return 'breakfast';
  if (raw === 1 || raw === '1') return 'lunch';
  if (raw === 2 || raw === '2') return 'dinner';
  return 'lunch';
};

const RecipesPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedMealType, setSelectedMealType] = useState('all');

  const mealTypes = [
    { id: 'all', name: '全部' },
    { id: 'breakfast', name: '早餐' },
    { id: 'lunch', name: '午餐' },
    { id: 'dinner', name: '晚餐' },
  ];

  useEffect(() => {
    loadRecipes();
  }, []);

  const loadRecipes = async () => {
    setLoading(true);
    try {
      const res: any = await api.get('/api/diet/recipe/list');
      if (res.code === 200 && res.data) {
        const list = Array.isArray(res.data)
          ? res.data
          : (res.data.recipes || res.data.data || res.data.list || []);
        setRecipes(list.map((r: any) => ({
          id: r.recipeId || r.id,
          title: r.recipeName || r.title || '未命名食谱',
          mealType: normalizeMealType(r.mealType),
          cookingTime: r.cookingTime || '15分钟',
          servings: r.servings || 1,
          calories: r.totalCalories ?? r.calories ?? 0,
          protein: r.totalProtein ?? r.protein ?? 0,
          foods: r.foods || '',
          tags: r.tags || '',
          rating: r.rating || 0,
          favoriteCount: r.favoriteCount || 0,
          isFavorited: r.isFavorited || false,
          description: r.description || r.recipeName || '',
        })));
      }
    } catch (err) {
      console.error('加载食谱失败:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async () => {
    if (!searchTerm) {
      loadRecipes();
      return;
    }
    setLoading(true);
    try {
      const res: any = await api.get('/api/diet/recipe/search', {
        params: { keyword: searchTerm }
      });
      if (res.code === 200 && res.data) {
        const list = Array.isArray(res.data)
          ? res.data
          : (res.data.recipes || res.data.data || res.data.list || []);
        setRecipes(list.map((r: any) => ({
          id: r.recipeId || r.id,
          title: r.recipeName || r.title || '未命名食谱',
          mealType: normalizeMealType(r.mealType),
          cookingTime: r.cookingTime || '15分钟',
          servings: r.servings || 1,
          calories: r.totalCalories ?? r.calories ?? 0,
          protein: r.totalProtein ?? r.protein ?? 0,
          foods: r.foods || '',
          tags: r.tags || '',
          rating: r.rating || 0,
          favoriteCount: r.favoriteCount || 0,
          isFavorited: r.isFavorited || false,
          description: r.description || r.recipeName || '',
        })));
      }
    } catch (err) {
      console.error('搜索食谱失败:', err);
    } finally {
      setLoading(false);
    }
  };

  const toggleFavorite = async (recipeId: number) => {
    try {
      const current = recipes.find(r => r.id === recipeId);
      const isFavorited = !!current?.isFavorited;
      if (isFavorited) {
        await api.delete(`/api/diet/recipe/${recipeId}/favorite`);
        setRecipes(prev => prev.map(r => r.id === recipeId ? { ...r, isFavorited: false, favoriteCount: Math.max((r.favoriteCount || 0) - 1, 0) } : r));
      } else {
        await api.post(`/api/diet/recipe/${recipeId}/favorite`);
        setRecipes(prev => prev.map(r => r.id === recipeId ? { ...r, isFavorited: true, favoriteCount: (r.favoriteCount || 0) + 1 } : r));
      }
    } catch (err) {
      console.error('收藏/取消收藏失败:', err);
    }
  };

  const filteredRecipes = recipes.filter(r => {
    const matchMeal = selectedMealType === 'all' || r.mealType === selectedMealType;
    return matchMeal;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <BookOpen className="h-6 w-6 text-primary-600" />
          食谱推荐
        </h1>
        <p className="text-gray-700 mt-1">发现健康美味的食谱</p>
      </div>

      {/* 搜索 */}
      <div className="flex gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="搜索食谱..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-primary-500 text-gray-900 placeholder:text-gray-400"
          />
        </div>
        <Button onClick={handleSearch}>搜索</Button>
      </div>

      {/* 分类 */}
      <div className="flex flex-wrap gap-2">
        {mealTypes.map((mt) => (
          <button
            key={mt.id}
            onClick={() => setSelectedMealType(mt.id)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selectedMealType === mt.id ? 'bg-primary-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
          >
            {mt.name}
          </button>
        ))}
      </div>

      {/* 食谱列表 */}
      {filteredRecipes.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRecipes.map((recipe) => (
            <Card
              key={recipe.id}
              className="hover:shadow-lg transition-shadow cursor-pointer group"
              onClick={() => navigate(`/recipes/${recipe.id}`)}
            >
              <CardContent className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-semibold text-gray-900">{recipe.title}</h3>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      toggleFavorite(recipe.id);
                    }}
                    className="p-1"
                  >
                    <Heart className={`h-5 w-5 ${recipe.isFavorited ? 'text-red-500 fill-current' : 'text-gray-400 hover:text-red-400'}`} />
                  </button>
                </div>

                {recipe.description && (
                  <p className="text-sm text-gray-600 mb-3">{recipe.description}</p>
                )}

                {recipe.tags && (
                  <div className="flex flex-wrap gap-1 mb-3">
                    {recipe.tags.split(',').slice(0, 3).map((tag, i) => (
                      <span key={i} className="px-2 py-1 bg-primary-50 text-primary-700 text-xs rounded-full">{tag.trim()}</span>
                    ))}
                  </div>
                )}

                <div className="grid grid-cols-3 gap-2 mb-3 text-xs">
                  <div className="text-center p-2 bg-orange-50 rounded">
                    <div className="font-medium text-orange-600">{recipe.calories}</div>
                    <div className="text-orange-500">卡路里</div>
                  </div>
                  <div className="text-center p-2 bg-blue-50 rounded">
                    <div className="font-medium text-blue-600">{recipe.protein}g</div>
                    <div className="text-blue-500">蛋白质</div>
                  </div>
                  <div className="text-center p-2 bg-green-50 rounded">
                    <div className="font-medium text-green-600">{recipe.servings}</div>
                    <div className="text-green-500">人份</div>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1 text-sm text-gray-600">
                    <Clock className="h-4 w-4" />
                    {recipe.cookingTime}
                  </div>
                  <Button
                    size="sm"
                    onClick={(e) => {
                      e.stopPropagation();
                      navigate(`/recipes/${recipe.id}`);
                    }}
                  >
                    查看详情
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="text-center py-16">
          <div className="text-5xl mb-4">📖</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">暂无食谱</h3>
          <p className="text-sm text-gray-600">通过智能推荐生成您的专属食谱</p>
        </div>
      )}

    </div>
  );
};

export default RecipesPage;
