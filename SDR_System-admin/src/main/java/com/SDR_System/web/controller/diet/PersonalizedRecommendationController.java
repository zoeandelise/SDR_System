package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 个性化健康推荐Controller
 * 
 * @author SDR_System
 */
@RestController
@RequestMapping("/api/user/diet")
public class PersonalizedRecommendationController extends BaseController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 获取个性化推荐（考虑健康约束）
     */
    @PostMapping("/personalized-recommend")
    public AjaxResult getPersonalizedRecommendation(@RequestBody Map<String, Object> params) {
        try {
            Long userId = Long.parseLong(params.get("userId").toString());
            String mealType = params.get("mealType").toString();
            Integer count = Integer.parseInt(params.getOrDefault("count", 10).toString());
            
            // 调用个性化推荐存储过程
            List<Map<String, Object>> recommendations = jdbcTemplate.queryForList(
                "CALL generate_personalized_health_recommendation(?, ?, ?)",
                userId, mealType, count
            );
            
            // 获取用户健康信息用于说明
            String healthSql = "SELECT diseases, allergies, diet_preferences, health_goal " +
                             "FROM sys_user_health WHERE user_id = ?";
            List<Map<String, Object>> healthInfo = jdbcTemplate.queryForList(healthSql, userId);
            
            Map<String, Object> result = new HashMap<>();
            result.put("recommendations", recommendations);
            result.put("healthConstraints", healthInfo.isEmpty() ? null : healthInfo.get(0));
            result.put("message", buildConstraintMessage(healthInfo.isEmpty() ? null : healthInfo.get(0)));
            
            return success(result);
            
        } catch (Exception e) {
            logger.error("个性化推荐失败", e);
            return error("推荐失败：" + e.getMessage());
        }
    }
    
    /**
     * 构建健康约束提示信息
     */
    private String buildConstraintMessage(Map<String, Object> healthInfo) {
        if (healthInfo == null) {
            return "基于通用营养推荐";
        }
        
        StringBuilder msg = new StringBuilder("已应用个性化健康约束：");
        
        String diseases = (String)healthInfo.get("diseases");
        if (diseases != null && !diseases.isEmpty()) {
            if (diseases.contains("高血压")) msg.append("低钠食物优先、");
            if (diseases.contains("糖尿病")) msg.append("低GI食物优先、");
            if (diseases.contains("痛风")) msg.append("低嘌呤食物优先、");
        }
        
        String allergies = (String)healthInfo.get("allergies");
        if (allergies != null && !allergies.isEmpty()) {
            msg.append("已排除过敏食物、");
        }
        
        String preferences = (String)healthInfo.get("diet_preferences");
        if (preferences != null && !preferences.isEmpty()) {
            if (preferences.contains("清淡")) msg.append("清淡食物优先、");
            if (preferences.contains("素食")) msg.append("植物性食物、");
        }
        
        String healthGoal = (String)healthInfo.get("health_goal");
        if ("0".equals(healthGoal)) {
            msg.append("减脂优化（低热量高蛋白）");
        } else if ("1".equals(healthGoal)) {
            msg.append("增肌优化（高蛋白质）");
        } else {
            msg.append("营养均衡");
        }
        
        return msg.toString();
    }
}

