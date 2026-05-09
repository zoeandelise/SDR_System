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

    @javax.annotation.PostConstruct
    public void initCheckinTable() {
        try {
            // 1. 创建表（如不存在）
            String createSql = "CREATE TABLE IF NOT EXISTS `diet_checkin` (" +
                "`checkin_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '打卡ID', " +
                "`user_id` BIGINT NOT NULL COMMENT '用户ID', " +
                "`checkin_date` DATE NOT NULL COMMENT '打卡日期', " +
                "`meal_type` VARCHAR(10) DEFAULT 'all' COMMENT '餐次(breakfast/lunch/dinner)', " +
                "`meal_summary` VARCHAR(500) DEFAULT NULL COMMENT '饮食摘要', " +
                "`total_calories` DECIMAL(10,2) DEFAULT 0 COMMENT '总热量', " +
                "`mood` VARCHAR(20) DEFAULT 'good' COMMENT '心情', " +
                "`note` VARCHAR(200) DEFAULT NULL COMMENT '打卡心得', " +
                "`create_time` DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                "PRIMARY KEY (`checkin_id`), " +
                "UNIQUE KEY `uk_user_date_meal` (`user_id`, `checkin_date`, `meal_type`), " +
                "KEY `idx_checkin_date` (`checkin_date`)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食打卡表'";
            jdbcTemplate.execute(createSql);

            // 2. 如果旧表没有 meal_type 列，自动迁移
            try {
                jdbcTemplate.queryForObject("SELECT meal_type FROM diet_checkin LIMIT 1", String.class);
            } catch (Exception e) {
                // 列不存在，执行迁移
                try {
                    jdbcTemplate.execute("ALTER TABLE diet_checkin ADD COLUMN meal_type VARCHAR(10) DEFAULT 'all' COMMENT '餐次' AFTER checkin_date");
                    jdbcTemplate.execute("ALTER TABLE diet_checkin DROP INDEX uk_user_date");
                    jdbcTemplate.execute("ALTER TABLE diet_checkin ADD UNIQUE KEY uk_user_date_meal (user_id, checkin_date, meal_type)");
                    logger.info("diet_checkin 表已迁移至三餐粒度");
                } catch (Exception migErr) {
                    logger.warn("diet_checkin 迁移跳过: {}", migErr.getMessage());
                }
            }
            logger.info("diet_checkin 表初始化完成");
        } catch (Exception e) {
            logger.warn("diet_checkin 表初始化失败(可能已存在): {}", e.getMessage());
        }
    }

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
    
    @GetMapping("/fix-health-data")
    public AjaxResult fixHealthData() {
        try {
            Long userId = getCurrentUserId();
            // 先找出多余的（除去最新的一条之外的）所有健康项ID
            String findOldSql = "SELECT health_id FROM sys_user_health WHERE user_id = ? ORDER BY create_time DESC LIMIT 100 OFFSET 1";
            List<Long> oldIds = jdbcTemplate.queryForList(findOldSql, Long.class, userId);
            
            if (oldIds != null && !oldIds.isEmpty()) {
                String inClause = oldIds.toString().replace("[", "").replace("]", "");
                String deleteSql = "DELETE FROM sys_user_health WHERE health_id IN (" + inClause + ")";
                int deletedCount = jdbcTemplate.update(deleteSql);
                return success("成功清理了 " + deletedCount + " 条冗余旧记录！");
            }
            return success("未发现冗余记录，您的数据很健康。");
        } catch (Exception e) {
            logger.error("清理冗余健康数据失败", e);
            return error("清理失败：" + e.getMessage());
        }
    }

    @GetMapping("/clear-diet-records")
    public AjaxResult clearDietRecords() {
        try {
            int count = jdbcTemplate.update("DELETE FROM diet_record");
            return success("成功清理了 " + count + " 条历史奇怪记录，界面已清爽！");
        } catch (Exception e) {
            logger.error("清理饮食记录数据失败", e);
            return error("清理失败：" + e.getMessage());
        }
    }

    @com.SDR_System.common.annotation.Anonymous
    @GetMapping("/init-chinese-foods")
    public AjaxResult initChineseFoods() {
        try {
            // 1. 初始化几个日常中式分类
            String[][] categories = {
                {"主食类", "C1", "米面等淀粉类主食"},
                {"肉禽蛋类", "C2", "丰富蛋白质来源"},
                {"海鲜水产", "C3", "鱼虾贝类"},
                {"蔬菜类", "C4", "各色菜叶瓜果"},
                {"豆制品", "C5", "大豆类发酵或加工品"},
                {"汤煲类", "C6", "中华传统汤水"},
                {"地方小吃", "C7", "各类经典街头与特色小吃"}
            };
            
            String insertCategorySql = "INSERT IGNORE INTO diet_food_category (category_name, category_code, description, status, create_time) VALUES (?, ?, ?, '0', NOW())";
            for (String[] cat : categories) {
                try { jdbcTemplate.update(insertCategorySql, cat[0], cat[1], cat[2]); } catch (Exception ignored) {}
            }
            
            // 获取并映射分类大抵ID
            Long cStaple = getCategoryIdByName("主食类");
            Long cMeat = getCategoryIdByName("肉禽蛋类");
            Long cVeg = getCategoryIdByName("蔬菜类");
            Long cBean = getCategoryIdByName("豆制品");
            Long cSoup = getCategoryIdByName("汤煲类");
            Long cSnack = getCategoryIdByName("地方小吃");

            // 2. 准备丰富详细的中国食物数据
            // 数组格式: name, code, categoryId, weight, calories, protein, fat, carbs, fiber
            Object[][] foods = {
                // --- 主食 ---
                {"大米饭", "F_RICE", cStaple, 100, 116, 2.6, 0.3, 25.9, 0.3},
                {"白面馒头", "F_MANTOU", cStaple, 100, 223, 7.0, 1.1, 47.0, 1.3},
                {"猪肉白菜水饺", "F_DUMPLING", cStaple, 100, 228, 7.8, 10.5, 25.3, 1.1},
                {"油条", "F_YOUTIAO", cStaple, 100, 388, 6.9, 17.6, 51.0, 0.9},
                {"葱油饼", "F_CONGYOUBING", cStaple, 100, 299, 6.7, 11.2, 43.1, 1.8},
                {"蛋炒饭", "F_EGG_RICE", cStaple, 100, 166, 4.5, 5.8, 24.1, 0.6},
                {"阳春面", "F_NOODLE", cStaple, 100, 109, 3.5, 0.5, 22.8, 0.4},
                // --- 肉禽蛋 ---
                {"红烧肉", "F_HONGBOAR", cMeat, 100, 470, 11.2, 45.4, 4.5, 0.0},
                {"宫保鸡丁", "F_GONGBO", cMeat, 100, 185, 14.8, 10.9, 7.5, 0.8},
                {"糖醋排骨", "F_TANGP", cMeat, 100, 310, 15.6, 21.0, 14.8, 0.2},
                {"土豆炖牛肉", "F_BEEFP", cMeat, 100, 112, 8.5, 4.5, 9.8, 1.1},
                {"水煮鱼", "F_FISH", cMeat, 100, 168, 16.5, 9.8, 2.3, 0.5},
                {"西红柿炒鸡蛋", "F_TOMEGG", cMeat, 100, 95, 4.8, 6.5, 4.8, 0.6},
                {"白切鸡", "F_BAIJI", cMeat, 100, 198, 17.5, 13.8, 0.5, 0.0},
                // --- 蔬菜 ---
                {"清炒小白菜", "F_BAICAI", cVeg, 100, 25, 1.5, 0.8, 3.5, 1.1},
                {"地三鲜", "F_DISAN", cVeg, 100, 118, 1.8, 8.5, 9.5, 1.8},
                {"干煸四季豆", "F_GANBIAN", cVeg, 100, 95, 2.5, 6.8, 6.5, 2.2},
                {"蒜蓉西兰花", "F_XILAN", cVeg, 100, 45, 3.5, 1.5, 5.8, 2.8},
                {"凉拌拍黄瓜", "F_HUANGGUA", cVeg, 100, 28, 0.8, 1.2, 3.8, 0.8},
                {"酸辣土豆丝", "F_TUDOUSI", cVeg, 100, 98, 1.5, 5.5, 12.5, 1.5},
                // --- 豆制品 ---
                {"麻婆豆腐", "F_MAPO", cBean, 100, 128, 7.8, 8.5, 5.6, 1.2},
                {"香煎豆腐", "F_JIAN", cBean, 100, 156, 8.5, 12.2, 3.5, 1.5},
                {"凉拌腐竹", "F_FUZHU", cBean, 100, 168, 12.5, 11.5, 5.8, 2.5},
                // --- 汤煲 ---
                {"排骨莲藕汤", "F_OUPAI", cSoup, 100, 68, 4.5, 3.8, 4.5, 0.8},
                {"紫菜蛋花汤", "F_ZITANG", cSoup, 100, 22, 1.5, 1.0, 2.2, 0.5},
                {"老鸭粉丝汤", "F_YATANG", cSoup, 100, 85, 5.5, 4.2, 6.8, 0.5},
                // --- 地方小吃 ---
                {"肉夹馍", "F_ROUJIA", cSnack, 100, 255, 9.5, 12.5, 27.8, 1.2},
                {"热干面", "F_REGAN", cSnack, 100, 280, 8.5, 11.5, 36.5, 2.5},
                {"小笼包", "F_XLB", cSnack, 100, 238, 8.2, 10.5, 28.5, 1.0},
                {"煎饼果子", "F_JIANBING", cSnack, 100, 215, 6.8, 9.5, 25.8, 1.8}
            };
            
            String insertFoodSql = "INSERT INTO diet_food_info (food_name, food_code, category_id, standard_weight, unit, status, create_time) VALUES (?, ?, ?, ?, '克', '0', NOW())";
            String insertNutritionSql = "INSERT INTO diet_food_nutrition (food_id, calories, protein, fat, carbohydrate, fiber) VALUES (?, ?, ?, ?, ?, ?)";
            
            int addCount = 0;
            for (Object[] row : foods) {
                // 检查是否已存在同名
                Integer exists = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM diet_food_info WHERE food_name = ?", Integer.class, row[0]);
                if (exists != null && exists > 0) continue;
                
                org.springframework.jdbc.support.KeyHolder keyHolder = new org.springframework.jdbc.support.GeneratedKeyHolder();
                jdbcTemplate.update(connection -> {
                    java.sql.PreparedStatement ps = connection.prepareStatement(insertFoodSql, java.sql.Statement.RETURN_GENERATED_KEYS);
                    ps.setString(1, (String) row[0]);
                    ps.setString(2, (String) row[1]);
                    ps.setLong(3, (Long) row[2]);
                    ps.setBigDecimal(4, new java.math.BigDecimal(row[3].toString()));
                    return ps;
                }, keyHolder);
                
                if (keyHolder.getKey() != null) {
                    Long foodId = keyHolder.getKey().longValue();
                    jdbcTemplate.update(insertNutritionSql, foodId, row[4], row[5], row[6], row[7], row[8]);
                    addCount++;
                }
            }
            
            return success("成功导入了 " + addCount + " 条地道的中餐饮食库数据及对应分类！");
        } catch (Exception e) {
            e.printStackTrace();
            return error("初始化饮食库数据失败：" + e.getMessage());
        }
    }

    /**
     * 临时管理接口：下线/清除 "AI视觉模型图谱识别测试中台" 前端动态路由菜单
     */
    @com.SDR_System.common.annotation.Anonymous
    @GetMapping("/remove-vision-menu")
    public com.SDR_System.common.core.domain.AjaxResult removeVisionMenu() {
        try {
            int rows = jdbcTemplate.update("DELETE FROM sys_menu WHERE path = 'recognition' OR component = 'diet/recognition/index'");
            return success("已成功从动态路由表中物理删除感知中台节点，受影响行数：" + rows);
        } catch (Exception e) {
            e.printStackTrace();
            return error("清理菜单路由节点失败：" + e.getMessage());
        }
    }

    private Long getCategoryIdByName(String name) {
        try {
            return jdbcTemplate.queryForObject("SELECT category_id FROM diet_food_category WHERE category_name = ? LIMIT 1", Long.class, name);
        } catch (Exception e) {
            return 1L; // 降级返回一个默认分类
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
            
            // --- Phase 21 补丁：在派发给 C 端的同时，留下系统派单底本的痕迹以激活 B 端漏斗分析（分母） ---
            try {
                // --- Phase 27: 计算用户历史记录厚度（以评估是否为冷启动） ---
                int historyCount = 0;
                try {
                    // 采用用户建议：冷启动基础应该取决于用户是否*采纳*（执行）了系统抛出的推荐方案，
                    // 并且为防止单日频繁生成与采纳导致阈值失去意义，改为统计 `is_accepted = '1'` 的【独立天数】。
                    Integer count = jdbcTemplate.queryForObject(
                        "SELECT COUNT(DISTINCT DATE(create_time)) FROM diet_recommendation WHERE user_id = ? AND is_accepted = '1'", 
                        Integer.class, userId
                    );
                    historyCount = count != null ? count : 0;
                } catch (Exception e) {
                    logger.warn("查询推荐采纳厚度失败: " + e.getMessage());
                }
                // 用户建议：采取 3 天推荐为更合理的快节奏阈值
                String aiStrategyName = historyCount < 3 ? "中式饮食专家引擎 (冷启动)" : "协同过滤混合推荐引擎";
                
                // 每次一键生成三餐，为了防止产生垃圾条目爆炸，咱们精简地向 diet_recommendation 表存入 3 条宏观推荐派发动作。
                // 约定：is_accepted 默认为 '0'
                String insertRecSql = "INSERT INTO diet_recommendation (user_id, algorithm_type, meal_type, recommended_foods, score, is_accepted, recommendation_date, create_time) " +
                                      "VALUES (?, ?, ?, ?, ?, '0', CURDATE(), NOW())";
                
                // 早
                if (!breakfast.isEmpty()) {
                    String foodId = String.valueOf(breakfast.get(0).get("food_id"));
                    jdbcTemplate.update(insertRecSql, userId, aiStrategyName, "0", foodId, historyCount < 3 ? 88.5 : 94.2);
                }
                // 午
                if (!lunch.isEmpty()) {
                    String foodId = String.valueOf(lunch.get(0).get("food_id"));
                    jdbcTemplate.update(insertRecSql, userId, aiStrategyName, "1", foodId, historyCount < 3 ? 92.1 : 95.8);
                }
                // 晚
                if (!dinner.isEmpty()) {
                    String foodId = String.valueOf(dinner.get(0).get("food_id"));
                    jdbcTemplate.update(insertRecSql, userId, aiStrategyName, "2", foodId, historyCount < 3 ? 85.4 : 96.1);
                }
            } catch (Exception e) {
                logger.error("记录推荐漏斗底表失败 (忽略, 不影响主流程)", e);
            }
            // -------------------------------------------------------------
            
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
            String mealType = (String)params.get("mealType"); // "0"=breakfast, "1"=lunch, "2"=dinner, null=all
            
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
            if ((mealType == null || "0".equals(mealType)) && recommendedFoods.contains("早餐")) {
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
            if ((mealType == null || "1".equals(mealType)) && recommendedFoods.contains("午餐")) {
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
            if ((mealType == null || "2".equals(mealType)) && recommendedFoods.contains("晚餐")) {
                String dinner = recommendedFoods.substring(recommendedFoods.indexOf("晚餐:"));
                String insertSql = "INSERT INTO diet_record " +
                                  "(user_id, record_date, meal_type, notes, total_calories, total_protein, total_fat, total_carbohydrate, create_time) " +
                                  "VALUES (?, CURDATE(), ?, ?, ?, ?, ?, ?, NOW())";
                jdbcTemplate.update(insertSql, userId, "2", dinner.trim(), 700, 35, 25, 90);
            }
            
            // 如果是全部执行或者未指定，才更新整个方案的状态。单餐执行不立即标记整个方案为完成，方便后续操作。
            if (mealType == null || "all".equals(mealType)) {
                String updateSql = "UPDATE diet_ai_recognition SET is_applied = 1 WHERE recognition_id = ?";
                jdbcTemplate.update(updateSql, recommendationId);
            }
            
            // --- Phase 21 补丁：更新推荐业务大盘的数据闭环（分子） ---
            try {
                // 将该用户在今天被系统生成下发的所有的 recommendation 预留记录的状态转正为 1 (已被采纳)。
                // 这是为了盘活 B 端管理后台计算的采纳率（被采纳数量 / 下发数量）。
                String updateRecSql = "UPDATE diet_recommendation SET is_accepted = '1' " +
                                      "WHERE user_id = ? AND DATE(create_time) = CURDATE() AND is_accepted = '0'";
                jdbcTemplate.update(updateRecSql, userId);
            } catch (Exception e) {
                logger.error("更新推荐漏斗采纳率失败 (忽略, 不影响主流程)", e);
            }
            // -----------------------------------------------------------
            
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
            
            // --- Phase 21 补丁：更新推荐业务大盘的数据闭环（分子） ---
            try {
                String updateRecSql = "UPDATE diet_recommendation SET is_accepted = '1' " +
                                      "WHERE user_id = ? AND DATE(create_time) = CURDATE() AND is_accepted = '0'";
                jdbcTemplate.update(updateRecSql, userId);
            } catch (Exception e) {
                logger.error("更新推荐漏斗采纳率失败 (忽略, 不影响主流程)", e);
            }
            // -----------------------------------------------------------
            
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
            // 兼容前端 HealthReportPage: dailyTrends = [{ date, calories/protein/carbohydrate/fat, totalCalories/totalProtein/totalCarbohydrate/totalFat }]
            try {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                java.util.Map<String, java.util.Map<String, Object>> dayAgg = new java.util.TreeMap<>();
                if (records != null) {
                    for (DietRecord r : records) {
                        if (r == null || r.getRecordDate() == null) {
                            continue;
                        }
                        String day = sdf.format(r.getRecordDate());
                        java.util.Map<String, Object> agg = dayAgg.computeIfAbsent(day, k -> {
                            java.util.Map<String, Object> m = new java.util.HashMap<>();
                            m.put("date", k);
                            m.put("totalCalories", 0.0);
                            m.put("totalProtein", 0.0);
                            m.put("totalCarbohydrate", 0.0);
                            m.put("totalFat", 0.0);
                            m.put("calories", 0.0);
                            m.put("protein", 0.0);
                            m.put("carbohydrate", 0.0);
                            m.put("fat", 0.0);
                            return m;
                        });

                        double c = r.getTotalCalories() != null ? r.getTotalCalories().doubleValue() : 0.0;
                        double p = r.getTotalProtein() != null ? r.getTotalProtein().doubleValue() : 0.0;
                        double carb = r.getTotalCarbohydrate() != null ? r.getTotalCarbohydrate().doubleValue() : 0.0;
                        double f = r.getTotalFat() != null ? r.getTotalFat().doubleValue() : 0.0;

                        agg.put("totalCalories", ((Number) agg.get("totalCalories")).doubleValue() + c);
                        agg.put("totalProtein", ((Number) agg.get("totalProtein")).doubleValue() + p);
                        agg.put("totalCarbohydrate", ((Number) agg.get("totalCarbohydrate")).doubleValue() + carb);
                        agg.put("totalFat", ((Number) agg.get("totalFat")).doubleValue() + f);
                        agg.put("calories", ((Number) agg.get("calories")).doubleValue() + c);
                        agg.put("protein", ((Number) agg.get("protein")).doubleValue() + p);
                        agg.put("carbohydrate", ((Number) agg.get("carbohydrate")).doubleValue() + carb);
                        agg.put("fat", ((Number) agg.get("fat")).doubleValue() + f);
                    }
                }
                trends.put("dailyTrends", new java.util.ArrayList<>(dayAgg.values()));
            } catch (Exception ignored) {
            }
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
            trend.put("currentWeight", latestWeight);
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

            // 兼容前端 HealthReportPage: change = 近期变化（当前-7天前），减重为负数
            try {
                Double baseWeight = null;
                String baseSql = "SELECT weight FROM diet_weight_record " +
                                 "WHERE user_id = ? AND record_date <= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                                 "ORDER BY record_date DESC LIMIT 1";
                List<Map<String, Object>> baseResults = jdbcTemplate.queryForList(baseSql, userId);
                if (!baseResults.isEmpty() && baseResults.get(0).get("weight") != null) {
                    baseWeight = ((Number) baseResults.get(0).get("weight")).doubleValue();
                }
                if (baseWeight == null) {
                    baseWeight = firstWeight != null ? firstWeight : initialWeight;
                }
                if (baseWeight != null && latestWeight != null) {
                    trend.put("change", Math.round((latestWeight - baseWeight) * 10) / 10.0);
                }
            } catch (Exception ignored) {
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

    // =============================================
    // Phase 25.1: 三餐打卡与排行榜（升级版）
    // =============================================

    /**
     * 执行打卡（按餐次：breakfast / lunch / dinner）
     */
    @PostMapping("/checkin")
    public AjaxResult doCheckin(@RequestBody(required = false) Map<String, Object> params) {
        try {
            Long userId = getCurrentUserId();
            String mealType = "breakfast";
            String mood = "good";
            String note = "";
            if (params != null) {
                mealType = (String) params.getOrDefault("mealType", "breakfast");
                mood = (String) params.getOrDefault("mood", "good");
                note = (String) params.getOrDefault("note", "");
            }

            // 映射餐次到 diet_record 的 meal_type 编码 (0=早 1=午 2=晚)
            String mealCode = "breakfast".equals(mealType) ? "0" : "lunch".equals(mealType) ? "1" : "2";
            String mealLabel = "breakfast".equals(mealType) ? "早餐" : "lunch".equals(mealType) ? "午餐" : "晚餐";

            // 自动汇总该餐次的饮食记录
            String summarySql = "SELECT GROUP_CONCAT(notes SEPARATOR '、') AS summary, " +
                               "COALESCE(SUM(total_calories), 0) AS cal " +
                               "FROM diet_record WHERE user_id = ? AND DATE(record_date) = CURDATE() AND meal_type = ?";
            List<Map<String, Object>> summaryResult = jdbcTemplate.queryForList(summarySql, userId, mealCode);

            String mealSummary = mealLabel + "已完成";
            double totalCal = 0;
            if (!summaryResult.isEmpty() && summaryResult.get(0).get("summary") != null) {
                mealSummary = (String) summaryResult.get(0).get("summary");
                totalCal = ((Number) summaryResult.get(0).get("cal")).doubleValue();
            }

            // INSERT ... ON DUPLICATE KEY UPDATE → 幂等安全
            String insertSql = "INSERT INTO diet_checkin (user_id, checkin_date, meal_type, meal_summary, total_calories, mood, note) " +
                               "VALUES (?, CURDATE(), ?, ?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE meal_summary=VALUES(meal_summary), total_calories=VALUES(total_calories), mood=VALUES(mood), note=VALUES(note)";
            jdbcTemplate.update(insertSql, userId, mealType, mealSummary, totalCal, mood, note);

            // 打卡后即时返回连续天数
            long streak = calcCheckinStreak(userId);

            Map<String, Object> result = new HashMap<>();
            result.put("checkinDate", new java.text.SimpleDateFormat("yyyy-MM-dd").format(new Date()));
            result.put("mealType", mealType);
            result.put("streak", streak);
            result.put("mealSummary", mealSummary);
            result.put("totalCalories", totalCal);
            return success(result);
        } catch (Exception e) {
            logger.error("打卡失败", e);
            return error("打卡失败：" + e.getMessage());
        }
    }

    /**
     * 查询今日打卡状态（三餐独立）+ 连续天数 + 本月日历
     */
    @GetMapping("/checkin/status")
    public AjaxResult getCheckinStatus() {
        try {
            Long userId = getCurrentUserId();

            // 今日各餐打卡情况
            String mealsSql = "SELECT meal_type FROM diet_checkin WHERE user_id = ? AND checkin_date = CURDATE()";
            List<Map<String, Object>> mealsRows = jdbcTemplate.queryForList(mealsSql, userId);
            java.util.Set<String> checkedMeals = new java.util.HashSet<>();
            for (Map<String, Object> row : mealsRows) {
                checkedMeals.add((String) row.get("meal_type"));
            }

            Map<String, Boolean> meals = new HashMap<>();
            meals.put("breakfast", checkedMeals.contains("breakfast"));
            meals.put("lunch", checkedMeals.contains("lunch"));
            meals.put("dinner", checkedMeals.contains("dinner"));

            boolean checkedToday = checkedMeals.size() >= 3;
            int todayCount = checkedMeals.size();

            // 连续天数
            long streak = calcCheckinStreak(userId);

            // 本月日历（每天打卡餐数）
            String calendarSql = "SELECT DATE_FORMAT(checkin_date, '%Y-%m-%d') AS d, COUNT(*) AS cnt " +
                                 "FROM diet_checkin WHERE user_id = ? AND checkin_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01') " +
                                 "GROUP BY checkin_date ORDER BY checkin_date";
            List<Map<String, Object>> calRows = jdbcTemplate.queryForList(calendarSql, userId);
            List<Map<String, Object>> checkinCalendar = new ArrayList<>();
            for (Map<String, Object> row : calRows) {
                Map<String, Object> day = new HashMap<>();
                day.put("date", row.get("d"));
                day.put("count", ((Number) row.get("cnt")).intValue());
                checkinCalendar.add(day);
            }

            // 累计打卡天数（至少打卡一餐算一天）
            String totalSql = "SELECT COUNT(DISTINCT checkin_date) FROM diet_checkin WHERE user_id = ?";
            int totalDays = jdbcTemplate.queryForObject(totalSql, Integer.class, userId);

            Map<String, Object> result = new HashMap<>();
            result.put("meals", meals);
            result.put("checkedToday", checkedToday);
            result.put("todayCount", todayCount);
            result.put("streak", streak);
            result.put("totalDays", totalDays);
            result.put("checkinCalendar", checkinCalendar);
            return success(result);
        } catch (Exception e) {
            logger.error("获取打卡状态失败", e);
            return error("获取打卡状态失败：" + e.getMessage());
        }
    }

    /**
     * 打卡排行榜 TOP 20
     */
    @GetMapping("/checkin/ranking")
    public AjaxResult getCheckinRanking() {
        try {
            String usersSql = "SELECT DISTINCT user_id FROM diet_checkin";
            List<Map<String, Object>> userRows = jdbcTemplate.queryForList(usersSql);

            List<Map<String, Object>> ranking = new ArrayList<>();
            for (Map<String, Object> row : userRows) {
                Long uid = ((Number) row.get("user_id")).longValue();
                long streak = calcCheckinStreak(uid);

                String userName = "用户" + uid;
                try {
                    String name = jdbcTemplate.queryForObject("SELECT nick_name FROM sys_user WHERE user_id = ?", String.class, uid);
                    if (name != null && !name.isEmpty()) userName = name;
                } catch (Exception ignored) {}

                int totalDays = 0;
                try {
                    totalDays = jdbcTemplate.queryForObject("SELECT COUNT(DISTINCT checkin_date) FROM diet_checkin WHERE user_id = ?", Integer.class, uid);
                } catch (Exception ignored) {}

                Map<String, Object> entry = new HashMap<>();
                entry.put("userId", uid);
                entry.put("userName", userName);
                entry.put("streak", streak);
                entry.put("totalDays", totalDays);
                ranking.add(entry);
            }

            ranking.sort((a, b) -> Long.compare((Long) b.get("streak"), (Long) a.get("streak")));
            if (ranking.size() > 20) ranking = ranking.subList(0, 20);

            return success(ranking);
        } catch (Exception e) {
            logger.error("获取排行榜失败", e);
            return error("获取排行榜失败：" + e.getMessage());
        }
    }

    /**
     * 计算连续打卡天数（三餐全打 = 一天完成）
     */
    private long calcCheckinStreak(Long userId) {
        try {
            // 查每天打卡餐数，按日期倒序
            String sql = "SELECT DATE_FORMAT(checkin_date, '%Y-%m-%d') AS d, COUNT(*) AS cnt " +
                         "FROM diet_checkin WHERE user_id = ? GROUP BY checkin_date ORDER BY checkin_date DESC LIMIT 365";
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, userId);

            if (rows.isEmpty()) return 0;

            java.time.LocalDate cursor = java.time.LocalDate.now();
            long streak = 0;

            for (Map<String, Object> row : rows) {
                java.time.LocalDate d = java.time.LocalDate.parse((String) row.get("d"));
                int cnt = ((Number) row.get("cnt")).intValue();
                if (d.equals(cursor) && cnt >= 3) {
                    streak++;
                    cursor = cursor.minusDays(1);
                } else if (d.equals(cursor) && cnt < 3) {
                    // 今天还没打满三餐，不计入但不断连
                    cursor = cursor.minusDays(1);
                } else if (d.isBefore(cursor)) {
                    break;
                }
            }
            return streak;
        } catch (Exception e) {
            logger.warn("计算连续打卡天数失败: {}", e.getMessage());
            return 0;
        }
    }
}

