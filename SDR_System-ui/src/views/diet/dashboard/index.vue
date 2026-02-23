<template>
  <div class="diet-dashboard">
    <!-- ML训练状态通知 -->
    <div v-if="mlTrainingStatus.isTraining" class="ml-training-notification">
      <el-alert
        title="机器学习模型正在训练中"
        type="info"
        :closable="false"
        show-icon
      >
        <template slot>
          <div class="training-info">
            <span>进度: {{ mlTrainingStatus.progress }}%</span>
            <span class="training-models">训练模型: {{ mlTrainingStatus.currentModels.join(', ') }}</span>
          </div>
          <el-progress 
            :percentage="mlTrainingStatus.progress" 
            :show-text="false" 
            stroke-width="4"
            style="margin-top: 8px;"
          ></el-progress>
        </template>
      </el-alert>
    </div>

    <el-row :gutter="20">
      <!-- 今日概览卡片 -->
      <el-col :xs="24" :sm="24" :lg="8">
        <el-card class="today-overview">
          <div slot="header" class="card-header">
            <span>今日概览</span>
            <el-button style="float: right; padding: 3px 0" type="text" @click="refreshData">刷新</el-button>
          </div>
          <div class="overview-content">
            <div class="overview-item">
              <div class="label">目标热量</div>
              <div class="value">{{ todayData.targetCalories || 0 }} kcal</div>
            </div>
            <div class="overview-item">
              <div class="label">已摄入</div>
              <div class="value">{{ todayData.actualCalories || 0 }} kcal</div>
            </div>
            <div class="overview-item">
              <div class="label">剩余</div>
              <div class="value remaining">{{ remainingCalories }} kcal</div>
            </div>
          </div>
          <el-progress 
            :percentage="calorieProgress" 
            :color="progressColor"
            :show-text="false"
          ></el-progress>
        </el-card>
      </el-col>

      <!-- 今日营养分布 -->
      <el-col :xs="24" :sm="24" :lg="8">
        <el-card class="nutrition-pie">
          <div slot="header" class="card-header">
            <span>今日营养分布</span>
          </div>
          <div ref="nutritionPie" style="height: 300px;"></div>
        </el-card>
      </el-col>

      <!-- 快速操作 -->
      <el-col :xs="24" :sm="24" :lg="8">
        <el-card class="quick-actions">
          <div slot="header" class="card-header">
            <span>快速操作</span>
          </div>
          <div class="action-buttons">
            <el-button type="primary" icon="el-icon-camera-solid" @click="openFoodRecognition">
              拍照识别
            </el-button>
            <el-button type="success" icon="el-icon-plus" @click="addRecord">
              手动添加
            </el-button>
            <el-button type="info" icon="el-icon-magic-stick" @click="getRecommendation">
              智能推荐
            </el-button>
          </div>
          
          <!-- 管理员专用功能 -->
          <div v-if="isAdmin" class="admin-actions">
            <el-divider content-position="center">管理员功能</el-divider>
            <el-button 
              type="warning" 
              icon="el-icon-cpu" 
              size="small" 
              @click="$router.push('/diet/ml/management')"
              plain
            >ML推荐管理</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 热量趋势图 -->
      <el-col :xs="24" :sm="24" :lg="12">
        <el-card class="calorie-trend">
          <div slot="header" class="card-header">
            <span>7日热量趋势</span>
            <el-date-picker
              v-model="trendDateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              size="mini"
              @change="loadTrendData"
              style="float: right;"
            >
            </el-date-picker>
          </div>
          <div ref="calorieTrend" style="height: 400px;"></div>
        </el-card>
      </el-col>

      <!-- 今日餐次记录 -->
      <el-col :xs="24" :sm="24" :lg="12">
        <el-card class="meal-records">
          <div slot="header" class="card-header">
            <span>今日餐次</span>
          </div>
          <div class="meal-list">
            <div v-for="meal in mealRecords" :key="meal.mealType" class="meal-item">
              <div class="meal-header">
                <span class="meal-name">{{ getMealTypeName(meal.mealType) }}</span>
                <span class="meal-calories">{{ meal.totalCalories || 0 }} kcal</span>
              </div>
              <div class="meal-foods" v-if="meal.foods && meal.foods.length">
                <el-tag v-for="food in meal.foods" :key="food.foodId" size="mini">
                  {{ food.foodName }}
                </el-tag>
              </div>
              <div v-else class="no-record">
                <el-button type="text" size="mini" @click="addMealRecord(meal.mealType)">
                  + 添加{{ getMealTypeName(meal.mealType) }}记录
                </el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 食物识别对话框 -->
    <el-dialog title="拍照识别食物" :visible.sync="recognitionDialogVisible" width="500px">
      <div class="recognition-content">
        <el-upload
          class="upload-demo"
          drag
          :action="uploadAction"
          :headers="uploadHeaders"
          :before-upload="beforeUpload"
          :on-success="handleRecognitionSuccess"
          :on-error="handleRecognitionError"
          :show-file-list="false"
          accept="image/*"
        >
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">将图片拖到此处，或<em>点击上传</em></div>
          <div class="el-upload__tip" slot="tip">只能上传jpg/png文件，且不超过10MB</div>
        </el-upload>
        
        <!-- 识别结果 -->
        <div v-if="recognitionResult" class="recognition-result">
          <h4>识别结果：</h4>
          <div v-for="food in recognitionResult.recognizedFoods" :key="food.foodName" class="recognized-food">
            <span>{{ food.foodName }}</span>
            <span>置信度: {{ (food.confidence * 100).toFixed(1) }}%</span>
            <span v-if="food.estimatedWeight">重量: {{ food.estimatedWeight }}g</span>
          </div>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="recognitionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmRecognition" :disabled="!recognitionResult">确认添加</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { recognizeFood } from '@/api/diet/record'

