package com.SDR_System.diet.mapper;

import java.util.List;
import java.util.Date;
import org.apache.ibatis.annotations.Param;
import com.SDR_System.diet.domain.DietRecommendation;

/**
 * 饮食推荐Mapper接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface DietRecommendationMapper 
{
    /**
     * 查询饮食推荐
     * 
     * @param recommendationId 饮食推荐主键
     * @return 饮食推荐
     */
    public DietRecommendation selectDietRecommendationByRecommendationId(Long recommendationId);

    /**
     * 查询饮食推荐列表
     * 
     * @param dietRecommendation 饮食推荐
     * @return 饮食推荐集合
     */
    public List<DietRecommendation> selectDietRecommendationList(DietRecommendation dietRecommendation);

    /**
     * 新增饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    public int insertDietRecommendation(DietRecommendation dietRecommendation);

    /**
     * 修改饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    public int updateDietRecommendation(DietRecommendation dietRecommendation);

    /**
     * 删除饮食推荐
     * 
     * @param recommendationId 饮食推荐主键
     * @return 结果
     */
    public int deleteDietRecommendationByRecommendationId(Long recommendationId);

    /**
     * 批量删除饮食推荐
     * 
     * @param recommendationIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDietRecommendationByRecommendationIds(Long[] recommendationIds);

    /**
     * 根据用户ID和日期查询推荐方案
     * 
     * @param userId 用户ID
     * @param date 日期
     * @return 推荐方案
     */
    public DietRecommendation selectDietRecommendationByUserIdAndDate(@Param("userId") Long userId, @Param("date") Date date);

    /**
     * 根据用户ID和日期范围查询推荐方案列表
     * 
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 推荐方案列表
     */
    public List<DietRecommendation> selectDietRecommendationsByUserIdAndDateRange(
        @Param("userId") Long userId, 
        @Param("startDate") Date startDate, 
        @Param("endDate") Date endDate
    );

    /**
     * 更新推荐方案状态
     * 
     * @param recommendationId 推荐方案ID
     * @param status 状态
     * @return 结果
     */
    public int updateDietRecommendationStatus(@Param("recommendationId") Long recommendationId, @Param("status") String status);
}
