package com.SDR_System.diet.service.impl;

import java.util.Date;
import java.util.List;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Random;
import java.util.Map;
import java.util.HashMap;
import java.util.Arrays;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.SDR_System.diet.mapper.DietRecommendationMapper;
import com.SDR_System.diet.domain.DietRecommendation;
import com.SDR_System.diet.service.IDietRecommendationService;
import com.SDR_System.system.domain.SysUserHealth;
import com.SDR_System.diet.service.ISysUserHealthService;
import com.SDR_System.diet.service.IDietFoodInfoService;
import com.SDR_System.system.domain.DietFoodInfo;
import com.SDR_System.diet.service.impl.MLRecommendationService.MLRecommendationResult;
import com.SDR_System.diet.service.impl.MLRecommendationService.FoodRecommendation;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 饮食推荐服务实现
 * 增强版 - 集成机器学习推荐算法
 * 
 * @author SDR_System
 */
@Service
public class DietRecommendationServiceImpl implements IDietRecommendationService
{
    private static final Logger logger = LoggerFactory.getLogger(DietRecommendationServiceImpl.class);
    
    @Autowired
    private DietRecommendationMapper dietRecommendationMapper;

    @Autowired
    private ISysUserHealthService sysUserHealthService;

    @Autowired
    private IDietFoodInfoService dietFoodInfoService;
    
    @Autowired
    private MLRecommendationService mlRecommendationService;
    
    @Value("${ml.recommendation.enabled:true}")
    private boolean mlRecommendationEnabled;

    /**
     * 查询饮食推荐
     * 
     * @param recommendationId 饮食推荐主键
     * @return 饮食推荐
     */
    @Override
    public DietRecommendation selectDietRecommendationByRecommendationId(Long recommendationId)
    {
        return dietRecommendationMapper.selectDietRecommendationByRecommendationId(recommendationId);
    }

    /**
     * 查询饮食推荐列表
     * 
     * @param dietRecommendation 饮食推荐
     * @return 饮食推荐
     */
    @Override
    public List<DietRecommendation> selectDietRecommendationList(DietRecommendation dietRecommendation)
    {
        return dietRecommendationMapper.selectDietRecommendationList(dietRecommendation);
    }

    /**
     * 新增饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    @Override
    public int insertDietRecommendation(DietRecommendation dietRecommendation)
    {
        // 设置创建时间
        dietRecommendation.setCreateTime(new Date());
        
        // 确保必填字段有默认值
        if (dietRecommendation.getMealType() == null || dietRecommendation.getMealType().isEmpty()) {
            dietRecommendation.setMealType("0"); // 默认为早餐
        }
        
        if (dietRecommendation.getRecommendationDate() == null) {
            dietRecommendation.setRecommendationDate(new Date());
        }
        
        return dietRecommendationMapper.insertDietRecommendation(dietRecommendation);
    }

    /**
     * 修改饮食推荐
     * 
     * @param dietRecommendation 饮食推荐
     * @return 结果
     */
    @Override
    public int updateDietRecommendation(DietRecommendation dietRecommendation)
    {
        dietRecommendation.setUpdateTime(new Date());
        return dietRecommendationMapper.updateDietRecommendation(dietRecommendation);
    }

    /**
     * 批量删除饮食推荐
     * 
     * @param recommendationIds 需要删除的饮食推荐主键
     * @return 结果
     */
    @Override
    public int deleteDietRecommendationByRecommendationIds(Long[] recommendationIds)
    {
        return dietRecommendationMapper.deleteDietRecommendationByRecommendationIds(recommendationIds);
    }

    /**
     * 删除饮食推荐信息
     * 
     * @param recommendationId 饮食推荐主键
     * @return 结果
     */
    @Override
    public int deleteDietRecommendationByRecommendationId(Long recommendationId)
    {
        return dietRecommendationMapper.deleteDietRecommendationByRecommendationId(recommendationId);
    }

