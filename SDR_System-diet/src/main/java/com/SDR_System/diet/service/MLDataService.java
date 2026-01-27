package com.SDR_System.diet.service;

import com.SDR_System.diet.mapper.MLDataMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * ML数据服务
 * 负责所有ML相关的数据库操作
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@Service
public class MLDataService {
    
    private static final Logger logger = LoggerFactory.getLogger(MLDataService.class);
    
    @Autowired
    private MLDataMapper mlDataMapper;
    
    @Value("${ml.service.url:http://localhost:8001}")
    private String mlServiceUrl;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    // ========================
    // 模型信息相关
    // ========================
    
    /**
     * 获取所有模型信息
     */
    public List<Map<String, Object>> getModelInfo() {
        try {
            return mlDataMapper.selectAllModels();
        } catch (Exception e) {
            logger.error("获取模型信息失败", e);
            return new ArrayList<>();
        }
    }
    
    /**
     * 更新模型加载状态
     */
    public void updateModelStatus(String modelType, boolean isLoaded) {
        try {
            mlDataMapper.updateModelStatus(modelType, isLoaded ? 1 : 0);
            logger.info("更新模型状态: {} - {}", modelType, isLoaded ? "已加载" : "未加载");
        } catch (Exception e) {
            logger.error("更新模型状态失败: " + modelType, e);
        }
    }
    
    /**
     * 更新模型训练信息
     */
    public void updateModelTrainingInfo(String modelType, Double accuracy, Integer trainingDataSize) {
        try {
            mlDataMapper.updateModelTrainingInfo(modelType, accuracy, new Date(), trainingDataSize);
            mlDataMapper.updateModelStatus(modelType, 1); // 训练完成后标记为已加载
        } catch (Exception e) {
            logger.error("更新模型训练信息失败: " + modelType, e);
        }
    }
    
    // ========================
    // 训练历史相关
    // ========================
    
    /**
     * 开始训练
     */
    public Long startTraining(String modelType, Integer trainingDays) {
        try {
            Map<String, Object> training = new HashMap<>();
            training.put("modelType", modelType);
            training.put("trainingStatus", "pending");
            training.put("progress", 0);
            training.put("currentStep", "准备开始训练...");
            training.put("startTime", new Date());
            training.put("trainingDays", trainingDays != null ? trainingDays : 180);
            training.put("dataSize", 0);
            
            mlDataMapper.insertTrainingHistory(training);
            
            // 处理自增ID类型转换（可能是BigInteger或Long）
            Object trainingIdObj = training.get("trainingId");
            Long trainingId = null;
            if (trainingIdObj instanceof Long) {
                trainingId = (Long) trainingIdObj;
            } else if (trainingIdObj instanceof Number) {
                trainingId = ((Number) trainingIdObj).longValue();
            }
            
            logger.info("开始训练记录创建成功: trainingId={}, modelType={}", trainingId, modelType);
            return trainingId;
        } catch (Exception e) {
            logger.error("创建训练记录失败: " + modelType, e);
            return null;
        }
    }
    
    /**
     * 更新训练进度（添加同步锁和数据验证）
     */
    public synchronized void updateTrainingProgress(Long trainingId, Integer progress, String currentStep) {
        try {
            // 数据验证：进度值必须在0-100之间
            if (progress < 0 || progress > 100) {
                logger.warn("进度值异常: {}, 自动修正到合法范围", progress);
                progress = Math.max(0, Math.min(100, progress));
            }
            
            // 验证trainingId
            if (trainingId == null || trainingId <= 0) {
                logger.error("无效的trainingId: {}", trainingId);
                return;
            }
            
            String status = progress >= 100 ? "completed" : "training";
            
            mlDataMapper.updateTrainingProgress(trainingId, progress, currentStep, status);
            
            logger.debug("进度已更新: trainingId={}, progress={}%, step={}", trainingId, progress, currentStep);
            
        } catch (Exception e) {
            logger.error("更新训练进度失败: trainingId={}, progress={}, step={}", 
                         trainingId, progress, currentStep, e);
        }
    }
    
