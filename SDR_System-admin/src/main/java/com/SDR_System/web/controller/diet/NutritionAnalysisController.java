package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.system.domain.DietRecord;
import com.SDR_System.diet.service.IDietRecordService;
import com.SDR_System.diet.service.ISysUserHealthService;

/**
 * 营养分析Controller
 * 
 * @author SDR_System
 * @date 2025-09-23
 */
@RestController
@RequestMapping("/diet/analysis")
public class NutritionAnalysisController extends BaseController
{
    @Autowired
    private IDietRecordService dietRecordService;

    @Autowired
    private ISysUserHealthService sysUserHealthService;

    /**
     * 获取营养分析数据
     */
    @GetMapping("/nutrition")
    public AjaxResult getNutritionAnalysis(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) Long userId)
    {
        try {
            // 权限控制：非管理员只能查看自己的数据
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            } else if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && !SecurityUtils.getUserId().equals(userId)) {
                return error("无权限访问其他用户的数据");
            }
            
            // 获取指定时间范围内的饮食记录
            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
            
            // 获取营养汇总
            DietRecord summary = dietRecordService.selectNutritionSummaryByUserIdAndDateRange(userId, startDate, endDate);
            
            // 获取统计报告
            IDietRecordService.DietStatisticsReport report = dietRecordService.getDietStatisticsReport(userId, startDate, endDate);
            
            Map<String, Object> result = new HashMap<>();
            result.put("rows", records);
            result.put("total", records.size());
            result.put("summary", summary);
            result.put("report", report);
            
            return success(result);
        } catch (Exception e) {
            logger.error("获取营养分析数据失败", e);
            return error("获取营养分析数据失败：" + e.getMessage());
        }
    }

    /**
     * 获取营养建议
     */
    @GetMapping("/advice")
    public AjaxResult getNutritionAdvice(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) Long userId)
    {
        try {
            // 如果没有指定userId，使用当前登录用户
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }
            
            // 获取用户健康评估报告
            ISysUserHealthService.HealthAssessmentReport healthReport = 
                sysUserHealthService.getHealthAssessmentReport(userId);
            
            // 获取营养汇总
            DietRecord summary = dietRecordService.selectNutritionSummaryByUserIdAndDateRange(userId, startDate, endDate);
            
            // 生成营养建议
            List<Map<String, Object>> advice = generateNutritionAdvice(healthReport, summary);
            
            return success(advice);
        } catch (Exception e) {
            logger.error("获取营养建议失败", e);
            return error("获取营养建议失败：" + e.getMessage());
        }
    }

    /**
     * 获取营养摄入趋势
     */
    @GetMapping("/trend")
    public AjaxResult getNutritionTrend(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) Long userId)
    {
        try {
            // 如果没有指定userId，使用当前登录用户
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }
            
            // 获取统计报告
            IDietRecordService.DietStatisticsReport report = dietRecordService.getDietStatisticsReport(userId, startDate, endDate);
            
            return success(report.getDailyTrends());
        } catch (Exception e) {
            logger.error("获取营养趋势失败", e);
            return error("获取营养趋势失败：" + e.getMessage());
        }
    }

    /**
     * 获取营养分布分析
     */
    @GetMapping("/distribution")
    public AjaxResult getNutritionDistribution(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) Long userId)
    {
        try {
            // 如果没有指定userId，使用当前登录用户
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }
            
            // 获取营养汇总
            DietRecord summary = dietRecordService.selectNutritionSummaryByUserIdAndDateRange(userId, startDate, endDate);
            
            Map<String, Object> distribution = new HashMap<>();
            if (summary != null) {
                double totalCalories = summary.getTotalCalories() != null ? summary.getTotalCalories().doubleValue() : 0;
                double protein = summary.getTotalProtein() != null ? summary.getTotalProtein().doubleValue() : 0;
                double fat = summary.getTotalFat() != null ? summary.getTotalFat().doubleValue() : 0;
                double carb = summary.getTotalCarbohydrate() != null ? summary.getTotalCarbohydrate().doubleValue() : 0;
                
                // 计算营养素热量占比
                double proteinCalories = protein * 4; // 蛋白质4kcal/g
                double fatCalories = fat * 9; // 脂肪9kcal/g
                double carbCalories = carb * 4; // 碳水4kcal/g
                
                if (totalCalories > 0) {
                    distribution.put("proteinPercent", Math.round(proteinCalories / totalCalories * 100 * 100.0) / 100.0);
                    distribution.put("fatPercent", Math.round(fatCalories / totalCalories * 100 * 100.0) / 100.0);
                    distribution.put("carbPercent", Math.round(carbCalories / totalCalories * 100 * 100.0) / 100.0);
                } else {
                    distribution.put("proteinPercent", 0);
                    distribution.put("fatPercent", 0);
                    distribution.put("carbPercent", 0);
                }
                
                distribution.put("totalCalories", totalCalories);
                distribution.put("protein", protein);
                distribution.put("fat", fat);
                distribution.put("carbohydrate", carb);
            }
            
            return success(distribution);
        } catch (Exception e) {
            logger.error("获取营养分布失败", e);
            return error("获取营养分布失败：" + e.getMessage());
        }
    }

    /**
     * 生成营养建议
     */
    private List<Map<String, Object>> generateNutritionAdvice(
            ISysUserHealthService.HealthAssessmentReport healthReport, 
            DietRecord summary) {
        
        List<Map<String, Object>> advice = new java.util.ArrayList<>();
        
        if (healthReport == null || summary == null) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "info");
            item.put("title", "数据不足");
            item.put("content", "请先完善健康信息并记录饮食数据");
            advice.add(item);
            return advice;
        }
        
        double actualCalories = summary.getTotalCalories() != null ? summary.getTotalCalories().doubleValue() : 0;
        double targetCalories = healthReport.getDailyCalorieNeed() != null ? healthReport.getDailyCalorieNeed() : 2000;
        
        // 热量建议
        if (actualCalories < targetCalories * 0.8) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "warning");
            item.put("title", "热量摄入不足");
            item.put("content", String.format("您的热量摄入(%.0f kcal)低于建议值(%.0f kcal)，建议增加健康食物的摄入", 
                actualCalories, targetCalories));
            advice.add(item);
        } else if (actualCalories > targetCalories * 1.2) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "warning");
            item.put("title", "热量摄入过多");
            item.put("content", String.format("您的热量摄入(%.0f kcal)超过建议值(%.0f kcal)，建议控制饮食或增加运动", 
                actualCalories, targetCalories));
            advice.add(item);
        } else {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "success");
            item.put("title", "热量摄入适宜");
            item.put("content", "您的热量摄入在合理范围内，请继续保持");
            advice.add(item);
        }
        
        // 蛋白质建议
        double actualProtein = summary.getTotalProtein() != null ? summary.getTotalProtein().doubleValue() : 0;
        double targetProtein = healthReport.getDailyProteinNeed() != null ? healthReport.getDailyProteinNeed() : 60;
        
        if (actualProtein < targetProtein * 0.8) {
            Map<String, Object> item = new HashMap<>();
            item.put("type", "warning");
            item.put("title", "蛋白质摄入不足");
            item.put("content", "建议增加瘦肉、鱼类、蛋类、豆制品等优质蛋白质的摄入");
            advice.add(item);
        }
        
        // 营养均衡建议
        Map<String, Object> item = new HashMap<>();
        item.put("type", "info");
        item.put("title", "营养均衡建议");
        item.put("content", "建议每日摄入多样化食物，包括谷类、蔬菜、水果、肉类、奶类等各类食物");
        advice.add(item);
        
        return advice;
    }
}