    /**
     * 智能生成推荐方案
     * 
     * @param dietRecommendation 推荐方案参数
     * @return 生成的推荐方案
     */
    @Override
    public DietRecommendation generateRecommendation(DietRecommendation dietRecommendation)
    {
        try {
            // 获取用户健康信息
            SysUserHealth userHealth = sysUserHealthService.selectSysUserHealthByUserId(dietRecommendation.getUserId());
            
            // 获取食物库中的食物
            List<DietFoodInfo> allFoods = dietFoodInfoService.selectDietFoodInfoList(new DietFoodInfo());
            
            // 根据推荐类型生成不同的推荐
            DietRecommendation recommendation = new DietRecommendation();
            recommendation.setUserId(dietRecommendation.getUserId());
            recommendation.setRecommendationDate(dietRecommendation.getRecommendationDate());
            recommendation.setRecommendationType(dietRecommendation.getRecommendationType());
            recommendation.setMealType(dietRecommendation.getMealType());
            recommendation.setSpecialRequirements(dietRecommendation.getSpecialRequirements());
            recommendation.setDislikedFoods(dietRecommendation.getDislikedFoods());
            
            // 基于用户健康信息计算目标营养素
            calculateNutritionTargets(recommendation, userHealth, dietRecommendation.getTargetCalories());
            
            // 生成推荐食物
            generateRecommendedFoods(recommendation, allFoods);
            
            // 设置推荐算法类型和评分
            recommendation.setAlgorithmType("基础推荐算法");
            recommendation.setScore(new BigDecimal("8.5"));
            recommendation.setStatus("0"); // 待应用
            recommendation.setCreateTime(new Date());
            
            // 保存到数据库
            insertDietRecommendation(recommendation);
            
            return recommendation;
        } catch (Exception e) {
            throw new RuntimeException("生成推荐方案失败：" + e.getMessage(), e);
        }
    }

    /**
     * 应用推荐方案
     * 
     * @param recommendationId 推荐方案ID
     * @return 结果
     */
    @Override
    public int applyRecommendation(Long recommendationId)
    {
        return dietRecommendationMapper.updateDietRecommendationStatus(recommendationId, "1");
    }

    /**
     * 获取每日推荐
     * 
     * @param userId 用户ID
     * @param date 日期
     * @return 推荐方案
     */
    @Override
    public DietRecommendation getDailyRecommendation(Long userId, Date date)
    {
        return dietRecommendationMapper.selectDietRecommendationByUserIdAndDate(userId, date);
    }

    /**
     * 生成每日推荐
     * 
     * @param userId 用户ID
     * @param date 日期
     * @return 推荐方案
     */
    @Override
    public DietRecommendation generateDailyRecommendation(Long userId, Date date)
    {
        DietRecommendation recommendation = new DietRecommendation();
        recommendation.setUserId(userId);
        recommendation.setRecommendationDate(date);
        recommendation.setRecommendationType("0"); // 每日推荐
        recommendation.setMealType("0"); // 默认为早餐推荐
        recommendation.setTargetCalories(new BigDecimal("2000")); // 默认2000卡路里
        
        return generateRecommendation(recommendation);
    }

