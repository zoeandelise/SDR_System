package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Property;
import org.springframework.data.neo4j.core.schema.RelationshipProperties;
import org.springframework.data.neo4j.core.schema.TargetNode;

import java.math.BigDecimal;

/**
 * Neo4j疾病关系实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RelationshipProperties
public class DiseaseRelation {

    @Id
    @GeneratedValue
    private Long id;

    /** 风险等级(1-5, 5为最高风险) */
    @Property("risk_level")
    private Integer riskLevel;

    /** 不适宜原因 */
    @Property("reason")
    private String reason;

    /** 建议限制量 */
    @Property("restriction_limit")
    private BigDecimal restrictionLimit;

    /** 限制单位 */
    @Property("restriction_unit")
    private String restrictionUnit;

    /** 医学证据等级 */
    @Property("evidence_level")
    private String evidenceLevel;

    /** 目标疾病节点 */
    @TargetNode
    private DiseaseNode disease;

    // 构造函数
    public DiseaseRelation() {}

    public DiseaseRelation(DiseaseNode disease, Integer riskLevel, String reason) {
        this.disease = disease;
        this.riskLevel = riskLevel;
        this.reason = reason;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(Integer riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getRestrictionLimit() {
        return restrictionLimit;
    }

    public void setRestrictionLimit(BigDecimal restrictionLimit) {
        this.restrictionLimit = restrictionLimit;
    }

    public String getRestrictionUnit() {
        return restrictionUnit;
    }

    public void setRestrictionUnit(String restrictionUnit) {
        this.restrictionUnit = restrictionUnit;
    }

    public String getEvidenceLevel() {
        return evidenceLevel;
    }

    public void setEvidenceLevel(String evidenceLevel) {
        this.evidenceLevel = evidenceLevel;
    }

    public DiseaseNode getDisease() {
        return disease;
    }

    public void setDisease(DiseaseNode disease) {
        this.disease = disease;
    }

    @Override
    public String toString() {
        return "DiseaseRelation{" +
                "id=" + id +
                ", riskLevel=" + riskLevel +
                ", reason='" + reason + '\'' +
                ", disease=" + (disease != null ? disease.getName() : null) +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DiseaseRelation)) return false;
        DiseaseRelation that = (DiseaseRelation) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
