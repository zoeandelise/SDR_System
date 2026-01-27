package com.SDR_System.diet.service.impl;

import com.SDR_System.diet.service.IAiRecognitionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * AI识别服务Mock实现类（用于测试）
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
@ConditionalOnProperty(name = "diet.ai.mock.enabled", havingValue = "true", matchIfMissing = true)
public class MockAiRecognitionServiceImpl implements IAiRecognitionService {

    private static final Logger log = LoggerFactory.getLogger(MockAiRecognitionServiceImpl.class);
    
    private final Random random = new Random();
    
    // Mock食物数据
    private static final String[][] MOCK_FOODS = {
        {"白米饭", "1", "150"},
        {"鸡胸肉", "2", "120"},
        {"西兰花", "3", "100"},
        {"鸡蛋", "4", "50"},
        {"香蕉", "5", "120"},
        {"牛奶", "6", "250"},
        {"燕麦", "7", "50"},
        {"三文鱼", "8", "100"},
        {"菠菜", "9", "80"},
        {"苹果", "10", "150"}
    };

    @Override
    public AiRecognitionResult recognizeFood(MultipartFile imageFile, Long userId) {
        log.info("Mock AI识别服务 - 识别图片文件，用户ID：{}, 文件名：{}", userId, imageFile.getOriginalFilename());
        
        // 模拟处理时间
        try {
            Thread.sleep(1000 + random.nextInt(2000)); // 1-3秒随机延迟
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return generateMockResult();
    }

    @Override
    public AiRecognitionResult recognizeFoodByUrl(String imageUrl, Long userId) {
        log.info("Mock AI识别服务 - 识别图片URL，用户ID：{}, URL：{}", userId, imageUrl);
        
        // 模拟处理时间
        try {
            Thread.sleep(800 + random.nextInt(1500)); // 0.8-2.3秒随机延迟
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return generateMockResult();
    }

    /**
     * 生成Mock识别结果
     */
    private AiRecognitionResult generateMockResult() {
        AiRecognitionResult result = new AiRecognitionResult();
        
        try {
            // 90%成功率
            if (random.nextDouble() < 0.9) {
                result.setSuccess(true);
                result.setConfidenceScore(0.7 + random.nextDouble() * 0.3); // 0.7-1.0
                result.setProcessingTime(1000L + random.nextInt(2000)); // 1-3秒
                result.setModelVersion("MockModel-v1.0");
                
                // 随机选择1-3种食物
                int foodCount = 1 + random.nextInt(3);
                List<RecognizedFood> recognizedFoods = new ArrayList<>();
                
                for (int i = 0; i < foodCount; i++) {
                    String[] foodData = MOCK_FOODS[random.nextInt(MOCK_FOODS.length)];
                    
                    RecognizedFood food = new RecognizedFood();
                    food.setFoodName(foodData[0]);
                    food.setFoodId(Long.parseLong(foodData[1]));
                    food.setConfidence(0.6 + random.nextDouble() * 0.4); // 0.6-1.0
                    food.setEstimatedWeight(Double.parseDouble(foodData[2]) + random.nextInt(50) - 25); // ±25g随机变化
                    
                    // 生成随机边界框
                    BoundingBox bbox = new BoundingBox();
                    bbox.setX(random.nextInt(100));
                    bbox.setY(random.nextInt(100));
                    bbox.setWidth(100 + random.nextInt(200));
                    bbox.setHeight(100 + random.nextInt(200));
                    food.setBoundingBox(bbox);
                    
                    recognizedFoods.add(food);
                }
                
                result.setRecognizedFoods(recognizedFoods);
                
                log.info("Mock AI识别成功，识别出{}种食物", foodCount);
                
            } else {
                // 10%失败率
                result.setSuccess(false);
                result.setErrorMessage("Mock AI识别失败 - 图片质量不佳或无法识别食物");
                log.warn("Mock AI识别失败");
            }
            
        } catch (Exception e) {
            result.setSuccess(false);
            result.setErrorMessage("Mock AI服务内部错误：" + e.getMessage());
            log.error("Mock AI识别异常", e);
        }
        
        return result;
    }
}
