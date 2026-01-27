package com.SDR_System.diet.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * AI识别服务接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IAiRecognitionService {

    /**
     * 识别食物图片
     * 
     * @param imageFile 图片文件
     * @param userId 用户ID
     * @return 识别结果
     */
    AiRecognitionResult recognizeFood(MultipartFile imageFile, Long userId);

    /**
     * 根据图片URL识别食物
     * 
     * @param imageUrl 图片URL
     * @param userId 用户ID
     * @return 识别结果
     */
    AiRecognitionResult recognizeFoodByUrl(String imageUrl, Long userId);

    /**
     * AI识别结果
     */
    class AiRecognitionResult {
        /** 识别是否成功 */
        private boolean success;
        
        /** 错误信息 */
        private String errorMessage;
        
        /** 识别结果列表 */
        private java.util.List<RecognizedFood> recognizedFoods;
        
        /** 置信度分数 */
        private Double confidenceScore;
        
        /** 处理时间(毫秒) */
        private Long processingTime;
        
        /** AI模型版本 */
        private String modelVersion;

        // Getters and Setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }

        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

        public java.util.List<RecognizedFood> getRecognizedFoods() { return recognizedFoods; }
        public void setRecognizedFoods(java.util.List<RecognizedFood> recognizedFoods) { this.recognizedFoods = recognizedFoods; }

        public Double getConfidenceScore() { return confidenceScore; }
        public void setConfidenceScore(Double confidenceScore) { this.confidenceScore = confidenceScore; }

        public Long getProcessingTime() { return processingTime; }
        public void setProcessingTime(Long processingTime) { this.processingTime = processingTime; }

        public String getModelVersion() { return modelVersion; }
        public void setModelVersion(String modelVersion) { this.modelVersion = modelVersion; }
    }

    /**
     * 识别出的食物信息
     */
    class RecognizedFood {
        /** 食物名称 */
        private String foodName;
        
        /** 食物ID(如果在数据库中找到) */
        private Long foodId;
        
        /** 置信度 */
        private Double confidence;
        
        /** 估计重量(克) */
        private Double estimatedWeight;
        
        /** 边界框坐标 */
        private BoundingBox boundingBox;

        // Getters and Setters
        public String getFoodName() { return foodName; }
        public void setFoodName(String foodName) { this.foodName = foodName; }

        public Long getFoodId() { return foodId; }
        public void setFoodId(Long foodId) { this.foodId = foodId; }

        public Double getConfidence() { return confidence; }
        public void setConfidence(Double confidence) { this.confidence = confidence; }

        public Double getEstimatedWeight() { return estimatedWeight; }
        public void setEstimatedWeight(Double estimatedWeight) { this.estimatedWeight = estimatedWeight; }

        public BoundingBox getBoundingBox() { return boundingBox; }
        public void setBoundingBox(BoundingBox boundingBox) { this.boundingBox = boundingBox; }
    }

    /**
     * 边界框坐标
     */
    class BoundingBox {
        private Integer x;
        private Integer y;
        private Integer width;
        private Integer height;

        // Getters and Setters
        public Integer getX() { return x; }
        public void setX(Integer x) { this.x = x; }

        public Integer getY() { return y; }
        public void setY(Integer y) { this.y = y; }

        public Integer getWidth() { return width; }
        public void setWidth(Integer width) { this.width = width; }

        public Integer getHeight() { return height; }
        public void setHeight(Integer height) { this.height = height; }
    }
}
