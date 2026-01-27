package com.SDR_System.web.controller.diet;

import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.diet.service.IDietRecordService;
import com.SDR_System.diet.service.IDietGoalService;
import com.SDR_System.diet.service.IDietRecommendationService;
import com.SDR_System.diet.domain.DietGoal;
import com.SDR_System.diet.domain.DietRecommendation;
import com.SDR_System.system.domain.DietRecord;
import com.SDR_System.system.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 管理端饮食仪表板Controller
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/diet/dashboard")
public class DietDashboardController extends BaseController
{
    private static final org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(DietDashboardController.class);

    @Autowired
    private IDietRecordService dietRecordService;

    @Autowired
    private IDietGoalService dietGoalService;

    @Autowired
    private IDietRecommendationService dietRecommendationService;

    @Autowired
    private ISysUserService userService;

    /**
     * 获取今日概览数据
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/today-overview")
    public AjaxResult getTodayOverview(@RequestParam(required = false) Long userId)
    {
        try {
            // 如果没有传userId，使用当前登录用户ID
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            // 获取今日饮食记录
            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDate(userId, new Date());

            // 计算营养摄入
            BigDecimal actualCalories = BigDecimal.ZERO;
            BigDecimal actualProtein = BigDecimal.ZERO;
            BigDecimal actualFat = BigDecimal.ZERO;
            BigDecimal actualCarbohydrate = BigDecimal.ZERO;

            for (DietRecord record : records) {
                if (record.getTotalCalories() != null) {
                    actualCalories = actualCalories.add(record.getTotalCalories());
                }
                if (record.getTotalProtein() != null) {
                    actualProtein = actualProtein.add(record.getTotalProtein());
                }
                if (record.getTotalFat() != null) {
                    actualFat = actualFat.add(record.getTotalFat());
                }
                if (record.getTotalCarbohydrate() != null) {
                    actualCarbohydrate = actualCarbohydrate.add(record.getTotalCarbohydrate());
                }
            }

            // 获取用户目标 - 使用默认值
            BigDecimal targetCalories = new BigDecimal("2000");
            BigDecimal targetProtein = new BigDecimal("60");
            BigDecimal targetFat = new BigDecimal("60");
            BigDecimal targetCarbohydrate = new BigDecimal("250");

            // 尝试从用户健康目标中获取
            try {
                DietGoal goalQuery = new DietGoal();
                goalQuery.setUserId(userId);
                goalQuery.setStatus("0"); // 进行中
                List<DietGoal> goals = dietGoalService.selectDietGoalList(goalQuery);

                if (!goals.isEmpty() && goals.get(0).getTargetValue() != null) {
                    // 根据目标类型设置目标热量
                    targetCalories = goals.get(0).getTargetValue();
                }
            } catch (Exception e) {
                logger.warn("获取用户目标失败，使用默认值: {}", e.getMessage());
            }

            // 构建返回数据
            Map<String, Object> result = new HashMap<>();
            result.put("targetCalories", targetCalories);
            result.put("actualCalories", actualCalories);
            result.put("targetProtein", targetProtein);
            result.put("actualProtein", actualProtein);
            result.put("targetFat", targetFat);
            result.put("actualFat", actualFat);
            result.put("targetCarbohydrate", targetCarbohydrate);
            result.put("actualCarbohydrate", actualCarbohydrate);
            result.put("date", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));

            return AjaxResult.success(result);
        } catch (Exception e) {
            logger.error("获取今日概览失败", e);
            return AjaxResult.error("获取今日概览失败: " + e.getMessage());
        }
    }

    /**
     * 获取今日各餐次记录
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/today-meals")
    public AjaxResult getTodayMeals(@RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDate(userId, new Date());

            // 按餐次分组
            Map<String, List<DietRecord>> mealGroups = records.stream()
                .collect(Collectors.groupingBy(record -> 
                    record.getMealType() != null ? record.getMealType() : "unknown"
                ));

            return AjaxResult.success(mealGroups);
        } catch (Exception e) {
            logger.error("获取今日餐次失败", e);
            return AjaxResult.error("获取今日餐次失败: " + e.getMessage());
        }
    }

    /**
     * 获取热量趋势（最近7天）
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/calorie-trend")
    public AjaxResult getCalorieTrend(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            // 默认最近7天
            Date end = endDate != null ? new SimpleDateFormat("yyyy-MM-dd").parse(endDate) : new Date();
            Date start = startDate != null ? new SimpleDateFormat("yyyy-MM-dd").parse(startDate) : 
                         new Date(end.getTime() - 6 * 24 * 60 * 60 * 1000L);

            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, start, end);

            // 按日期分组并汇总
            Map<String, BigDecimal> dailyCalories = new TreeMap<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            for (DietRecord record : records) {
                String date = sdf.format(record.getRecordDate());
                BigDecimal calories = record.getTotalCalories() != null ? record.getTotalCalories() : BigDecimal.ZERO;
                dailyCalories.merge(date, calories, BigDecimal::add);
            }

            // 转换为图表数据格式
            List<Map<String, Object>> trendData = new ArrayList<>();
            for (Map.Entry<String, BigDecimal> entry : dailyCalories.entrySet()) {
                Map<String, Object> point = new HashMap<>();
                point.put("date", entry.getKey());
                point.put("calories", entry.getValue());
                trendData.add(point);
            }

            return AjaxResult.success(trendData);
        } catch (Exception e) {
            logger.error("获取热量趋势失败", e);
            return AjaxResult.error("获取热量趋势失败: " + e.getMessage());
        }
    }

    /**
     * 获取营养分布数据
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/nutrition-distribution")
    public AjaxResult getNutritionDistribution(
            @RequestParam(required = false) String date,
            @RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            Date targetDate = date != null ? new SimpleDateFormat("yyyy-MM-dd").parse(date) : new Date();
            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDate(userId, targetDate);

            // 汇总三大营养素
            BigDecimal totalProtein = BigDecimal.ZERO;
            BigDecimal totalFat = BigDecimal.ZERO;
            BigDecimal totalCarbohydrate = BigDecimal.ZERO;

            for (DietRecord record : records) {
                if (record.getTotalProtein() != null) {
                    totalProtein = totalProtein.add(record.getTotalProtein());
                }
                if (record.getTotalFat() != null) {
                    totalFat = totalFat.add(record.getTotalFat());
                }
                if (record.getTotalCarbohydrate() != null) {
                    totalCarbohydrate = totalCarbohydrate.add(record.getTotalCarbohydrate());
                }
            }

            Map<String, Object> distribution = new HashMap<>();
            distribution.put("protein", totalProtein);
            distribution.put("fat", totalFat);
            distribution.put("carbohydrate", totalCarbohydrate);

            return AjaxResult.success(distribution);
        } catch (Exception e) {
            logger.error("获取营养分布失败", e);
            return AjaxResult.error("获取营养分布失败: " + e.getMessage());
        }
    }

    /**
     * 获取快速统计数据
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/quick-stats")
    public AjaxResult getQuickStats(@RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            DietRecord queryRecord = new DietRecord();
            queryRecord.setUserId(userId);
            List<DietRecord> allRecords = dietRecordService.selectDietRecordList(queryRecord);

            // 计算统计数据
            long recordCount = allRecords.size();
            long uniqueDays = allRecords.stream()
                .map(r -> new SimpleDateFormat("yyyy-MM-dd").format(r.getRecordDate()))
                .distinct()
                .count();

            DietGoal goalQuery = new DietGoal();
            goalQuery.setUserId(userId);
            List<DietGoal> goals = dietGoalService.selectDietGoalList(goalQuery);
            long goalsCount = goals.size();

            Map<String, Object> stats = new HashMap<>();
            stats.put("recordCount", recordCount);
            stats.put("recordDays", uniqueDays);
            stats.put("goalsCount", goalsCount);

            return AjaxResult.success(stats);
        } catch (Exception e) {
            logger.error("获取快速统计失败", e);
            return AjaxResult.error("获取快速统计失败: " + e.getMessage());
        }
    }

    /**
     * 获取健康目标进度
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/goal-progress")
    public AjaxResult getGoalProgress(@RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            DietGoal goalQuery = new DietGoal();
            goalQuery.setUserId(userId);
            goalQuery.setStatus("0"); // 进行中
            List<DietGoal> goals = dietGoalService.selectDietGoalList(goalQuery);

            List<Map<String, Object>> progressList = new ArrayList<>();
            for (DietGoal goal : goals) {
                Map<String, Object> progress = new HashMap<>();
                progress.put("goalId", goal.getGoalId());
                progress.put("goalType", goal.getGoalType());
                progress.put("targetValue", goal.getTargetValue());
                progress.put("currentValue", goal.getCurrentValue());
                
                // 计算进度百分比
                if (goal.getTargetValue() != null && goal.getTargetValue().compareTo(BigDecimal.ZERO) > 0 
                    && goal.getCurrentValue() != null) {
                    BigDecimal percentage = goal.getCurrentValue()
                        .multiply(new BigDecimal("100"))
                        .divide(goal.getTargetValue(), 2, BigDecimal.ROUND_HALF_UP);
                    progress.put("progress", percentage);
                } else {
                    progress.put("progress", BigDecimal.ZERO);
                }
                
                progressList.add(progress);
            }

            return AjaxResult.success(progressList);
        } catch (Exception e) {
            logger.error("获取目标进度失败", e);
            return AjaxResult.error("获取目标进度失败: " + e.getMessage());
        }
    }

    /**
     * 生成快速推荐
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:edit')")
    @PostMapping("/quick-recommendation")
    public AjaxResult generateQuickRecommendation(@RequestParam(required = false) Long userId)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            // 获取今日营养摄入
            List<DietRecord> todayRecords = dietRecordService.selectDietRecordsByUserIdAndDate(userId, new Date());
            
            BigDecimal todayCalories = todayRecords.stream()
                .map(r -> r.getTotalCalories() != null ? r.getTotalCalories() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

            // 生成简单推荐
            DietRecommendation recommendation = new DietRecommendation();
            recommendation.setUserId(userId);
            recommendation.setRecommendationDate(new Date());
            recommendation.setRecommendationType("0"); // 快速推荐
            recommendation.setMealType("0"); // 默认早餐推荐
            
            // 根据今日摄入情况生成推荐食物和理由
            String recommendedFoods = "";
            String reason = "";
            
            if (todayCalories.compareTo(new BigDecimal("2000")) > 0) {
                recommendedFoods = "西兰花,番茄,鸡胸肉,藜麦";
                reason = "今日热量摄入较高，建议选择低热量高营养密度的食物。";
                recommendation.setTargetCalories(new BigDecimal("300"));
            } else if (todayCalories.compareTo(new BigDecimal("1500")) < 0) {
                recommendedFoods = "牛油果,坚果,全麦面包,鸡蛋";
                reason = "今日热量摄入偏低，建议增加健康脂肪和蛋白质摄入。";
                recommendation.setTargetCalories(new BigDecimal("500"));
            } else {
                recommendedFoods = "三文鱼,糙米饭,菠菜,胡萝卜";
                reason = "今日营养摄入合理，推荐均衡搭配的食物组合。";
                recommendation.setTargetCalories(new BigDecimal("400"));
            }
            
            recommendation.setRecommendedFoods(recommendedFoods);
            recommendation.setReason(reason);
            recommendation.setAlgorithmType("快速推荐算法");
            recommendation.setScore(new BigDecimal("85"));
            recommendation.setStatus("0");
            
            dietRecommendationService.insertDietRecommendation(recommendation);

            // 返回格式化的推荐结果
            Map<String, Object> result = new HashMap<>();
            result.put("recommendationId", recommendation.getRecommendationId());
            result.put("recommendedFoods", recommendedFoods);
            result.put("reason", reason);
            result.put("targetCalories", recommendation.getTargetCalories());
            result.put("todayCalories", todayCalories);
            
            return AjaxResult.success("推荐生成成功", result);
        } catch (Exception e) {
            logger.error("生成快速推荐失败", e);
            return AjaxResult.error("生成快速推荐失败: " + e.getMessage());
        }
    }

    /**
     * 获取最近的推荐记录
     */
    @PreAuthorize("@ss.hasPermi('diet:dashboard:view')")
    @GetMapping("/recent-recommendations")
    public AjaxResult getRecentRecommendations(
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "5") Integer limit)
    {
        try {
            if (userId == null) {
                userId = SecurityUtils.getUserId();
            }

            DietRecommendation query = new DietRecommendation();
            query.setUserId(userId);
            List<DietRecommendation> recommendations = dietRecommendationService.selectDietRecommendationList(query);

            // 按日期排序，取最近N条
            List<DietRecommendation> recentList = recommendations.stream()
                .sorted((a, b) -> b.getRecommendationDate().compareTo(a.getRecommendationDate()))
                .limit(limit)
                .collect(Collectors.toList());

            return AjaxResult.success(recentList);
        } catch (Exception e) {
            logger.error("获取最近推荐失败", e);
            return AjaxResult.error("获取最近推荐失败: " + e.getMessage());
        }
    }
}