import { 
  getTodayOverview, 
  getTodayMeals, 
  getCalorieTrend, 
  getNutritionDistribution,
  getQuickStats,
  getGoalProgress,
  generateQuickRecommendation,
  getRecentRecommendations
} from '@/api/diet/dashboard'
import { getToken } from '@/utils/auth'
import { getTrainingProgress } from '@/api/diet/ml'
import * as echarts from 'echarts'

export default {
  name: 'DietDashboard',
  data() {
    return {
      todayData: {
        targetCalories: 2000,
        actualCalories: 0,
        targetProtein: 0,
        actualProtein: 0,
        targetFat: 0,
        actualFat: 0,
        targetCarbohydrate: 0,
        actualCarbohydrate: 0
      },
      nutritionData: [],
      mealRecords: [
        { mealType: '0', totalCalories: 0, foods: [] },
        { mealType: '1', totalCalories: 0, foods: [] },
        { mealType: '2', totalCalories: 0, foods: [] },
        { mealType: '3', totalCalories: 0, foods: [] }
      ],
      trendDateRange: [],
      trendData: [],
      recognitionDialogVisible: false,
      recognitionResult: null,
      uploadAction: (process.env.VUE_APP_BASE_API || '/dev-api') + '/diet/record/recognize',
      uploadHeaders: {},
      // 管理员权限标识
      isAdmin: false,
      // ML训练状态
      mlTrainingStatus: {
        isTraining: false,
        progress: 0,
        currentModels: []
      }
    }
  },
  computed: {
    remainingCalories() {
      return Math.max(0, this.todayData.targetCalories - this.todayData.actualCalories)
    },
    calorieProgress() {
      if (this.todayData.targetCalories === 0) return 0
      return Math.min(100, (this.todayData.actualCalories / this.todayData.targetCalories) * 100)
    },
    progressColor() {
      const progress = this.calorieProgress
      if (progress < 50) return '#67C23A'
      if (progress < 80) return '#E6A23C'
      return '#F56C6C'
    }
  },
  mounted() {
    this.checkUserRole();
    this.initDateRange();
    // 设置上传请求头
    this.setUploadHeaders();
    // 初始化图表
    this.initCharts();
    // 加载数据
    this.loadTodayData();
    this.loadTrendData();
    this.loadNutritionData();
  },
  methods: {
    checkUserRole() {
      // 检查当前用户是否为管理员
      const roles = this.$store.getters.roles;
      this.isAdmin = roles.includes('admin');
    },
    
    setUploadHeaders() {
      // 设置上传请求的认证头
      const token = getToken();
      if (token) {
        this.uploadHeaders = {
          Authorization: "Bearer " + token
        };
      }
    },
    
    initDateRange() {
      const end = new Date()
      const start = new Date()
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 7)
      this.trendDateRange = [start, end]
    },
    
    async loadTodayData() {
      try {
        // 使用新的仪表盘API并行加载数据
        await Promise.all([
          this.loadTodayOverview(),
          this.loadTodayMeals(),
          this.checkMLTrainingStatus(), // 检查ML训练状态
          this.loadNutritionData()
        ]);
      } catch (error) {
        console.error('加载今日数据失败:', error)
      }
    },
    
    // 加载今日概览数据
    async loadTodayOverview() {
      try {
        const response = await getTodayOverview();
        if (response.code === 200) {
          // 更新今日数据
          this.todayData = {
            ...this.todayData,
            ...response.data
          };
        }
      } catch (error) {
        console.error('加载今日概览失败:', error);
      }
    },

    // 加载今日餐次数据
    async loadTodayMeals() {
      try {
        const response = await getTodayMeals();
        if (response.code === 200) {
          this.mealRecords = response.data;
        }
      } catch (error) {
        console.error('加载今日餐次失败:', error);
      }
    },
    
    processTodayData(records) {
      // 重置餐次记录
      this.mealRecords.forEach(meal => {
        meal.totalCalories = 0
        meal.foods = []
      })
      
      let totalCalories = 0
      let totalProtein = 0
      let totalFat = 0
      let totalCarbohydrate = 0
      
      records.forEach(record => {
        totalCalories += record.totalCalories || 0
        totalProtein += record.totalProtein || 0
        totalFat += record.totalFat || 0
        totalCarbohydrate += record.totalCarbohydrate || 0
        
        // 更新餐次记录
        const mealIndex = this.mealRecords.findIndex(m => m.mealType === record.mealType)
        if (mealIndex !== -1) {
          this.mealRecords[mealIndex].totalCalories += record.totalCalories || 0
        }
      })
      
      this.todayData.actualCalories = totalCalories
      this.todayData.actualProtein = totalProtein
      this.todayData.actualFat = totalFat
      this.todayData.actualCarbohydrate = totalCarbohydrate
      
      // 更新营养分布图表
      this.updateNutritionChart()
    },
    
    async loadTrendData() {
      try {
        let startDate = null;
        let endDate = null;
        
        if (this.trendDateRange && this.trendDateRange.length === 2) {
          startDate = this.formatDate(this.trendDateRange[0]);
          endDate = this.formatDate(this.trendDateRange[1]);
        }
        
        const response = await getCalorieTrend(startDate, endDate);
        if (response.code === 200) {
          this.trendData = response.data.trendData;
          // 更新趋势图表
          this.$nextTick(() => {
            this.updateTrendChart();
          });
        }
      } catch (error) {
        console.error('加载趋势数据失败:', error);
      }
    },
    
    // 加载营养分布数据
    async loadNutritionData() {
      try {
        const response = await getNutritionDistribution();
        if (response.code === 200) {
          this.nutritionData = response.data.nutritionData;
          // 更新营养饼图
          this.$nextTick(() => {
            this.updateNutritionChart();
          });
        }
      } catch (error) {
        console.error('加载营养分布数据失败:', error);
      }
    },
    
    initCharts() {
      this.$nextTick(() => {
        this.initNutritionChart()
        this.initTrendChart()
      })
    },
    
    initNutritionChart() {
      const chart = echarts.init(this.$refs.nutritionPie)
      this.nutritionChart = chart
      
      const option = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c}g ({d}%)'
        },
        legend: {
          orient: 'vertical',
          left: 10,
          data: ['蛋白质', '脂肪', '碳水化合物']
        },
        series: [
          {
            name: '营养分布',
            type: 'pie',
            radius: ['50%', '70%'],
            avoidLabelOverlap: false,
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '30',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            data: [
              { value: 0, name: '蛋白质' },
              { value: 0, name: '脂肪' },
              { value: 0, name: '碳水化合物' }
            ]
          }
        ]
      }
      
      chart.setOption(option)
    },
    
    updateNutritionChart() {
      if (this.nutritionChart) {
        // 如果有营养分布数据，使用API数据
        if (this.nutritionData && this.nutritionData.length > 0) {
          const option = {
            series: [{
              data: this.nutritionData.map(item => ({
                value: parseFloat(item.value) || 0,
                name: item.name,
                itemStyle: { color: item.color }
              }))
            }]
          };
          this.nutritionChart.setOption(option);
        } else {
          // 否则使用今日数据计算
          const option = {
            series: [{
              data: [
                { value: this.todayData.actualProtein || 0, name: '蛋白质', itemStyle: { color: '#67C23A' } },
                { value: this.todayData.actualFat || 0, name: '脂肪', itemStyle: { color: '#E6A23C' } },
                { value: this.todayData.actualCarbohydrate || 0, name: '碳水化合物', itemStyle: { color: '#409EFF' } }
              ]
            }]
          };
          this.nutritionChart.setOption(option);
        }
      }
    },
    
    initTrendChart() {
      const chart = echarts.init(this.$refs.calorieTrend)
      this.trendChart = chart
      
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['实际热量', '目标热量']
        },
        xAxis: {
          type: 'category',
          data: []
        },
        yAxis: {
          type: 'value',
          name: '热量 (kcal)'
        },
        series: [
          {
            name: '实际热量',
            type: 'line',
            data: []
          },
          {
            name: '目标热量',
            type: 'line',
            data: [],
            lineStyle: {
              type: 'dashed'
            }
          }
        ]
      }
      
      chart.setOption(option)
    },
    
    updateTrendChart() {
      if (this.trendChart && this.trendData) {
        const dates = this.trendData.map(item => item.date);
        const calories = this.trendData.map(item => parseFloat(item.calories) || 0);
        const protein = this.trendData.map(item => parseFloat(item.protein) || 0);
        const fat = this.trendData.map(item => parseFloat(item.fat) || 0);
        const carbohydrate = this.trendData.map(item => parseFloat(item.carbohydrate) || 0);
        
        const option = {
          xAxis: {
            data: dates
          },
          series: [
            {
              name: '实际热量',
              data: calories
            },
            {
              name: '目标热量',
              data: new Array(dates.length).fill(this.todayData.targetCalories || 2000)
            },
            {
              name: '蛋白质',
              data: protein
            },
            {
              name: '脂肪',
              data: fat
            },
            {
              name: '碳水化合物',
              data: carbohydrate
            }
          ]
        };
        
        this.trendChart.setOption(option);
      }
    },
    
    getMealTypeName(mealType) {
      const names = {
        '0': '早餐',
        '1': '午餐',
        '2': '晚餐',
        '3': '加餐'
      }
      return names[mealType] || '未知'
    },
    
    async refreshData() {
      try {
        await Promise.all([
          this.loadTodayData(),
          this.loadTrendData(),
          this.loadNutritionData()
        ]);
        this.$modal.msgSuccess('数据刷新成功');
      } catch (error) {
        console.error('刷新数据失败:', error);
        this.$modal.msgError('数据刷新失败');
      }
    },
    
    openFoodRecognition() {
      // 更新认证头确保token是最新的
      this.setUploadHeaders();
      this.recognitionDialogVisible = true;
      this.recognitionResult = null;
    },
    
    addRecord() {
      this.$router.push('/diet/record')
    },
    
    addMealRecord(mealType) {
      this.$router.push({
        path: '/diet/record',
        query: { mealType }
      })
    },
    
    async getRecommendation() {
      try {
        const response = await generateQuickRecommendation();
        if (response.code === 200) {
          this.$modal.msgSuccess('推荐生成成功！');
          // 可以在这里显示推荐内容或跳转到推荐页面
          const recommendation = response.data;
          if (recommendation.recommendedFoods) {
            this.$message({
              message: `推荐：${recommendation.recommendedFoods}`,
              type: 'success',
              duration: 5000
            });
          }
          // 可选择跳转到推荐页面查看详细信息
          // this.$router.push('/diet/recommendation')
        }
      } catch (error) {
        console.error('生成推荐失败:', error);
        this.$modal.msgError('生成推荐失败');
      }
    },
    
    // 检查ML训练状态
    async checkMLTrainingStatus() {
      try {
        const response = await getTrainingProgress();
        if (response.code === 200 && response.data) {
          const progressData = response.data;
          this.mlTrainingStatus = {
            isTraining: progressData.isTraining || false,
            progress: progressData.overallProgress || 0,
            currentModels: this.getTrainingModelNames(progressData.models || [])
          };
        }
      } catch (error) {
        console.error('检查ML训练状态失败:', error);
        // 不显示错误消息，静默失败
      }
    },
    
    getTrainingModelNames(models) {
      const modelNameMap = {
        'collaborative_filtering': '协同过滤',
        'content_based': '内容推荐', 
        'deep_learning': '深度学习'
      };
      
      return models
        .filter(model => model.status === 'training')
        .map(model => modelNameMap[model.name] || model.name);
    },
    
    beforeUpload(file) {
      const isImage = file.type.indexOf('image/') === 0
      const isLt10M = file.size / 1024 / 1024 < 10
      
      if (!isImage) {
        this.$message.error('只能上传图片文件!')
        return false
      }
      if (!isLt10M) {
        this.$message.error('图片大小不能超过 10MB!')
        return false
      }
      return true
    },
    
    handleRecognitionSuccess(response) {
      if (response.code === 200) {
        this.recognitionResult = response.data
        this.$message.success('识别成功')
      } else {
        this.$message.error(response.msg || '识别失败')
      }
    },
    
    handleRecognitionError() {
      this.$message.error('识别失败，请重试')
    },
    
    confirmRecognition() {
      if (this.recognitionResult) {
        // 跳转到添加记录页面，带上识别结果
        this.$router.push({
          path: '/diet/record',
          query: { 
            recognitionData: JSON.stringify(this.recognitionResult)
          }
        })
      }
      this.recognitionDialogVisible = false
    },
    
    formatDate(date) {
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      return `${year}-${month}-${day}`
    }
  }
}
</script>

