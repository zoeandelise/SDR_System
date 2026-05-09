package com.SDR_System.diet.mapper;

import java.util.List;
import java.util.Date;
import org.apache.ibatis.annotations.Param;
import com.SDR_System.system.domain.DietRecord;

/**
 * 饮食记录Mapper接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface DietRecordMapper 
{
    /**
     * 查询饮食记录
     * 
     * @param recordId 饮食记录主键
     * @return 饮食记录
     */
    public DietRecord selectDietRecordByRecordId(Long recordId);

    /**
     * 查询饮食记录列表
     * 
     * @param dietRecord 饮食记录
     * @return 饮食记录集合
     */
    public List<DietRecord> selectDietRecordList(DietRecord dietRecord);

    /**
     * 新增饮食记录
     * 
     * @param dietRecord 饮食记录
     * @return 结果
     */
    public int insertDietRecord(DietRecord dietRecord);

    /**
     * 修改饮食记录
     * 
     * @param dietRecord 饮食记录
     * @return 结果
     */
    public int updateDietRecord(DietRecord dietRecord);

    /**
     * 删除饮食记录
     * 
     * @param recordId 饮食记录主键
     * @return 结果
     */
    public int deleteDietRecordByRecordId(Long recordId);

    /**
     * 批量删除饮食记录
     * 
     * @param recordIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDietRecordByRecordIds(Long[] recordIds);

    /**
     * 根据用户ID和日期范围查询饮食记录
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 饮食记录列表
     */
    public List<DietRecord> selectDietRecordsByUserIdAndDateRange(@Param("userId") Long userId, @Param("startDate") Date startDate, @Param("endDate") Date endDate);

    /**
     * 根据用户ID和日期查询当日饮食记录
     * 
     * @param userId 用户ID
     * @param recordDate 记录日期
     * @return 饮食记录列表
     */
    public List<DietRecord> selectDietRecordsByUserIdAndDate(@Param("userId") Long userId, @Param("recordDate") Date recordDate);

    /**
     * 统计用户指定日期范围内的营养摄入总量
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 营养统计信息
     */
    public DietRecord selectNutritionSummaryByUserIdAndDateRange(@Param("userId") Long userId, @Param("startDate") Date startDate, @Param("endDate") Date endDate);

    /**
     * 【大盘专供】获取全站今日新增饮食记录数
     * @return 数量
     */
    public int selectGlobalTodayRecordsCount();

    /**
     * 【大盘专供】获取全站近10日每天产生的饮食流水数
     * @return map list
     */
    public List<java.util.Map<String, Object>> selectGlobalRecent10DaysRecordStats();

    /**
     * 【大盘专供】获取全网最高频上报的 5 大食物种类
     * @return map list
     */
    public List<java.util.Map<String, Object>> selectGlobalTop5HotFoods();
}
