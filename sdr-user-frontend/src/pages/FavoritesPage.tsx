import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Star, Trash2 } from 'lucide-react';
import api from '../services/api';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

type FavoriteType = '' | 'recipe' | 'food' | 'recommendation';

interface FavoriteItem {
  favoriteId?: number;
  favoriteType: string;
  targetId: number;
  targetName: string;
  targetDescription?: string;
  targetImage?: string;
  createTime?: string;
}

const FavoritesPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [activeType, setActiveType] = useState<FavoriteType>('');
  const [list, setList] = useState<FavoriteItem[]>([]);

  const loadFavorites = async (type: FavoriteType) => {
    setLoading(true);
    try {
      const res: any = await api.get('/api/user/diet/favorites/list', {
        params: type ? { favoriteType: type } : {},
      });
      if (res?.code === 200 && res.data) {
        const items = Array.isArray(res.data) ? res.data : (res.data.data || res.data.list || []);
        setList(items.map((it: any) => ({
          favoriteId: it.favoriteId ?? it.favorite_id,
          favoriteType: it.favoriteType ?? it.favorite_type,
          targetId: it.targetId ?? it.target_id,
          targetName: it.targetName ?? it.target_name,
          targetDescription: it.targetDescription ?? it.target_description,
          targetImage: it.targetImage ?? it.target_image,
          createTime: it.createTime ?? it.create_time,
        })));
      } else {
        setList([]);
      }
    } catch (e) {
      console.error('加载收藏失败:', e);
      setList([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadFavorites(activeType);
  }, [activeType]);

  const typeTabs = useMemo(() => ([
    { key: '' as FavoriteType, label: '全部' },
    { key: 'recipe' as FavoriteType, label: '食谱' },
    { key: 'food' as FavoriteType, label: '食物' },
    { key: 'recommendation' as FavoriteType, label: '方案' },
  ]), []);

  const handleRemove = async (item: FavoriteItem) => {
    try {
      await api.post('/api/user/diet/favorites/toggle', {
        favoriteType: item.favoriteType,
        targetId: item.targetId,
        targetName: item.targetName,
      });
      setList(prev => prev.filter(x => !(x.favoriteType === item.favoriteType && x.targetId === item.targetId)));
    } catch (e) {
      console.error('取消收藏失败:', e);
    }
  };

  return (
    <div className="space-y-6 animate-fadeIn">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <Star className="h-6 w-6 text-primary-600" />
          我的收藏
        </h1>
        <p className="text-gray-700 mt-1">管理您收藏的食谱和食物</p>
      </div>

      <div className="flex flex-wrap gap-2">
        {typeTabs.map(t => (
          <button
            key={t.key}
            onClick={() => setActiveType(t.key)}
            className={
              activeType === t.key
                ? 'px-3 py-1.5 rounded-lg bg-emerald-600 text-white text-sm font-semibold'
                : 'px-3 py-1.5 rounded-lg bg-gray-100 text-gray-700 text-sm font-semibold hover:bg-gray-200'
            }
          >
            {t.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="text-center py-16">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin mx-auto" />
          <p className="mt-4 text-sm text-gray-700">加载中...</p>
        </div>
      ) : list.length === 0 ? (
        <div className="text-center py-16">
          <div className="text-5xl mb-4">⭐</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">暂无收藏内容</h3>
          <p className="text-sm text-gray-600">在食物库或社区中收藏/点赞您喜欢的内容</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {list.map((item) => (
            <Card
              key={`${item.favoriteType}-${item.targetId}`}
              className="border-0 shadow-sm"
              hoverEffect={false}
              onClick={() => {
                const t = (item.favoriteType || '').toLowerCase();
                if (t === 'recipe') {
                  navigate(`/recipes/${item.targetId}`);
                  return;
                }
                if (t === 'food') {
                  navigate(`/food-database?foodId=${item.targetId}`);
                  return;
                }
                if (t === 'recommendation') {
                  navigate('/smart-recommendation');
                  return;
                }
              }}
            >
              <div className="p-4 flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <div className="text-sm text-gray-500 font-semibold">{item.favoriteType}</div>
                  <div className="text-base font-bold text-gray-900 truncate">{item.targetName}</div>
                  {item.targetDescription ? (
                    <div className="text-sm text-gray-600 mt-1 line-clamp-2">{item.targetDescription}</div>
                  ) : null}
                </div>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleRemove(item);
                  }}
                  className="flex-shrink-0"
                >
                  <Trash2 className="w-4 h-4 mr-1" />
                  取消
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default FavoritesPage;
