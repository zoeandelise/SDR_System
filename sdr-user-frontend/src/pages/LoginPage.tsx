// 登录页面 - 基于若依登录逻辑
import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { login, register, getCaptcha, checkUserNeedsInit, type LoginParams, type RegisterParams } from '../services/authService';
import { isAuthenticated } from '../utils/auth';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [isLogin, setIsLogin] = useState(true);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  // 登录表单
  // 验证码状态
  const [captchaUrl, setCaptchaUrl] = useState('');
  const [loginForm, setLoginForm] = useState({
    username: 'admin',
    password: 'admin123',
    rememberMe: false,
    code: '',
    uuid: ''
  });

  // 注册表单
  const [registerForm, setRegisterForm] = useState({
    username: '',
    password: '',
    confirmPassword: '',
    email: '',
    nickName: ''
  });

  useEffect(() => {
    // 如果已经登录，重定向到首页
    if (isAuthenticated()) {
      const from = (location.state as any)?.from || '/';
      navigate(from, { replace: true });
      return;
    }
  }, [navigate, location]);

  const RefreshCaptcha = async () => {
    try {
      const res = await getCaptcha();
      setCaptchaUrl('data:image/gif;base64,' + res.img);
      setLoginForm(p => ({ ...p, uuid: res.uuid }));
    } catch (error) {
      console.error('获取验证码失败', error);
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!loginForm.username || !loginForm.password) {
      setMessage('请输入用户名和密码');
      return;
    }


    setLoading(true);
    setMessage('');
    try {
      await login({
        username: loginForm.username,
        password: loginForm.password,
        code: loginForm.code,
        uuid: loginForm.uuid
      });

      // 登录成功后，立即检查是否为未填基础信息的新人
      const needsInit = await checkUserNeedsInit();

      if (needsInit) {
        // 新人强制路由到健康目标并提示
        navigate('/health-goal', {
          replace: true,
          state: { showNewUserWelcome: true }
        });
      } else {
        // 老用户正常跳回之前被拦截的地方或首页
        const from = (location.state as any)?.from || '/';
        navigate(from, { replace: true });
      }

    } catch (error: any) {
      console.error('登录失败:', error);
      setMessage(error.message || '登录失败，请检查用户名、密码或验证码');
      // 失败后刷新验证码
      RefreshCaptcha();
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    // ... existing register logic ...
    e.preventDefault();
    if (!registerForm.username || !registerForm.password) {
      setMessage('请输入用户名和密码');
      return;
    }
    if (registerForm.password !== registerForm.confirmPassword) {
      setMessage('两次输入的密码不一致');
      return;
    }
    setLoading(true);
    setMessage('');
    try {
      await register({
        username: registerForm.username,
        password: registerForm.password,
        email: registerForm.email,
        nickName: registerForm.nickName
      });
      setMessage('注册成功，请登录');
      setIsLogin(true);
      setRegisterForm({ username: '', password: '', confirmPassword: '', email: '', nickName: '' });
    } catch (error: any) {
      console.error('注册失败:', error);
      setMessage(error.message || '注册失败，请重试');
    } finally {
      setLoading(false);
    }
  };

  const handleFormSwitch = () => {
    setIsLogin(!isLogin);
    setMessage('');
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-600 via-teal-600 to-emerald-800 py-12 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* 动态背景球 */}
      <div className="absolute top-0 left-0 w-96 h-96 bg-white/10 rounded-full blur-3xl -translate-x-1/2 -translate-y-1/2"></div>
      <div className="absolute bottom-0 right-0 w-96 h-96 bg-yellow-400/10 rounded-full blur-3xl translate-x-1/2 translate-y-1/2"></div>

      <div className="max-w-md w-full space-y-8 relative z-10 animate-fade-in">
        <div className="text-center">
          <div className="mx-auto h-20 w-20 flex items-center justify-center rounded-2xl bg-white/20 backdrop-blur-md shadow-xl text-5xl mb-6">
            🥗
          </div>
          <h2 className="text-center text-3xl font-bold text-white tracking-tight">
            {isLogin ? '欢迎回到健康生活' : '开启您的健康之旅'}
          </h2>
          <p className="mt-2 text-center text-sm text-primary-100">
            {isLogin ? '登录以继续您的个性化饮食计划' : '注册即刻享受 AI 智能推荐'}
          </p>
        </div>

        <Card className="bg-white/95 backdrop-blur-xl shadow-2xl border-0 p-8 sm:rounded-2xl">
          <form className="space-y-6" onSubmit={isLogin ? handleLogin : handleRegister}>
            <div className="space-y-4">
              {/* 用户名 */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">用户名</label>
                <input
                  required
                  className="appearance-none block w-full px-3 py-2.5 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                  placeholder="请输入您的用户名"
                  value={isLogin ? loginForm.username : registerForm.username}
                  onChange={(e) => isLogin
                    ? setLoginForm(p => ({ ...p, username: e.target.value }))
                    : setRegisterForm(p => ({ ...p, username: e.target.value }))
                  }
                />
              </div>

              {/* 密码 */}
              <div className="grid grid-cols-2 gap-4">
                <div className={isLogin ? "col-span-2" : "col-span-1"}>
                  <label className="block text-sm font-medium text-gray-700 mb-1">密码</label>
                  <input
                    type="password"
                    required
                    className="appearance-none block w-full px-3 py-2.5 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                    placeholder="密码"
                    value={isLogin ? loginForm.password : registerForm.password}
                    onChange={(e) => isLogin
                      ? setLoginForm(p => ({ ...p, password: e.target.value }))
                      : setRegisterForm(p => ({ ...p, password: e.target.value }))
                    }
                  />
                </div>
                {!isLogin && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">确认密码</label>
                    <input
                      type="password"
                      required
                      className="appearance-none block w-full px-3 py-2.5 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                      placeholder="确认"
                      value={registerForm.confirmPassword}
                      onChange={(e) => setRegisterForm(p => ({ ...p, confirmPassword: e.target.value }))}
                    />
                  </div>
                )}
              </div>



              {!isLogin && (
                <>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">昵称 (可选)</label>
                    <input
                      className="appearance-none block w-full px-3 py-2.5 border border-gray-300 rounded-lg placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all bg-gray-50 focus:bg-white"
                      value={registerForm.nickName}
                      onChange={(e) => setRegisterForm(p => ({ ...p, nickName: e.target.value }))}
                    />
                  </div>
                </>
              )}
            </div>

            {isLogin && (
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded cursor-pointer"
                    checked={loginForm.rememberMe}
                    onChange={(e) => setLoginForm(p => ({ ...p, rememberMe: e.target.checked }))}
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-600 cursor-pointer">
                    记住我
                  </label>
                </div>
                <div className="text-sm">
                  <a href="#" className="font-medium text-primary-600 hover:text-primary-500">
                    忘记密码?
                  </a>
                </div>
              </div>
            )}

            {message && (
              <div className={`p-3 rounded-lg text-sm text-center font-medium animate-pulse ${message.includes('成功') ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'
                }`}>
                {message}
              </div>
            )}

            <Button
              type="submit"
              disabled={loading}
              className="w-full text-lg shadow-lg hover:shadow-primary-500/30"
              size="lg"
            >
              {loading ? (
                <div className="flex items-center">
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  处理中...
                </div>
              ) : (
                isLogin ? '登录' : '注册并登录'
              )}
            </Button>
          </form>

          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-200"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-400">
                  {isLogin ? '还没有账户？' : '已有账户？'}
                </span>
              </div>
            </div>

            <div className="mt-6 text-center">
              <button
                onClick={handleFormSwitch}
                className="text-primary-600 hover:text-primary-700 font-medium hover:underline transition-all"
              >
                {isLogin ? '立即创建一个新账户' : '返回登录'}
              </button>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default LoginPage;
