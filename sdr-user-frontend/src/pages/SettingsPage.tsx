import React, { useState, useEffect } from 'react';
import { 
  User, 
  Bell, 
  Shield, 
  Palette, 
  Globe, 
  HelpCircle, 
  LogOut,
  Camera,
  Save,
  Edit,
  Target,
  Activity,
  Scale
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { useAuth } from '../components/AuthGuard';
import { useNavigate } from 'react-router-dom';

const SettingsPage: React.FC = () => {
  const { userInfo, logout } = useAuth();
  const navigate = useNavigate();
  
  const [activeTab, setActiveTab] = useState('profile');
  const [loading, setLoading] = useState(false);
  const [profileData, setProfileData] = useState({
    nickname: '',
    email: '',
    phone: '',
    birthday: '',
    gender: 'male',
    height: '',
    weight: '',
    targetWeight: '',
    activityLevel: 'moderate',
    dietGoal: 'maintain'
  });

  const [notificationSettings, setNotificationSettings] = useState({
    mealReminder: true,
    exerciseReminder: false,
    weeklyReport: true,
    promotions: false
  });

  const [preferences, setPreferences] = useState({
    theme: 'light',
    language: 'zh-CN',
    units: 'metric'
  });

  // 获取用户信息
  useEffect(() => {
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      try {
        const parsed = JSON.parse(storedUserInfo);
        setProfileData(prev => ({
          ...prev,
          nickname: parsed.nickName || parsed.userName || '',
          email: parsed.email || ''
        }));
      } catch (e) {
        console.error('解析用户信息失败:', e);
      }
    }
  }, []);

  const handleProfileSave = async () => {
    setLoading(true);
    try {
      // 这里应该调用API更新用户信息
      // await userApi.updateProfile(profileData);
      
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 更新本地存储
      const currentUserInfo = JSON.parse(localStorage.getItem('userInfo') || '{}');
      const updatedUserInfo = {
        ...currentUserInfo,
        nickName: profileData.nickname,
        email: profileData.email
      };
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo));
      
      alert('个人信息更新成功！');
    } catch (error) {
      console.error('更新失败:', error);
      alert('更新失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    if (window.confirm('确定要退出登录吗？')) {
      logout();
    }
  };

  const tabs = [
    { id: 'profile', label: '个人资料', icon: User },
    { id: 'health', label: '健康信息', icon: Activity },
    { id: 'notifications', label: '通知设置', icon: Bell },
    { id: 'preferences', label: '偏好设置', icon: Palette },
    { id: 'security', label: '安全设置', icon: Shield },
    { id: 'help', label: '帮助支持', icon: HelpCircle }
  ];

  const renderProfileTab = () => (
    <div className="space-y-6">
      {/* 头像部分 */}
      <Card>
        <CardHeader>
          <CardTitle>头像设置</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center space-x-4">
            <div className="w-20 h-20 bg-gradient-to-br from-primary-400 to-primary-600 rounded-full flex items-center justify-center">
              <User className="h-10 w-10 text-white" />
            </div>
            <div>
              <Button variant="outline" size="sm">
                <Camera className="h-4 w-4 mr-2" />
                更换头像
              </Button>
              <p className="text-sm text-gray-500 mt-1">
                支持 JPG、PNG 格式，建议尺寸 200x200px
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 基本信息 */}
      <Card>
        <CardHeader>
          <CardTitle>基本信息</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                昵称
              </label>
              <input
                type="text"
                value={profileData.nickname}
                onChange={(e) => setProfileData(prev => ({ ...prev, nickname: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入昵称"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                邮箱
              </label>
              <input
                type="email"
                value={profileData.email}
                onChange={(e) => setProfileData(prev => ({ ...prev, email: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入邮箱"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                手机号
              </label>
              <input
                type="tel"
                value={profileData.phone}
                onChange={(e) => setProfileData(prev => ({ ...prev, phone: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入手机号"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                生日
              </label>
              <input
                type="date"
                value={profileData.birthday}
                onChange={(e) => setProfileData(prev => ({ ...prev, birthday: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              性别
            </label>
            <div className="flex space-x-4">
              {[
                { value: 'male', label: '男' },
                { value: 'female', label: '女' },
                { value: 'other', label: '其他' }
              ].map((option) => (
                <label key={option.value} className="flex items-center">
                  <input
                    type="radio"
                    name="gender"
                    value={option.value}
                    checked={profileData.gender === option.value}
                    onChange={(e) => setProfileData(prev => ({ ...prev, gender: e.target.value }))}
                    className="mr-2"
                  />
                  {option.label}
                </label>
              ))}
            </div>
          </div>

          <div className="flex justify-end">
            <Button onClick={handleProfileSave} disabled={loading}>
              {loading ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                  保存中...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  保存更改
                </>
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const renderHealthTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Scale className="h-5 w-5 mr-2" />
            身体数据
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                身高 (cm)
              </label>
              <input
                type="number"
                value={profileData.height}
                onChange={(e) => setProfileData(prev => ({ ...prev, height: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入身高"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                当前体重 (kg)
              </label>
              <input
                type="number"
                value={profileData.weight}
                onChange={(e) => setProfileData(prev => ({ ...prev, weight: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入体重"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                目标体重 (kg)
              </label>
              <input
                type="number"
                value={profileData.targetWeight}
                onChange={(e) => setProfileData(prev => ({ ...prev, targetWeight: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="请输入目标体重"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Target className="h-5 w-5 mr-2" />
            健康目标
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              活动水平
            </label>
            <select
              value={profileData.activityLevel}
              onChange={(e) => setProfileData(prev => ({ ...prev, activityLevel: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="sedentary">久坐不动</option>
              <option value="light">轻度活动</option>
              <option value="moderate">中度活动</option>
              <option value="active">高度活动</option>
              <option value="very_active">极度活动</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              饮食目标
            </label>
            <select
              value={profileData.dietGoal}
              onChange={(e) => setProfileData(prev => ({ ...prev, dietGoal: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="lose">减重</option>
              <option value="maintain">维持</option>
              <option value="gain">增重</option>
              <option value="muscle">增肌</option>
            </select>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const renderNotificationsTab = () => (
    <Card>
      <CardHeader>
        <CardTitle>通知偏好</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {[
          { key: 'mealReminder', label: '用餐提醒', description: '在用餐时间提醒您记录饮食' },
          { key: 'exerciseReminder', label: '运动提醒', description: '提醒您进行日常运动' },
          { key: 'weeklyReport', label: '周报', description: '每周发送健康数据总结' },
          { key: 'promotions', label: '推广信息', description: '接收产品更新和优惠信息' }
        ].map((item) => (
          <div key={item.key} className="flex items-center justify-between p-4 border border-gray-200 rounded-xl">
            <div>
              <h3 className="font-medium">{item.label}</h3>
              <p className="text-sm text-gray-500">{item.description}</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                checked={notificationSettings[item.key as keyof typeof notificationSettings]}
                onChange={(e) => setNotificationSettings(prev => ({
                  ...prev,
                  [item.key]: e.target.checked
                }))}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
            </label>
          </div>
        ))}
      </CardContent>
    </Card>
  );

  const renderPreferencesTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>显示偏好</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              主题
            </label>
            <select
              value={preferences.theme}
              onChange={(e) => setPreferences(prev => ({ ...prev, theme: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="light">浅色主题</option>
              <option value="dark">深色主题</option>
              <option value="auto">跟随系统</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              语言
            </label>
            <select
              value={preferences.language}
              onChange={(e) => setPreferences(prev => ({ ...prev, language: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="zh-CN">简体中文</option>
              <option value="en-US">English</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              单位制
            </label>
            <select
              value={preferences.units}
              onChange={(e) => setPreferences(prev => ({ ...prev, units: e.target.value }))}
              className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="metric">公制 (kg, cm)</option>
              <option value="imperial">英制 (lb, ft)</option>
            </select>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const renderSecurityTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>密码安全</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button variant="outline" className="w-full">
            <Edit className="h-4 w-4 mr-2" />
            修改密码
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>账户管理</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <Button variant="outline" onClick={() => navigate('/data-export')}>
            导出数据
          </Button>
          <Button variant="outline" className="text-red-600 border-red-200 hover:bg-red-50">
            删除账户
          </Button>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>退出登录</CardTitle>
        </CardHeader>
        <CardContent>
          <Button 
            variant="outline" 
            onClick={handleLogout}
            className="text-red-600 border-red-200 hover:bg-red-50"
          >
            <LogOut className="h-4 w-4 mr-2" />
            退出当前账户
          </Button>
        </CardContent>
      </Card>
    </div>
  );

  const renderHelpTab = () => (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>常见问题</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {[
            '如何使用AI食物识别功能？',
            '如何设置营养目标？',
            '如何导出我的数据？',
            '如何联系客服？'
          ].map((question, index) => (
            <button
              key={index}
              className="w-full text-left p-3 border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors"
            >
              {question}
            </button>
          ))}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>联系我们</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm text-gray-600">
            <p>邮箱: support@diet-assistant.com</p>
            <p>电话: 400-123-4567</p>
            <p>工作时间: 周一至周五 9:00-18:00</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>关于应用</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-sm text-gray-600">
            <p>智能饮食助手 v1.0.0</p>
            <p>© 2025 智能饮食助手团队</p>
          </div>
        </CardContent>
      </Card>
    </div>
  );

  const renderTabContent = () => {
    switch (activeTab) {
      case 'profile':
        return renderProfileTab();
      case 'health':
        return renderHealthTab();
      case 'notifications':
        return renderNotificationsTab();
      case 'preferences':
        return renderPreferencesTab();
      case 'security':
        return renderSecurityTab();
      case 'help':
        return renderHelpTab();
      default:
        return renderProfileTab();
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">个人设置</h1>
        <p className="text-gray-600 mt-1">管理您的个人资料和应用偏好</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Sidebar */}
        <div className="lg:col-span-1">
          <Card>
            <CardContent className="p-0">
              <nav className="space-y-1">
                {tabs.map((tab) => {
                  const Icon = tab.icon;
                  return (
                    <button
                      key={tab.id}
                      onClick={() => setActiveTab(tab.id)}
                      className={`w-full flex items-center px-4 py-3 text-sm font-medium rounded-none first:rounded-t-xl last:rounded-b-xl transition-colors ${
                        activeTab === tab.id
                          ? 'bg-primary-50 text-primary-700 border-r-2 border-primary-500'
                          : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                      }`}
                    >
                      <Icon className="h-5 w-5 mr-3" />
                      {tab.label}
                    </button>
                  );
                })}
              </nav>
            </CardContent>
          </Card>
        </div>

        {/* Main Content */}
        <div className="lg:col-span-3">
          {renderTabContent()}
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;