    /**
     * 完成训练
     */
    public void completeTraining(Long trainingId, String status, Double accuracy, String errorMessage) {
        try {
            mlDataMapper.completeTraining(trainingId, status, accuracy, errorMessage);
            logger.info("训练完成: trainingId={}, status={}", trainingId, status);
        } catch (Exception e) {
            logger.error("完成训练记录失败: trainingId=" + trainingId, e);
        }
    }
    
    /**
     * 获取进行中的训练
     */
    public List<Map<String, Object>> getActiveTrainings() {
        try {
            return mlDataMapper.selectActiveTrainings();
        } catch (Exception e) {
            logger.error("获取活跃训练失败", e);
            return new ArrayList<>();
        }
    }
    
    /**
     * 获取训练进度信息
     */
    public Map<String, Object> getTrainingProgress() {
        Map<String, Object> result = new HashMap<>();
        try {
            List<Map<String, Object>> activeTrainings = getActiveTrainings();
            
            // 检查是否有正在训练的模型（状态为pending或training）
            boolean isTraining = activeTrainings.stream()
                .anyMatch(t -> "training".equals(t.get("trainingStatus")) || 
                              "pending".equals(t.get("trainingStatus")));
            
            result.put("isTraining", isTraining);
            result.put("models", activeTrainings);
            
            if (!activeTrainings.isEmpty()) {
                int totalProgress = 0;
                int completedCount = 0;
                int totalCount = activeTrainings.size();
                
                for (Map<String, Object> training : activeTrainings) {
                    Integer progress = (Integer) training.get("progress");
                    totalProgress += (progress != null ? progress : 0);
                    if (progress != null && progress >= 100) {
                        completedCount++;
                    }
                }
                
                result.put("overallProgress", totalCount > 0 ? totalProgress / totalCount : 0);
                result.put("completedModels", completedCount);
                result.put("totalModels", totalCount);
                result.put("totalElapsedTime", activeTrainings.get(0).get("elapsedTime"));
            } else {
                result.put("overallProgress", 0);
                result.put("completedModels", 0);
                result.put("totalModels", 0);
                result.put("totalElapsedTime", 0);
            }
        } catch (Exception e) {
            logger.error("获取训练进度失败", e);
            result.put("isTraining", false);
            result.put("models", new ArrayList<>());
        }
        return result;
    }
    
    // ========================
    // 推荐统计相关
    // ========================
    
