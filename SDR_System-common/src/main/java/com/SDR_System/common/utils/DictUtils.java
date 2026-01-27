package com.SDR_System.common.utils;

import java.util.Collection;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import org.springframework.beans.factory.NoSuchBeanDefinitionException;
import com.alibaba.fastjson2.JSONArray;
import com.SDR_System.common.constant.CacheConstants;
import com.SDR_System.common.core.domain.entity.SysDictData;
import com.SDR_System.common.core.redis.RedisCache;
import com.SDR_System.common.utils.spring.SpringUtils;

/**
 * 字典工具类
 * 
 * @author ruoyi
 */
public class DictUtils
{
    /**
     * 分隔符
     */
    public static final String SEPARATOR = ",";
    
    /**
     * 内存缓存，当Redis不可用时使用
     */
    private static final ConcurrentHashMap<String, List<SysDictData>> MEMORY_CACHE = new ConcurrentHashMap<>();

    /**
     * 设置字典缓存
     * 
     * @param key 参数键
     * @param dictDatas 字典数据列表
     */
    public static void setDictCache(String key, List<SysDictData> dictDatas)
    {
        try
        {
            RedisCache redisCache = SpringUtils.getBean(RedisCache.class);
            redisCache.setCacheObject(getCacheKey(key), dictDatas);
        }
        catch (NoSuchBeanDefinitionException e)
        {
            // Redis不可用时，使用内存缓存
            System.out.println("[DictUtils] NoSuchBeanDefinitionException: 使用内存缓存 - " + e.getMessage());
            MEMORY_CACHE.put(getCacheKey(key), dictDatas);
        }
        catch (Exception e)
        {
            // 其他异常也使用内存缓存
            System.out.println("[DictUtils] 其他异常: 使用内存缓存 - " + e.getClass().getName() + ": " + e.getMessage());
            MEMORY_CACHE.put(getCacheKey(key), dictDatas);
        }
    }

    /**
     * 获取字典缓存
     * 
     * @param key 参数键
     * @return dictDatas 字典数据列表
     */
    public static List<SysDictData> getDictCache(String key)
    {
        try
        {
            RedisCache redisCache = SpringUtils.getBean(RedisCache.class);
            JSONArray arrayCache = redisCache.getCacheObject(getCacheKey(key));
            if (StringUtils.isNotNull(arrayCache))
            {
                return arrayCache.toList(SysDictData.class);
            }
        }
        catch (NoSuchBeanDefinitionException e)
        {
            // Redis不可用时，使用内存缓存
            return MEMORY_CACHE.get(getCacheKey(key));
        }
        catch (Exception e)
        {
            // 其他异常也使用内存缓存
            return MEMORY_CACHE.get(getCacheKey(key));
        }
        return null;
    }

    /**
     * 根据字典类型和字典值获取字典标签
     * 
     * @param dictType 字典类型
     * @param dictValue 字典值
     * @return 字典标签
     */
    public static String getDictLabel(String dictType, String dictValue)
    {
        if (StringUtils.isEmpty(dictValue))
        {
            return StringUtils.EMPTY;
        }
        return getDictLabel(dictType, dictValue, SEPARATOR);
    }

    /**
     * 根据字典类型和字典标签获取字典值
     * 
     * @param dictType 字典类型
     * @param dictLabel 字典标签
     * @return 字典值
     */
    public static String getDictValue(String dictType, String dictLabel)
    {
        if (StringUtils.isEmpty(dictLabel))
        {
            return StringUtils.EMPTY;
        }
        return getDictValue(dictType, dictLabel, SEPARATOR);
    }

