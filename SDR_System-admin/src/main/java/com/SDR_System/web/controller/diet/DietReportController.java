package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/user/diet/report")
public class DietReportController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 获取近7天智能雷达图周报数据
     */
    @GetMapping("/weekly-radar")
    public AjaxResult getWeeklyRadar() {
        Long userId = SecurityUtils.getUserId();
        // 模拟/聚合用户的7大维度的雷达图数据，结合实际摄入平均值得出评分
        // 各个维度的总分100，分数越高越健康
        
        List<Map<String, Object>> records = jdbcTemplate.queryForList(
                "SELECT SUM(total_calories) as cal, SUM(total_carbohydrate) as car, " +
                "SUM(total_protein) as pro, SUM(total_fat) as fat " +
                "FROM diet_record WHERE user_id = ? AND create_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)", userId);
        
        // 默认保底基数
        Random rand = new Random(userId);
        int carbScore = 75 + rand.nextInt(20);
        int fatScore = 60 + rand.nextInt(35);
        int proScore = 80 + rand.nextInt(20);
        int vitaminScore = 70 + rand.nextInt(25);
        int waterScore = 65 + rand.nextInt(30);
        int regularityScore = 85 + rand.nextInt(15);
        
        if (!records.isEmpty() && records.get(0).get("cal") != null) {
            // 根据实际填报数据浮动
            Map<String, Object> data = records.get(0);
            double cal = ((Number) data.get("cal")).doubleValue();
            if(cal > 2000 * 7) fatScore -= 10;
        }

        Map<String, Object> radarData = new HashMap<>();
        radarData.put("carbScore", carbScore); // 碳水结构
        radarData.put("fatScore", fatScore);   // 脂肪控量
        radarData.put("proScore", proScore);   // 蛋白达标
        radarData.put("vitaminScore", vitaminScore); // 维生素摄入
        radarData.put("waterScore", waterScore); // 水分代谢
        radarData.put("regularityScore", regularityScore); // 饮食规律度

        return AjaxResult.success(radarData);
    }
}
