package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.Map;
import java.math.BigDecimal;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.diet.domain.DietGoal;
import com.SDR_System.diet.service.IDietGoalService;
import com.SDR_System.common.utils.poi.ExcelUtil;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.utils.SecurityUtils;

/**
 * 健康目标控制器
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/diet/goal")
public class DietGoalController extends BaseController
{
    @Autowired
    private IDietGoalService dietGoalService;

    /**
     * 查询健康目标列表
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:list')")
    @GetMapping("/list")
    public TableDataInfo list(DietGoal dietGoal)
    {
        startPage();
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietGoal.setUserId(SecurityUtils.getUserId());
        }
        List<DietGoal> list = dietGoalService.selectDietGoalList(dietGoal);
        return getDataTable(list);
    }

    /**
     * 导出健康目标列表
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:export')")
    @Log(title = "健康目标", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, DietGoal dietGoal)
    {
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietGoal.setUserId(SecurityUtils.getUserId());
        }
        List<DietGoal> list = dietGoalService.selectDietGoalList(dietGoal);
        ExcelUtil<DietGoal> util = new ExcelUtil<DietGoal>(DietGoal.class);
        util.exportExcel(response, list, "健康目标数据");
    }

    /**
     * 获取健康目标详细信息
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:query')")
    @GetMapping(value = "/{goalId}")
    public AjaxResult getInfo(@PathVariable("goalId") Long goalId)
    {
        return AjaxResult.success(dietGoalService.selectDietGoalByGoalId(goalId));
    }

    /**
     * 新增健康目标
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:add')")
    @Log(title = "健康目标", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DietGoal dietGoal)
    {
        dietGoal.setUserId(SecurityUtils.getUserId());
        return toAjax(dietGoalService.insertDietGoal(dietGoal));
    }

    /**
     * 修改健康目标
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:edit')")
    @Log(title = "健康目标", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DietGoal dietGoal)
    {
        return toAjax(dietGoalService.updateDietGoal(dietGoal));
    }

    /**
     * 删除健康目标
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:remove')")
    @Log(title = "健康目标", businessType = BusinessType.DELETE)
	@DeleteMapping("/{goalIds}")
    public AjaxResult remove(@PathVariable Long[] goalIds)
    {
        return toAjax(dietGoalService.deleteDietGoalByGoalIds(goalIds));
    }

    /**
     * 更新目标进度
     */
    @PreAuthorize("@ss.hasPermi('diet:goal:edit')")
    @Log(title = "更新目标进度", businessType = BusinessType.UPDATE)
    @PutMapping("/progress")
    public AjaxResult updateProgress(@RequestBody Map<String, Object> params)
    {
        Long goalId = Long.valueOf(params.get("goalId").toString());
        BigDecimal currentValue = new BigDecimal(params.get("currentValue").toString());
        return toAjax(dietGoalService.updateGoalProgress(goalId, currentValue));
    }

    /**
     * 获取目标概览
     */
    @GetMapping("/summary")
    public AjaxResult getSummary(@org.springframework.web.bind.annotation.RequestParam(required = false) Long userId)
    {
        if (userId == null) {
            userId = SecurityUtils.getUserId();
        } else if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && !SecurityUtils.getUserId().equals(userId)) {
            return error("无权限访问其他用户的数据");
        }
        return AjaxResult.success(dietGoalService.getGoalSummary(userId));
    }

    /**
     * 获取目标进度历史
     */
    @GetMapping("/history/{goalId}")
    public AjaxResult getProgressHistory(@PathVariable Long goalId)
    {
        return AjaxResult.success(dietGoalService.getGoalProgressHistory(goalId));
    }

    /**
     * 完成目标
     */
    @Log(title = "完成目标", businessType = BusinessType.UPDATE)
    @PostMapping("/complete/{goalId}")
    public AjaxResult completeGoal(@PathVariable Long goalId)
    {
        return toAjax(dietGoalService.completeGoal(goalId));
    }

    /**
     * 暂停目标
     */
    @Log(title = "暂停目标", businessType = BusinessType.UPDATE)
    @PostMapping("/pause/{goalId}")
    public AjaxResult pauseGoal(@PathVariable Long goalId)
    {
        return toAjax(dietGoalService.pauseGoal(goalId));
    }

    /**
     * 恢复目标
     */
    @Log(title = "恢复目标", businessType = BusinessType.UPDATE)
    @PostMapping("/resume/{goalId}")
    public AjaxResult resumeGoal(@PathVariable Long goalId)
    {
        return toAjax(dietGoalService.resumeGoal(goalId));
    }
}
