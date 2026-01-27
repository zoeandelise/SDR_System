package com.SDR_System.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.annotation.Excel.ColumnType;
import com.SDR_System.common.core.domain.BaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 饮食记录表 diet_record
 * 
 * @author SDR_System
 */
public class DietRecord extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 记录ID */
    private Long recordId;

    /** 用户ID */
    @Excel(name = "用户ID", cellType = ColumnType.NUMERIC)
    private Long userId;

    /** 记录日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "记录日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date recordDate;

    /** 餐次类型(0早餐 1午餐 2晚餐 3加餐) */
    @Excel(name = "餐次类型", readConverterExp = "0=早餐,1=午餐,2=晚餐,3=加餐")
    private String mealType;

    /** 总热量(kcal) */
    @Excel(name = "总热量(kcal)")
    private BigDecimal totalCalories;

    /** 总蛋白质(g) */
    @Excel(name = "总蛋白质(g)")
    private BigDecimal totalProtein;

    /** 总脂肪(g) */
    @Excel(name = "总脂肪(g)")
    private BigDecimal totalFat;

    /** 总碳水化合物(g) */
    @Excel(name = "总碳水化合物(g)")
    private BigDecimal totalCarbohydrate;

    /** MongoDB文档ID */
    @Excel(name = "MongoDB文档ID")
    private String mongoDocId;

    /** 食物照片URLs */
    private String imageUrls;

    /** 备注 */
    @Excel(name = "备注")
    private String notes;

    /** 用户名称 */
    @Excel(name = "用户名称")
    private String userName;

    /** 餐次名称 */
    @Excel(name = "餐次名称")
    private String mealTypeName;

    public Long getRecordId()
    {
        return recordId;
    }

    public void setRecordId(Long recordId)
    {
        this.recordId = recordId;
    }

    @NotNull(message = "用户ID不能为空")
    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    @NotNull(message = "记录日期不能为空")
    public Date getRecordDate()
    {
        return recordDate;
    }

    public void setRecordDate(Date recordDate)
    {
        this.recordDate = recordDate;
    }

    @NotNull(message = "餐次类型不能为空")
    public String getMealType()
    {
        return mealType;
    }

    public void setMealType(String mealType)
    {
        this.mealType = mealType;
    }

    public BigDecimal getTotalCalories()
    {
        return totalCalories;
    }

    public void setTotalCalories(BigDecimal totalCalories)
    {
        this.totalCalories = totalCalories;
    }

    public BigDecimal getTotalProtein()
    {
        return totalProtein;
    }

    public void setTotalProtein(BigDecimal totalProtein)
    {
        this.totalProtein = totalProtein;
    }

    public BigDecimal getTotalFat()
    {
        return totalFat;
    }

    public void setTotalFat(BigDecimal totalFat)
    {
        this.totalFat = totalFat;
    }

    public BigDecimal getTotalCarbohydrate()
    {
        return totalCarbohydrate;
    }

    public void setTotalCarbohydrate(BigDecimal totalCarbohydrate)
    {
        this.totalCarbohydrate = totalCarbohydrate;
    }

    @Size(min = 0, max = 100, message = "MongoDB文档ID不能超过100个字符")
    public String getMongoDocId()
    {
        return mongoDocId;
    }

    public void setMongoDocId(String mongoDocId)
    {
        this.mongoDocId = mongoDocId;
    }

    public String getImageUrls()
    {
        return imageUrls;
    }

    public void setImageUrls(String imageUrls)
    {
        this.imageUrls = imageUrls;
    }

    public String getNotes()
    {
        return notes;
    }

    public void setNotes(String notes)
    {
        this.notes = notes;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getMealTypeName()
    {
        return mealTypeName;
    }

    public void setMealTypeName(String mealTypeName)
    {
        this.mealTypeName = mealTypeName;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("recordId", getRecordId())
            .append("userId", getUserId())
            .append("recordDate", getRecordDate())
            .append("mealType", getMealType())
            .append("totalCalories", getTotalCalories())
            .append("totalProtein", getTotalProtein())
            .append("totalFat", getTotalFat())
            .append("totalCarbohydrate", getTotalCarbohydrate())
            .append("mongoDocId", getMongoDocId())
            .append("imageUrls", getImageUrls())
            .append("notes", getNotes())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
