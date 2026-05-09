package com.SDR_System.diet.controller;

import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.diet.service.MLDataService;
import com.SDR_System.diet.service.impl.MLRecommendationService;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.enums.BusinessType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * ML机器学习推荐管理Controller
 * 基于真实数据库数据，无模拟数据
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@RestController
@RequestMapping("/diet/ml")
public class DietMLController extends BaseController {
    
    @Autowired
    private MLDataService mlDataService;
    
    @Autowired
    private MLRecommendationService mlRecommendationService;
    
    /**
     * 获取ML服务状态
     * URL: GET /diet/ml/status
     */
    @GetMapping({"/status", "/service/status"})
    public AjaxResult getServiceStatus() {
        try {
            // 从数据库获取最新服务状态
            Map<String, Object> status = mlDataService.getServiceStatus();
            return AjaxResult.success(status);
        } catch (Exception e) {
            logger.error("获取ML服务状态失败", e);
            return AjaxResult.error("获取服务状态失败: " + e.getMessage());
        }
    }
    
    /**
     * 刷新服务状态（主动检查ML服务）
     * URL: POST /diet/ml/status/refresh
     */
    @PostMapping("/status/refresh")
    public AjaxResult refreshServiceStatus() {
        try {
            // 检查并更新服务状态
            Map<String, Object> status = mlDataService.checkAndUpdateServiceStatus();
            return AjaxResult.success("服务状态已刷新", status);
        } catch (Exception e) {
            logger.error("刷新服务状态失败", e);
            return AjaxResult.error("刷新失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取推荐效果分析
     * URL: GET /diet/ml/analytics
     */
    @GetMapping({"/analytics", "/analytics/stats"})
    public AjaxResult getAnalytics(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            // 从ml_recommendation_stats表聚合真实数据
            Date start = null;
            Date end = null;
            
            if (startDate != null && !startDate.isEmpty()) {
                start = java.sql.Date.valueOf(startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                end = java.sql.Date.valueOf(endDate);
            }
            
            Map<String, Object> analytics = mlDataService.getRecommendationStats(start, end);
            return AjaxResult.success(analytics);
        } catch (Exception e) {
            logger.error("获取推荐分析失败", e);
            return AjaxResult.error("获取推荐分析失败: " + e.getMessage());
        }
    }
    
    /**
     * 启动模型训练
     * URL: POST /diet/ml/model/train
     */
    @Log(title = "推荐模型训练", businessType = BusinessType.OTHER)
    @PostMapping({"/model/train", "/training/start"})
    public AjaxResult startTraining(@RequestBody Map<String, Object> params) {
        try {
            @SuppressWarnings("unchecked")
            List<String> modelTypes = params.containsKey("modelTypes") 
                ? (List<String>) params.get("modelTypes") 
                : Arrays.asList("collaborative_filtering", "content_based");
            
            Integer trainingDays = params.containsKey("trainingDays")
                ? Integer.valueOf(params.get("trainingDays").toString())
                : 180;
            
            // 异步启动训练
            mlRecommendationService.trainModelsAsync(modelTypes, trainingDays);
            
            Map<String, Object> result = new HashMap<>();
            result.put("modelTypes", modelTypes);
            result.put("trainingDays", trainingDays);
            result.put("message", "训练已启动，共" + modelTypes.size() + "个模型");
            
            return AjaxResult.success("训练已启动", result);
            
        } catch (Exception e) {
            logger.error("启动模型训练失败", e);
            return AjaxResult.error("启动训练失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取训练进度
     * URL: GET /diet/ml/training/progress
     */
    @GetMapping("/training/progress")
    public AjaxResult getTrainingProgress() {
        try {
            // 从ml_training_history表读取实时进度
            Map<String, Object> progress = mlDataService.getTrainingProgress();
            return AjaxResult.success(progress);
        } catch (Exception e) {
            logger.error("获取训练进度失败", e);
            Map<String, Object> emptyProgress = new HashMap<>();
            emptyProgress.put("isTraining", false);
            emptyProgress.put("models", new ArrayList<>());
            return AjaxResult.success(emptyProgress);
        }
    }
    
    /**
     * 停止模型训练
     * URL: POST /diet/ml/training/stop
     */
    @Log(title = "推荐模型断联", businessType = BusinessType.OTHER)
    @PostMapping("/training/stop")
    public AjaxResult stopTraining(@RequestBody(required = false) Map<String, Object> params) {
        try {
            // 获取所有进行中的训练
            List<Map<String, Object>> activeTrainings = mlDataService.getActiveTrainings();
            
            for (Map<String, Object> training : activeTrainings) {
                Long trainingId = (Long) training.get("trainingId");
                mlDataService.completeTraining(trainingId, "cancelled", null, "用户主动停止");
            }
            
            return AjaxResult.success("训练已停止，共停止" + activeTrainings.size() + "个模型");
        } catch (Exception e) {
            logger.error("停止训练失败", e);
            return AjaxResult.error("停止训练失败: " + e.getMessage());
        }
    }
    
    /**
     * 测试ML推荐
     * URL: POST /diet/ml/recommend
     */
    @Log(title = "算法干预测试", businessType = BusinessType.OTHER)
    @PostMapping("/recommend")
    public AjaxResult testRecommendation(@RequestBody Map<String, Object> params) {
        try {
            Long userId = params.containsKey("userId") ? 
                Long.valueOf(params.get("userId").toString()) : null;
            String mealType = params.containsKey("mealType") ? 
                params.get("mealType").toString() : "1";
            Integer nRecommendations = params.containsKey("nRecommendations") ? 
                Integer.valueOf(params.get("nRecommendations").toString()) : 8;
                
            // Phase 14: 混合多模态干预参数
            String target = params.containsKey("target") ? params.get("target").toString() : "";
            String allergies = params.containsKey("allergies") ? params.get("allergies").toString() : "";
            String disease = params.containsKey("disease") ? params.get("disease").toString() : "";
            String appetite = params.containsKey("appetite") ? params.get("appetite").toString() : "normal";
            
            if (userId == null) {
                return AjaxResult.error("用户ID不能为空");
            }
            
            // 调用ML推荐服务（追加传递多模态混合参数）
            Map<String, Object> result = mlRecommendationService.getMLRecommendations(
                userId, mealType, nRecommendations, target, allergies, disease, appetite);
            
            return AjaxResult.success("推荐生成成功", result);
            
        } catch (Exception e) {
            logger.error("测试ML推荐失败", e);
            return AjaxResult.error("推荐测试失败: " + e.getMessage());
        }
    }
    
    /**
     * 算法对比测试
     * URL: POST /diet/ml/test/compare
     */
    @Log(title = "推荐算法竞赛", businessType = BusinessType.OTHER)
    @PostMapping("/test/compare")
    public AjaxResult compareAlgorithms(@RequestBody Map<String, Object> params) {
        try {
            Long userId = params.containsKey("userId") ? 
                Long.valueOf(params.get("userId").toString()) : null;
            String mealType = params.containsKey("mealType") ? 
                params.get("mealType").toString() : "1";
            
            if (userId == null) {
                return AjaxResult.error("用户ID不能为空");
            }
            
            // 对比不同算法（基于真实推荐记录）
            Map<String, Object> comparisonResult = mlRecommendationService.compareAlgorithms(userId, mealType);
            
            return AjaxResult.success("算法对比完成", comparisonResult);
            
        } catch (Exception e) {
            logger.error("算法对比失败", e);
            return AjaxResult.error("算法对比失败: " + e.getMessage());
        }
    }
    
    /**
     * 生成协同过滤原理的关系图谱 (Nodes & Links)
     * URL: POST /diet/ml/test/collaborative-graph
     */
    @PostMapping("/test/collaborative-graph")
    public AjaxResult getCollaborativeGraph(@RequestBody Map<String, Object> params) {
        try {
            Long userId = params.containsKey("userId") ? 
                Long.valueOf(params.get("userId").toString()) : null;
            String mealType = params.containsKey("mealType") ? 
                params.get("mealType").toString() : "1";
            
            if (userId == null) {
                return AjaxResult.error("用户ID不能为空");
            }
            
            // 调度服务层抓取拓扑图网络
            Map<String, Object> graphData = mlRecommendationService.buildCollaborativeGraph(userId, mealType);
            
            return AjaxResult.success("图谱构建完成", graphData);
            
        } catch (Exception e) {
            logger.error("构建协同过滤图谱失败", e);
            return AjaxResult.error("构建协同图谱失败: " + e.getMessage());
        }
    }
}
