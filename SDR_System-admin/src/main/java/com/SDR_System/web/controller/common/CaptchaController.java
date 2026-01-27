package com.SDR_System.web.controller.common;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.FastByteArrayOutputStream;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.google.code.kaptcha.Producer;
import com.SDR_System.common.config.RuoYiConfig;
import com.SDR_System.common.constant.CacheConstants;
import com.SDR_System.common.constant.Constants;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.core.redis.RedisCache;
import com.SDR_System.common.utils.sign.Base64;
import com.SDR_System.common.utils.uuid.IdUtils;
import com.SDR_System.system.service.ISysConfigService;

/**
 * 验证码操作处理
 * 
 * @author ruoyi
 */
@RestController
public class CaptchaController
{
    @Resource(name = "captchaProducer")
    private Producer captchaProducer;

    @Resource(name = "captchaProducerMath")
    private Producer captchaProducerMath;

    @Autowired(required = false)
    private RedisCache redisCache;
    
    @Autowired
    private ISysConfigService configService;

    // 内存存储验证码（当Redis不可用时）
    private final ConcurrentHashMap<String, CaptchaData> captchaCache = new ConcurrentHashMap<>();
    /**
     * 生成验证码
     */
    @GetMapping("/captchaImage")
    public AjaxResult getCode(HttpServletResponse response) throws IOException
    {
        AjaxResult ajax = AjaxResult.success();
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        ajax.put("captchaEnabled", captchaEnabled);
        if (!captchaEnabled)
        {
            return ajax;
        }

        // 保存验证码信息
        String uuid = IdUtils.simpleUUID();
        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + uuid;

        String capStr = null, code = null;
        BufferedImage image = null;

        // 生成验证码
        String captchaType = RuoYiConfig.getCaptchaType();
        if ("math".equals(captchaType))
        {
            String capText = captchaProducerMath.createText();
            capStr = capText.substring(0, capText.lastIndexOf("@"));
            code = capText.substring(capText.lastIndexOf("@") + 1);
            image = captchaProducerMath.createImage(capStr);
        }
        else if ("char".equals(captchaType))
        {
            capStr = code = captchaProducer.createText();
            image = captchaProducer.createImage(capStr);
        }

        // 存储验证码
        if (redisCache != null) {
            redisCache.setCacheObject(verifyKey, code, Constants.CAPTCHA_EXPIRATION, TimeUnit.MINUTES);
        } else {
            // 使用内存存储
            long expireTime = System.currentTimeMillis() + Constants.CAPTCHA_EXPIRATION * 60 * 1000;
            captchaCache.put(verifyKey, new CaptchaData(code, expireTime));
            // 清理过期数据
            cleanExpiredCaptcha();
        }
        // 转换流信息写出
        FastByteArrayOutputStream os = new FastByteArrayOutputStream();
        try
        {
            ImageIO.write(image, "jpg", os);
        }
        catch (IOException e)
        {
            return AjaxResult.error(e.getMessage());
        }

        ajax.put("uuid", uuid);
        ajax.put("img", Base64.encode(os.toByteArray()));
        return ajax;
    }

    /**
     * 清理过期的验证码
     */
    private void cleanExpiredCaptcha() {
        long currentTime = System.currentTimeMillis();
        captchaCache.entrySet().removeIf(entry -> 
            currentTime > entry.getValue().expireTime
        );
    }

    /**
     * 验证码数据
     */
    private static class CaptchaData {
        String code;
        long expireTime;

        CaptchaData(String code, long expireTime) {
            this.code = code;
            this.expireTime = expireTime;
        }
    }
}
