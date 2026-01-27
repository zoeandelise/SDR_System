package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 管理员饮食记录概览Controller
 * 
 * @author SDR_System
 */
@RestController
@RequestMapping("/admin/diet/records")
public class DietRecordsOverviewController extends BaseController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 获取饮食记录概览数据
     */
    @GetMapping("/overview")
    public AjaxResult getRecordsOverview(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            Map<String, Object> overview = new HashMap<>();
            
            // 1. 总记录数（指定日期范围）
            String totalRecordsSql = "SELECT COUNT(*) as total_records " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ?";
            
            Integer totalRecords = jdbcTemplate.queryForObject(totalRecordsSql, Integer.class, startDate, endDate);
            
            // 2. 按餐次类型统计
            String mealTypeSql = "SELECT " +
                    "CASE " +
                    "  WHEN meal_type = '0' THEN '早餐' " +
                    "  WHEN meal_type = '1' THEN '午餐' " +
                    "  WHEN meal_type = '2' THEN '晚餐' " +
                    "  WHEN meal_type = '3' THEN '加餐' " +
                    "  ELSE '其他' " +
                    "END as meal_name, " +
                    "COUNT(*) as record_count, " +
                    "ROUND(AVG(total_calories), 2) as avg_calories " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ? " +
                    "GROUP BY meal_type " +
                    "ORDER BY meal_type";
            
            List<Map<String, Object>> mealTypeStats = jdbcTemplate.queryForList(mealTypeSql, startDate, endDate);
            
            // 3. 每日记录趋势
            String dailyTrendSql = "SELECT " +
                    "record_date, " +
                    "COUNT(*) as daily_records, " +
                    "ROUND(SUM(total_calories), 2) as daily_total_calories, " +
                    "COUNT(DISTINCT user_id) as active_users " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ? " +
                    "GROUP BY record_date " +
                    "ORDER BY record_date";
            
            List<Map<String, Object>> dailyTrend = jdbcTemplate.queryForList(dailyTrendSql, startDate, endDate);
            
            // 4. 活跃用户统计
            String activeUsersSql = "SELECT " +
                    "COUNT(DISTINCT user_id) as active_users, " +
                    "ROUND(AVG(total_calories), 2) as avg_calories_per_record, " +
                    "ROUND(SUM(total_calories), 2) as total_calories " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ?";
            
            List<Map<String, Object>> activeUsersStats = jdbcTemplate.queryForList(activeUsersSql, startDate, endDate);
            
            // 5. 营养摄入统计
            String nutritionSql = "SELECT " +
                    "ROUND(AVG(total_calories), 2) as avg_calories, " +
                    "ROUND(AVG(total_protein), 2) as avg_protein, " +
                    "ROUND(AVG(total_fat), 2) as avg_fat, " +
                    "ROUND(AVG(total_carbohydrate), 2) as avg_carbohydrate, " +
                    "ROUND(SUM(total_calories), 2) as total_calories, " +
                    "ROUND(SUM(total_protein), 2) as total_protein, " +
                    "ROUND(SUM(total_fat), 2) as total_fat, " +
                    "ROUND(SUM(total_carbohydrate), 2) as total_carbohydrate " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ?";
            
            List<Map<String, Object>> nutritionStats = jdbcTemplate.queryForList(nutritionSql, startDate, endDate);
            
            // 6. 用户参与度统计
            String participationSql = "SELECT " +
                    "u.user_id, u.nick_name, " +
                    "COUNT(dr.record_id) as record_count, " +
                    "ROUND(AVG(dr.total_calories), 2) as avg_calories " +
                    "FROM sys_user u " +
                    "LEFT JOIN diet_record dr ON u.user_id = dr.user_id " +
                    "    AND dr.record_date >= ? AND dr.record_date <= ? " +
                    "WHERE u.user_id >= 101 " +
                    "GROUP BY u.user_id, u.nick_name " +
                    "HAVING record_count > 0 " +
                    "ORDER BY record_count DESC " +
                    "LIMIT 10";
            
            List<Map<String, Object>> topUsers = jdbcTemplate.queryForList(participationSql, startDate, endDate);
            
            // 组装返回数据
            Map<String, String> dateRangeMap = new HashMap<>();
            dateRangeMap.put("startDate", startDate);
            dateRangeMap.put("endDate", endDate);
            overview.put("dateRange", dateRangeMap);
            
            overview.put("totalRecords", totalRecords != null ? totalRecords : 0);
            overview.put("mealTypeStats", mealTypeStats);
            overview.put("dailyTrend", dailyTrend);
            
            if (activeUsersStats.isEmpty()) {
                Map<String, Object> emptyActiveUsersInfo = new HashMap<>();
                emptyActiveUsersInfo.put("active_users", 0);
                emptyActiveUsersInfo.put("avg_calories_per_record", 0);
                emptyActiveUsersInfo.put("total_calories", 0);
                overview.put("activeUsersInfo", emptyActiveUsersInfo);
            } else {
                overview.put("activeUsersInfo", activeUsersStats.get(0));
            }
            
            if (nutritionStats.isEmpty()) {
                Map<String, Object> emptyNutritionStats = new HashMap<>();
                emptyNutritionStats.put("avg_calories", 0);
                emptyNutritionStats.put("avg_protein", 0);
                emptyNutritionStats.put("avg_fat", 0);
                emptyNutritionStats.put("avg_carbohydrate", 0);
                overview.put("nutritionStats", emptyNutritionStats);
            } else {
                overview.put("nutritionStats", nutritionStats.get(0));
            }
            
            overview.put("topActiveUsers", topUsers);
            
            return AjaxResult.success(overview);
            
        } catch (Exception e) {
            logger.error("获取饮食记录概览失败", e);
            return AjaxResult.error("获取饮食记录概览失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取用户饮食记录详细统计
     */
    @GetMapping("/user-stats")
    public AjaxResult getUserRecordStats(
            @RequestParam Long userId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            // 如果没有指定日期范围，默认查询最近30天
            if (startDate == null || endDate == null) {
                startDate = "DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
                endDate = "CURDATE()";
            }
            
            Map<String, Object> userStats = new HashMap<>();
            
            // 用户基本统计
            String basicStatsSql = "SELECT " +
                    "COUNT(*) as total_records, " +
                    "ROUND(AVG(total_calories), 2) as avg_daily_calories, " +
                    "ROUND(AVG(total_protein), 2) as avg_daily_protein, " +
                    "ROUND(AVG(total_fat), 2) as avg_daily_fat, " +
                    "ROUND(AVG(total_carbohydrate), 2) as avg_daily_carb, " +
                    "MIN(record_date) as first_record, " +
                    "MAX(record_date) as last_record " +
                    "FROM diet_record " +
                    "WHERE user_id = ? AND record_date >= ? AND record_date <= ?";
            
            List<Map<String, Object>> basicStats = jdbcTemplate.queryForList(basicStatsSql, userId, startDate, endDate);
            
            // 按餐次统计
            String mealStatsSql = "SELECT " +
                    "meal_type, " +
                    "COUNT(*) as count, " +
                    "ROUND(AVG(total_calories), 2) as avg_calories " +
                    "FROM diet_record " +
                    "WHERE user_id = ? AND record_date >= ? AND record_date <= ? " +
                    "GROUP BY meal_type";
            
            List<Map<String, Object>> mealStats = jdbcTemplate.queryForList(mealStatsSql, userId, startDate, endDate);
            
            userStats.put("userId", userId);
            userStats.put("basicStats", basicStats.isEmpty() ? new HashMap<>() : basicStats.get(0));
            userStats.put("mealStats", mealStats);
            
            return AjaxResult.success(userStats);
            
        } catch (Exception e) {
            logger.error("获取用户记录统计失败", e);
            return AjaxResult.error("获取用户记录统计失败");
        }
    }
    
    /**
     * 获取营养摄入趋势分析
     */
    @GetMapping("/nutrition-trends")
    public AjaxResult getNutritionTrends(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            // 默认查询最近7天
            if (startDate == null || endDate == null) {
                startDate = "DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
                endDate = "CURDATE()";
            }
            
            String sql = "SELECT " +
                    "record_date, " +
                    "ROUND(AVG(total_calories), 2) as avg_calories, " +
                    "ROUND(AVG(total_protein), 2) as avg_protein, " +
                    "ROUND(AVG(total_fat), 2) as avg_fat, " +
                    "ROUND(AVG(total_carbohydrate), 2) as avg_carbohydrate, " +
                    "COUNT(DISTINCT user_id) as active_users, " +
                    "COUNT(*) as total_records " +
                    "FROM diet_record " +
                    "WHERE record_date >= ? AND record_date <= ? " +
                    "GROUP BY record_date " +
                    "ORDER BY record_date";
            
            List<Map<String, Object>> trends = jdbcTemplate.queryForList(sql, startDate, endDate);
            
            Map<String, Object> result = new HashMap<>();
            Map<String, String> dateRangeMap = new HashMap<>();
            dateRangeMap.put("startDate", startDate);
            dateRangeMap.put("endDate", endDate);
            result.put("dateRange", dateRangeMap);
            result.put("trends", trends);
            
            return AjaxResult.success(result);
            
        } catch (Exception e) {
            logger.error("获取营养趋势失败", e);
            return AjaxResult.error("获取营养趋势失败");
        }
    }
}
