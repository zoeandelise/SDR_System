// AI智能推荐页面 - 基于协同过滤算法
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { useToast } from '../components/ui/Toast';

interface RecommendedFood {
    food_id: number;
    food_name: string;
    calories: number;
    protein: number;
    carbohydrate: number;
    fat: number;
    score?: number;
    reason?: string;
}

interface DailyPlan {
    breakfast: RecommendedFood[];
    lunch: RecommendedFood[];
    dinner: RecommendedFood[];
    totalCalories: number;
    totalProtein: number;
    totalCarbohydrate: number;
    totalFat: number;
}

const SmartRecommendationPage: React.FC = () => {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);
    const [dailyPlan, setDailyPlan] = useState<DailyPlan | null>(null);
    const [error, setError] = useState('');
    const [saving, setSaving] = useState(false);
    const [replacingFood, setReplacingFood] = useState<string | null>(null); // 正在替换的食物标识
    const [selectedFood, setSelectedFood] = useState<RecommendedFood | null>(null);
    const { showToast } = useToast();

    // 生成今日方案
    const generateDailyPlan = async () => {
        try {
            setLoading(true);
            setError('');
            setDailyPlan(null);

            const response: any = await api.post('/api/user/diet/daily-plan', {});

            if (response.code === 200 && response.data) {
                // 延迟一点以展示加载动画（因为太快了用户没感觉）
                setTimeout(() => {
                    setDailyPlan(response.data);
                    setLoading(false);
                }, 1500);
            } else {
                throw new Error(response.data.msg || '生成方案失败');
                setLoading(false);
            }
        } catch (err: any) {
            console.error('生成方案失败:', err);
            setError(err.response?.data?.msg || err.message || '生成方案失败');
            setLoading(false);
        }
    };

    // 保存方案
    const saveDailyPlan = async () => {
        if (!dailyPlan) return;

        try {
            setSaving(true);

            const response: any = await api.post('/api/user/diet/save-daily-plan', dailyPlan);

            if (response.code === 200) {
                showToast('success', '已添加至今日方案！请在首页点击【打卡】记录热量。');
                navigate('/');
            } else {
                throw new Error(response.msg || '保存失败');
            }
        } catch (err: any) {
            console.error('保存方案失败:', err);
            showToast('error', '保存失败：' + (err.response?.data?.msg || err.message));
        } finally {
            setSaving(false);
        }
    };

    // 替换单个食物
    const replaceFood = async (mealType: 'breakfast' | 'lunch' | 'dinner', foodIndex: number) => {
        if (!dailyPlan) return;

        const mealTypeMap = { breakfast: '0', lunch: '1', dinner: '2' };
        const mealTypeCode = mealTypeMap[mealType];
        const currentFood = dailyPlan[mealType][foodIndex];
        const foodKey = `${mealType}-${foodIndex}`;

        try {
            setReplacingFood(foodKey);

            const response: any = await api.post('/api/user/diet/replace-food', {
                mealType: mealTypeCode,
                excludeFoodId: currentFood.food_id
            });

            if (response.code === 200 && response.data) {
                // 映射字段名
                const newFood: RecommendedFood = {
                    food_id: response.data.food_id,
                    food_name: response.data.food_name,
                    calories: response.data.calories_per_100g || response.data.calories || 0,
                    protein: response.data.protein_per_100g || response.data.protein || 0,
                    carbohydrate: response.data.carb_per_100g || response.data.carbohydrate || 0,
                    fat: response.data.fat_per_100g || response.data.fat || 0,
                    reason: response.data.reason || '智能推荐'
                };

                // 更新 dailyPlan 中对应的食物
                const updatedMeal = [...dailyPlan[mealType]];
                updatedMeal[foodIndex] = newFood;

                // 重新计算总营养（四舍五入避免浮点精度问题）
                const updatedPlan = { ...dailyPlan, [mealType]: updatedMeal };
                const allFoods = [...updatedPlan.breakfast, ...updatedPlan.lunch, ...updatedPlan.dinner];
                updatedPlan.totalCalories = Math.round(allFoods.reduce((sum, f) => sum + (f.calories || 0), 0));
                updatedPlan.totalProtein = Math.round(allFoods.reduce((sum, f) => sum + (f.protein || 0), 0) * 10) / 10;
                updatedPlan.totalCarbohydrate = Math.round(allFoods.reduce((sum, f) => sum + (f.carbohydrate || 0), 0) * 10) / 10;
                updatedPlan.totalFat = Math.round(allFoods.reduce((sum, f) => sum + (f.fat || 0), 0) * 10) / 10;

                setDailyPlan(updatedPlan);
            } else {
                throw new Error(response.msg || '替换失败');
            }
        } catch (err: any) {
            console.error('替换食物失败:', err);
            showToast('error', '替换失败：' + (err.message || '未知错误'));
        } finally {
            setReplacingFood(null);
        }
    };

    useEffect(() => {
        // 页面加载时自动生成方案
        generateDailyPlan();
    }, []);

    return (
        <div className="animate-fadeIn">
                {/* 顶部介绍区 */}
                <div className="text-center mb-10">
                    <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-600 to-pink-600 mb-3">
                        AI 智能膳食推荐
                    </h1>
                    <p className="text-gray-600 font-medium max-w-2xl mx-auto text-lg">
                        利用协同过滤算法，分析您的历史偏好与健康目标，为您量身定制今日的三餐计划。
                    </p>
                </div>

                {/* 算法展示卡片 */}
                <div className="mb-8 relative overflow-hidden rounded-2xl bg-gradient-to-r from-indigo-900 to-purple-900 text-white shadow-xl">
                    <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full blur-3xl -mr-16 -mt-16"></div>
                    <div className="p-8 relative z-10 flex flex-col md:flex-row items-center justify-between gap-6">
                        <div className="flex items-center space-x-4">
                            <div className="w-16 h-16 bg-white/10 rounded-2xl flex items-center justify-center backdrop-blur-sm text-4xl">
                                🧠
                            </div>
                            <div>
                                <h2 className="text-xl font-bold mb-2 !text-white">推荐引擎核心</h2>
                                <div className="flex flex-wrap gap-2">
                                    {['协同过滤', '营养均衡', '口味偏好', '热量控制'].map((tag) => (
                                        <span key={tag} className="px-3 py-1 bg-white/40 hover:bg-white/50 transition-colors rounded-lg text-sm font-bold text-white border border-white/40">
                                            {tag}
                                        </span>
                                    ))}
                                </div>
                            </div>
                        </div>

                        <div className="flex gap-3">
                            <Button
                                onClick={generateDailyPlan}
                                disabled={loading}
                                variant="secondary"
                                className="bg-white/10 text-white border-white/20 hover:bg-white/20"
                            >
                                {loading ? '分析中...' : '🔄 重新生成'}
                            </Button>
                        </div>
                    </div>
                </div>

                {/* 错误提示 */}
                {error && (
                    <div className="mb-6 bg-red-50 border border-red-200 rounded-xl p-4 flex items-center justify-between animate-fadeIn">
                        <div className="flex items-center">
                            <span className="text-red-500 mr-2 text-xl">⚠️</span>
                            <span className="text-red-700">{error}</span>
                        </div>
                    </div>
                )}

                {/* 加载状态 */}
                {loading && (
                    <div className="py-20 text-center">
                        <div className="relative w-24 h-24 mx-auto mb-8">
                            <div className="absolute inset-0 border-4 border-gray-100 rounded-full"></div>
                            <div className="absolute inset-0 border-4 border-purple-500 rounded-full border-t-transparent animate-spin"></div>
                            <div className="absolute inset-0 flex items-center justify-center text-3xl animate-pulse">
                                🥗
                            </div>
                        </div>
                        <h3 className="text-xl font-bold text-gray-900 mb-2">正在为您规划食谱...</h3>
                        <p className="text-gray-600 font-bold text-sm">AI 正在计算最佳营养组合</p>
                    </div>
                )}

                {/* 方案展示 */}
                {!loading && dailyPlan && (
                    <div className="animate-slideUp space-y-8">
                        {/* 营养概览 */}
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <NutritionOverviewCard
                                label="总热量"
                                value={dailyPlan.totalCalories}
                                unit="kcal"
                                color="text-orange-500"
                                bgColor="bg-orange-50"
                            />
                            <NutritionOverviewCard
                                label="蛋白质"
                                value={dailyPlan.totalProtein}
                                unit="g"
                                color="text-blue-500"
                                bgColor="bg-blue-50"
                            />
                            <NutritionOverviewCard
                                label="碳水"
                                value={dailyPlan.totalCarbohydrate}
                                unit="g"
                                color="text-yellow-600"
                                bgColor="bg-yellow-50"
                            />
                            <NutritionOverviewCard
                                label="脂肪"
                                value={dailyPlan.totalFat}
                                unit="g"
                                color="text-purple-500"
                                bgColor="bg-purple-50"
                            />
                        </div>

                        {/* 三餐卡片 */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                            <MealCard
                                title="早餐"
                                emoji="🍳"
                                foods={dailyPlan.breakfast}
                                type="breakfast"
                                onReplace={(idx: number) => replaceFood('breakfast', idx)}
                                onFoodClick={(food: RecommendedFood) => setSelectedFood(food)}
                                replacingFood={replacingFood}
                            />
                            <MealCard
                                title="午餐"
                                emoji="🍱"
                                foods={dailyPlan.lunch}
                                type="lunch"
                                onReplace={(idx: number) => replaceFood('lunch', idx)}
                                onFoodClick={(food: RecommendedFood) => setSelectedFood(food)}
                                replacingFood={replacingFood}
                            />
                            <MealCard
                                title="晚餐"
                                emoji="🍲"
                                foods={dailyPlan.dinner}
                                type="dinner"
                                onReplace={(idx: number) => replaceFood('dinner', idx)}
                                onFoodClick={(food: RecommendedFood) => setSelectedFood(food)}
                                replacingFood={replacingFood}
                            />
                        </div>

                        {/* 提示说明 */}
                        <div className="bg-emerald-50 border border-emerald-200 rounded-xl px-5 py-3 text-sm text-emerald-800">
                            <span className="font-bold">提示：</span>添加到今日方案后不会直接计入热量，请记得在<span className="font-bold text-emerald-600">「首页 - 今日饮食」</span>中点击【打卡】完成记录。
                        </div>

                        {/* 底部操作区 */}
                        <div className="fixed bottom-0 left-0 right-0 p-4 bg-white border-t shadow-lg md:relative md:bg-transparent md:border-0 md:shadow-none md:p-0 z-20">
                            <div className="max-w-5xl mx-auto flex gap-4">
                                <Button
                                    onClick={generateDailyPlan}
                                    variant="outline"
                                    className="flex-1 md:flex-none border-gray-300"
                                >
                                    不喜欢，换一组
                                </Button>
                                <Button
                                    onClick={saveDailyPlan}
                                    disabled={saving}
                                    className="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg hover:shadow-purple-500/30"
                                >
                                    {saving ? '正在添加...' : '✨ 添加至今日方案'}
                                </Button>
                            </div>
                        </div>
                        {/* 移动端底部垫高 */}
                        <div className="h-20 md:hidden"></div>
                    </div>
                )}

                {/* 食物详情浮窗 */}
                {selectedFood && (() => {
                    const sf = selectedFood as any;
                    const portion = sf.recommended_portion || (() => {
                        const name = sf.food_name || '';
                        if (name.includes('饭') || name.includes('面') || name.includes('粥')) return 200;
                        if (name.includes('汤') || name.includes('水') || name.includes('奶') || name.includes('豆浆')) return 250;
                        if (name.includes('菜') || name.includes('瓜') || name.includes('花')) return 150;
                        if (name.includes('肉') || name.includes('鱼') || name.includes('虾') || name.includes('鸡')) return 100;
                        if (name.includes('蛋')) return 50;
                        return 100;
                    })();
                    const cal100 = sf.calories_per_100g || sf.calories || 0;
                    const pro100 = sf.protein_per_100g || sf.protein || 0;
                    const carb100 = sf.carb_per_100g || sf.carbohydrate || 0;
                    const fat100 = sf.fat_per_100g || sf.fat || 0;
                    const actualCal = Math.round(cal100 * portion / 100);
                    const actualPro = Math.round(pro100 * portion / 100 * 10) / 10;
                    const actualCarb = Math.round(carb100 * portion / 100 * 10) / 10;
                    const actualFat = Math.round(fat100 * portion / 100 * 10) / 10;
                    const totalMacro = actualPro + actualCarb + actualFat;
                    const proPct = totalMacro > 0 ? Math.round(actualPro / totalMacro * 100) : 0;
                    const carbPct = totalMacro > 0 ? Math.round(actualCarb / totalMacro * 100) : 0;
                    const fatPct = totalMacro > 0 ? 100 - proPct - carbPct : 0;
                    const score = sf.score;

                    return (
                        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-[60] p-4 animate-fadeIn" onClick={() => setSelectedFood(null)}>
                            <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl animate-scaleIn relative overflow-hidden" onClick={e => e.stopPropagation()}>
                                <div className="bg-gradient-to-r from-purple-500 to-pink-500 p-5 text-white">
                                    <div className="flex justify-between items-start">
                                        <div>
                                            <h3 className="text-xl font-bold">{sf.food_name}</h3>
                                            {sf.reason && (
                                                <div className="text-sm mt-1.5 text-white/85">💡 {sf.reason}</div>
                                            )}
                                        </div>
                                        <button
                                            onClick={() => setSelectedFood(null)}
                                            className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center text-white hover:bg-white/30 transition-colors"
                                        >
                                            ✕
                                        </button>
                                    </div>
                                </div>
                                <div className="p-5 space-y-4">
                                    {/* 分量 + 推荐分数 */}
                                    <div className="flex gap-3">
                                        <div className="flex-1 bg-amber-50 rounded-xl p-3 text-center border border-amber-100">
                                            <div className="text-xs text-amber-600 font-bold mb-1">推荐分量</div>
                                            <div className="text-xl font-bold text-gray-900">{portion}<span className="text-xs font-normal">g</span></div>
                                        </div>
                                        {score != null && (
                                            <div className="flex-1 bg-purple-50 rounded-xl p-3 text-center border border-purple-100">
                                                <div className="text-xs text-purple-600 font-bold mb-1">推荐指数</div>
                                                <div className="text-xl font-bold text-gray-900">{Math.round(score * 100)}<span className="text-xs font-normal">分</span></div>
                                            </div>
                                        )}
                                    </div>

                                    {/* 每份实际营养 */}
                                    <div className="bg-orange-50 rounded-xl p-4 text-center border border-orange-100">
                                        <div className="text-sm text-orange-600 font-semibold mb-1">每份热量</div>
                                        <div className="text-3xl font-black text-gray-900">
                                            {actualCal}
                                            <span className="text-base font-normal text-gray-500 ml-1">kcal</span>
                                        </div>
                                        <div className="text-xs text-gray-500 mt-1">约 {portion}g 份量</div>
                                    </div>

                                    {/* 每份三大营养素 */}
                                    <div className="grid grid-cols-3 gap-3">
                                        <div className="bg-blue-50 rounded-xl p-3 text-center border border-blue-100">
                                            <div className="text-xs text-blue-600 font-bold mb-1">蛋白质</div>
                                            <div className="text-lg font-bold text-gray-900">{actualPro}<span className="text-xs font-normal">g</span></div>
                                        </div>
                                        <div className="bg-yellow-50 rounded-xl p-3 text-center border border-yellow-100">
                                            <div className="text-xs text-yellow-600 font-bold mb-1">碳水</div>
                                            <div className="text-lg font-bold text-gray-900">{actualCarb}<span className="text-xs font-normal">g</span></div>
                                        </div>
                                        <div className="bg-purple-50 rounded-xl p-3 text-center border border-purple-100">
                                            <div className="text-xs text-purple-600 font-bold mb-1">脂肪</div>
                                            <div className="text-lg font-bold text-gray-900">{actualFat}<span className="text-xs font-normal">g</span></div>
                                        </div>
                                    </div>

                                    {/* 营养占比条 */}
                                    {totalMacro > 0 && (
                                        <div className="bg-purple-50/50 rounded-xl p-3 border border-purple-100/50">
                                            <div className="text-xs text-purple-700 font-bold mb-2">营养构成</div>
                                            <div className="flex h-3 rounded-full overflow-hidden bg-gray-200">
                                                <div className="bg-blue-400" style={{ width: `${proPct}%` }} />
                                                <div className="bg-yellow-400" style={{ width: `${carbPct}%` }} />
                                                <div className="bg-purple-400" style={{ width: `${fatPct}%` }} />
                                            </div>
                                            <div className="flex justify-between text-[10px] font-semibold mt-1.5">
                                                <span className="text-blue-600">蛋白 {proPct}%</span>
                                                <span className="text-yellow-600">碳水 {carbPct}%</span>
                                                <span className="text-purple-600">脂肪 {fatPct}%</span>
                                            </div>
                                        </div>
                                    )}

                                    {/* 每100g参考 */}
                                    <div className="text-xs text-gray-400 text-center">
                                        参考值：每100g 含 {Math.round(cal100)} kcal / {Math.round(pro100 * 10) / 10}g 蛋白 / {Math.round(carb100 * 10) / 10}g 碳水 / {Math.round(fat100 * 10) / 10}g 脂肪
                                    </div>

                                    <button
                                        onClick={() => setSelectedFood(null)}
                                        className="w-full py-2.5 rounded-xl bg-gray-100 text-gray-700 font-semibold hover:bg-gray-200 transition-colors"
                                    >
                                        关闭
                                    </button>
                                </div>
                            </div>
                        </div>
                    );
                })()}
            </div>
    );
};

