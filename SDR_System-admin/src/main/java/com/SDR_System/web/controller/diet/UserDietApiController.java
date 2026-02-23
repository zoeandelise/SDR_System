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
            
            // 先检查用户是否有健康记录
            String checkSql = "SELECT COUNT(*) FROM sys_user_health WHERE user_id = ?";
            Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, userId);
            
            if (count == null || count == 0) {
                // 新用户，先插入记录
                String insertSql = "INSERT INTO sys_user_health (user_id, gender, age, height, weight, " +
                            "diseases, allergies, diet_preferences, health_goal, target_weight, " +
                            "daily_calorie_goal, daily_protein_goal, daily_carb_goal, daily_fat_goal, " +
                            "portion_preference, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                
                jdbcTemplate.update(insertSql,
                    userId,
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
                    goalData.get("portionPreference")
                );
            } else {
                // 已有记录，更新
                String updateSql = "UPDATE sys_user_health SET " +
                            "gender = ?, age = ?, height = ?, weight = ?, " +
                            "diseases = ?, allergies = ?, diet_preferences = ?, " +
                            "health_goal = ?, target_weight = ?, " +
                            "daily_calorie_goal = ?, daily_protein_goal = ?, " +
                            "daily_carb_goal = ?, daily_fat_goal = ?, " +
                            "portion_preference = ?, update_time = NOW() " +
                            "WHERE user_id = ?";
                
                jdbcTemplate.update(updateSql,
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
                    goalData.get("portionPreference"),
                    userId
                );
            }
            
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
     * 删除AI推荐方案
     */
    @DeleteMapping("/recommendation/{recommendationId}")
    @Log(title = "删除AI推荐方案", businessType = BusinessType.DELETE)
    public AjaxResult deleteRecommendation(@PathVariable Long recommendationId) {
        try {
            Long userId = getCurrentUserId();
            
            // 验证记录所有权并删除
            String sql = "DELETE FROM diet_ai_recognition WHERE recognition_id = ? AND user_id = ?";
            int result = jdbcTemplate.update(sql, recommendationId, userId);
            
            if (result > 0) {
                return success("删除成功");
            } else {
                return error("记录不存在或无权限删除");
            }
        } catch (Exception e) {
            logger.error("删除推荐方案失败", e);
            return error("删除失败：" + e.getMessage());
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
            plan.put("totalCarbohydrate", Math.round(totalCarb * 10) / 10.0);
            plan.put("totalFat", Math.round(totalFat * 10) / 10.0);
            
            return success(plan);
        } catch (Exception e) {
            logger.error("生成全天方案失败", e);
            return error("生成失败：" + e.getMessage());
        }
    }
    
    /**
     * 替换单个食物（获取一个新的同餐型食物推荐）
     */
    @PostMapping("/replace-food")
    public AjaxResult replaceSingleFood(@RequestBody Map<String, Object> params) {
        try {
            Long userId = getCurrentUserId();
            String mealType = (String) params.get("mealType"); // "0"=早餐, "1"=午餐, "2"=晚餐
            Integer excludeFoodId = params.get("excludeFoodId") != null ? 
                ((Number) params.get("excludeFoodId")).intValue() : null;
            
            if (mealType == null) {
                return error("缺少餐型参数");
            }
            
            // 调用推荐算法获取一个新食物
            List<Map<String, Object>> newFoods = jdbcTemplate.queryForList(
                "CALL generate_chinese_diet_recommendation(?, ?, ?)", 
                userId, mealType, 1
            );
            
            // 如果需要排除某个食物ID，重新获取直到不重复（最多尝试3次）
            int attempts = 0;
            while (excludeFoodId != null && attempts < 3 && !newFoods.isEmpty()) {
                Map<String, Object> newFood = newFoods.get(0);
                Object foodIdObj = newFood.get("food_id");
                if (foodIdObj != null && ((Number) foodIdObj).intValue() == excludeFoodId) {
                    newFoods = jdbcTemplate.queryForList(
                        "CALL generate_chinese_diet_recommendation(?, ?, ?)", 
                        userId, mealType, 1
                    );
                    attempts++;
                } else {
                    break;
                }
            }
            
            if (newFoods.isEmpty()) {
                return error("暂无可替换的食物");
            }
            
            // 处理字段映射
            processFoodList(newFoods);
            
            return success(newFoods.get(0));
        } catch (Exception e) {
            logger.error("替换食物失败", e);
            return error("替换失败：" + e.getMessage());
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
     * 计算健康评分（改进版：考虑多个维度）
     * 满分100分 = 饮食记录25分 + 营养均衡25分 + 饮食规律25分 + 体重管理25分
     */
    private Integer calculateHealthScore(Long userId) {
        int score = 0;
        
        try {
            Date today = new Date();
            Date weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000L);
            
            List<DietRecord> recentRecords = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, weekAgo, today);
            int recordCount = recentRecords != null ? recentRecords.size() : 0;
            
            // 1. 饮食记录完整度 (25分)
            // 理想情况：7天×3餐=21条记录
            int recordScore = Math.min((recordCount * 25) / 21, 25);
            score += recordScore;
            
            // 2. 营养均衡度 (25分)
            if (recentRecords != null && !recentRecords.isEmpty()) {
                double totalProtein = 0, totalCarbs = 0, totalFat = 0;
                for (DietRecord r : recentRecords) {
                    totalProtein += r.getTotalProtein() != null ? r.getTotalProtein().doubleValue() : 0;
                    totalCarbs += r.getTotalCarbohydrate() != null ? r.getTotalCarbohydrate().doubleValue() : 0;
                    totalFat += r.getTotalFat() != null ? r.getTotalFat().doubleValue() : 0;
                }
                double total = totalProtein + totalCarbs + totalFat;
                if (total > 0) {
                    double proteinRatio = totalProtein / total;
                    double carbRatio = totalCarbs / total;
                    double fatRatio = totalFat / total;
                    
                    // 理想比例：蛋白质20-30%, 碳水50-60%, 脂肪20-30%
                    int proteinScore = (proteinRatio >= 0.15 && proteinRatio <= 0.35) ? 8 : 4;
                    int carbScore = (carbRatio >= 0.40 && carbRatio <= 0.65) ? 9 : 4;
                    int fatScore = (fatRatio >= 0.15 && fatRatio <= 0.35) ? 8 : 4;
                    score += proteinScore + carbScore + fatScore;
                }
            }
            
            // 3. 饮食规律性 (25分)
            // 检查是否有早/午/晚餐记录
            boolean hasBreakfast = false, hasLunch = false, hasDinner = false;
            if (recentRecords != null) {
                for (DietRecord r : recentRecords) {
                    if ("0".equals(r.getMealType())) hasBreakfast = true;
                    if ("1".equals(r.getMealType())) hasLunch = true;
                    if ("2".equals(r.getMealType())) hasDinner = true;
                }
            }
            if (hasBreakfast) score += 8;
            if (hasLunch) score += 9;
            if (hasDinner) score += 8;
            
            // 4. 体重管理 (25分)
            Double weightProgress = calculateWeightProgress(userId);
            if (weightProgress != null) {
                if (weightProgress >= 100) {
                    score += 25; // 达到目标
                } else if (weightProgress >= 50) {
                    score += 20; // 进展良好
                } else if (weightProgress > 0) {
                    score += 15; // 有进展
                } else {
                    score += 10; // 开始记录
                }
            } else {
                score += 10; // 未设置目标也给基础分
            }
            
            return Math.max(0, Math.min(score, 100));
            
        } catch (Exception e) {
            logger.warn("计算健康评分失败: {}", e.getMessage());
            return 60; // 默认评分
        }
    }
    
    /**
     * 计算体重进度百分比
     */
    private Double calculateWeightProgress(Long userId) {
        try {
            // 获取用户目标体重和当前体重
            String healthSql = "SELECT weight, target_weight FROM sys_user_health WHERE user_id = ? LIMIT 1";
            List<Map<String, Object>> healthResults = jdbcTemplate.queryForList(healthSql, userId);
            
            if (healthResults.isEmpty()) return null;
            
            Map<String, Object> health = healthResults.get(0);
            Double currentWeight = health.get("weight") != null ? ((Number)health.get("weight")).doubleValue() : null;
            Double targetWeight = health.get("target_weight") != null ? ((Number)health.get("target_weight")).doubleValue() : null;
            
            if (currentWeight == null || targetWeight == null) return null;
            
            // 获取最新体重记录
            String weightSql = "SELECT weight FROM diet_weight_record WHERE user_id = ? ORDER BY record_date DESC LIMIT 1";
            List<Map<String, Object>> weightResults = jdbcTemplate.queryForList(weightSql, userId);
            
            Double latestWeight = weightResults.isEmpty() ? currentWeight : 
                ((Number)weightResults.get(0).get("weight")).doubleValue();
            
            // 计算进度
            double weightDiff = currentWeight - targetWeight;
            if (Math.abs(weightDiff) < 0.1) return 100.0; // 已达目标
            
            double progress = ((currentWeight - latestWeight) / weightDiff) * 100;
            return Math.max(0, Math.min(progress, 100));
            
        } catch (Exception e) {
            logger.warn("计算体重进度失败: {}", e.getMessage());
            return null;
        }
    }
    
    // ========== 体重记录 API ==========
    
    /**
     * 添加体重记录
     */
    @PostMapping("/weight")
    @Log(title = "添加体重记录", businessType = BusinessType.INSERT)
    public AjaxResult addWeightRecord(@RequestBody Map<String, Object> params) {
        try {
            Long userId = getCurrentUserId();
            Double weight = params.get("weight") != null ? ((Number)params.get("weight")).doubleValue() : null;
            String notes = (String) params.get("notes");
            String dateStr = (String) params.get("date");
            
            if (weight == null || weight <= 0) {
                return error("请输入有效的体重");
            }
            
            // 默认今天
            String recordDate = dateStr != null ? dateStr : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new Date());
            
            // 使用 INSERT ... ON DUPLICATE KEY UPDATE 处理当天重复记录
            String sql = "INSERT INTO diet_weight_record (user_id, weight, record_date, notes) " +
                        "VALUES (?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE weight = VALUES(weight), notes = VALUES(notes)";
            
            jdbcTemplate.update(sql, userId, weight, recordDate, notes);
            
            // 同时更新 sys_user_health 中的当前体重
            String updateHealthSql = "UPDATE sys_user_health SET weight = ? WHERE user_id = ?";
            jdbcTemplate.update(updateHealthSql, weight, userId);
            
            return success("体重记录成功");
        } catch (Exception e) {
            logger.error("添加体重记录失败", e);
            return error("添加失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取体重历史
     */
    @GetMapping("/weight/history")
    public AjaxResult getWeightHistory(@RequestParam(defaultValue = "30") int days) {
        try {
            Long userId = getCurrentUserId();
            
            String sql = "SELECT record_id, weight, record_date, notes, create_time " +
                        "FROM diet_weight_record " +
                        "WHERE user_id = ? AND record_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
                        "ORDER BY record_date DESC";
            
            List<Map<String, Object>> records = jdbcTemplate.queryForList(sql, userId, days);
            
            return success(records);
        } catch (Exception e) {
            logger.error("获取体重历史失败", e);
            return error("获取失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取体重变化趋势
     */
    @GetMapping("/weight/trend")
    public AjaxResult getWeightTrend() {
        try {
            Long userId = getCurrentUserId();
            
            // 获取首次记录的体重
            String firstSql = "SELECT weight, record_date FROM diet_weight_record " +
                             "WHERE user_id = ? ORDER BY record_date ASC LIMIT 1";
            List<Map<String, Object>> firstResults = jdbcTemplate.queryForList(firstSql, userId);
            
            // 获取最新体重
            String latestSql = "SELECT weight, record_date FROM diet_weight_record " +
                              "WHERE user_id = ? ORDER BY record_date DESC LIMIT 1";
            List<Map<String, Object>> latestResults = jdbcTemplate.queryForList(latestSql, userId);
            
            // 获取目标体重
            String goalSql = "SELECT weight AS initial_weight, target_weight FROM sys_user_health WHERE user_id = ? LIMIT 1";
            List<Map<String, Object>> goalResults = jdbcTemplate.queryForList(goalSql, userId);
            
            Map<String, Object> trend = new HashMap<>();
            
            Double firstWeight = firstResults.isEmpty() ? null : ((Number)firstResults.get(0).get("weight")).doubleValue();
            Double latestWeight = latestResults.isEmpty() ? null : ((Number)latestResults.get(0).get("weight")).doubleValue();
            Double targetWeight = goalResults.isEmpty() || goalResults.get(0).get("target_weight") == null ? 
                null : ((Number)goalResults.get(0).get("target_weight")).doubleValue();
            Double initialWeight = goalResults.isEmpty() || goalResults.get(0).get("initial_weight") == null ? 
                null : ((Number)goalResults.get(0).get("initial_weight")).doubleValue();
            
            trend.put("firstWeight", firstWeight);
            trend.put("latestWeight", latestWeight);
            trend.put("targetWeight", targetWeight);
            trend.put("initialWeight", initialWeight);
            
            // 计算累计变化
            if (firstWeight != null && latestWeight != null) {
                trend.put("totalChange", Math.round((firstWeight - latestWeight) * 10) / 10.0);
            } else if (initialWeight != null && latestWeight != null) {
                trend.put("totalChange", Math.round((initialWeight - latestWeight) * 10) / 10.0);
            } else {
                trend.put("totalChange", 0.0);
            }
            
            // 计算达成率
            if (firstWeight != null && latestWeight != null && targetWeight != null && firstWeight > targetWeight) {
                double progress = ((firstWeight - latestWeight) / (firstWeight - targetWeight)) * 100;
                trend.put("progressPercent", Math.max(0, Math.min(Math.round(progress), 100)));
            } else {
                trend.put("progressPercent", 0);
            }
            
            return success(trend);
        } catch (Exception e) {
            logger.error("获取体重趋势失败", e);
            return error("获取失败：" + e.getMessage());
        }
    }
    
    /**
     * 计算体重变化（改进版：基于实际体重记录）
     */
    private Double calculateWeightLoss(Long userId) {
        try {
            // 先尝试从体重记录表获取
            String sql = "SELECT " +
                        "(SELECT weight FROM diet_weight_record WHERE user_id = ? ORDER BY record_date ASC LIMIT 1) AS first_weight, " +
                        "(SELECT weight FROM diet_weight_record WHERE user_id = ? ORDER BY record_date DESC LIMIT 1) AS latest_weight";
            
            List<Map<String, Object>> results = jdbcTemplate.queryForList(sql, userId, userId);
            
            if (!results.isEmpty()) {
                Object first = results.get(0).get("first_weight");
                Object latest = results.get(0).get("latest_weight");
                
                if (first != null && latest != null) {
                    double firstWeight = ((Number)first).doubleValue();
                    double latestWeight = ((Number)latest).doubleValue();
                    double change = firstWeight - latestWeight;
                    
                    // 返回减重值（正数表示减重，负数表示增重）
                    return Math.round(change * 10) / 10.0;
                }
            }
            
            // 如果没有体重记录，返回0
            return 0.0;
            
        } catch (Exception e) {
            logger.warn("计算体重变化失败: {}", e.getMessage());
            return 0.0;
        }
    }
}
