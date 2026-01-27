package com.SDR_System.diet.service;

import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * 全天饮食方案生成服务
 * 
 * @author SDR_System
 */
@Service
public class DailyMealPlanService {
    
    private static final Logger logger = LoggerFactory.getLogger(DailyMealPlanService.class);
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 一键生成全天饮食方案（早午晚三餐）
     */
    public Map<String, Object> generateDailyMealPlan(Long userId) {
        Map<String, Object> plan = new HashMap<>();
        
        try {
            // 生成三餐推荐
            List<Map<String, Object>> breakfast = generateMeal(userId, "0", 3); // 早餐3种
            List<Map<String, Object>> lunch = generateMeal(userId, "1", 5);     // 午餐5种
            List<Map<String, Object>> dinner = generateMeal(userId, "2", 5);    // 晚餐5种
            
            plan.put("userId", userId);
            plan.put("userName", SecurityUtils.getUsername());
            plan.put("breakfast", breakfast);
            plan.put("lunch", lunch);
            plan.put("dinner", dinner);
            plan.put("generateTime", new Date());
            
            // 计算全天营养总计
            int totalCalories = 0;
            double totalProtein = 0;
            double totalCarb = 0;
            double totalFat = 0;
            
            for (Map<String, Object> food : breakfast) {
                totalCalories += ((Number)food.get("calories_per_100g")).intValue();
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue();
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue();
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue();
            }
            for (Map<String, Object> food : lunch) {
                totalCalories += ((Number)food.get("calories_per_100g")).intValue();
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue();
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue();
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue();
            }
            for (Map<String, Object> food : dinner) {
                totalCalories += ((Number)food.get("calories_per_100g")).intValue();
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue();
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue();
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue();
            }
            
            plan.put("totalCalories", totalCalories);
            plan.put("totalProtein", Math.round(totalProtein * 10) / 10.0);
            plan.put("totalCarb", Math.round(totalCarb * 10) / 10.0);
            plan.put("totalFat", Math.round(totalFat * 10) / 10.0);
            
            // 不自动保存，由用户确认后调用savePlan接口
            
            return plan;
            
        } catch (Exception e) {
            logger.error("生成全天方案失败", e);
            throw new RuntimeException("生成全天方案失败：" + e.getMessage());
        }
    }
    
    /**
     * 生成单餐推荐
     */
    private List<Map<String, Object>> generateMeal(Long userId, String mealType, int count) {
        String sql = "CALL generate_diverse_recommendation_simple(?, ?, ?)";
        return jdbcTemplate.queryForList(sql, userId, mealType, count);
    }
    
    /**
     * 保存用户确认的方案（由前端调用）
     */
    public void saveMealPlan(Long userId, String planJson) {
        try {
            String insertSql = "INSERT INTO diet_recommendation " +
                              "(user_id, meal_type, recommended_foods, recommendation_date, algorithm_type) " +
                              "VALUES (?, ?, ?, CURDATE(), 'ML智能推荐-全天方案')";
            
            // meal_type是char(1)，用'9'表示全天方案
            jdbcTemplate.update(insertSql, userId, "9", planJson);
            
            logger.info("全天方案已保存，用户ID: {}", userId);
            
        } catch (Exception e) {
            logger.error("保存方案失败", e);
            throw new RuntimeException("保存方案失败：" + e.getMessage());
        }
    }
}
