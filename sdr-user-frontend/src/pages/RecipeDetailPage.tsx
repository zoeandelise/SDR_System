import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, Clock, Heart } from 'lucide-react';
import api from '../services/api';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

interface Ingredient {
  foodName: string;
  amount?: number;
  unit?: string;
  calories?: number;
  protein?: number;
  fat?: number;
  carbohydrate?: number;
}

interface RecipeDetail {
  id: number;
  title: string;
  mealType: string;
  cookingTime: string;
  servings: number;
  calories: number;
  protein: number;
  fat: number;
  carbohydrate: number;
  foods: string;
  tags: string;
  rating: number;
  favoriteCount: number;
  isFavorited: boolean;
  description: string;
  ingredients: Ingredient[];
  steps: string[];
  nutritionTips: string[];
}

const normalizeMealType = (raw: any) => {
  if (raw === 'breakfast' || raw === 'lunch' || raw === 'dinner') return raw;
  if (raw === 0 || raw === '0') return 'breakfast';
  if (raw === 1 || raw === '1') return 'lunch';
  if (raw === 2 || raw === '2') return 'dinner';
  return 'lunch';
};

const mealTypeLabel = (mealType: string) => {
  if (mealType === 'breakfast') return '早餐';
  if (mealType === 'lunch') return '午餐';
  if (mealType === 'dinner') return '晚餐';
  return '午餐';
};

