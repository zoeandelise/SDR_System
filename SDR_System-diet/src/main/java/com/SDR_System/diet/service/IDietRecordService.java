package com.SDR_System.diet.service;

import java.util.List;
import java.util.Date;
import com.SDR_System.system.domain.DietRecord;
// MongoDB相关已移除 - V2.0仅使用MySQL
// import com.SDR_System.diet.domain.mongo.DietRecordDetail;

/**
 * 饮食记录Service接口
 * 
 * V2.0: MongoDB相关方法已移除，仅使用MySQL
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IDietRecordService 
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
     * 批量删除饮食记录
     * 
     * @param recordIds 需要删除的饮食记录主键集合
     * @return 结果
     */
    public int deleteDietRecordByRecordIds(Long[] recordIds);

    /**
     * 删除饮食记录信息
     * 
     * @param recordId 饮食记录主键
     * @return 结果
     */
    public int deleteDietRecordByRecordId(Long recordId);

    /**
     * 根据用户ID和日期范围查询饮食记录
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 饮食记录列表
     */
    public List<DietRecord> selectDietRecordsByUserIdAndDateRange(Long userId, Date startDate, Date endDate);

    /**
     * 根据用户ID和日期查询当日饮食记录
     * 
     * @param userId 用户ID
     * @param recordDate 记录日期
     * @return 饮食记录列表
     */
    public List<DietRecord> selectDietRecordsByUserIdAndDate(Long userId, Date recordDate);

    /**
     * 统计用户指定日期范围内的营养摄入总量
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 营养统计信息
     */
    public DietRecord selectNutritionSummaryByUserIdAndDateRange(Long userId, Date startDate, Date endDate);

    // ========================================
    // MongoDB相关方法已移除 - V2.0仅使用MySQL
    // ========================================
    
    /*
    public int insertDietRecordWithDetail(DietRecord dietRecord, DietRecordDetail recordDetail);
    public DietRecordDetail selectDietRecordDetailByRecordId(Long recordId);
    public DietRecord calculateAndUpdateNutritionSummary(DietRecordDetail recordDetail);
    public DietRecordDetail createDietRecordDetail(List<DietRecordDetail.FoodItem> foodItems, 
                                                   Long userId, Date recordDate, String mealType);
    */

    /**
     * 获取用户饮食统计报告
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 统计报告
     */
    public DietStatisticsReport getDietStatisticsReport(Long userId, Date startDate, Date endDate);


    /**
     * 饮食统计报告
     */
    class DietStatisticsReport {
        /** 总记录数 */
        private Long totalRecords;
        
        /** 平均每日热量 */
        private Double avgDailyCalories;
        
        /** 平均每日蛋白质 */
        private Double avgDailyProtein;
        
        /** 平均每日脂肪 */
        private Double avgDailyFat;
        
        /** 平均每日碳水化合物 */
        private Double avgDailyCarbohydrate;
        
        /** 最常吃的食物 */
        private List<String> mostFrequentFoods;
        
        /** 每日热量趋势 */
        private List<DailyCalorieTrend> dailyTrends;

        // Getters and Setters
        public Long getTotalRecords() { return totalRecords; }
        public void setTotalRecords(Long totalRecords) { this.totalRecords = totalRecords; }

        public Double getAvgDailyCalories() { return avgDailyCalories; }
        public void setAvgDailyCalories(Double avgDailyCalories) { this.avgDailyCalories = avgDailyCalories; }

        public Double getAvgDailyProtein() { return avgDailyProtein; }
        public void setAvgDailyProtein(Double avgDailyProtein) { this.avgDailyProtein = avgDailyProtein; }

        public Double getAvgDailyFat() { return avgDailyFat; }
        public void setAvgDailyFat(Double avgDailyFat) { this.avgDailyFat = avgDailyFat; }

        public Double getAvgDailyCarbohydrate() { return avgDailyCarbohydrate; }
        public void setAvgDailyCarbohydrate(Double avgDailyCarbohydrate) { this.avgDailyCarbohydrate = avgDailyCarbohydrate; }

        public List<String> getMostFrequentFoods() { return mostFrequentFoods; }
        public void setMostFrequentFoods(List<String> mostFrequentFoods) { this.mostFrequentFoods = mostFrequentFoods; }

        public List<DailyCalorieTrend> getDailyTrends() { return dailyTrends; }
        public void setDailyTrends(List<DailyCalorieTrend> dailyTrends) { this.dailyTrends = dailyTrends; }
    }

    /**
     * 每日热量趋势
     */
    class DailyCalorieTrend {
        /** 日期 */
        private Date date;
        
        /** 热量 */
        private Double calories;
        
        /** 蛋白质 */
        private Double protein;
        
        /** 脂肪 */
        private Double fat;
        
        /** 碳水化合物 */
        private Double carbohydrate;

        // Getters and Setters
        public Date getDate() { return date; }
        public void setDate(Date date) { this.date = date; }

        public Double getCalories() { return calories; }
        public void setCalories(Double calories) { this.calories = calories; }

        public Double getProtein() { return protein; }
        public void setProtein(Double protein) { this.protein = protein; }

        public Double getFat() { return fat; }
        public void setFat(Double fat) { this.fat = fat; }

        public Double getCarbohydrate() { return carbohydrate; }
        public void setCarbohydrate(Double carbohydrate) { this.carbohydrate = carbohydrate; }
    }
}
