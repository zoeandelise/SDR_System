package com.SDR_System.diet.domain.neo4j;

import org.springframework.data.neo4j.core.schema.GeneratedValue;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;

/**
 * Neo4j健康目标节点实体
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Node("HealthGoal")
public class HealthGoalNode {

    @Id
    @GeneratedValue
    private Long id;

    /** 健康目标名称 */
    @Property("name")
    private String name;

    /** 健康目标代码 */
    @Property("code")
    private String code;

    /** 健康目标分类 */
    @Property("category")
    private String category;

    /** 描述 */
    @Property("description")
    private String description;

    /** 目标人群 */
    @Property("target_population")
    private String targetPopulation;

    /** 优先级 */
    @Property("priority")
    private Integer priority;

    // 构造函数
    public HealthGoalNode() {}

    public HealthGoalNode(String name, String category) {
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

    public String getTargetPopulation() {
        return targetPopulation;
    }

    public void setTargetPopulation(String targetPopulation) {
        this.targetPopulation = targetPopulation;
    }

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    @Override
    public String toString() {
        return "HealthGoalNode{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", priority=" + priority +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof HealthGoalNode)) return false;
        HealthGoalNode that = (HealthGoalNode) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
