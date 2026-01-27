package com.SDR_System.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.SDR_System.system.domain.DietFavorites;

/**
 * 饮食收藏夹Mapper接口
 * 
 * @author SDR_System
 * @date 2025-01-01
 */
public interface DietFavoritesMapper 
{
    /**
     * 查询饮食收藏夹
     * 
     * @param favoriteId 饮食收藏夹主键
     * @return 饮食收藏夹
     */
    public DietFavorites selectDietFavoritesByFavoriteId(Long favoriteId);

    /**
     * 查询饮食收藏夹列表
     * 
     * @param dietFavorites 饮食收藏夹
     * @return 饮食收藏夹集合
     */
    public List<DietFavorites> selectDietFavoritesList(DietFavorites dietFavorites);

    /**
     * 新增饮食收藏夹
     * 
     * @param dietFavorites 饮食收藏夹
     * @return 结果
     */
    public int insertDietFavorites(DietFavorites dietFavorites);

    /**
     * 修改饮食收藏夹
     * 
     * @param dietFavorites 饮食收藏夹
     * @return 结果
     */
    public int updateDietFavorites(DietFavorites dietFavorites);

    /**
     * 删除饮食收藏夹
     * 
     * @param favoriteId 饮食收藏夹主键
     * @return 结果
     */
    public int deleteDietFavoritesByFavoriteId(Long favoriteId);

    /**
     * 批量删除饮食收藏夹
     * 
     * @param favoriteIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteDietFavoritesByFavoriteIds(Long[] favoriteIds);

    /**
     * 根据用户ID和类型查询收藏列表
     * 
     * @param userId 用户ID
     * @param favoriteType 收藏类型
     * @return 饮食收藏夹集合
     */
    public List<DietFavorites> selectDietFavoritesByUserIdAndType(@Param("userId") Long userId, @Param("favoriteType") String favoriteType);

    /**
     * 检查是否已收藏
     * 
     * @param userId 用户ID
     * @param favoriteType 收藏类型
     * @param targetId 目标ID
     * @return 收藏记录
     */
    public DietFavorites selectDietFavoritesByUserIdAndTypeAndTargetId(@Param("userId") Long userId, @Param("favoriteType") String favoriteType, @Param("targetId") Long targetId);

    /**
     * 根据用户ID删除收藏
     * 
     * @param userId 用户ID
     * @param favoriteType 收藏类型
     * @param targetId 目标ID
     * @return 结果
     */
    public int deleteDietFavoritesByUserIdAndTypeAndTargetId(@Param("userId") Long userId, @Param("favoriteType") String favoriteType, @Param("targetId") Long targetId);

    /**
     * 统计用户收藏数量
     * 
     * @param userId 用户ID
     * @param favoriteType 收藏类型（可选）
     * @return 收藏数量
     */
    public int countDietFavoritesByUserId(@Param("userId") Long userId, @Param("favoriteType") String favoriteType);
}
