import React, { useState } from 'react';
import { Users, MessageCircle, Heart, Share2, Plus, Search, TrendingUp, Award, Camera } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

const CommunityPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState('feed');
  const [searchTerm, setSearchTerm] = useState('');

  const tabs = [
    { id: 'feed', name: '动态', icon: '📱' },
    { id: 'groups', name: '小组', icon: '👥' },
    { id: 'challenges', name: '挑战', icon: '🏆' },
    { id: 'experts', name: '专家', icon: '👨‍⚕️' }
  ];

  const posts = [
    {
      id: 1,
      user: {
        name: '健康小达人',
        avatar: '👩‍🦰',
        level: 'VIP',
        followers: 1234
      },
      content: '今天成功完成了21天健康饮食挑战！分享一下我的心得：坚持记录每日饮食真的很重要，让我更了解自己的饮食习惯。现在体重减了3.5kg，精神状态也好了很多！',
      images: ['🥗', '📊', '⚖️'],
      tags: ['减重成功', '21天挑战', '健康饮食'],
      likes: 89,
      comments: 23,
      shares: 12,
      time: '2小时前',
      isLiked: false
    },
    {
      id: 2,
      user: {
        name: '营养师小王',
        avatar: '👨‍⚕️',
        level: '专家',
        followers: 5678
      },
      content: '很多朋友问我关于蛋白质摄入的问题。这里给大家分享一个简单的计算方法：每公斤体重需要0.8-1.2g蛋白质。对于运动人群，可以适当增加到1.5-2g。记住，优质蛋白质来源包括：鸡蛋、鱼类、瘦肉、豆类等。',
      images: ['🥚', '🐟', '🥩'],
      tags: ['营养知识', '蛋白质', '专业建议'],
      likes: 156,
      comments: 45,
      shares: 28,
      time: '4小时前',
      isLiked: true
    },
    {
      id: 3,
      user: {
        name: '运动爱好者',
        avatar: '🏃‍♂️',
        level: '活跃',
        followers: 892
      },
      content: '今天的晨跑配早餐！5公里跑步后来一份营养丰富的早餐，燕麦+酸奶+坚果+水果，满满的能量感。大家也要记得运动后及时补充营养哦～',
      images: ['🏃‍♂️', '🥣', '🍓'],
      tags: ['晨跑', '营养早餐', '运动后营养'],
      likes: 67,
      comments: 18,
      shares: 9,
      time: '6小时前',
      isLiked: false
    }
  ];

  const groups = [
    {
      id: 1,
      name: '减脂小分队',
      description: '一起科学减脂，健康瘦身',
      members: 2341,
      posts: 156,
      image: '🏃‍♀️',
      isJoined: true
    },
    {
      id: 2,
      name: '营养师在线',
      description: '专业营养师答疑解惑',
      members: 5678,
      posts: 289,
      image: '👨‍⚕️',
      isJoined: false
    },
    {
      id: 3,
      name: '健身达人',
      description: '分享健身心得和经验',
      members: 3456,
      posts: 234,
      image: '💪',
      isJoined: true
    },
    {
      id: 4,
      name: '素食主义者',
      description: '素食生活方式交流',
      members: 1234,
      posts: 123,
      image: '🥬',
      isJoined: false
    }
  ];

  const challenges = [
    {
      id: 1,
      title: '30天健康饮食挑战',
      description: '连续30天记录饮食，养成健康习惯',
      participants: 1234,
      daysLeft: 15,
      reward: '健康达人徽章',
      progress: 65,
      image: '🥗',
      isJoined: true
    },
    {
      id: 2,
      title: '每日一万步',
      description: '每天走一万步，提高身体活力',
      participants: 2345,
      daysLeft: 8,
      reward: '运动达人称号',
      progress: 0,
      image: '👟',
      isJoined: false
    },
    {
      id: 3,
      title: '水分摄入打卡',
      description: '每天喝足8杯水，保持身体水分',
      participants: 1567,
      daysLeft: 22,
      reward: '水分管理专家',
      progress: 80,
      image: '💧',
      isJoined: true
    }
  ];

  const experts = [
    {
      id: 1,
      name: '李营养师',
      title: '注册营养师',
      speciality: '减重营养',
      followers: 12345,
      posts: 234,
      avatar: '👩‍⚕️',
      rating: 4.9,
      isFollowed: true
    },
    {
      id: 2,
      name: '王健身教练',
      title: '高级健身教练',
      speciality: '力量训练',
      followers: 8765,
      posts: 189,
      avatar: '💪',
      rating: 4.8,
      isFollowed: false
    },
    {
      id: 3,
      name: '张医生',
      title: '内分泌科医生',
      speciality: '代谢调理',
      followers: 15678,
      posts: 156,
      avatar: '👨‍⚕️',
      rating: 4.9,
      isFollowed: true
    }
  ];

  const toggleLike = (postId: number) => {
    console.log('Toggle like for post:', postId);
  };

  const joinGroup = (groupId: number) => {
    console.log('Join group:', groupId);
  };

  const joinChallenge = (challengeId: number) => {
    console.log('Join challenge:', challengeId);
  };

  const followExpert = (expertId: number) => {
    console.log('Follow expert:', expertId);
  };

  const renderFeed = () => (
    <div className="space-y-6">
      {/* 发布动态 */}
      <Card>
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-400 to-primary-600 rounded-full flex items-center justify-center text-white text-lg">
              👤
            </div>
            <div className="flex-1">
              <input
                type="text"
                placeholder="分享你的健康心得..."
                className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
              />
            </div>
            <Button>
              <Plus className="h-4 w-4 mr-2" />
              发布
            </Button>
          </div>
          <div className="flex gap-4 mt-3 ml-13">
            <button className="flex items-center gap-2 text-gray-600 hover:text-primary-600">
              <Camera className="h-4 w-4" />
              照片
            </button>
            <button className="flex items-center gap-2 text-gray-600 hover:text-primary-600">
              <Award className="h-4 w-4" />
              成就
            </button>
          </div>
        </CardContent>
      </Card>

      {/* 动态列表 */}
      {posts.map((post) => (
        <Card key={post.id}>
          <CardContent className="p-6">
            {/* 用户信息 */}
            <div className="flex items-center gap-3 mb-4">
              <div className="text-2xl">{post.user.avatar}</div>
              <div className="flex-1">
                <div className="flex items-center gap-2">
                  <h4 className="font-medium text-gray-900">{post.user.name}</h4>
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    post.user.level === '专家' ? 'bg-blue-100 text-blue-700' :
                    post.user.level === 'VIP' ? 'bg-purple-100 text-purple-700' :
                    'bg-gray-100 text-gray-700'
                  }`}>
                    {post.user.level}
                  </span>
                </div>
                <div className="text-sm text-gray-600">{post.user.followers} 粉丝 • {post.time}</div>
              </div>
            </div>

            {/* 内容 */}
            <p className="text-gray-800 mb-4">{post.content}</p>

            {/* 图片 */}
            {post.images.length > 0 && (
              <div className="flex gap-2 mb-4">
                {post.images.map((image, index) => (
                  <div key={index} className="w-20 h-20 bg-gray-100 rounded-lg flex items-center justify-center text-2xl">
                    {image}
                  </div>
                ))}
              </div>
            )}

            {/* 标签 */}
            <div className="flex flex-wrap gap-2 mb-4">
              {post.tags.map((tag, index) => (
                <span key={index} className="px-3 py-1 bg-primary-50 text-primary-700 text-sm rounded-full">
                  #{tag}
                </span>
              ))}
            </div>

            {/* 互动按钮 */}
            <div className="flex items-center justify-between pt-4 border-t border-gray-100">
              <button
                onClick={() => toggleLike(post.id)}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-colors ${
                  post.isLiked ? 'text-red-600 bg-red-50' : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                <Heart className={`h-4 w-4 ${post.isLiked ? 'fill-current' : ''}`} />
                {post.likes}
              </button>
              <button className="flex items-center gap-2 px-4 py-2 rounded-lg text-gray-600 hover:bg-gray-50">
                <MessageCircle className="h-4 w-4" />
                {post.comments}
              </button>
              <button className="flex items-center gap-2 px-4 py-2 rounded-lg text-gray-600 hover:bg-gray-50">
                <Share2 className="h-4 w-4" />
                {post.shares}
              </button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderGroups = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      {groups.map((group) => (
        <Card key={group.id}>
          <CardContent className="p-6">
            <div className="flex items-center gap-4 mb-4">
              <div className="text-4xl">{group.image}</div>
              <div className="flex-1">
                <h3 className="font-semibold text-gray-900">{group.name}</h3>
                <p className="text-sm text-gray-600">{group.description}</p>
              </div>
            </div>
            
            <div className="flex justify-between text-sm text-gray-600 mb-4">
              <span>{group.members} 成员</span>
              <span>{group.posts} 帖子</span>
            </div>

            <Button
              variant={group.isJoined ? "outline" : "default"}
              onClick={() => joinGroup(group.id)}
              className="w-full"
            >
              {group.isJoined ? '已加入' : '加入小组'}
            </Button>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderChallenges = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {challenges.map((challenge) => (
        <Card key={challenge.id}>
          <CardContent className="p-6">
            <div className="text-center mb-4">
              <div className="text-4xl mb-2">{challenge.image}</div>
              <h3 className="font-semibold text-gray-900">{challenge.title}</h3>
              <p className="text-sm text-gray-600 mt-1">{challenge.description}</p>
            </div>

            <div className="space-y-3 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">参与人数:</span>
                <span className="font-medium">{challenge.participants}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">剩余天数:</span>
                <span className="font-medium">{challenge.daysLeft} 天</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">奖励:</span>
                <span className="font-medium text-primary-600">{challenge.reward}</span>
              </div>
            </div>

            {challenge.isJoined && (
              <div className="mb-4">
                <div className="flex justify-between text-sm mb-1">
                  <span>进度</span>
                  <span>{challenge.progress}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-primary-500 h-2 rounded-full"
                    style={{ width: `${challenge.progress}%` }}
                  ></div>
                </div>
              </div>
            )}

            <Button
              variant={challenge.isJoined ? "outline" : "default"}
              onClick={() => joinChallenge(challenge.id)}
              className="w-full"
            >
              {challenge.isJoined ? '继续挑战' : '参加挑战'}
            </Button>
          </CardContent>
        </Card>
      ))}
    </div>
  );

  const renderExperts = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {experts.map((expert) => (
        <Card key={expert.id}>
          <CardContent className="p-6 text-center">
            <div className="text-4xl mb-3">{expert.avatar}</div>
            <h3 className="font-semibold text-gray-900">{expert.name}</h3>
            <p className="text-sm text-gray-600">{expert.title}</p>
            <p className="text-sm text-primary-600 mb-3">{expert.speciality}</p>

            <div className="flex justify-center items-center gap-1 mb-3">
              {[...Array(5)].map((_, i) => (
                <div key={i} className={`w-3 h-3 ${i < Math.floor(expert.rating) ? 'text-yellow-500' : 'text-gray-300'}`}>
                  ⭐
                </div>
              ))}
              <span className="text-sm text-gray-600 ml-1">{expert.rating}</span>
            </div>

            <div className="flex justify-between text-sm text-gray-600 mb-4">
              <span>{expert.followers} 粉丝</span>
              <span>{expert.posts} 帖子</span>
            </div>

            <Button
              variant={expert.isFollowed ? "outline" : "default"}
              onClick={() => followExpert(expert.id)}
              className="w-full"
            >
              {expert.isFollowed ? '已关注' : '关注'}
            </Button>
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
            <Users className="h-6 w-6 text-primary-600" />
            健康社区
          </h1>
          <p className="text-gray-600 mt-1">与健康达人一起分享经验，互相鼓励</p>
        </div>
        
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="搜索用户、话题..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10 pr-4 py-2 border border-gray-200 rounded-lg bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
      </div>

      {/* 统计信息 */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4 text-center">
            <div className="text-2xl font-bold text-primary-600">12,345</div>
            <div className="text-sm text-gray-600">活跃用户</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 text-center">
            <div className="text-2xl font-bold text-blue-600">2,567</div>
            <div className="text-sm text-gray-600">今日动态</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 text-center">
            <div className="text-2xl font-bold text-green-600">156</div>
            <div className="text-sm text-gray-600">活跃小组</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 text-center">
            <div className="text-2xl font-bold text-orange-600">89</div>
            <div className="text-sm text-gray-600">进行中挑战</div>
          </CardContent>
        </Card>
      </div>

      {/* 标签页 */}
      <div className="flex gap-2 border-b border-gray-200">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 transition-colors ${
              activeTab === tab.id
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-600 hover:text-gray-900'
            }`}
          >
            <span>{tab.icon}</span>
            {tab.name}
          </button>
        ))}
      </div>

      {/* 内容区域 */}
      <div>
        {activeTab === 'feed' && renderFeed()}
        {activeTab === 'groups' && renderGroups()}
        {activeTab === 'challenges' && renderChallenges()}
        {activeTab === 'experts' && renderExperts()}
      </div>
    </div>
  );
};

export default CommunityPage;
