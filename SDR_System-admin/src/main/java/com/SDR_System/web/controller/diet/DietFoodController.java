package com.SDR_System.web.controller.diet;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.system.domain.DietFoodInfo;
import com.SDR_System.diet.service.IDietFoodInfoService;
import com.SDR_System.common.utils.poi.ExcelUtil;
import com.SDR_System.common.core.page.TableDataInfo;

/**
 * 食物基础信息Controller
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/diet/food")
public class DietFoodController extends BaseController
{
    @Autowired
    private IDietFoodInfoService dietFoodInfoService;

    /**
     * 查询食物基础信息列表
     */
    @PreAuthorize("@ss.hasPermi('diet:food:list')")
    @GetMapping("/list")
    public TableDataInfo list(DietFoodInfo dietFoodInfo)
    {
        startPage();
        List<DietFoodInfo> list = dietFoodInfoService.selectDietFoodInfoList(dietFoodInfo);
        return getDataTable(list);
    }

    /**
     * 导出食物基础信息列表
     */
    @PreAuthorize("@ss.hasPermi('diet:food:export')")
    @Log(title = "食物基础信息", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, DietFoodInfo dietFoodInfo)
    {
        List<DietFoodInfo> list = dietFoodInfoService.selectDietFoodInfoList(dietFoodInfo);
        ExcelUtil<DietFoodInfo> util = new ExcelUtil<DietFoodInfo>(DietFoodInfo.class);
        util.exportExcel(response, list, "食物基础信息数据");
    }

    /**
     * 获取食物基础信息详细信息
     */
    @PreAuthorize("@ss.hasPermi('diet:food:query')")
    @GetMapping(value = "/{foodId}")
    public AjaxResult getInfo(@PathVariable("foodId") Long foodId)
    {
        return success(dietFoodInfoService.selectDietFoodInfoByFoodId(foodId));
    }

    /**
     * 新增食物基础信息
     */
    @PreAuthorize("@ss.hasPermi('diet:food:add')")
    @Log(title = "食物基础信息", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DietFoodInfo dietFoodInfo)
    {
        return toAjax(dietFoodInfoService.insertDietFoodInfo(dietFoodInfo));
    }

    /**
     * 修改食物基础信息
     */
    @PreAuthorize("@ss.hasPermi('diet:food:edit')")
    @Log(title = "食物基础信息", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DietFoodInfo dietFoodInfo)
    {
        return toAjax(dietFoodInfoService.updateDietFoodInfo(dietFoodInfo));
    }

    /**
     * 删除食物基础信息
     */
    @PreAuthorize("@ss.hasPermi('diet:food:remove')")
    @Log(title = "食物基础信息", businessType = BusinessType.DELETE)
	@DeleteMapping("/{foodIds}")
    public AjaxResult remove(@PathVariable Long[] foodIds)
    {
        return toAjax(dietFoodInfoService.deleteDietFoodInfoByFoodIds(foodIds));
    }

    /**
     * 根据食物名称搜索
     */
    @GetMapping("/search/{foodName}")
    public AjaxResult searchByName(@PathVariable String foodName)
    {
        List<DietFoodInfo> list = dietFoodInfoService.selectDietFoodInfoByName(foodName);
        return success(list);
    }

    /**
     * 根据分类查询食物
     */
    @GetMapping("/category/{categoryId}")
    public AjaxResult getByCategory(@PathVariable Long categoryId)
    {
        List<DietFoodInfo> list = dietFoodInfoService.selectDietFoodInfoByCategoryId(categoryId);
        return success(list);
    }
}
