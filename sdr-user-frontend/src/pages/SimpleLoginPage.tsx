// 简洁现代的登录页面
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { login, type LoginParams } from '../services/authService';
import { isAuthenticated } from '../utils/auth';

const SimpleLoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [loginForm, setLoginForm] = useState({
    username: 'admin',
    password: 'admin123'
  });

  useEffect(() => {
    if (isAuthenticated()) {
      navigate('/', { replace: true });
    }
  }, [navigate]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!loginForm.username || !loginForm.password) {
      setMessage('请输入用户名和密码');
      return;
    }

    setLoading(true);
    setMessage('');

    try {
      const params: LoginParams = {
        username: loginForm.username,
        password: loginForm.password
      };

      await login(params);
      navigate('/', { replace: true });

    } catch (error: any) {
      console.error('登录失败:', error);
      setMessage(error.message || '登录失败，请检查用户名和密码');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-400 via-blue-500 to-purple-600 flex items-center justify-center p-4">
      <div className="max-w-md w-full">
        {/* Logo和标题 */}
        <div className="text-center mb-8">
          <div className="inline-block p-4 bg-white rounded-2xl shadow-xl mb-4">
            <span className="text-6xl">🥗</span>
          </div>
          <h1 className="text-4xl font-bold text-white mb-2">
            智能健康饮食助手
          </h1>
          <p className="text-green-100">基于协同过滤的个性化推荐系统</p>
        </div>

        {/* 登录卡片 */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">
            登录您的账户
          </h2>

          {message && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
              {message}
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                用户名
              </label>
              <input
                type="text"
                value={loginForm.username}
                onChange={(e) => setLoginForm({ ...loginForm, username: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                placeholder="请输入用户名"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                密码
              </label>
              <input
                type="password"
                value={loginForm.password}
                onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                placeholder="请输入密码"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-gradient-to-r from-green-500 to-blue-500 text-white rounded-lg font-semibold hover:from-green-600 hover:to-blue-600 transition-all disabled:opacity-50"
            >
              {loading ? '登录中...' : '登录'}
            </button>
          </form>

          <div className="mt-6 text-center text-sm text-gray-600">
            <p>测试账号：admin / admin123</p>
          </div>
        </div>

        {/* 底部信息 */}
        <div className="mt-8 text-center text-white text-sm">
          <p>© 2025 智能健康饮食推荐系统</p>
          <p className="mt-1 text-green-100">160个用户 • 55种食物 • 100%真实数据</p>
        </div>
      </div>
    </div>
  );
};

export default SimpleLoginPage;

