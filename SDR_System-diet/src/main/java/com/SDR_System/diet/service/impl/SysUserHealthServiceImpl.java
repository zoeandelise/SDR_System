package com.SDR_System.diet.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import com.SDR_System.common.utils.DateUtils;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.SDR_System.diet.mapper.SysUserHealthMapper;
import com.SDR_System.system.domain.SysUserHealth;
import com.SDR_System.diet.service.ISysUserHealthService;

/**
 * 用户健康信息Service业务层处理
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
public class SysUserHealthServiceImpl implements ISysUserHealthService 
{
    @Autowired
    private SysUserHealthMapper sysUserHealthMapper;

    /**
     * 查询用户健康信息
     * 
     * @param healthId 用户健康信息主键
     * @return 用户健康信息
     */
    @Override
    public SysUserHealth selectSysUserHealthByHealthId(Long healthId)
    {
        return sysUserHealthMapper.selectSysUserHealthByHealthId(healthId);
    }

    /**
     * 根据用户ID查询用户健康信息
     * 
     * @param userId 用户ID
     * @return 用户健康信息
     */
    @Override
    public SysUserHealth selectSysUserHealthByUserId(Long userId)
    {
        SysUserHealth userHealth = sysUserHealthMapper.selectSysUserHealthByUserId(userId);
        if (userHealth != null) {
            // 计算并设置BMI
            userHealth.calculateBmi();
        }
        return userHealth;
    }

    /**
     * 查询用户健康信息列表
     * 
     * @param sysUserHealth 用户健康信息
     * @return 用户健康信息
     */
    @Override
    public List<SysUserHealth> selectSysUserHealthList(SysUserHealth sysUserHealth)
    {
        List<SysUserHealth> list = sysUserHealthMapper.selectSysUserHealthList(sysUserHealth);
        // 为每个用户健康信息计算BMI
        for (SysUserHealth userHealth : list) {
            userHealth.calculateBmi();
        }
        return list;
    }

    /**
     * 新增用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    @Override
    public int insertSysUserHealth(SysUserHealth sysUserHealth)
    {
        // 计算BMI
        sysUserHealth.calculateBmi();
        
        // 计算每日热量目标
        if (sysUserHealth.getDailyCalorieGoal() == null) {
            Integer calorieGoal = this.calculateDailyCalorieNeedForHealth(sysUserHealth);
            sysUserHealth.setDailyCalorieGoal(calorieGoal);
        }
        
        sysUserHealth.setCreateTime(DateUtils.getNowDate());
        return sysUserHealthMapper.insertSysUserHealth(sysUserHealth);
    }

    /**
     * 修改用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    @Override
    public int updateSysUserHealth(SysUserHealth sysUserHealth)
    {
        // 重新计算BMI
        sysUserHealth.calculateBmi();
        
        // 重新计算每日热量目标
        if (sysUserHealth.getDailyCalorieGoal() == null) {
            Integer calorieGoal = this.calculateDailyCalorieNeedForHealth(sysUserHealth);
            sysUserHealth.setDailyCalorieGoal(calorieGoal);
        }
        
        sysUserHealth.setUpdateTime(DateUtils.getNowDate());
        return sysUserHealthMapper.updateSysUserHealth(sysUserHealth);
    }

    /**
     * 批量删除用户健康信息
     * 
     * @param healthIds 需要删除的用户健康信息主键
     * @return 结果
     */
    @Override
    public int deleteSysUserHealthByHealthIds(Long[] healthIds)
    {
        return sysUserHealthMapper.deleteSysUserHealthByHealthIds(healthIds);
    }

    /**
     * 删除用户健康信息信息
     * 
     * @param healthId 用户健康信息主键
     * @return 结果
     */
    @Override
    public int deleteSysUserHealthByHealthId(Long healthId)
    {
        return sysUserHealthMapper.deleteSysUserHealthByHealthId(healthId);
    }

    /**
     * 计算用户BMI
     * 
     * @param userId 用户ID
     * @return BMI值
     */
    @Override
    public Double calculateUserBMI(Long userId)
    {
        SysUserHealth userHealth = this.selectSysUserHealthByUserId(userId);
        if (userHealth != null && userHealth.getBmi() != null) {
            return userHealth.getBmi().doubleValue();
        }
        return null;
    }

    /**
     * 计算用户每日热量需求
     * 
     * @param userId 用户ID
     * @return 每日热量需求(kcal)
     */
    @Override
    public Integer calculateDailyCalorieNeed(Long userId)
    {
        SysUserHealth userHealth = this.selectSysUserHealthByUserId(userId);
        if (userHealth != null) {
            return this.calculateDailyCalorieNeedForHealth(userHealth);
        }
        return null;
    }

    /**
     * 获取用户健康评估报告
     * 
     * @param userId 用户ID
     * @return 健康评估报告
     */
    @Override
    public HealthAssessmentReport getHealthAssessmentReport(Long userId)
    {
        SysUserHealth userHealth = this.selectSysUserHealthByUserId(userId);
        if (userHealth == null) {
            return null;
        }

        HealthAssessmentReport report = new HealthAssessmentReport();
        report.setUserId(userId);
        
        // BMI相关信息
        Double bmi = userHealth.getBmi() != null ? userHealth.getBmi().doubleValue() : null;
        report.setBmi(bmi);
        report.setBmiCategory(this.getBmiCategory(bmi));
        
        // 每日营养需求
        Integer dailyCalories = this.calculateDailyCalorieNeedForHealth(userHealth);
        report.setDailyCalorieNeed(dailyCalories);
        
        if (dailyCalories != null) {
            // 按比例计算营养素需求
            report.setDailyProteinNeed(dailyCalories * 0.15 / 4); // 蛋白质4kcal/g
            report.setDailyFatNeed(dailyCalories * 0.25 / 9); // 脂肪9kcal/g
            report.setDailyCarbohydrateNeed(dailyCalories * 0.60 / 4); // 碳水4kcal/g
        }
        
        // 健康建议
        List<String> suggestions = this.generateHealthSuggestions(userHealth);
        report.setHealthSuggestions(suggestions);
        
        // 风险提示
        List<String> warnings = this.generateRiskWarnings(userHealth);
        report.setRiskWarnings(warnings);
        
        return report;
    }

    /**
     * 根据健康信息计算每日热量需求
     * 
     * @param userHealth 用户健康信息
     * @return 每日热量需求
     */
    private Integer calculateDailyCalorieNeedForHealth(SysUserHealth userHealth) {
        if (userHealth.getWeight() == null || userHealth.getHeight() == null || 
            userHealth.getAge() == null || StringUtils.isEmpty(userHealth.getGender())) {
            return null;
        }
        
        double weight = userHealth.getWeight().doubleValue();
        double height = userHealth.getHeight().doubleValue();
        int age = userHealth.getAge();
        String gender = userHealth.getGender();
        
        // 使用Harris-Benedict公式计算基础代谢率(BMR)
        double bmr;
        if ("0".equals(gender)) { // 男性
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
        } else { // 女性
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
        }
        
        // 根据活动水平调整
        double[] activityFactors = {1.2, 1.375, 1.55, 1.725, 1.9}; // 久坐到极重度活动
        String activityLevel = userHealth.getActivityLevel() != null ? userHealth.getActivityLevel() : "2";
        int activityIndex = Integer.parseInt(activityLevel);
        if (activityIndex < 0 || activityIndex >= activityFactors.length) {
            activityIndex = 2; // 默认中度活动
        }
        
        double tdee = bmr * activityFactors[activityIndex];
        
        // 根据健康目标调整
        String healthGoal = userHealth.getHealthGoal() != null ? userHealth.getHealthGoal() : "0";
        switch (healthGoal) {
            case "1": // 减脂
                tdee *= 0.8; // 减少20%
                break;
            case "2": // 增肌
                tdee *= 1.1; // 增加10%
                break;
            case "3": // 增重
                tdee *= 1.2; // 增加20%
                break;
            default: // 保持
                // 不变
                break;
        }
        
        return (int) Math.round(tdee);
    }

    /**
     * 获取BMI分类
     * 
     * @param bmi BMI值
     * @return BMI分类
     */
    private String getBmiCategory(Double bmi) {
        if (bmi == null) {
            return "未知";
        }
        
        if (bmi < 18.5) {
            return "偏瘦";
        } else if (bmi < 24.0) {
            return "正常";
        } else if (bmi < 28.0) {
            return "偏胖";
        } else {
            return "肥胖";
        }
    }

    /**
     * 生成健康建议
     * 
     * @param userHealth 用户健康信息
     * @return 健康建议列表
     */
    private List<String> generateHealthSuggestions(SysUserHealth userHealth) {
        List<String> suggestions = new ArrayList<>();
        
        Double bmi = userHealth.getBmi() != null ? userHealth.getBmi().doubleValue() : null;
        if (bmi != null) {
            if (bmi < 18.5) {
                suggestions.add("您的体重偏轻，建议适当增加营养摄入，多吃高蛋白、高热量的健康食物");
                suggestions.add("建议进行适量的力量训练，帮助增加肌肉量");
            } else if (bmi >= 28.0) {
                suggestions.add("您的体重偏重，建议控制热量摄入，增加有氧运动");
                suggestions.add("建议选择低热量、高纤维的食物，如蔬菜、水果和全谷物");
            } else if (bmi >= 24.0) {
                suggestions.add("您的体重略高，建议保持均衡饮食，适量运动");
            } else {
                suggestions.add("您的体重正常，请继续保持健康的生活方式");
            }
        }
        
        // 根据健康目标给建议
        String healthGoal = userHealth.getHealthGoal();
        if ("1".equals(healthGoal)) {
            suggestions.add("减脂期间建议增加蛋白质摄入，减少精制碳水化合物");
            suggestions.add("建议结合有氧运动和力量训练，提高减脂效率");
        } else if ("2".equals(healthGoal)) {
            suggestions.add("增肌期间建议充足的蛋白质摄入，每公斤体重1.6-2.2g蛋白质");
            suggestions.add("建议进行规律的力量训练，确保充足的休息");
        }
        
        // 根据年龄给建议
        if (userHealth.getAge() != null) {
            int age = userHealth.getAge();
            if (age >= 60) {
                suggestions.add("建议增加钙质和维生素D的摄入，预防骨质疏松");
                suggestions.add("建议进行适合的低冲击运动，如散步、游泳等");
            } else if (age >= 40) {
                suggestions.add("建议定期体检，关注心血管健康");
                suggestions.add("建议增加抗氧化食物的摄入，如蓝莓、绿茶等");
            }
        }
        
        return suggestions;
    }

    /**
     * 生成风险提示
     * 
     * @param userHealth 用户健康信息
     * @return 风险提示列表
     */
    private List<String> generateRiskWarnings(SysUserHealth userHealth) {
        List<String> warnings = new ArrayList<>();
        
        // BMI相关风险
        Double bmi = userHealth.getBmi() != null ? userHealth.getBmi().doubleValue() : null;
        if (bmi != null) {
            if (bmi < 16.0) {
                warnings.add("严重体重不足，建议咨询医生或营养师");
            } else if (bmi >= 35.0) {
                warnings.add("重度肥胖，存在健康风险，建议寻求专业医疗帮助");
            } else if (bmi >= 30.0) {
                warnings.add("肥胖可能增加糖尿病、心血管疾病等风险");
            }
        }
        
        // 疾病相关风险
        if (StringUtils.isNotEmpty(userHealth.getDiseases())) {
            warnings.add("请根据您的疾病情况，在医生指导下调整饮食");
        }
        
        // 过敏相关风险
        if (StringUtils.isNotEmpty(userHealth.getAllergies())) {
            warnings.add("请注意避免过敏食物，仔细查看食物成分");
        }
        
        return warnings;
    }
}
