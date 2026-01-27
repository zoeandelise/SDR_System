package com.SDR_System.diet.service.impl;

import java.util.List;
import java.util.Date;
import java.util.ArrayList;
import java.math.BigDecimal;
import com.SDR_System.common.utils.DateUtils;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.SDR_System.diet.mapper.DietRecordMapper;
import com.SDR_System.system.domain.DietRecord;
// MongoDB相关已移除 - V2.0仅使用MySQL
// import com.SDR_System.diet.domain.mongo.DietRecordDetail;
// import com.SDR_System.diet.repository.DietRecordDetailRepository;
import com.SDR_System.diet.service.IDietRecordService;
import com.SDR_System.diet.service.IDietFoodInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 饮食记录Service业务层处理
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
public class DietRecordServiceImpl implements IDietRecordService 
{
    private static final Logger logger = LoggerFactory.getLogger(DietRecordServiceImpl.class);

    @Autowired
    private DietRecordMapper dietRecordMapper;

    // MongoDB Repository已移除 - V2.0仅使用MySQL
    // @Autowired(required = false)
    // private DietRecordDetailRepository dietRecordDetailRepository;

    @Autowired
    private IDietFoodInfoService dietFoodInfoService;

    /**
     * 查询饮食记录
     * 
     * @param recordId 饮食记录主键
     * @return 饮食记录
     */
    @Override
    public DietRecord selectDietRecordByRecordId(Long recordId)
    {
        return dietRecordMapper.selectDietRecordByRecordId(recordId);
    }

    /**
     * 查询饮食记录列表
     * 
     * @param dietRecord 饮食记录
     * @return 饮食记录
     */
    @Override
    public List<DietRecord> selectDietRecordList(DietRecord dietRecord)
    {
        return dietRecordMapper.selectDietRecordList(dietRecord);
    }

    /**
     * 新增饮食记录
     * 
     * @param dietRecord 饮食记录
     * @return 结果
     */
    @Override
    @Transactional
    public int insertDietRecord(DietRecord dietRecord)
    {
        dietRecord.setCreateTime(DateUtils.getNowDate());
        
        // 如果没有设置用户ID，使用当前登录用户
        if (dietRecord.getUserId() == null) {
            dietRecord.setUserId(SecurityUtils.getUserId());
        }
        
        // 设置默认值
        if (dietRecord.getTotalCalories() == null) {
            dietRecord.setTotalCalories(BigDecimal.ZERO);
        }
        if (dietRecord.getTotalProtein() == null) {
            dietRecord.setTotalProtein(BigDecimal.ZERO);
        }
        if (dietRecord.getTotalFat() == null) {
            dietRecord.setTotalFat(BigDecimal.ZERO);
        }
        if (dietRecord.getTotalCarbohydrate() == null) {
            dietRecord.setTotalCarbohydrate(BigDecimal.ZERO);
        }
        
        return dietRecordMapper.insertDietRecord(dietRecord);
    }

    /**
     * 修改饮食记录
     * 
     * @param dietRecord 饮食记录
     * @return 结果
     */
    @Override
    public int updateDietRecord(DietRecord dietRecord)
    {
        dietRecord.setUpdateTime(DateUtils.getNowDate());
        return dietRecordMapper.updateDietRecord(dietRecord);
    }

    /**
     * 批量删除饮食记录
     * 
     * @param recordIds 需要删除的饮食记录主键
     * @return 结果
     */
    @Override
    @Transactional
    public int deleteDietRecordByRecordIds(Long[] recordIds)
    {
        // V2.0: MongoDB已移除，直接删除MySQL记录
        return dietRecordMapper.deleteDietRecordByRecordIds(recordIds);
    }

    /**
     * 删除饮食记录信息
     * 
     * @param recordId 饮食记录主键
     * @return 结果
     */
    @Override
    @Transactional
    public int deleteDietRecordByRecordId(Long recordId)
    {
        // V2.0: MongoDB已移除，直接删除MySQL记录
        return dietRecordMapper.deleteDietRecordByRecordId(recordId);
    }

    /**
     * 根据用户ID和日期范围查询饮食记录
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 饮食记录列表
     */
    @Override
    public List<DietRecord> selectDietRecordsByUserIdAndDateRange(Long userId, Date startDate, Date endDate)
    {
        return dietRecordMapper.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
    }

