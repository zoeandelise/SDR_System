// 食物分量估算工具函数

/**
 * 根据食物名称估算标准分量(g)
 * @param foodName 食物名称
 * @returns 估算的分量(g)
 */
export const getPortionSize = (foodName: string): number => {
    const name = foodName || '';

    // 主食类
    if (name.includes('饭') || name.includes('面') || name.includes('粥')) return 200;
    if (name.includes('馒头') || name.includes('包子')) return 100;
    if (name.includes('玉米') || name.includes('红薯') || name.includes('土豆')) return 150;

    // 饮品类
    if (name.includes('汤') || name.includes('水') || name.includes('奶') || name.includes('豆浆') || name.includes('茶')) return 250;

    // 蔬菜类
    if (name.includes('菜') || name.includes('瓜') || name.includes('花') || name.includes('萝卜') || name.includes('茄')) return 150;

    // 肉类
    if (name.includes('肉') || name.includes('鱼') || name.includes('虾') || name.includes('鸡') || name.includes('鸭') || name.includes('排骨')) return 100;

    // 蛋类
    if (name.includes('蛋')) return 50;

    // 水果类
    if (name.includes('苹果') || name.includes('橙') || name.includes('梨') || name.includes('香蕉')) return 150;

    // 豆制品
    if (name.includes('豆腐') || name.includes('豆干')) return 100;

    // 默认
    return 100;
};

/**
 * 计算食物列表中各食物的估算分量和每份热量
 * @param foodNames 食物名称（逗号分隔）
 * @param totalCalories 总热量
 * @returns 带分量和热量的食物列表
 */
export const parseFoodsWithPortion = (foodNames: string, totalCalories: number) => {
    if (!foodNames) return [];

    const foods = foodNames.split(/[,，、]/)
        .map(name => name.trim().replace(/^(早餐|午餐|晚餐|加餐)[::：]\s*/, ''))
        .filter(name => name.length > 0);

    if (foods.length === 0) return [];

    // 估算每个食物的分量
    const foodsWithPortion = foods.map(name => ({
        name,
        portion: getPortionSize(name)
    }));

    // 根据分量比例分配热量
    const totalPortion = foodsWithPortion.reduce((sum, f) => sum + f.portion, 0);

    return foodsWithPortion.map(f => ({
        name: f.name,
        portion: f.portion,
        calories: Math.round(totalCalories * f.portion / totalPortion)
    }));
};

/**
 * 格式化显示食物和分量
 * @param foodName 食物名称
 * @returns 带分量的显示文本
 */
export const formatFoodWithPortion = (foodName: string): string => {
    const portion = getPortionSize(foodName);
    return `${foodName}(${portion}g)`;
};
