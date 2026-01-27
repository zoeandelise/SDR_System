package com.SDR_System.framework.web.service;

import javax.servlet.http.HttpServletRequest;
import com.SDR_System.common.core.domain.model.LoginUser;

/**
 * Token服务接口
 * 
 * @author SDR_System
 */
public interface ITokenService
{
    /**
     * 获取用户身份信息
     * 
     * @return 用户信息
     */
    LoginUser getLoginUser(HttpServletRequest request);

    /**
     * 设置用户身份信息
     */
    void setLoginUser(LoginUser loginUser);

    /**
     * 删除用户身份信息
     */
    void delLoginUser(String token);

    /**
     * 创建令牌
     * 
     * @param loginUser 用户信息
     * @return 令牌
     */
    String createToken(LoginUser loginUser);

    /**
     * 验证令牌有效期，相差不足20分钟，自动刷新缓存
     * 
     * @param loginUser
     * @return 令牌
     */
    void verifyToken(LoginUser loginUser);

    /**
     * 刷新令牌有效期
     * 
     * @param loginUser 登录信息
     */
    void refreshToken(LoginUser loginUser);
}
