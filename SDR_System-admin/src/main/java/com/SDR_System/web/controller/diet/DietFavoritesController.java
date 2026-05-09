package com.SDR_System.web.controller.diet;

import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.utils.SecurityUtils;
import com.SDR_System.system.domain.DietFavorites;
import com.SDR_System.system.mapper.DietFavoritesMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user/diet/favorites")
public class DietFavoritesController {

    @Autowired
    private DietFavoritesMapper dietFavoritesMapper;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) String favoriteType) {
        Long userId = SecurityUtils.getUserId();
        List<DietFavorites> list = dietFavoritesMapper.selectDietFavoritesByUserIdAndType(userId, favoriteType);
        return AjaxResult.success(list);
    }

    @PostMapping("/toggle")
    public AjaxResult toggle(@RequestBody Map<String, Object> body) {
        Long userId = SecurityUtils.getUserId();
        String favoriteType = (String) body.get("favoriteType");
        Object targetIdObj = body.get("targetId");

        if (favoriteType == null || favoriteType.trim().isEmpty()) {
            return AjaxResult.error("favoriteType不能为空");
        }
        if (targetIdObj == null) {
            return AjaxResult.error("targetId不能为空");
        }

        Long targetId;
        try {
            targetId = ((Number) targetIdObj).longValue();
        } catch (Exception e) {
            return AjaxResult.error("targetId格式错误");
        }

        DietFavorites existing = dietFavoritesMapper.selectDietFavoritesByUserIdAndTypeAndTargetId(userId, favoriteType, targetId);
        if (existing != null && existing.getFavoriteId() != null) {
            dietFavoritesMapper.deleteDietFavoritesByFavoriteId(existing.getFavoriteId());
            Map<String, Object> result = new HashMap<>();
            result.put("favoriteType", favoriteType);
            result.put("targetId", targetId);
            result.put("isFavorited", false);
            result.put("unfavoriteTime", new Date());
            return AjaxResult.success(result);
        }

        String targetName = (String) body.get("targetName");
        String targetDescription = (String) body.getOrDefault("targetDescription", "");
        String targetImage = (String) body.getOrDefault("targetImage", "");
        if (targetName == null || targetName.trim().isEmpty()) {
            targetName = favoriteType + ":" + targetId;
        }

        DietFavorites toInsert = new DietFavorites();
        toInsert.setUserId(userId);
        toInsert.setFavoriteType(favoriteType);
        toInsert.setTargetId(targetId);
        toInsert.setTargetName(targetName);
        toInsert.setTargetDescription(targetDescription);
        toInsert.setTargetImage(targetImage);
        toInsert.setCreateTime(new Date());
        toInsert.setCreateBy(String.valueOf(userId));

        dietFavoritesMapper.insertDietFavorites(toInsert);

        Map<String, Object> result = new HashMap<>();
        result.put("favoriteId", toInsert.getFavoriteId());
        result.put("favoriteType", favoriteType);
        result.put("targetId", targetId);
        result.put("isFavorited", true);
        result.put("favoriteTime", new Date());
        return AjaxResult.success(result);
    }
}
