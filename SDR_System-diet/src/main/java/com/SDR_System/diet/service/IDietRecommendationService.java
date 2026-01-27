package com.SDR_System.diet.service;

import com.SDR_System.diet.domain.DietRecommendation;
import com.SDR_System.system.domain.DietFoodInfo;
import com.SDR_System.system.domain.SysUserHealth;

import java.util.Date;
import java.util.List;

/**
 * 饮食推荐服务接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IDietRecommendationService {

    /**
     * 查询饮食推荐
     * 
     * @param recommendationId 饮食推荐主键
     * @return 饮食推荐
     */
    public DietRecommendation selectDietRecommendationByRecommendationId(Long recommendationId);

    /**
     * 查询饮食推荐列表
     * 
     * @param dietRecommendation 饮食推荐
     * @return 饮食推荐集合
     */
    public List<DietRecommendation> selectDietRecommendationList(DietRecommendation dietRecommendation);

    /**
     * 新增饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    public int insertDietRecommendation(DietRecommendation dietRecommendation);

    /**
     * 修改饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    public int updateDietRecommendation(DietRecommendation dietRecommendation);

    /**
     * 批量删除饮食推荐
     * 
     * @param recommendationIds 需要删除的饮食推荐主键集合
     * @return 结果
     */
    public int deleteDietRecommendationByRecommendationIds(Long[] recommendationIds);

    /**
     * 删除饮食推荐信息
     * 
     * @param recommendationId 饮食推荐主键
     * @return 结果
     */
    public int deleteDietRecommendationByRecommendationId(Long recommendationId);

    /**
     * 智能生成推荐方案
     * 
     * @param dietRecommendation 推荐方案参数
     * @return 生成的推荐方案
     */
    public DietRecommendation generateRecommendation(DietRecommendation dietRecommendation);

    /**
     * 应用推荐方案
     * 
     * @param recommendationId 推荐方案ID
     * @return 结果
     */
    public int applyRecommendation(Long recommendationId);

    /**
     * 获取每日推荐
     * 
     * @param userId 用户ID
     * @param date 日期
     * @return 推荐方案
     */
    public DietRecommendation getDailyRecommendation(Long userId, Date date);

    /**
     * 生成每日推荐
     * 
     * @param userId 用户ID
     * @param date 日期
     * @return 推荐方案
     */
    public DietRecommendation generateDailyRecommendation(Long userId, Date date);

    /**
     * 为用户生成每日饮食推荐（详细结果）
     * 
     * @param userId 用户ID
     * @param date 推荐日期
     * @return 推荐结果
     */
    DailyRecommendationResult generateDetailedDailyRecommendation(Long userId, Date date);

    /**
     * 为用户生成单餐推荐
     * 
     * @param userId 用户ID
     * @param mealType 餐次类型(0早餐 1午餐 2晚餐 3加餐)
     * @param targetCalories 目标热量
     * @return 推荐结果
     */
    MealRecommendationResult generateMealRecommendation(Long userId, String mealType, Double targetCalories);

    /**
     * 基于用户历史数据的个性化推荐
     * 
     * @param userId 用户ID
     * @param mealType 餐次类型
     * @return 推荐结果
     */
    MealRecommendationResult generatePersonalizedRecommendation(Long userId, String mealType);

    /**
     * 基于健康目标的推荐
     * 
     * @param userHealth 用户健康信息
     * @param mealType 餐次类型
     * @param targetCalories 目标热量
     * @return 推荐结果
     */
    MealRecommendationResult generateHealthGoalBasedRecommendation(SysUserHealth userHealth, String mealType, Double targetCalories);

    /**
     * 每日推荐结果
     */
    class DailyRecommendationResult {
        /** 推荐是否成功 */
        private boolean success;
        
        /** 错误信息 */
        private String errorMessage;
        
        /** 用户ID */
        private Long userId;
        
        /** 推荐日期 */
        private Date recommendationDate;
        
        /** 早餐推荐 */
        private MealRecommendationResult breakfast;
        
        /** 午餐推荐 */
        private MealRecommendationResult lunch;
        
        /** 晚餐推荐 */
        private MealRecommendationResult dinner;
        
        /** 加餐推荐 */
        private List<MealRecommendationResult> snacks;
        
        /** 每日营养目标 */
        private DailyNutritionTarget nutritionTarget;
        
        /** 推荐算法类型 */
        private String algorithmType;

        // Getters and Setters
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }

        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }

        public Date getRecommendationDate() { return recommendationDate; }
        public void setRecommendationDate(Date recommendationDate) { this.recommendationDate = recommendationDate; }

        public MealRecommendationResult getBreakfast() { return breakfast; }
        public void setBreakfast(MealRecommendationResult breakfast) { this.breakfast = breakfast; }

        public MealRecommendationResult getLunch() { return lunch; }
        public void setLunch(MealRecommendationResult lunch) { this.lunch = lunch; }

        public MealRecommendationResult getDinner() { return dinner; }
        public void setDinner(MealRecommendationResult dinner) { this.dinner = dinner; }

        public List<MealRecommendationResult> getSnacks() { return snacks; }
        public void setSnacks(List<MealRecommendationResult> snacks) { this.snacks = snacks; }

        public DailyNutritionTarget getNutritionTarget() { return nutritionTarget; }
        public void setNutritionTarget(DailyNutritionTarget nutritionTarget) { this.nutritionTarget = nutritionTarget; }

        public String getAlgorithmType() { return algorithmType; }
        public void setAlgorithmType(String algorithmType) { this.algorithmType = algorithmType; }
    }

    /**
     * 单餐推荐结果
     */
    class MealRecommendationResult {
        /** 餐次类型 */
        private String mealType;
        
        /** 推荐食物列表 */
        private List<RecommendedFood> recommendedFoods;
        
        /** 目标热量 */
        private Double targetCalories;
        
        /** 实际热量 */
        private Double actualCalories;
        
        /** 营养信息 */
        private MealNutritionInfo nutritionInfo;
        
        /** 推荐理由 */
        private String recommendationReason;
        
        /** 推荐评分 */
        private Double score;
        
        /** 是否成功 */
        private boolean success;
        
        /** 置信度分数 */
        private double confidenceScore;
        
        /** 算法类型 */
        private String algorithmType;

        // Getters and Setters
        public String getMealType() { return mealType; }
        public void setMealType(String mealType) { this.mealType = mealType; }

        public List<RecommendedFood> getRecommendedFoods() { return recommendedFoods; }
        public void setRecommendedFoods(List<RecommendedFood> recommendedFoods) { this.recommendedFoods = recommendedFoods; }

        public Double getTargetCalories() { return targetCalories; }
        public void setTargetCalories(Double targetCalories) { this.targetCalories = targetCalories; }

        public Double getActualCalories() { return actualCalories; }
        public void setActualCalories(Double actualCalories) { this.actualCalories = actualCalories; }

        public MealNutritionInfo getNutritionInfo() { return nutritionInfo; }
        public void setNutritionInfo(MealNutritionInfo nutritionInfo) { this.nutritionInfo = nutritionInfo; }

        public String getRecommendationReason() { return recommendationReason; }
        public void setRecommendationReason(String recommendationReason) { this.recommendationReason = recommendationReason; }

        public Double getScore() { return score; }
        public void setScore(Double score) { this.score = score; }
        
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public double getConfidenceScore() { return confidenceScore; }
        public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }
        
        public String getAlgorithmType() { return algorithmType; }
        public void setAlgorithmType(String algorithmType) { this.algorithmType = algorithmType; }
    }

    /**
     * 推荐食物
     */
    class RecommendedFood {
        /** 食物信息 */
        private DietFoodInfo foodInfo;
        
        /** 食物ID */
        private Long foodId;
        
        /** 食物名称 */
        private String foodName;
        
        /** 推荐重量(克) */
        private Double recommendedWeight;
        
        /** 推荐数量/份量 */
        private Double quantity;
        
        /** 推荐理由 */
        private String reason;
        
        /** 适合度评分 */
        private Double suitabilityScore;
        
        /** 推荐评分 */
        private Double score;

        // Getters and Setters
        public DietFoodInfo getFoodInfo() { return foodInfo; }
        public void setFoodInfo(DietFoodInfo foodInfo) { this.foodInfo = foodInfo; }
        
        public Long getFoodId() { return foodId; }
        public void setFoodId(Long foodId) { this.foodId = foodId; }
        
        public String getFoodName() { return foodName; }
        public void setFoodName(String foodName) { this.foodName = foodName; }

        public Double getRecommendedWeight() { return recommendedWeight; }
        public void setRecommendedWeight(Double recommendedWeight) { this.recommendedWeight = recommendedWeight; }
        
        public Double getQuantity() { return quantity; }
        public void setQuantity(Double quantity) { this.quantity = quantity; }

        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }

        public Double getSuitabilityScore() { return suitabilityScore; }
        public void setSuitabilityScore(Double suitabilityScore) { this.suitabilityScore = suitabilityScore; }
        
        public Double getScore() { return score; }
        public void setScore(Double score) { this.score = score; }
    }

    /**
     * 每日营养目标
     */
    class DailyNutritionTarget {
        private Double targetCalories;
        private Double targetProtein;
        private Double targetFat;
        private Double targetCarbohydrate;
        private Double targetFiber;

        // Getters and Setters
        public Double getTargetCalories() { return targetCalories; }
        public void setTargetCalories(Double targetCalories) { this.targetCalories = targetCalories; }

        public Double getTargetProtein() { return targetProtein; }
        public void setTargetProtein(Double targetProtein) { this.targetProtein = targetProtein; }

        public Double getTargetFat() { return targetFat; }
        public void setTargetFat(Double targetFat) { this.targetFat = targetFat; }

        public Double getTargetCarbohydrate() { return targetCarbohydrate; }
        public void setTargetCarbohydrate(Double targetCarbohydrate) { this.targetCarbohydrate = targetCarbohydrate; }

        public Double getTargetFiber() { return targetFiber; }
        public void setTargetFiber(Double targetFiber) { this.targetFiber = targetFiber; }
    }

    /**
     * 单餐营养信息
     */
    class MealNutritionInfo {
        private Double calories;
        private Double protein;
        private Double fat;
        private Double carbohydrate;
        private Double fiber;
        private Double sugar;
        private Double sodium;

        // Getters and Setters
        public Double getCalories() { return calories; }
        public void setCalories(Double calories) { this.calories = calories; }

        public Double getProtein() { return protein; }
        public void setProtein(Double protein) { this.protein = protein; }

        public Double getFat() { return fat; }
        public void setFat(Double fat) { this.fat = fat; }

        public Double getCarbohydrate() { return carbohydrate; }
        public void setCarbohydrate(Double carbohydrate) { this.carbohydrate = carbohydrate; }

        public Double getFiber() { return fiber; }
        public void setFiber(Double fiber) { this.fiber = fiber; }

        public Double getSugar() { return sugar; }
        public void setSugar(Double sugar) { this.sugar = sugar; }

        public Double getSodium() { return sodium; }
        public void setSodium(Double sodium) { this.sodium = sodium; }
    }
}
