package com.SDR_System.framework.interceptor.impl;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;
import com.alibaba.fastjson2.JSON;
import com.SDR_System.common.annotation.RepeatSubmit;
import com.SDR_System.common.filter.RepeatedlyRequestWrapper;
import com.SDR_System.common.utils.StringUtils;
import com.SDR_System.common.utils.http.HttpHelper;
import com.SDR_System.framework.interceptor.RepeatSubmitInterceptor;

/**
 * 简单的重复提交拦截器（不依赖Redis）
 * 
 * @author SDR_System
 */
@Component
@ConditionalOnMissingBean(SameUrlDataInterceptor.class)
public class SimpleRepeatSubmitInterceptor extends RepeatSubmitInterceptor
{
    // 内存存储重复提交数据（生产环境应该使用更好的解决方案）
    private final Map<String, RepeatData> submitCache = new ConcurrentHashMap<>();

    // 令牌自定义标识
    @Value("${token.header}")
    private String header;

    @Override
    public boolean isRepeatSubmit(HttpServletRequest request, RepeatSubmit annotation)
    {
        String nowParams = "";
        if (request instanceof RepeatedlyRequestWrapper)
        {
            RepeatedlyRequestWrapper repeatedlyRequest = (RepeatedlyRequestWrapper) request;
            nowParams = HttpHelper.getBodyString(repeatedlyRequest);
        }

        // body参数为空，获取Parameter的数据
        if (StringUtils.isEmpty(nowParams))
        {
            nowParams = JSON.toJSONString(request.getParameterMap());
        }
        
        // 请求地址（作为存放cache的key值）
        String url = request.getRequestURI();

        // 唯一值（没有消息头则使用请求地址）
        String submitKey = StringUtils.trimToEmpty(request.getHeader(header));

        // 唯一标识（指定key + url + 消息头）
        String cacheRepeatKey = "repeat_submit:" + submitKey + ":" + url;

        String requestTime = String.valueOf(System.currentTimeMillis());

        // 如果缓存中存在
        RepeatData existData = submitCache.get(cacheRepeatKey);
        if (existData != null)
        {
            String saveRequestTime = existData.repeatTime;
            // 请求参数
            String saveParams = existData.repeatParams;

            // 如果当前请求与上次请求  请求参数不同，重置缓存
            if (!compareParams(nowParams, saveParams))
            {
                submitCache.put(cacheRepeatKey, new RepeatData(nowParams, requestTime));
                return false;
            }

            // 两次相同参数的请求间隔时间
            if ((Long.parseLong(requestTime) - Long.parseLong(saveRequestTime)) < annotation.interval())
            {
                return true;
            }
        }

        // 缓存当前请求信息
        submitCache.put(cacheRepeatKey, new RepeatData(nowParams, requestTime));
        
        // 定期清理过期数据（简单实现）
        cleanExpiredData(annotation.interval());
        
        return false;
    }

    /**
     * 判断参数是否相同
     */
    private boolean compareParams(String nowParams, String preParams)
    {
        return nowParams.equals(preParams);
    }

    /**
     * 清理过期数据
     */
    private void cleanExpiredData(int intervalTime)
    {
        long currentTime = System.currentTimeMillis();
        submitCache.entrySet().removeIf(entry -> 
            (currentTime - Long.parseLong(entry.getValue().repeatTime)) > (intervalTime * 10)
        );
    }

    /**
     * 重复提交数据
     */
    private static class RepeatData
    {
        String repeatParams;
        String repeatTime;

        RepeatData(String repeatParams, String repeatTime)
        {
            this.repeatParams = repeatParams;
            this.repeatTime = repeatTime;
        }
    }
}