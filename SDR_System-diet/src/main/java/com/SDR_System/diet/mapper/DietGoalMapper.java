package com.SDR_System.diet.mapper;

import java.util.List;
import java.math.BigDecimal;
import java.util.Date;
import org.apache.ibatis.annotations.Param;
import com.SDR_System.diet.domain.DietGoal;

/**
 * 健康目标Mapper接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface DietGoalMapper 
{
    /**
     * 查询健康目标
     * 
     * @param goalId 健康目标主键
     * @return 健康目标
     */
    public DietGoal selectDietGoalByGoalId(Long goalId);

    /**
     * 查询健康目标列表
     * 
     * @param dietGoal 健康目标
     * @return 健康目标集合
     */
    public List<DietGoal> selectDietGoalList(DietGoal dietGoal);

    /**
     * 新增健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    public int insertDietGoal(DietGoal dietGoal);

    /**
     * 修改健康目标
     * 
     * @param dietGoal 健康目标
     * @return 结果
     */
    public int updateDietGoal(DietGoal dietGoal);

    /**
     * 删除健康目标
     * 
     * @param goalId 健康目标主键
     * @return 结果
     */
    public int deleteDietGoalByGoalId(Long goalId);

    /**
     * 批量删除健康目标
     * 
     * @param goalIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDietGoalByGoalIds(Long[] goalIds);

    /**
     * 更新目标进度
     * 
     * @param goalId 目标ID
     * @param currentValue 当前值
     * @param completionPercentage 完成百分比
     * @return 结果
     */
    public int updateGoalProgress(@Param("goalId") Long goalId, 
                                  @Param("currentValue") BigDecimal currentValue, 
                                  @Param("completionPercentage") BigDecimal completionPercentage);

    /**
     * 更新目标状态
     * 
     * @param goalId 目标ID
     * @param status 状态
     * @return 结果
     */
    public int updateGoalStatus(@Param("goalId") Long goalId, @Param("status") String status);

    /**
     * 根据用户ID查询目标统计
     * 
     * @param userId 用户ID
     * @return 统计结果
     */
    public List<DietGoal> selectGoalStatsByUserId(@Param("userId") Long userId);

    /**
     * 查询即将到期的目标
     * 
     * @param userId 用户ID
     * @param days 天数
     * @return 目标列表
     */
    public List<DietGoal> selectSoonExpireGoals(@Param("userId") Long userId, @Param("days") Integer days);
}
