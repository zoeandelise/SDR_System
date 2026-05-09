package com.SDR_System.diet.controller;

import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.diet.domain.DietRecommendation;
import com.SDR_System.diet.service.IDietRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 饮食推荐Controller
 * 
 * @author SDR_System
 */
@RestController
@RequestMapping("/diet/recommendation")
public class DietRecommendationController extends BaseController
{
    @Autowired
    private IDietRecommendationService dietRecommendationService;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 查询饮食推荐列表（联表查询用户信息）
     */
    @PreAuthorize("@ss.hasPermi('diet:recommendation:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(required = false) String userName,
                              @RequestParam(required = false) String startDate,
                              @RequestParam(required = false) String endDate,
                              @RequestParam(required = false) String isAccepted)
    {
        try {
            // 从diet_ai_recognition表查询AI推荐方案
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT a.recognition_id AS recommendationId, a.user_id AS userId, ");
            sql.append("a.recognition_date AS recommendationDate, ");
            sql.append("a.recognition_result AS recommendedFoods, ");
            // Phase 27改动: 不再硬编码，而是通过子查询动态还原历史策略。
            // 查询该AI推荐生成时刻之前，该用户在 diet_recommendation 表中历史采纳(is_accepted = '1')的【不同天数】。
            // 采用 COUNT(DISTINCT DATE(create_time)) 防止单日多次刷单导致阈值被快速耗尽。如果有效天数 < 3，则定性为冷启动。
            sql.append("CASE WHEN (SELECT COUNT(DISTINCT DATE(dr.create_time)) FROM diet_recommendation dr WHERE dr.user_id = a.user_id AND dr.is_accepted = '1' AND dr.create_time < a.create_time) < 3 ");
            sql.append("THEN '中式饮食专家引擎 (冷启动)' ");
            sql.append("ELSE '协同过滤混合推荐引擎' END AS algorithmType, ");
            sql.append("CASE WHEN a.is_applied = 1 THEN '1' ELSE '2' END AS isAccepted, ");
            sql.append("a.create_time AS createTime, u.user_name AS userName ");
            sql.append("FROM diet_ai_recognition a ");
            sql.append("LEFT JOIN sys_user u ON a.user_id = u.user_id ");
            sql.append("WHERE a.recognition_type = 'ML全天方案' ");
            
            // 添加查询条件
            if (userName != null && !userName.isEmpty()) {
                sql.append("AND (u.user_name LIKE '%").append(userName).append("%' ");
                // 防止传入非数字字符串时导致 unknown column 错误
                if (userName.matches("\\d+")) {
                    sql.append("OR a.user_id = ").append(userName).append(") ");
                } else {
                    sql.append(") ");
                }
            }
            if (startDate != null && !startDate.isEmpty()) {
                sql.append("AND a.recognition_date >= '").append(startDate).append("' ");
            }
            if (endDate != null && !endDate.isEmpty()) {
                sql.append("AND a.recognition_date <= '").append(endDate).append("' ");
            }
            if (isAccepted != null && !isAccepted.isEmpty()) {
                if ("1".equals(isAccepted)) {
                    sql.append("AND a.is_applied = 1 ");
                } else {
                    sql.append("AND (a.is_applied = 0 OR a.is_applied IS NULL) ");
                }
            }
            
            sql.append("ORDER BY a.recognition_date DESC, a.recognition_id DESC");
            
            // 执行查询
            List<Map<String, Object>> list = jdbcTemplate.queryForList(sql.toString());
            
            // 返回分页数据
            TableDataInfo rspData = new TableDataInfo();
            rspData.setCode(200);
            rspData.setRows(list);
            rspData.setTotal(list.size());
            
            return rspData;
            
        } catch (Exception e) {
            logger.error("查询推荐方案失败", e);
            TableDataInfo rspData = new TableDataInfo();
            rspData.setCode(500);
            rspData.setMsg("查询失败：" + e.getMessage());
            return rspData;
        }
    }

    /**
     * 删除推荐方案
     */
    @PreAuthorize("@ss.hasPermi('diet:recommendation:remove')")
    @Log(title = "饮食推荐", businessType = BusinessType.DELETE)
    @DeleteMapping("/{recommendationId}")
    public AjaxResult remove(@PathVariable Long recommendationId)
    {
        try {
            String sql = "DELETE FROM diet_ai_recognition WHERE recognition_id = ?";
            jdbcTemplate.update(sql, recommendationId);
            return success("删除成功");
        } catch (Exception e) {
            logger.error("删除失败", e);
            return error("删除失败：" + e.getMessage());
        }
    }
}

