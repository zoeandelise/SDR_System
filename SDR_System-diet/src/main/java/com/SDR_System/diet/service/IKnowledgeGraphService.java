package com.SDR_System.diet.service;

import com.SDR_System.diet.domain.neo4j.FoodNode;
import com.SDR_System.system.domain.SysUserHealth;

import java.util.List;

/**
 * 知识图谱服务接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IKnowledgeGraphService {

    /**
     * 根据健康目标推荐食物
     * 
     * @param healthGoal 健康目标
     * @return 推荐食物列表
     */
    List<FoodNode> recommendFoodsByHealthGoal(String healthGoal);

    /**
     * 根据疾病限制过滤食物
     * 
     * @param diseases 疾病列表
     * @return 不适合的食物列表
     */
    List<FoodNode> getFoodsUnsuitableForDiseases(List<String> diseases);

    /**
     * 根据营养需求推荐食物
     * 
     * @param nutrient 营养素名称
     * @param minContent 最小含量
     * @param maxContent 最大含量
     * @return 符合条件的食物列表
     */
    List<FoodNode> recommendFoodsByNutrient(String nutrient, Double minContent, Double maxContent);

    /**
     * 获取高蛋白食物推荐
     * 
     * @param minProtein 最小蛋白质含量
     * @return 高蛋白食物列表
     */
    List<FoodNode> getHighProteinFoods(Double minProtein);

    /**
     * 获取低热量食物推荐
     * 
     * @param maxCalories 最大热量
     * @return 低热量食物列表
     */
    List<FoodNode> getLowCalorieFoods(Double maxCalories);

    /**
     * 根据用户健康信息综合推荐食物
     * 
     * @param userHealth 用户健康信息
     * @return 综合推荐结果
     */
    FoodRecommendationResult getComprehensiveRecommendation(SysUserHealth userHealth);

    /**
     * 获取食物搭配推荐
     * 
     * @param foodName 食物名称
     * @return 搭配推荐列表
     */
    List<FoodNode> getFoodPairings(String foodName);

    /**
     * 食物推荐结果
     */
    class FoodRecommendationResult {
        /** 推荐食物列表 */
        private List<RecommendedFoodWithReason> recommendedFoods;
        
        /** 不推荐食物列表 */
        private List<RecommendedFoodWithReason> notRecommendedFoods;
        
        /** 推荐理由摘要 */
        private String reasonSummary;

        // Getters and Setters
        public List<RecommendedFoodWithReason> getRecommendedFoods() { return recommendedFoods; }
        public void setRecommendedFoods(List<RecommendedFoodWithReason> recommendedFoods) { this.recommendedFoods = recommendedFoods; }

        public List<RecommendedFoodWithReason> getNotRecommendedFoods() { return notRecommendedFoods; }
        public void setNotRecommendedFoods(List<RecommendedFoodWithReason> notRecommendedFoods) { this.notRecommendedFoods = notRecommendedFoods; }

        public String getReasonSummary() { return reasonSummary; }
        public void setReasonSummary(String reasonSummary) { this.reasonSummary = reasonSummary; }
    }

    /**
     * 带推荐理由的食物
     */
    class RecommendedFoodWithReason {
        /** 食物节点 */
        private FoodNode food;
        
        /** 推荐理由 */
        private String reason;
        
        /** 适合度评分 */
        private Double suitabilityScore;

        // Getters and Setters
        public FoodNode getFood() { return food; }
        public void setFood(FoodNode food) { this.food = food; }

        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }

        public Double getSuitabilityScore() { return suitabilityScore; }
        public void setSuitabilityScore(Double suitabilityScore) { this.suitabilityScore = suitabilityScore; }
    }
}