    /**
     * 根据用户ID和日期查询当日饮食记录
     * 
     * @param userId 用户ID
     * @param recordDate 记录日期
     * @return 饮食记录列表
     */
    @Override
    public List<DietRecord> selectDietRecordsByUserIdAndDate(Long userId, Date recordDate)
    {
        return dietRecordMapper.selectDietRecordsByUserIdAndDate(userId, recordDate);
    }

    /**
     * 统计用户指定日期范围内的营养摄入总量
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 营养统计信息
     */
    @Override
    public DietRecord selectNutritionSummaryByUserIdAndDateRange(Long userId, Date startDate, Date endDate)
    {
        return dietRecordMapper.selectNutritionSummaryByUserIdAndDateRange(userId, startDate, endDate);
    }

    // ========================================
    // MongoDB相关方法已移除 - V2.0仅使用MySQL
    // ========================================
    
    /*
    // 以下方法已弃用，因为系统不再使用MongoDB
    
    @Override
    @Transactional
    public int insertDietRecordWithDetail(DietRecord dietRecord, DietRecordDetail recordDetail) {
        // V2.0: 仅插入MySQL记录，不再使用MongoDB
        return this.insertDietRecord(dietRecord);
    }
    
    @Override
    public DietRecordDetail selectDietRecordDetailByRecordId(Long recordId) {
        // V2.0: MongoDB已移除，返回null
        return null;
    }
    
    @Override
    public DietRecord calculateAndUpdateNutritionSummary(DietRecordDetail recordDetail) {
        // V2.0: MongoDB已移除，方法已弃用
        return null;
    }
    */

    /**
     * 获取用户饮食统计报告
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 统计报告
     */
    @Override
    public DietStatisticsReport getDietStatisticsReport(Long userId, Date startDate, Date endDate)
    {
        DietStatisticsReport report = new DietStatisticsReport();
        
        // 获取基础统计数据
        List<DietRecord> records = this.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
        report.setTotalRecords((long) records.size());
        
        if (!records.isEmpty()) {
            // 计算平均值
            double totalCalories = 0, totalProtein = 0, totalFat = 0, totalCarbohydrate = 0;
            List<DailyCalorieTrend> dailyTrends = new ArrayList<>();
            
            for (DietRecord record : records) {
                totalCalories += record.getTotalCalories() != null ? record.getTotalCalories().doubleValue() : 0;
                totalProtein += record.getTotalProtein() != null ? record.getTotalProtein().doubleValue() : 0;
                totalFat += record.getTotalFat() != null ? record.getTotalFat().doubleValue() : 0;
                totalCarbohydrate += record.getTotalCarbohydrate() != null ? record.getTotalCarbohydrate().doubleValue() : 0;
                
                // 构建趋势数据
                DailyCalorieTrend trend = new DailyCalorieTrend();
                trend.setDate(record.getRecordDate());
                trend.setCalories(record.getTotalCalories() != null ? record.getTotalCalories().doubleValue() : 0);
                trend.setProtein(record.getTotalProtein() != null ? record.getTotalProtein().doubleValue() : 0);
                trend.setFat(record.getTotalFat() != null ? record.getTotalFat().doubleValue() : 0);
                trend.setCarbohydrate(record.getTotalCarbohydrate() != null ? record.getTotalCarbohydrate().doubleValue() : 0);
                dailyTrends.add(trend);
            }
            
            // 计算天数
            long daysBetween = DateUtils.differentDaysByMillisecond(startDate, endDate) + 1;
            
            report.setAvgDailyCalories(totalCalories / daysBetween);
            report.setAvgDailyProtein(totalProtein / daysBetween);
            report.setAvgDailyFat(totalFat / daysBetween);
            report.setAvgDailyCarbohydrate(totalCarbohydrate / daysBetween);
            report.setDailyTrends(dailyTrends);
            
            // TODO: 实现最常吃的食物统计
            report.setMostFrequentFoods(new ArrayList<>());
        }
        
        return report;
    }

    // ========================================
    // MongoDB相关私有方法已移除 - V2.0仅使用MySQL
    // 如需详细记录功能，建议使用MySQL的JSON字段存储
    // ========================================
}