    /**
     * 计算营养目标
     */
    private void calculateNutritionTargets(DietRecommendation recommendation, SysUserHealth userHealth, BigDecimal targetCalories)
    {
        if (targetCalories == null) {
            // 根据用户健康信息计算基础代谢率
            if (userHealth != null) {
                // 简化的BMR计算（Harris-Benedict公式）
                double bmr = 1800; // 默认值
                if ("男".equals(userHealth.getGender())) {
                    bmr = 88.362 + (13.397 * (userHealth.getWeight() != null ? userHealth.getWeight().doubleValue() : 70)) +
                          (4.799 * (userHealth.getHeight() != null ? userHealth.getHeight().doubleValue() : 170)) -
                          (5.677 * (userHealth.getAge() != null ? userHealth.getAge() : 30));
                } else {
                    bmr = 447.593 + (9.247 * (userHealth.getWeight() != null ? userHealth.getWeight().doubleValue() : 60)) +
                          (3.098 * (userHealth.getHeight() != null ? userHealth.getHeight().doubleValue() : 160)) -
                          (4.330 * (userHealth.getAge() != null ? userHealth.getAge() : 30));
                }
                targetCalories = new BigDecimal(bmr * 1.2); // 轻度活动系数
            } else {
                targetCalories = new BigDecimal("2000"); // 默认值
            }
        }
        
        recommendation.setTargetCalories(targetCalories);
        
        // 根据热量计算其他营养素（蛋白质15%，脂肪30%，碳水化合物55%）
        double calories = targetCalories.doubleValue();
        recommendation.setTargetProtein(new BigDecimal(calories * 0.15 / 4)); // 蛋白质1g=4kcal
        recommendation.setTargetFat(new BigDecimal(calories * 0.30 / 9)); // 脂肪1g=9kcal  
        recommendation.setTargetCarbohydrate(new BigDecimal(calories * 0.55 / 4)); // 碳水1g=4kcal
    }

    /**
     * 生成推荐食物
     */
    private void generateRecommendedFoods(DietRecommendation recommendation, List<DietFoodInfo> allFoods)
    {
        if (allFoods == null || allFoods.isEmpty()) {
            recommendation.setRecommendedFoods("白米饭,鸡胸肉,西兰花");
            recommendation.setReason("基于默认食物的基础推荐");
            return;
        }
        
        List<String> recommendedFoodNames = new ArrayList<>();
        StringBuilder reasonBuilder = new StringBuilder();
        
        // 根据餐次类型选择不同的食物
        String mealType = recommendation.getMealType();
        if ("0".equals(mealType)) { // 早餐
            // 选择适合早餐的食物
            for (DietFoodInfo food : allFoods) {
                if (food.getFoodName().contains("蛋") || food.getFoodName().contains("奶") || 
                    food.getFoodName().contains("粥") || food.getFoodName().contains("面包")) {
                    recommendedFoodNames.add(food.getFoodName());
                    if (recommendedFoodNames.size() >= 3) break;
                }
            }
            reasonBuilder.append("早餐推荐富含蛋白质和碳水化合物的食物，有助于开启一天的能量");
        } else if ("1".equals(mealType)) { // 午餐
            // 选择适合午餐的食物
            for (DietFoodInfo food : allFoods) {
                if (food.getFoodName().contains("米饭") || food.getFoodName().contains("肉") || 
                    food.getFoodName().contains("菜") || food.getFoodName().contains("鱼")) {
                    recommendedFoodNames.add(food.getFoodName());
                    if (recommendedFoodNames.size() >= 4) break;
                }
            }
            reasonBuilder.append("午餐推荐营养均衡的搭配，包含主食、蛋白质和蔬菜");
        } else if ("2".equals(mealType)) { // 晚餐
            // 选择适合晚餐的食物
            for (DietFoodInfo food : allFoods) {
                if (food.getFoodName().contains("蔬菜") || food.getFoodName().contains("鱼") || 
                    food.getFoodName().contains("汤") || food.getFoodName().contains("粥")) {
                    recommendedFoodNames.add(food.getFoodName());
                    if (recommendedFoodNames.size() >= 3) break;
                }
            }
            reasonBuilder.append("晚餐推荐清淡易消化的食物，有助于睡眠质量");
        } else { // 加餐
            // 选择适合加餐的食物
            for (DietFoodInfo food : allFoods) {
                if (food.getFoodName().contains("水果") || food.getFoodName().contains("坚果") || 
                    food.getFoodName().contains("酸奶") || food.getFoodName().contains("饼干")) {
                    recommendedFoodNames.add(food.getFoodName());
                    if (recommendedFoodNames.size() >= 2) break;
                }
            }
            reasonBuilder.append("加餐推荐低热量、营养丰富的小食，补充能量不负担");
        }
        
        // 如果没有找到合适的食物，使用默认推荐
        if (recommendedFoodNames.isEmpty()) {
            Random random = new Random();
            int count = Math.min(3, allFoods.size());
            for (int i = 0; i < count; i++) {
                DietFoodInfo food = allFoods.get(random.nextInt(allFoods.size()));
                if (!recommendedFoodNames.contains(food.getFoodName())) {
                    recommendedFoodNames.add(food.getFoodName());
                }
            }
            reasonBuilder.append("基于食物库的随机推荐，营养均衡");
        }
        
        recommendation.setRecommendedFoods(String.join(",", recommendedFoodNames));
        recommendation.setReason(reasonBuilder.toString());
    }
    