<style scoped>
.diet-dashboard {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.today-overview .overview-content {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.overview-item {
  text-align: center;
}

.overview-item .label {
  font-size: 12px;
  color: #999;
  margin-bottom: 5px;
}

.overview-item .value {
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.overview-item .value.remaining {
  color: #67C23A;
}

.quick-actions .action-buttons {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.quick-actions .action-buttons .el-button {
  width: 100%;
}

.meal-list {
  max-height: 400px;
  overflow-y: auto;
}

.meal-item {
  padding: 15px 0;
  border-bottom: 1px solid #eee;
}

.meal-item:last-child {
  border-bottom: none;
}

.meal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.meal-name {
  font-weight: bold;
  font-size: 16px;
}

.meal-calories {
  color: #E6A23C;
  font-weight: bold;
}

.meal-foods .el-tag {
  margin-right: 5px;
  margin-bottom: 5px;
}

.no-record {
  color: #999;
  font-size: 14px;
}

.recognition-content {
  text-align: center;
}

.recognition-result {
  margin-top: 20px;
  text-align: left;
}

.recognized-food {
  padding: 10px;
  border: 1px solid #eee;
  border-radius: 4px;
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
}

@media (max-width: 768px) {
  .today-overview .overview-content {
    flex-direction: column;
    gap: 10px;
  }
  
  .quick-actions .action-buttons {
    flex-direction: row;
  }
  
  .quick-actions .action-buttons .el-button {
    width: auto;
    flex: 1;
  }
}

.admin-actions {
  margin-top: 15px;
  text-align: center;
}

.admin-actions .el-button {
  margin: 5px;
  width: calc(50% - 10px);
}

/* ML训练状态通知样式 */
.ml-training-notification {
  margin-bottom: 20px;
}

.training-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.training-models {
  color: #666;
  font-size: 12px;
}

.admin-actions .el-divider {
  margin: 15px 0 10px 0;
}
</style>
