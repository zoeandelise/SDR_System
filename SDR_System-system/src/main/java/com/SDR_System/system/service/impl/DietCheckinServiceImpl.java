package com.SDR_System.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.SDR_System.system.mapper.DietCheckinMapper;
import com.SDR_System.system.domain.DietCheckin;
import com.SDR_System.system.service.IDietCheckinService;

/**
 * 饮食打卡记录Service业务层处理
 * 
 * @author SDR_System
 * @date 2026-03-03
 */
@Service
public class DietCheckinServiceImpl implements IDietCheckinService 
{
    @Autowired
    private DietCheckinMapper dietCheckinMapper;

    /**
     * 查询饮食打卡记录
     * 
     * @param checkinId 饮食打卡记录主键
     * @return 饮食打卡记录
     */
    @Override
    public DietCheckin selectDietCheckinByCheckinId(Long checkinId)
    {
        return dietCheckinMapper.selectDietCheckinByCheckinId(checkinId);
    }

    /**
     * 查询饮食打卡记录列表
     * 
     * @param dietCheckin 饮食打卡记录
     * @return 饮食打卡记录
     */
    @Override
    public List<DietCheckin> selectDietCheckinList(DietCheckin dietCheckin)
    {
        return dietCheckinMapper.selectDietCheckinList(dietCheckin);
    }

    /**
     * 批量删除饮食打卡记录
     * 
     * @param checkinIds 需要删除的饮食打卡记录主键
     * @return 结果
     */
    @Override
    public int deleteDietCheckinByCheckinIds(Long[] checkinIds)
    {
        return dietCheckinMapper.deleteDietCheckinByCheckinIds(checkinIds);
    }

    /**
     * 删除饮食打卡记录信息
     * 
     * @param checkinId 饮食打卡记录主键
     * @return 结果
     */
    @Override
    public int deleteDietCheckinByCheckinId(Long checkinId)
    {
        return dietCheckinMapper.deleteDietCheckinByCheckinId(checkinId);
    }
}
