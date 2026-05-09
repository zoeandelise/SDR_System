import React, { useState, useEffect } from 'react';
import ReactECharts from 'echarts-for-react';
import { BarChart3, TrendingUp, Heart, AlertCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/Card';
import api from '../services/api';

const HealthReportPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [radarData, setRadarData] = useState<any>(null);
  const [nutritionData, setNutritionData] = useState<any>(null);
  const [trendsData, setTrendsData] = useState<any>(null);
  const [weightTrend, setWeightTrend] = useState<any>(null);

  useEffect(() => {
    loadReportData();
  }, []);

  const loadReportData = async () => {
    setLoading(true);
    setError('');
    try {
      const [radarRes, nutritionRes, trendsRes, weightRes]: any[] = await Promise.all([
        api.get('/api/user/diet/report/weekly-radar').catch(() => null),
        api.get('/api/user/diet/analysis/nutrition', {
          params: { startDate: getDateStr(7), endDate: getDateStr(0) }
        }).catch(() => null),
        api.get('/api/user/diet/analysis/trends', {
          params: { days: 7 }
        }).catch(() => null),
        api.get('/api/user/diet/weight/trend').catch(() => null),
      ]);

      if (radarRes?.code === 200 && radarRes.data) setRadarData(radarRes.data);
      if (nutritionRes?.code === 200 && nutritionRes.data) setNutritionData(nutritionRes.data);
      if (trendsRes?.code === 200 && trendsRes.data) setTrendsData(trendsRes.data);
      if (weightRes?.code === 200 && weightRes.data) setWeightTrend(weightRes.data);
    } catch (err: any) {
      console.error('加载报告数据失败:', err);
      setError('加载报告数据失败，请稍后重试');
    } finally {
      setLoading(false);
    }
  };

  const getDateStr = (daysAgo: number) => {
    const d = new Date();
    d.setDate(d.getDate() - daysAgo);
    return d.toISOString().slice(0, 10);
  };

  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-green-700 bg-green-100';
    if (score >= 80) return 'text-blue-700 bg-blue-100';
    if (score >= 70) return 'text-yellow-700 bg-yellow-100';
    return 'text-red-700 bg-red-100';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-10 h-10 border-2 border-emerald-200 border-t-emerald-600 rounded-full animate-spin mx-auto" />
          <p className="mt-4 text-sm text-gray-700">加载报告中...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <BarChart3 className="h-7 w-7 text-primary-600" />
          健康报告
        </h1>
        <p className="text-gray-700 mt-1">基于您的真实饮食数据生成</p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex items-center gap-2">
          <AlertCircle className="w-5 h-5 text-red-500" />
          <span className="text-sm text-red-800">{error}</span>
        </div>
      )}

      {/* 智能分析雷达图 */}
      <Card>
        <CardHeader>
          <CardTitle>多维健康雷达评估</CardTitle>
        </CardHeader>
        <CardContent>
          {radarData ? (
            <ReactECharts
              option={{
                tooltip: {},
                radar: {
                  indicator: [
                    { name: '碳水结构', max: 100 },
                    { name: '脂肪控量', max: 100 },
                    { name: '蛋白达标', max: 100 },
                    { name: '维生素摄入', max: 100 },
                    { name: '水分代谢', max: 100 },
                    { name: '饮食规律', max: 100 }
                  ],
                  center: ['50%', '50%'],
                  radius: '75%',
                  axisName: { color: '#374151', fontWeight: 'bold', fontSize: 13 },
                  splitArea: { areaStyle: { color: ['#f8fafc', '#f1f5f9', '#e2e8f0', '#cbd5e1'] } }
                },
                series: [{
                  name: '健康雷达分析',
                  type: 'radar',
                  data: [{
                    value: [
                      radarData.carbScore || 0, radarData.fatScore || 0, radarData.proScore || 0,
                      radarData.vitaminScore || 0, radarData.waterScore || 0, radarData.regularityScore || 0
                    ],
                    name: '本周指标',
                    areaStyle: { color: 'rgba(16, 185, 129, 0.3)' },
                    lineStyle: { width: 3, color: '#10b981' },
                    itemStyle: { color: '#10b981' }
                  }]
                }]
              }}
              style={{ height: '350px', width: '100%' }}
            />
          ) : (
            <div className="text-center py-12 text-gray-600">
              <p className="text-base">暂无雷达评估数据</p>
              <p className="text-sm text-gray-500 mt-1">需要积累更多饮食记录后生成</p>
            </div>
          )}

          {radarData && (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3 mt-6">
              {[
                { label: '碳水结构', score: radarData.carbScore },
                { label: '脂肪控量', score: radarData.fatScore },
                { label: '蛋白达标', score: radarData.proScore },
                { label: '维生素摄入', score: radarData.vitaminScore },
                { label: '水分代谢', score: radarData.waterScore },
                { label: '饮食规律', score: radarData.regularityScore },
              ].map((item) => (
                <div key={item.label} className={`text-center p-3 rounded-lg ${getScoreColor(item.score || 0)}`}>
                  <div className="text-2xl font-bold">{item.score || 0}</div>
                  <div className="text-xs font-semibold mt-1">{item.label}</div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* 营养摄入统计 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Heart className="h-5 w-5" />
              近7日营养摄入
            </CardTitle>
          </CardHeader>
          <CardContent>
            {nutritionData ? (
              <div className="space-y-4">
                {[
                  { label: '总热量', value: nutritionData.totalCalories, unit: 'kcal', color: 'bg-orange-500' },
                  { label: '蛋白质', value: nutritionData.totalProtein, unit: 'g', color: 'bg-blue-500' },
                  { label: '碳水化合物', value: nutritionData.totalCarbohydrate, unit: 'g', color: 'bg-amber-500' },
                  { label: '脂肪', value: nutritionData.totalFat, unit: 'g', color: 'bg-purple-500' },
                ].map((item) => (
                  <div key={item.label} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center gap-3">
                      <div className={`w-3 h-3 rounded-full ${item.color}`}></div>
                      <span className="font-medium text-gray-800">{item.label}</span>
                    </div>
                    <span className="text-sm font-semibold text-gray-900">
                      {Math.round(item.value || 0)} {item.unit}
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-8 text-gray-600">
                <p className="text-sm">暂无营养统计数据</p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* 体重变化趋势 */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              体重变化趋势
            </CardTitle>
          </CardHeader>
          <CardContent>
            {weightTrend ? (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-2xl font-bold text-gray-900">
                      {weightTrend.currentWeight || weightTrend.latestWeight || '--'} kg
                    </div>
                    <div className="text-sm text-gray-700">当前体重</div>
                  </div>
                  {weightTrend.change !== undefined && (
                    <div className="text-right">
                      <div className={`text-lg font-semibold ${weightTrend.change < 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {weightTrend.change > 0 ? '+' : ''}{weightTrend.change} kg
                      </div>
                      <div className="text-sm text-gray-700">近期变化</div>
                    </div>
                  )}
                </div>
                {weightTrend.targetWeight && (
                  <div className="text-center p-3 bg-blue-50 rounded-lg">
                    <div className="text-lg font-bold text-blue-700">{weightTrend.targetWeight} kg</div>
                    <div className="text-sm text-blue-800">目标体重</div>
                  </div>
                )}
              </div>
            ) : (
              <div className="text-center py-8 text-gray-600">
                <p className="text-sm">暂无体重数据</p>
                <p className="text-xs text-gray-500 mt-1">请在健康目标页面记录体重</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* 健康趋势数据 */}
      <Card>
        <CardHeader>
          <CardTitle>健康趋势分析</CardTitle>
        </CardHeader>
        <CardContent>
          {trendsData ? (
            <div className="space-y-4">
              {trendsData.dailyTrends && Array.isArray(trendsData.dailyTrends) ? (
                <ReactECharts
                  option={{
                    tooltip: { trigger: 'axis' },
                    legend: { data: ['热量', '蛋白质', '碳水', '脂肪'], bottom: 0 },
                    grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
                    xAxis: {
                      type: 'category',
                      data: trendsData.dailyTrends.map((d: any) => d.date || d.day || ''),
                    },
                    yAxis: { type: 'value' },
                    series: [
                      { name: '热量', type: 'line', data: trendsData.dailyTrends.map((d: any) => d.calories || d.totalCalories || 0), smooth: true, itemStyle: { color: '#f97316' } },
                      { name: '蛋白质', type: 'line', data: trendsData.dailyTrends.map((d: any) => d.protein || d.totalProtein || 0), smooth: true, itemStyle: { color: '#3b82f6' } },
                      { name: '碳水', type: 'line', data: trendsData.dailyTrends.map((d: any) => d.carbohydrate || d.totalCarbohydrate || 0), smooth: true, itemStyle: { color: '#f59e0b' } },
                      { name: '脂肪', type: 'line', data: trendsData.dailyTrends.map((d: any) => d.fat || d.totalFat || 0), smooth: true, itemStyle: { color: '#a855f7' } },
                    ]
                  }}
                  style={{ height: '300px', width: '100%' }}
                />
              ) : (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  {Object.entries(trendsData).slice(0, 8).map(([key, value]) => (
                    <div key={key} className="p-3 bg-gray-50 rounded-lg text-center">
                      <div className="text-lg font-bold text-gray-900">{String(value)}</div>
                      <div className="text-xs text-gray-600 mt-1">{key}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : (
            <div className="text-center py-8 text-gray-600">
              <p className="text-sm">暂无趋势数据</p>
              <p className="text-xs text-gray-500 mt-1">持续记录饮食后将生成趋势分析</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default HealthReportPage;
