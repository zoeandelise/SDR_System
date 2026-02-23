package com.SDR_System.system.domain;

import java.math.BigDecimal;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.annotation.Excel.ColumnType;
import com.SDR_System.common.core.domain.BaseEntity;

/**
 * 用户健康信息表 sys_user_health
 * 
 * @author SDR_System
 */
public class SysUserHealth extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 健康信息ID */
    private Long healthId;

    /** 用户ID */
    @Excel(name = "用户ID", cellType = ColumnType.NUMERIC)
    private Long userId;

    /** 身高(cm) */
    @Excel(name = "身高(cm)")
    private BigDecimal height;

    /** 体重(kg) */
    @Excel(name = "体重(kg)")
    private BigDecimal weight;

    /** 年龄 */
    @Excel(name = "年龄")
    private Integer age;

    /** 性别(0男 1女) */
    @Excel(name = "性别", readConverterExp = "0=男,1=女")
    private String gender;

    /** 活动水平(0久坐 1轻度 2中度 3重度 4极重度) */
    @Excel(name = "活动水平", readConverterExp = "0=久坐,1=轻度,2=中度,3=重度,4=极重度")
    private String activityLevel;

    /** 健康目标(0保持 1减脂 2增肌 3增重) */
    @Excel(name = "健康目标", readConverterExp = "0=保持,1=减脂,2=增肌,3=增重")
    private String healthGoal;

    /** 目标体重(kg) */
    @Excel(name = "目标体重(kg)")
    private BigDecimal targetWeight;

    /** 每日热量目标(kcal) */
    @Excel(name = "每日热量目标(kcal)")
    private Integer dailyCalorieGoal;

    /** 过敏信息 */
    @Excel(name = "过敏信息")
    private String allergies;

    /** 疾病信息 */
    @Excel(name = "疾病信息")
    private String diseases;

    /** 饮食偏好 */
    @Excel(name = "饮食偏好")
    private String dietPreferences;

    /** 每日蛋白质目标(g) */
    @Excel(name = "每日蛋白质目标(g)")
    private Integer dailyProteinGoal;

    /** 每日碳水目标(g) */
    @Excel(name = "每日碳水目标(g)")
    private Integer dailyCarbGoal;

    /** 每日脂肪目标(g) */
    @Excel(name = "每日脂肪目标(g)")
    private Integer dailyFatGoal;

    /** 食量偏好(small/normal/large) */
    private String portionPreference;

    /** 职业 */
    private String occupation;

    /** 用户名称 */
    @Excel(name = "用户名称")
    private String userName;

    /** BMI值 */
    private BigDecimal bmi;

    public Long getHealthId()
    {
        return healthId;
    }

    public void setHealthId(Long healthId)
    {
        this.healthId = healthId;
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

    public BigDecimal getHeight()
    {
        return height;
    }

    public void setHeight(BigDecimal height)
    {
        this.height = height;
    }

    public BigDecimal getWeight()
    {
        return weight;
    }

    public void setWeight(BigDecimal weight)
    {
        this.weight = weight;
    }

    public Integer getAge()
    {
        return age;
    }

    public void setAge(Integer age)
    {
        this.age = age;
    }

    public String getGender()
    {
        return gender;
    }

    public void setGender(String gender)
    {
        this.gender = gender;
    }

    public String getActivityLevel()
    {
        return activityLevel;
    }

    public void setActivityLevel(String activityLevel)
    {
        this.activityLevel = activityLevel;
    }

    public String getHealthGoal()
    {
        return healthGoal;
    }

    public void setHealthGoal(String healthGoal)
    {
        this.healthGoal = healthGoal;
    }

    public BigDecimal getTargetWeight()
    {
        return targetWeight;
    }

    public void setTargetWeight(BigDecimal targetWeight)
    {
        this.targetWeight = targetWeight;
    }

    public Integer getDailyCalorieGoal()
    {
        return dailyCalorieGoal;
    }

    public void setDailyCalorieGoal(Integer dailyCalorieGoal)
    {
        this.dailyCalorieGoal = dailyCalorieGoal;
    }

    @Size(min = 0, max = 500, message = "过敏信息不能超过500个字符")
    public String getAllergies()
    {
        return allergies;
    }

    public void setAllergies(String allergies)
    {
        this.allergies = allergies;
    }

    @Size(min = 0, max = 500, message = "疾病信息不能超过500个字符")
    public String getDiseases()
    {
        return diseases;
    }

    public void setDiseases(String diseases)
    {
        this.diseases = diseases;
    }

    public String getDietPreferences()
    {
        return dietPreferences;
    }

    public void setDietPreferences(String dietPreferences)
    {
        this.dietPreferences = dietPreferences;
    }

    public Integer getDailyProteinGoal()
    {
        return dailyProteinGoal;
    }

    public void setDailyProteinGoal(Integer dailyProteinGoal)
    {
        this.dailyProteinGoal = dailyProteinGoal;
    }

    public Integer getDailyCarbGoal()
    {
        return dailyCarbGoal;
    }

    public void setDailyCarbGoal(Integer dailyCarbGoal)
    {
        this.dailyCarbGoal = dailyCarbGoal;
    }

    public Integer getDailyFatGoal()
    {
        return dailyFatGoal;
    }

    public void setDailyFatGoal(Integer dailyFatGoal)
    {
        this.dailyFatGoal = dailyFatGoal;
    }

    public String getPortionPreference()
    {
        return portionPreference;
    }

    public void setPortionPreference(String portionPreference)
    {
        this.portionPreference = portionPreference;
    }

    public String getOccupation()
    {
        return occupation;
    }

    public void setOccupation(String occupation)
    {
        this.occupation = occupation;
    }

    public String getUserName() 
    {
        return userName;
    }

    public void setUserName(String userName) 
    {
        this.userName = userName;
    }

    public BigDecimal getBmi() 
    {
        return bmi;
    }

    public void setBmi(BigDecimal bmi) 
    {
        this.bmi = bmi;
    }

    /**
     * 计算BMI值
     */
    public void calculateBmi() {
        if (height != null && weight != null && height.compareTo(BigDecimal.ZERO) > 0) {
            // BMI = 体重(kg) / 身高(m)²
            BigDecimal heightInMeters = height.divide(new BigDecimal(100), 4, BigDecimal.ROUND_HALF_UP);
            this.bmi = weight.divide(heightInMeters.multiply(heightInMeters), 2, BigDecimal.ROUND_HALF_UP);
        }
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("healthId", getHealthId())
            .append("userId", getUserId())
            .append("height", getHeight())
            .append("weight", getWeight())
            .append("age", getAge())
            .append("gender", getGender())
            .append("activityLevel", getActivityLevel())
            .append("healthGoal", getHealthGoal())
            .append("targetWeight", getTargetWeight())
            .append("dailyCalorieGoal", getDailyCalorieGoal())
            .append("allergies", getAllergies())
            .append("diseases", getDiseases())
            .append("userName", getUserName())
            .append("bmi", getBmi())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
