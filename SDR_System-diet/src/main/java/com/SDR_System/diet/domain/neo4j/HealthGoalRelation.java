package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Property;
import org.springframework.data.neo4j.core.schema.RelationshipProperties;
import org.springframework.data.neo4j.core.schema.TargetNode;

import java.math.BigDecimal;

/**
 * Neo4j健康目标关系实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RelationshipProperties
public class HealthGoalRelation {

    @Id
    @GeneratedValue
    private Long id;

    /** 适宜度评分(0-10) */
    @Property("suitability_score")
    private BigDecimal suitabilityScore;

    /** 推荐理由 */
    @Property("reason")
    private String reason;

    /** 建议摄入量 */
    @Property("recommended_amount")
    private BigDecimal recommendedAmount;

    /** 建议频率 */
    @Property("frequency")
    private String frequency;

    /** 目标健康目标节点 */
    @TargetNode
    private HealthGoalNode healthGoal;

    // 构造函数
    public HealthGoalRelation() {}

    public HealthGoalRelation(HealthGoalNode healthGoal, BigDecimal suitabilityScore, String reason) {
        this.healthGoal = healthGoal;
        this.suitabilityScore = suitabilityScore;
        this.reason = reason;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BigDecimal getSuitabilityScore() {
        return suitabilityScore;
    }

    public void setSuitabilityScore(BigDecimal suitabilityScore) {
        this.suitabilityScore = suitabilityScore;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getRecommendedAmount() {
        return recommendedAmount;
    }

    public void setRecommendedAmount(BigDecimal recommendedAmount) {
        this.recommendedAmount = recommendedAmount;
    }

    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public HealthGoalNode getHealthGoal() {
        return healthGoal;
    }

    public void setHealthGoal(HealthGoalNode healthGoal) {
        this.healthGoal = healthGoal;
    }

    @Override
    public String toString() {
        return "HealthGoalRelation{" +
                "id=" + id +
                ", suitabilityScore=" + suitabilityScore +
                ", reason='" + reason + '\'' +
                ", healthGoal=" + (healthGoal != null ? healthGoal.getName() : null) +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof HealthGoalRelation)) return false;
        HealthGoalRelation that = (HealthGoalRelation) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