    /**
     * 获取推荐统计数据
     */
    public Map<String, Object> getRecommendationStats(Date startDate, Date endDate) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 如果没有指定日期范围，使用最近90天，确保能显示数据
            if (startDate == null) {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.DAY_OF_MONTH, -90);
                startDate = cal.getTime();
            }
            if (endDate == null) {
                endDate = new Date();
            }
            
            // 获取总体统计
            Map<String, Object> overallStats = mlDataMapper.aggregateRecommendationStats(startDate, endDate);
            result.putAll(overallStats);
            
            // 获取按算法分组的统计，并转换为Map格式（用于前端图表）
            List<Map<String, Object>> algorithmStatsList = mlDataMapper.aggregateStatsByAlgorithm(startDate, endDate);
            
            // 同时保存列表格式（用于表格展示）
            result.put("algorithmPerformance", algorithmStatsList);
            
            // 转换为Map格式（用于前端algorithmPerformance对象访问）
            Map<String, Object> algorithmPerformanceMap = new HashMap<>();
            for (Map<String, Object> algo : algorithmStatsList) {
                String algoType = (String) algo.get("algorithmType");
                if (algoType != null) {
                    algorithmPerformanceMap.put(algoType, algo);
                }
            }
            result.put("algorithmPerformanceMap", algorithmPerformanceMap);
            
            logger.debug("推荐统计: totalRecommendations={}, algorithms={}", 
                result.get("totalRecommendations"), algorithmStatsList.size());
            return result;
        } catch (Exception e) {
            logger.error("获取推荐统计失败", e);
            // 返回默认值
            result.put("totalRecommendations", 0);
            result.put("acceptedRecommendations", 0);
            result.put("acceptanceRate", 0.0);
            result.put("avgScore", 0.0);
            result.put("activeUsers", 0);
            result.put("avgResponseTime", 0);
            result.put("algorithmPerformance", new ArrayList<>());
            result.put("algorithmPerformanceMap", new HashMap<>());
            return result;
        }
    }
    
    /**
     * 聚合昨日推荐统计
     */
    public void aggregateYesterdayStats() {
        try {
            List<Map<String, Object>> yesterdayStats = mlDataMapper.aggregateYesterdayFromRecommendations();
            
            for (Map<String, Object> stat : yesterdayStats) {
                Date statDate = (Date) stat.get("statDate");
                String algorithmType = (String) stat.get("algorithmType");
                mlDataMapper.upsertDailyStats(statDate, algorithmType, stat);
            }
            
            logger.info("昨日推荐统计聚合完成，共{}条记录", yesterdayStats.size());
        } catch (Exception e) {
            logger.error("聚合昨日统计失败", e);
        }
    }
    
    // ========================
    // 服务状态相关
    // ========================
    
    /**
     * 获取最新服务状态
     */
    public Map<String, Object> getServiceStatus() {
        try {
            Map<String, Object> status = mlDataMapper.selectLatestServiceStatus();
            logger.debug("从数据库查询到的服务状态: {}", status);
            if (status == null) {
                // 如果没有记录，返回离线状态
                logger.warn("数据库中没有服务状态记录，返回默认离线状态");
                status = createOfflineStatus();
            }
            
            // 添加模型详细信息
            List<Map<String, Object>> modelsList = getModelInfo();
            Map<String, Boolean> modelsLoaded = new HashMap<>();
            Map<String, Object> modelsData = new HashMap<>();
            
            for (Map<String, Object> model : modelsList) {
                String modelType = (String) model.get("modelType");
                Object isLoadedObj = model.get("isLoaded");
                
                // 处理isLoaded可能是Boolean或Integer类型
                boolean isLoaded = false;
                if (isLoadedObj instanceof Boolean) {
                    isLoaded = (Boolean) isLoadedObj;
                } else if (isLoadedObj instanceof Number) {
                    isLoaded = ((Number) isLoadedObj).intValue() == 1;
                }
                
                // modelsLoaded映射（布尔值）
                modelsLoaded.put(modelType, isLoaded);
                
                // models详细数据（包含last_trained等）
                Map<String, Object> modelDetail = new HashMap<>();
                modelDetail.put("loaded", isLoaded);
                modelDetail.put("last_trained", model.get("lastTrainedTime"));
                modelDetail.put("accuracy", model.get("accuracy"));
                modelDetail.put("version", model.get("modelVersion"));
                modelsData.put(modelType, modelDetail);
            }
            
            status.put("modelsLoaded", modelsLoaded);
            status.put("models", modelsData);
            
            // 添加组件状态（从数据库字段读取）
            Map<String, Boolean> components = new HashMap<>();
            Object dataLoaderObj = status.get("dataLoaderStatus");
            Object userProfilingObj = status.get("userProfilingStatus");
            Object recommenderObj = status.get("recommenderStatus");
            
            // 处理可能的类型转换
            boolean dataLoaderStatus = convertToBoolean(dataLoaderObj);
            boolean userProfilingStatus = convertToBoolean(userProfilingObj);
            boolean recommenderStatus = convertToBoolean(recommenderObj);
            
            components.put("dataLoader", dataLoaderStatus);
            components.put("userProfiling", userProfilingStatus);
            components.put("recommender", recommenderStatus);
            status.put("components", components);
            
            logger.info("服务状态组件: dataLoader={}, userProfiling={}, recommender={}", 
                dataLoaderStatus, userProfilingStatus, recommenderStatus);
            logger.debug("返回的完整状态: {}", status);
            
            return status;
        } catch (Exception e) {
            logger.error("获取服务状态失败", e);
            return createOfflineStatus();
        }
    }
    
    /**
     * 保存服务状态
     */
    public void saveServiceStatus(Map<String, Object> statusData) {
        try {
            Map<String, Object> status = new HashMap<>();
            status.put("serviceStatus", statusData.get("serviceStatus"));
            status.put("dataLoaderStatus", statusData.get("dataLoaderStatus"));
            status.put("userProfilingStatus", statusData.get("userProfilingStatus"));
            status.put("recommenderStatus", statusData.get("recommenderStatus"));
            status.put("checkTime", new Date());
            status.put("responseTime", statusData.get("responseTime"));
            status.put("errorMessage", statusData.get("errorMessage"));
            
            mlDataMapper.insertServiceStatus(status);
        } catch (Exception e) {
            logger.error("保存服务状态失败", e);
        }
    }
    
    /**
     * 检查并更新服务状态
     */
    public Map<String, Object> checkAndUpdateServiceStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // 尝试ping ML服务
            boolean isOnline = pingMLService();
            
            status.put("serviceStatus", isOnline ? "healthy" : "offline");
            status.put("dataLoaderStatus", isOnline ? 1 : 0);
            status.put("userProfilingStatus", isOnline ? 1 : 0);
            status.put("recommenderStatus", isOnline ? 1 : 0);
            status.put("responseTime", isOnline ? 50 : null);
            status.put("errorMessage", isOnline ? null : "ML服务离线");
            
            saveServiceStatus(status);
            
            logger.info("服务状态检查完成: {}", isOnline ? "在线" : "离线");
        } catch (Exception e) {
            logger.error("检查服务状态失败", e);
            status.put("serviceStatus", "offline");
            status.put("dataLoaderStatus", 0);
            status.put("userProfilingStatus", 0);
            status.put("recommenderStatus", 0);
            status.put("errorMessage", e.getMessage());
            saveServiceStatus(status);
        }
        
        return getServiceStatus();
    }
    
    /**
     * Ping ML服务
     */
    private boolean pingMLService() {
        try {
            String url = mlServiceUrl + "/health";
            restTemplate.getForObject(url, String.class);
            return true;
        } catch (Exception e) {
            logger.debug("ML服务不可用: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * 类型转换辅助方法：将对象转为boolean
     */
    private boolean convertToBoolean(Object obj) {
        if (obj == null) {
            return false;
        }
        if (obj instanceof Boolean) {
            return (Boolean) obj;
        }
        if (obj instanceof Number) {
            return ((Number) obj).intValue() == 1;
        }
        if (obj instanceof String) {
            String str = (String) obj;
            return "1".equals(str) || "true".equalsIgnoreCase(str);
        }
        return false;
    }
    
    /**
     * 创建离线状态
     */
    private Map<String, Object> createOfflineStatus() {
        Map<String, Object> status = new HashMap<>();
        Date now = new Date();
        status.put("serviceStatus", "offline");
        status.put("dataLoaderStatus", 0);
        status.put("userProfilingStatus", 0);
        status.put("recommenderStatus", 0);
        status.put("checkTime", now);
        status.put("lastCheckTime", now);
        status.put("responseTime", null);
        status.put("errorMessage", "未找到服务状态记录");
        
        Map<String, Boolean> components = new HashMap<>();
        components.put("dataLoader", false);
        components.put("userProfiling", false);
        components.put("recommender", false);
        status.put("components", components);
        
        Map<String, Boolean> modelsLoaded = new HashMap<>();
        modelsLoaded.put("collaborative_filtering", false);
        modelsLoaded.put("content_based", false);
        modelsLoaded.put("deep_learning", false);
        status.put("modelsLoaded", modelsLoaded);
        
        return status;
    }
}