    /**
     * 转换ML推荐结果为餐次推荐结果
     */
    private MealRecommendationResult convertMLResultToMealRecommendation(MLRecommendationResult mlResult, String mealType) {
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        result.setSuccess(true);
        
        // 构建推荐食物列表
        List<RecommendedFood> recommendedFoods = new ArrayList<>();
        List<String> reasons = new ArrayList<>();
        double totalScore = 0.0;
        
        for (FoodRecommendation foodRec : mlResult.getRecommendations()) {
            // 创建推荐食物对象
            RecommendedFood food = new RecommendedFood();
            food.setFoodName(foodRec.getFoodName());
            food.setFoodId(foodRec.getFoodId());
            food.setScore(foodRec.getScore());
            food.setReason(foodRec.getReason());
            food.setQuantity(150.0); // 默认150g
            
            recommendedFoods.add(food);
            reasons.add(foodRec.getReason());
            totalScore += foodRec.getScore();
        }
        
        result.setRecommendedFoods(recommendedFoods);
        result.setRecommendationReason(String.join("; ", reasons));
        result.setConfidenceScore(totalScore / mlResult.getRecommendations().size()); // 平均置信度
        
        // 计算总目标热量
        double totalCalories = mlResult.getRecommendations().stream()
            .mapToDouble(rec -> rec.getNutritionInfo().getCaloriesPer100g() * 1.5) // 假设150g份量
            .sum();
        result.setTargetCalories(totalCalories);
        
        // 设置算法信息
        Map<String, Object> algorithmInfo = mlResult.getAlgorithmInfo();
        if (algorithmInfo != null) {
            @SuppressWarnings("unchecked")
            List<String> algorithms = (List<String>) algorithmInfo.get("algorithms_used");
            if (algorithms != null && !algorithms.isEmpty()) {
                result.setAlgorithmType("ML-" + String.join("+", algorithms));
            }
        }
        
        return result;
    }
    
