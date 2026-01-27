package com.SDR_System.system.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.SDR_System.common.annotation.Excel;
import com.SDR_System.common.annotation.Excel.ColumnType;
import com.SDR_System.common.core.domain.BaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;

/**
 * 饮食收藏夹表 diet_favorites
 * 
 * @author SDR_System
 */
public class DietFavorites extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 收藏ID */
    private Long favoriteId;

    /** 用户ID */
    @Excel(name = "用户ID", cellType = ColumnType.NUMERIC)
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /** 收藏类型(food食物,recipe食谱,recommendation推荐方案) */
    @Excel(name = "收藏类型", readConverterExp = "food=食物,recipe=食谱,recommendation=推荐方案")
    @NotBlank(message = "收藏类型不能为空")
    @Size(min = 0, max = 20, message = "收藏类型不能超过20个字符")
    private String favoriteType;

    /** 目标ID（食物ID、食谱ID或推荐方案ID） */
    @Excel(name = "目标ID", cellType = ColumnType.NUMERIC)
    @NotNull(message = "目标ID不能为空")
    private Long targetId;

    /** 目标名称 */
    @Excel(name = "目标名称")
    @NotBlank(message = "目标名称不能为空")
    @Size(min = 0, max = 200, message = "目标名称不能超过200个字符")
    private String targetName;

    /** 目标描述 */
    @Excel(name = "目标描述")
    @Size(min = 0, max = 500, message = "目标描述不能超过500个字符")
    private String targetDescription;

    /** 目标图片URL */
    @Excel(name = "目标图片URL")
    @Size(min = 0, max = 500, message = "目标图片URL不能超过500个字符")
    private String targetImage;

    /** 用户名称（关联查询用） */
    @Excel(name = "用户名称")
    private String userName;

    public Long getFavoriteId()
    {
        return favoriteId;
    }

    public void setFavoriteId(Long favoriteId)
    {
        this.favoriteId = favoriteId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getFavoriteType()
    {
        return favoriteType;
    }

    public void setFavoriteType(String favoriteType)
    {
        this.favoriteType = favoriteType;
    }

    public Long getTargetId()
    {
        return targetId;
    }

    public void setTargetId(Long targetId)
    {
        this.targetId = targetId;
    }

    public String getTargetName()
    {
        return targetName;
    }

    public void setTargetName(String targetName)
    {
        this.targetName = targetName;
    }

    public String getTargetDescription()
    {
        return targetDescription;
    }

    public void setTargetDescription(String targetDescription)
    {
        this.targetDescription = targetDescription;
    }

    public String getTargetImage()
    {
        return targetImage;
    }

    public void setTargetImage(String targetImage)
    {
        this.targetImage = targetImage;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("favoriteId", getFavoriteId())
            .append("userId", getUserId())
            .append("favoriteType", getFavoriteType())
            .append("targetId", getTargetId())
            .append("targetName", getTargetName())
            .append("targetDescription", getTargetDescription())
            .append("targetImage", getTargetImage())
            .append("createTime", getCreateTime())
            .append("createBy", getCreateBy())
            .append("updateTime", getUpdateTime())
            .append("updateBy", getUpdateBy())
            .append("remark", getRemark())
            .toString();
    }
}