const RecipeDetailPage: React.FC = () => {
  const navigate = useNavigate();
  const params = useParams();
  const recipeId = useMemo(() => {
    const raw = params.id;
    const n = raw ? Number(raw) : NaN;
    return Number.isFinite(n) ? n : null;
  }, [params.id]);

  const [loading, setLoading] = useState(true);
  const [recipe, setRecipe] = useState<RecipeDetail | null>(null);

  const loadRecipe = async (id: number) => {
    setLoading(true);
    try {
      const res: any = await api.get(`/api/diet/recipe/${id}`);
      if (res?.code === 200 && res.data) {
        const r = res.data;
        const ingredientsRaw = Array.isArray(r.ingredients) ? r.ingredients : [];
        const stepsRaw = Array.isArray(r.steps) ? r.steps : [];
        const tipsRaw = Array.isArray(r.nutritionTips) ? r.nutritionTips : [];

        setRecipe({
          id: r.recipeId || r.id || id,
          title: r.recipeName || r.title || '未命名食谱',
          mealType: normalizeMealType(r.mealType),
          cookingTime: r.cookingTime || '15分钟',
          servings: r.servings || 1,
          calories: r.totalCalories ?? r.calories ?? 0,
          protein: r.totalProtein ?? r.protein ?? 0,
          fat: r.totalFat ?? r.fat ?? 0,
          carbohydrate: r.totalCarbohydrate ?? r.carbohydrate ?? 0,
          foods: r.foods || '',
          tags: r.tags || '',
          rating: r.rating || 0,
          favoriteCount: r.favoriteCount || 0,
          isFavorited: r.isFavorited || false,
          description: r.description || r.recipeName || '',
          ingredients: ingredientsRaw.map((it: any) => ({
            foodName: it.foodName || it.name || '',
            amount: it.amount,
            unit: it.unit,
            calories: it.calories,
            protein: it.protein,
            fat: it.fat,
            carbohydrate: it.carbohydrate,
          })),
          steps: stepsRaw.map((s: any) => String(s)),
          nutritionTips: tipsRaw.map((s: any) => String(s)),
        });
      } else {
        setRecipe(null);
      }
    } catch (e) {
      console.error('加载食谱详情失败:', e);
      setRecipe(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (recipeId) {
      loadRecipe(recipeId);
    } else {
      setLoading(false);
      setRecipe(null);
    }
  }, [recipeId]);

  const toggleFavorite = async () => {
    if (!recipe) return;
    try {
      if (recipe.isFavorited) {
        await api.delete(`/api/diet/recipe/${recipe.id}/favorite`);
        setRecipe(prev => prev ? { ...prev, isFavorited: false, favoriteCount: Math.max((prev.favoriteCount || 0) - 1, 0) } : prev);
      } else {
        await api.post(`/api/diet/recipe/${recipe.id}/favorite`);
        setRecipe(prev => prev ? { ...prev, isFavorited: true, favoriteCount: (prev.favoriteCount || 0) + 1 } : prev);
      }
    } catch (e) {
      console.error('收藏/取消收藏失败:', e);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin" />
      </div>
    );
  }

  if (!recipe) {
    return (
      <div className="space-y-4 animate-fadeIn">
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={() => navigate(-1)}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            返回
          </Button>
        </div>
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-bold text-lg">食谱不存在或加载失败</div>
            <div className="text-gray-700 text-sm mt-2">请返回列表重试</div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      <div className="flex items-center justify-between gap-3">
        <Button variant="outline" onClick={() => navigate(-1)} className="flex-shrink-0">
          <ArrowLeft className="h-4 w-4 mr-2" />
          返回
        </Button>
        <div className="min-w-0 flex-1">
          <div className="text-sm text-gray-600 font-semibold">{mealTypeLabel(recipe.mealType)}</div>
          <h1 className="text-2xl font-bold text-gray-900 truncate">{recipe.title}</h1>
        </div>
        <Button onClick={toggleFavorite} className="flex-shrink-0">
          <Heart className={`h-4 w-4 mr-2 ${recipe.isFavorited ? 'fill-current' : ''}`} />
          {recipe.isFavorited ? '取消收藏' : '收藏'}
        </Button>
      </div>

      {recipe.description ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-semibold mb-2">简介</div>
            <div className="text-gray-700 text-sm leading-relaxed">{recipe.description}</div>
          </CardContent>
        </Card>
      ) : null}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="border-0 shadow-sm">
          <CardContent className="p-4">
            <div className="text-sm text-gray-600 font-semibold flex items-center gap-2">
              <Clock className="h-4 w-4" />
              用时
            </div>
            <div className="text-lg font-bold text-gray-900 mt-1">{recipe.cookingTime}</div>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-sm">
          <CardContent className="p-4">
            <div className="text-sm text-gray-600 font-semibold">人份</div>
            <div className="text-lg font-bold text-gray-900 mt-1">{recipe.servings}</div>
          </CardContent>
        </Card>
        <Card className="border-0 shadow-sm">
          <CardContent className="p-4">
            <div className="text-sm text-gray-600 font-semibold">收藏数</div>
            <div className="text-lg font-bold text-gray-900 mt-1">{recipe.favoriteCount}</div>
          </CardContent>
        </Card>
      </div>

      <Card className="border-0 shadow-sm">
        <CardContent className="p-6">
          <div className="text-gray-900 font-semibold mb-3">营养信息</div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm">
            <div className="p-3 bg-orange-50 rounded-lg">
              <div className="text-orange-600 font-bold text-lg">{recipe.calories}</div>
              <div className="text-orange-700 font-semibold">卡路里</div>
            </div>
            <div className="p-3 bg-blue-50 rounded-lg">
              <div className="text-blue-600 font-bold text-lg">{recipe.protein}g</div>
              <div className="text-blue-700 font-semibold">蛋白质</div>
            </div>
            <div className="p-3 bg-emerald-50 rounded-lg">
              <div className="text-emerald-600 font-bold text-lg">{recipe.fat}g</div>
              <div className="text-emerald-700 font-semibold">脂肪</div>
            </div>
            <div className="p-3 bg-purple-50 rounded-lg">
              <div className="text-purple-600 font-bold text-lg">{recipe.carbohydrate}g</div>
              <div className="text-purple-700 font-semibold">碳水</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {recipe.tags ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-semibold mb-3">标签</div>
            <div className="flex flex-wrap gap-2">
              {recipe.tags.split(',').map((tag, i) => (
                <span key={i} className="px-3 py-1 bg-primary-50 text-primary-700 text-sm rounded-full font-semibold">{tag.trim()}</span>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}

      {recipe.ingredients.length > 0 ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-semibold mb-3">所需食材</div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {recipe.ingredients.map((it, idx) => (
                <div key={idx} className="p-3 bg-gray-50 rounded-lg">
                  <div className="text-gray-900 font-bold">{it.foodName}</div>
                  {(it.amount !== undefined || it.unit) ? (
                    <div className="text-gray-700 text-sm mt-1">{it.amount ?? ''}{it.unit ?? ''}</div>
                  ) : null}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}

      {recipe.steps.length > 0 ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-semibold mb-3">制作步骤</div>
            <div className="space-y-3">
              {recipe.steps.map((s, idx) => (
                <div key={idx} className="flex items-start gap-3">
                  <div className="w-7 h-7 rounded-full bg-emerald-600 text-white flex items-center justify-center text-sm font-bold flex-shrink-0">{idx + 1}</div>
                  <div className="text-gray-800 text-sm leading-relaxed">{s}</div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}

      {recipe.nutritionTips.length > 0 ? (
        <Card className="border-0 shadow-sm">
          <CardContent className="p-6">
            <div className="text-gray-900 font-semibold mb-3">营养建议</div>
            <div className="space-y-2">
              {recipe.nutritionTips.map((s, idx) => (
                <div key={idx} className="text-gray-800 text-sm">{s}</div>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
};

export default RecipeDetailPage;
