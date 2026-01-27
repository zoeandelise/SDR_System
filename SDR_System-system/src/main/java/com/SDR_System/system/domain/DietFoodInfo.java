package com.SDR_System.system.domain;

import java.math.BigDecimal;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.annotation.Excel.ColumnType;
import com.SDR_System.common.core.domain.BaseEntity;

/**
 * 食物基础信息表 diet_food_info
 * 
 * @author SDR_System
 */
public class DietFoodInfo extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 食物ID */
    private Long foodId;

    /** 食物名称 */
    @Excel(name = "食物名称")
    private String foodName;

    /** 食物编码 */
    @Excel(name = "食物编码")
    private String foodCode;

    /** 食物分类ID */
    @Excel(name = "食物分类ID", cellType = ColumnType.NUMERIC)
    private Long categoryId;

    /** 品牌 */
    @Excel(name = "品牌")
    private String brand;

    /** 食物描述 */
    @Excel(name = "食物描述")
    private String description;

    /** 食物图片URL */
    @Excel(name = "食物图片URL")
    private String imageUrl;

    /** 计量单位 */
    @Excel(name = "计量单位")
    private String unit;

    /** 标准重量(g) */
    @Excel(name = "标准重量(g)")
    private BigDecimal standardWeight;

    /** 状态(0正常 1停用) */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;

    /** 分类名称 */
    @Excel(name = "分类名称")
    private String categoryName;

    /** 分类编码(用于前端字典显示) */
    private String category;

    /** 热量(kcal/100g) */
    @Excel(name = "热量(kcal/100g)")
    private BigDecimal caloriesPer100g;

    /** 蛋白质(g/100g) */
    @Excel(name = "蛋白质(g/100g)")
    private BigDecimal proteinPer100g;

    /** 脂肪(g/100g) */
    @Excel(name = "脂肪(g/100g)")
    private BigDecimal fatPer100g;

    /** 碳水化合物(g/100g) */
    @Excel(name = "碳水化合物(g/100g)")
    private BigDecimal carbohydratePer100g;

    /** 纤维(g/100g) */
    @Excel(name = "纤维(g/100g)")
    private BigDecimal fiberPer100g;

    public Long getFoodId()
    {
        return foodId;
    }

    public void setFoodId(Long foodId)
    {
        this.foodId = foodId;
    }

    @NotBlank(message = "食物名称不能为空")
    @Size(min = 0, max = 100, message = "食物名称不能超过100个字符")
    public String getFoodName()
    {
        return foodName;
    }

    public void setFoodName(String foodName)
    {
        this.foodName = foodName;
    }

    @Size(min = 0, max = 50, message = "食物编码不能超过50个字符")
    public String getFoodCode()
    {
        return foodCode;
    }

    public void setFoodCode(String foodCode)
    {
        this.foodCode = foodCode;
    }

    public Long getCategoryId()
    {
        return categoryId;
    }

    public void setCategoryId(Long categoryId)
    {
        this.categoryId = categoryId;
    }

    @Size(min = 0, max = 100, message = "品牌不能超过100个字符")
    public String getBrand()
    {
        return brand;
    }

    public void setBrand(String brand)
    {
        this.brand = brand;
    }

    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    @Size(min = 0, max = 255, message = "食物图片URL不能超过255个字符")
    public String getImageUrl()
    {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl)
    {
        this.imageUrl = imageUrl;
    }

    @Size(min = 0, max = 20, message = "计量单位不能超过20个字符")
    public String getUnit()
    {
        return unit;
    }

    public void setUnit(String unit)
    {
        this.unit = unit;
    }

    public BigDecimal getStandardWeight()
    {
        return standardWeight;
    }

    public void setStandardWeight(BigDecimal standardWeight)
    {
        this.standardWeight = standardWeight;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getCategoryName()
    {
        return categoryName;
    }

    public void setCategoryName(String categoryName)
    {
        this.categoryName = categoryName;
    }

    public String getCategory()
    {
        return category;
    }

    public void setCategory(String category)
    {
        this.category = category;
    }

    public BigDecimal getCaloriesPer100g()
    {
        return caloriesPer100g;
    }

    public void setCaloriesPer100g(BigDecimal caloriesPer100g)
    {
        this.caloriesPer100g = caloriesPer100g;
    }

    public BigDecimal getProteinPer100g()
    {
        return proteinPer100g;
    }

    public void setProteinPer100g(BigDecimal proteinPer100g)
    {
        this.proteinPer100g = proteinPer100g;
    }

    public BigDecimal getFatPer100g()
    {
        return fatPer100g;
    }

    public void setFatPer100g(BigDecimal fatPer100g)
    {
        this.fatPer100g = fatPer100g;
    }

    public BigDecimal getCarbohydratePer100g()
    {
        return carbohydratePer100g;
    }

    public void setCarbohydratePer100g(BigDecimal carbohydratePer100g)
    {
        this.carbohydratePer100g = carbohydratePer100g;
    }

    public BigDecimal getFiberPer100g()
    {
        return fiberPer100g;
    }

    public void setFiberPer100g(BigDecimal fiberPer100g)
    {
        this.fiberPer100g = fiberPer100g;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("foodId", getFoodId())
            .append("foodName", getFoodName())
            .append("foodCode", getFoodCode())
            .append("categoryId", getCategoryId())
            .append("categoryName", getCategoryName())
            .append("category", getCategory())
            .append("brand", getBrand())
            .append("description", getDescription())
            .append("imageUrl", getImageUrl())
            .append("unit", getUnit())
            .append("standardWeight", getStandardWeight())
            .append("caloriesPer100g", getCaloriesPer100g())
            .append("proteinPer100g", getProteinPer100g())
            .append("fatPer100g", getFatPer100g())
            .append("carbohydratePer100g", getCarbohydratePer100g())
            .append("fiberPer100g", getFiberPer100g())
            .append("status", getStatus())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
