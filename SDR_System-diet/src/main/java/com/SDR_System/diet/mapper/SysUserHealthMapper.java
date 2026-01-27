package com.SDR_System.diet.mapper;

import java.util.List;
import com.SDR_System.system.domain.SysUserHealth;

/**
 * 用户健康信息Mapper接口
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
public interface SysUserHealthMapper 
{
    /**
     * 查询用户健康信息
     * 
     * @param healthId 用户健康信息主键
     * @return 用户健康信息
     */
    public SysUserHealth selectSysUserHealthByHealthId(Long healthId);

    /**
     * 根据用户ID查询用户健康信息
     * 
     * @param userId 用户ID
     * @return 用户健康信息
     */
    public SysUserHealth selectSysUserHealthByUserId(Long userId);

    /**
     * 查询用户健康信息列表
     * 
     * @param sysUserHealth 用户健康信息
     * @return 用户健康信息集合
     */
    public List<SysUserHealth> selectSysUserHealthList(SysUserHealth sysUserHealth);

    /**
     * 新增用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    public int insertSysUserHealth(SysUserHealth sysUserHealth);

    /**
     * 修改用户健康信息
     * 
     * @param sysUserHealth 用户健康信息
     * @return 结果
     */
    public int updateSysUserHealth(SysUserHealth sysUserHealth);

    /**
     * 删除用户健康信息
     * 
     * @param healthId 用户健康信息主键
     * @return 结果
     */
    public int deleteSysUserHealthByHealthId(Long healthId);

    /**
     * 批量删除用户健康信息
     * 
     * @param healthIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteSysUserHealthByHealthIds(Long[] healthIds);
}
