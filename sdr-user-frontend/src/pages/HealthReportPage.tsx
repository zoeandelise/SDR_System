import React, { useState } from 'react';
import { BarChart3, TrendingUp, Calendar, Download, Filter, Award, Activity, Heart } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

const HealthReportPage: React.FC = () => {
  const [selectedPeriod, setSelectedPeriod] = useState('week');
  const [selectedMetric, setSelectedMetric] = useState('all');

  const periods = [
    { id: 'week', name: '本周', days: 7 },
    { id: 'month', name: '本月', days: 30 },
    { id: 'quarter', name: '本季度', days: 90 },
    { id: 'year', name: '本年', days: 365 }
  ];

  const metrics = [
    { id: 'all', name: '全部指标', icon: '📊' },
    { id: 'weight', name: '体重变化', icon: '⚖️' },
    { id: 'nutrition', name: '营养摄入', icon: '🥗' },
    { id: 'exercise', name: '运动数据', icon: '🏃' },
    { id: 'sleep', name: '睡眠质量', icon: '😴' }
  ];

  // 模拟数据
  const weeklyData = [
    { day: '周一', calories: 1850, protein: 75, carbs: 230, fat: 48, exercise: 45, weight: 70.2 },
    { day: '周二', calories: 1920, protein: 82, carbs: 245, fat: 52, exercise: 60, weight: 70.1 },
    { day: '周三', calories: 1780, protein: 68, carbs: 220, fat: 45, exercise: 30, weight: 70.0 },
    { day: '周四', calories: 2100, protein: 95, carbs: 280, fat: 58, exercise: 75, weight: 69.9 },
    { day: '周五', calories: 1950, protein: 88, carbs: 250, fat: 55, exercise: 50, weight: 69.8 },
    { day: '周六', calories: 2200, protein: 102, carbs: 290, fat: 62, exercise: 90, weight: 69.7 },
    { day: '周日', calories: 1880, protein: 78, carbs: 235, fat: 48, exercise: 40, weight: 69.6 }
  ];

  const healthScores = {
    overall: 85,
    nutrition: 88,
    exercise: 82,
    sleep: 79,
    hydration: 91
  };

  const achievements = [
    { title: '连续打卡7天', icon: '🔥', date: '2024-09-28', type: 'streak' },
    { title: '达成蛋白质目标', icon: '💪', date: '2024-09-27', type: 'nutrition' },
    { title: '完成运动目标', icon: '🏃', date: '2024-09-26', type: 'exercise' },
    { title: '体重下降1kg', icon: '⚖️', date: '2024-09-25', type: 'weight' }
  ];

  const nutritionTrends = {
    calories: { current: 1920, target: 2000, change: -4.2, trend: 'down' },
    protein: { current: 84, target: 80, change: +5.2, trend: 'up' },
    carbs: { current: 248, target: 250, change: -0.8, trend: 'stable' },
    fat: { current: 52, target: 55, change: -5.5, trend: 'down' }
  };

  const exportReport = () => {
    alert('健康报告已导出！');
  };

  const getTrendIcon = (trend: string) => {
    switch (trend) {
      case 'up': return <TrendingUp className="h-4 w-4 text-green-500" />;
      case 'down': return <TrendingUp className="h-4 w-4 text-red-500 transform rotate-180" />;
      default: return <div className="h-4 w-4 bg-gray-400 rounded-full"></div>;
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-green-600 bg-green-50';
    if (score >= 80) return 'text-blue-600 bg-blue-50';
    if (score >= 70) return 'text-yellow-600 bg-yellow-50';
    return 'text-red-600 bg-red-50';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <BarChart3 className="h-6 w-6 text-primary-600" />
            健康报告
          </h1>
          <p className="text-gray-600 mt-1">全面分析您的健康数据和进展</p>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" className="flex items-center gap-2">
            <Filter className="h-4 w-4" />
            筛选
          </Button>
          <Button onClick={exportReport} className="flex items-center gap-2">
            <Download className="h-4 w-4" />
            导出报告
          </Button>
        </div>
      </div>

      {/* 时间和指标选择 */}
      <div className="flex flex-wrap gap-4">
        <div className="flex gap-2">
          {periods.map((period) => (
            <button
              key={period.id}
              onClick={() => setSelectedPeriod(period.id)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                selectedPeriod === period.id
                  ? 'bg-primary-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {period.name}
            </button>
          ))}
        </div>
        
        <div className="flex gap-2">
          {metrics.map((metric) => (
            <button
              key={metric.id}
              onClick={() => setSelectedMetric(metric.id)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center gap-2 ${
                selectedMetric === metric.id
                  ? 'bg-primary-500 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <span>{metric.icon}</span>
              {metric.name}
            </button>
          ))}
        </div>
      </div>

      {/* 健康评分概览 */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        {Object.entries(healthScores).map(([key, score]) => (
          <Card key={key}>
            <CardContent className="p-4 text-center">
              <div className={`text-3xl font-bold mb-2 ${getScoreColor(score)}`}>
                {score}
              </div>
              <div className="text-sm text-gray-600 capitalize">
                {key === 'overall' ? '综合评分' : 
                 key === 'nutrition' ? '营养' :
                 key === 'exercise' ? '运动' :
                 key === 'sleep' ? '睡眠' : '水分'}
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 mt-2">
                <div 
                  className={`h-2 rounded-full ${score >= 90 ? 'bg-green-500' : score >= 80 ? 'bg-blue-500' : score >= 70 ? 'bg-yellow-500' : 'bg-red-500'}`}
                  style={{ width: `${score}%` }}
                ></div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* 营养摄入趋势 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Heart className="h-5 w-5" />
              营养摄入趋势
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {Object.entries(nutritionTrends).map(([key, data]) => (
                <div key={key} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="w-3 h-3 rounded-full bg-primary-500"></div>
                    <span className="font-medium capitalize">
                      {key === 'calories' ? '卡路里' : 
                       key === 'protein' ? '蛋白质' :
                       key === 'carbs' ? '碳水化合物' : '脂肪'}
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-gray-600">
                      {data.current}/{data.target}
                    </span>
                    <div className="flex items-center gap-1">
                      {getTrendIcon(data.trend)}
                      <span className={`text-sm ${data.change > 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {data.change > 0 ? '+' : ''}{data.change}%
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            
            {/* 简单的图表模拟 */}
            <div className="mt-6">
              <h4 className="text-sm font-medium text-gray-700 mb-3">本周卡路里摄入</h4>
              <div className="flex items-end justify-between h-32 bg-gray-50 rounded-lg p-4">
                {weeklyData.map((day, index) => (
                  <div key={index} className="flex flex-col items-center gap-2">
                    <div 
                      className="bg-primary-500 rounded-t w-6"
                      style={{ height: `${(day.calories / 2500) * 100}px` }}
                    ></div>
                    <span className="text-xs text-gray-600">{day.day.slice(-1)}</span>
                  </div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* 体重变化 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              体重变化趋势
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-2xl font-bold text-gray-900">69.6 kg</div>
                  <div className="text-sm text-gray-600">当前体重</div>
                </div>
                <div className="text-right">
                  <div className="text-lg font-semibold text-green-600">-0.6 kg</div>
                  <div className="text-sm text-gray-600">本周变化</div>
                </div>
              </div>

              {/* 体重趋势图 */}
              <div className="mt-6">
                <h4 className="text-sm font-medium text-gray-700 mb-3">本周体重变化</h4>
                <div className="flex items-end justify-between h-32 bg-gray-50 rounded-lg p-4">
                  {weeklyData.map((day, index) => (
                    <div key={index} className="flex flex-col items-center gap-2">
                      <div 
                        className="bg-blue-500 rounded-full w-2 h-2"
                        style={{ marginBottom: `${((day.weight - 69) / 2) * 100}px` }}
                      ></div>
                      <span className="text-xs text-gray-600">{day.day.slice(-1)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 mt-4">
                <div className="text-center p-3 bg-blue-50 rounded-lg">
                  <div className="text-lg font-bold text-blue-600">65 kg</div>
                  <div className="text-xs text-blue-700">目标体重</div>
                </div>
                <div className="text-center p-3 bg-green-50 rounded-lg">
                  <div className="text-lg font-bold text-green-600">8 周</div>
                  <div className="text-xs text-green-700">预计达成</div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* 运动数据 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="h-5 w-5" />
            运动数据分析
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="text-center p-4 bg-orange-50 rounded-lg">
              <div className="text-2xl font-bold text-orange-600">350</div>
              <div className="text-sm text-orange-700">本周总运动时间(分钟)</div>
            </div>
            <div className="text-center p-4 bg-red-50 rounded-lg">
              <div className="text-2xl font-bold text-red-600">2,450</div>
              <div className="text-sm text-red-700">本周消耗卡路里</div>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-lg">
              <div className="text-2xl font-bold text-purple-600">5</div>
              <div className="text-sm text-purple-700">运动天数</div>
            </div>
            <div className="text-center p-4 bg-green-50 rounded-lg">
              <div className="text-2xl font-bold text-green-600">70%</div>
              <div className="text-sm text-green-700">目标完成度</div>
            </div>
          </div>

          {/* 运动类型分布 */}
          <div>
            <h4 className="text-sm font-medium text-gray-700 mb-3">运动类型分布</h4>
            <div className="space-y-3">
              {[
                { type: '跑步', time: 120, color: 'bg-red-500' },
                { type: '力量训练', time: 90, color: 'bg-blue-500' },
                { type: '瑜伽', time: 80, color: 'bg-green-500' },
                { type: '游泳', time: 60, color: 'bg-purple-500' }
              ].map((exercise, index) => (
                <div key={index} className="flex items-center gap-3">
                  <div className="w-16 text-sm text-gray-600">{exercise.type}</div>
                  <div className="flex-1 bg-gray-200 rounded-full h-3">
                    <div 
                      className={`h-3 rounded-full ${exercise.color}`}
                      style={{ width: `${(exercise.time / 120) * 100}%` }}
                    ></div>
                  </div>
                  <div className="w-16 text-sm text-gray-600 text-right">{exercise.time}分钟</div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 成就和里程碑 */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Award className="h-5 w-5" />
            最近成就
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {achievements.map((achievement, index) => (
              <div key={index} className="flex items-center gap-3 p-4 bg-gray-50 rounded-lg">
                <div className="text-2xl">{achievement.icon}</div>
                <div className="flex-1">
                  <div className="font-medium text-gray-900">{achievement.title}</div>
                  <div className="text-sm text-gray-600">{achievement.date}</div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* 建议和提醒 */}
      <Card>
        <CardHeader>
          <CardTitle>个性化建议</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="p-4 bg-blue-50 rounded-lg">
              <h4 className="font-medium text-blue-900 mb-2">💧 增加水分摄入</h4>
              <p className="text-sm text-blue-700">
                您的水分摄入已达标91%，建议每天再多喝200ml水以达到最佳状态。
              </p>
            </div>
            <div className="p-4 bg-green-50 rounded-lg">
              <h4 className="font-medium text-green-900 mb-2">🥗 营养均衡良好</h4>
              <p className="text-sm text-green-700">
                您的营养摄入比例很好，继续保持当前的饮食习惯。
              </p>
            </div>
            <div className="p-4 bg-orange-50 rounded-lg">
              <h4 className="font-medium text-orange-900 mb-2">🏃 增加有氧运动</h4>
              <p className="text-sm text-orange-700">
                建议增加30分钟有氧运动，有助于提高心肺功能和减脂效果。
              </p>
            </div>
            <div className="p-4 bg-purple-50 rounded-lg">
              <h4 className="font-medium text-purple-900 mb-2">😴 改善睡眠质量</h4>
              <p className="text-sm text-purple-700">
                睡眠评分79分，建议晚上10点后避免使用电子设备，提高睡眠质量。
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default HealthReportPage;
