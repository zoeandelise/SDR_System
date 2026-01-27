package com.SDR_System.diet.service;

import java.util.List;
import java.math.BigDecimal;
import java.util.Date;
import com.SDR_System.diet.domain.DietGoal;

/**
 * 健康目标Service接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IDietGoalService 
{
    /**
     * 查询健康目标
     * 
     * @param goalId 健康目标主键
     * @return 健康目标
     */
    public DietGoal selectDietGoalByGoalId(Long goalId);

    /**
     * 查询健康目标列表
     * 
     * @param dietGoal 健康目标
     * @return 健康目标集合
     */
    public List<DietGoal> selectDietGoalList(DietGoal dietGoal);

    /**
     * 新增健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    public int insertDietGoal(DietGoal dietGoal);

    /**
     * 修改健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    public int updateDietGoal(DietGoal dietGoal);

    /**
     * 批量删除健康目标
     * 
     * @param goalIds 需要删除的健康目标主键集合
     * @return 结果
     */
    public int deleteDietGoalByGoalIds(Long[] goalIds);

    /**
     * 删除健康目标信息
     * 
     * @param goalId 健康目标主键
     * @return 结果
     */
    public int deleteDietGoalByGoalId(Long goalId);

    /**
     * 更新目标进度
     * 
     * @param goalId 目标ID
     * @param currentValue 当前值
     * @return 结果
     */
    public int updateGoalProgress(Long goalId, BigDecimal currentValue);

    /**
     * 获取目标概览
     * 
     * @param userId 用户ID
     * @return 目标概览
     */
    public GoalSummary getGoalSummary(Long userId);

    /**
     * 获取目标进度历史
     * 
     * @param goalId 目标ID
     * @return 进度历史
     */
    public List<GoalProgressHistory> getGoalProgressHistory(Long goalId);

    /**
     * 完成目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    public int completeGoal(Long goalId);

    /**
     * 暂停目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    public int pauseGoal(Long goalId);

    /**
     * 恢复目标
     * 
     * @param goalId 目标ID
     * @return 结果
     */
    public int resumeGoal(Long goalId);

    /**
     * 目标概览
     */
    class GoalSummary {
        /** 总目标数 */
        private Integer totalGoals;
        
        /** 进行中的目标数 */
        private Integer activeGoals;
        
        /** 已完成的目标数 */
        private Integer completedGoals;
        
        /** 已暂停的目标数 */
        private Integer pausedGoals;
        
        /** 平均完成度 */
        private BigDecimal averageCompletion;
        
        /** 即将到期的目标数 */
        private Integer soonExpireGoals;

        // Getters and Setters
        public Integer getTotalGoals() { return totalGoals; }
        public void setTotalGoals(Integer totalGoals) { this.totalGoals = totalGoals; }

        public Integer getActiveGoals() { return activeGoals; }
        public void setActiveGoals(Integer activeGoals) { this.activeGoals = activeGoals; }

        public Integer getCompletedGoals() { return completedGoals; }
        public void setCompletedGoals(Integer completedGoals) { this.completedGoals = completedGoals; }

        public Integer getPausedGoals() { return pausedGoals; }
        public void setPausedGoals(Integer pausedGoals) { this.pausedGoals = pausedGoals; }

        public BigDecimal getAverageCompletion() { return averageCompletion; }
        public void setAverageCompletion(BigDecimal averageCompletion) { this.averageCompletion = averageCompletion; }

        public Integer getSoonExpireGoals() { return soonExpireGoals; }
        public void setSoonExpireGoals(Integer soonExpireGoals) { this.soonExpireGoals = soonExpireGoals; }
    }

    /**
     * 目标进度历史
     */
    class GoalProgressHistory {
        /** 记录日期 */
        private Date recordDate;
        
        /** 当时的值 */
        private BigDecimal value;
        
        /** 完成百分比 */
        private BigDecimal completionPercentage;
        
        /** 备注 */
        private String remark;

        // Getters and Setters
        public Date getRecordDate() { return recordDate; }
        public void setRecordDate(Date recordDate) { this.recordDate = recordDate; }

        public BigDecimal getValue() { return value; }
        public void setValue(BigDecimal value) { this.value = value; }

        public BigDecimal getCompletionPercentage() { return completionPercentage; }
        public void setCompletionPercentage(BigDecimal completionPercentage) { this.completionPercentage = completionPercentage; }

        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }
}
