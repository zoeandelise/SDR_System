package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Property;
import org.springframework.data.neo4j.core.schema.RelationshipProperties;
import org.springframework.data.neo4j.core.schema.TargetNode;

import java.math.BigDecimal;

/**
 * Neo4j营养素关系实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RelationshipProperties
public class NutrientRelation {

    @Id
    @GeneratedValue
    private Long id;

    /** 营养素含量 */
    @Property("content")
    private BigDecimal content;

    /** 含量单位 */
    @Property("unit")
    private String unit;

    /** 营养素密度 */
    @Property("density")
    private BigDecimal density;

    /** 生物利用度 */
    @Property("bioavailability")
    private BigDecimal bioavailability;

    /** 目标营养素节点 */
    @TargetNode
    private NutrientNode nutrient;

    // 构造函数
    public NutrientRelation() {}

    public NutrientRelation(NutrientNode nutrient, BigDecimal content, String unit) {
        this.nutrient = nutrient;
        this.content = content;
        this.unit = unit;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BigDecimal getContent() {
        return content;
    }

    public void setContent(BigDecimal content) {
        this.content = content;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public BigDecimal getDensity() {
        return density;
    }

    public void setDensity(BigDecimal density) {
        this.density = density;
    }

    public BigDecimal getBioavailability() {
        return bioavailability;
    }

    public void setBioavailability(BigDecimal bioavailability) {
        this.bioavailability = bioavailability;
    }

    public NutrientNode getNutrient() {
        return nutrient;
    }

    public void setNutrient(NutrientNode nutrient) {
        this.nutrient = nutrient;
    }

    @Override
    public String toString() {
        return "NutrientRelation{" +
                "id=" + id +
                ", content=" + content +
                ", unit='" + unit + '\'' +
                ", nutrient=" + (nutrient != null ? nutrient.getName() : null) +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof NutrientRelation)) return false;
        NutrientRelation that = (NutrientRelation) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
