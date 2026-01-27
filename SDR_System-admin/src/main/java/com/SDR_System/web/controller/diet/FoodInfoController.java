package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 食物详细信息Controller
 */
@RestController
@RequestMapping("/api/user/diet")
public class FoodInfoController extends BaseController {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 获取食物详细信息（包含功效）
     */
    @GetMapping("/food-info/{foodId}")
    public AjaxResult getFoodInfo(@PathVariable Long foodId) {
        try {
            String sql = "SELECT f.*, n.suitable_for AS suitableFor, n.unsuitable_for AS unsuitableFor " +
                        "FROM diet_food_info f " +
                        "LEFT JOIN diet_food_nutrition n ON f.food_id = n.food_id " +
                        "WHERE f.food_id = ?";
            
            List<Map<String, Object>> results = jdbcTemplate.queryForList(sql, foodId);
            
            if (results.isEmpty()) {
                return error("食物信息不存在");
            }
            
            return success(results.get(0));
        } catch (Exception e) {
            logger.error("获取食物信息失败", e);
            return error("获取失败：" + e.getMessage());
        }
    }
}

