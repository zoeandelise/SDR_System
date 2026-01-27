package com.SDR_System.diet.service.impl;

import com.SDR_System.diet.service.IAiRecognitionService;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * AI识别服务实现类
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
@ConditionalOnProperty(name = "diet.ai.mock.enabled", havingValue = "false")
public class AiRecognitionServiceImpl implements IAiRecognitionService {

    private static final Logger log = LoggerFactory.getLogger(AiRecognitionServiceImpl.class);

    @Value("${diet.ai.recognition-url}")
    private String aiRecognitionUrl;

    @Value("${diet.ai.connect-timeout:5000}")
    private int connectTimeout;

    @Value("${diet.ai.read-timeout:30000}")
    private int readTimeout;

    @Value("${diet.ai.max-retry:3}")
    private int maxRetry;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public AiRecognitionResult recognizeFood(MultipartFile imageFile, Long userId) {
        AiRecognitionResult result = new AiRecognitionResult();
        long startTime = System.currentTimeMillis();

        try {
            // 验证文件
            if (imageFile == null || imageFile.isEmpty()) {
                result.setSuccess(false);
                result.setErrorMessage("图片文件不能为空");
                return result;
            }

            // 调用AI服务
            String response = callAiService(imageFile);
            
            // 解析响应
            parseAiResponse(response, result);
            
            result.setProcessingTime(System.currentTimeMillis() - startTime);
            
            log.info("AI食物识别完成，用户ID：{}，处理时间：{}ms", userId, result.getProcessingTime());
            
        } catch (Exception e) {
            log.error("AI食物识别失败，用户ID：{}", userId, e);
            result.setSuccess(false);
            result.setErrorMessage("AI识别服务调用失败：" + e.getMessage());
        }

        return result;
    }

    @Override
    public AiRecognitionResult recognizeFoodByUrl(String imageUrl, Long userId) {
        AiRecognitionResult result = new AiRecognitionResult();
        long startTime = System.currentTimeMillis();

        try {
            // 验证URL
            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                result.setSuccess(false);
                result.setErrorMessage("图片URL不能为空");
                return result;
            }

            // 调用AI服务
            String response = callAiServiceByUrl(imageUrl);
            
            // 解析响应
            parseAiResponse(response, result);
            
            result.setProcessingTime(System.currentTimeMillis() - startTime);
            
            log.info("AI食物识别完成（URL方式），用户ID：{}，处理时间：{}ms", userId, result.getProcessingTime());
            
        } catch (Exception e) {
            log.error("AI食物识别失败（URL方式），用户ID：{}", userId, e);
            result.setSuccess(false);
            result.setErrorMessage("AI识别服务调用失败：" + e.getMessage());
        }

        return result;
    }

    /**
     * 调用AI服务（文件上传方式）
     */
    private String callAiService(MultipartFile imageFile) throws IOException {
        // 构建multipart请求
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("image", new ByteArrayResource(imageFile.getBytes()) {
            @Override
            public String getFilename() {
                return imageFile.getOriginalFilename();
            }
        });

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

        // 执行请求
        ResponseEntity<String> response = restTemplate.postForEntity(aiRecognitionUrl, requestEntity, String.class);
        return response.getBody();
    }

    /**
     * 调用AI服务（URL方式）
     */
    private String callAiServiceByUrl(String imageUrl) throws IOException {
        // 构建JSON请求体
        JSONObject requestBody = new JSONObject();
        requestBody.put("image_url", imageUrl);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<String> requestEntity = new HttpEntity<>(requestBody.toString(), headers);

        // 执行请求
        ResponseEntity<String> response = restTemplate.postForEntity(aiRecognitionUrl, requestEntity, String.class);
        return response.getBody();
    }

    /**
     * 解析AI服务响应
     */
    private void parseAiResponse(String response, AiRecognitionResult result) {
        try {
            JSONObject jsonResponse = JSON.parseObject(response);
            
            // 检查响应状态
            boolean success = jsonResponse.getBooleanValue("success");
            result.setSuccess(success);
            
            if (!success) {
                result.setErrorMessage(jsonResponse.getString("error_message"));
                return;
            }
            
            // 解析识别结果
            JSONObject data = jsonResponse.getJSONObject("data");
            if (data != null) {
                result.setConfidenceScore(data.getDouble("confidence_score"));
                result.setModelVersion(data.getString("model_version"));
                
                // 解析识别的食物列表
                JSONArray recognizedFoods = data.getJSONArray("recognized_foods");
                if (recognizedFoods != null) {
                    List<RecognizedFood> foodList = new ArrayList<>();
                    
                    for (int i = 0; i < recognizedFoods.size(); i++) {
                        JSONObject foodJson = recognizedFoods.getJSONObject(i);
                        RecognizedFood food = parseRecognizedFood(foodJson);
                        foodList.add(food);
                    }
                    
                    result.setRecognizedFoods(foodList);
                }
            }
            
        } catch (Exception e) {
            log.error("解析AI服务响应失败", e);
            result.setSuccess(false);
            result.setErrorMessage("解析AI服务响应失败：" + e.getMessage());
        }
    }

    /**
     * 解析识别的食物信息
     */
    private RecognizedFood parseRecognizedFood(JSONObject foodJson) {
        RecognizedFood food = new RecognizedFood();
        
        food.setFoodName(foodJson.getString("food_name"));
        food.setFoodId(foodJson.getLong("food_id"));
        food.setConfidence(foodJson.getDouble("confidence"));
        food.setEstimatedWeight(foodJson.getDouble("estimated_weight"));
        
        // 解析边界框
        JSONObject bboxJson = foodJson.getJSONObject("bounding_box");
        if (bboxJson != null) {
            BoundingBox bbox = new BoundingBox();
            bbox.setX(bboxJson.getInteger("x"));
            bbox.setY(bboxJson.getInteger("y"));
            bbox.setWidth(bboxJson.getInteger("width"));
            bbox.setHeight(bboxJson.getInteger("height"));
            food.setBoundingBox(bbox);
        }
        
        return food;
    }
}
