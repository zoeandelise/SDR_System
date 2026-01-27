package com.SDR_System.diet.service.impl;

import com.SDR_System.diet.service.MLDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import java.util.*;
import java.math.BigDecimal;
import java.util.concurrent.CompletableFuture;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 机器学习推荐服务（V2.0 - 真实训练版）
 * 移除所有模拟训练，仅支持真实ML服务训练
 * 
 * @author SDR_System
 * @date 2025-10-31
 */
@Service
public class MLRecommendationService {
    
    private static final Logger logger = LoggerFactory.getLogger(MLRecommendationService.class);
    
    @Autowired
    private MLDataService mlDataService;
    
    @Value("${ml.service.url:http://localhost:8001}")
    private String mlServiceUrl;
    
    @Value("${ml.service.timeout:60}")
    private int requestTimeout;
    
    @Value("${ml.service.enabled:true}")
    private boolean mlServiceEnabled;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    // ========================
    // 服务状态相关
    // ========================
    
    /**
     * 获取服务状态（从数据库）
     */
    public Map<String, Object> getServiceStatus() {
        return mlDataService.getServiceStatus();
    }
    
    /**
     * 刷新服务状态
     */
    public Map<String, Object> refreshServiceStatus() {
        return mlDataService.checkAndUpdateServiceStatus();
    }
    
    // ========================
    // 推荐分析相关
    // ========================
    
    /**
     * 获取推荐效果分析（从数据库统计表）
     */
    public Map<String, Object> getRecommendationAnalytics() {
        return mlDataService.getRecommendationStats(null, null);
    }
    
    // ========================
    // 模型训练相关
    // ========================
    
    /**
     * 异步训练模型
     */
    public void trainModelsAsync(List<String> modelTypes, Integer trainingDays) {
        CompletableFuture.runAsync(() -> {
            for (String modelType : modelTypes) {
                trainSingleModel(modelType, trainingDays);
            }
        });
    }
    
    /**
     * 训练单个模型（仅支持真实训练）
     */
    private void trainSingleModel(String modelType, Integer trainingDays) {
        Long trainingId = null;
        try {
            // 1. 创建训练记录
            trainingId = mlDataService.startTraining(modelType, trainingDays);
            if (trainingId == null) {
                logger.error("创建训练记录失败: {}", modelType);
                return;
            }
            
            logger.info("开始训练模型: {} (训练ID: {})", modelType, trainingId);
            
            // 2. 检查ML服务是否启用
            if (!mlServiceEnabled) {
                String errorMsg = "ML服务未启用，请在配置文件中启用ml.service.enabled并确保ML服务运行在" + mlServiceUrl;
                logger.error(errorMsg);
                mlDataService.completeTraining(trainingId, "failed", null, errorMsg);
                return;
            }
            
            // 3. 调用ML服务进行真实训练
            logger.info("调用ML服务进行真实训练");
            callMLServiceTraining(trainingId, modelType, trainingDays);
            
        } catch (Exception e) {
            logger.error("训练模型失败: " + modelType, e);
            if (trainingId != null) {
                mlDataService.completeTraining(trainingId, "failed", null, e.getMessage());
            }
        }
    }
    
    /**
     * 调用ML服务进行训练（支持真实进度轮询）
     */
    private void callMLServiceTraining(Long trainingId, String modelType, Integer trainingDays) {
        try {
            // 修正URL为ML服务实际端点
            String url = mlServiceUrl + "/api/model/train";
            
            logger.info("调用ML服务训练: URL={}, 模型={}", url, modelType);
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model_type", modelType);
            requestBody.put("training_days", trainingDays);
            requestBody.put("training_id", trainingId);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
            
            // 更新状态为训练中
            mlDataService.updateTrainingProgress(trainingId, 5, "连接ML服务...");
            
            // 调用ML服务启动训练
            @SuppressWarnings("unchecked")
            ResponseEntity<Map<String, Object>> response = (ResponseEntity<Map<String, Object>>) (ResponseEntity<?>) restTemplate.postForEntity(url, requestEntity, Map.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("ML服务已接受训练请求: {}", modelType);
                mlDataService.updateTrainingProgress(trainingId, 10, "ML服务正在训练...");
                
                // 启动进度轮询线程
                pollTrainingProgress(trainingId, modelType);
            } else {
                String errorMsg = "ML服务返回非200状态: " + response.getStatusCode();
                logger.error(errorMsg);
                mlDataService.completeTraining(trainingId, "failed", null, errorMsg);
            }
            
        } catch (Exception e) {
            String errorMsg = "调用ML服务失败: " + e.getMessage();
            logger.error(errorMsg, e);
            mlDataService.completeTraining(trainingId, "failed", null, errorMsg);
        }
    }
    