    /**
     * 生成增强规则推荐（基于用户历史数据）
     */
    private MealRecommendationResult generateEnhancedRuleBasedRecommendation(Long userId, String mealType) {
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        result.setSuccess(true);
        
        try {
            // 获取用户健康信息
            SysUserHealth userHealth = sysUserHealthService.selectSysUserHealthByUserId(userId);
            
            // 获取用户画像信息（如果ML服务可用）
            MLRecommendationService.UserProfileResult userProfile = null;
            try {
                userProfile = mlRecommendationService.getUserProfile(userId, 30);
            } catch (Exception e) {
                logger.debug("获取用户画像失败，使用基础推荐: {}", e.getMessage());
            }
            
            // 基于用户特征生成推荐
            List<String> recommendations = new ArrayList<>();
            StringBuilder reasonBuilder = new StringBuilder();
            
            // 根据健康目标调整推荐
            if (userHealth != null && userHealth.getHealthGoal() != null) {
                switch (userHealth.getHealthGoal()) {
                    case "1": // 减脂
                        recommendations.addAll(getLowCalorieFoodsForMeal(mealType));
                        reasonBuilder.append("基于您的减脂目标，推荐低热量高营养食物；");
                        break;
                    case "2": // 增肌
                        recommendations.addAll(getHighProteinFoodsForMeal(mealType));
                        reasonBuilder.append("基于您的增肌目标，推荐高蛋白食物；");
                        break;
                    default: // 保持健康
                        recommendations.addAll(getBalancedFoodsForMeal(mealType));
                        reasonBuilder.append("基于均衡营养原则推荐；");
                        break;
                }
            } else {
                recommendations.addAll(getBalancedFoodsForMeal(mealType));
                reasonBuilder.append("基于营养均衡原则推荐；");
            }
            
            // 基于用户画像调整推荐
            if (userProfile != null && userProfile.isSuccess()) {
                if (userProfile.getDiversityScore() != null && userProfile.getDiversityScore() < 0.3) {
                    // 用户饮食单一，推荐多样化食物
                    recommendations.addAll(getDiverseFoodsForMeal(mealType));
                    reasonBuilder.append("建议增加饮食多样性；");
                }
                
                if (userProfile.getAvgDailyCalories() != null) {
                    double avgCalories = userProfile.getAvgDailyCalories();
                    if (avgCalories < 1500) {
                        // 热量摄入不足
                        recommendations.addAll(getHighCalorieFoodsForMeal(mealType));
                        reasonBuilder.append("建议增加热量摄入；");
                    } else if (avgCalories > 2500) {
                        // 热量摄入过多
                        recommendations.addAll(getLowCalorieFoodsForMeal(mealType));
                        reasonBuilder.append("建议控制热量摄入；");
                    }
                }
            }
            
            // 去重并限制数量
            List<String> uniqueRecommendations = new ArrayList<>(
                recommendations.stream().distinct().limit(8).collect(Collectors.toList())
            );
            
            result.setRecommendedFoods(convertStringListToRecommendedFoods(uniqueRecommendations));
            result.setRecommendationReason(reasonBuilder.toString());
            result.setTargetCalories(calculateMealTargetCalories(userHealth, mealType));
            result.setConfidenceScore(0.75); // 规则推荐置信度
            
            logger.info("增强规则推荐完成，推荐食物数量: {}", uniqueRecommendations.size());
            
        } catch (Exception e) {
            logger.error("增强规则推荐失败: {}", e.getMessage());
            return generateBasicRecommendation(mealType);
        }
        
        return result;
    }
    
    /**
     * 生成基础推荐（最终降级方案）
     */
    private MealRecommendationResult generateBasicRecommendation(String mealType) {
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        result.setSuccess(true);
        
        List<String> basicRecommendations = getBasicFoodsForMeal(mealType);
        result.setRecommendedFoods(convertStringListToRecommendedFoods(basicRecommendations));
        result.setRecommendationReason("基于基础营养需求的推荐");
        result.setTargetCalories(getDefaultMealCalories(mealType));
        result.setConfidenceScore(0.6);
        result.setAlgorithmType("基础规则推荐");
        
        return result;
    }
    
    // =================== 辅助方法 ===================
    
    private String getMealTypeName(String mealType) {
        switch (mealType) {
            case "0": return "早餐";
            case "1": return "午餐";
            case "2": return "晚餐";
            case "3": return "加餐";
            default: return "餐次";
        }
    }
    
    private List<String> getLowCalorieFoodsForMeal(String mealType) {
        Map<String, List<String>> lowCalorieFoods = new HashMap<>();
        lowCalorieFoods.put("0", Arrays.asList("燕麦粥", "鸡蛋白", "脱脂牛奶", "全麦面包", "蓝莓"));
        lowCalorieFoods.put("1", Arrays.asList("鸡胸肉", "西兰花", "菠菜", "黄瓜", "豆腐"));
        lowCalorieFoods.put("2", Arrays.asList("蒸蛋羹", "冬瓜汤", "青菜", "白萝卜", "紫菜蛋花汤"));
        lowCalorieFoods.put("3", Arrays.asList("苹果", "黄瓜片", "胡萝卜", "樱桃番茄", "绿茶"));
        return new ArrayList<>(lowCalorieFoods.getOrDefault(mealType, lowCalorieFoods.get("1")));
    }
    
