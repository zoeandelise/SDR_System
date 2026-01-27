package com.SDR_System.diet.service.impl;

import java.util.List;
import com.SDR_System.common.utils.DateUtils;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.SDR_System.diet.mapper.DietFoodInfoMapper;
import com.SDR_System.system.domain.DietFoodInfo;
import com.SDR_System.diet.service.IDietFoodInfoService;

/**
 * 食物基础信息Service业务层处理
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@Service
public class DietFoodInfoServiceImpl implements IDietFoodInfoService 
{
    @Autowired
    private DietFoodInfoMapper dietFoodInfoMapper;

    /**
     * 查询食物基础信息
     * 
     * @param foodId 食物基础信息主键
     * @return 食物基础信息
     */
    @Override
    public DietFoodInfo selectDietFoodInfoByFoodId(Long foodId)
    {
        return dietFoodInfoMapper.selectDietFoodInfoByFoodId(foodId);
    }

    /**
     * 查询食物基础信息列表
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 食物基础信息
     */
    @Override
    public List<DietFoodInfo> selectDietFoodInfoList(DietFoodInfo dietFoodInfo)
    {
        return dietFoodInfoMapper.selectDietFoodInfoList(dietFoodInfo);
    }

    /**
     * 新增食物基础信息
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 结果
     */
    @Override
    public int insertDietFoodInfo(DietFoodInfo dietFoodInfo)
    {
        dietFoodInfo.setCreateBy(SecurityUtils.getUsername());
        dietFoodInfo.setCreateTime(DateUtils.getNowDate());
        
        // 生成食物编码
        if (StringUtils.isEmpty(dietFoodInfo.getFoodCode())) {
            dietFoodInfo.setFoodCode(generateFoodCode(dietFoodInfo));
        }
        
        return dietFoodInfoMapper.insertDietFoodInfo(dietFoodInfo);
    }

    /**
     * 修改食物基础信息
     * 
     * @param dietFoodInfo 食物基础信息
     * @return 结果
     */
    @Override
    public int updateDietFoodInfo(DietFoodInfo dietFoodInfo)
    {
        dietFoodInfo.setUpdateBy(SecurityUtils.getUsername());
        dietFoodInfo.setUpdateTime(DateUtils.getNowDate());
        return dietFoodInfoMapper.updateDietFoodInfo(dietFoodInfo);
    }

    /**
     * 批量删除食物基础信息
     * 
     * @param foodIds 需要删除的食物基础信息主键
     * @return 结果
     */
    @Override
    public int deleteDietFoodInfoByFoodIds(Long[] foodIds)
    {
        return dietFoodInfoMapper.deleteDietFoodInfoByFoodIds(foodIds);
    }

    /**
     * 删除食物基础信息信息
     * 
     * @param foodId 食物基础信息主键
     * @return 结果
     */
    @Override
    public int deleteDietFoodInfoByFoodId(Long foodId)
    {
        return dietFoodInfoMapper.deleteDietFoodInfoByFoodId(foodId);
    }

    /**
     * 根据食物名称搜索食物
     * 
     * @param foodName 食物名称
     * @return 食物信息列表
     */
    @Override
    public List<DietFoodInfo> selectDietFoodInfoByName(String foodName)
    {
        return dietFoodInfoMapper.selectDietFoodInfoByName(foodName);
    }

    /**
     * 根据分类ID查询食物
     * 
     * @param categoryId 分类ID
     * @return 食物信息列表
     */
    @Override
    public List<DietFoodInfo> selectDietFoodInfoByCategoryId(Long categoryId)
    {
        return dietFoodInfoMapper.selectDietFoodInfoByCategoryId(categoryId);
    }

    /**
     * 获取食物营养信息（包含营养数据）
     * 
     * @param foodId 食物ID
     * @return 包含营养信息的食物对象
     */
    @Override
    public DietFoodInfo selectDietFoodInfoWithNutrition(Long foodId)
    {
        // TODO: 实现包含营养信息的查询
        DietFoodInfo foodInfo = dietFoodInfoMapper.selectDietFoodInfoByFoodId(foodId);
        if (foodInfo != null) {
            // 这里可以关联查询营养信息
            // DietFoodNutrition nutrition = dietFoodNutritionMapper.selectByFoodId(foodId);
            // foodInfo.setNutrition(nutrition);
        }
        return foodInfo;
    }

    /**
     * 批量导入食物信息
     * 
     * @param foodList 食物信息列表
     * @return 导入结果
     */
    @Override
    public String importFoodInfo(List<DietFoodInfo> foodList)
    {
        if (StringUtils.isNull(foodList) || foodList.size() == 0) {
            return "导入食物数据不能为空！";
        }
        
        int successNum = 0;
        int failureNum = 0;
        StringBuilder successMsg = new StringBuilder();
        StringBuilder failureMsg = new StringBuilder();
        
        for (DietFoodInfo food : foodList) {
            try {
                // 验证食物名称是否已存在
                List<DietFoodInfo> existingFoods = this.selectDietFoodInfoByName(food.getFoodName());
                if (existingFoods.size() > 0) {
                    failureNum++;
                    failureMsg.append("<br/>").append(failureNum).append("、食物 ").append(food.getFoodName()).append(" 已存在");
                } else {
                    this.insertDietFoodInfo(food);
                    successNum++;
                    successMsg.append("<br/>").append(successNum).append("、食物 ").append(food.getFoodName()).append(" 导入成功");
                }
            } catch (Exception e) {
                failureNum++;
                String msg = "<br/>" + failureNum + "、食物 " + food.getFoodName() + " 导入失败：";
                failureMsg.append(msg).append(e.getMessage());
            }
        }
        
        if (failureNum > 0) {
            failureMsg.insert(0, "很抱歉，导入失败！共 " + failureNum + " 条数据格式不正确，错误如下：");
            throw new RuntimeException(failureMsg.toString());
        } else {
            successMsg.insert(0, "恭喜您，数据已全部导入成功！共 " + successNum + " 条，数据如下：");
        }
        
        return successMsg.toString();
    }

    /**
     * 生成食物编码
     * 
     * @param dietFoodInfo 食物信息
     * @return 食物编码
     */
    private String generateFoodCode(DietFoodInfo dietFoodInfo) {
        // 简单的编码生成规则：分类ID + 时间戳后6位
        String categoryPrefix = dietFoodInfo.getCategoryId() != null ? 
            String.format("%02d", dietFoodInfo.getCategoryId()) : "00";
        String timestamp = String.valueOf(System.currentTimeMillis()).substring(7);
        return "FOOD" + categoryPrefix + timestamp;
    }
}
