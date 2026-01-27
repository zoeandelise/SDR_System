package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.Date;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.system.domain.DietRecord;
import com.SDR_System.diet.service.IDietRecordService;
import com.SDR_System.diet.service.IAiRecognitionService;
import com.SDR_System.common.utils.poi.ExcelUtil;
import com.SDR_System.common.core.page.TableDataInfo;
import com.SDR_System.common.utils.SecurityUtils;
import org.springframework.format.annotation.DateTimeFormat;
// MongoDB相关已移除 - V2.0仅使用MySQL
// import com.SDR_System.diet.domain.mongo.DietRecordDetail;
import com.SDR_System.diet.service.IDietRecordService.DietStatisticsReport;

/**
 * 饮食记录Controller
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/diet/record")
public class DietRecordController extends BaseController
{
    @Autowired
    private IDietRecordService dietRecordService;

    @Autowired
    private IAiRecognitionService aiRecognitionService;

    /**
     * 查询饮食记录列表
     */
    @PreAuthorize("@ss.hasPermi('diet:record:list')")
    @GetMapping("/list")
    public TableDataInfo list(DietRecord dietRecord)
    {
        startPage();
        
        // 非管理员用户只能查看自己的记录
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietRecord.setUserId(SecurityUtils.getUserId());
        }
        
        List<DietRecord> list = dietRecordService.selectDietRecordList(dietRecord);
        return getDataTable(list);
    }

    /**
     * 导出饮食记录列表
     */
    @PreAuthorize("@ss.hasPermi('diet:record:export')")
    @Log(title = "饮食记录", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, DietRecord dietRecord)
    {
        // 非管理员用户只能导出自己的记录
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId())) {
            dietRecord.setUserId(SecurityUtils.getUserId());
        }
        
        List<DietRecord> list = dietRecordService.selectDietRecordList(dietRecord);
        ExcelUtil<DietRecord> util = new ExcelUtil<DietRecord>(DietRecord.class);
        util.exportExcel(response, list, "饮食记录数据");
    }

    /**
     * 获取饮食记录详细信息
     */
    @PreAuthorize("@ss.hasPermi('diet:record:query')")
    @GetMapping(value = "/{recordId}")
    public AjaxResult getInfo(@PathVariable("recordId") Long recordId)
    {
        DietRecord record = dietRecordService.selectDietRecordByRecordId(recordId);
        
        // 非管理员用户只能查看自己的记录
        if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && record != null && 
            !SecurityUtils.getUserId().equals(record.getUserId())) {
            return error("无权限访问该记录");
        }
        
        return success(record);
    }

    /**
     * 新增饮食记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:add')")
    @Log(title = "饮食记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DietRecord dietRecord)
    {
        dietRecord.setUserId(SecurityUtils.getUserId());
        return toAjax(dietRecordService.insertDietRecord(dietRecord));
    }

    /**
     * 修改饮食记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:edit')")
    @Log(title = "饮食记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DietRecord dietRecord)
    {
        return toAjax(dietRecordService.updateDietRecord(dietRecord));
    }

    /**
     * 删除饮食记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:remove')")
    @Log(title = "饮食记录", businessType = BusinessType.DELETE)
	@DeleteMapping("/{recordIds}")
    public AjaxResult remove(@PathVariable Long[] recordIds)
    {
        return toAjax(dietRecordService.deleteDietRecordByRecordIds(recordIds));
    }

    /**
     * 上传食物照片进行AI识别
     */
    @PreAuthorize("@ss.hasPermi('diet:record:add')")
    @PostMapping("/recognize")
    @Log(title = "AI食物识别", businessType = BusinessType.OTHER)
    public AjaxResult recognizeFood(@RequestParam("image") MultipartFile imageFile)
    {
        try {
            Long userId = SecurityUtils.getUserId();
            IAiRecognitionService.AiRecognitionResult result = aiRecognitionService.recognizeFood(imageFile, userId);
            return success(result);
        } catch (Exception e) {
            logger.error("AI食物识别失败", e);
            return error("AI食物识别失败：" + e.getMessage());
        }
    }

    /**
     * 根据图片URL进行AI识别
     */
    @PreAuthorize("@ss.hasPermi('diet:record:add')")
    @PostMapping("/recognize/url")
    @Log(title = "AI食物识别", businessType = BusinessType.OTHER)
    public AjaxResult recognizeFoodByUrl(@RequestParam("imageUrl") String imageUrl)
    {
        try {
            Long userId = SecurityUtils.getUserId();
            IAiRecognitionService.AiRecognitionResult result = aiRecognitionService.recognizeFoodByUrl(imageUrl, userId);
            return success(result);
        } catch (Exception e) {
            logger.error("AI食物识别失败", e);
            return error("AI食物识别失败：" + e.getMessage());
        }
    }

    /**
     * 查询用户指定日期的饮食记录
     */
    @GetMapping("/daily")
    public AjaxResult getDailyRecords(@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date date)
    {
        Long userId = SecurityUtils.getUserId();
        List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDate(userId, date);
        return success(records);
    }

    /**
     * 查询用户指定日期范围的饮食记录
     */
    @GetMapping("/range")
    public AjaxResult getRecordsByRange(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate)
    {
        Long userId = SecurityUtils.getUserId();
        List<DietRecord> records = dietRecordService.selectDietRecordsByUserIdAndDateRange(userId, startDate, endDate);
        return success(records);
    }

    /**
     * 获取用户营养摄入统计
     */
    @GetMapping("/nutrition/summary")
    public AjaxResult getNutritionSummary(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate)
    {
        Long userId = SecurityUtils.getUserId();
        DietRecord summary = dietRecordService.selectNutritionSummaryByUserIdAndDateRange(userId, startDate, endDate);
        return success(summary);
    }

    /**
     * 新增饮食记录（包含详细信息）
     * V2.0: MongoDB已移除，仅保存MySQL基础记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:add')")
    @Log(title = "饮食记录详细", businessType = BusinessType.INSERT)
    @PostMapping("/detail")
    public AjaxResult addWithDetail(@RequestBody DietRecordDetailRequest request)
    {
        try {
            Long userId = SecurityUtils.getUserId();
            request.getDietRecord().setUserId(userId);
            
            // V2.0: 仅插入MySQL基础记录
            int result = dietRecordService.insertDietRecord(request.getDietRecord());
            
            return toAjax(result);
        } catch (Exception e) {
            logger.error("新增饮食记录失败", e);
            return error("新增饮食记录失败：" + e.getMessage());
        }
    }

    /**
     * 获取饮食记录详细信息
     * V2.0: MongoDB已移除，返回基础记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:query')")
    @GetMapping("/detail/{recordId}")
    public AjaxResult getDetailInfo(@PathVariable("recordId") Long recordId)
    {
        // V2.0: 返回MySQL基础记录
        DietRecord record = dietRecordService.selectDietRecordByRecordId(recordId);
        return success(record);
    }

    /**
     * 更新饮食记录的营养汇总信息
     * V2.0: MongoDB已移除，返回基础记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:edit')")
    @Log(title = "营养汇总计算", businessType = BusinessType.UPDATE)
    @PutMapping("/nutrition/calculate/{recordId}")
    public AjaxResult calculateNutrition(@PathVariable("recordId") Long recordId)
    {
        try {
            // V2.0: 直接返回MySQL记录
            DietRecord record = dietRecordService.selectDietRecordByRecordId(recordId);
            if (record == null) {
                return error("未找到记录");
            }
            return success(record);
        } catch (Exception e) {
            logger.error("查询记录失败", e);
            return error("查询记录失败：" + e.getMessage());
        }
    }

    /**
     * 获取用户饮食统计报告
     */
    @GetMapping("/statistics")
    public AjaxResult getStatisticsReport(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate)
    {
        Long userId = SecurityUtils.getUserId();
        DietStatisticsReport report = dietRecordService.getDietStatisticsReport(userId, startDate, endDate);
        return success(report);
    }

    /**
     * 批量导入饮食记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:import')")
    @Log(title = "饮食记录导入", businessType = BusinessType.IMPORT)
    @PostMapping("/import")
    public AjaxResult importData(MultipartFile file, boolean updateSupport) throws Exception
    {
        ExcelUtil<DietRecord> util = new ExcelUtil<DietRecord>(DietRecord.class);
        List<DietRecord> recordList = util.importExcel(file.getInputStream());
        
        Long userId = SecurityUtils.getUserId();
        String message = "";
        
        for (DietRecord record : recordList) {
            try {
                record.setUserId(userId);
                dietRecordService.insertDietRecord(record);
            } catch (Exception e) {
                message += "导入失败：" + e.getMessage() + "\n";
            }
        }
        
        return success(message.isEmpty() ? "导入成功" : message);
    }

    /**
     * 获取饮食记录模板
     */
    @PostMapping("/importTemplate")
    public void importTemplate(HttpServletResponse response)
    {
        ExcelUtil<DietRecord> util = new ExcelUtil<DietRecord>(DietRecord.class);
        util.importTemplateExcel(response, "饮食记录数据");
    }

    /**
     * 基于食物ID列表创建饮食记录
     */
    @PreAuthorize("@ss.hasPermi('diet:record:add')")
    @Log(title = "基于食物创建记录", businessType = BusinessType.INSERT)
    @PostMapping("/create-by-foods")
    public AjaxResult createByFoods(@RequestBody CreateByFoodsRequest request)
    {
        try {
            Long userId = SecurityUtils.getUserId();
            
            // 创建基础记录
            DietRecord dietRecord = new DietRecord();
            dietRecord.setUserId(userId);
            dietRecord.setRecordDate(request.getRecordDate());
            dietRecord.setMealType(request.getMealType());
            dietRecord.setNotes(request.getNotes());
            
            // 暂时只保存基础记录，详细功能后续完善
            int result = dietRecordService.insertDietRecord(dietRecord);
            
            return toAjax(result);
        } catch (Exception e) {
            logger.error("基于食物ID创建饮食记录失败", e);
            return error("创建饮食记录失败：" + e.getMessage());
        }
    }

    /**
     * 饮食记录详细请求类
     * V2.0: MongoDB已移除，仅保留DietRecord
     */
    public static class DietRecordDetailRequest {
        private DietRecord dietRecord;
        // private DietRecordDetail recordDetail; // MongoDB已移除

        public DietRecord getDietRecord() { return dietRecord; }
        public void setDietRecord(DietRecord dietRecord) { this.dietRecord = dietRecord; }

        // public DietRecordDetail getRecordDetail() { return recordDetail; }
        // public void setRecordDetail(DietRecordDetail recordDetail) { this.recordDetail = recordDetail; }
    }

    /**
     * 基于食物ID创建记录的请求类
     * V2.0: MongoDB已移除，简化为基础字段
     */
    public static class CreateByFoodsRequest {
        // V2.0: MongoDB已移除，简化请求类
        // private List<DietRecordDetail.FoodItem> foodItems;
        private String foodNames;  // 食物名称列表（逗号分隔）
        private Date recordDate;
        private String mealType;
        private String notes;

        // public List<DietRecordDetail.FoodItem> getFoodItems() { return foodItems; }
        // public void setFoodItems(List<DietRecordDetail.FoodItem> foodItems) { this.foodItems = foodItems; }

        public String getFoodNames() { return foodNames; }
        public void setFoodNames(String foodNames) { this.foodNames = foodNames; }

        public Date getRecordDate() { return recordDate; }
        public void setRecordDate(Date recordDate) { this.recordDate = recordDate; }

        public String getMealType() { return mealType; }
        public void setMealType(String mealType) { this.mealType = mealType; }

        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
    }
}
