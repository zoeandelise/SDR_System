import React, { useState } from 'react';
import { BookOpen, Search, Filter, Clock, Users, Star, Heart, ChefHat, Flame } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

const RecipesPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedDifficulty, setSelectedDifficulty] = useState('all');
  const [selectedTime, setSelectedTime] = useState('all');

  const categories = [
    { id: 'all', name: '全部', count: 156 },
    { id: 'breakfast', name: '早餐', count: 32 },
    { id: 'lunch', name: '午餐', count: 45 },
    { id: 'dinner', name: '晚餐', count: 38 },
    { id: 'snack', name: '小食', count: 24 },
    { id: 'soup', name: '汤品', count: 17 }
  ];

  const difficulties = [
    { id: 'all', name: '全部难度' },
    { id: 'easy', name: '简单', icon: '⭐' },
    { id: 'medium', name: '中等', icon: '⭐⭐' },
    { id: 'hard', name: '困难', icon: '⭐⭐⭐' }
  ];

  const timeRanges = [
    { id: 'all', name: '全部时间' },
    { id: 'quick', name: '15分钟内' },
    { id: 'medium', name: '15-30分钟' },
    { id: 'long', name: '30分钟以上' }
  ];

  const recipes = [
    {
      id: 1,
      title: '蒸蛋羹配蔬菜',
      category: 'breakfast',
      difficulty: 'easy',
      time: 15,
      servings: 2,
      calories: 180,
      protein: 12,
      image: '🥚',
      rating: 4.8,
      likes: 234,
      isLiked: true,
      tags: ['高蛋白', '低卡路里', '营养均衡'],
      description: '嫩滑的蒸蛋羹搭配新鲜蔬菜，营养丰富，制作简单',
      ingredients: ['鸡蛋 2个', '胡萝卜 50g', '西兰花 50g', '盐 适量'],
      steps: [
        '将鸡蛋打散，加入温水搅拌均匀',
        '胡萝卜和西兰花切小丁，焯水备用',
        '蛋液过筛倒入碗中，加入蔬菜丁',
        '蒸锅水开后蒸10-12分钟即可'
      ]
    },
    {
      id: 2,
      title: '鸡胸肉沙拉',
      category: 'lunch',
      difficulty: 'easy',
      time: 20,
      servings: 1,
      calories: 320,
      protein: 35,
      image: '🥗',
      rating: 4.6,
      likes: 189,
      isLiked: false,
      tags: ['高蛋白', '低脂', '减脂'],
      description: '新鲜蔬菜搭配嫩滑鸡胸肉，健康美味的减脂餐',
      ingredients: ['鸡胸肉 150g', '生菜 100g', '番茄 1个', '黄瓜 1根'],
      steps: [
        '鸡胸肉用盐和黑胡椒腌制10分钟',
        '平底锅少油煎制鸡胸肉至熟透',
        '蔬菜洗净切块装盘',
        '鸡胸肉切片摆在蔬菜上即可'
      ]
    },
    {
      id: 3,
      title: '番茄鸡蛋面',
      category: 'dinner',
      difficulty: 'medium',
      time: 25,
      servings: 2,
      calories: 420,
      protein: 18,
      image: '🍝',
      rating: 4.9,
      likes: 456,
      isLiked: true,
      tags: ['家常菜', '营养丰富', '经典'],
      description: '经典的家常面条，酸甜可口，营养全面',
      ingredients: ['挂面 200g', '鸡蛋 2个', '番茄 2个', '葱花 适量'],
      steps: [
        '番茄去皮切块，鸡蛋打散',
        '热锅炒鸡蛋盛起备用',
        '炒番茄出汁，加入鸡蛋翻炒',
        '加水煮开，下面条煮熟即可'
      ]
    },
    {
      id: 4,
      title: '燕麦酸奶杯',
      category: 'snack',
      difficulty: 'easy',
      time: 5,
      servings: 1,
      calories: 250,
      protein: 15,
      image: '🥛',
      rating: 4.7,
      likes: 167,
      isLiked: false,
      tags: ['快手', '高纤维', '益生菌'],
      description: '层次丰富的酸奶杯，美味又健康的下午茶',
      ingredients: ['燕麦片 50g', '酸奶 200ml', '蓝莓 30g', '蜂蜜 适量'],
      steps: [
        '燕麦片用热水泡软',
        '杯子底部放入燕麦片',
        '倒入酸奶，撒上蓝莓',
        '淋上蜂蜜即可享用'
      ]
    },
    {
      id: 5,
      title: '冬瓜排骨汤',
      category: 'soup',
      difficulty: 'medium',
      time: 60,
      servings: 4,
      calories: 180,
      protein: 20,
      image: '🍲',
      rating: 4.5,
      likes: 298,
      isLiked: true,
      tags: ['清淡', '滋补', '去火'],
      description: '清香的冬瓜排骨汤，清热去火，营养滋补',
      ingredients: ['排骨 500g', '冬瓜 300g', '姜片 3片', '盐 适量'],
      steps: [
        '排骨焯水去血沫',
        '锅中加水，放入排骨和姜片',
        '大火煮开转小火炖40分钟',
        '加入冬瓜块煮15分钟，调味即可'
      ]
    },
    {
      id: 6,
      title: '牛油果吐司',
      category: 'breakfast',
      difficulty: 'easy',
      time: 10,
      servings: 1,
      calories: 280,
      protein: 8,
      image: '🥑',
      rating: 4.4,
      likes: 145,
      isLiked: false,
      tags: ['健康脂肪', '快手', '网红'],
      description: '简单美味的牛油果吐司，富含健康脂肪',
      ingredients: ['全麦面包 2片', '牛油果 1个', '柠檬汁 几滴', '盐 少许'],
      steps: [
        '面包片烤至微黄',
        '牛油果压成泥，加柠檬汁和盐',
        '将牛油果泥涂在吐司上',
        '可撒些黑胡椒粉装饰'
      ]
    }
  ];

  const [selectedRecipe, setSelectedRecipe] = useState<typeof recipes[0] | null>(null);

  const filteredRecipes = recipes.filter(recipe => {
    const matchesSearch = recipe.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         recipe.tags.some(tag => tag.includes(searchTerm));
    const matchesCategory = selectedCategory === 'all' || recipe.category === selectedCategory;
    const matchesDifficulty = selectedDifficulty === 'all' || recipe.difficulty === selectedDifficulty;
    const matchesTime = selectedTime === 'all' || 
                       (selectedTime === 'quick' && recipe.time <= 15) ||
                       (selectedTime === 'medium' && recipe.time > 15 && recipe.time <= 30) ||
                       (selectedTime === 'long' && recipe.time > 30);
    
    return matchesSearch && matchesCategory && matchesDifficulty && matchesTime;
  });

  const toggleLike = (recipeId: number) => {
    // 这里可以调用API更新收藏状态
    console.log('Toggle like for recipe:', recipeId);
  };

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'easy': return 'text-green-600 bg-green-50';
      case 'medium': return 'text-yellow-600 bg-yellow-50';
      case 'hard': return 'text-red-600 bg-red-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <BookOpen className="h-6 w-6 text-primary-600" />
          食谱推荐
        </h1>
        <p className="text-gray-600 mt-1">发现健康美味的食谱，享受烹饪的乐趣</p>
      </div>

      {/* 搜索和筛选 */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="搜索食谱名称或标签..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>
            
            <select
              value={selectedDifficulty}
              onChange={(e) => setSelectedDifficulty(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500"
            >
              {difficulties.map((difficulty) => (
                <option key={difficulty.id} value={difficulty.id}>
                  {difficulty.name}
                </option>
              ))}
            </select>
            
            <select
              value={selectedTime}
              onChange={(e) => setSelectedTime(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500"
            >
              {timeRanges.map((time) => (
                <option key={time.id} value={time.id}>
                  {time.name}
                </option>
              ))}
            </select>
          </div>
        </CardContent>
      </Card>

      {/* 分类标签 */}
      <div className="flex flex-wrap gap-2">
        {categories.map((category) => (
          <button
            key={category.id}
            onClick={() => setSelectedCategory(category.id)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
              selectedCategory === category.id
                ? 'bg-primary-500 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            {category.name} ({category.count})
          </button>
        ))}
      </div>

      {/* 推荐食谱 */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredRecipes.map((recipe) => (
          <Card key={recipe.id} className="hover:shadow-lg transition-shadow cursor-pointer group">
            <CardContent className="p-0">
              {/* 食谱图片区域 */}
              <div className="relative p-6 bg-gradient-to-br from-gray-50 to-gray-100">
                <div className="text-6xl text-center mb-4">{recipe.image}</div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    toggleLike(recipe.id);
                  }}
                  className="absolute top-4 right-4 p-2 rounded-full bg-white shadow-md hover:shadow-lg transition-all"
                >
                  <Heart className={`h-4 w-4 ${recipe.isLiked ? 'text-red-500 fill-current' : 'text-gray-400'}`} />
                </button>
                
                {/* 难度标签 */}
                <div className={`absolute top-4 left-4 px-2 py-1 rounded-full text-xs font-medium ${getDifficultyColor(recipe.difficulty)}`}>
                  {difficulties.find(d => d.id === recipe.difficulty)?.icon} 
                  {difficulties.find(d => d.id === recipe.difficulty)?.name}
                </div>
              </div>

              <div className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-semibold text-gray-900 group-hover:text-primary-600 transition-colors">
                    {recipe.title}
                  </h3>
                  <div className="flex items-center gap-1 text-sm text-gray-600">
                    <Star className="h-4 w-4 text-yellow-500 fill-current" />
                    {recipe.rating}
                  </div>
                </div>

                <p className="text-sm text-gray-600 mb-3 line-clamp-2">{recipe.description}</p>

                {/* 标签 */}
                <div className="flex flex-wrap gap-1 mb-3">
                  {recipe.tags.slice(0, 2).map((tag, index) => (
                    <span key={index} className="px-2 py-1 bg-primary-50 text-primary-700 text-xs rounded-full">
                      {tag}
                    </span>
                  ))}
                  {recipe.tags.length > 2 && (
                    <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full">
                      +{recipe.tags.length - 2}
                    </span>
                  )}
                </div>

                {/* 营养信息 */}
                <div className="grid grid-cols-3 gap-2 mb-4 text-xs">
                  <div className="text-center p-2 bg-red-50 rounded">
                    <Flame className="h-3 w-3 text-red-500 mx-auto mb-1" />
                    <div className="font-medium text-red-600">{recipe.calories}</div>
                    <div className="text-red-500">卡路里</div>
                  </div>
                  <div className="text-center p-2 bg-blue-50 rounded">
                    <ChefHat className="h-3 w-3 text-blue-500 mx-auto mb-1" />
                    <div className="font-medium text-blue-600">{recipe.protein}g</div>
                    <div className="text-blue-500">蛋白质</div>
                  </div>
                  <div className="text-center p-2 bg-green-50 rounded">
                    <Users className="h-3 w-3 text-green-500 mx-auto mb-1" />
                    <div className="font-medium text-green-600">{recipe.servings}</div>
                    <div className="text-green-500">人份</div>
                  </div>
                </div>

                {/* 时间和操作 */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1 text-sm text-gray-600">
                    <Clock className="h-4 w-4" />
                    {recipe.time} 分钟
                  </div>
                  <Button 
                    size="sm" 
                    onClick={() => setSelectedRecipe(recipe)}
                    className="opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    查看详情
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* 食谱详情弹窗 */}
      {selectedRecipe && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-2xl font-bold text-gray-900">{selectedRecipe.title}</h2>
                <button
                  onClick={() => setSelectedRecipe(null)}
                  className="p-2 hover:bg-gray-100 rounded-full"
                >
                  ✕
                </button>
              </div>

              <div className="text-center mb-6">
                <div className="text-8xl mb-4">{selectedRecipe.image}</div>
                <p className="text-gray-600">{selectedRecipe.description}</p>
              </div>

              {/* 营养信息 */}
              <div className="grid grid-cols-4 gap-4 mb-6">
                <div className="text-center p-3 bg-red-50 rounded-lg">
                  <div className="text-xl font-bold text-red-600">{selectedRecipe.calories}</div>
                  <div className="text-sm text-red-500">卡路里</div>
                </div>
                <div className="text-center p-3 bg-blue-50 rounded-lg">
                  <div className="text-xl font-bold text-blue-600">{selectedRecipe.protein}g</div>
                  <div className="text-sm text-blue-500">蛋白质</div>
                </div>
                <div className="text-center p-3 bg-green-50 rounded-lg">
                  <div className="text-xl font-bold text-green-600">{selectedRecipe.servings}</div>
                  <div className="text-sm text-green-500">人份</div>
                </div>
                <div className="text-center p-3 bg-orange-50 rounded-lg">
                  <div className="text-xl font-bold text-orange-600">{selectedRecipe.time}</div>
                  <div className="text-sm text-orange-500">分钟</div>
                </div>
              </div>

              {/* 食材 */}
              <div className="mb-6">
                <h3 className="text-lg font-semibold mb-3">所需食材</h3>
                <div className="grid grid-cols-2 gap-2">
                  {selectedRecipe.ingredients.map((ingredient, index) => (
                    <div key={index} className="flex items-center gap-2 p-2 bg-gray-50 rounded">
                      <div className="w-2 h-2 bg-primary-500 rounded-full"></div>
                      <span className="text-sm">{ingredient}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* 制作步骤 */}
              <div className="mb-6">
                <h3 className="text-lg font-semibold mb-3">制作步骤</h3>
                <div className="space-y-3">
                  {selectedRecipe.steps.map((step, index) => (
                    <div key={index} className="flex gap-3">
                      <div className="w-6 h-6 bg-primary-500 text-white rounded-full flex items-center justify-center text-sm font-medium">
                        {index + 1}
                      </div>
                      <p className="text-sm text-gray-700 flex-1">{step}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* 操作按钮 */}
              <div className="flex gap-3">
                <Button className="flex-1">
                  <Heart className="h-4 w-4 mr-2" />
                  收藏食谱
                </Button>
                <Button variant="outline" className="flex-1">
                  添加到计划
                </Button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 无结果提示 */}
      {filteredRecipes.length === 0 && (
        <Card>
          <CardContent className="p-12 text-center">
            <div className="text-4xl mb-4">🔍</div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">未找到相关食谱</h3>
            <p className="text-gray-600">请尝试调整搜索条件或筛选选项</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default RecipesPage;
