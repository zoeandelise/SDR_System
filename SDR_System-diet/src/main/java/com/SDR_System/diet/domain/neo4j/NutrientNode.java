package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;

/**
 * Neo4j营养素节点实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Node("Nutrient")
public class NutrientNode {

    @Id
    @GeneratedValue
    private Long id;

    /** 营养素名称 */
    @Property("name")
    private String name;

    /** 营养素代码 */
    @Property("code")
    private String code;

    /** 营养素分类 */
    @Property("category")
    private String category;

    /** 单位 */
    @Property("unit")
    private String unit;

    /** 描述 */
    @Property("description")
    private String description;

    /** 推荐日摄入量 */
    @Property("recommendedDailyIntake")
    private Double recommendedDailyIntake;

    /** 最大安全摄入量 */
    @Property("maxSafeIntake")
    private Double maxSafeIntake;

    // 构造函数
    public NutrientNode() {}

    public NutrientNode(String name, String category, String unit) {
        this.name = name;
        this.category = category;
        this.unit = unit;
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

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Double getRecommendedDailyIntake() {
        return recommendedDailyIntake;
    }

    public void setRecommendedDailyIntake(Double recommendedDailyIntake) {
        this.recommendedDailyIntake = recommendedDailyIntake;
    }

    public Double getMaxSafeIntake() {
        return maxSafeIntake;
    }

    public void setMaxSafeIntake(Double maxSafeIntake) {
        this.maxSafeIntake = maxSafeIntake;
    }

    @Override
    public String toString() {
        return "NutrientNode{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", unit='" + unit + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof NutrientNode)) return false;
        NutrientNode that = (NutrientNode) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
