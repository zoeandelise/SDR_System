package com.SDR_System.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotNull;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.annotation.Excel.ColumnType;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 食物营养信息表 diet_food_nutrition
 * 
 * @author SDR_System
 */
public class DietFoodNutrition
{
    private static final long serialVersionUID = 1L;

    /** 营养信息ID */
    private Long nutritionId;

    /** 食物ID */
    @Excel(name = "食物ID", cellType = ColumnType.NUMERIC)
    private Long foodId;

    /** 热量(kcal/100g) */
    @Excel(name = "热量(kcal/100g)")
    private BigDecimal calories;

    /** 蛋白质(g/100g) */
    @Excel(name = "蛋白质(g/100g)")
    private BigDecimal protein;

    /** 脂肪(g/100g) */
    @Excel(name = "脂肪(g/100g)")
    private BigDecimal fat;

    /** 碳水化合物(g/100g) */
    @Excel(name = "碳水化合物(g/100g)")
    private BigDecimal carbohydrate;

    /** 膳食纤维(g/100g) */
    @Excel(name = "膳食纤维(g/100g)")
    private BigDecimal fiber;

    /** 糖分(g/100g) */
    @Excel(name = "糖分(g/100g)")
    private BigDecimal sugar;

    /** 钠(mg/100g) */
    @Excel(name = "钠(mg/100g)")
    private BigDecimal sodium;

    /** 胆固醇(mg/100g) */
    @Excel(name = "胆固醇(mg/100g)")
    private BigDecimal cholesterol;

    /** 维生素A(μg/100g) */
    @Excel(name = "维生素A(μg/100g)")
    private BigDecimal vitaminA;

    /** 维生素C(mg/100g) */
    @Excel(name = "维生素C(mg/100g)")
    private BigDecimal vitaminC;

    /** 维生素D(μg/100g) */
    @Excel(name = "维生素D(μg/100g)")
    private BigDecimal vitaminD;

    /** 钙(mg/100g) */
    @Excel(name = "钙(mg/100g)")
    private BigDecimal calcium;

    /** 铁(mg/100g) */
    @Excel(name = "铁(mg/100g)")
    private BigDecimal iron;

    /** 钾(mg/100g) */
    @Excel(name = "钾(mg/100g)")
    private BigDecimal potassium;

    /** 维生素B1/硫胺素(mg/100g) */
    @Excel(name = "维生素B1(mg/100g)")
    private BigDecimal vitaminB1;

    /** 维生素B2/核黄素(mg/100g) */
    @Excel(name = "维生素B2(mg/100g)")
    private BigDecimal vitaminB2;

    /** 维生素B3/烟酸(mg/100g) */
    @Excel(name = "维生素B3(mg/100g)")
    private BigDecimal vitaminB3;

    /** 维生素B6(mg/100g) */
    @Excel(name = "维生素B6(mg/100g)")
    private BigDecimal vitaminB6;

    /** 维生素B12(μg/100g) */
    @Excel(name = "维生素B12(μg/100g)")
    private BigDecimal vitaminB12;

    /** 叶酸(μg/100g) */
    @Excel(name = "叶酸(μg/100g)")
    private BigDecimal folate;

    /** 维生素E(mg/100g) */
    @Excel(name = "维生素E(mg/100g)")
    private BigDecimal vitaminE;

    /** 维生素K(μg/100g) */
    @Excel(name = "维生素K(μg/100g)")
    private BigDecimal vitaminK;

    /** 镁(mg/100g) */
    @Excel(name = "镁(mg/100g)")
    private BigDecimal magnesium;

    /** 磷(mg/100g) */
    @Excel(name = "磷(mg/100g)")
    private BigDecimal phosphorus;

    /** 锌(mg/100g) */
    @Excel(name = "锌(mg/100g)")
    private BigDecimal zinc;

    /** 铜(mg/100g) */
    @Excel(name = "铜(mg/100g)")
    private BigDecimal copper;

    /** 锰(mg/100g) */
    @Excel(name = "锰(mg/100g)")
    private BigDecimal manganese;

    /** 硒(μg/100g) */
    @Excel(name = "硒(μg/100g)")
    private BigDecimal selenium;

    /** 碘(μg/100g) */
    @Excel(name = "碘(μg/100g)")
    private BigDecimal iodine;

    /** Omega-3脂肪酸(g/100g) */
    @Excel(name = "Omega-3脂肪酸(g/100g)")
    private BigDecimal omega3;

    /** Omega-6脂肪酸(g/100g) */
    @Excel(name = "Omega-6脂肪酸(g/100g)")
    private BigDecimal omega6;

    /** 饱和脂肪酸(g/100g) */
    @Excel(name = "饱和脂肪酸(g/100g)")
    private BigDecimal saturatedFat;

    /** 单不饱和脂肪酸(g/100g) */
    @Excel(name = "单不饱和脂肪酸(g/100g)")
    private BigDecimal monounsaturatedFat;

