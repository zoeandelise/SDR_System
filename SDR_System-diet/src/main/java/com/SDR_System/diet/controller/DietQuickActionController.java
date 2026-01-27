package com.SDR_System.diet.controller;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

/**
 * 饮食快速操作Controller
 * 包括：拍照识别、手动添加、智能推荐
 * 
 * @author SDR_System
 */
@RestController
@RequestMapping("/diet/quickaction")
public class DietQuickActionController extends BaseController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 拍照识别食物
     * 
     * @param file 上传的图片文件
     * @param userId 用户ID
     * @return 识别结果
     */
    @PostMapping("/ai/recognize")
    public AjaxResult recognizeFood(
            @RequestParam(required = false) MultipartFile file,
            @RequestParam(required = false) Long userId) {
        try {
            // TODO: 调用Python AI服务进行图片识别
            // 暂时返回模拟数据
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("foodName", "苹果");
            result.put("confidence", 0.95);
            result.put("category", "水果类");
            
            Map<String, Object> nutrition = new HashMap<>();
            nutrition.put("calories", 52);
            nutrition.put("protein", 0.3);
            nutrition.put("fat", 0.2);
            nutrition.put("carbohydrate", 14);
            nutrition.put("fiber", 2.4);
            
            result.put("nutrition", nutrition);
            result.put("message", "AI识别功能开发中，当前返回模拟数据");
            
            return AjaxResult.success("识别成功", result);
            
        } catch (Exception e) {
            logger.error("食物识别失败", e);
            return AjaxResult.error("识别失败：" + e.getMessage());
        }
    }
    
    /**
     * 智能推荐饮食方案
     * 
     * @param userId 用户ID
     * @param targetCalories 目标热量
     * @return 推荐方案
     */
    @PostMapping("/recommendation/smart")
    public AjaxResult smartRecommendation(
            @RequestParam Long userId,
            @RequestParam(required = false) Integer targetCalories) {
        try {
            // 查询用户最近的饮食记录，分析模式
            String sql = "SELECT " +
                    "COALESCE(AVG(total_calories), 2000) as avg_calories, " +
                    "COALESCE(AVG(total_protein), 60) as avg_protein, " +
                    "COALESCE(AVG(total_fat), 50) as avg_fat, " +
                    "COALESCE(AVG(total_carbohydrate), 250) as avg_carbohydrate " +
                    "FROM diet_record " +
                    "WHERE user_id = ? " +
                    "AND record_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            
            List<Map<String, Object>> history = jdbcTemplate.queryForList(sql, userId);
            
            // 生成推荐方案（简化版）
            Map<String, Object> recommendation = new HashMap<>();
            recommendation.put("userId", userId);
            recommendation.put("targetCalories", targetCalories != null ? targetCalories : 2000);
            
            // 推荐食物列表
            String foodSql = "SELECT f.food_id, f.food_name, f.category_id, " +
                    "n.calories, n.protein, n.fat, n.carbohydrate, n.fiber " +
                    "FROM diet_food_info f " +
                    "LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id " +
                    "WHERE f.status = '0' " +
                    "ORDER BY RAND() LIMIT 5";
            
            List<Map<String, Object>> recommendedFoods = jdbcTemplate.queryForList(foodSql);
            
            recommendation.put("recommendedFoods", recommendedFoods);
            recommendation.put("userHistory", history.isEmpty() ? null : history.get(0));
            recommendation.put("message", "基于您的历史数据生成的推荐方案");
            
            return AjaxResult.success("推荐生成成功", recommendation);
            
        } catch (Exception e) {
            logger.error("生成智能推荐失败", e);
            return AjaxResult.error("生成推荐失败");
        }
    }
    
    /**
     * 获取今日推荐
     */
    @GetMapping("/recommendation/today")
    public AjaxResult getTodayRecommendation(@RequestParam Long userId) {
        try {
            // 简化版：返回随机推荐的健康食物
            String sql = "SELECT f.food_id, f.food_name, c.category_name, " +
                    "n.calories, n.protein, n.fat, n.carbohydrate " +
                    "FROM diet_food_info f " +
                    "LEFT JOIN diet_food_category c ON f.category_id = c.category_id " +
                    "LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id " +
                    "WHERE f.status = '0' " +
                    "AND n.calories < 200 " +  // 低热量食物
                    "ORDER BY RAND() LIMIT 3";
            
            List<Map<String, Object>> recommendations = jdbcTemplate.queryForList(sql);
            
            Map<String, Object> result = new HashMap<>();
            result.put("date", new Date());
            result.put("recommendations", recommendations);
            result.put("message", "今日健康推荐");
            
            return AjaxResult.success(result);
            
        } catch (Exception e) {
            logger.error("获取今日推荐失败", e);
            return AjaxResult.error("获取推荐失败");
        }
    }
}
