package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
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
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.common.utils.poi.ExcelUtil;
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
    /**
     * 查询健康目标列表
     */
    @GetMapping("/list")
    public TableDataInfo list(@org.springframework.web.bind.annotation.RequestParam(required = false) Long userId)
    {
        startPage();
        
        // 权限控制：非管理员只能查看自己的目标
        if (userId == null) {
            userId = SecurityUtils.getUserId();
        } else if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && !SecurityUtils.getUserId().equals(userId)) {
            return getDataTable(new ArrayList<>()); // 返回空列表
        }
        
        List<Map<String, Object>> list = new ArrayList<>();
        
        // 模拟目标数据（根据用户ID调整）
        Map<String, Object> goal1 = new HashMap<>();
        goal1.put("goalId", 1L);
        goal1.put("userId", userId);
        goal1.put("goalName", "减重10公斤");
        goal1.put("goalType", "减重");
        goal1.put("description", "通过科学饮食和运动，在3个月内健康减重10公斤");
        goal1.put("targetValue", 10.0);
        goal1.put("currentValue", 3.5);
        goal1.put("unit", "公斤");
        goal1.put("startDate", new Date());
        goal1.put("targetDate", new Date(System.currentTimeMillis() + 90L * 24 * 60 * 60 * 1000)); // 90天后
        goal1.put("status", "0");
        goal1.put("priority", "高");
        goal1.put("completionPercentage", 35.0);
        goal1.put("reminderSettings", "每日提醒");
        goal1.put("rewardMechanism", "达成目标奖励新衣服");
        goal1.put("createTime", new Date());
        
        Map<String, Object> goal2 = new HashMap<>();
        goal2.put("goalId", 2L);
        goal2.put("userId", userId);
        goal2.put("goalName", "增加肌肉量");
        goal2.put("goalType", "增肌");
        goal2.put("description", "通过力量训练和高蛋白饮食，增加3公斤肌肉量");
        goal2.put("targetValue", 3.0);
        goal2.put("currentValue", 1.2);
        goal2.put("unit", "公斤");
        goal2.put("startDate", new Date());
        goal2.put("targetDate", new Date(System.currentTimeMillis() + 120L * 24 * 60 * 60 * 1000)); // 120天后
        goal2.put("status", "0");
        goal2.put("priority", "中");
        goal2.put("completionPercentage", 40.0);
        goal2.put("reminderSettings", "每周提醒");
        goal2.put("rewardMechanism", "达成目标奖励健身装备");
        goal2.put("createTime", new Date());
        
        list.add(goal1);
        list.add(goal2);
        
        return getDataTable(list);
    }

    /**
     * 获取健康目标详细信息
     */
    @GetMapping(value = "/{goalId}")
    public AjaxResult getInfo(@PathVariable("goalId") Long goalId)
    {
        Map<String, Object> goal = new HashMap<>();
        goal.put("goalId", goalId);
        goal.put("userId", SecurityUtils.getUserId());
        goal.put("goalName", "减重10公斤");
        goal.put("goalType", "减重");
        goal.put("description", "通过科学饮食和运动，在3个月内健康减重10公斤");
        goal.put("targetValue", 10.0);
        goal.put("currentValue", 3.5);
        goal.put("unit", "公斤");
        goal.put("startDate", new Date());
        goal.put("targetDate", new Date(System.currentTimeMillis() + 90L * 24 * 60 * 60 * 1000));
        goal.put("status", "0");
        goal.put("priority", "高");
        goal.put("completionPercentage", 35.0);
        goal.put("reminderSettings", "每日提醒");
        goal.put("rewardMechanism", "达成目标奖励新衣服");
        goal.put("createTime", new Date());
        
        return AjaxResult.success(goal);
    }

    /**
     * 新增健康目标
     */
    @Log(title = "健康目标", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Map<String, Object> goal)
    {
        goal.put("goalId", System.currentTimeMillis());
        goal.put("userId", SecurityUtils.getUserId());
        goal.put("createTime", new Date());
        goal.put("status", "0");
        goal.put("currentValue", 0.0);
        goal.put("completionPercentage", 0.0);
        
        return AjaxResult.success("健康目标创建成功", goal);
    }

    /**
     * 修改健康目标
     */
    @Log(title = "健康目标", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Map<String, Object> goal)
    {
        goal.put("updateTime", new Date());
        
        // 重新计算完成百分比
        Double targetValue = (Double) goal.get("targetValue");
        Double currentValue = (Double) goal.get("currentValue");
        if (targetValue != null && currentValue != null && targetValue > 0) {
            double percentage = (currentValue / targetValue) * 100;
            goal.put("completionPercentage", Math.min(percentage, 100.0));
        }
        
        return AjaxResult.success("健康目标更新成功", goal);
    }

    /**
     * 删除健康目标
     */
    @Log(title = "健康目标", businessType = BusinessType.DELETE)
    @DeleteMapping("/{goalIds}")
    public AjaxResult remove(@PathVariable Long[] goalIds)
    {
        return AjaxResult.success("删除成功，共删除 " + goalIds.length + " 条记录");
    }

    /**
     * 更新目标进度
     */
    @Log(title = "更新进度", businessType = BusinessType.UPDATE)
    @PutMapping("/progress")
    public AjaxResult updateProgress(@RequestBody Map<String, Object> params)
    {
        Long goalId = Long.valueOf(params.get("goalId").toString());
        Double currentValue = Double.valueOf(params.get("currentValue").toString());
        Double targetValue = Double.valueOf(params.get("targetValue").toString());
        
        double percentage = (currentValue / targetValue) * 100;
        
        Map<String, Object> result = new HashMap<>();
        result.put("goalId", goalId);
        result.put("currentValue", currentValue);
        result.put("completionPercentage", Math.min(percentage, 100.0));
        result.put("updateTime", new Date());
        
        return AjaxResult.success("进度更新成功", result);
    }

    /**
     * 获取目标统计
     */
    @GetMapping("/summary")
    public AjaxResult getSummary(@org.springframework.web.bind.annotation.RequestParam(required = false) Long userId)
    {
        // 权限控制：非管理员只能查看自己的统计
        if (userId == null) {
            userId = SecurityUtils.getUserId();
        } else if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && !SecurityUtils.getUserId().equals(userId)) {
            return error("无权限访问其他用户的数据");
        }
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("userId", userId);
        summary.put("totalGoals", 5);
        summary.put("activeGoals", 3);
        summary.put("completedGoals", 2);
        summary.put("pausedGoals", 0);
        summary.put("averageProgress", 45.6);
        summary.put("thisMonthProgress", 12.3);
        
        // 目标分类统计
        Map<String, Integer> goalTypes = new HashMap<>();
        goalTypes.put("减重", 2);
        goalTypes.put("增肌", 1);
        goalTypes.put("健康饮食", 2);
        summary.put("goalTypes", goalTypes);
        
        // 即将到期的目标
        List<Map<String, Object>> expiringSoon = new ArrayList<>();
        Map<String, Object> expiring = new HashMap<>();
        expiring.put("goalId", 1L);
        expiring.put("goalName", "减重10公斤");
        expiring.put("daysLeft", 15);
        expiring.put("progress", 35.0);
        expiringSoon.add(expiring);
        summary.put("expiringSoon", expiringSoon);
        
        return AjaxResult.success(summary);
    }

    /**
     * 获取进度历史
     */
    @GetMapping("/history/{goalId}")
    public AjaxResult getProgressHistory(@PathVariable Long goalId)
    {
        List<Map<String, Object>> history = new ArrayList<>();
        
        // 模拟历史数据
        for (int i = 0; i < 10; i++) {
            Map<String, Object> record = new HashMap<>();
            record.put("date", new Date(System.currentTimeMillis() - i * 7L * 24 * 60 * 60 * 1000));
            record.put("value", 0.5 * i);
            record.put("percentage", 5.0 * i);
            record.put("note", "第" + (i + 1) + "周进展");
            history.add(record);
        }
        
        return AjaxResult.success(history);
    }

    /**
     * 完成目标
     */
    @Log(title = "完成目标", businessType = BusinessType.UPDATE)
    @PostMapping("/complete/{goalId}")
    public AjaxResult completeGoal(@PathVariable Long goalId)
    {
        Map<String, Object> result = new HashMap<>();
        result.put("goalId", goalId);
        result.put("status", "1");
        result.put("completionPercentage", 100.0);
        result.put("completeTime", new Date());
        result.put("message", "恭喜您完成了这个健康目标！");
        
        return AjaxResult.success("目标完成", result);
    }

    /**
     * 暂停目标
     */
    @Log(title = "暂停目标", businessType = BusinessType.UPDATE)
    @PostMapping("/pause/{goalId}")
    public AjaxResult pauseGoal(@PathVariable Long goalId)
    {
        Map<String, Object> result = new HashMap<>();
        result.put("goalId", goalId);
        result.put("status", "2");
        result.put("pauseTime", new Date());
        result.put("message", "目标已暂停，您可以随时恢复");
        
        return AjaxResult.success("目标已暂停", result);
    }

    /**
     * 恢复目标
     */
    @Log(title = "恢复目标", businessType = BusinessType.UPDATE)
    @PostMapping("/resume/{goalId}")
    public AjaxResult resumeGoal(@PathVariable Long goalId)
    {
        Map<String, Object> result = new HashMap<>();
        result.put("goalId", goalId);
        result.put("status", "0");
        result.put("resumeTime", new Date());
        result.put("message", "目标已恢复，继续加油！");
        
        return AjaxResult.success("目标已恢复", result);
    }

    /**
     * 导出健康目标
     */
    @Log(title = "健康目标", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response)
    {
        List<Map<String, Object>> list = new ArrayList<>();
        // 这里可以添加导出逻辑
        // ExcelUtil<Map<String, Object>> util = new ExcelUtil<Map<String, Object>>(Map.class);
        // util.exportExcel(response, list, "健康目标数据");
    }
}