    /** 多不饱和脂肪酸(g/100g) */
    @Excel(name = "多不饱和脂肪酸(g/100g)")
    private BigDecimal polyunsaturatedFat;

    /** 血糖指数GI */
    @Excel(name = "血糖指数GI", cellType = ColumnType.NUMERIC)
    private Integer glycemicIndex;

    /** 抗氧化能力(ORAC值) */
    @Excel(name = "抗氧化能力(ORAC值)")
    private BigDecimal antioxidantCapacity;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "创建时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "更新时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date updateTime;

    /** 食物名称 */
    @Excel(name = "食物名称")
    private String foodName;

    public Long getNutritionId()
    {
        return nutritionId;
    }

    public void setNutritionId(Long nutritionId)
    {
        this.nutritionId = nutritionId;
    }

    @NotNull(message = "食物ID不能为空")
    public Long getFoodId()
    {
        return foodId;
    }

    public void setFoodId(Long foodId)
    {
        this.foodId = foodId;
    }

    public BigDecimal getCalories()
    {
        return calories;
    }

    public void setCalories(BigDecimal calories)
    {
        this.calories = calories;
    }

    public BigDecimal getProtein()
    {
        return protein;
    }

    public void setProtein(BigDecimal protein)
    {
        this.protein = protein;
    }

    public BigDecimal getFat()
    {
        return fat;
    }

    public void setFat(BigDecimal fat)
    {
        this.fat = fat;
    }

    public BigDecimal getCarbohydrate()
    {
        return carbohydrate;
    }

    public void setCarbohydrate(BigDecimal carbohydrate)
    {
        this.carbohydrate = carbohydrate;
    }

    public BigDecimal getFiber()
    {
        return fiber;
    }

    public void setFiber(BigDecimal fiber)
    {
        this.fiber = fiber;
    }

    public BigDecimal getSugar()
    {
        return sugar;
    }

    public void setSugar(BigDecimal sugar)
    {
        this.sugar = sugar;
    }

    public BigDecimal getSodium()
    {
        return sodium;
    }

    public void setSodium(BigDecimal sodium)
    {
        this.sodium = sodium;
    }

    public BigDecimal getCholesterol()
    {
        return cholesterol;
    }

    public void setCholesterol(BigDecimal cholesterol)
    {
        this.cholesterol = cholesterol;
    }

    public BigDecimal getVitaminA()
    {
        return vitaminA;
    }

    public void setVitaminA(BigDecimal vitaminA)
    {
        this.vitaminA = vitaminA;
    }

    public BigDecimal getVitaminC()
    {
        return vitaminC;
    }

    public void setVitaminC(BigDecimal vitaminC)
    {
        this.vitaminC = vitaminC;
    }

    public BigDecimal getVitaminD()
    {
        return vitaminD;
    }

    public void setVitaminD(BigDecimal vitaminD)
    {
        this.vitaminD = vitaminD;
    }

    public BigDecimal getCalcium()
    {
        return calcium;
    }

    public void setCalcium(BigDecimal calcium)
    {
        this.calcium = calcium;
    }

    public BigDecimal getIron()
    {
        return iron;
    }

    public void setIron(BigDecimal iron)
    {
        this.iron = iron;
    }

    public BigDecimal getPotassium()
    {
        return potassium;
    }

    public void setPotassium(BigDecimal potassium)
    {
        this.potassium = potassium;
    }

    public BigDecimal getVitaminB1()
    {
        return vitaminB1;
    }

    public void setVitaminB1(BigDecimal vitaminB1)
    {
        this.vitaminB1 = vitaminB1;
    }

    public BigDecimal getVitaminB2()
    {
        return vitaminB2;
    }

    public void setVitaminB2(BigDecimal vitaminB2)
    {
        this.vitaminB2 = vitaminB2;
    }

    public BigDecimal getVitaminB3()
    {
        return vitaminB3;
    }

    public void setVitaminB3(BigDecimal vitaminB3)
    {
        this.vitaminB3 = vitaminB3;
    }

    public BigDecimal getVitaminB6()
    {
        return vitaminB6;
    }

    public void setVitaminB6(BigDecimal vitaminB6)
    {
        this.vitaminB6 = vitaminB6;
    }

    public BigDecimal getVitaminB12()
    {
        return vitaminB12;
    }

    public void setVitaminB12(BigDecimal vitaminB12)
    {
        this.vitaminB12 = vitaminB12;
    }

    public BigDecimal getFolate()
    {
        return folate;
    }

    public void setFolate(BigDecimal folate)
    {
        this.folate = folate;
    }

    public BigDecimal getVitaminE()
    {
        return vitaminE;
    }

    public void setVitaminE(BigDecimal vitaminE)
    {
        this.vitaminE = vitaminE;
    }

    public BigDecimal getVitaminK()
    {
        return vitaminK;
    }

