import React, { useState, useEffect } from 'react';
import { Users, MessageCircle, Heart, Plus, X, ThumbsUp, BookOpen, Clock, Eye, Image as ImageIcon, Loader2, Trash2 } from 'lucide-react';
import { useAuth } from '../components/AuthGuard';
import { Card, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';

const CommunityPage: React.FC = () => {
  const [posts, setPosts] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<'posts'|'articles'>('posts');
  const [articles, setArticles] = useState<any[]>([]);
  const [loadingArticles, setLoadingArticles] = useState(false);

  const [articleModalOpen, setArticleModalOpen] = useState(false);
  const [currentArticle, setCurrentArticle] = useState<any>(null);
  const [loadingArticleDetail, setLoadingArticleDetail] = useState(false);

  const [newPostContent, setNewPostContent] = useState('');
  const [newPostImages, setNewPostImages] = useState<string[]>([]);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [publishOpen, setPublishOpen] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [likedOnly, setLikedOnly] = useState(false);

  const [expandedPostIds, setExpandedPostIds] = useState<Record<number, boolean>>({});
  const [commentsByPostId, setCommentsByPostId] = useState<Record<number, any[]>>({});
  const [commentDraftByPostId, setCommentDraftByPostId] = useState<Record<number, string>>({});
  const [commentLoadingByPostId, setCommentLoadingByPostId] = useState<Record<number, boolean>>({});
  const [commentSubmittingByPostId, setCommentSubmittingByPostId] = useState<Record<number, boolean>>({});

  const [loading, setLoading] = useState(true);
  const { showToast } = useToast();
  const { userInfo } = useAuth();

  const getCurrentUserId = () => {
    if (userInfo?.user?.userId) return userInfo.user.userId;
    if (userInfo?.userId) return userInfo.userId;
    const stored = localStorage.getItem('userInfo');
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        return parsed.user?.userId || parsed.userId || null;
      } catch { return null; }
    }
    return null;
  };

  const loadPosts = async () => {
    try {
      setLoading(true);
      const res: any = await api.get('/api/user/diet/community/list');
      if (res && res.code === 200 && res.data) {
        const list = Array.isArray(res.data) ? res.data : (res.data.data || res.data.list || []);
        const fetchedPosts = list.map((p: any) => ({
          id: p.postId || p.post_id,
          userId: p.userId || p.user_id,
          user: {
            name: p.nickName || p.nick_name || '匿名用户',
            avatar: p.avatar,
          },
          content: p.content,
          imageUrl: p.imageUrl || p.image_url || p.imageUrls || p.image_urls || '',
          likes: p.likeCount || p.like_count || 0,
          comments: p.commentCount || p.comment_count || 0,
          time: p.createTime ? new Date(p.createTime).toLocaleString() : (p.create_time ? new Date(p.create_time).toLocaleString() : ''),
          isLiked: !!(p.isLiked ?? p.is_liked)
        }));
        setPosts(fetchedPosts);
      }
    } catch (err) {
      console.error('加载社区动态失败:', err);
    } finally {
      setLoading(false);
    }
  };

  const loadArticles = async () => {
    try {
      setLoadingArticles(true);
      const res: any = await api.get('/api/user/diet/article/list');
      if (res && res.code === 200) {
        setArticles(res.data || []);
      }
    } catch (err) {
      console.error('加载科普资讯失败:', err);
    } finally {
      setLoadingArticles(false);
    }
  };

  const viewArticle = async (id: number) => {
    setArticleModalOpen(true);
    setLoadingArticleDetail(true);
    setCurrentArticle(null);
    try {
      const res: any = await api.get('/api/user/diet/article/' + id);
      if (res?.code === 200) setCurrentArticle(res.data);
    } catch (e) {}
    finally { setLoadingArticleDetail(false); }
  };

  useEffect(() => {
    loadPosts();
    loadArticles();
  }, []);

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      setUploadingImage(true);
      const res: any = await api.post('/common/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      if (res?.code === 200) {
        setNewPostImages(prev => [...prev, res.url || res.fileName]);
      } else {
        showToast('error', res?.msg || '上传失败');
      }
    } catch (e) {
      showToast('error', '上传失败，请重试');
    } finally {
      setUploadingImage(false);
    }
  };

  const handlePublish = async () => {
    const content = newPostContent.trim();
    if (!content && newPostImages.length === 0) return;
    try {
      setPublishing(true);
      // 若后端要求 content 必填，当只有图片时补充默认文案
      const finalContent = content || '分享图片';
      const res: any = await api.post('/api/user/diet/community/publish', {
        content: finalContent,
        imageUrls: newPostImages.join(',')
      });
      if (res?.code !== 200) {
        showToast('error', res?.msg || '发布失败');
        return;
      }
      setNewPostContent('');
      setNewPostImages([]);
      setPublishOpen(false);
      showToast('success', '发布成功');
      await loadPosts();
    } catch (err: any) {
      const msg = err?.response?.data?.msg || err?.msg || '发布失败，请稍后重试';
      showToast('error', msg);
    } finally {
      setPublishing(false);
    }
  };

  const deletePost = async (postId: number) => {
    if (!window.confirm('确定要删除这条动态吗？')) return;
    try {
      const res: any = await api.delete('/api/user/diet/community/' + postId);
      if (res?.code === 200) {
        showToast('success', '删除成功');
        setPosts(prev => prev.filter(p => p.id !== postId));
      } else {
        showToast('error', res?.msg || '删除失败');
      }
    } catch (e) {
      showToast('error', '删除失败');
    }
  };

  const toggleLike = async (postId: number) => {
    try {
      const before = posts.find(p => p.id === postId);
      const optimisticLiked = !before?.isLiked;
      setPosts(prev => prev.map(p => p.id === postId ? {
        ...p,
        isLiked: optimisticLiked,
        likes: Math.max((p.likes || 0) + (optimisticLiked ? 1 : -1), 0)
      } : p));

      const res: any = await api.post('/api/user/diet/community/like/' + postId);
      if (res?.code === 200 && res.data) {
        const data = res.data;
        setPosts(prev => prev.map(p => p.id === postId ? {
          ...p,
          isLiked: !!data.isLiked,
          likes: typeof data.likeCount === 'number' ? data.likeCount : p.likes,
        } : p));
      } else {
        loadPosts();
      }
    } catch (err) {
      console.error('点赞失败:', err);
      showToast('error', '操作失败，请稍后重试');
      loadPosts();
    }
  };

  const toggleComments = async (postId: number) => {
    setExpandedPostIds(prev => ({ ...prev, [postId]: !prev[postId] }));

    const willExpand = !expandedPostIds[postId];
    if (!willExpand) return;

    if (commentsByPostId[postId]) return;

    setCommentLoadingByPostId(prev => ({ ...prev, [postId]: true }));
    try {
      const res: any = await api.get('/api/user/diet/community/comments/' + postId);
      if (res?.code === 200) {
        setCommentsByPostId(prev => ({ ...prev, [postId]: res.data || [] }));
      } else {
        setCommentsByPostId(prev => ({ ...prev, [postId]: [] }));
      }
    } catch (e) {
      console.error('加载评论失败:', e);
      setCommentsByPostId(prev => ({ ...prev, [postId]: [] }));
    } finally {
      setCommentLoadingByPostId(prev => ({ ...prev, [postId]: false }));
    }
  };

  const submitComment = async (postId: number) => {
    const content = (commentDraftByPostId[postId] || '').trim();
    if (!content) return;
    try {
      setCommentSubmittingByPostId(prev => ({ ...prev, [postId]: true }));
      const publishRes: any = await api.post('/api/user/diet/community/comments/' + postId, { content });
      if (publishRes?.code !== 200) {
        showToast('error', publishRes?.msg || '评论失败');
        return;
      }
      setCommentDraftByPostId(prev => ({ ...prev, [postId]: '' }));

      // 重新拉取评论列表
      const res: any = await api.get('/api/user/diet/community/comments/' + postId);
      if (res?.code === 200) {
        setCommentsByPostId(prev => ({ ...prev, [postId]: res.data || [] }));
        setPosts(prev => prev.map(p => p.id === postId ? { ...p, comments: (res.data || []).length } : p));
        showToast('success', '评论已发送');
      } else {
        loadPosts();
      }
    } catch (e: any) {
      const msg = e?.response?.data?.msg || e?.msg || '评论失败，请稍后重试';
      showToast('error', msg);
    } finally {
      setCommentSubmittingByPostId(prev => ({ ...prev, [postId]: false }));
    }
  };

  const toggleCommentLike = async (postId: number, commentId: number) => {
    try {
      const res: any = await api.post('/api/user/diet/community/comment-like/' + commentId);
      if (res?.code === 200) {
        // 刷新评论列表
        const commRes: any = await api.get('/api/user/diet/community/comments/' + postId);
        if (commRes?.code === 200) {
          setCommentsByPostId(prev => ({ ...prev, [postId]: commRes.data || [] }));
        }
      }
    } catch (e) {
      console.error('评论点赞失败:', e);
    }
  };

  // =================== 渲染帖子列表 ===================
  const renderPostsTab = () => (
    <>
      {/* 发布动态 */}
      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-emerald-600 rounded-full flex items-center justify-center text-white text-lg font-bold flex-shrink-0">
              我
            </div>
            <button
              onClick={() => setPublishOpen(true)}
              className="flex-1 text-left p-3 border border-gray-300 rounded-lg bg-white text-gray-500 hover:bg-gray-50 transition-colors"
            >
              分享你的健康心得...
            </button>
            <Button onClick={() => setPublishOpen(true)}>
              <Plus className="h-4 w-4 mr-2" />
              发布
            </Button>
          </div>
        </CardContent>
      </Card>

      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-600 font-semibold">{likedOnly ? '我的点赞' : '全部动态'}</div>
        <button
          onClick={() => setLikedOnly(v => !v)}
          className={`px-3 py-1.5 rounded-lg text-sm font-semibold transition-colors ${likedOnly ? 'bg-red-50 text-red-600' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}`}
        >
          {likedOnly ? '查看全部' : '只看已点赞'}
        </button>
      </div>

      {/* 动态列表 */}
      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin" />
        </div>
      ) : (likedOnly ? posts.filter(p => p.isLiked).length > 0 : posts.length > 0) ? (
        <div className="space-y-4">
          {(likedOnly ? posts.filter(p => p.isLiked) : posts).map((post) => (
            <Card key={post.id}>
              <CardContent className="p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="relative w-10 h-10 rounded-full flex-shrink-0 flex items-center justify-center bg-gray-200 text-gray-700 text-sm font-bold border border-gray-200 overflow-hidden shadow-sm">
                    {(post.user.name || '匿').charAt(0).toUpperCase()}
                    {post.user.avatar && String(post.user.avatar).trim() !== '' && String(post.user.avatar) !== 'null' && (
                      <img 
                        src={post.user.avatar} 
                        alt="avatar" 
                        className="absolute inset-0 w-full h-full object-cover"
                        onError={(e) => { e.currentTarget.style.display = 'none'; }}
                      />
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <h4 className="font-semibold text-gray-900">{post.user.name}</h4>
                      {getCurrentUserId() === post.userId && (
                        <button onClick={() => deletePost(post.id)} className="text-gray-400 hover:text-red-500 transition-colors p-1" title="删除动态">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                    <div className="text-sm text-gray-600">{post.time}</div>
                  </div>
                </div>

                <p className="text-gray-800 mb-4 text-base whitespace-pre-wrap">{post.content}</p>

                {post.imageUrl && (
                  <div className={`mt-3 mb-4 ${post.imageUrl.split(',').filter((u:string)=>u.trim()).length === 1 ? '' : 'grid grid-cols-2 sm:grid-cols-3 gap-2'}`}>
                    {post.imageUrl.split(',').filter((url:string) => url.trim()).map((url:string, idx:number, arr:string[]) => {
                      const isSingle = arr.length === 1;
                      const fullUrl = url.startsWith('http') ? url : (process.env.REACT_APP_BASE_API || '') + url;
                      return (
                        <img 
                          key={idx} 
                          src={fullUrl} 
                          alt="post image" 
                          className={
                            isSingle 
                              ? "w-auto max-w-[80%] md:max-w-md max-h-64 object-contain rounded-lg border border-gray-100 cursor-pointer" 
                              : "w-full aspect-square object-cover rounded-lg border border-gray-100 cursor-pointer"
                          }
                          onClick={() => window.open(fullUrl, '_blank')}
                        />
                      );
                    })}
                  </div>
                )}

                <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                  <button
                    onClick={() => toggleLike(post.id)}
                    className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${post.isLiked ? 'text-red-600 bg-red-50' : 'text-gray-600 hover:bg-gray-50'}`}
                  >
                    <Heart className={`h-4 w-4 ${post.isLiked ? 'fill-current' : ''}`} />
                    {post.likes}
                  </button>
                  <button
                    onClick={() => toggleComments(post.id)}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg text-gray-600 hover:bg-gray-50"
                  >
                    <MessageCircle className="h-4 w-4" />
                    {post.comments}
                  </button>
                </div>

                {expandedPostIds[post.id] && (
                  <div className="mt-4 pt-4 border-t border-gray-100 space-y-3">
                    {/* 评论列表 */}
                    {commentLoadingByPostId[post.id] ? (
                      <div className="text-sm text-gray-500">加载评论中...</div>
                    ) : (
                      <div className="space-y-3">
                        {(commentsByPostId[post.id] || []).length === 0 ? (
                          <div className="text-sm text-gray-500">暂无评论</div>
                        ) : (
                          (commentsByPostId[post.id] || []).map((c: any) => {
                            const cId = c.commentId || c.comment_id;
                            const cLiked = !!(c.isLiked ?? c.is_liked);
                            const cLikes = c.likeCount ?? c.like_count ?? 0;
                            return (
                            <div key={cId} className="flex gap-3">
                              <div className="relative w-8 h-8 rounded-full flex-shrink-0 flex items-center justify-center bg-gray-200 text-gray-700 text-xs font-bold border border-gray-200 overflow-hidden">
                                {((c.nickName || c.nick_name || '匿') as string).charAt(0).toUpperCase()}
                                {c.avatar && String(c.avatar).trim() !== '' && String(c.avatar) !== 'null' && (
                                  <img 
                                    src={c.avatar} 
                                    alt="avatar" 
                                    className="absolute inset-0 w-full h-full object-cover"
                                    onError={(e) => { e.currentTarget.style.display = 'none'; }}
                                  />
                                )}
                              </div>
                              <div className="flex-1">
                                <div className="text-sm font-semibold text-gray-900">{c.nickName || c.nick_name || '匿名用户'}</div>
                                <div className="text-sm text-gray-700 mt-0.5">{c.content}</div>
                                <div className="flex items-center gap-3 mt-1">
                                  <span className="text-xs text-gray-500">
                                    {c.createTime ? new Date(c.createTime).toLocaleString() : (c.create_time ? new Date(c.create_time).toLocaleString() : '')}
                                  </span>
                                  <button
                                    onClick={() => toggleCommentLike(post.id, cId)}
                                    className={`flex items-center gap-1 text-xs px-2 py-0.5 rounded transition-colors ${cLiked ? 'text-blue-600 bg-blue-50' : 'text-gray-400 hover:text-blue-500 hover:bg-gray-50'}`}
                                  >
                                    <ThumbsUp className={`h-3 w-3 ${cLiked ? 'fill-current' : ''}`} />
                                    {cLikes > 0 && <span>{cLikes}</span>}
                                  </button>
                                </div>
                              </div>
                            </div>
                            );
                          })
                        )}
                      </div>
                    )}

                    {/* 评论输入 */}
                    <div className="flex gap-2 items-center">
                      <input
                        type="text"
                        placeholder="写下你的评论..."
                        value={commentDraftByPostId[post.id] || ''}
                        onChange={(e) => setCommentDraftByPostId(prev => ({ ...prev, [post.id]: e.target.value }))}
                        onKeyDown={(e) => {
                          if (e.key === 'Enter') submitComment(post.id);
                        }}
                        className="flex-1 p-2 border border-gray-200 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500 text-gray-900 placeholder:text-gray-400"
                      />
                      <Button size="sm" onClick={() => submitComment(post.id)} disabled={!!commentSubmittingByPostId[post.id]}>
                        {commentSubmittingByPostId[post.id] ? '发送中...' : '发送'}
                      </Button>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <div className="text-4xl mb-4">📝</div>
          <p className="text-base text-gray-700">{likedOnly ? '暂无点赞内容' : '暂无社区动态'}</p>
          <p className="text-sm text-gray-500 mt-1">{likedOnly ? '去给喜欢的帖子点个赞吧' : '成为第一个分享健康心得的人吧！'}</p>
        </div>
      )}
    </>
  );

  // =================== 渲染科普资讯列表 ===================
  const renderArticlesTab = () => (
    <div className="space-y-4">
      {loadingArticles ? (
        <div className="flex items-center justify-center py-16">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin" />
        </div>
      ) : articles.length > 0 ? (
        articles.map(article => {
          const articleId = article.article_id || article.articleId;
          return (
            <Card key={articleId} className="hover:shadow-md transition-shadow cursor-pointer" onClick={() => viewArticle(articleId)}>
              <CardContent className="p-5">
                <h3 className="text-lg font-bold text-gray-900 mb-2 line-clamp-2">{article.title}</h3>
                <div className="flex items-center gap-4 text-xs text-gray-500">
                  <span className="flex items-center gap-1"><BookOpen className="w-3.5 h-3.5" />{article.author || '管理员'}</span>
                  <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" />{article.create_time ? new Date(article.create_time).toLocaleString() : (article.createTime ? new Date(article.createTime).toLocaleString() : '')}</span>
                  <span className="flex items-center gap-1"><Eye className="w-3.5 h-3.5" />{article.view_count || article.viewCount || 0}</span>
                </div>
              </CardContent>
            </Card>
          );
        })
      ) : (
        <div className="text-center py-12">
          <div className="text-4xl mb-4">📚</div>
          <p className="text-base text-gray-700">暂无科普资讯</p>
          <p className="text-sm text-gray-500 mt-1">管理员可在后台发布科普文章</p>
        </div>
      )}
    </div>
  );

  return (
    <>
      <div className="space-y-6 animate-fadeIn">
        {/* Header & Tabs */}
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2 mb-4">
            <Users className="h-6 w-6 text-emerald-600" />
            健康社区
          </h1>
          <div className="flex border-b border-gray-200">
            <button
              className={`py-3 px-6 font-semibold text-sm border-b-2 transition-colors ${activeTab === 'posts' ? 'border-emerald-600 text-emerald-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
              onClick={() => setActiveTab('posts')}
            >
              互动动态
            </button>
            <button
              className={`py-3 px-6 font-semibold text-sm border-b-2 transition-colors ${activeTab === 'articles' ? 'border-emerald-600 text-emerald-600' : 'border-transparent text-gray-500 hover:text-gray-700'}`}
              onClick={() => setActiveTab('articles')}
            >
              科普资讯
            </button>
          </div>
        </div>

        {/* Tab内容 */}
        {activeTab === 'posts' ? renderPostsTab() : renderArticlesTab()}
      </div>

      {/* 资讯详情弹窗 */}
      {articleModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[9999] p-4" onClick={() => setArticleModalOpen(false)}>
          <div className="bg-white rounded-2xl max-w-2xl w-full shadow-2xl overflow-hidden max-h-[85vh] flex flex-col" onClick={e => e.stopPropagation()}>
            <div className="p-4 border-b border-gray-100 flex items-center justify-between flex-shrink-0">
              <div className="text-lg font-bold text-gray-900">资讯详情</div>
              <button
                onClick={() => setArticleModalOpen(false)}
                className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 hover:bg-gray-200 transition-colors"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="p-6 overflow-y-auto">
              {loadingArticleDetail ? (
                <div className="py-20 flex justify-center"><div className="w-8 h-8 border-2 border-emerald-500 border-t-transparent rounded-full animate-spin"/></div>
              ) : currentArticle ? (
                <div>
                  <h1 className="text-2xl font-bold text-gray-900 mb-4">{currentArticle.title}</h1>
                  <div className="flex items-center gap-4 text-sm text-gray-500 mb-6 pb-6 border-b border-gray-100">
                    <span>{currentArticle.author || '管理员'}</span>
                    <span>{currentArticle.create_time ? new Date(currentArticle.create_time).toLocaleString() : (currentArticle.createTime ? new Date(currentArticle.createTime).toLocaleString() : '')}</span>
                    <span>阅读 {currentArticle.view_count || currentArticle.viewCount || 0}</span>
                  </div>
                  {(currentArticle.cover_image || currentArticle.coverImage) && (
                    <img src={currentArticle.cover_image || currentArticle.coverImage} alt="cover" className="w-full h-auto max-h-64 object-cover rounded-xl mb-6" />
                  )}
                  <div className="prose prose-emerald max-w-none text-gray-800 leading-relaxed whitespace-pre-wrap">
                    {currentArticle.content}
                  </div>
                </div>
              ) : (
                <div className="py-20 text-center text-gray-500">无法加载文章详情</div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* 发布动态弹窗 */}
      {publishOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[9999] p-4" onClick={() => !publishing && setPublishOpen(false)}>
          <div className="bg-white rounded-2xl max-w-lg w-full shadow-2xl overflow-hidden" onClick={e => e.stopPropagation()}>
            <div className="p-4 border-b border-gray-100 flex items-center justify-between">
              <div className="text-base font-bold text-gray-900">发布动态</div>
              <button
                onClick={() => setPublishOpen(false)}
                disabled={publishing}
                className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 hover:bg-gray-200 transition-colors disabled:opacity-60"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="p-4 space-y-3">
              <textarea
                rows={5}
                placeholder="分享你的健康心得..."
                value={newPostContent}
                onChange={e => setNewPostContent(e.target.value)}
                className="w-full p-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 focus:border-transparent text-gray-900 placeholder:text-gray-400 resize-none"
              />
              
              {/* 图片预览区 */}
              {(newPostImages.length > 0 || uploadingImage) && (
                <div className="flex flex-wrap gap-2 mt-2">
                  {newPostImages.map((url, idx) => (
                    <div key={idx} className="relative w-20 h-20 rounded-lg overflow-hidden border border-gray-200">
                      <img src={url.startsWith('http') ? url : (process.env.REACT_APP_BASE_API || '') + url} alt="upload" className="w-full h-full object-cover" />
                      <button 
                        onClick={() => setNewPostImages(prev => prev.filter((_, i) => i !== idx))}
                        className="absolute top-1 right-1 bg-black/50 text-white rounded-full p-0.5 hover:bg-black/70"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </div>
                  ))}
                  {uploadingImage && (
                    <div className="w-20 h-20 rounded-lg border border-gray-200 flex items-center justify-center bg-gray-50">
                      <Loader2 className="w-6 h-6 animate-spin text-emerald-500" />
                    </div>
                  )}
                </div>
              )}

              <div className="flex justify-between items-center mt-2">
                <div>
                  <input type="file" id="imageUpload" accept="image/*" className="hidden" onChange={handleImageUpload} disabled={uploadingImage || newPostImages.length >= 9} />
                  <label htmlFor="imageUpload" className={`flex items-center gap-1 text-sm px-2 py-1 rounded-md transition-colors ${newPostImages.length >= 9 ? 'text-gray-400 cursor-not-allowed' : 'text-gray-500 hover:text-emerald-600 cursor-pointer hover:bg-emerald-50'}`}>
                    <ImageIcon className="w-4 h-4" />
                    {newPostImages.length >= 9 ? '最多9张' : '添加图片'}
                  </label>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" onClick={() => setPublishOpen(false)} disabled={publishing}>取消</Button>
                  <Button onClick={handlePublish} disabled={publishing || (!newPostContent.trim() && newPostImages.length === 0)}>
                    {publishing ? '发布中...' : '发布'}
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default CommunityPage;
