package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.system.domain.SysUserHealth;
import com.SDR_System.diet.service.ISysUserHealthService;
import com.SDR_System.common.utils.poi.ExcelUtil;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.utils.SecurityUtils;

/**
 * 用户健康信息Controller
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/diet/health")
public class SysUserHealthController extends BaseController
{
    @Autowired
    private ISysUserHealthService sysUserHealthService;
    
    @Autowired
    private org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    /**
     * 查询用户健康信息列表
     */
    @PreAuthorize("@ss.hasPermi('diet:health:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUserHealth sysUserHealth)
    {
        startPage();
        List<SysUserHealth> list = sysUserHealthService.selectSysUserHealthList(sysUserHealth);
        return getDataTable(list);
    }
    
    /**
     * 查询所有用户健康信息（带用户名，管理端用）
     */
    @PreAuthorize("@ss.hasPermi('diet:health:list')")
    @GetMapping("/all")
    public TableDataInfo getAllUserHealth(@RequestParam(required = false) String userName,
                                          @RequestParam(required = false) String healthGoal) {
        try {
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT h.health_id AS healthId, h.user_id AS userId, h.gender, h.age, h.height, h.weight, ");
            sql.append("h.target_weight AS targetWeight, h.health_goal AS healthGoal, h.daily_calorie_goal AS dailyCalorieGoal, ");
            sql.append("h.daily_protein_goal AS dailyProteinGoal, h.daily_fat_goal AS dailyFatGoal, h.daily_carb_goal AS dailyCarbGoal, ");
            sql.append("h.diseases, h.allergies, h.diet_preferences AS dietPreferences, h.create_time AS createTime, h.update_time AS updateTime, ");
            sql.append("u.user_name AS userName ");
            sql.append("FROM sys_user_health h ");
            sql.append("LEFT JOIN sys_user u ON h.user_id = u.user_id ");
            sql.append("WHERE 1=1 ");
            
            if (userName != null && !userName.isEmpty()) {
                sql.append("AND (u.user_name LIKE '%").append(userName).append("%' ");
                sql.append("OR h.user_id = '").append(userName).append("') ");
            }
            if (healthGoal != null && !healthGoal.isEmpty()) {
                sql.append("AND h.health_goal = '").append(healthGoal).append("' ");
            }
            
            sql.append("ORDER BY h.user_id");
            
            List<Map<String, Object>> list = jdbcTemplate.queryForList(sql.toString());
            
            TableDataInfo rspData = new TableDataInfo();
            rspData.setCode(200);
            rspData.setRows(list);
            rspData.setTotal(list.size());
            
            return rspData;
        } catch (Exception e) {
            logger.error("查询用户健康信息失败", e);
            TableDataInfo rspData = new TableDataInfo();
            rspData.setCode(500);
            rspData.setMsg("查询失败");
            return rspData;
        }
    }

    /**
     * 导出用户健康信息列表
     */
    @PreAuthorize("@ss.hasPermi('diet:health:export')")
    @Log(title = "用户健康信息", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, SysUserHealth sysUserHealth)
    {
        List<SysUserHealth> list = sysUserHealthService.selectSysUserHealthList(sysUserHealth);
        ExcelUtil<SysUserHealth> util = new ExcelUtil<SysUserHealth>(SysUserHealth.class);
        util.exportExcel(response, list, "用户健康信息数据");
    }

    /**
     * 获取用户健康信息详细信息
     */
    @PreAuthorize("@ss.hasPermi('diet:health:query')")
    @GetMapping(value = "/{healthId}")
    public AjaxResult getInfo(@PathVariable("healthId") Long healthId)
    {
        return success(sysUserHealthService.selectSysUserHealthByHealthId(healthId));
    }

    /**
     * 获取当前用户的健康信息
     */
    @GetMapping("/my")
    public AjaxResult getMyHealthInfo()
    {
        Long userId = SecurityUtils.getUserId();
        SysUserHealth userHealth = sysUserHealthService.selectSysUserHealthByUserId(userId);
        return success(userHealth);
    }

    /**
     * 新增用户健康信息
     */
    @PreAuthorize("@ss.hasPermi('diet:health:add')")
    @Log(title = "用户健康信息", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysUserHealth sysUserHealth)
    {
        return toAjax(sysUserHealthService.insertSysUserHealth(sysUserHealth));
    }

    /**
     * 保存当前用户的健康信息
     */
    @PostMapping("/my")
    @Log(title = "保存用户健康信息", businessType = BusinessType.UPDATE)
    public AjaxResult saveMyHealthInfo(@RequestBody SysUserHealth sysUserHealth)
    {
        Long userId = SecurityUtils.getUserId();
        sysUserHealth.setUserId(userId);
        
        // 检查是否已存在健康信息
        SysUserHealth existingHealth = sysUserHealthService.selectSysUserHealthByUserId(userId);
        if (existingHealth != null) {
            // 更新现有记录
            sysUserHealth.setHealthId(existingHealth.getHealthId());
            return toAjax(sysUserHealthService.updateSysUserHealth(sysUserHealth));
        } else {
            // 新增记录
            return toAjax(sysUserHealthService.insertSysUserHealth(sysUserHealth));
        }
    }

    /**
     * 修改用户健康信息
     */
    @PreAuthorize("@ss.hasPermi('diet:health:edit')")
    @Log(title = "用户健康信息", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysUserHealth sysUserHealth)
    {
        return toAjax(sysUserHealthService.updateSysUserHealth(sysUserHealth));
    }

    /**
     * 删除用户健康信息
     */
    @PreAuthorize("@ss.hasPermi('diet:health:remove')")
    @Log(title = "用户健康信息", businessType = BusinessType.DELETE)
	@DeleteMapping("/{healthIds}")
    public AjaxResult remove(@PathVariable Long[] healthIds)
    {
        return toAjax(sysUserHealthService.deleteSysUserHealthByHealthIds(healthIds));
    }

    /**
     * 计算用户BMI
     */
    @GetMapping("/bmi")
    public AjaxResult calculateBMI()
    {
        Long userId = SecurityUtils.getUserId();
        Double bmi = sysUserHealthService.calculateUserBMI(userId);
        return success(bmi);
    }

    /**
     * 计算用户每日热量需求
     */
    @GetMapping("/calorie-need")
    public AjaxResult calculateCalorieNeed()
    {
        Long userId = SecurityUtils.getUserId();
        Integer calorieNeed = sysUserHealthService.calculateDailyCalorieNeed(userId);
        return success(calorieNeed);
    }

    /**
     * 获取用户健康评估报告
     */
    @GetMapping("/assessment")
    public AjaxResult getHealthAssessment()
    {
        Long userId = SecurityUtils.getUserId();
        ISysUserHealthService.HealthAssessmentReport report = 
            sysUserHealthService.getHealthAssessmentReport(userId);
        
        if (report == null) {
            return error("请先完善您的健康信息");
        }
        
        return success(report);
    }

    /**
     * 获取指定用户的健康评估报告
     */
    @PreAuthorize("@ss.hasPermi('diet:health:query')")
    @GetMapping("/assessment/{userId}")
    public AjaxResult getHealthAssessmentByUserId(@PathVariable Long userId)
    {
        ISysUserHealthService.HealthAssessmentReport report = 
            sysUserHealthService.getHealthAssessmentReport(userId);
        
        if (report == null) {
            return error("该用户尚未完善健康信息");
        }
        
        return success(report);
    }
}
