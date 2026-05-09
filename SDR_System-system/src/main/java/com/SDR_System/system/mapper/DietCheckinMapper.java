package com.SDR_System.system.mapper;

import java.util.List;
import com.SDR_System.system.domain.DietCheckin;

/**
 * 饮食打卡记录Mapper接口
 * 
 * @author SDR_System
 * @date 2026-03-03
 */
public interface DietCheckinMapper 
{
    /**
     * 查询饮食打卡记录
     * 
     * @param checkinId 饮食打卡记录主键
     * @return 饮食打卡记录
     */
    public DietCheckin selectDietCheckinByCheckinId(Long checkinId);

    /**
     * 查询饮食打卡记录列表
     * 
     * @param dietCheckin 饮食打卡记录
     * @return 饮食打卡记录集合
     */
    public List<DietCheckin> selectDietCheckinList(DietCheckin dietCheckin);

    /**
     * 删除饮食打卡记录
     * 
     * @param checkinId 饮食打卡记录主键
     * @return 结果
     */
    public int deleteDietCheckinByCheckinId(Long checkinId);

    /**
     * 批量删除饮食打卡记录
     * 
     * @param checkinIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDietCheckinByCheckinIds(Long[] checkinIds);
}
