package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/user/diet/article")
public class DietArticleController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // ==================== C端用户接口 ====================

    /**
     * 拉取前台科普资讯列表 (C端用户)
     */
    @GetMapping("/list")
    public AjaxResult listArticles() {
        String sql = "SELECT article_id, title, author, cover_image, view_count, create_time " +
                     "FROM diet_article " +
                     "WHERE status = '0' ORDER BY create_time DESC LIMIT 20";
        List<Map<String, Object>> articles = jdbcTemplate.queryForList(sql);
        return AjaxResult.success(articles);
    }
    
    /**
     * 获取文章详情
     */
    @GetMapping("/{id}")
    public AjaxResult getArticle(@PathVariable Long id) {
        jdbcTemplate.update("UPDATE diet_article SET view_count = view_count + 1 WHERE article_id = ?", id);
        
        List<Map<String, Object>> res = jdbcTemplate.queryForList(
                "SELECT * FROM diet_article WHERE article_id = ?", id);
        if(!res.isEmpty()) {
            return AjaxResult.success(res.get(0));
        }
        return AjaxResult.error("未找到对应文章");
    }

    // ==================== 管理员接口 ====================

    /**
     * [管理员] 获取所有文章列表（含未发布的）
     */
    @GetMapping("/admin/list")
    public AjaxResult adminListArticles(@RequestParam(required = false) String keyword,
                                         @RequestParam(required = false) String status) {
        StringBuilder sql = new StringBuilder(
            "SELECT article_id, title, author, cover_image, view_count, status, create_time, update_time " +
            "FROM diet_article WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append("AND status = ? ");
            params.add(status);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (title LIKE ? OR content LIKE ?) ");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        sql.append("ORDER BY create_time DESC LIMIT 200");
        return AjaxResult.success(jdbcTemplate.queryForList(sql.toString(), params.toArray()));
    }

    /**
     * [管理员] 获取文章详情（编辑用）
     */
    @GetMapping("/admin/{id}")
    public AjaxResult adminGetArticle(@PathVariable Long id) {
        List<Map<String, Object>> res = jdbcTemplate.queryForList(
            "SELECT * FROM diet_article WHERE article_id = ?", id);
        if (!res.isEmpty()) {
            return AjaxResult.success(res.get(0));
        }
        return AjaxResult.error("未找到对应文章");
    }

    /**
     * [管理员] 新增文章
     */
    @PostMapping("/admin")
    public AjaxResult adminAddArticle(@RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        String content = (String) body.get("content");
        String author = (String) body.getOrDefault("author", "系统管理员");
        String coverImage = (String) body.getOrDefault("coverImage", "");
        String status = (String) body.getOrDefault("status", "0");

        if (title == null || title.trim().isEmpty()) return AjaxResult.error("标题不能为空");
        if (content == null || content.trim().isEmpty()) return AjaxResult.error("内容不能为空");

        String createBy = "";
        try { createBy = SecurityUtils.getUsername(); } catch (Exception ignored) {}

        jdbcTemplate.update(
            "INSERT INTO diet_article (title, content, author, cover_image, status, create_by, create_time) VALUES (?, ?, ?, ?, ?, ?, NOW())",
            title.trim(), content, author, coverImage, status, createBy);
        return AjaxResult.success("发布成功");
    }

    /**
     * [管理员] 修改文章
     */
    @PutMapping("/admin/{id}")
    public AjaxResult adminUpdateArticle(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        String content = (String) body.get("content");
        String author = (String) body.get("author");
        String coverImage = (String) body.get("coverImage");
        String status = (String) body.get("status");

        if (title == null || title.trim().isEmpty()) return AjaxResult.error("标题不能为空");
        if (content == null || content.trim().isEmpty()) return AjaxResult.error("内容不能为空");

        jdbcTemplate.update(
            "UPDATE diet_article SET title=?, content=?, author=?, cover_image=?, status=?, update_time=NOW() WHERE article_id=?",
            title.trim(), content, author, coverImage, status, id);
        return AjaxResult.success("修改成功");
    }

    /**
     * [管理员] 删除文章
     */
    @DeleteMapping("/admin/{id}")
    public AjaxResult adminDeleteArticle(@PathVariable Long id) {
        jdbcTemplate.update("DELETE FROM diet_article WHERE article_id = ?", id);
        return AjaxResult.success("删除成功");
    }

    /**
     * [管理员] 切换发布状态
     */
    @PutMapping("/admin/toggle-status/{id}")
    public AjaxResult adminToggleStatus(@PathVariable Long id) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
            "SELECT status FROM diet_article WHERE article_id = ?", id);
        if (rows.isEmpty()) return AjaxResult.error("文章不存在");
        String current = (String) rows.get(0).get("status");
        String newStatus = "0".equals(current) ? "1" : "0";
        jdbcTemplate.update("UPDATE diet_article SET status = ?, update_time = NOW() WHERE article_id = ?", newStatus, id);
        return AjaxResult.success("0".equals(newStatus) ? "已发布" : "已下架");
    }
}
