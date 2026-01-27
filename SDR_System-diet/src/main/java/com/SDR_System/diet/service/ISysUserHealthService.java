package com.SDR_System.diet.service;

import java.util.List;
import com.SDR_System.system.domain.SysUserHealth;

/**
 * 用户健康信息Service接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface ISysUserHealthService 
{
    /**
     * 查询用户健康信息
     * 
     * @param healthId 用户健康信息主键
     * @return 用户健康信息
     */
    public SysUserHealth selectSysUserHealthByHealthId(Long healthId);

    /**
     * 根据用户ID查询用户健康信息
     * 
     * @param userId 用户ID
     * @return 用户健康信息
     */
    public SysUserHealth selectSysUserHealthByUserId(Long userId);

    /**
     * 查询用户健康信息列表
     * 
     * @param sysUserHealth 用户健康信息
     * @return 用户健康信息集合
     */
    public List<SysUserHealth> selectSysUserHealthList(SysUserHealth sysUserHealth);

    /**
     * 新增用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    public int insertSysUserHealth(SysUserHealth sysUserHealth);

    /**
     * 修改用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    public int updateSysUserHealth(SysUserHealth sysUserHealth);

    /**
     * 批量删除用户健康信息
     * 
     * @param healthIds 需要删除的用户健康信息主键集合
     * @return 结果
     */
    public int deleteSysUserHealthByHealthIds(Long[] healthIds);

    /**
     * 删除用户健康信息信息
     * 
     * @param healthId 用户健康信息主键
     * @return 结果
     */
    public int deleteSysUserHealthByHealthId(Long healthId);

    /**
     * 计算用户BMI
     * 
     * @param userId 用户ID
     * @return BMI值
     */
    public Double calculateUserBMI(Long userId);

    /**
     * 计算用户每日热量需求
     * 
     * @param userId 用户ID
     * @return 每日热量需求(kcal)
     */
    public Integer calculateDailyCalorieNeed(Long userId);

    /**
     * 获取用户健康评估报告
     * 
     * @param userId 用户ID
     * @return 健康评估报告
     */
    public HealthAssessmentReport getHealthAssessmentReport(Long userId);

    /**
     * 健康评估报告
     */
    class HealthAssessmentReport {
        /** 用户ID */
        private Long userId;
        
        /** BMI值 */
        private Double bmi;
        
        /** BMI评级 */
        private String bmiCategory;
        
        /** 每日热量需求 */
        private Integer dailyCalorieNeed;
        
        /** 每日蛋白质需求(g) */
        private Double dailyProteinNeed;
        
        /** 每日脂肪需求(g) */
        private Double dailyFatNeed;
        
        /** 每日碳水化合物需求(g) */
        private Double dailyCarbohydrateNeed;
        
        /** 健康建议 */
        private List<String> healthSuggestions;
        
        /** 风险提示 */
        private List<String> riskWarnings;

        // Getters and Setters
        public Long getUserId() { return userId; }
        public void setUserId(Long userId) { this.userId = userId; }

        public Double getBmi() { return bmi; }
        public void setBmi(Double bmi) { this.bmi = bmi; }

        public String getBmiCategory() { return bmiCategory; }
        public void setBmiCategory(String bmiCategory) { this.bmiCategory = bmiCategory; }

        public Integer getDailyCalorieNeed() { return dailyCalorieNeed; }
        public void setDailyCalorieNeed(Integer dailyCalorieNeed) { this.dailyCalorieNeed = dailyCalorieNeed; }

        public Double getDailyProteinNeed() { return dailyProteinNeed; }
        public void setDailyProteinNeed(Double dailyProteinNeed) { this.dailyProteinNeed = dailyProteinNeed; }

        public Double getDailyFatNeed() { return dailyFatNeed; }
        public void setDailyFatNeed(Double dailyFatNeed) { this.dailyFatNeed = dailyFatNeed; }

        public Double getDailyCarbohydrateNeed() { return dailyCarbohydrateNeed; }
        public void setDailyCarbohydrateNeed(Double dailyCarbohydrateNeed) { this.dailyCarbohydrateNeed = dailyCarbohydrateNeed; }

        public List<String> getHealthSuggestions() { return healthSuggestions; }
        public void setHealthSuggestions(List<String> healthSuggestions) { this.healthSuggestions = healthSuggestions; }

        public List<String> getRiskWarnings() { return riskWarnings; }
        public void setRiskWarnings(List<String> riskWarnings) { this.riskWarnings = riskWarnings; }
    }
}
