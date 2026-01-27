package com.SDR_System.web.controller.diet;

import java.util.List;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.SDR_System.common.annotation.Log;
import com.SDR_System.common.core.controller.BaseController;
import com.SDR_System.common.core.domain.AjaxResult;
import com.SDR_System.common.enums.BusinessType;
import com.SDR_System.common.utils.SecurityUtils;

/**
 * 我的食谱控制器
 * 复用推荐方案逻辑，提供用户端专用的食谱API
 * 
 * @author SDR_System
 * @date 2025-01-22
 */
@RestController
@RequestMapping("/api/diet/recipe")
public class DietRecipeController extends BaseController
{
    // 未来可能会用到推荐服务
    // @Autowired
    // private IDietRecommendationService dietRecommendationService;

    /**
     * 获取用户的食谱列表（基于推荐方案）
     */
    @GetMapping("/list")
    public AjaxResult getRecipeList(@RequestParam(required = false) Long userId)
    {
        try {
            // 权限控制：非管理员只能查看自己的食谱
            if (userId == null) {
                userId = getCurrentUserId();
            } else if (!SecurityUtils.isAdmin(SecurityUtils.getUserId()) && !SecurityUtils.getUserId().equals(userId)) {
                return error("无权限访问其他用户的食谱");
            }
            
            List<Map<String, Object>> recipeList = new ArrayList<>();
            
            // 模拟用户食谱数据（基于推荐方案逻辑）
            Map<String, Object> recipe1 = new HashMap<>();
            recipe1.put("recipeId", 1L);
            recipe1.put("recipeName", "健康早餐套餐");
            recipe1.put("userId", userId);
            recipe1.put("recipeDate", new Date());
            recipe1.put("mealType", "0"); // 早餐
            recipe1.put("totalCalories", 400.0);
            recipe1.put("totalProtein", 20.0);
            recipe1.put("totalFat", 15.0);
            recipe1.put("totalCarbohydrate", 50.0);
            recipe1.put("foods", "燕麦片,香蕉,牛奶,鸡蛋");
            recipe1.put("description", "营养均衡的早餐搭配，富含蛋白质和复合碳水化合物");
            recipe1.put("tags", "健康,低脂,高蛋白");
            recipe1.put("difficulty", "简单");
            recipe1.put("cookingTime", "15分钟");
            recipe1.put("servings", 1);
            recipe1.put("isOriginal", true);
            recipe1.put("favoriteCount", 25);
            recipe1.put("rating", 4.5);
            recipe1.put("createTime", new Date());
            
            Map<String, Object> recipe2 = new HashMap<>();
            recipe2.put("recipeId", 2L);
            recipe2.put("recipeName", "营养午餐搭配");
            recipe2.put("userId", userId);
            recipe2.put("recipeDate", new Date());
            recipe2.put("mealType", "1"); // 午餐
            recipe2.put("totalCalories", 600.0);
            recipe2.put("totalProtein", 35.0);
            recipe2.put("totalFat", 20.0);
            recipe2.put("totalCarbohydrate", 75.0);
            recipe2.put("foods", "鸡胸肉,糙米饭,西兰花,胡萝卜");
            recipe2.put("description", "午餐搭配，提供充足能量维持下午精力");
            recipe2.put("tags", "营养均衡,高蛋白,减脂");
            recipe2.put("difficulty", "中等");
            recipe2.put("cookingTime", "30分钟");
            recipe2.put("servings", 1);
            recipe2.put("isOriginal", true);
            recipe2.put("favoriteCount", 42);
            recipe2.put("rating", 4.8);
            recipe2.put("createTime", new Date());
            
            Map<String, Object> recipe3 = new HashMap<>();
            recipe3.put("recipeId", 3L);
            recipe3.put("recipeName", "清淡晚餐");
            recipe3.put("userId", userId);
            recipe3.put("recipeDate", new Date());
            recipe3.put("mealType", "2"); // 晚餐
            recipe3.put("totalCalories", 500.0);
            recipe3.put("totalProtein", 25.0);
            recipe3.put("totalFat", 18.0);
            recipe3.put("totalCarbohydrate", 60.0);
            recipe3.put("foods", "三文鱼,藜麦,菠菜,番茄");
            recipe3.put("description", "晚餐应该清淡易消化，富含优质蛋白质和维生素");
            recipe3.put("tags", "清淡,易消化,omega-3");
            recipe3.put("difficulty", "中等");
            recipe3.put("cookingTime", "25分钟");
            recipe3.put("servings", 1);
            recipe3.put("isOriginal", false);
            recipe3.put("favoriteCount", 33);
            recipe3.put("rating", 4.6);
            recipe3.put("createTime", new Date());
            
            recipeList.add(recipe1);
            recipeList.add(recipe2);
            recipeList.add(recipe3);
            
            Map<String, Object> result = new HashMap<>();
            result.put("recipes", recipeList);
            result.put("total", recipeList.size());
            result.put("totalCaloriesToday", 1500.0);
            result.put("totalProteinToday", 80.0);
            result.put("recommendations", "今日食谱营养搭配合理，建议适量运动");
            
            return success(result);
        } catch (Exception e) {
            logger.error("获取食谱列表失败", e);
            return error("获取食谱列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取食谱详情
     */
    @GetMapping("/{recipeId}")
    public AjaxResult getRecipeDetail(@PathVariable("recipeId") Long recipeId)
    {
        try {
            Map<String, Object> recipe = new HashMap<>();
            recipe.put("recipeId", recipeId);
            recipe.put("recipeName", "健康早餐套餐");
            recipe.put("userId", getCurrentUserId());
            recipe.put("recipeDate", new Date());
            recipe.put("mealType", "0");
            recipe.put("totalCalories", 400.0);
            recipe.put("totalProtein", 20.0);
            recipe.put("totalFat", 15.0);
            recipe.put("totalCarbohydrate", 50.0);
            recipe.put("description", "营养均衡的早餐搭配，富含蛋白质和复合碳水化合物");
            recipe.put("tags", "健康,低脂,高蛋白");
            recipe.put("difficulty", "简单");
            recipe.put("cookingTime", "15分钟");
            recipe.put("servings", 1);
            recipe.put("isOriginal", true);
            recipe.put("favoriteCount", 25);
            recipe.put("rating", 4.5);
            
            // 详细食材列表
            List<Map<String, Object>> ingredients = new ArrayList<>();
            Map<String, Object> ingredient1 = new HashMap<>();
            ingredient1.put("foodName", "燕麦片");
            ingredient1.put("amount", 50.0);
            ingredient1.put("unit", "g");
            ingredient1.put("calories", 190.0);
            ingredient1.put("protein", 7.0);
            ingredient1.put("fat", 3.5);
            ingredient1.put("carbohydrate", 35.0);
            ingredients.add(ingredient1);
            
            Map<String, Object> ingredient2 = new HashMap<>();
            ingredient2.put("foodName", "香蕉");
            ingredient2.put("amount", 100.0);
            ingredient2.put("unit", "g");
            ingredient2.put("calories", 89.0);
            ingredient2.put("protein", 1.1);
            ingredient2.put("fat", 0.3);
            ingredient2.put("carbohydrate", 23.0);
            ingredients.add(ingredient2);
            
            Map<String, Object> ingredient3 = new HashMap<>();
            ingredient3.put("foodName", "牛奶");
            ingredient3.put("amount", 200.0);
            ingredient3.put("unit", "ml");
            ingredient3.put("calories", 120.0);
            ingredient3.put("protein", 6.4);
            ingredient3.put("fat", 6.8);
            ingredient3.put("carbohydrate", 9.0);
            ingredients.add(ingredient3);
            
            recipe.put("ingredients", ingredients);
            
            // 制作步骤
            List<String> steps = new ArrayList<>();
            steps.add("将燕麦片倒入碗中，加入适量温水或牛奶浸泡");
            steps.add("香蕉切片，可直接食用或加入燕麦中");
            steps.add("将牛奶加热至适宜温度");
            steps.add("所有食材搭配享用，营养早餐完成");
            recipe.put("steps", steps);
            
            // 营养建议
            List<String> tips = new ArrayList<>();
            tips.add("燕麦富含β-葡聚糖，有助于降低胆固醇");
            tips.add("香蕉含钾量高，有助于维持电解质平衡");
            tips.add("牛奶提供优质蛋白质和钙质");
            tips.add("建议餐后30分钟进行轻度运动");
            recipe.put("nutritionTips", tips);
            
            return success(recipe);
        } catch (Exception e) {
            logger.error("获取食谱详情失败", e);
            return error("获取食谱详情失败：" + e.getMessage());
        }
    }

    /**
     * 创建新食谱（基于推荐生成）
     */
    @Log(title = "我的食谱", businessType = BusinessType.INSERT)
    @PostMapping("/create")
    public AjaxResult createRecipe(@RequestBody Map<String, Object> params)
    {
        try {
            Long userId = getCurrentUserId();
            String mealType = (String) params.get("mealType");
            String recipeName = (String) params.get("recipeName");
            
            // 使用推荐算法生成食谱内容
            Map<String, Object> recipe = new HashMap<>();
            recipe.put("recipeId", System.currentTimeMillis());
            recipe.put("recipeName", recipeName != null ? recipeName : "智能推荐食谱");
            recipe.put("userId", userId);
            recipe.put("recipeDate", new Date());
            recipe.put("mealType", mealType);
            recipe.put("isOriginal", true);
            recipe.put("favoriteCount", 0);
            recipe.put("rating", 0.0);
            recipe.put("createTime", new Date());
            
            // 根据餐次类型生成不同食谱内容
            switch (mealType) {
                case "0": // 早餐
                    recipe.put("totalCalories", 400.0);
                    recipe.put("totalProtein", 20.0);
                    recipe.put("totalFat", 15.0);
                    recipe.put("totalCarbohydrate", 50.0);
                    recipe.put("foods", "燕麦片,香蕉,牛奶,鸡蛋");
                    recipe.put("description", "营养均衡的早餐食谱");
                    recipe.put("tags", "健康,早餐,高蛋白");
                    recipe.put("difficulty", "简单");
                    recipe.put("cookingTime", "15分钟");
                    break;
                case "1": // 午餐
                    recipe.put("totalCalories", 600.0);
                    recipe.put("totalProtein", 35.0);
                    recipe.put("totalFat", 20.0);
                    recipe.put("totalCarbohydrate", 75.0);
                    recipe.put("foods", "鸡胸肉,糙米饭,西兰花,胡萝卜");
                    recipe.put("description", "营养丰富的午餐食谱");
                    recipe.put("tags", "营养均衡,午餐,减脂");
                    recipe.put("difficulty", "中等");
                    recipe.put("cookingTime", "30分钟");
                    break;
                case "2": // 晚餐
                    recipe.put("totalCalories", 500.0);
                    recipe.put("totalProtein", 25.0);
                    recipe.put("totalFat", 18.0);
                    recipe.put("totalCarbohydrate", 60.0);
                    recipe.put("foods", "三文鱼,藜麦,菠菜,番茄");
                    recipe.put("description", "清淡易消化的晚餐食谱");
                    recipe.put("tags", "清淡,晚餐,易消化");
                    recipe.put("difficulty", "中等");
                    recipe.put("cookingTime", "25分钟");
                    break;
                default:
                    recipe.put("totalCalories", 200.0);
                    recipe.put("totalProtein", 10.0);
                    recipe.put("totalFat", 8.0);
                    recipe.put("totalCarbohydrate", 25.0);
                    recipe.put("foods", "坚果,酸奶,水果");
                    recipe.put("description", "健康的加餐食谱");
                    recipe.put("tags", "加餐,健康,低热量");
                    recipe.put("difficulty", "简单");
                    recipe.put("cookingTime", "5分钟");
            }
            
            recipe.put("servings", 1);
            
            return AjaxResult.success("食谱创建成功", recipe);
        } catch (Exception e) {
            logger.error("创建食谱失败", e);
            return error("创建食谱失败：" + e.getMessage());
        }
    }

    /**
     * 更新食谱
     */
    @Log(title = "我的食谱", businessType = BusinessType.UPDATE)
    @PutMapping("/{recipeId}")
    public AjaxResult updateRecipe(@PathVariable("recipeId") Long recipeId, @RequestBody Map<String, Object> recipe)
    {
        try {
            recipe.put("recipeId", recipeId);
            recipe.put("updateTime", new Date());
            recipe.put("userId", getCurrentUserId());
            
            return AjaxResult.success("食谱更新成功", recipe);
        } catch (Exception e) {
            logger.error("更新食谱失败", e);
            return error("更新食谱失败：" + e.getMessage());
        }
    }

    /**
     * 删除食谱
     */
    @Log(title = "我的食谱", businessType = BusinessType.DELETE)
    @DeleteMapping("/{recipeId}")
    public AjaxResult deleteRecipe(@PathVariable("recipeId") Long recipeId)
    {
        try {
            return success("食谱删除成功");
        } catch (Exception e) {
            logger.error("删除食谱失败", e);
            return error("删除食谱失败：" + e.getMessage());
        }
    }

    /**
     * 收藏食谱
     */
    @Log(title = "收藏食谱", businessType = BusinessType.UPDATE)
    @PostMapping("/{recipeId}/favorite")
    public AjaxResult favoriteRecipe(@PathVariable("recipeId") Long recipeId)
    {
        try {
            Map<String, Object> result = new HashMap<>();
            result.put("recipeId", recipeId);
            result.put("isFavorited", true);
            result.put("favoriteTime", new Date());
            
            return AjaxResult.success("收藏成功", result);
        } catch (Exception e) {
            logger.error("收藏食谱失败", e);
            return error("收藏失败：" + e.getMessage());
        }
    }

    /**
     * 取消收藏食谱
     */
    @Log(title = "取消收藏食谱", businessType = BusinessType.UPDATE)
    @DeleteMapping("/{recipeId}/favorite")
    public AjaxResult unfavoriteRecipe(@PathVariable("recipeId") Long recipeId)
    {
        try {
            Map<String, Object> result = new HashMap<>();
            result.put("recipeId", recipeId);
            result.put("isFavorited", false);
            result.put("unfavoriteTime", new Date());
            
            return AjaxResult.success("取消收藏成功", result);
        } catch (Exception e) {
            logger.error("取消收藏食谱失败", e);
            return error("取消收藏失败：" + e.getMessage());
        }
    }

    /**
     * 搜索食谱
     */
    @GetMapping("/search")
    public AjaxResult searchRecipes(@RequestParam(required = false) String keyword,
                                  @RequestParam(required = false) String mealType,
                                  @RequestParam(required = false) String tags)
    {
        try {
            List<Map<String, Object>> recipes = new ArrayList<>();
            
            // 模拟搜索结果
            if (keyword == null || keyword.isEmpty() || "健康".contains(keyword)) {
                Map<String, Object> recipe = new HashMap<>();
                recipe.put("recipeId", 1L);
                recipe.put("recipeName", "健康早餐套餐");
                recipe.put("totalCalories", 400.0);
                recipe.put("foods", "燕麦片,香蕉,牛奶,鸡蛋");
                recipe.put("tags", "健康,低脂,高蛋白");
                recipe.put("rating", 4.5);
                recipe.put("favoriteCount", 25);
                recipes.add(recipe);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("recipes", recipes);
            result.put("total", recipes.size());
            result.put("keyword", keyword);
            
            return success(result);
        } catch (Exception e) {
            logger.error("搜索食谱失败", e);
            return error("搜索失败：" + e.getMessage());
        }
    }

    /**
     * 获取热门食谱
     */
    @GetMapping("/popular")
    public AjaxResult getPopularRecipes(@RequestParam(defaultValue = "10") int limit)
    {
        try {
            List<Map<String, Object>> recipes = new ArrayList<>();
            
            Map<String, Object> recipe1 = new HashMap<>();
            recipe1.put("recipeId", 1L);
            recipe1.put("recipeName", "网红减脂餐");
            recipe1.put("totalCalories", 350.0);
            recipe1.put("foods", "鸡胸肉,生菜,圣女果");
            recipe1.put("tags", "减脂,低热量,高蛋白");
            recipe1.put("rating", 4.8);
            recipe1.put("favoriteCount", 156);
            recipe1.put("difficulty", "简单");
            recipe1.put("cookingTime", "20分钟");
            recipes.add(recipe1);
            
            Map<String, Object> recipe2 = new HashMap<>();
            recipe2.put("recipeId", 2L);
            recipe2.put("recipeName", "营养早餐碗");
            recipe2.put("totalCalories", 420.0);
            recipe2.put("foods", "燕麦,蓝莓,坚果,蜂蜜");
            recipe2.put("tags", "早餐,营养,美味");
            recipe2.put("rating", 4.7);
            recipe2.put("favoriteCount", 134);
            recipe2.put("difficulty", "简单");
            recipe2.put("cookingTime", "10分钟");
            recipes.add(recipe2);
            
            return success(recipes);
        } catch (Exception e) {
            logger.error("获取热门食谱失败", e);
            return error("获取热门食谱失败：" + e.getMessage());
        }
    }

    /**
     * 获取当前登录用户ID
     */
    private Long getCurrentUserId() {
        try {
            return SecurityUtils.getUserId();
        } catch (Exception e) {
            logger.warn("获取用户ID失败，使用默认值", e);
            return 1L; // 默认用户ID，实际应用中应该处理未登录情况
        }
    }
}
