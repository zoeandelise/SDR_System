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
            sql.append("a.recognition_date AS recommendationDate, a.recognition_type AS mealType, ");
            sql.append("a.recognition_result AS recommendedFoods, ");
            sql.append("'ML智能推荐-全天方案' AS algorithmType, ");
            sql.append("CASE WHEN a.is_applied = 1 THEN '1' ELSE '2' END AS isAccepted, ");
            sql.append("a.create_time AS createTime, u.user_name AS userName ");
            sql.append("FROM diet_ai_recognition a ");
            sql.append("LEFT JOIN sys_user u ON a.user_id = u.user_id ");
            sql.append("WHERE a.recognition_type = 'ML全天方案' ");
            
            // 添加查询条件
            if (userName != null && !userName.isEmpty()) {
                sql.append("AND (u.user_name LIKE '%").append(userName).append("%' ");
                sql.append("OR a.user_id = ").append(userName).append(") ");
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

