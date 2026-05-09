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
  withCredentials: true, // 支持跨域cookie
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
      window.location.href = '/login';
      return Promise.reject(new Error(res.msg || '认证失败'));
    } else {
      return Promise.reject(new Error(res.msg || '请求失败'));
    }
  },
  (error) => {
    console.error('API请求错误:', error);

    if (error.response?.status === 401) {
      removeToken();
      window.location.href = '/login';
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
    window.location.href = '/login';
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

// 检查用户是否需要初始化健康信息（即首次登录，或者从未保存过个人的身高体重等数据）
export const checkUserNeedsInit = async (): Promise<boolean> => {
  try {
    // 调用 healthAPI 获取信息
    // 注意：我们通过 authApi 实例去发这个带 Token 的请求，以避免循环依赖 api.ts
    const response: any = await authApi.get('/diet/health/my').catch(() => null);

    if (response && response.data) {
      const h = response.data;
      // 判定逻辑：如果 height / weight 都为 null / 0，或者某些关键指标为 0，基本判定为没使用过
      if (!h.weight || h.weight <= 0) {
        return true;
      }
      return false; // 已有有效数据
    }

    // 接口没数据返回，肯定是没初始化
    return true;
  } catch (error) {
    console.error('检查用户初始化状态失败', error);
    // 发生异常保守默认放行
    return false;
  }
};