// 子组件：营养概览卡片
const NutritionOverviewCard = ({ label, value, unit, color, bgColor }: any) => {
    const displayValue = typeof value === 'number' ? Math.round(value * 10) / 10 : value;
    return (
        <Card className={`${bgColor} border-0 shadow-sm`}>
            <div className="text-center p-3">
                <div className={`text-3xl font-black ${color}`}>{displayValue}</div>
                <div className="text-sm font-bold text-gray-600 mt-1">{label} ({unit})</div>
            </div>
        </Card>
    );
};

// 子组件：餐食卡片
const MealCard = ({ title, emoji, foods, type, onReplace, onFoodClick, replacingFood }: any) => {
    const bgGradient =
        type === 'breakfast' ? 'from-orange-100 to-orange-50' :
            type === 'lunch' ? 'from-green-100 to-green-50' :
                'from-blue-100 to-blue-50';

    const iconColor =
        type === 'breakfast' ? 'bg-orange-200 text-orange-700' :
            type === 'lunch' ? 'bg-green-200 text-green-700' :
                'bg-blue-200 text-blue-700';

    // 饮食时间和建议提示
    const mealTips: Record<string, { time: string; tip: string }> = {
        breakfast: { time: '7:00-9:00', tip: '蛋白质优先，启动新陈代谢' },
        lunch: { time: '11:30-13:00', tip: '均衡搭配，补充能量' },
        dinner: { time: '17:30-19:00', tip: '清淡为主，易于消化' }
    };

    const tip = mealTips[type];

    // 根据食物类型估算标准分量(g)
    const getPortionSize = (food: any): number => {
        const name = food.food_name || '';
        // 主食类
        if (name.includes('饭') || name.includes('面') || name.includes('粥')) return 200;
        // 饮品类
        if (name.includes('汤') || name.includes('水') || name.includes('奶') || name.includes('豆浆')) return 250;
        // 蔬菜类
        if (name.includes('菜') || name.includes('瓜') || name.includes('花')) return 150;
        // 肉类
        if (name.includes('肉') || name.includes('鱼') || name.includes('虾') || name.includes('鸡')) return 100;
        // 蛋类
        if (name.includes('蛋')) return 50;
        // 默认
        return 100;
    };

    return (
        <Card className="overflow-hidden border-0 shadow-md flex flex-col h-full hover:shadow-xl transition-shadow duration-300">
            <div className={`p-4 bg-gradient-to-r ${bgGradient}`}>
                <div className="flex items-center gap-3 mb-2">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center ${iconColor} text-xl shadow-sm`}>
                        {emoji}
                    </div>
                    <div>
                        <h3 className="font-bold text-gray-800 text-lg">{title}</h3>
                        {tip && (
                            <div className="text-sm font-bold text-gray-600">⏰ {tip.time}</div>
                        )}
                    </div>
                </div>
                {tip && (
                    <div className="text-xs font-bold text-gray-800 bg-white/70 shadow-sm px-3 py-1.5 rounded-lg border border-white/50">
                        💡 <span className="font-medium">{tip.tip}</span>
                    </div>
                )}
            </div>

            <div className="p-4 space-y-3 flex-1 bg-white">
                {foods?.map((food: any, idx: number) => {
                    const isReplacing = replacingFood === `${type}-${idx}`;
                    // 使用后端返回的推荐分量，没有则用估算值
                    const portion = food.recommended_portion || getPortionSize(food);
                    // 计算该分量对应的实际热量和蛋白质
                    const actualCalories = Math.round((food.calories_per_100g || food.calories || 0) * portion / 100);
                    const actualProtein = Math.round((food.protein_per_100g || food.protein || 0) * portion / 100 * 10) / 10;
                    return (
                        <div
                            key={idx}
                            className="flex items-start gap-3 p-2 rounded-lg hover:bg-gray-50 transition-colors group cursor-pointer"
                            onClick={() => onFoodClick && onFoodClick(food)}
                        >
                            <div className="w-1.5 h-1.5 rounded-full bg-gray-300 mt-2 group-hover:bg-purple-400 transition-colors"></div>
                            <div className="flex-1">
                                <div className="font-bold text-gray-900 text-base leading-tight">
                                    {food.food_name}
                                </div>
                                <div className="text-sm font-semibold text-gray-600 mt-1 flex flex-wrap gap-2">
                                    <span className="bg-amber-100/80 text-amber-800 px-1.5 rounded">{portion}g</span>
                                    <span>{actualCalories} kcal</span>
                                    <span>· {actualProtein}g 蛋白</span>
                                </div>
                                {food.reason && (
                                    <div className="text-xs font-bold text-purple-700 mt-1 hover:bg-purple-100 bg-purple-50 px-2 py-0.5 rounded inline-block transition-colors">
                                        💡 {food.reason}
                                    </div>
                                )}
                            </div>
                            {/* 替换按钮 */}
                            <button
                                onClick={() => onReplace && onReplace(idx)}
                                onMouseDown={(e) => e.stopPropagation()}
                                disabled={isReplacing}
                                className={`text-xs px-2 py-1 rounded-full transition-all opacity-0 group-hover:opacity-100 ${isReplacing
                                    ? 'bg-gray-100 text-gray-400 cursor-wait'
                                    : 'bg-purple-100 text-purple-600 hover:bg-purple-200'
                                    }`}
                                title="换一个"
                            >
                                {isReplacing ? '⚙️' : '🔄 换'}
                            </button>
                        </div>
                    );
                })}
                {(!foods || foods.length === 0) && (
                    <div className="text-center text-gray-400 py-8 text-sm">
                        暂无推荐
                    </div>
                )}
            </div>
        </Card>
    );
};

export default SmartRecommendationPage;
