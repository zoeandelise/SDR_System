package com.SDR_System.diet.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * ML数据访问Mapper
 * 
 * @author SDR_System
 * @date 2025-10-10
 */
@Mapper
public interface MLDataMapper {
    
    // ========================
    // 模型信息相关
    // ========================
    
    /**
     * 获取所有模型信息
     */
    List<Map<String, Object>> selectAllModels();
    
    /**
     * 根据模型类型获取模型信息
     */
    Map<String, Object> selectModelByType(@Param("modelType") String modelType);
    
    /**
     * 更新模型加载状态
     */
    int updateModelStatus(@Param("modelType") String modelType, 
                          @Param("isLoaded") Integer isLoaded);
    
    /**
     * 更新模型训练信息
     */
    int updateModelTrainingInfo(@Param("modelType") String modelType,
                                @Param("accuracy") Double accuracy,
                                @Param("lastTrainedTime") Date lastTrainedTime,
                                @Param("trainingDataSize") Integer trainingDataSize);
    
    // ========================
    // 训练历史相关
    // ========================
    
    /**
     * 插入训练历史记录
     */
    int insertTrainingHistory(Map<String, Object> training);
    
    /**
     * 更新训练进度
     */
    int updateTrainingProgress(@Param("trainingId") Long trainingId,
                               @Param("progress") Integer progress,
                               @Param("currentStep") String currentStep,
                               @Param("status") String status);
    
    /**
     * 完成训练
     */
    int completeTraining(@Param("trainingId") Long trainingId,
                         @Param("status") String status,
                         @Param("accuracy") Double accuracy,
                         @Param("errorMessage") String errorMessage);
    
    /**
     * 获取进行中的训练
     */
    List<Map<String, Object>> selectActiveTrainings();
    
    /**
     * 获取最新训练记录
     */
    Map<String, Object> selectLatestTraining(@Param("modelType") String modelType);
    
    /**
     * 获取训练历史
     */
    List<Map<String, Object>> selectTrainingHistory(@Param("modelType") String modelType,
                                                     @Param("limit") Integer limit);
    
    // ========================
    // 推荐统计相关
    // ========================
    
    /**
     * 聚合推荐统计数据
     */
    Map<String, Object> aggregateRecommendationStats(@Param("startDate") Date startDate,
                                                      @Param("endDate") Date endDate);
    
    /**
     * 按算法类型聚合统计
     */
    List<Map<String, Object>> aggregateStatsByAlgorithm(@Param("startDate") Date startDate,
                                                         @Param("endDate") Date endDate);
    
    /**
     * 插入或更新每日统计
     */
    int upsertDailyStats(@Param("statDate") Date statDate,
                         @Param("algorithmType") String algorithmType,
                         @Param("stats") Map<String, Object> stats);
    
    /**
     * 从推荐记录聚合昨日统计
     */
    List<Map<String, Object>> aggregateYesterdayFromRecommendations();
    
    // ========================
    // 服务状态相关
    // ========================
    
    /**
     * 获取最新服务状态
     */
    Map<String, Object> selectLatestServiceStatus();
    
    /**
     * 插入服务状态记录
     */
    int insertServiceStatus(Map<String, Object> status);
    
    /**
     * 获取最近N条服务状态记录
     */
    List<Map<String, Object>> selectRecentServiceStatus(@Param("limit") Integer limit);
}

