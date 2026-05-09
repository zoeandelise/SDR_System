package com.SDR_System.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.core.domain.BaseEntity;

/**
 * 饮食打卡记录对象 diet_checkin
 * 
 * @author SDR_System
 * @date 2026-03-03
 */
public class DietCheckin extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 打卡ID */
    private Long checkinId;

    /** 用户ID */
    @Excel(name = "用户ID")
    private Long userId;
    
    /** 用户名 (关联查询出) */
    @Excel(name = "用户账号")
    private String userName;

    /** 打卡日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "打卡日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date checkinDate;

    /** 餐次类型 (breakfast/lunch/dinner) */
    @Excel(name = "餐次类型")
    private String mealType;

    /** 打卡心情 */
    @Excel(name = "打卡心情")
    private String mood;

    /** 打卡心得 */
    @Excel(name = "打卡心得")
    private String notes;

    public void setCheckinId(Long checkinId) 
    {
        this.checkinId = checkinId;
    }

    public Long getCheckinId() 
    {
        return checkinId;
    }
    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }
    
    public String getUserName() 
    {
        return userName;
    }

    public void setUserName(String userName) 
    {
        this.userName = userName;
    }

    public void setCheckinDate(Date checkinDate) 
    {
        this.checkinDate = checkinDate;
    }

    public Date getCheckinDate() 
    {
        return checkinDate;
    }
    public void setMealType(String mealType) 
    {
        this.mealType = mealType;
    }

    public String getMealType() 
    {
        return mealType;
    }
    public void setMood(String mood) 
    {
        this.mood = mood;
    }

    public String getMood() 
    {
        return mood;
    }
    public void setNotes(String notes) 
    {
        this.notes = notes;
    }

    public String getNotes() 
    {
        return notes;
    }

    @Override
    public String toString() {
        return "DietCheckin{" +
            "checkinId=" + checkinId +
            ", userId=" + userId +
            ", checkinDate=" + checkinDate +
            ", mealType='" + mealType + '\'' +
            ", mood='" + mood + '\'' +
            ", notes='" + notes + '\'' +
            '}';
    }
}
