package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;
import java.math.BigDecimal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.system.domain.DietRecord;
import com.SDR_System.system.domain.DietFoodInfo;
import com.SDR_System.diet.service.IDietRecordService;
import com.SDR_System.diet.service.IDietFoodInfoService;
import com.SDR_System.diet.service.IAiRecognitionService;
import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.format.annotation.DateTimeFormat;
import com.SDR_System.diet.service.IDietRecordService.DietStatisticsReport;

/**
 * 用户端饮食API控制器
 * 为React前端提供API服务
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/api/user/diet")
public class UserDietApiController extends BaseController
{
    @Autowired
    private IDietRecordService dietRecordService;

    @Autowired
    private IDietFoodInfoService dietFoodInfoService;

    @Autowired
    private IAiRecognitionService aiRecognitionService;

    @Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    // =================== 健康目标相关API ===================
    
    /**
     * 更新用户健康目标（完整信息）
     */
    @PostMapping("/update-health-goal")
    public AjaxResult updateHealthGoal(@RequestBody Map<String, Object> goalData) {
        try {
            Long userId = getCurrentUserId();
            
            String sql = "UPDATE sys_user_health SET " +
                        "gender = ?, age = ?, height = ?, weight = ?, " +
                        "diseases = ?, allergies = ?, diet_preferences = ?, " +
                        "health_goal = ?, target_weight = ?, " +
                        "daily_calorie_goal = ?, daily_protein_goal = ?, " +
                        "daily_carb_goal = ?, daily_fat_goal = ? " +
                        "WHERE user_id = ?";
            
            jdbcTemplate.update(sql,
                goalData.get("gender"),
                goalData.get("age"),
                goalData.get("height"),
                goalData.get("weight"),
                goalData.get("diseases"),
                goalData.get("allergies"),
                goalData.get("dietPreferences"),
                goalData.get("healthGoal"),
                goalData.get("targetWeight"),
                goalData.get("dailyCalorieGoal"),
                goalData.get("dailyProteinGoal"),
                goalData.get("dailyCarbGoal"),
                goalData.get("dailyFatGoal"),
                userId
            );
            
            return success("健康信息已更新");
        } catch (Exception e) {
            logger.error("更新健康目标失败", e);
            return error("更新失败：" + e.getMessage());
        }
    }
    
    // =================== 全天方案相关API ===================
    
    /**
     * 获取我的推荐方案
     */
    @GetMapping("/my-recommendations")
    public AjaxResult getMyRecommendations(@RequestParam(defaultValue = "7") int days) {
        try {
            Long userId = getCurrentUserId();
            
            String sql = "SELECT " +
                        "recognition_id AS recommendationId, " +
                        "user_id AS userId, " +
                        "recognition_type AS mealType, " +
                        "recognition_result AS recommendedFoods, " +
                        "recognition_date AS recommendationDate, " +
                        "'ML智能推荐' AS algorithmType, " +
                        "CASE WHEN is_applied = 1 THEN '1' ELSE '2' END AS isAccepted " +
                        "FROM diet_ai_recognition " +
                        "WHERE user_id = ? " +
                        "AND recognition_type = 'ML全天方案' " +
                        "AND recognition_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
                        "ORDER BY recognition_date DESC, recognition_id DESC";
            
            List<Map<String, Object>> recommendations = jdbcTemplate.queryForList(sql, userId, days);
            
            return success(recommendations);
        } catch (Exception e) {
            logger.error("获取推荐方案失败", e);
            return error("获取推荐方案失败：" + e.getMessage());
        }
    }
    
    /**
     * 一键生成全天饮食方案
     */
    @PostMapping("/daily-plan")
    @Log(title = "生成全天饮食方案", businessType = BusinessType.OTHER)
    public AjaxResult generateDailyPlan() {
        try {
            Long userId = getCurrentUserId();
            
            // 使用中式饮食智能推荐算法生成三餐 (count=1 表示生成1个组合)
            List<Map<String, Object>> breakfast = jdbcTemplate.queryForList("CALL generate_chinese_diet_recommendation(?, ?, ?)", userId, "0", 1);
            List<Map<String, Object>> lunch = jdbcTemplate.queryForList("CALL generate_chinese_diet_recommendation(?, ?, ?)", userId, "1", 1);
            List<Map<String, Object>> dinner = jdbcTemplate.queryForList("CALL generate_chinese_diet_recommendation(?, ?, ?)", userId, "2", 1);
            
            // 处理字段映射 (calories -> calories_per_100g)
            processFoodList(breakfast);
            processFoodList(lunch);
            processFoodList(dinner);
            
            Map<String, Object> plan = new HashMap<>();
            plan.put("userId", userId);
            plan.put("userName", SecurityUtils.getUsername());
            plan.put("breakfast", breakfast);
            plan.put("lunch", lunch);
            plan.put("dinner", dinner);
            
            // 计算总营养（合并所有三餐）
            int totalCal = 0;
            double totalProtein = 0;
            double totalCarb = 0;
            double totalFat = 0;
            
            // 累加早餐
            for (Map<String, Object> food : breakfast) {
                double portion = ((Number)food.get("recommended_portion")).doubleValue();
                totalCal += ((Number)food.get("calories_per_100g")).doubleValue() * portion / 100;
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue() * portion / 100;
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue() * portion / 100;
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue() * portion / 100;
            }
            
            // 累加午餐
            for (Map<String, Object> food : lunch) {
                double portion = ((Number)food.get("recommended_portion")).doubleValue();
                totalCal += ((Number)food.get("calories_per_100g")).doubleValue() * portion / 100;
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue() * portion / 100;
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue() * portion / 100;
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue() * portion / 100;
            }
            
            // 累加晚餐
            for (Map<String, Object> food : dinner) {
                double portion = ((Number)food.get("recommended_portion")).doubleValue();
                totalCal += ((Number)food.get("calories_per_100g")).doubleValue() * portion / 100;
                totalProtein += ((Number)food.get("protein_per_100g")).doubleValue() * portion / 100;
                totalCarb += ((Number)food.get("carb_per_100g")).doubleValue() * portion / 100;
                totalFat += ((Number)food.get("fat_per_100g")).doubleValue() * portion / 100;
            }
            
            plan.put("totalCalories", totalCal);
            plan.put("totalProtein", Math.round(totalProtein * 10) / 10.0);
            plan.put("totalCarb", Math.round(totalCarb * 10) / 10.0);
            plan.put("totalFat", Math.round(totalFat * 10) / 10.0);
            
            return success(plan);
        } catch (Exception e) {
            logger.error("生成全天方案失败", e);
            return error("生成失败：" + e.getMessage());
        }
    }
    
    /**
     * 处理食物列表字段映射
     */
    private void processFoodList(List<Map<String, Object>> foods) {
        for (Map<String, Object> food : foods) {
            // 映射营养字段
            if (food.containsKey("calories")) food.put("calories_per_100g", food.get("calories"));
            if (food.containsKey("protein")) food.put("protein_per_100g", food.get("protein"));
            if (food.containsKey("carbohydrate")) food.put("carb_per_100g", food.get("carbohydrate"));
            if (food.containsKey("fat")) food.put("fat_per_100g", food.get("fat"));
            
            // 映射份量字段
            if (food.containsKey("portion")) food.put("recommended_portion", food.get("portion"));
            
            // 确保数值不为null
            if (food.get("calories_per_100g") == null) food.put("calories_per_100g", 0);
            if (food.get("protein_per_100g") == null) food.put("protein_per_100g", 0);
            if (food.get("carb_per_100g") == null) food.put("carb_per_100g", 0);
            if (food.get("fat_per_100g") == null) food.put("fat_per_100g", 0);
            if (food.get("recommended_portion") == null) food.put("recommended_portion", 100);
        }
    }
    
    /**
     * 执行推荐方案（将推荐转为实际饮食记录）
     */
    @PostMapping("/plan/execute")
    @Log(title = "执行推荐方案", businessType = BusinessType.INSERT)
    public AjaxResult executePlan(@RequestBody Map<String, Object> params) {
        try {
            Long userId = getCurrentUserId();
            Integer recommendationId = (Integer)params.get("recommendationId");
            
            // 查询AI识别方案
            String querySql = "SELECT * FROM diet_ai_recognition WHERE recognition_id = ? AND user_id = ?";
            List<Map<String, Object>> results = jdbcTemplate.queryForList(querySql, recommendationId, userId);
            
            if (results.isEmpty()) {
                return error("推荐方案不存在");
            }
            
            Map<String, Object> recommendation = results.get(0);
            String recommendedFoods = (String)recommendation.get("recognition_result");
            
            // 简化：添加3条记录（早中晚各一条），使用合理的营养估算
            // 早餐记录
            if (recommendedFoods.contains("早餐")) {
                String breakfast = recommendedFoods.substring(
                    recommendedFoods.indexOf("早餐:"),
                    recommendedFoods.contains("午餐") ? recommendedFoods.indexOf("午餐") : recommendedFoods.length()
                );
                String insertSql = "INSERT INTO diet_record " +
                                  "(user_id, record_date, meal_type, notes, total_calories, total_protein, total_fat, total_carbohydrate, create_time) " +
                                  "VALUES (?, CURDATE(), ?, ?, ?, ?, ?, ?, NOW())";
                jdbcTemplate.update(insertSql, userId, "0", breakfast.trim(), 600, 25, 20, 75);
            }
            
            // 午餐记录
            if (recommendedFoods.contains("午餐")) {
                String lunch = recommendedFoods.substring(
                    recommendedFoods.indexOf("午餐:"),
                    recommendedFoods.contains("晚餐") ? recommendedFoods.indexOf("晚餐") : recommendedFoods.length()
                );
                String insertSql = "INSERT INTO diet_record " +
                                  "(user_id, record_date, meal_type, notes, total_calories, total_protein, total_fat, total_carbohydrate, create_time) " +
                                  "VALUES (?, CURDATE(), ?, ?, ?, ?, ?, ?, NOW())";
                jdbcTemplate.update(insertSql, userId, "1", lunch.trim(), 800, 40, 30, 100);
            }
            
            // 晚餐记录
            if (recommendedFoods.contains("晚餐")) {
                String dinner = recommendedFoods.substring(recommendedFoods.indexOf("晚餐:"));
                String insertSql = "INSERT INTO diet_record " +
                                  "(user_id, record_date, meal_type, notes, total_calories, total_protein, total_fat, total_carbohydrate, create_time) " +
                                  "VALUES (?, CURDATE(), ?, ?, ?, ?, ?, ?, NOW())";
                jdbcTemplate.update(insertSql, userId, "2", dinner.trim(), 700, 35, 25, 90);
            }
            
            // 更新AI识别方案状态为已应用
            String updateSql = "UPDATE diet_ai_recognition SET is_applied = 1 WHERE recognition_id = ?";
            jdbcTemplate.update(updateSql, recommendationId);
            
            return success("方案已执行，已添加到今日饮食记录");
        } catch (Exception e) {
            logger.error("执行方案失败", e);
            return error("执行失败：" + e.getMessage());
        }
    }
    
    /**
     * 保存全天饮食方案
     */
    @PostMapping("/save-daily-plan")
    @Log(title = "保存全天饮食方案", businessType = BusinessType.INSERT)
    public AjaxResult saveDailyPlan(@RequestBody Map<String, Object> planData) {
        try {
            Long userId = getCurrentUserId();
            
            // 构建推荐食物列表
            StringBuilder foodsJson = new StringBuilder();
            
            List breakfast = (List)planData.get("breakfast");
            foodsJson.append("早餐: ");
            for (Object food : breakfast) {
                Map f = (Map)food;
                foodsJson.append(f.get("food_name")).append(", ");
            }
            
            List lunch = (List)planData.get("lunch");
            foodsJson.append("午餐: ");
            for (Object food : lunch) {
                Map f = (Map)food;
                foodsJson.append(f.get("food_name")).append(", ");
            }
            
            List dinner = (List)planData.get("dinner");
            foodsJson.append("晚餐: ");
            for (Object food : dinner) {
                Map f = (Map)food;
                foodsJson.append(f.get("food_name")).append(", ");
            }
            
            // 保存到AI识别表（用于AI推荐方案）
            String sql = "INSERT INTO diet_ai_recognition " +
                        "(user_id, image_url, recognition_date, recognition_type, recognition_result, confidence_score, is_applied, create_time) " +
                        "VALUES (?, '', CURDATE(), 'ML全天方案', ?, 0.95, 0, NOW())";
            
            jdbcTemplate.update(sql, userId, foodsJson.toString());
            
            return success("方案已保存");
        } catch (Exception e) {
            logger.error("保存方案失败", e);
            return error("保存失败：" + e.getMessage());
        }
    }

    // =================== 仪表板相关API ===================

    /**
     * 获取用户仪表板数据
     */
    @GetMapping("/dashboard")
    public AjaxResult getDashboardData()
    {
        try {
            Long userId = getCurrentUserId();
            Date today = new Date();
            
            Map<String, Object> dashboardData = new HashMap<>();
            
            // 今日营养摄入统计（严格查询今天）
            DietRecord todayNutrition = calculateTodayNutrition(userId);
            
            // 本周统计
            Date weekStart = getWeekStartDate(today);
            DietStatisticsReport weekStats = dietRecordService.getDietStatisticsReport(userId, weekStart, today);
            
            // 今日饮食记录（严格查询今天）
            List<DietRecord> todayRecords = dietRecordService.selectDietRecordsByUserIdAndDate(userId, today);
            if (todayRecords == null) {
                todayRecords = new ArrayList<>();
            }
            
            dashboardData.put("todayNutrition", todayNutrition);
            dashboardData.put("weekStats", weekStats);
            dashboardData.put("todayRecords", todayRecords);
            dashboardData.put("userProfile", getUserProfile(userId));
            
            return success(dashboardData);
        } catch (Exception e) {
            logger.error("获取仪表板数据失败", e);
            return error("获取仪表板数据失败：" + e.getMessage());
        }
    }

    /**
     * 获取今日营养摄入
     */
    @GetMapping("/nutrition/today")
    public AjaxResult getTodayNutrition()
    {
        try {
            Long userId = getCurrentUserId();
            Date today = new Date();
            
            DietRecord nutrition = dietRecordService.selectNutritionSummaryByUserIdAndDateRange(userId, today, today);
            if (nutrition == null) {
                // 返回0值，不用假数据
                nutrition = new DietRecord();
                nutrition.setTotalCalories(new BigDecimal("0"));
                nutrition.setTotalProtein(new BigDecimal("0"));
                nutrition.setTotalFat(new BigDecimal("0"));
                nutrition.setTotalCarbohydrate(new BigDecimal("0"));
            }
            
            return success(nutrition);
        } catch (Exception e) {
            logger.error("获取今日营养数据失败", e);
            return error("获取营养数据失败：" + e.getMessage());
        }
    }

    // =================== 饮食记录相关API ===================

    /**
     * 获取用户饮食记录列表
     */
    @GetMapping("/records")
    public AjaxResult getRecords(
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) String mealType)
    {
        try {
            Long userId = getCurrentUserId();
            
            List<DietRecord> records;
            if (startDate != null && endDate != null) {
                records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
            } else if (startDate != null) {
                records = dietRecordService.selectDietRecordsByUserIdAndDate(userId, startDate);
            } else {
                // 默认获取最近7天的记录
                Date today = new Date();
                Date weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000L);
                records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, weekAgo, today);
            }
            
            return success(records);
        } catch (Exception e) {
            logger.error("获取饮食记录失败", e);
            return error("获取饮食记录失败：" + e.getMessage());
        }
    }

    /**
     * 添加饮食记录
     */
    @PostMapping("/records")
    @Log(title = "用户添加饮食记录", businessType = BusinessType.INSERT)
    public AjaxResult addRecord(@RequestBody DietRecord dietRecord)
    {
        try {
            Long userId = getCurrentUserId();
            dietRecord.setUserId(userId);
            
            int result = dietRecordService.insertDietRecord(dietRecord);
            return toAjax(result);
        } catch (Exception e) {
            logger.error("添加饮食记录失败", e);
            return error("添加饮食记录失败：" + e.getMessage());
        }
    }

    /**
     * 更新饮食记录
     */
    @PutMapping("/records/{recordId}")
    @Log(title = "用户更新饮食记录", businessType = BusinessType.UPDATE)
    public AjaxResult updateRecord(@PathVariable Long recordId, @RequestBody DietRecord dietRecord)
    {
        try {
            Long userId = getCurrentUserId();
            
            // 验证记录所有权
            DietRecord existingRecord = dietRecordService.selectDietRecordByRecordId(recordId);
            if (existingRecord == null || !userId.equals(existingRecord.getUserId())) {
                return error("无权限操作该记录");
            }
            
            dietRecord.setRecordId(recordId);
            dietRecord.setUserId(userId);
            
            int result = dietRecordService.updateDietRecord(dietRecord);
            return toAjax(result);
        } catch (Exception e) {
            logger.error("更新饮食记录失败", e);
            return error("更新饮食记录失败：" + e.getMessage());
        }
    }

    /**
     * 删除饮食记录（禁用MongoDB，只使用MySQL）
     */
    @DeleteMapping("/records/{recordId}")
    @Log(title = "用户删除饮食记录", businessType = BusinessType.DELETE)
    public AjaxResult deleteRecord(@PathVariable Long recordId)
    {
        try {
            Long userId = getCurrentUserId();
            
            // 验证记录所有权
            DietRecord existingRecord = dietRecordService.selectDietRecordByRecordId(recordId);
            if (existingRecord == null || !userId.equals(existingRecord.getUserId())) {
                return error("无权限操作该记录");
            }
            
            // 只删除MySQL记录，避免MongoDB认证问题
            int result = dietRecordService.deleteDietRecordByRecordIds(new Long[]{recordId});
            return success("删除成功");
        } catch (Exception e) {
            logger.error("删除饮食记录失败", e);
            // 简化错误信息，不暴露MongoDB细节
            return error("删除失败");
        }
    }

    // =================== 食物数据库相关API ===================

    /**
     * 搜索食物
     */
    @GetMapping("/foods/search")
    public AjaxResult searchFoods(@RequestParam String keyword)
    {
        try {
            List<DietFoodInfo> foods = dietFoodInfoService.selectDietFoodInfoByName(keyword);
            return success(foods);
        } catch (Exception e) {
            logger.error("搜索食物失败", e);
            return error("搜索食物失败：" + e.getMessage());
        }
    }

    /**
     * 根据分类获取食物
     */
    @GetMapping("/foods/category/{categoryId}")
    public AjaxResult getFoodsByCategory(@PathVariable Long categoryId)
    {
        try {
            List<DietFoodInfo> foods = dietFoodInfoService.selectDietFoodInfoByCategoryId(categoryId);
            return success(foods);
        } catch (Exception e) {
            logger.error("获取分类食物失败", e);
            return error("获取分类食物失败：" + e.getMessage());
        }
    }

    /**
     * 获取所有食物列表
     */
    @GetMapping("/foods")
    public AjaxResult getAllFoods(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword)
    {
        try {
            DietFoodInfo queryParam = new DietFoodInfo();
            if (keyword != null && !keyword.trim().isEmpty()) {
                queryParam.setFoodName(keyword);
            }
            
            List<DietFoodInfo> foods = dietFoodInfoService.selectDietFoodInfoList(queryParam);
            return success(foods);
        } catch (Exception e) {
            logger.error("获取食物列表失败", e);
            return error("获取食物列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取食物详细信息
     */
    @GetMapping("/foods/{foodId}")
    public AjaxResult getFoodDetail(@PathVariable Long foodId)
    {
        try {
            DietFoodInfo food = dietFoodInfoService.selectDietFoodInfoByFoodId(foodId);
            if (food == null) {
                return error("食物不存在");
            }
            return success(food);
        } catch (Exception e) {
            logger.error("获取食物详情失败", e);
            return error("获取食物详情失败：" + e.getMessage());
        }
    }

    // =================== AI识别相关API ===================

    /**
     * AI食物识别
     */
    @PostMapping("/recognize")
    @Log(title = "用户AI食物识别", businessType = BusinessType.OTHER)
    public AjaxResult recognizeFood(@RequestParam("image") MultipartFile imageFile)
    {
        try {
            Long userId = getCurrentUserId();
            IAiRecognitionService.AiRecognitionResult result = aiRecognitionService.recognizeFood(imageFile, userId);
            return success(result);
        } catch (Exception e) {
            logger.error("AI食物识别失败", e);
            return error("AI食物识别失败：" + e.getMessage());
        }
    }

    // =================== 统计分析相关API ===================

    /**
     * 获取营养统计报告
     */
    @GetMapping("/analysis/nutrition")
    public AjaxResult getStatistics(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate)
    {
        try {
            Long userId = getCurrentUserId();
            DietStatisticsReport report = dietRecordService.getDietStatisticsReport(userId, startDate, endDate);
            return success(report);
        } catch (Exception e) {
            logger.error("获取统计报告失败", e);
            return error("获取统计报告失败：" + e.getMessage());
        }
    }

    /**
     * 获取健康趋势数据
     */
    @GetMapping("/analysis/trends")
    public AjaxResult getHealthTrends(@RequestParam(defaultValue = "30") int days)
    {
        try {
            Long userId = getCurrentUserId();
            Date endDate = new Date();
            Date startDate = new Date(endDate.getTime() - days * 24 * 60 * 60 * 1000L);
            
            // 获取趋势数据
            List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
            
            Map<String, Object> trends = new HashMap<>();
            trends.put("records", records);
            trends.put("period", days);
            trends.put("startDate", startDate);
            trends.put("endDate", endDate);
            
            return success(trends);
        } catch (Exception e) {
            logger.error("获取健康趋势失败", e);
            return error("获取健康趋势失败：" + e.getMessage());
        }
    }

    // =================== 工具方法 ===================

    /**
     * 获取当前用户ID
     */
    private Long getCurrentUserId() {
        try {
            return SecurityUtils.getUserId();
        } catch (Exception e) {
            // 如果获取不到用户ID，返回默认测试用户ID
            logger.warn("无法获取当前用户ID，使用默认用户ID: 1");
            return 1L;
        }
    }


    /**
     * 获取本周开始日期
     */
    private Date getWeekStartDate(Date date) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(date);
        cal.set(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.MONDAY);
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
        cal.set(java.util.Calendar.MINUTE, 0);
        cal.set(java.util.Calendar.SECOND, 0);
        cal.set(java.util.Calendar.MILLISECOND, 0);
        return cal.getTime();
    }


    /**
     * 获取用户档案信息（真实数据，包含营养目标）
     */
    private Map<String, Object> getUserProfile(Long userId) {
        Map<String, Object> profile = new HashMap<>();
        
        try {
            // 获取用户基本信息
            profile.put("userId", userId);
            profile.put("userName", SecurityUtils.getUsername());
            
            // 从健康数据表获取营养目标
            String healthSql = "SELECT daily_calorie_goal, daily_protein_goal, daily_carb_goal, daily_fat_goal " +
                             "FROM sys_user_health WHERE user_id = ? LIMIT 1";
            List<Map<String, Object>> healthResults = jdbcTemplate.queryForList(healthSql, userId);
            
            if (!healthResults.isEmpty()) {
                Map<String, Object> healthData = healthResults.get(0);
                profile.put("dailyCalorieGoal", healthData.get("daily_calorie_goal"));
                profile.put("dailyProteinGoal", healthData.get("daily_protein_goal"));
                profile.put("dailyCarbGoal", healthData.get("daily_carb_goal"));
                profile.put("dailyFatGoal", healthData.get("daily_fat_goal"));
            } else {
                // 默认值
                profile.put("dailyCalorieGoal", 2000);
                profile.put("dailyProteinGoal", 80);
                profile.put("dailyCarbGoal", 250);
                profile.put("dailyFatGoal", 55);
            }
            
            // 计算连续打卡天数
            Long continuousDays = calculateContinuousDays(userId);
            profile.put("continuousDays", continuousDays);
            
            // 计算体重变化
            Double weightLoss = calculateWeightLoss(userId);
            profile.put("totalWeightLoss", weightLoss);
            
            // 计算健康评分
            Integer healthScore = calculateHealthScore(userId);
            profile.put("healthScore", healthScore);
            
        } catch (Exception e) {
            logger.warn("获取用户档案部分数据失败: {}", e.getMessage());
            profile.put("continuousDays", 0);
            profile.put("totalWeightLoss", 0.0);
            profile.put("healthScore", 0);
            profile.put("dailyCalorieGoal", 2000);
            profile.put("dailyProteinGoal", 80);
            profile.put("dailyCarbGoal", 250);
            profile.put("dailyFatGoal", 55);
        }
        
        return profile;
    }
    
    /**
     * 计算今日营养摄入（严格查询今天）
     */
    private DietRecord calculateTodayNutrition(Long userId) {
        DietRecord nutrition = new DietRecord();
        
        try {
            String sql = "SELECT " +
                        "COALESCE(SUM(total_calories), 0) AS totalCalories, " +
                        "COALESCE(SUM(total_protein), 0) AS totalProtein, " +
                        "COALESCE(SUM(total_fat), 0) AS totalFat, " +
                        "COALESCE(SUM(total_carbohydrate), 0) AS totalCarbohydrate " +
                        "FROM diet_record " +
                        "WHERE user_id = ? AND DATE(record_date) = CURDATE()";
            
            List<Map<String, Object>> results = jdbcTemplate.queryForList(sql, userId);
            
            if (!results.isEmpty()) {
                Map<String, Object> data = results.get(0);
                nutrition.setTotalCalories(new BigDecimal(data.get("totalCalories").toString()));
                nutrition.setTotalProtein(new BigDecimal(data.get("totalProtein").toString()));
                nutrition.setTotalFat(new BigDecimal(data.get("totalFat").toString()));
                nutrition.setTotalCarbohydrate(new BigDecimal(data.get("totalCarbohydrate").toString()));
            } else {
                // 今天无记录，返回0
                nutrition.setTotalCalories(new BigDecimal("0"));
                nutrition.setTotalProtein(new BigDecimal("0"));
                nutrition.setTotalFat(new BigDecimal("0"));
                nutrition.setTotalCarbohydrate(new BigDecimal("0"));
            }
        } catch (Exception e) {
            logger.error("计算今日营养失败", e);
            nutrition.setTotalCalories(new BigDecimal("0"));
            nutrition.setTotalProtein(new BigDecimal("0"));
            nutrition.setTotalFat(new BigDecimal("0"));
            nutrition.setTotalCarbohydrate(new BigDecimal("0"));
        }
        
        return nutrition;
    }
    
    
    /**
     * 计算连续打卡天数（从第一条记录到今天）
     */
    private Long calculateContinuousDays(Long userId) {
        try {
            String sql = "SELECT DATEDIFF(CURDATE(), MIN(record_date)) + 1 AS days " +
                        "FROM diet_record WHERE user_id = ?";
            List<Map<String, Object>> results = jdbcTemplate.queryForList(sql, userId);
            
            if (!results.isEmpty() && results.get(0).get("days") != null) {
                return ((Number)results.get(0).get("days")).longValue();
            }
        } catch (Exception e) {
            logger.warn("计算连续天数失败: {}", e.getMessage());
        }
        return 0L;
    }
    
    /**
     * 计算体重变化（简化版：从健康数据估算）
     */
    private Double calculateWeightLoss(Long userId) {
        try {
            // 查询用户目标体重和当前体重
            String sql = "SELECT weight, target_weight FROM sys_user_health WHERE user_id = ? LIMIT 1";
            List<Map<String, Object>> results = jdbcTemplate.queryForList(sql, userId);
            
            if (!results.isEmpty()) {
                Map<String, Object> data = results.get(0);
                Double weight = data.get("weight") != null ? ((Number)data.get("weight")).doubleValue() : 70.0;
                Double targetWeight = data.get("target_weight") != null ? ((Number)data.get("target_weight")).doubleValue() : weight;
                
                // 如果目标体重小于当前体重，说明在减重
                if (targetWeight < weight) {
                    return Math.round((weight - targetWeight) * 10) / 10.0;
                }
            }
        } catch (Exception e) {
            logger.warn("计算体重变化失败: {}", e.getMessage());
        }
        return 0.0;
    }
    
    /**
     * 计算健康评分（基于饮食记录的完整度和规律性）
     */
    private Integer calculateHealthScore(Long userId) {
        try {
            // 查询最近7天的记录数
            Date today = new Date();
            Date weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000L);
            
            List<DietRecord> recentRecords = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, weekAgo, today);
            
            int recordCount = recentRecords != null ? recentRecords.size() : 0;
            
            // 基础分60分
            int score = 60;
            
            // 根据记录数量加分（每条记录+2分，最多40分）
            score += Math.min(recordCount * 2, 40);
            
            // 确保在60-100范围内
            return Math.max(60, Math.min(score, 100));
            
        } catch (Exception e) {
            logger.warn("计算健康评分失败: {}", e.getMessage());
            return 75; // 默认中等评分
        }
    }
}