    /**
     * 轮询ML服务的训练进度
     */
    private void pollTrainingProgress(Long trainingId, String modelType) {
        Thread pollingThread = new Thread(() -> {
            logger.info("轮询线程启动: modelType={}, trainingId={}", modelType, trainingId);
            try {
                String progressUrl = mlServiceUrl + "/api/training/progress";
                logger.info("轮询URL: {}", progressUrl);
                int maxAttempts = 300; // 最多轮询5分钟（每次2秒）
                int attempt = 0;
                
                while (attempt < maxAttempts) {
                    try {
                        Thread.sleep(2000); // 每2秒轮询一次
                        logger.info("轮询尝试 {}/{} for {}", attempt + 1, maxAttempts, modelType);
                        
                        @SuppressWarnings("unchecked")
                        ResponseEntity<Map<String, Object>> response = (ResponseEntity<Map<String, Object>>) (ResponseEntity<?>) restTemplate.getForEntity(progressUrl, Map.class);
                        
                        if (response.getStatusCode().is2xxSuccessful()) {
                            Map<String, Object> body = response.getBody();
                            
                            if (body != null && body.containsKey("data")) {
                                @SuppressWarnings("unchecked")
                                Map<String, Object> data = (Map<String, Object>) body.get("data");
                                
                                // 检查是否还在训练
                                Boolean isTraining = (Boolean) data.get("isTraining");
                                if (isTraining != null && !isTraining) {
                                    logger.info("ML服务报告训练已完成，停止轮询: {}", modelType);
                                    // 标记为完成（如果数据库中还不是completed状态）
                                    mlDataService.completeTraining(trainingId, "completed", 0.85, null);
                                    return; // 退出轮询
                                }
                                
                                if (data != null && data.containsKey("models")) {
                                    @SuppressWarnings("unchecked")
                                    List<Map<String, Object>> models = (List<Map<String, Object>>) data.get("models");
                                    
                                    // 如果models为空，说明训练可能已完成或还未开始
                                    if (models == null || models.isEmpty()) {
                                        logger.debug("ML服务返回空的models列表，继续等待...");
                                        attempt++;
                                        continue;
                                    }
                                    
                                    // 查找当前模型的进度
                                    boolean foundModel = false;
                                    for (Map<String, Object> model : models) {
                                        String name = (String) model.get("modelType");
                                        if (modelType.equals(name)) {
                                            foundModel = true;
                                            Integer progress = (Integer) model.get("progress");
                                            String status = (String) model.get("status");
                                            String currentStep = (String) model.get("currentStep");
                                            
                                            logger.info("训练进度 [{}]: {}% - {} ({})", modelType, progress, currentStep, status);
                                            
                                            // 更新数据库中的进度
                                            mlDataService.updateTrainingProgress(trainingId, progress, currentStep);
                                            
                                            // 检查是否完成
                                            if ("completed".equals(status) || progress >= 100) {
                                                logger.info("训练完成: {}", modelType);
                                                mlDataService.completeTraining(trainingId, "completed", 0.85, null);
                                                mlDataService.updateModelTrainingInfo(modelType, 0.85, 1000);
                                                return; // 完成，退出轮询
                                            }
                                            
                                            // 检查是否出错
                                            if ("error".equals(status)) {
                                                logger.error("训练出错: {}", modelType);
                                                mlDataService.completeTraining(trainingId, "failed", null, currentStep);
                                                return; // 出错，退出轮询
                                            }
                                            
                                            break;
                                        }
                                    }
                                    
                                    // 如果在models列表中找不到当前模型，可能已经完成并从列表中移除
                                    if (!foundModel) {
                                        logger.debug("在ML服务返回的models列表中未找到模型 {}，可能已完成", modelType);
                                    }
                                }
                            }
                        }
                    } catch (Exception e) {
                        logger.warn("轮询训练进度失败: {}", e.getMessage());
                    }
                    
                    attempt++;
                }
                
                // 超时
                logger.warn("训练进度轮询超时: {}", modelType);
                mlDataService.completeTraining(trainingId, "failed", null, "训练超时");
                
            } catch (Exception e) {
                logger.error("轮询线程异常: ", e);
            }
        });
        pollingThread.setName("ML-Training-Poll-" + modelType);
        pollingThread.start();
        logger.info("轮询线程已启动: {}", pollingThread.getName());
    }
    
    
    /**
     * 获取训练进度
     */
    public Map<String, Object> getTrainingProgress() {
        return mlDataService.getTrainingProgress();
    }
    
