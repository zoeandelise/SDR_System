package com.SDR_System.web.controller.diet;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.system.domain.DietCheckin;
import com.SDR_System.system.service.IDietCheckinService;
import com.SDR_System.common.utils.poi.ExcelUtil;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.utils.SecurityUtils;

/**
 * 饮食打卡记录后台管理Controller
 * 
 * @author SDR_System
 * @date 2026-03-03
 */
@RestController
@RequestMapping("/diet/checkin")
public class DietCheckinController extends BaseController
{
    @Autowired
    private IDietCheckinService dietCheckinService;

    /**
     * 查询饮食打卡记录列表
     */
    @PreAuthorize("@ss.hasPermi('diet:checkin:list')")
    @GetMapping("/list")
    public TableDataInfo list(DietCheckin dietCheckin)
    {
        startPage();
        
        // 非管理员只能查看自己的
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietCheckin.setUserId(SecurityUtils.getUserId());
        }
        
        List<DietCheckin> list = dietCheckinService.selectDietCheckinList(dietCheckin);
        return getDataTable(list);
    }

    /**
     * 导出饮食打卡记录列表
     */
    @PreAuthorize("@ss.hasPermi('diet:checkin:export')")
    @Log(title = "饮食打卡记录", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, DietCheckin dietCheckin)
    {
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietCheckin.setUserId(SecurityUtils.getUserId());
        }
        List<DietCheckin> list = dietCheckinService.selectDietCheckinList(dietCheckin);
        ExcelUtil<DietCheckin> util = new ExcelUtil<DietCheckin>(DietCheckin.class);
        util.exportExcel(response, list, "饮食打卡记录数据");
    }

    /**
     * 获取饮食打卡记录详细信息
     */
    @PreAuthorize("@ss.hasPermi('diet:checkin:query')")
    @GetMapping(value = "/{checkinId}")
    public AjaxResult getInfo(@PathVariable("checkinId") Long checkinId)
    {
        DietCheckin checkin = dietCheckinService.selectDietCheckinByCheckinId(checkinId);
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && checkin != null && 
            !SecurityUtils.getUserId().equals(checkin.getUserId())) {
            return error("无权限");
        }
        return success(checkin);
    }

    /**
     * 删除饮食打卡记录
     */
    @PreAuthorize("@ss.hasPermi('diet:checkin:remove')")
    @Log(title = "饮食打卡记录", businessType = BusinessType.DELETE)
	@DeleteMapping("/{checkinIds}")
    public AjaxResult remove(@PathVariable Long[] checkinIds)
    {
        return toAjax(dietCheckinService.deleteDietCheckinByCheckinIds(checkinIds));
    }
}
