package com.SDR_System.web.core.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class DatabaseSetupRunner implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(DatabaseSetupRunner.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        log.info("--- 正在初始化新增模块相关的数据库表 ---");
        try {
            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_post (" +
                "post_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "user_id BIGINT NOT NULL," +
                "content VARCHAR(2000)," +
                "image_urls VARCHAR(1000)," +
                "like_count INT DEFAULT 0," +
                "comment_count INT DEFAULT 0," +
                "del_flag CHAR(1) DEFAULT '0'," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_post_comment (" +
                "comment_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "post_id BIGINT NOT NULL," +
                "user_id BIGINT NOT NULL," +
                "content VARCHAR(500) NOT NULL," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "KEY idx_post_id (post_id)," +
                "KEY idx_user_id (user_id)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_post_like (" +
                "like_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "post_id BIGINT NOT NULL," +
                "user_id BIGINT NOT NULL," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "UNIQUE KEY uk_post_user (post_id, user_id)," +
                "KEY idx_post_id (post_id)," +
                "KEY idx_user_id (user_id)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_article (" +
                "article_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "title VARCHAR(200) NOT NULL," +
                "author VARCHAR(50) DEFAULT 'SYS'," +
                "content LONGTEXT NOT NULL," +
                "cover_image VARCHAR(255)," +
                "view_count INT DEFAULT 0," +
                "status CHAR(1) DEFAULT '0'," +
                "create_by VARCHAR(64)," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // 评论点赞表
            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_comment_like (" +
                "like_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "comment_id BIGINT NOT NULL," +
                "user_id BIGINT NOT NULL," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "UNIQUE KEY uk_comment_user (comment_id, user_id)," +
                "KEY idx_comment_id (comment_id)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // 敏感词表
            jdbcTemplate.execute(
                "CREATE TABLE IF NOT EXISTS diet_sensitive_word (" +
                "word_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "word VARCHAR(100) NOT NULL," +
                "status CHAR(1) DEFAULT '0' COMMENT '0启用 1停用'," +
                "create_time DATETIME DEFAULT CURRENT_TIMESTAMP," +
                "UNIQUE KEY uk_word (word)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // 给 diet_post_comment 补一个 like_count 字段（如果不存在的话）
            try {
                jdbcTemplate.execute("ALTER TABLE diet_post_comment ADD COLUMN like_count INT DEFAULT 0");
            } catch (Exception ignored) {}

            // 初始化敏感词
            try {
                String[] defaultWords = {"广告", "代购", "微商", "加微信", "加QQ", "赌博", "色情", "诈骗", "传销", "刷单", "免费领", "日赚", "兼职"};
                for (String w : defaultWords) {
                    try {
                        jdbcTemplate.update("INSERT IGNORE INTO diet_sensitive_word (word) VALUES (?)", w);
                    } catch (Exception ignored) {}
                }
            } catch (Exception ignored) {}

            try {
                jdbcTemplate.execute("INSERT INTO diet_article (title, content, author) SELECT '如何判断碳水是不是优质碳水？', '优质碳水一般富含膳食纤维，升糖指数（GI）较低，如糙米、燕麦、紫薯等。', '营养专家团队' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM diet_article LIMIT 1)");
                jdbcTemplate.execute("INSERT INTO diet_article (title, content, author) SELECT '糖尿病患者如何度过秋季？', '秋季干燥，应多喝水并避免过高糖分的水果如柿子、哈密瓜。建议以粗粮作为主食。', '医疗组' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM diet_article WHERE article_id = 2)");
            } catch (Exception e) {}

            log.info("--- 数据库表创建/补齐完成 ---");
        } catch (Exception e) {
            log.error("创建表失败", e);
        }
    }
}
