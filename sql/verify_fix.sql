SELECT i.food_name, n.calories, n.protein, n.fat, n.carbohydrate
FROM diet_food_nutrition n 
JOIN diet_food_info i ON n.food_id = i.food_id 
WHERE i.food_name IN ('大米粥', '白面馒头', '西瓜', '红烧肉(家常)');
