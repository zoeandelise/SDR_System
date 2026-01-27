package com.SDR_System.diet.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.util.*;

/**
 * 智能推荐服务（基于数据库算法）
 * 
 * 功能：调用数据库中的推荐算法函数，生成个性化饮食推荐
 * 算法：营养匹配(70%) + 历史反馈(30%)
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@Service
public class SmartRecommendationService {
    
    private static final Logger logger = LoggerFactory.getLogger(SmartRecommendationService.class);
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 为用户生成个性化推荐 (中式组合推荐)
     * 
     * @param userId 用户ID
     * @param mealType 餐次类型（0=早餐, 1=午餐, 2=晚餐, 3=加餐）
     * @param count 推荐数量
     * @return 推荐结果列表 (每个元素是一个组合，包含 foods 列表)
     */
    public List<Map<String, Object>> generateRecommendation(Long userId, String mealType, Integer count) {
        try {
            logger.info("开始为用户{}生成餐次{}的推荐，数量:{}", userId, mealType, count);
            
            // 调用新的中式推荐存储过程
            String sql = "CALL generate_chinese_diet_recommendation(?, ?, ?)";
            
            List<Map<String, Object>> flatResults = jdbcTemplate.queryForList(sql, userId, mealType, count);
            
            // 将扁平化结果按 combo_id 分组
            Map<Integer, Map<String, Object>> comboMap = new LinkedHashMap<>();
            
            for (Map<String, Object> row : flatResults) {
                Integer comboId = (Integer) row.get("combo_id");
                
                comboMap.computeIfAbsent(comboId, k -> {
                    Map<String, Object> combo = new HashMap<>();
                    combo.put("combo_id", k);
                    combo.put("foods", new ArrayList<Map<String, Object>>());
                    combo.put("total_calories", BigDecimal.ZERO);
                    combo.put("total_protein", BigDecimal.ZERO);
                    combo.put("total_fat", BigDecimal.ZERO);
                    combo.put("total_carbohydrate", BigDecimal.ZERO);
                    return combo;
                });
                
                Map<String, Object> combo = comboMap.get(comboId);
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> foods = (List<Map<String, Object>>) combo.get("foods");
                
                // 添加食物信息
                foods.add(row);
                
                // 累加营养素 (基于份量计算总值)
                BigDecimal portion = new BigDecimal(row.get("portion").toString());
                BigDecimal ratio = portion.divide(new BigDecimal("100"), 4, BigDecimal.ROUND_HALF_UP);
                
                addNutrition(combo, "total_calories", row.get("calories"), ratio);
                addNutrition(combo, "total_protein", row.get("protein"), ratio);
                addNutrition(combo, "total_fat", row.get("fat"), ratio);
                addNutrition(combo, "total_carbohydrate", row.get("carbohydrate"), ratio);
            }
            
            logger.info("推荐生成成功，共{}个组合", comboMap.size());
            return new ArrayList<>(comboMap.values());
            
        } catch (Exception e) {
            logger.error("生成推荐失败", e);
            return Collections.emptyList();
        }
    }

    private void addNutrition(Map<String, Object> combo, String key, Object value, BigDecimal ratio) {
        if (value != null) {
            BigDecimal current = (BigDecimal) combo.get(key);
            BigDecimal per100g = new BigDecimal(value.toString());
            BigDecimal total = per100g.multiply(ratio);
            combo.put(key, current.add(total));
        }
    }
    
    /**
     * 获取用户单餐营养目标
     * 
     * @param userId 用户ID
     * @param mealType 餐次类型
     * @return 营养目标JSON
     */
    public Map<String, Object> getMealNutritionTarget(Long userId, String mealType) {
        try {
            String sql = "SELECT calculate_meal_nutrition_target(?, ?) AS target";
            String jsonResult = jdbcTemplate.queryForObject(sql, String.class, userId, mealType);
            
            // 解析JSON结果
            Map<String, Object> target = new HashMap<>();
            // 简单解析（实际项目可用Jackson或Gson）
            target.put("raw_json", jsonResult);
            
            return target;
            
        } catch (Exception e) {
            logger.error("获取营养目标失败", e);
            return Collections.emptyMap();
        }
    }
    
    /**
     * 计算食物营养匹配度
     * 
     * @param foodNutrition 食物营养数据
     * @param targetNutrition 目标营养数据
     * @return 匹配度评分（0-100）
     */
    public BigDecimal calculateMatchScore(
            Map<String, BigDecimal> foodNutrition,
            Map<String, BigDecimal> targetNutrition) {
        try {
            String sql = "SELECT calculate_nutrition_match_score(?, ?, ?, ?, ?, ?, ?, ?) AS score";
            
            BigDecimal score = jdbcTemplate.queryForObject(sql, BigDecimal.class,
                foodNutrition.get("calories"),
                foodNutrition.get("protein"),
                foodNutrition.get("carb"),
                foodNutrition.get("fat"),
                targetNutrition.get("calories"),
                targetNutrition.get("protein"),
                targetNutrition.get("carb"),
                targetNutrition.get("fat")
            );
            
            return score;
            
        } catch (Exception e) {
            logger.error("计算匹配度失败", e);
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * 批量为多个用户生成推荐（用于每日定时任务）
     * 
     * @param userIds 用户ID列表
     * @param mealType 餐次类型
     * @return 生成结果统计
     */
    public Map<String, Object> batchGenerateRecommendations(List<Long> userIds, String mealType) {
        int successCount = 0;
        int failCount = 0;
        
        for (Long userId : userIds) {
            try {
                List<Map<String, Object>> recommendations = generateRecommendation(userId, mealType, 5);
                if (!recommendations.isEmpty()) {
                    successCount++;
                } else {
                    failCount++;
                }
            } catch (Exception e) {
                logger.error("为用户{}生成推荐失败", userId, e);
                failCount++;
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("total", userIds.size());
        result.put("success", successCount);
        result.put("failed", failCount);
        
        return result;
    }
    
    /**
     * 获取推荐算法统计信息
     * 
     * @return 算法使用统计
     */
    public Map<String, Object> getAlgorithmStats() {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // 统计不同餐次的推荐数量
            String mealCountSql = "SELECT meal_type, COUNT(*) as count FROM diet_recommendation GROUP BY meal_type";
            List<Map<String, Object>> mealCounts = jdbcTemplate.queryForList(mealCountSql);
            stats.put("meal_distribution", mealCounts);
            
            // 统计平均营养匹配度（基于历史记录）
            String avgScoreSql = "SELECT AVG(score) as avg_score FROM diet_recommendation WHERE score IS NOT NULL";
            BigDecimal avgScore = jdbcTemplate.queryForObject(avgScoreSql, BigDecimal.class);
            stats.put("avg_score", avgScore);
            
            // 统计接受率
            String acceptRateSql = 
                "SELECT COUNT(CASE WHEN is_accepted='1' THEN 1 END) * 100.0 / COUNT(*) as rate " +
                "FROM diet_recommendation WHERE is_accepted IS NOT NULL";
            BigDecimal acceptRate = jdbcTemplate.queryForObject(acceptRateSql, BigDecimal.class);
            stats.put("acceptance_rate", acceptRate);
            
        } catch (Exception e) {
            logger.error("获取算法统计失败", e);
        }
        
        return stats;
    }
}