    private List<String> getHighProteinFoodsForMeal(String mealType) {
        Map<String, List<String>> highProteinFoods = new HashMap<>();
        highProteinFoods.put("0", Arrays.asList("鸡蛋", "牛奶", "希腊酸奶", "燕麦蛋白粉", "坚果"));
        highProteinFoods.put("1", Arrays.asList("鸡胸肉", "牛肉", "三文鱼", "豆腐", "鸡蛋"));
        highProteinFoods.put("2", Arrays.asList("瘦肉", "鱼类", "豆制品", "鸡蛋", "虾"));
        highProteinFoods.put("3", Arrays.asList("坚果", "酸奶", "煮蛋", "蛋白棒", "牛奶"));
        return new ArrayList<>(highProteinFoods.getOrDefault(mealType, highProteinFoods.get("1")));
    }
    
    private List<String> getBalancedFoodsForMeal(String mealType) {
        Map<String, List<String>> balancedFoods = new HashMap<>();
        balancedFoods.put("0", Arrays.asList("燕麦粥", "鸡蛋", "牛奶", "香蕉", "全麦吐司"));
        balancedFoods.put("1", Arrays.asList("糙米饭", "鸡肉", "西兰花", "胡萝卜", "豆腐汤"));
        balancedFoods.put("2", Arrays.asList("小米粥", "鱼肉", "青菜", "豆腐", "紫薯"));
        balancedFoods.put("3", Arrays.asList("苹果", "核桃", "酸奶", "红枣", "蜂蜜"));
        return new ArrayList<>(balancedFoods.getOrDefault(mealType, balancedFoods.get("1")));
    }
    
    private List<String> getDiverseFoodsForMeal(String mealType) {
        Map<String, List<String>> diverseFoods = new HashMap<>();
        diverseFoods.put("0", Arrays.asList("紫薯粥", "鹌鹑蛋", "羊奶", "奇异果", "藜麦饼"));
        diverseFoods.put("1", Arrays.asList("黑米饭", "鸭肉", "芦笋", "彩椒", "海带汤"));
        diverseFoods.put("2", Arrays.asList("薏米粥", "带鱼", "菠菜", "山药", "银耳汤"));
        diverseFoods.put("3", Arrays.asList("火龙果", "腰果", "椰汁", "枸杞", "柠檬蜂蜜水"));
        return new ArrayList<>(diverseFoods.getOrDefault(mealType, diverseFoods.get("1")));
    }
    
    private List<String> getHighCalorieFoodsForMeal(String mealType) {
        Map<String, List<String>> highCalorieFoods = new HashMap<>();
        highCalorieFoods.put("0", Arrays.asList("牛油果吐司", "坚果燕麦", "全脂牛奶", "花生酱面包", "香蕉奶昔"));
        highCalorieFoods.put("1", Arrays.asList("牛肉饭", "三文鱼", "坚果沙拉", "芝士意面", "牛油果"));
        highCalorieFoods.put("2", Arrays.asList("排骨汤", "红烧肉", "坚果", "芝麻糊", "红薯"));
        highCalorieFoods.put("3", Arrays.asList("坚果", "干果", "巧克力", "奶昔", "能量棒"));
        return new ArrayList<>(highCalorieFoods.getOrDefault(mealType, highCalorieFoods.get("1")));
    }
    
    private List<String> getBasicFoodsForMeal(String mealType) {
        Map<String, List<String>> basicFoods = new HashMap<>();
        basicFoods.put("0", Arrays.asList("粥", "鸡蛋", "牛奶", "面包"));
        basicFoods.put("1", Arrays.asList("米饭", "肉类", "蔬菜", "汤"));
        basicFoods.put("2", Arrays.asList("粥", "蔬菜", "豆腐", "汤"));
        basicFoods.put("3", Arrays.asList("水果", "坚果", "酸奶", "茶"));
        return new ArrayList<>(basicFoods.getOrDefault(mealType, basicFoods.get("1")));
    }
    