    public void setVitaminK(BigDecimal vitaminK)
    {
        this.vitaminK = vitaminK;
    }

    public BigDecimal getMagnesium()
    {
        return magnesium;
    }

    public void setMagnesium(BigDecimal magnesium)
    {
        this.magnesium = magnesium;
    }

    public BigDecimal getPhosphorus()
    {
        return phosphorus;
    }

    public void setPhosphorus(BigDecimal phosphorus)
    {
        this.phosphorus = phosphorus;
    }

    public BigDecimal getZinc()
    {
        return zinc;
    }

    public void setZinc(BigDecimal zinc)
    {
        this.zinc = zinc;
    }

    public BigDecimal getCopper()
    {
        return copper;
    }

    public void setCopper(BigDecimal copper)
    {
        this.copper = copper;
    }

    public BigDecimal getManganese()
    {
        return manganese;
    }

    public void setManganese(BigDecimal manganese)
    {
        this.manganese = manganese;
    }

    public BigDecimal getSelenium()
    {
        return selenium;
    }

    public void setSelenium(BigDecimal selenium)
    {
        this.selenium = selenium;
    }

    public BigDecimal getIodine()
    {
        return iodine;
    }

    public void setIodine(BigDecimal iodine)
    {
        this.iodine = iodine;
    }

    public BigDecimal getOmega3()
    {
        return omega3;
    }

    public void setOmega3(BigDecimal omega3)
    {
        this.omega3 = omega3;
    }

    public BigDecimal getOmega6()
    {
        return omega6;
    }

    public void setOmega6(BigDecimal omega6)
    {
        this.omega6 = omega6;
    }

    public BigDecimal getSaturatedFat()
    {
        return saturatedFat;
    }

    public void setSaturatedFat(BigDecimal saturatedFat)
    {
        this.saturatedFat = saturatedFat;
    }

    public BigDecimal getMonounsaturatedFat()
    {
        return monounsaturatedFat;
    }

    public void setMonounsaturatedFat(BigDecimal monounsaturatedFat)
    {
        this.monounsaturatedFat = monounsaturatedFat;
    }

    public BigDecimal getPolyunsaturatedFat()
    {
        return polyunsaturatedFat;
    }

    public void setPolyunsaturatedFat(BigDecimal polyunsaturatedFat)
    {
        this.polyunsaturatedFat = polyunsaturatedFat;
    }

    public Integer getGlycemicIndex()
    {
        return glycemicIndex;
    }

    public void setGlycemicIndex(Integer glycemicIndex)
    {
        this.glycemicIndex = glycemicIndex;
    }

    public BigDecimal getAntioxidantCapacity()
    {
        return antioxidantCapacity;
    }

    public void setAntioxidantCapacity(BigDecimal antioxidantCapacity)
    {
        this.antioxidantCapacity = antioxidantCapacity;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }

    public Date getUpdateTime()
    {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime)
    {
        this.updateTime = updateTime;
    }

    public String getFoodName()
    {
        return foodName;
    }

    public void setFoodName(String foodName)
    {
        this.foodName = foodName;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("nutritionId", getNutritionId())
            .append("foodId", getFoodId())
            .append("calories", getCalories())
            .append("protein", getProtein())
            .append("fat", getFat())
            .append("carbohydrate", getCarbohydrate())
            .append("fiber", getFiber())
            .append("sugar", getSugar())
            .append("sodium", getSodium())
            .append("cholesterol", getCholesterol())
            .append("vitaminA", getVitaminA())
            .append("vitaminC", getVitaminC())
            .append("vitaminD", getVitaminD())
            .append("calcium", getCalcium())
            .append("iron", getIron())
            .append("potassium", getPotassium())
            .append("vitaminB1", getVitaminB1())
            .append("vitaminB2", getVitaminB2())
            .append("vitaminB3", getVitaminB3())
            .append("vitaminB6", getVitaminB6())
            .append("vitaminB12", getVitaminB12())
            .append("folate", getFolate())
            .append("vitaminE", getVitaminE())
            .append("vitaminK", getVitaminK())
            .append("magnesium", getMagnesium())
            .append("phosphorus", getPhosphorus())
            .append("zinc", getZinc())
            .append("copper", getCopper())
            .append("manganese", getManganese())
            .append("selenium", getSelenium())
            .append("iodine", getIodine())
            .append("omega3", getOmega3())
            .append("omega6", getOmega6())
            .append("saturatedFat", getSaturatedFat())
            .append("monounsaturatedFat", getMonounsaturatedFat())
            .append("polyunsaturatedFat", getPolyunsaturatedFat())
            .append("glycemicIndex", getGlycemicIndex())
            .append("antioxidantCapacity", getAntioxidantCapacity())
            .append("createTime", getCreateTime())
            .append("updateTime", getUpdateTime())
            .toString();
    }
}
