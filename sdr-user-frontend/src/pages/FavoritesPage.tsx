import React, { useState } from 'react';
import { Star, Search, Filter, Trash2, Share2, Calendar, Clock, Users, Heart } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

const FavoritesPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState('recipes');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedItems, setSelectedItems] = useState<number[]>([]);

  const tabs = [
    { id: 'recipes', name: '食谱收藏', icon: '📖', count: 24 },
    { id: 'foods', name: '食物收藏', icon: '🥗', count: 18 },
    { id: 'posts', name: '动态收藏', icon: '📱', count: 12 },
    { id: 'articles', name: '文章收藏', icon: '📄', count: 8 }
  ];

  const favoriteRecipes = [
    {
      id: 1,
      title: '蒸蛋羹配蔬菜',
      category: '早餐',
      time: 15,
      servings: 2,
      calories: 180,
      rating: 4.8,
      image: '🥚',
      tags: ['高蛋白', '低卡路里'],
      addedDate: '2024-09-25',
      author: '健康厨房'
    },
    {
      id: 2,
      title: '鸡胸肉沙拉',
      category: '午餐',
      time: 20,
      servings: 1,
      calories: 320,
      rating: 4.6,
      image: '🥗',
      tags: ['高蛋白', '减脂'],
      addedDate: '2024-09-24',
      author: '营养师小李'
    },
    {
      id: 3,
      title: '番茄鸡蛋面',
      category: '晚餐',
      time: 25,
      servings: 2,
      calories: 420,
      rating: 4.9,
      image: '🍝',
      tags: ['家常菜', '营养丰富'],
      addedDate: '2024-09-23',
      author: '美食达人'
    },
    {
      id: 4,
      title: '燕麦酸奶杯',
      category: '小食',
      time: 5,
      servings: 1,
      calories: 250,
      rating: 4.7,
      image: '🥛',
      tags: ['快手', '高纤维'],
      addedDate: '2024-09-22',
      author: '轻食生活'
    }
  ];

  const favoriteFoods = [
    {
      id: 1,
      name: '鸡胸肉',
      category: '肉类',
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
      image: '🍗',
      addedDate: '2024-09-26',
      notes: '减脂期间的主要蛋白质来源'
    },
    {
      id: 2,
      name: '西兰花',
      category: '蔬菜',
      calories: 34,
      protein: 2.8,
      carbs: 7,
      fat: 0.4,
      image: '🥦',
      addedDate: '2024-09-25',
      notes: '富含维生素C和膳食纤维'
    },
    {
      id: 3,
      name: '燕麦',
      category: '谷物',
      calories: 389,
      protein: 17,
      carbs: 66,
      fat: 7,
      image: '🌾',
      addedDate: '2024-09-24',
      notes: '早餐的好选择，饱腹感强'
    },
    {
      id: 4,
      name: '酸奶',
      category: '乳制品',
      calories: 59,
      protein: 10,
      carbs: 3.6,
      fat: 0.4,
      image: '🥛',
      addedDate: '2024-09-23',
      notes: '含有益生菌，有助消化'
    }
  ];

  const favoritePosts = [
    {
      id: 1,
      title: '21天健康饮食挑战成功心得',
      author: '健康小达人',
      authorAvatar: '👩‍🦰',
      content: '今天成功完成了21天健康饮食挑战！分享一下我的心得...',
      likes: 89,
      comments: 23,
      addedDate: '2024-09-26',
      tags: ['减重成功', '21天挑战']
    },
    {
      id: 2,
      title: '蛋白质摄入的科学方法',
      author: '营养师小王',
      authorAvatar: '👨‍⚕️',
      content: '很多朋友问我关于蛋白质摄入的问题...',
      likes: 156,
      comments: 45,
      addedDate: '2024-09-25',
      tags: ['营养知识', '蛋白质']
    }
  ];

  const favoriteArticles = [
    {
      id: 1,
      title: '如何制定个人营养计划',
      author: '营养专家团队',
      readTime: 8,
      category: '营养指导',
      image: '📊',
      addedDate: '2024-09-27',
      summary: '详细介绍如何根据个人情况制定科学的营养计划'
    },
    {
      id: 2,
      title: '运动前后的营养补充策略',
      author: '运动营养师',
      readTime: 6,
      category: '运动营养',
      image: '🏃‍♂️',
      addedDate: '2024-09-26',
      summary: '运动前后如何合理补充营养，提高运动效果'
    }
  ];

  const toggleSelectItem = (id: number) => {
    setSelectedItems(prev => 
      prev.includes(id) 
        ? prev.filter(item => item !== id)
        : [...prev, id]
    );
  };

  const selectAll = () => {
    const currentData = getCurrentData();
    const allIds = currentData.map((item: any) => item.id);
    setSelectedItems(selectedItems.length === allIds.length ? [] : allIds);
  };

  const deleteSelected = () => {
    if (selectedItems.length > 0) {
      alert(`删除 ${selectedItems.length} 个收藏项目`);
      setSelectedItems([]);
    }
  };

  const getCurrentData = (): any[] => {
    switch (activeTab) {
      case 'recipes': return favoriteRecipes;
      case 'foods': return favoriteFoods;
      case 'posts': return favoritePosts;
      case 'articles': return favoriteArticles;
      default: return [];
    }
  };

  const filteredData = getCurrentData().filter((item: any) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      item.title?.toLowerCase().includes(searchLower) ||
      item.name?.toLowerCase().includes(searchLower) ||
      (item.tags && Array.isArray(item.tags) && item.tags.some((tag: string) => tag.toLowerCase().includes(searchLower)))
    );
  });

  const renderRecipes = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {filteredData.map((recipe: any) => (
        <Card key={recipe.id} className="hover:shadow-lg transition-shadow">
          <CardContent className="p-0">
            <div className="relative">
              <div className="p-6 bg-gradient-to-br from-gray-50 to-gray-100 text-center">
                <div className="text-5xl mb-3">{recipe.image}</div>
                <div className="absolute top-3 left-3">
                  <input
                    type="checkbox"
                    checked={selectedItems.includes(recipe.id)}
                    onChange={() => toggleSelectItem(recipe.id)}
                    className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                  />
                </div>
              </div>
              
              <div className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-semibold text-gray-900">{recipe.title}</h3>
                  <div className="flex items-center gap-1 text-sm text-gray-600">
                    <Star className="h-4 w-4 text-yellow-500 fill-current" />
                    {recipe.rating}
                  </div>
                </div>
                
                <p className="text-sm text-gray-600 mb-3">{recipe.category} • {recipe.author}</p>
                
                <div className="flex flex-wrap gap-1 mb-3">
                  {recipe.tags.map((tag: string, index: number) => (
                    <span key={index} className="px-2 py-1 bg-primary-50 text-primary-700 text-xs rounded-full">
                      {tag}
                    </span>
                  ))}
                </div>
                
                <div className="grid grid-cols-3 gap-2 text-xs text-center mb-3">
                  <div>
                    <Clock className="h-3 w-3 mx-auto mb-1 text-gray-500" />
                    <div>{recipe.time}分钟</div>
                  </div>
                  <div>
                    <Users className="h-3 w-3 mx-auto mb-1 text-gray-500" />
                    <div>{recipe.servings}人份</div>
                  </div>
                  <div>
                    <div className="text-red-500 font-medium">{recipe.calories}</div>
                    <div className="text-gray-500">卡路里</div>
                  </div>
                </div>
                
                <div className="flex items-center justify-between text-xs text-gray-500 mb-3">
                  <span>收藏于 {recipe.addedDate}</span>
                </div>
                
                <div className="flex gap-2">
                  <Button size="sm" className="flex-1">查看详情</Button>
                  <Button variant="outline" size="sm">
                    <Share2 className="h-3 w-3" />
                  </Button>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderFoods = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {filteredData.map((food: any) => (
        <Card key={food.id} className="hover:shadow-lg transition-shadow">
          <CardContent className="p-4">
            <div className="flex items-center gap-3 mb-3">
              <input
                type="checkbox"
                checked={selectedItems.includes(food.id)}
                onChange={() => toggleSelectItem(food.id)}
                className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
              />
              <div className="text-3xl">{food.image}</div>
              <div className="flex-1">
                <h3 className="font-semibold text-gray-900">{food.name}</h3>
                <p className="text-sm text-gray-600">{food.category}</p>
              </div>
            </div>
            
            <div className="bg-primary-50 rounded-lg p-3 mb-3 text-center">
              <div className="text-xl font-bold text-primary-600">{food.calories}</div>
              <div className="text-sm text-primary-700">卡路里/100g</div>
            </div>
            
            <div className="grid grid-cols-3 gap-2 text-xs text-center mb-3">
              <div>
                <div className="font-medium text-blue-600">{food.protein}g</div>
                <div className="text-gray-500">蛋白质</div>
              </div>
              <div>
                <div className="font-medium text-orange-600">{food.carbs}g</div>
                <div className="text-gray-500">碳水</div>
              </div>
              <div>
                <div className="font-medium text-purple-600">{food.fat}g</div>
                <div className="text-gray-500">脂肪</div>
              </div>
            </div>
            
            {food.notes && (
              <div className="p-2 bg-gray-50 rounded text-xs text-gray-600 mb-3">
                💡 {food.notes}
              </div>
            )}
            
            <div className="flex items-center justify-between text-xs text-gray-500 mb-3">
              <span>收藏于 {food.addedDate}</span>
            </div>
            
            <div className="flex gap-2">
              <Button size="sm" className="flex-1">添加到记录</Button>
              <Button variant="outline" size="sm">
                <Share2 className="h-3 w-3" />
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderPosts = () => (
    <div className="space-y-4">
      {filteredData.map((post: any) => (
        <Card key={post.id}>
          <CardContent className="p-4">
            <div className="flex items-start gap-3">
              <input
                type="checkbox"
                checked={selectedItems.includes(post.id)}
                onChange={() => toggleSelectItem(post.id)}
                className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500 mt-1"
              />
              
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <div className="text-lg">{post.authorAvatar}</div>
                  <div>
                    <h4 className="font-medium text-gray-900">{post.author}</h4>
                    <p className="text-xs text-gray-500">收藏于 {post.addedDate}</p>
                  </div>
                </div>
                
                <h3 className="font-semibold text-gray-900 mb-2">{post.title}</h3>
                <p className="text-sm text-gray-600 mb-3">{post.content}</p>
                
                <div className="flex flex-wrap gap-1 mb-3">
                  {post.tags.map((tag: string, index: number) => (
                    <span key={index} className="px-2 py-1 bg-primary-50 text-primary-700 text-xs rounded-full">
                      #{tag}
                    </span>
                  ))}
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4 text-sm text-gray-600">
                    <span className="flex items-center gap-1">
                      <Heart className="h-4 w-4" />
                      {post.likes}
                    </span>
                    <span>{post.comments} 评论</span>
                  </div>
                  
                  <div className="flex gap-2">
                    <Button size="sm" variant="outline">查看原文</Button>
                    <Button size="sm" variant="outline">
                      <Share2 className="h-3 w-3" />
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderArticles = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      {filteredData.map((article: any) => (
        <Card key={article.id} className="hover:shadow-lg transition-shadow">
          <CardContent className="p-4">
            <div className="flex items-start gap-3 mb-3">
              <input
                type="checkbox"
                checked={selectedItems.includes(article.id)}
                onChange={() => toggleSelectItem(article.id)}
                className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500 mt-1"
              />
              
              <div className="text-3xl">{article.image}</div>
              
              <div className="flex-1">
                <h3 className="font-semibold text-gray-900 mb-1">{article.title}</h3>
                <p className="text-sm text-gray-600">{article.author}</p>
              </div>
            </div>
            
            <p className="text-sm text-gray-600 mb-3">{article.summary}</p>
            
            <div className="flex items-center gap-4 text-xs text-gray-500 mb-3">
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {article.readTime} 分钟阅读
              </span>
              <span>{article.category}</span>
            </div>
            
            <div className="flex items-center justify-between text-xs text-gray-500 mb-3">
              <span>收藏于 {article.addedDate}</span>
            </div>
            
            <div className="flex gap-2">
              <Button size="sm" className="flex-1">阅读文章</Button>
              <Button variant="outline" size="sm">
                <Share2 className="h-3 w-3" />
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <Star className="h-6 w-6 text-primary-600" />
            我的收藏
          </h1>
          <p className="text-gray-600 mt-1">管理您收藏的食谱、食物和精彩内容</p>
        </div>
        
        <div className="flex gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="搜索收藏内容..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 pr-4 py-2 border border-gray-200 rounded-lg bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          
          {selectedItems.length > 0 && (
            <Button variant="outline" onClick={deleteSelected} className="text-red-600 hover:text-red-700">
              <Trash2 className="h-4 w-4 mr-2" />
              删除选中 ({selectedItems.length})
            </Button>
          )}
        </div>
      </div>

      {/* 统计信息 */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {tabs.map((tab) => (
          <Card key={tab.id} className={`cursor-pointer transition-all ${activeTab === tab.id ? 'ring-2 ring-primary-500' : ''}`}>
            <CardContent className="p-4 text-center" onClick={() => setActiveTab(tab.id)}>
              <div className="text-2xl mb-2">{tab.icon}</div>
              <div className="text-lg font-bold text-gray-900">{tab.count}</div>
              <div className="text-sm text-gray-600">{tab.name}</div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* 操作栏 */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button
            onClick={selectAll}
            className="text-sm text-primary-600 hover:text-primary-700"
          >
            {selectedItems.length === getCurrentData().length ? '取消全选' : '全选'}
          </button>
          
          {selectedItems.length > 0 && (
            <span className="text-sm text-gray-600">
              已选择 {selectedItems.length} 项
            </span>
          )}
        </div>
        
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm">
            <Filter className="h-4 w-4 mr-2" />
            筛选
          </Button>
        </div>
      </div>

      {/* 内容区域 */}
      <div>
        {activeTab === 'recipes' && renderRecipes()}
        {activeTab === 'foods' && renderFoods()}
        {activeTab === 'posts' && renderPosts()}
        {activeTab === 'articles' && renderArticles()}
      </div>

      {/* 空状态 */}
      {filteredData.length === 0 && (
        <Card>
          <CardContent className="p-12 text-center">
            <div className="text-4xl mb-4">⭐</div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">暂无收藏内容</h3>
            <p className="text-gray-600">
              {searchTerm ? '没有找到匹配的收藏内容' : '开始收藏您喜欢的食谱、食物和文章吧'}
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default FavoritesPage;
