package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;
import org.springframework.data.neo4j.core.schema.Relationship;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

/**
 * Neo4j食物节点实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Node("Food")
public class FoodNode {

    @Id
    @GeneratedValue
    private Long id;

    /** 食物名称 */
    @Property("name")
    private String name;

    /** 食物编码 */
    @Property("code")
    private String code;

    /** 食物分类 */
    @Property("category")
    private String category;

    /** 品牌 */
    @Property("brand")
    private String brand;

    /** 描述 */
    @Property("description")
    private String description;

    /** 热量(kcal/100g) */
    @Property("calories")
    private BigDecimal calories;

    /** 蛋白质含量(g/100g) */
    @Property("protein")
    private BigDecimal protein;

    /** 脂肪含量(g/100g) */
    @Property("fat")
    private BigDecimal fat;

    /** 碳水化合物含量(g/100g) */
    @Property("carbohydrate")
    private BigDecimal carbohydrate;

    /** 纤维含量(g/100g) */
    @Property("fiber")
    private BigDecimal fiber;

    /** 钠含量(mg/100g) */
    @Property("sodium")
    private BigDecimal sodium;

    /** 钙含量(mg/100g) */
    @Property("calcium")
    private BigDecimal calcium;

    /** 铁含量(mg/100g) */
    @Property("iron")
    private BigDecimal iron;

    /** 维生素C含量(mg/100g) */
    @Property("vitaminC")
    private BigDecimal vitaminC;

    /** 食物图片URL */
    @Property("imageUrl")
    private String imageUrl;

    /** 计量单位 */
    @Property("unit")
    private String unit;

    /** 标准重量(g) */
    @Property("standardWeight")
    private BigDecimal standardWeight;

    /** 状态(0正常 1停用) */
    @Property("status")
    private String status;

    /** 营养素关系 */
    @Relationship(type = "CONTAINS", direction = Relationship.Direction.OUTGOING)
    private Set<NutrientRelation> nutrients = new HashSet<>();

    /** 健康目标关系 */
    @Relationship(type = "SUITABLE_FOR", direction = Relationship.Direction.OUTGOING)
    private Set<HealthGoalRelation> healthGoals = new HashSet<>();

    /** 疾病关系 */
    @Relationship(type = "UNSUITABLE_FOR", direction = Relationship.Direction.OUTGOING)
    private Set<DiseaseRelation> diseases = new HashSet<>();

    /** 食物搭配关系 */
    @Relationship(type = "PAIRS_WITH", direction = Relationship.Direction.OUTGOING)
    private Set<FoodNode> pairings = new HashSet<>();

    // 构造函数
    public FoodNode() {}

    public FoodNode(String name, String category) {
        this.name = name;
        this.category = category;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getCalories() {
        return calories;
    }

    public void setCalories(BigDecimal calories) {
        this.calories = calories;
    }

    public BigDecimal getProtein() {
        return protein;
    }

    public void setProtein(BigDecimal protein) {
        this.protein = protein;
    }

    public BigDecimal getFat() {
        return fat;
    }

    public void setFat(BigDecimal fat) {
        this.fat = fat;
    }

    public BigDecimal getCarbohydrate() {
        return carbohydrate;
    }

    public void setCarbohydrate(BigDecimal carbohydrate) {
        this.carbohydrate = carbohydrate;
    }

    public BigDecimal getFiber() {
        return fiber;
    }

    public void setFiber(BigDecimal fiber) {
        this.fiber = fiber;
    }

    public BigDecimal getSodium() {
        return sodium;
    }

    public void setSodium(BigDecimal sodium) {
        this.sodium = sodium;
    }

    public BigDecimal getCalcium() {
        return calcium;
    }

    public void setCalcium(BigDecimal calcium) {
        this.calcium = calcium;
    }

    public BigDecimal getIron() {
        return iron;
    }

    public void setIron(BigDecimal iron) {
        this.iron = iron;
    }

    public BigDecimal getVitaminC() {
        return vitaminC;
    }

    public void setVitaminC(BigDecimal vitaminC) {
        this.vitaminC = vitaminC;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getStandardWeight() {
        return standardWeight;
    }

    public void setStandardWeight(BigDecimal standardWeight) {
        this.standardWeight = standardWeight;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Set<NutrientRelation> getNutrients() {
        return nutrients;
    }

    public void setNutrients(Set<NutrientRelation> nutrients) {
        this.nutrients = nutrients;
    }

    public Set<HealthGoalRelation> getHealthGoals() {
        return healthGoals;
    }

    public void setHealthGoals(Set<HealthGoalRelation> healthGoals) {
        this.healthGoals = healthGoals;
    }

    public Set<DiseaseRelation> getDiseases() {
        return diseases;
    }

    public void setDiseases(Set<DiseaseRelation> diseases) {
        this.diseases = diseases;
    }

    public Set<FoodNode> getPairings() {
        return pairings;
    }

    public void setPairings(Set<FoodNode> pairings) {
        this.pairings = pairings;
    }

    @Override
    public String toString() {
        return "FoodNode{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", calories=" + calories +
                ", protein=" + protein +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof FoodNode)) return false;
        FoodNode foodNode = (FoodNode) o;
        return id != null && id.equals(foodNode.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
