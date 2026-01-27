package com.SDR_System.framework.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Arrays;

/**
 * 全局CORS跨域配置
 * 
 * 解决前后端分离项目的跨域访问问题
 * 支持前端axios withCredentials: true 配置
 * 
 * @author SDR_System
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    /**
     * 全局跨域配置
     * 通过重写addCorsMappings方法实现跨域设置
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                // 允许的源地址
                .allowedOrigins(
                    "http://localhost:3000",  // 用户端前端
                    "http://localhost:81",    // 管理端前端  
                    "http://127.0.0.1:3000",  // 用户端前端（IP访问）
                    "http://127.0.0.1:81"     // 管理端前端（IP访问）
                )
                // 允许的请求方法
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
                // 允许的请求头
                .allowedHeaders("*")
                // 允许发送凭据（重要：与前端 withCredentials: true 配套）
                .allowCredentials(true)
                // 预检请求的有效期，单位为秒
                .maxAge(3600)
                // 允许暴露的响应头
                .exposedHeaders(
                    "Authorization", 
                    "Content-Type", 
                    "X-Requested-With",
                    "accept",
                    "Origin",
                    "Access-Control-Request-Method",
                    "Access-Control-Request-Headers"
                );
    }

    /**
     * CORS配置源
     * 提供更细粒度的CORS配置
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 允许的源（不能使用通配符*，因为allowCredentials=true时不兼容）
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",    // 用户端前端
            "http://localhost:81",      // 管理端前端
            "http://127.0.0.1:3000",    // 用户端前端（IP访问）
            "http://127.0.0.1:81"       // 管理端前端（IP访问）
        ));
        
        // 允许的HTTP方法
        configuration.setAllowedMethods(Arrays.asList(
            "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));
        
        // 允许的请求头
        configuration.setAllowedHeaders(Arrays.asList("*"));
        
        // 关键配置：允许发送认证信息（cookies, authorization headers等）
        configuration.setAllowCredentials(true);
        
        // 预检请求缓存时间
        configuration.setMaxAge(3600L);
        
        // 允许暴露的响应头
        configuration.setExposedHeaders(Arrays.asList(
            "Authorization", 
            "Content-Type", 
            "X-Requested-With",
            "accept",
            "Origin",
            "Access-Control-Request-Method",
            "Access-Control-Request-Headers"
        ));
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
