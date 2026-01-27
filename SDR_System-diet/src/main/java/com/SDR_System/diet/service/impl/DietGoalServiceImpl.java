package com.SDR_System.diet.service.impl;

import java.util.List;
import java.util.ArrayList;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.Calendar;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.SDR_System.diet.mapper.DietGoalMapper;
import com.SDR_System.diet.domain.DietGoal;
import com.SDR_System.diet.service.IDietGoalService;

/**
 * 健康目标Service业务层处理
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
public class DietGoalServiceImpl implements IDietGoalService 
{
    @Autowired
    private DietGoalMapper dietGoalMapper;

    /**
     * 查询健康目标
     * 
     * @param goalId 健康目标主键
     * @return 健康目标
     */
    @Override
    public DietGoal selectDietGoalByGoalId(Long goalId)
    {
        return dietGoalMapper.selectDietGoalByGoalId(goalId);
    }

    /**
     * 查询健康目标列表
     * 
     * @param dietGoal 健康目标
     * @return 健康目标
     */
    @Override
    public List<DietGoal> selectDietGoalList(DietGoal dietGoal)
    {
        return dietGoalMapper.selectDietGoalList(dietGoal);
    }

    /**
     * 新增健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    @Override
    public int insertDietGoal(DietGoal dietGoal)
    {
        // 设置初始状态为进行中
        if (dietGoal.getStatus() == null) {
            dietGoal.setStatus("0");
        }
        
        // 计算初始完成百分比
        if (dietGoal.getCurrentValue() != null && dietGoal.getTargetValue() != null 
            && dietGoal.getTargetValue().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal percentage = dietGoal.getCurrentValue()
                .divide(dietGoal.getTargetValue(), 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
            dietGoal.setCompletionPercentage(percentage);
        } else {
            dietGoal.setCompletionPercentage(BigDecimal.ZERO);
        }
        
        dietGoal.setCreateTime(new Date());
        return dietGoalMapper.insertDietGoal(dietGoal);
    }

    /**
     * 修改健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    @Override
    public int updateDietGoal(DietGoal dietGoal)
    {
        // 重新计算完成百分比
        if (dietGoal.getCurrentValue() != null && dietGoal.getTargetValue() != null 
            && dietGoal.getTargetValue().compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal percentage = dietGoal.getCurrentValue()
                .divide(dietGoal.getTargetValue(), 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
            dietGoal.setCompletionPercentage(percentage);
        }
        
        dietGoal.setUpdateTime(new Date());
        return dietGoalMapper.updateDietGoal(dietGoal);
    }

    /**
     * 批量删除健康目标
     * 
     * @param goalIds 需要删除的健康目标主键
     * @return 结果
     */
    @Override
    public int deleteDietGoalByGoalIds(Long[] goalIds)
    {
        return dietGoalMapper.deleteDietGoalByGoalIds(goalIds);
    }

    /**
     * 删除健康目标信息
     * 
     * @param goalId 健康目标主键
     * @return 结果
     */
    @Override
    public int deleteDietGoalByGoalId(Long goalId)
    {
        return dietGoalMapper.deleteDietGoalByGoalId(goalId);
    }

    /**
     * 更新目标进度
     * 
     * @param goalId 目标ID
     * @param currentValue 当前值
     * @return 结果
     */
    @Override
    public int updateGoalProgress(Long goalId, BigDecimal currentValue)
    {
        DietGoal goal = dietGoalMapper.selectDietGoalByGoalId(goalId);
        if (goal == null) {
            throw new RuntimeException("目标不存在");
        }
        
        // 计算完成百分比
        BigDecimal percentage = BigDecimal.ZERO;
        if (goal.getTargetValue() != null && goal.getTargetValue().compareTo(BigDecimal.ZERO) > 0) {
            percentage = currentValue
                .divide(goal.getTargetValue(), 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));
            
            // 限制百分比在0-100之间
            if (percentage.compareTo(BigDecimal.ZERO) < 0) {
                percentage = BigDecimal.ZERO;
            } else if (percentage.compareTo(new BigDecimal("100")) > 0) {
                percentage = new BigDecimal("100");
            }
        }
        
        return dietGoalMapper.updateGoalProgress(goalId, currentValue, percentage);
    }

    /**
     * 获取目标概览
     * 
     * @param userId 用户ID
     * @return 目标概览
     */
    @Override
    public GoalSummary getGoalSummary(Long userId)
    {
        DietGoal query = new DietGoal();
        query.setUserId(userId);
        List<DietGoal> goals = dietGoalMapper.selectDietGoalList(query);
        
        GoalSummary summary = new GoalSummary();
        summary.setTotalGoals(goals.size());
        
        int activeGoals = 0;
        int completedGoals = 0;
        int pausedGoals = 0;
        BigDecimal totalCompletion = BigDecimal.ZERO;
        
        for (DietGoal goal : goals) {
            switch (goal.getStatus()) {
                case "0": // 进行中
                    activeGoals++;
                    break;
                case "1": // 已完成
                    completedGoals++;
                    break;
                case "2": // 已暂停
                    pausedGoals++;
                    break;
            }
            
            if (goal.getCompletionPercentage() != null) {
                totalCompletion = totalCompletion.add(goal.getCompletionPercentage());
            }
        }
        
        summary.setActiveGoals(activeGoals);
        summary.setCompletedGoals(completedGoals);
        summary.setPausedGoals(pausedGoals);
        
        // 计算平均完成度
        if (goals.size() > 0) {
            summary.setAverageCompletion(totalCompletion.divide(new BigDecimal(goals.size()), 2, RoundingMode.HALF_UP));
        } else {
            summary.setAverageCompletion(BigDecimal.ZERO);
        }
        
        // 查询即将到期的目标（7天内）
        List<DietGoal> soonExpireGoals = dietGoalMapper.selectSoonExpireGoals(userId, 7);
        summary.setSoonExpireGoals(soonExpireGoals.size());
        
        return summary;
    }

    /**
     * 获取目标进度历史
     * 
     * @param goalId 目标ID
     * @return 进度历史
     */
    @Override
    public List<GoalProgressHistory> getGoalProgressHistory(Long goalId)
    {
        // TODO: 实现进度历史查询
        // 这里需要一个单独的表来记录进度历史
        List<GoalProgressHistory> history = new ArrayList<>();
        
        // 暂时返回空列表，实际实现需要创建进度历史表
        return history;
    }

    /**
     * 完成目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    @Override
    public int completeGoal(Long goalId)
    {
        return dietGoalMapper.updateGoalStatus(goalId, "1");
    }

    /**
     * 暂停目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    @Override
    public int pauseGoal(Long goalId)
    {
        return dietGoalMapper.updateGoalStatus(goalId, "2");
    }

    /**
     * 恢复目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    @Override
    public int resumeGoal(Long goalId)
    {
        return dietGoalMapper.updateGoalStatus(goalId, "0");
    }
}