    /**
     * 根据字典类型和字典值获取字典标签
     * 
     * @param dictType 字典类型
     * @param dictValue 字典值
     * @param separator 分隔符
     * @return 字典标签
     */
    public static String getDictLabel(String dictType, String dictValue, String separator)
    {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas))
        {
            return StringUtils.EMPTY;
        }
        if (StringUtils.containsAny(separator, dictValue))
        {
            for (SysDictData dict : datas)
            {
                for (String value : dictValue.split(separator))
                {
                    if (value.equals(dict.getDictValue()))
                    {
                        propertyString.append(dict.getDictLabel()).append(separator);
                        break;
                    }
                }
            }
        }
        else
        {
            for (SysDictData dict : datas)
            {
                if (dictValue.equals(dict.getDictValue()))
                {
                    return dict.getDictLabel();
                }
            }
        }
        return StringUtils.stripEnd(propertyString.toString(), separator);
    }

    /**
     * 根据字典类型和字典标签获取字典值
     * 
     * @param dictType 字典类型
     * @param dictLabel 字典标签
     * @param separator 分隔符
     * @return 字典值
     */
    public static String getDictValue(String dictType, String dictLabel, String separator)
    {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas))
        {
            return StringUtils.EMPTY;
        }
        if (StringUtils.containsAny(separator, dictLabel))
        {
            for (SysDictData dict : datas)
            {
                for (String label : dictLabel.split(separator))
                {
                    if (label.equals(dict.getDictLabel()))
                    {
                        propertyString.append(dict.getDictValue()).append(separator);
                        break;
                    }
                }
            }
        }
        else
        {
            for (SysDictData dict : datas)
            {
                if (dictLabel.equals(dict.getDictLabel()))
                {
                    return dict.getDictValue();
                }
            }
        }
        return StringUtils.stripEnd(propertyString.toString(), separator);
    }

    /**
     * 根据字典类型获取字典所有值
     *
     * @param dictType 字典类型
     * @return 字典值
     */
    public static String getDictValues(String dictType)
    {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas))
        {
            return StringUtils.EMPTY;
        }
        for (SysDictData dict : datas)
        {
            propertyString.append(dict.getDictValue()).append(SEPARATOR);
        }
        return StringUtils.stripEnd(propertyString.toString(), SEPARATOR);
    }

    /**
     * 根据字典类型获取字典所有标签
     *
     * @param dictType 字典类型
     * @return 字典值
     */
    public static String getDictLabels(String dictType)
    {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas))
        {
            return StringUtils.EMPTY;
        }
        for (SysDictData dict : datas)
        {
            propertyString.append(dict.getDictLabel()).append(SEPARATOR);
        }
        return StringUtils.stripEnd(propertyString.toString(), SEPARATOR);
    }

    /**
     * 删除指定字典缓存
     * 
     * @param key 字典键
     */
    public static void removeDictCache(String key)
    {
        try
        {
            RedisCache redisCache = SpringUtils.getBean(RedisCache.class);
            redisCache.deleteObject(getCacheKey(key));
        }
        catch (NoSuchBeanDefinitionException e)
        {
            // Redis不可用时，从内存缓存中删除
            MEMORY_CACHE.remove(getCacheKey(key));
        }
        catch (Exception e)
        {
            // 其他异常也从内存缓存中删除
            MEMORY_CACHE.remove(getCacheKey(key));
        }
    }

    /**
     * 清空字典缓存
     */
    public static void clearDictCache()
    {
        try
        {
            RedisCache redisCache = SpringUtils.getBean(RedisCache.class);
            Collection<String> keys = redisCache.keys(CacheConstants.SYS_DICT_KEY + "*");
            redisCache.deleteObject(keys);
        }
        catch (NoSuchBeanDefinitionException e)
        {
            // Redis不可用时，清空内存缓存
            MEMORY_CACHE.entrySet().removeIf(entry -> entry.getKey().startsWith(CacheConstants.SYS_DICT_KEY));
        }
        catch (Exception e)
        {
            // 其他异常也清空内存缓存
            MEMORY_CACHE.entrySet().removeIf(entry -> entry.getKey().startsWith(CacheConstants.SYS_DICT_KEY));
        }
    }

    /**
     * 设置cache key
     * 
     * @param configKey 参数键
     * @return 缓存键key
     */
    public static String getCacheKey(String configKey)
    {
        return CacheConstants.SYS_DICT_KEY + configKey;
    }
}
