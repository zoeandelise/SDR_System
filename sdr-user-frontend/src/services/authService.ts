// 认证服务 - 基于若依登录API
import axios from 'axios';
import { getToken, setToken, removeToken, setUserInfo } from '../utils/auth';

// API配置
// API配置 - 使用相对路径以支持代理
const API_BASE_URL = ''; // 为空则使用当前域名，走devServer代理

// 创建axios实例
const authApi = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// 请求拦截器
authApi.interceptors.request.use(
  (config) => {
    const token = getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
authApi.interceptors.response.use(
  (response) => {
    const res = response.data;

    // 若依框架的响应格式处理
    if (res.code === 200) {
      return res;
    } else if (res.code === 401) {
      // 未授权，清除token
      removeToken();
      window.location.href = '/auth/login';
      return Promise.reject(new Error(res.msg || '认证失败'));
    } else {
      return Promise.reject(new Error(res.msg || '请求失败'));
    }
  },
  (error) => {
    console.error('API请求错误:', error);

    if (error.response?.status === 401) {
      removeToken();
      window.location.href = '/auth/login';
    }

    return Promise.reject(error);
  }
);

// 登录接口
export interface LoginParams {
  username: string;
  password: string;
  code?: string;
  uuid?: string;
}

export interface LoginResponse {
  token: string;
  user: {
    userId: number;
    userName: string;
    nickName: string;
    avatar?: string;
  };
  roles: string[];
  permissions: string[];
}

// 验证码响应
export interface CaptchaResponse {
  img: string;
  uuid: string;
  captchaEnabled: boolean;
}

// 登录
export const login = async (params: LoginParams): Promise<LoginResponse> => {
  const response: any = await authApi.post('/login', {
    username: params.username,
    password: params.password,
    code: params.code,
    uuid: params.uuid
  });

  if (response.token) {
    setToken(response.token);
  }

  return response as LoginResponse;
};

// 获取用户信息
export const getUserInfo = async (): Promise<any> => {
  const response: any = await authApi.get('/getInfo');

  if (response.user) {
    setUserInfo(response);
  }

  return response;
};

// 登出
export const logout = async (): Promise<void> => {
  try {
    await authApi.post('/logout');
  } catch (error) {
    console.error('登出请求失败:', error);
  } finally {
    removeToken();
    localStorage.removeItem('userInfo');
    window.location.href = '/auth/login';
  }
};

// 注册
export interface RegisterParams {
  username: string;
  password: string;
  email?: string;
  nickName?: string;
}

export const register = async (params: RegisterParams): Promise<void> => {
  await authApi.post('/register', params);
};

// 获取验证码
export const getCaptcha = async (): Promise<CaptchaResponse> => {
  const response: any = await authApi.get('/captchaImage');
  return response as CaptchaResponse;
};

// 检查认证状态
export const checkAuth = async (): Promise<boolean> => {
  try {
    const token = getToken();
    if (!token) {
      return false;
    }

    await getUserInfo();
    return true;
  } catch (error) {
    console.error('认证检查失败:', error);
    removeToken();
    return false;
  }
};
