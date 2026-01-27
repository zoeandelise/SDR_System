package com.SDR_System.diet.controller;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.diet.service.SmartRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 智能推荐Controller
 * 
 * 功能：提供基于算法的智能饮食推荐API
 * 算法版本：V1.0（营养匹配 + 偏好过滤 + 反馈优化）
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@RestController
@RequestMapping("/diet/smart")
public class SmartRecommendationController extends BaseController {
    
    @Autowired
    private SmartRecommendationService smartRecommendationService;
    
    /**
     * 生成个性化推荐
     * 
     * URL: POST /diet/smart/recommend
     * 请求体示例：
     * {
     *   "userId": 101,
     *   "mealType": "1",
     *   "count": 10
     * }
     */
    @PostMapping("/recommend")
    public AjaxResult generateRecommendation(@RequestBody Map<String, Object> params) {
        try {
            Long userId = Long.valueOf(params.get("userId").toString());
            String mealType = params.getOrDefault("mealType", "1").toString();
            Integer count = Integer.valueOf(params.getOrDefault("count", 10).toString());
            
            List<Map<String, Object>> recommendations = 
                smartRecommendationService.generateRecommendation(userId, mealType, count);
            
            if (recommendations.isEmpty()) {
                return AjaxResult.error("暂无可推荐的食物，请检查用户数据或食物库");
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("recommendations", recommendations);
            result.put("count", recommendations.size());
            result.put("algorithm", "nutrition_match_v1");
            result.put("version", "1.0.0");
            
            return AjaxResult.success("推荐生成成功", result);
            
        } catch (Exception e) {
            logger.error("生成推荐失败", e);
            return AjaxResult.error("推荐生成失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户营养目标
     * 
     * URL: GET /diet/smart/nutrition-target?userId=101&mealType=1
     */
    @GetMapping("/nutrition-target")
    public AjaxResult getNutritionTarget(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") String mealType) {
        try {
            Map<String, Object> target = 
                smartRecommendationService.getMealNutritionTarget(userId, mealType);
            
            return AjaxResult.success("营养目标获取成功", target);
            
        } catch (Exception e) {
            logger.error("获取营养目标失败", e);
            return AjaxResult.error("获取失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取算法统计信息
     * 
     * URL: GET /diet/smart/stats
     */
    @GetMapping("/stats")
    public AjaxResult getAlgorithmStats() {
        try {
            Map<String, Object> stats = smartRecommendationService.getAlgorithmStats();
            return AjaxResult.success("统计信息获取成功", stats);
        } catch (Exception e) {
            logger.error("获取算法统计失败", e);
            return AjaxResult.error("获取失败: " + e.getMessage());
        }
    }
    
    /**
     * 批量生成推荐（定时任务用）
     * 
     * URL: POST /diet/smart/batch-recommend
     * 请求体示例：
     * {
     *   "userIds": [101, 102, 103],
     *   "mealType": "1"
     * }
     */
    @PostMapping("/batch-recommend")
    public AjaxResult batchRecommend(@RequestBody Map<String, Object> params) {
        try {
            @SuppressWarnings("unchecked")
            List<Long> userIds = (List<Long>) params.get("userIds");
            String mealType = params.getOrDefault("mealType", "1").toString();
            
            Map<String, Object> result = 
                smartRecommendationService.batchGenerateRecommendations(userIds, mealType);
            
            return AjaxResult.success("批量推荐完成", result);
            
        } catch (Exception e) {
            logger.error("批量推荐失败", e);
            return AjaxResult.error("批量推荐失败: " + e.getMessage());
        }
    }
    
    /**
     * 测试算法（开发调试用）
     * 
     * URL: GET /diet/smart/test?userId=101
     */
    @GetMapping("/test")
    public AjaxResult testAlgorithm(@RequestParam Long userId) {
        try {
            Map<String, Object> testResults = new HashMap<>();
            
            // 测试早午晚三餐推荐
            testResults.put("breakfast", smartRecommendationService.generateRecommendation(userId, "0", 3));
            testResults.put("lunch", smartRecommendationService.generateRecommendation(userId, "1", 3));
            testResults.put("dinner", smartRecommendationService.generateRecommendation(userId, "2", 3));
            
            // 获取营养目标
            testResults.put("nutrition_targets", new HashMap<String, Object>() {{
                put("breakfast", smartRecommendationService.getMealNutritionTarget(userId, "0"));
                put("lunch", smartRecommendationService.getMealNutritionTarget(userId, "1"));
                put("dinner", smartRecommendationService.getMealNutritionTarget(userId, "2"));
            }});
            
            return AjaxResult.success("算法测试完成", testResults);
            
        } catch (Exception e) {
            logger.error("算法测试失败", e);
            return AjaxResult.error("测试失败: " + e.getMessage());
        }
    }
}

