package com.SDR_System.diet.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.core.domain.BaseEntity;

/**
 * 健康目标对象 diet_goal
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public class DietGoal extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 目标ID */
    private Long goalId;

    /** 用户ID */
    @Excel(name = "用户ID")
    private Long userId;

    /** 目标类型(0减重 1增重 2维持 3增肌 4减脂 5改善血糖 6改善血压) */
    @Excel(name = "目标类型", readConverterExp = "0=减重,1=增重,2=维持,3=增肌,4=减脂,5=改善血糖,6=改善血压")
    private String goalType;

    /** 目标名称 */
    @Excel(name = "目标名称")
    private String goalName;

    /** 目标描述 */
    @Excel(name = "目标描述")
    private String description;

    /** 目标值 */
    @Excel(name = "目标值")
    private BigDecimal targetValue;

    /** 当前值 */
    @Excel(name = "当前值")
    private BigDecimal currentValue;

    /** 单位 */
    @Excel(name = "单位")
    private String unit;

    /** 开始日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "开始日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date startDate;

    /** 目标日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "目标日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date targetDate;

    /** 状态(0进行中 1已完成 2已暂停 3已取消) */
    @Excel(name = "状态", readConverterExp = "0=进行中,1=已完成,2=已暂停,3=已取消")
    private String status;

    /** 优先级(0低 1中 2高) */
    @Excel(name = "优先级", readConverterExp = "0=低,1=中,2=高")
    private String priority;

    /** 完成百分比 */
    @Excel(name = "完成百分比")
    private BigDecimal completionPercentage;

    /** 提醒设置 */
    @Excel(name = "提醒设置")
    private String reminderSettings;

    /** 奖励机制 */
    @Excel(name = "奖励机制")
    private String rewardMechanism;

    public void setGoalId(Long goalId) 
    {
        this.goalId = goalId;
    }

    public Long getGoalId() 
    {
        return goalId;
    }
    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }
    public void setGoalType(String goalType) 
    {
        this.goalType = goalType;
    }

    public String getGoalType() 
    {
        return goalType;
    }
    public void setGoalName(String goalName) 
    {
        this.goalName = goalName;
    }

    public String getGoalName() 
    {
        return goalName;
    }
    public void setDescription(String description) 
    {
        this.description = description;
    }

    public String getDescription() 
    {
        return description;
    }
    public void setTargetValue(BigDecimal targetValue) 
    {
        this.targetValue = targetValue;
    }

    public BigDecimal getTargetValue() 
    {
        return targetValue;
    }
    public void setCurrentValue(BigDecimal currentValue) 
    {
        this.currentValue = currentValue;
    }

    public BigDecimal getCurrentValue() 
    {
        return currentValue;
    }
    public void setUnit(String unit) 
    {
        this.unit = unit;
    }

    public String getUnit() 
    {
        return unit;
    }
    public void setStartDate(Date startDate) 
    {
        this.startDate = startDate;
    }

    public Date getStartDate() 
    {
        return startDate;
    }
    public void setTargetDate(Date targetDate) 
    {
        this.targetDate = targetDate;
    }

    public Date getTargetDate() 
    {
        return targetDate;
    }
    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }
    public void setPriority(String priority) 
    {
        this.priority = priority;
    }

    public String getPriority() 
    {
        return priority;
    }
    public void setCompletionPercentage(BigDecimal completionPercentage) 
    {
        this.completionPercentage = completionPercentage;
    }

    public BigDecimal getCompletionPercentage() 
    {
        return completionPercentage;
    }
    public void setReminderSettings(String reminderSettings) 
    {
        this.reminderSettings = reminderSettings;
    }

    public String getReminderSettings() 
    {
        return reminderSettings;
    }
    public void setRewardMechanism(String rewardMechanism) 
    {
        this.rewardMechanism = rewardMechanism;
    }

    public String getRewardMechanism() 
    {
        return rewardMechanism;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("goalId", getGoalId())
            .append("userId", getUserId())
            .append("goalType", getGoalType())
            .append("goalName", getGoalName())
            .append("description", getDescription())
            .append("targetValue", getTargetValue())
            .append("currentValue", getCurrentValue())
            .append("unit", getUnit())
            .append("startDate", getStartDate())
            .append("targetDate", getTargetDate())
            .append("status", getStatus())
            .append("priority", getPriority())
            .append("completionPercentage", getCompletionPercentage())
            .append("reminderSettings", getReminderSettings())
            .append("rewardMechanism", getRewardMechanism())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
