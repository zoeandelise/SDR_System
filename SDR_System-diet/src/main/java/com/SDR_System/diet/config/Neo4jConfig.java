package com.SDR_System.diet.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.neo4j.core.transaction.Neo4jTransactionManager;
import org.springframework.data.neo4j.repository.config.EnableNeo4jRepositories;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.neo4j.driver.Driver;

/**
 * Neo4j配置类
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Configuration
@EnableNeo4jRepositories(basePackages = "com.SDR_System.diet.repository")
@EnableTransactionManagement
@ConditionalOnProperty(name = "spring.data.neo4j.uri")
public class Neo4jConfig {
    
    /**
     * Neo4j事务管理器
     * 指定名称避免与其他事务管理器冲突
     */
    @Bean("neo4jTransactionManager")
    @ConditionalOnProperty(name = "spring.data.neo4j.uri")
    public PlatformTransactionManager neo4jTransactionManager(Driver driver) {
        return new Neo4jTransactionManager(driver);
    }
}
