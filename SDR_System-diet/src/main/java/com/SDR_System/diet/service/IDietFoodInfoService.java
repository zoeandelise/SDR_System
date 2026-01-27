package com.SDR_System.diet.service;

import java.util.List;
import com.SDR_System.system.domain.DietFoodInfo;

/**
 * 食物基础信息Service接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface IDietFoodInfoService 
{
    /**
     * 查询食物基础信息
     * 
     * @param foodId 食物基础信息主键
     * @return 食物基础信息
     */
    public DietFoodInfo selectDietFoodInfoByFoodId(Long foodId);

    /**
     * 查询食物基础信息列表
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 食物基础信息集合
     */
    public List<DietFoodInfo> selectDietFoodInfoList(DietFoodInfo dietFoodInfo);

    /**
     * 新增食物基础信息
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 结果
     */
    public int insertDietFoodInfo(DietFoodInfo dietFoodInfo);

    /**
     * 修改食物基础信息
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 结果
     */
    public int updateDietFoodInfo(DietFoodInfo dietFoodInfo);

    /**
     * 批量删除食物基础信息
     * 
     * @param foodIds 需要删除的食物基础信息主键集合
     * @return 结果
     */
    public int deleteDietFoodInfoByFoodIds(Long[] foodIds);

    /**
     * 删除食物基础信息信息
     * 
     * @param foodId 食物基础信息主键
     * @return 结果
     */
    public int deleteDietFoodInfoByFoodId(Long foodId);

    /**
     * 根据食物名称搜索食物
     * 
     * @param foodName 食物名称
     * @return 食物信息列表
     */
    public List<DietFoodInfo> selectDietFoodInfoByName(String foodName);

    /**
     * 根据分类ID查询食物
     * 
     * @param categoryId 分类ID
     * @return 食物信息列表
     */
    public List<DietFoodInfo> selectDietFoodInfoByCategoryId(Long categoryId);

    /**
     * 获取食物营养信息（包含营养数据）
     * 
     * @param foodId 食物ID
     * @return 包含营养信息的食物对象
     */
    public DietFoodInfo selectDietFoodInfoWithNutrition(Long foodId);

    /**
     * 批量导入食物信息
     * 
     * @param foodList 食物信息列表
     * @return 导入结果
     */
    public String importFoodInfo(List<DietFoodInfo> foodList);
}