    private double calculateMealTargetCalories(SysUserHealth userHealth, String mealType) {
        double dailyCalories = 2000.0;
        
        if (userHealth != null && userHealth.getDailyCalorieGoal() != null) {
            dailyCalories = userHealth.getDailyCalorieGoal().doubleValue();
        }
        
        // 餐次热量分配
        switch (mealType) {
            case "0": return dailyCalories * 0.25; // 早餐 25%
            case "1": return dailyCalories * 0.40; // 午餐 40%
            case "2": return dailyCalories * 0.30; // 晚餐 30%
            case "3": return dailyCalories * 0.05; // 加餐 5%
            default: return dailyCalories * 0.33;
        }
    }
    
    private double getDefaultMealCalories(String mealType) {
        switch (mealType) {
            case "0": return 500.0; // 早餐
            case "1": return 800.0; // 午餐
            case "2": return 600.0; // 晚餐
            case "3": return 100.0; // 加餐
            default: return 600.0;
        }
    }
    
    /**
     * 将字符串列表转换为推荐食物列表
     */
    private List<RecommendedFood> convertStringListToRecommendedFoods(List<String> foodNames) {
        return foodNames.stream().map(foodName -> {
            RecommendedFood food = new RecommendedFood();
            food.setFoodName(foodName);
            food.setFoodId(0L); // 默认ID
            food.setScore(0.8); // 默认评分
            food.setReason("规则推荐");
            food.setQuantity(150.0); // 默认份量
            return food;
        }).collect(Collectors.toList());
    }

    @Override
    public DailyRecommendationResult generateDetailedDailyRecommendation(Long userId, Date date)
    {
        // TODO: 实现每日饮食推荐算法
        DailyRecommendationResult result = new DailyRecommendationResult();
        result.setSuccess(false);
        result.setErrorMessage("推荐功能尚未实现");
        return result;
    }

    @Override
    public MealRecommendationResult generateMealRecommendation(Long userId, String mealType, Double targetCalories)
    {
        // TODO: 实现单餐推荐算法
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        result.setTargetCalories(targetCalories);
        result.setRecommendationReason("推荐功能尚未实现");
        return result;
    }

    @Override
    public MealRecommendationResult generatePersonalizedRecommendation(Long userId, String mealType)
    {
        logger.info("为用户 {} 生成{}个性化推荐", userId, getMealTypeName(mealType));
        
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        
        try {
            if (mlRecommendationEnabled) {
                // 1. 尝试使用ML推荐
                MLRecommendationResult mlResult = mlRecommendationService.getPersonalizedRecommendation(
                    userId, mealType, null, null, null, 8
                );
                
                if (mlResult != null && mlResult.isSuccess() && mlResult.getRecommendations() != null) {
                    // 转换ML推荐结果
                    result = convertMLResultToMealRecommendation(mlResult, mealType);
                    result.setAlgorithmType("机器学习个性化推荐");
                    logger.info("ML个性化推荐成功，推荐数量: {}", mlResult.getRecommendations().size());
                    return result;
                }
            }
            
            // 2. 降级到增强规则推荐
            logger.info("ML推荐不可用，使用增强规则推荐");
            result = generateEnhancedRuleBasedRecommendation(userId, mealType);
            result.setAlgorithmType("增强规则推荐");
            
        } catch (Exception e) {
            logger.error("个性化推荐生成失败: {}", e.getMessage(), e);
            
            // 3. 最终降级方案
            result = generateBasicRecommendation(mealType);
            result.setAlgorithmType("基础规则推荐");
        }
        
        return result;
    }

    @Override
    public MealRecommendationResult generateHealthGoalBasedRecommendation(SysUserHealth userHealth, String mealType, Double targetCalories)
    {
        // TODO: 实现基于健康目标的推荐算法
        MealRecommendationResult result = new MealRecommendationResult();
        result.setMealType(mealType);
        result.setTargetCalories(targetCalories);
        result.setRecommendationReason("基于健康目标的推荐功能尚未实现");
        return result;
    }
}