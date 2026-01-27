package com.SDR_System.diet.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.core.domain.BaseEntity;

/**
 * 饮食推荐对象 diet_recommendation
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public class DietRecommendation extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 推荐ID */
    private Long recommendationId;

    /** 用户ID */
    @Excel(name = "用户ID")
    private Long userId;

    /** 推荐日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "推荐日期", width = 30, dateFormat = "yyyy-MM-dd")
    private Date recommendationDate;

    /** 推荐类型(0每日推荐 1单餐推荐 2个性化推荐) */
    @Excel(name = "推荐类型", readConverterExp = "0=每日推荐,1=单餐推荐,2=个性化推荐")
    private String recommendationType;

    /** 餐次类型(0早餐 1午餐 2晚餐 3加餐) */
    @Excel(name = "餐次类型", readConverterExp = "0=早餐,1=午餐,2=晚餐,3=加餐")
    private String mealType;

    /** 目标热量 */
    @Excel(name = "目标热量")
    private BigDecimal targetCalories;

    /** 目标蛋白质 */
    @Excel(name = "目标蛋白质")
    private BigDecimal targetProtein;

    /** 目标脂肪 */
    @Excel(name = "目标脂肪")
    private BigDecimal targetFat;

    /** 目标碳水化合物 */
    @Excel(name = "目标碳水化合物")
    private BigDecimal targetCarbohydrate;

    /** 推荐食物列表(JSON格式) */
    @Excel(name = "推荐食物列表")
    private String recommendedFoods;

    /** 推荐理由 */
    @Excel(name = "推荐理由")
    private String reason;

    /** 推荐算法类型 */
    @Excel(name = "推荐算法类型")
    private String algorithmType;

    /** 推荐评分 */
    @Excel(name = "推荐评分")
    private BigDecimal score;

    /** 状态(0待应用 1已应用 2已拒绝) */
    @Excel(name = "状态", readConverterExp = "0=待应用,1=已应用,2=已拒绝")
    private String status;

    /** 特殊要求 */
    @Excel(name = "特殊要求")
    private String specialRequirements;

    /** 不喜欢的食物 */
    @Excel(name = "不喜欢的食物")
    private String dislikedFoods;

    public void setRecommendationId(Long recommendationId) 
    {
        this.recommendationId = recommendationId;
    }

    public Long getRecommendationId() 
    {
        return recommendationId;
    }
    public void setUserId(Long userId) 
    {
        this.userId = userId;
    }

    public Long getUserId() 
    {
        return userId;
    }
    public void setRecommendationDate(Date recommendationDate) 
    {
        this.recommendationDate = recommendationDate;
    }

    public Date getRecommendationDate() 
    {
        return recommendationDate;
    }
    public void setRecommendationType(String recommendationType) 
    {
        this.recommendationType = recommendationType;
    }

    public String getRecommendationType() 
    {
        return recommendationType;
    }
    public void setMealType(String mealType) 
    {
        this.mealType = mealType;
    }

    public String getMealType() 
    {
        return mealType;
    }
    public void setTargetCalories(BigDecimal targetCalories) 
    {
        this.targetCalories = targetCalories;
    }

    public BigDecimal getTargetCalories() 
    {
        return targetCalories;
    }
    public void setTargetProtein(BigDecimal targetProtein) 
    {
        this.targetProtein = targetProtein;
    }

    public BigDecimal getTargetProtein() 
    {
        return targetProtein;
    }
    public void setTargetFat(BigDecimal targetFat) 
    {
        this.targetFat = targetFat;
    }

    public BigDecimal getTargetFat() 
    {
        return targetFat;
    }
    public void setTargetCarbohydrate(BigDecimal targetCarbohydrate) 
    {
        this.targetCarbohydrate = targetCarbohydrate;
    }

    public BigDecimal getTargetCarbohydrate() 
    {
        return targetCarbohydrate;
    }
    public void setRecommendedFoods(String recommendedFoods) 
    {
        this.recommendedFoods = recommendedFoods;
    }

    public String getRecommendedFoods() 
    {
        return recommendedFoods;
    }
    public void setReason(String reason) 
    {
        this.reason = reason;
    }

    public String getReason() 
    {
        return reason;
    }
    public void setAlgorithmType(String algorithmType) 
    {
        this.algorithmType = algorithmType;
    }

    public String getAlgorithmType() 
    {
        return algorithmType;
    }
    public void setScore(BigDecimal score) 
    {
        this.score = score;
    }

    public BigDecimal getScore() 
    {
        return score;
    }
    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }
    public void setSpecialRequirements(String specialRequirements) 
    {
        this.specialRequirements = specialRequirements;
    }

    public String getSpecialRequirements() 
    {
        return specialRequirements;
    }
    public void setDislikedFoods(String dislikedFoods) 
    {
        this.dislikedFoods = dislikedFoods;
    }

    public String getDislikedFoods() 
    {
        return dislikedFoods;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("recommendationId", getRecommendationId())
            .append("userId", getUserId())
            .append("recommendationDate", getRecommendationDate())
            .append("recommendationType", getRecommendationType())
            .append("mealType", getMealType())
            .append("targetCalories", getTargetCalories())
            .append("targetProtein", getTargetProtein())
            .append("targetFat", getTargetFat())
            .append("targetCarbohydrate", getTargetCarbohydrate())
            .append("recommendedFoods", getRecommendedFoods())
            .append("reason", getReason())
            .append("algorithmType", getAlgorithmType())
            .append("score", getScore())
            .append("status", getStatus())
            .append("specialRequirements", getSpecialRequirements())
            .append("dislikedFoods", getDislikedFoods())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
