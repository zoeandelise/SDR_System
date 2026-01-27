package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;

/**
 * Neo4j疾病节点实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Node("Disease")
public class DiseaseNode {

    @Id
    @GeneratedValue
    private Long id;

    /** 疾病名称 */
    @Property("name")
    private String name;

    /** 疾病代码(如ICD-10) */
    @Property("code")
    private String code;

    /** 疾病分类 */
    @Property("category")
    private String category;

    /** 描述 */
    @Property("description")
    private String description;

    /** 严重程度 */
    @Property("severity")
    private String severity;

    /** 患病率 */
    @Property("prevalence")
    private String prevalence;

    /** 是否慢性疾病 */
    @Property("is_chronic")
    private Boolean isChronic;

    // 构造函数
    public DiseaseNode() {}

    public DiseaseNode(String name, String category) {
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getPrevalence() {
        return prevalence;
    }

    public void setPrevalence(String prevalence) {
        this.prevalence = prevalence;
    }

    public Boolean getIsChronic() {
        return isChronic;
    }

    public void setIsChronic(Boolean isChronic) {
        this.isChronic = isChronic;
    }

    @Override
    public String toString() {
        return "DiseaseNode{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", severity='" + severity + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DiseaseNode)) return false;
        DiseaseNode that = (DiseaseNode) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
