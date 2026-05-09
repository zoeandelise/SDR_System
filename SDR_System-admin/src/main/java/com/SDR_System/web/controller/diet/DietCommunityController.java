package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/user/diet/community")
public class DietCommunityController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // ==================== 敏感词过滤 ====================

    /**
     * 从数据库加载启用状态的敏感词列表
     */
    private List<String> loadSensitiveWords() {
        try {
            return jdbcTemplate.queryForList(
                "SELECT word FROM diet_sensitive_word WHERE status = '0'", String.class
            );
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /**
     * 将文本中的敏感词替换为 ***
     */
    private String maskSensitiveWord(String text) {
        if (text == null || text.isEmpty()) return text;
        List<String> words = loadSensitiveWords();
        String masked = text;
        for (String w : words) {
            // 不区分大小写进行替换
            masked = masked.replaceAll("(?i)" + java.util.regex.Pattern.quote(w), "***");
        }
        return masked;
    }

    // ==================== 帖子相关 ====================

    /**
     * 拉取社区动态
     */
    @GetMapping("/list")
    public AjaxResult listPosts() {
        Long userId = getCurrentUserId();
        // 利用关联查询拉取动态及发送者名字，同时返回真实点赞/评论数与是否已赞
        String sql = "SELECT " +
                "p.post_id, p.user_id, p.content, p.image_urls, p.create_time, p.update_time, " +
                "u.nick_name, u.avatar, " +
                "(SELECT COUNT(1) FROM diet_post_like l WHERE l.post_id = p.post_id) AS like_count, " +
                "(SELECT COUNT(1) FROM diet_post_comment c WHERE c.post_id = p.post_id) AS comment_count, " +
                "EXISTS(SELECT 1 FROM diet_post_like l2 WHERE l2.post_id = p.post_id AND l2.user_id = ?) AS is_liked " +
                "FROM diet_post p " +
                "LEFT JOIN sys_user u ON p.user_id = u.user_id " +
                "WHERE p.del_flag = '0' " +
                "ORDER BY p.create_time DESC LIMIT 50";
        List<Map<String, Object>> posts = jdbcTemplate.queryForList(sql, userId);
        for (Map<String, Object> post : posts) {
            if (post.get("avatar") == null) post.put("avatar", "");
            if (post.get("image_urls") == null) post.put("image_urls", "");
        }
        return AjaxResult.success(posts);
    }

    /**
     * 发布动态 — 含敏感词过滤
     */
    @PostMapping("/publish")
    public AjaxResult publish(@RequestBody Map<String, Object> body) {
        Long userId = getCurrentUserId();
        String content = (String) body.get("content");
        String imageUrls = (String) body.get("imageUrls");
        
        if (content == null || content.trim().isEmpty()) {
            return AjaxResult.error("内容不能为空");
        }

        // 敏感词检测及脱敏
        content = maskSensitiveWord(content);
        
        jdbcTemplate.update("INSERT INTO diet_post (user_id, content, image_urls, create_time) VALUES (?, ?, ?, NOW())",
                           userId, content, imageUrls);
                           
        return AjaxResult.success("发布成功");
    }

    /**
     * 用户删除自己的帖子
     */
    @DeleteMapping("/{postId}")
    public AjaxResult deleteMyPost(@PathVariable Long postId) {
        Long userId = getCurrentUserId();
        int rows = jdbcTemplate.update(
            "UPDATE diet_post SET del_flag = '1' WHERE post_id = ? AND user_id = ?", postId, userId);
        return rows > 0 ? AjaxResult.success("删除成功") : AjaxResult.error("删除失败，只能删除自己的帖子");
    }

    // ==================== 帖子点赞 ====================

    /**
     * 点赞/取消点赞帖子（按用户 toggle）
     */
    @PostMapping("/like/{postId}")
    public AjaxResult like(@PathVariable Long postId) {
        Long userId = getCurrentUserId();
        try {
            Integer exists = 0;
            try {
                exists = jdbcTemplate.queryForObject(
                        "SELECT COUNT(1) FROM diet_post_like WHERE post_id = ? AND user_id = ?",
                        Integer.class, postId, userId
                );
            } catch (Exception ignored) {
            }

            boolean isLiked;
            if (exists != null && exists > 0) {
                jdbcTemplate.update("DELETE FROM diet_post_like WHERE post_id = ? AND user_id = ?", postId, userId);
                jdbcTemplate.update("UPDATE diet_post SET like_count = GREATEST(like_count - 1, 0) WHERE post_id = ?", postId);
                isLiked = false;
            } else {
                jdbcTemplate.update("INSERT INTO diet_post_like (post_id, user_id, create_time) VALUES (?, ?, NOW())", postId, userId);
                jdbcTemplate.update("UPDATE diet_post SET like_count = like_count + 1 WHERE post_id = ?", postId);
                isLiked = true;
            }

            Integer likeCount = 0;
            try {
                likeCount = jdbcTemplate.queryForObject(
                        "SELECT COUNT(1) FROM diet_post_like WHERE post_id = ?",
                        Integer.class, postId
                );
            } catch (Exception ignored) {
            }

            Map<String, Object> result = new HashMap<>();
            result.put("postId", postId);
            result.put("isLiked", isLiked);
            result.put("likeCount", likeCount == null ? 0 : likeCount);
            return AjaxResult.success(result);
        } catch (Exception e) {
            return AjaxResult.error("操作失败：" + e.getMessage());
        }
    }

    // ==================== 评论相关 ====================

    /**
     * 获取某条动态的评论列表（含每条评论的点赞数和当前用户是否已赞）
     */
    @GetMapping("/comments/{postId}")
    public AjaxResult listComments(@PathVariable Long postId) {
        try {
            Long userId = getCurrentUserId();
            String sql = "SELECT c.comment_id, c.post_id, c.user_id, c.content, c.create_time, " +
                    "u.nick_name, u.avatar, " +
                    "(SELECT COUNT(1) FROM diet_comment_like cl WHERE cl.comment_id = c.comment_id) AS like_count, " +
                    "EXISTS(SELECT 1 FROM diet_comment_like cl2 WHERE cl2.comment_id = c.comment_id AND cl2.user_id = ?) AS is_liked " +
                    "FROM diet_post_comment c " +
                    "LEFT JOIN sys_user u ON c.user_id = u.user_id " +
                    "WHERE c.post_id = ? " +
                    "ORDER BY c.create_time ASC";
            List<Map<String, Object>> list = jdbcTemplate.queryForList(sql, userId, postId);
            for (Map<String, Object> c : list) {
                if (c.get("avatar") == null) c.put("avatar", "");
            }
            return AjaxResult.success(list);
        } catch (Exception e) {
            return AjaxResult.error("获取评论失败：" + e.getMessage());
        }
    }

    /**
     * 发表评论 — 含敏感词过滤
     */
    @PostMapping("/comments/{postId}")
    public AjaxResult addComment(@PathVariable Long postId, @RequestBody Map<String, Object> body) {
        try {
            Long userId = getCurrentUserId();
            String content = (String) body.get("content");
            if (content == null || content.trim().isEmpty()) {
                return AjaxResult.error("评论内容不能为空");
            }

            // 敏感词检测及脱敏
            content = maskSensitiveWord(content);

            jdbcTemplate.update("INSERT INTO diet_post_comment (post_id, user_id, content, create_time) VALUES (?, ?, ?, NOW())",
                    postId, userId, content);
            // 保持 diet_post 的 comment_count 可用
            try {
                jdbcTemplate.update("UPDATE diet_post SET comment_count = comment_count + 1 WHERE post_id = ?", postId);
            } catch (Exception ignored) {
            }
            return AjaxResult.success("评论成功");
        } catch (Exception e) {
            return AjaxResult.error("评论失败：" + e.getMessage());
        }
    }

    /**
     * 评论点赞/取消点赞
     */
    @PostMapping("/comment-like/{commentId}")
    public AjaxResult likeComment(@PathVariable Long commentId) {
        Long userId = getCurrentUserId();
        try {
            Integer exists = 0;
            try {
                exists = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM diet_comment_like WHERE comment_id = ? AND user_id = ?",
                    Integer.class, commentId, userId);
            } catch (Exception ignored) {}

            boolean isLiked;
            if (exists != null && exists > 0) {
                jdbcTemplate.update("DELETE FROM diet_comment_like WHERE comment_id = ? AND user_id = ?", commentId, userId);
                try { jdbcTemplate.update("UPDATE diet_post_comment SET like_count = GREATEST(like_count - 1, 0) WHERE comment_id = ?", commentId); } catch (Exception ignored) {}
                isLiked = false;
            } else {
                jdbcTemplate.update("INSERT INTO diet_comment_like (comment_id, user_id, create_time) VALUES (?, ?, NOW())", commentId, userId);
                try { jdbcTemplate.update("UPDATE diet_post_comment SET like_count = like_count + 1 WHERE comment_id = ?", commentId); } catch (Exception ignored) {}
                isLiked = true;
            }

            Integer likeCount = 0;
            try {
                likeCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM diet_comment_like WHERE comment_id = ?", Integer.class, commentId);
            } catch (Exception ignored) {}

            Map<String, Object> result = new HashMap<>();
            result.put("commentId", commentId);
            result.put("isLiked", isLiked);
            result.put("likeCount", likeCount == null ? 0 : likeCount);
            return AjaxResult.success(result);
        } catch (Exception e) {
            return AjaxResult.error("操作失败：" + e.getMessage());
        }
    }

    // ==================== 管理员接口 ====================

    /**
     * [管理员] 获取所有帖子列表（含已删除）
     */
    @GetMapping("/admin/list")
    public AjaxResult adminListPosts(@RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String delFlag) {
        StringBuilder sql = new StringBuilder(
            "SELECT p.post_id, p.user_id, p.content, p.image_urls, p.del_flag, p.create_time, " +
            "u.nick_name, u.user_name, " +
            "(SELECT COUNT(1) FROM diet_post_like l WHERE l.post_id = p.post_id) AS like_count, " +
            "(SELECT COUNT(1) FROM diet_post_comment c WHERE c.post_id = p.post_id) AS comment_count " +
            "FROM diet_post p LEFT JOIN sys_user u ON p.user_id = u.user_id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (delFlag != null && !delFlag.isEmpty()) {
            sql.append("AND p.del_flag = ? ");
            params.add(delFlag);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND p.content LIKE ? ");
            params.add("%" + keyword + "%");
        }
        sql.append("ORDER BY p.create_time DESC LIMIT 200");
        return AjaxResult.success(jdbcTemplate.queryForList(sql.toString(), params.toArray()));
    }

    /**
     * [管理员] 删除帖子（逻辑删除）
     */
    @DeleteMapping("/admin/{postId}")
    public AjaxResult adminDeletePost(@PathVariable Long postId) {
        jdbcTemplate.update("UPDATE diet_post SET del_flag = '1' WHERE post_id = ?", postId);
        return AjaxResult.success("删除成功");
    }

    /**
     * [管理员] 恢复帖子
     */
    @PutMapping("/admin/restore/{postId}")
    public AjaxResult adminRestorePost(@PathVariable Long postId) {
        jdbcTemplate.update("UPDATE diet_post SET del_flag = '0' WHERE post_id = ?", postId);
        return AjaxResult.success("恢复成功");
    }

    /**
     * [管理员] 删除评论
     */
    @DeleteMapping("/admin/comment/{commentId}")
    public AjaxResult adminDeleteComment(@PathVariable Long commentId) {
        try {
            // 先查所属帖子ID
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT post_id FROM diet_post_comment WHERE comment_id = ?", commentId);
            jdbcTemplate.update("DELETE FROM diet_post_comment WHERE comment_id = ?", commentId);
            jdbcTemplate.update("DELETE FROM diet_comment_like WHERE comment_id = ?", commentId);
            if (!rows.isEmpty()) {
                Long postId = ((Number) rows.get(0).get("post_id")).longValue();
                try { jdbcTemplate.update("UPDATE diet_post SET comment_count = GREATEST(comment_count - 1, 0) WHERE post_id = ?", postId); } catch (Exception ignored) {}
            }
            return AjaxResult.success("评论已删除");
        } catch (Exception e) {
            return AjaxResult.error("删除失败：" + e.getMessage());
        }
    }

    /**
     * [管理员] 获取帖子下所有评论
     */
    @GetMapping("/admin/comments/{postId}")
    public AjaxResult adminListComments(@PathVariable Long postId) {
        String sql = "SELECT c.comment_id, c.post_id, c.user_id, c.content, c.create_time, " +
                "u.nick_name, u.user_name, " +
                "(SELECT COUNT(1) FROM diet_comment_like cl WHERE cl.comment_id = c.comment_id) AS like_count " +
                "FROM diet_post_comment c LEFT JOIN sys_user u ON c.user_id = u.user_id " +
                "WHERE c.post_id = ? ORDER BY c.create_time ASC";
        return AjaxResult.success(jdbcTemplate.queryForList(sql, postId));
    }

    // ==================== 敏感词管理（管理员） ====================

    /**
     * [管理员] 获取敏感词列表
     */
    @GetMapping("/admin/sensitive-words")
    public AjaxResult listSensitiveWords() {
        return AjaxResult.success(jdbcTemplate.queryForList(
            "SELECT word_id, word, status, create_time FROM diet_sensitive_word ORDER BY create_time DESC"));
    }

    /**
     * [管理员] 新增敏感词
     */
    @PostMapping("/admin/sensitive-words")
    public AjaxResult addSensitiveWord(@RequestBody Map<String, Object> body) {
        String word = (String) body.get("word");
        if (word == null || word.trim().isEmpty()) return AjaxResult.error("敏感词不能为空");
        try {
            jdbcTemplate.update("INSERT INTO diet_sensitive_word (word) VALUES (?)", word.trim());
            return AjaxResult.success("添加成功");
        } catch (Exception e) {
            return AjaxResult.error("添加失败，可能已存在");
        }
    }

    /**
     * [管理员] 删除敏感词
     */
    @DeleteMapping("/admin/sensitive-words/{wordId}")
    public AjaxResult deleteSensitiveWord(@PathVariable Long wordId) {
        jdbcTemplate.update("DELETE FROM diet_sensitive_word WHERE word_id = ?", wordId);
        return AjaxResult.success("删除成功");
    }

    private Long getCurrentUserId() {
        try {
            return SecurityUtils.getUserId();
        } catch (Exception e) {
            return 1L;
        }
    }
}