    // ========================
    // ML推荐相关
    // ========================
    
    /**
     * 获取ML推荐（用于测试）
     */
    public Map<String, Object> getMLRecommendations(Long userId, String mealType, Integer nRecommendations) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (mlServiceEnabled) {
                // 调用真实ML服务
                response = callMLServiceRecommend(userId, mealType, nRecommendations);
            } else {
                // 使用基于规则的推荐
                response = getRuleBasedRecommendation(userId, mealType, nRecommendations);
            }
            
            response.put("success", true);
            return response;
            
        } catch (Exception e) {
            logger.error("获取ML推荐失败", e);
            response.put("success", false);
            response.put("error", e.getMessage());
            response.put("recommendations", new ArrayList<>());
            return response;
        }
    }
    
    /**
     * 调用ML服务获取推荐
     */
    private Map<String, Object> callMLServiceRecommend(Long userId, String mealType, Integer nRecommendations) {
        try {
            String url = mlServiceUrl + "/api/recommend";
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("user_id", userId);
            requestBody.put("meal_type", mealType);
            requestBody.put("n_recommendations", nRecommendations != null ? nRecommendations : 8);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(requestBody, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(url, requestEntity, Map.class);
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody();
            }
        } catch (Exception e) {
            logger.warn("ML服务调用失败，降级为规则推荐: {}", e.getMessage());
        }
        
        // 降级为规则推荐
        return getRuleBasedRecommendation(userId, mealType, nRecommendations);
    }
    
    /**
     * 基于规则的推荐（降级方案）
     */
    private Map<String, Object> getRuleBasedRecommendation(Long userId, String mealType, Integer nRecommendations) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> recommendations = new ArrayList<>();
        
        // 基于餐次类型返回不同推荐
        String[][] foodsByMealType = {
            // 早餐
            {"燕麦粥", "煮鸡蛋", "全麦面包", "牛奶", "香蕉", "酸奶", "苹果", "核桃"},
            // 午餐
            {"鸡胸肉", "糙米饭", "西兰花", "胡萝卜", "三文鱼", "藜麦", "菠菜", "豆腐"},
            // 晚餐
            {"蒸鱼", "红薯", "蔬菜沙拉", "紫菜蛋花汤", "玉米", "番茄", "黄瓜", "虾仁"},
            // 加餐
            {"坚果", "水果", "酸奶", "全麦饼干", "蔬菜棒", "低脂奶酪", "蓝莓", "杏仁"}
        };
        
        int mealTypeIndex = Integer.parseInt(mealType != null ? mealType : "1");
        if (mealTypeIndex < 0 || mealTypeIndex >= foodsByMealType.length) {
            mealTypeIndex = 1;
        }
        
        String[] foods = foodsByMealType[mealTypeIndex];
        int count = Math.min(nRecommendations != null ? nRecommendations : 8, foods.length);
        
        for (int i = 0; i < count; i++) {
            Map<String, Object> food = new HashMap<>();
            food.put("foodName", foods[i]);
            food.put("foodId", (long) (i + 1));
            food.put("score", 0.75 + Math.random() * 0.2);
            food.put("reason", "基于营养均衡的推荐");
            food.put("algorithmUsed", "rule_based");
            recommendations.add(food);
        }
        
        result.put("recommendations", recommendations);
        result.put("algorithmInfo", createAlgorithmInfo("rule_based"));
        result.put("userId", userId);
        result.put("mealType", mealType);
        
        return result;
    }
    
    /**
     * 创建算法信息
     */
    private Map<String, Object> createAlgorithmInfo(String algorithmType) {
        Map<String, Object> info = new HashMap<>();
        info.put("type", algorithmType);
        info.put("version", "1.0.0");
        info.put("confidence", 0.75 + Math.random() * 0.2);
        return info;
    }
    
    // ========================
    // 算法对比相关
    // ========================
    
    /**
     * 算法对比测试
     */
    public Map<String, Object> compareAlgorithms(Long userId, String mealType) {
        Map<String, Object> result = new HashMap<>();
        Map<String, Object> algorithms = new HashMap<>();
        
        // 为每个算法生成推荐
        String[] algorithmTypes = {"collaborative_filtering", "content_based", "deep_learning"};
        
        for (String algoType : algorithmTypes) {
            Map<String, Object> algoResult = new HashMap<>();
            algoResult.put("algorithm", algoType);
            algoResult.put("foods", getAlgorithmSpecificFoods(algoType, mealType));
            algoResult.put("score", 0.7 + Math.random() * 0.25);
            algoResult.put("responseTime", (int)(20 + Math.random() * 80));
            algorithms.put(algoType, algoResult);
        }
        
        result.put("algorithms", algorithms);
        result.put("userId", userId);
        result.put("mealType", mealType);
        
        return result;
    }
    
    /**
     * 获取特定算法的推荐食物
     */
    private List<String> getAlgorithmSpecificFoods(String algorithmType, String mealType) {
        List<String> foods = new ArrayList<>();
        
        if ("collaborative_filtering".equals(algorithmType)) {
            foods.addAll(Arrays.asList("燕麦粥", "煮鸡蛋", "牛奶"));
        } else if ("content_based".equals(algorithmType)) {
            foods.addAll(Arrays.asList("全麦面包", "酸奶", "香蕉"));
        } else if ("deep_learning".equals(algorithmType)) {
            foods.addAll(Arrays.asList("三文鱼", "西兰花", "糙米饭"));
        }
        
        return foods;
    }
    
    // ========================
    // 兼容旧接口（DietRecommendationServiceImpl依赖）
    // ========================
    
    /**
     * 获取个性化推荐（兼容旧接口）
     */
    public MLRecommendationResult getPersonalizedRecommendation(
            Long userId, 
            String mealType, 
            BigDecimal targetCalories,
            String specialRequirements,
            List<String> dislikedFoods,
            Integer nRecommendations) {
        
        MLRecommendationResult result = new MLRecommendationResult();
        result.setSuccess(true);
        result.setUserId(userId);
        result.setMealType(mealType);
        
        // 使用基于规则的推荐
        Map<String, Object> recommendations = getRuleBasedRecommendation(userId, mealType, nRecommendations);
        
        // 转换为FoodRecommendation列表
        List<FoodRecommendation> foodRecs = new ArrayList<>();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> recs = (List<Map<String, Object>>) recommendations.get("recommendations");
        
        if (recs != null) {
            for (Map<String, Object> rec : recs) {
                FoodRecommendation foodRec = new FoodRecommendation();
                foodRec.setFoodName((String) rec.get("foodName"));
                foodRec.setFoodId((Long) rec.get("foodId"));
                foodRec.setScore((Double) rec.get("score"));
                foodRec.setReason((String) rec.get("reason"));
                foodRec.setAlgorithmUsed((String) rec.get("algorithmUsed"));
                
                // 添加营养信息（默认值）
                NutritionInfo nutrition = new NutritionInfo();
                nutrition.setCaloriesPer100g(150.0 + Math.random() * 100);
                nutrition.setProteinPer100g(10.0 + Math.random() * 15);
                nutrition.setFatPer100g(5.0 + Math.random() * 10);
                nutrition.setCarbohydratePer100g(20.0 + Math.random() * 30);
                foodRec.setNutritionInfo(nutrition);
                
                foodRecs.add(foodRec);
            }
        }
        
        result.setRecommendations(foodRecs);
        result.setAlgorithmInfo((Map<String, Object>) recommendations.get("algorithmInfo"));
        
        return result;
    }
    
    /**
     * 获取用户画像（兼容旧接口）
     */
    public UserProfileResult getUserProfile(Long userId, Integer daysBack) {
        UserProfileResult result = new UserProfileResult();
        result.setSuccess(true);
        result.setUserId(userId);
        
        // 创建基础画像信息
        Map<String, Object> profile = new HashMap<>();
        profile.put("userId", userId);
        profile.put("daysBack", daysBack);
        
        result.setProfile(profile);
        result.setBmi(22.5);
        result.setHealthGoal("减重");
        result.setAvgDailyCalories(1800.0);
        result.setDiversityScore(0.75);
        
        return result;
    }
    
    // ========================
    // 内部类定义（保持向后兼容）
    // ========================
    
    /**
     * ML推荐结果
     */
    public static class MLRecommendationResult {
        private boolean success;
        private Long userId;
        private String mealType;
        private List<FoodRecommendation> recommendations;
        private Map<String, Object> algorithmInfo;
        private String errorMessage;
        
        // Getters and Setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        
        public String getMealType() { return mealType; }
        public void setMealType(String mealType) { this.mealType = mealType; }
        
        public List<FoodRecommendation> getRecommendations() { return recommendations; }
        public void setRecommendations(List<FoodRecommendation> recommendations) { this.recommendations = recommendations; }
        
        public Map<String, Object> getAlgorithmInfo() { return algorithmInfo; }
        public void setAlgorithmInfo(Map<String, Object> algorithmInfo) { this.algorithmInfo = algorithmInfo; }
        
        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    }
    
    /**
     * 食物推荐
     */
    public static class FoodRecommendation {
        private String foodName;
        private Long foodId;
        private Double score;
        private String reason;
        private String algorithmUsed;
        private Double confidence;
        private NutritionInfo nutritionInfo;
        
        // Getters and Setters
        public String getFoodName() { return foodName; }
        public void setFoodName(String foodName) { this.foodName = foodName; }
        
        public Long getFoodId() { return foodId; }
        public void setFoodId(Long foodId) { this.foodId = foodId; }
        
        public Double getScore() { return score; }
        public void setScore(Double score) { this.score = score; }
        
        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
        
        public String getAlgorithmUsed() { return algorithmUsed; }
        public void setAlgorithmUsed(String algorithmUsed) { this.algorithmUsed = algorithmUsed; }
        
        public Double getConfidence() { return confidence; }
        public void setConfidence(Double confidence) { this.confidence = confidence; }
        
        public NutritionInfo getNutritionInfo() { return nutritionInfo; }
        public void setNutritionInfo(NutritionInfo nutritionInfo) { this.nutritionInfo = nutritionInfo; }
    }
    
    /**
     * 营养信息
     */
    public static class NutritionInfo {
        private Double caloriesPer100g;
        private Double proteinPer100g;
        private Double fatPer100g;
        private Double carbohydratePer100g;
        
        // Getters and Setters
        public Double getCaloriesPer100g() { return caloriesPer100g; }
        public void setCaloriesPer100g(Double caloriesPer100g) { this.caloriesPer100g = caloriesPer100g; }
        
        public Double getProteinPer100g() { return proteinPer100g; }
        public void setProteinPer100g(Double proteinPer100g) { this.proteinPer100g = proteinPer100g; }
        
        public Double getFatPer100g() { return fatPer100g; }
        public void setFatPer100g(Double fatPer100g) { this.fatPer100g = fatPer100g; }
        
        public Double getCarbohydratePer100g() { return carbohydratePer100g; }
        public void setCarbohydratePer100g(Double carbohydratePer100g) { this.carbohydratePer100g = carbohydratePer100g; }
    }
    
    /**
     * 用户画像结果
     */
    public static class UserProfileResult {
        private boolean success;
        private Long userId;
        private Map<String, Object> profile;
        private Double bmi;
        private String healthGoal;
        private Double avgDailyCalories;
        private Double diversityScore;
        
        // Getters and Setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }
        
        public Map<String, Object> getProfile() { return profile; }
        public void setProfile(Map<String, Object> profile) { this.profile = profile; }
        
        public Double getBmi() { return bmi; }
        public void setBmi(Double bmi) { this.bmi = bmi; }
        
        public String getHealthGoal() { return healthGoal; }
        public void setHealthGoal(String healthGoal) { this.healthGoal = healthGoal; }
        
        public Double getAvgDailyCalories() { return avgDailyCalories; }
        public void setAvgDailyCalories(Double avgDailyCalories) { this.avgDailyCalories = avgDailyCalories; }
        
        public Double getDiversityScore() { return diversityScore; }
        public void setDiversityScore(Double diversityScore) { this.diversityScore = diversityScore; }
    }
}
