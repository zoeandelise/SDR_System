<template>
  <div class="app-container ml-management">
    <el-card class="box-card">
      <div slot="header" class="card-header">
        <span class="title">
          <i class="el-icon-cpu"></i> 协同过滤推荐系统管理 v2.0
        </span>
        <div class="header-buttons">
          <el-button size="small" @click="refreshStatus" :loading="loading">
            <i class="el-icon-refresh"></i> 刷新状态
          </el-button>
          <el-button size="small" type="primary" @click="openTrainingDialog" :disabled="isTraining">
            <i class="el-icon-cpu"></i> 训练模型
          </el-button>
        </div>
      </div>

      <!-- 服务状态概览 -->
      <el-row :gutter="20" class="status-overview">
        <el-col :span="6">
          <div class="status-card" :class="serviceStatusClass">
            <i :class="serviceStatusIcon" class="watermark-icon"></i>
            <div class="status-icon-wrapper">
              <i :class="serviceStatusIcon"></i>
            </div>
            <div class="status-info">
              <div class="status-title">服务运行状态</div>
              <div class="status-value number-font">{{ getServiceStatusText(serviceStatus.serviceStatus) }}</div>
              <div class="status-time">最新刷新时间: {{ formatLastCheckTime(serviceStatus.lastCheckTime) }}</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card models-card">
            <i class="el-icon-cpu watermark-icon"></i>
            <div class="status-icon-wrapper">
              <i class="el-icon-cpu"></i>
            </div>
            <div class="status-info">
              <div class="status-title">模型装载量</div>
              <div class="status-value number-font">{{ loadedModelsCount }}<span class="unit">/2</span></div>
              <el-progress 
                :percentage="Math.round((loadedModelsCount / 2) * 100)"
                :stroke-width="8"
                :show-text="false"
                status="success"
              ></el-progress>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card analytics-card">
            <i class="el-icon-data-analysis watermark-icon"></i>
            <div class="status-icon-wrapper">
              <i class="el-icon-data-analysis"></i>
            </div>
            <div class="status-info">
              <div class="status-title">推荐采纳率</div>
              <div class="status-value number-font">{{ formatPercentage(analyticsData.acceptanceRate) }}<span class="unit">%</span></div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card performance-card">
            <i class="el-icon-timer watermark-icon"></i>
            <div class="status-icon-wrapper">
              <i class="el-icon-timer"></i>
            </div>
            <div class="status-info">
              <div class="status-title">平均响应时间</div>
              <div class="status-value number-font">{{ analyticsData.avgResponseTime || 0 }}<span class="unit">ms</span></div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 详细信息标签页 -->
      <el-tabs v-model="activeTab" class="ml-tabs">
        <!-- 模型管理 -->
        <el-tab-pane label="模型管理" name="models">
          <div class="models-section">
            <div class="section-header">
              <h3>推荐模型</h3>
              <el-button type="primary" size="small" @click="openTrainingDialog" :disabled="isTraining">
                <i class="el-icon-cpu"></i> 训练模型
                </el-button>
            </div>
            
            <el-row :gutter="20" class="model-cards">
              <el-col :span="8" v-for="model in modelsList" :key="model.type">
                <el-card class="model-card" :class="{ 'model-loaded': model.loaded }">
                  <div class="model-header">
                    <i :class="model.icon" class="model-icon"></i>
                    <div class="model-title">{{ model.name }}</div>
                    </div>
                  <div class="model-body">
                    <el-tag :type="model.loaded ? 'success' : 'info'" size="small">
                      {{ model.loaded ? '已加载' : '未加载' }}
                    </el-tag>
                    <div class="model-desc">{{ model.description }}</div>
                    <div class="model-meta" v-if="model.lastTrained">
                      <span>最后训练: {{ model.lastTrained }}</span>
                      </div>
                    </div>
                  <div class="model-actions">
                    <el-button size="mini" @click="trainSingleModel(model.type)" :disabled="isTraining">
                      训练
                    </el-button>
                  </div>
                </el-card>
              </el-col>
            </el-row>
                    </div>
        </el-tab-pane>

        <!-- 推荐分析 -->
        <el-tab-pane label="推荐分析" name="analytics">
          <div class="analytics-section">
            <el-row :gutter="20" style="margin-bottom: 20px;">
              <el-col :span="24">
                <el-card>
                  <div slot="header">整体业务转化漏斗</div>
                  <el-descriptions :column="4" border>
                    <el-descriptions-item label="总推荐发牌数">{{ analyticsData.totalRecommendations || 0 }}</el-descriptions-item>
                    <el-descriptions-item label="终端采纳数">{{ analyticsData.acceptedRecommendations || 0 }}</el-descriptions-item>
                    <el-descriptions-item label="平均大盘置信度">{{ formatScore(analyticsData.avgScore) }}</el-descriptions-item>
                    <el-descriptions-item label="单次预估耗时">{{ analyticsData.avgResponseTime || 0 }}ms</el-descriptions-item>
                  </el-descriptions>
                </el-card>
              </el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-card>
                  <div slot="header">算法下发采纳率分布 (Pie)</div>
                  <div ref="pieChart" style="height: 300px;"></div>
                </el-card>
              </el-col>
              <el-col :span="12">
                <el-card>
                  <div slot="header">各引擎链路转化率对比 (Bar)</div>
                  <div ref="barChart" style="height: 300px;"></div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- 推荐测试 -->
        <el-tab-pane label="模拟推荐体验" name="test">
          <div class="test-section">
            <el-row :gutter="20">
              <!-- 左侧发起参数 -->
              <el-col :span="8">
                <el-card class="debug-panel request-panel">
                  <div slot="header"><i class="el-icon-position"></i> 发起推荐体验</div>
                  <el-form :model="testForm" label-width="80px" label-position="top">
                    <el-form-item label="探测用户 ID / 模拟 ID">
                      <el-input v-model="testForm.userId" placeholder="输入整数 ID..."></el-input>
                    </el-form-item>
                    <el-form-item label="进食场景枚举">
                      <el-select v-model="testForm.mealType" style="width:100%">
                        <el-option label="早餐 (Morning)" value="1"></el-option>
                        <el-option label="午餐 (Noon)" value="2"></el-option>
                        <el-option label="晚餐 (Evening)" value="3"></el-option>
                        <el-option label="加餐 (Snack)" value="4"></el-option>
                      </el-select>
                    </el-form-item>
                    
                    <!-- Phase 14 新增：多模态混合特征注入 -->
                    <el-form-item label="强干预：健康近期目标">
                      <el-select v-model="testForm.target" style="width:100%" clearable placeholder="无特殊目标 (保持)">
                        <el-option label="🔥 减脂 (控制热量阈值)" value="fat_loss"></el-option>
                        <el-option label="💪 增肌 (侧重高优蛋白)" value="muscle_gain"></el-option>
                        <el-option label="⚖️ 保持 (均衡稳定饮食)" value="maintenance"></el-option>
                      </el-select>
                    </el-form-item>
                    <el-form-item label="强干预：过敏源记录">
                      <el-input v-model="testForm.allergies" placeholder="逗号分隔，如：海鲜,过敏..."></el-input>
                    </el-form-item>
                    <el-form-item label="强干预：疾病警戒史">
                      <el-input v-model="testForm.disease" placeholder="如：高血压,高尿酸..."></el-input>
                    </el-form-item>
                    <el-form-item label="沙盒衰减：每顿估计食量">
                      <el-select v-model="testForm.appetite" style="width:100%">
                        <el-option label="🍃 小食量 (标准分量 70%)" value="small"></el-option>
                        <el-option label="🍽️ 正常食量 (标准分量 100%)" value="normal"></el-option>
                        <el-option label="🍖 大食量 (标准分量 130%)" value="large"></el-option>
                      </el-select>
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" @click="testRecommendation" :loading="testLoading" style="width:100%">
                        <i class="el-icon-caret-right"></i> 执行 API 探针
                      </el-button>
                    </el-form-item>
                  </el-form>
                </el-card>
              </el-col>
              <!-- 右侧炫酷沉浸式卡片回显 (Phase 22 极客+现代 UI) -->
              <el-col :span="16">
                <el-card class="debug-panel response-panel immersive-panel" :class="{ 'has-data': testResult }">
                  <div slot="header" style="display: flex; align-items: center; justify-content: space-between;">
                    <div><i class="el-icon-magic-stick"></i> 智能推荐沙盘展示</div>
                    <el-tag v-if="testResult" size="small" type="success" effect="dark" style="border-radius: 12px; box-shadow: 0 2px 8px rgba(103,194,58,0.3);">
                      {{ testResult.recommendations ? testResult.recommendations.length : 0 }} 款臻选搭配
                    </el-tag>
                  </div>
                  <div class="recommendation-showcase">
                    <div v-if="testResult && testResult.recommendations && testResult.recommendations.length > 0" class="food-cards-container">
                      <div v-for="(item, index) in testResult.recommendations" :key="index" class="food-magic-card" :style="{ animationDelay: `${index * 0.08}s` }">
                        <div class="card-glass-bg"></div>
                        <div class="card-content-wrapper">
                          <div class="food-header">
                            <h4 class="food-title">{{ item.foodName }}</h4>
                            <div class="food-weight-badge">{{ item.weight || '100g' }}</div>
                          </div>
                          
                          <div class="macros-grid">
                            <div class="macro-item cal">
                              <span class="m-val">{{ String(item.calorie || '0').replace(' kcal', '') }}</span>
                              <span class="m-unit">kcal</span>
                            </div>
                            <div class="macro-item prot">
                              <span class="m-val">{{ String(item.protein || '0').replace('g', '') }}</span>
                              <span class="m-unit">g 蛋白</span>
                            </div>
                            <div class="macro-item carb">
                              <span class="m-val">{{ String(item.carbs || '0').replace('g', '') }}</span>
                              <span class="m-unit">g 碳水</span>
                            </div>
                            <div class="macro-item fat">
                              <span class="m-val">{{ String(item.fat || '0').replace('g', '') }}</span>
                              <span class="m-unit">g 脂肪</span>
                            </div>
                          </div>
                          
                          <div class="score-section">
                            <div class="score-label">
                              <span>算法置信度</span>
                              <span class="score-number">{{ formatAccuracy(item.score || 0) }}%</span>
                            </div>
                            <el-progress :percentage="Math.min((item.score || 0) * 100, 100)" :show-text="false" :color="getScoreColor(item.score || 0)" :stroke-width="6"></el-progress>
                          </div>
                          
                          <div class="reason-tooltip">
                            <i class="el-icon-data-analysis"></i> {{ item.reason || '多模态混合推荐引擎综合判定' }}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="terminal-empty showcase-empty" v-else>
                      <div class="empty-animation">
                        <div class="pulse-ring"></div>
                        <i class="el-icon-s-promotion"></i>
                      </div>
                      <p>等待运行探针以解算膳食多模态...</p>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
            
            <el-row style="margin-top: 20px;">
              <el-col :span="24">
                <el-card class="debug-panel graph-panel">
                  <div slot="header">
                    <i class="el-icon-share"></i> 推荐来源：用户群体相似度关系网
                    <el-button 
                      style="float: right; padding: 3px 0; color: #409EFF" 
                      type="text" 
                      icon="el-icon-refresh" 
                      @click="testRecommendation" 
                      :disabled="!testForm.userId || testLoading">
                      重构拓扑图
                    </el-button>
                  </div>
                  <div class="graph-window" v-loading="graphLoading">
                    <div v-show="!graphData" class="terminal-empty" style="text-align: center; line-height: 400px; color: #909399;">
                      输入任意数字 ID 发起测试，此终端将为您解算当前判定链路内的相似邻居群体与关联网络
                    </div>
                    <div v-show="graphData" ref="cfGraph" style="width: 100%; height: 500px"></div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 模型训练对话框（重构版 - 仅真实训练）-->
    <el-dialog
      title="🤖 训练协同过滤模型"
      :visible.sync="trainingDialogVisible"
      width="800px"
      :close-on-click-modal="false"
      :show-close="!isTraining"
    >
      <!-- 训练配置 -->
      <div v-if="!isTraining" class="training-config">
        <el-alert
          title="真实训练模式"
          type="info"
          description="将连接到ML服务进行真实模型训练。训练时间约2-5分钟，请确保ML服务已启动。"
          :closable="false"
          show-icon
          style="margin-bottom: 20px;">
        </el-alert>
        
        <div class="config-section">
          <h4>选择训练模型</h4>
          <p class="model-desc">系统采用协同过滤算法与营养学约束规则相结合的混合推荐模型</p>
          <el-checkbox-group v-model="selectedModels" class="model-selection">
            <el-checkbox label="collaborative_filtering" border>
              <i class="el-icon-s-data"></i> 协同过滤模型
              <span class="model-tag">核心算法</span>
            </el-checkbox>
            <el-checkbox label="content_based" border>
              <i class="el-icon-document"></i> 内容推荐模型
              <span class="model-tag">基于营养特征</span>
            </el-checkbox>
          </el-checkbox-group>
        </div>
        
        <div class="config-section">
          <h4>训练数据范围</h4>
          <el-slider
            v-model="dataDays"
            :min="30"
            :max="365"
            :step="30"
            :marks="{ 30: '30天', 90: '90天', 180: '180天', 365: '365天' }"
            show-stops>
          </el-slider>
          <div class="slider-value">使用最近 <b>{{ dataDays }}</b> 天的数据进行训练</div>
        </div>
        </div>
        
      <!-- 训练进度 -->
      <div v-if="isTraining" class="training-progress-container">
        <div class="training-header">
          <h3>训练进行中...</h3>
          <el-tag type="success" v-if="allModelsCompleted">
            <i class="el-icon-check"></i> 训练完成
          </el-tag>
          <el-tag type="warning" v-else>
            <i class="el-icon-loading"></i> 训练中
          </el-tag>
      </div>

        <!-- 每个模型的训练进度 -->
        <div class="models-progress">
          <div 
            v-for="model in trainingModels" 
            :key="model.modelType" 
            class="model-progress-item"
            :class="{ 'completed': model.progress >= 100 }">
            <div class="model-progress-header">
              <span class="model-name">
                <i class="el-icon-cpu"></i> {{ getModelDisplayName(model.modelType) }}
              </span>
              <el-tag :type="getStatusType(model.status)" size="small">
                {{ getStatusText(model.status) }}
            </el-tag>
          </div>
          
          <el-progress 
              :percentage="model.progress" 
              :status="model.progress >= 100 ? 'success' : undefined"
              :stroke-width="20">
              <span class="progress-text">{{ model.progress }}%</span>
          </el-progress>
          
            <div class="model-progress-step">
              <i class="el-icon-info"></i> {{ model.currentStep || '等待中...' }}
            </div>
            
            <div class="model-progress-meta" v-if="model.accuracy">
              <span>准确率: <b>{{ formatAccuracy(model.accuracy) }}%</b></span>
            </div>
          </div>
        </div>

        <!-- 总体进度 -->
        <div class="overall-progress">
          <h4>总体进度</h4>
          <el-progress 
            :percentage="overallProgress" 
            :status="allModelsCompleted ? 'success' : undefined"
            :stroke-width="30"
            :color="progressColor">
          </el-progress>
          <div class="progress-stats">
            <span>已完成: {{ completedModelsCount }}/{{ trainingModels.length }}</span>
            <span>总用时: {{ elapsedTime }}秒</span>
          </div>
        </div>
      </div>

      <div slot="footer" class="dialog-footer">
        <el-button @click="trainingDialogVisible = false" v-if="!isTraining">取消</el-button>
        <el-button 
          type="primary" 
          @click="startTraining" 
          :disabled="selectedModels.length === 0 || isTraining"
          :loading="trainingLoading"
          v-if="!isTraining">
          <i class="el-icon-cpu"></i> 开始训练
        </el-button>
        <el-button 
          type="danger" 
          @click="handleStopTraining" 
          v-if="isTraining && !allModelsCompleted">
          <i class="el-icon-close"></i> 停止训练
        </el-button>
        <el-button 
          type="success"
          @click="handleCloseAfterComplete" 
          v-if="isTraining && allModelsCompleted">
          <i class="el-icon-check"></i> 完成并关闭
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getMLStatus, refreshMLStatus, trainMLModels, getMLAnalytics, testMLRecommendation, getTrainingProgress, stopTraining, getCollaborativeGraph } from "@/api/diet/ml"
import * as echarts from 'echarts'

export default {
  name: "MLManagement",
  data() {
    return {
      loading: false,
      activeTab: 'models',
      
      // 测试相关扩建 (Phase 13 & 相位14 多模态拦截参数)
      testForm: { 
        userId: '', 
        mealType: '1',
        target: '',
        allergies: '',
        disease: '',
        appetite: 'normal'
      },
      testLoading: false,
      testResult: null,
      
      // 相位13: CF图谱拓展
      graphData: null,
      graphLoading: false,
      graphChartInstance: null,
      
      // 训练相关（仅协同过滤和内容推荐，符合开题报告）
      selectedModels: ['collaborative_filtering', 'content_based'],
      dataDays: 180,
      isTraining: false,
      trainingModels: [],
      pollingTimer: null,
      elapsedTime: 0,
      
      // 服务状态
      serviceStatus: {
        serviceStatus: 'unknown',
        components: {},
        modelsLoaded: {},
        lastCheckTime: null
      },
      
      // 分析数据
      analyticsData: {
        totalRecommendations: 0,
        acceptedRecommendations: 0,
        acceptanceRate: 0,
        avgScore: 0,
        activeUsers: 0,
        avgResponseTime: 0
      },
      
      // 模型训练
      trainingDialogVisible: false,
      trainingLoading: false,
      

      
      // 定时刷新
      refreshTimer: null,
      
      // 图表实例
      pieChartInstance: null,
      barChartInstance: null
    }
  },
  
  watch: {
    activeTab(newTab) {
      if (newTab === 'analytics') {
        this.$nextTick(() => {
          this.initCharts()
        })
      }
    }
  },
  
  computed: {
    serviceStatusClass() {
      const status = this.serviceStatus.serviceStatus
      return {
        'status-healthy': status === 'healthy',
        'status-degraded': status === 'degraded',
        'status-offline': status === 'offline'
      }
    },
    
    serviceStatusIcon() {
      const status = this.serviceStatus.serviceStatus
      return {
        'el-icon-success': status === 'healthy',
        'el-icon-warning': status === 'degraded',
        'el-icon-error': status === 'offline'
      }
    },
    
    loadedModelsCount() {
      if (!this.serviceStatus.modelsLoaded) return 0
      
      let count = 0
      if (this.serviceStatus.modelsLoaded['collaborative_filtering']) count++
      if (this.serviceStatus.modelsLoaded['content_based']) count++
      
      return count
    },
    
    modelsList() {
      return [
        {
          type: 'collaborative_filtering',
          name: '协同过滤模型',
          icon: 'el-icon-s-data',
          description: '发现饮食偏好相似的其他用户，为您打捞同阶层热门营养组合',
          loaded: this.serviceStatus.modelsLoaded?.collaborative_filtering || false,
          lastTrained: this.serviceStatus.models?.collaborative_filtering?.last_trained || null
        },
        {
          type: 'content_based',
          name: '内容推荐模型',
          icon: 'el-icon-document',
          description: '深度分析您近期的食谱成分结构，为您智能填平每日微量元素缺口',
          loaded: this.serviceStatus.modelsLoaded?.content_based || false,
          lastTrained: this.serviceStatus.models?.content_based?.last_trained || null
        }
      ]
    },
    
    algorithmPerformanceList() {
      return this.analyticsData.algorithmPerformance || []
    },
    
    overallProgress() {
      if (this.trainingModels.length === 0) return 0
      const total = this.trainingModels.reduce((sum, m) => sum + (m.progress || 0), 0)
      return Math.round(total / this.trainingModels.length)
    },
    
    completedModelsCount() {
      return this.trainingModels.filter(m => m.progress >= 100).length
    },
    
    allModelsCompleted() {
      return this.trainingModels.length > 0 && 
             this.trainingModels.every(m => m.progress >= 100)
    },
    
    progressColor() {
      const progress = this.overallProgress
      if (progress < 30) return '#909399'
      if (progress < 70) return '#E6A23C'
      if (progress < 100) return '#409EFF'
      return '#67C23A'
    }
  },
  
  mounted() {
    this.loadServiceStatus()
    this.loadAnalytics()
    this.startAutoRefresh()
    window.addEventListener('resize', this.resizeCharts)
  },
  
  beforeDestroy() {
    this.stopPolling()
    this.stopAutoRefresh()
    window.removeEventListener('resize', this.resizeCharts)
    if (this.pieChartInstance) this.pieChartInstance.dispose()
    if (this.barChartInstance) this.barChartInstance.dispose()
    if (this.graphChartInstance) this.graphChartInstance.dispose()
  },
  
  methods: {
    // 加载服务状态
    async loadServiceStatus() {
      try {
        const response = await getMLStatus()
        if (response.code === 200) {
          this.serviceStatus = response.data
        }
      } catch (error) {
        console.error('加载服务状态失败:', error)
      }
    },
    
    // 刷新状态
    async refreshStatus() {
      this.loading = true
      try {
        await refreshMLStatus()
        await this.loadServiceStatus()
        await this.loadAnalytics()
        this.$message.success('状态已刷新')
      } catch (error) {
        this.$message.error('刷新失败: ' + error.message)
      } finally {
        this.loading = false
      }
    },
    
    // 加载分析数据
    async loadAnalytics() {
      try {
        const response = await getMLAnalytics()
        if (response.code === 200) {
          this.analyticsData = response.data
          this.$nextTick(() => {
            if (this.activeTab === 'analytics') {
              this.initCharts()
            }
          })
        }
      } catch (error) {
        console.error('加载分析数据失败:', error)
      }
    },
    
    // 初始化或更新图表
    initCharts() {
      if (this.activeTab !== 'analytics') return

      const algos = this.analyticsData.algorithmPerformance || []

      // 1. 饼图
      if (this.$refs.pieChart) {
        if (!this.pieChartInstance) this.pieChartInstance = echarts.init(this.$refs.pieChart)
        const pieData = algos.map(a => ({
          name: a.algorithmType,
          value: a.totalRecommendations || 0
        }))
        this.pieChartInstance.setOption({
          tooltip: { trigger: 'item', formatter: '{b}: {c}次 ({d}%)' },
          legend: { orient: 'vertical', left: 'left' },
          color: ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C'],
          series: [{
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
            label: { show: false },
            data: pieData.length ? pieData : [{name:'基础权重配餐', value:100}]
          }]
        })
      }

      // 2. 柱状图 
      if (this.$refs.barChart) {
        if (!this.barChartInstance) this.barChartInstance = echarts.init(this.$refs.barChart)
        const barX = algos.length ? algos.map(a => a.algorithmType) : ['基础引擎'];
        const barY = algos.length ? algos.map(a => parseFloat((a.acceptanceRate * 100).toFixed(1)) || 0) : [0.0];
        this.barChartInstance.setOption({
          tooltip: { trigger: 'axis', formatter: '{b}: {c}%' },
          grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
          xAxis: { type: 'category', data: barX, axisLabel: { rotate: 30 } },
          yAxis: { type: 'value', name: '采纳率(%)' },
          series: [{
            data: barY,
            type: 'bar',
            barWidth: '40%',
            itemStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: '#83bff6' },
                { offset: 1, color: '#188df0' }
              ])
            }
          }]
        })
      }
    },
    
    // 初始化力导向 CF 图谱
    initGraphChart() {
      if (!this.$refs.cfGraph || !this.graphData) return
      if (!this.graphChartInstance) this.graphChartInstance = echarts.init(this.$refs.cfGraph)
      
      this.graphChartInstance.setOption({
        tooltip: { trigger: 'item', formatter: '{b}' },
        legend: { data: this.graphData.categories.map(a => a.name) },
        animationDurationUpdate: 1500,
        animationEasingUpdate: 'quinticInOut',
        series: [{
          type: 'graph',
          layout: 'force',
          data: this.graphData.nodes,
          edges: this.graphData.links,
          categories: this.graphData.categories,
          roam: true,
          label: { show: true, position: 'right', formatter: '{b}' },
          edgeSymbol: ['circle', 'arrow'],
          edgeSymbolSize: [4, 10],
          edgeLabel: { fontSize: 12 },
          force: { repulsion: 800, edgeLength: 150 },
          lineStyle: {
            color: 'source',
            curveness: 0.3,
            opacity: 0.7,
            width: 2
          },
          emphasis: {
            focus: 'adjacency',
            lineStyle: { width: 4 }
          }
        }]
      })
    },
    
    resizeCharts() {
      if (this.pieChartInstance) this.pieChartInstance.resize()
      if (this.barChartInstance) this.barChartInstance.resize()
      if (this.graphChartInstance) this.graphChartInstance.resize()
    },
    
    // 打开训练对话框
    openTrainingDialog() {
      if (this.serviceStatus.serviceStatus !== 'healthy') {
        this.$confirm('ML服务当前不可用，是否继续尝试训练？', '提示', {
          type: 'warning'
        }).then(() => {
          this.trainingDialogVisible = true
        }).catch(() => {})
      } else {
        this.trainingDialogVisible = true
      }
    },
    
    // 开始训练
    async startTraining() {
      if (this.selectedModels.length === 0) {
        this.$message.warning('请至少选择一个模型')
        return
      }
      
      this.trainingLoading = true
      
      try {
        // 初始化训练模型状态
      this.trainingModels = this.selectedModels.map(type => ({
          modelType: type,
        progress: 0,
        status: 'pending',
          currentStep: '准备训练...',
          accuracy: null
        }))
        
        // 调用训练API
        const response = await trainMLModels({
          modelTypes: this.selectedModels,
          trainingDays: this.dataDays
        })
        
        if (response.code === 200) {
          this.$message.success('训练已启动')
          this.isTraining = true
          this.elapsedTime = 0
          
          // 开始轮询进度
          this.startPolling()
        } else {
          this.$message.error('训练启动失败: ' + response.msg)
        }
      } catch (error) {
        console.error('启动训练失败:', error)
        this.$message.error('训练启动失败: ' + error.message)
      } finally {
        this.trainingLoading = false
      }
    },
    
    // 训练单个模型
    trainSingleModel(modelType) {
      this.selectedModels = [modelType]
      this.openTrainingDialog()
    },
    
    // 开始轮询进度
    startPolling() {
      this.pollingTimer = setInterval(async () => {
        await this.updateTrainingProgress()
        this.elapsedTime++
      }, 2000) // 每2秒轮询一次
    },
    
    // 停止轮询
    stopPolling() {
      if (this.pollingTimer) {
        clearInterval(this.pollingTimer)
        this.pollingTimer = null
      }
    },
    
    // 更新训练进度
    async updateTrainingProgress() {
      try {
        const response = await getTrainingProgress()
        
        if (response.code === 200) {
          const progressData = response.data
          
          // 更新训练模型状态
          if (progressData.models && Array.isArray(progressData.models)) {
            progressData.models.forEach(serverModel => {
              const localModel = this.trainingModels.find(m => m.modelType === serverModel.modelType)
              if (localModel) {
                localModel.progress = serverModel.progress || 0
                localModel.status = serverModel.status || 'pending'
                localModel.currentStep = serverModel.currentStep || '训练中...'
                localModel.accuracy = serverModel.accuracy || null
              }
            })
          }
      
      // 检查是否全部完成
          if (progressData.isTraining === false || this.allModelsCompleted) {
            this.stopPolling()
            this.$message.success('训练完成!')
            
            // 刷新服务状态
      setTimeout(() => {
              this.loadServiceStatus()
            }, 1000)
          }
        }
      } catch (error) {
        console.error('获取训练进度失败:', error)
      }
    },
    
    // 停止训练
    async handleStopTraining() {
      this.$confirm('确定要停止训练吗？', '提示', {
        type: 'warning'
      }).then(async () => {
        try {
          await stopTraining()
          this.stopPolling()
          this.isTraining = false
          this.$message.success('训练已停止')
          this.trainingDialogVisible = false
        } catch (error) {
          this.$message.error('停止训练失败: ' + error.message)
        }
      }).catch(() => {})
    },
    
    // 完成后关闭
    handleCloseAfterComplete() {
      this.stopPolling()
      this.isTraining = false
      this.trainingDialogVisible = false
      this.trainingModels = []
      this.loadServiceStatus()
    },
    
    // 测试推荐 (Phase 14: 将健康特征伴随 payload 推送至后端引擎)
    async testRecommendation() {
      if (!this.testForm.userId) {
        this.$message.warning('请输入用户ID')
        return
      }
      
      this.testLoading = true
      this.graphLoading = true
      
      try {
        const payloadParams = {
          userId: parseInt(this.testForm.userId),
          mealType: this.testForm.mealType,
          nRecommendations: 8,
          // 下方四项系 Phase 14 混杂结构补丁特征
          target: this.testForm.target || '',
          allergies: this.testForm.allergies || '',
          disease: this.testForm.disease || '',
          appetite: this.testForm.appetite || 'normal'
        };
        
        console.log("【前端诊断】准备向 /diet/ml/recommend 发送的终极Payload:", payloadParams);
        
        const response = await testMLRecommendation(payloadParams)
        
        if (response.code === 200) {
          this.testResult = response.data
          this.$message.success('推荐请求执行成功')
          
          // Phase 13 追加派发图谱捕获
          this.fetchCollaborativeGraphParams()
        } else {
          this.$message.error('推荐获取失败: ' + response.msg)
          this.graphLoading = false
        }
      } catch (error) {
        this.$message.error('推荐获取失败: ' + error.message)
        this.graphLoading = false
      } finally {
        this.testLoading = false
      }
    },
    
    // 获取力导向关系网的数据体系
    async fetchCollaborativeGraphParams() {
      try {
        const response = await getCollaborativeGraph({
          userId: parseInt(this.testForm.userId),
          mealType: this.testForm.mealType
        })
        
        if (response.code === 200) {
          this.graphData = response.data
          this.$nextTick(() => {
            this.initGraphChart()
          })
        }
      } catch (error) {
        console.error('获取 CF 推理图谱失败', error)
        this.$message.error('图谱生成出现异常')
      } finally {
        this.graphLoading = false
      }
    },
    
    // 自动刷新
    startAutoRefresh() {
      this.refreshTimer = setInterval(() => {
        if (!this.isTraining) {
          this.loadServiceStatus()
          this.loadAnalytics()
        }
      }, 30000) // 每30秒刷新一次
    },
    
    stopAutoRefresh() {
      if (this.refreshTimer) {
        clearInterval(this.refreshTimer)
        this.refreshTimer = null
      }
    },
    
    // 格式化方法
    getServiceStatusText(status) {
      const map = {
        healthy: '正常运行',
        degraded: '部分可用',
        offline: '离线'
      }
      return map[status] || '未知'
    },
    
    formatLastCheckTime(time) {
      if (!time) return '未检查'
      return new Date(time).toLocaleTimeString()
    },
    
    formatPercentage(val) {
      return (val * 100).toFixed(1)
    },
    
    formatScore(val) {
      return val ? val.toFixed(2) : '0.00'
    },
    
    formatAccuracy(val) {
      return (val * 100).toFixed(2)
    },
    
    getModelDisplayName(type) {
      const map = {
        collaborative_filtering: '协同过滤模型',
        content_based: '内容推荐模型'
      }
      return map[type] || type
    },
    
    getScoreColor(score) {
      if (score >= 0.90) return '#67C23A'; // Green for high confidence
      if (score >= 0.80) return '#E6A23C'; // Warning/Yellow
      return '#F56C6C'; // Red for low confidence
    },
    
    getStatusType(status) {
      const map = {
        pending: 'info',
        training: 'warning',
        completed: 'success',
        failed: 'danger'
      }
      return map[status] || 'info'
    },
    
    getStatusText(status) {
      const map = {
        pending: '等待中',
        training: '训练中',
        completed: '已完成',
        failed: '失败'
      }
      return map[status] || status
    }
  }
}
</script>

<style scoped lang="scss">
.ml-management {
  // 全局卡片包装层升级
  ::v-deep .box-card {
    border-radius: 16px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    border: none;
  }
  
  // 顶部大标题
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .title {
      font-size: 20px !important;
      font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', sans-serif;
      font-weight: 800 !important;
      letter-spacing: 0.5px;
      background: linear-gradient(90deg, #1890ff, #36cbcb);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      
      i {
        background: none;
        -webkit-text-fill-color: #1890ff;
        margin-right: 8px;
      }
    }
  }

  // 状态卡片 (次世代高级质感重构)
  .status-overview {
    margin-bottom: 35px;

    .status-card {
      padding: 24px;
      border-radius: 16px;
      background: #ffffff;
      color: #303133;
      box-shadow: 0 8px 20px rgba(149, 157, 165, 0.12);
      border: 1px solid rgba(0, 0, 0, 0.03);
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      position: relative;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      min-height: 140px;
      z-index: 1;

      // 发光科技底晕
      &::after {
        content: '';
        position: absolute;
        top: -30%;
        right: -10%;
        width: 150px;
        height: 150px;
        background: radial-gradient(circle, rgba(64,158,255,0.08) 0%, rgba(255,255,255,0) 70%);
        border-radius: 50%;
        z-index: -1;
      }

      &:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(50, 50, 93, 0.1), 0 5px 15px rgba(0, 0, 0, 0.07);
        
        .status-icon-wrapper i {
          transform: scale(1.1);
        }
      }
      
      // 水印大图标
      .watermark-icon {
        position: absolute;
        right: -15px;
        bottom: -20px;
        font-size: 110px;
        opacity: 0.03;
        transform: rotate(-15deg);
        z-index: -1;
        pointer-events: none;
        color: #000;
      }
      
      // 左上侧亮色浮雕小方块
      .status-icon-wrapper {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 15px;
        background: rgba(64,158,255,0.1);
        
        i {
          font-size: 24px;
          color: #409EFF;
          transition: transform 0.3s ease;
        }
      }
      
      // 各卡片色彩定制
      &.status-healthy .status-icon-wrapper { background: rgba(103,194,58,0.1); i { color: #67C23A; } }
      &.status-degraded .status-icon-wrapper { background: rgba(230,162,60,0.1); i { color: #E6A23C; } }
      &.status-offline .status-icon-wrapper { background: rgba(245,108,108,0.1); i { color: #F56C6C; } }
      
      &.models-card {
        .status-icon-wrapper { background: rgba(103,194,58,0.1); i { color: #67C23A; } }
        &::after { background: radial-gradient(circle, rgba(103,194,58,0.08) 0%, rgba(255,255,255,0) 70%); }
      }
      
      &.analytics-card {
        .status-icon-wrapper { background: rgba(230,162,60,0.1); i { color: #E6A23C; } }
        &::after { background: radial-gradient(circle, rgba(230,162,60,0.08) 0%, rgba(255,255,255,0) 70%); }
      }
      
      &.performance-card {
        .status-icon-wrapper { background: rgba(245,108,108,0.1); i { color: #F56C6C; } }
        &::after { background: radial-gradient(circle, rgba(245,108,108,0.08) 0%, rgba(255,255,255,0) 70%); }
      }
      
      .status-title {
        font-size: 13px;
        font-weight: 600;
        color: #8c939d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 8px;
      }
      
      .status-value.number-font {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        font-size: 32px;
        font-weight: 800;
        color: #2c3e50;
        line-height: 1.1;
        margin-bottom: 8px;
        
        .unit {
          font-size: 16px;
          font-weight: 500;
          color: #909399;
          margin-left: 4px;
        }
      }

      .status-time {
        font-size: 12px;
        color: #b0b8c4;
        font-weight: 500;
      }
      
      .el-progress {
        margin-top: 10px;
        ::v-deep .el-progress-bar__outer {
          background-color: #f0f2f5;
        }
      }
    }
  }
  
  // Element UI Tabs 现代风魔改
  ::v-deep .ml-tabs {
    .el-tabs__nav-wrap::after {
      height: 1px;
      background-color: #ebeef5;
    }
    .el-tabs__item {
      font-size: 16px;
      color: #909399;
      height: 50px;
      line-height: 50px;
      transition: all 0.3s cubic-bezier(.645,.045,.355,1);
      
      &.is-active {
        color: #303133;
        font-weight: bold;
        font-size: 17px;
      }
    }
    .el-tabs__active-bar {
      height: 3px;
      border-radius: 3px;
      background-color: #409EFF;
      box-shadow: 0 2px 6px rgba(64,158,255,0.4);
    }
  }
  
  // 模型卡片 (深度重构)
  .models-section {
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 25px;
      padding-top: 10px;
      
      h3 {
        margin: 0;
        color: #2c3e50;
        font-size: 18px;
        font-weight: 700;
      }
    }
    
    .model-cards {
      .model-card {
        margin-bottom: 25px;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        border: 1px solid rgba(0,0,0,0.04);
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.03);
        
        &:hover {
          transform: translateY(-5px);
          border-color: rgba(64, 158, 255, 0.3);
          box-shadow: 0 12px 24px rgba(64, 158, 255, 0.12);
          
          .model-header .model-icon {
            transform: scale(1.1) rotate(5deg);
          }
        }
        
        &.model-loaded {
          border-top: 4px solid #67C23A;
          
          .model-header .model-icon {
            color: #67C23A;
            background: rgba(103,194,58,0.1);
          }
        }
        
        ::v-deep .el-card__body {
          padding: 24px;
        }
        
        .model-header {
          display: flex;
          align-items: center;
          margin-bottom: 20px;
          
          .model-icon {
            width: 44px;
            height: 44px;
            background: rgba(64,158,255,0.1);
            color: #409EFF;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-right: 15px;
            transition: all 0.3s;
          }
          
          .model-title {
            font-size: 17px;
            font-weight: 700;
            color: #2c3e50;
            letter-spacing: 0.5px;
          }
        }
        
        .model-body {
          .el-tag {
            border-radius: 6px;
            padding: 0 12px;
            height: 26px;
            line-height: 24px;
            font-weight: 500;
          }
        
          .model-desc {
            margin: 15px 0;
            color: #5c6b77;
            font-size: 14px;
            line-height: 1.6;
            min-height: 44px;
          }
          
          .model-meta {
            font-size: 12px;
            color: #a0aab5;
            margin-top: 12px;
            font-family: monospace;
            background: #f8fafc;
            padding: 6px 10px;
            border-radius: 6px;
            display: inline-block;
          }
        }
        
        .model-actions {
          margin-top: 20px;
          text-align: right;
          border-top: 1px dashed #ebeef5;
          padding-top: 15px;
          
          .el-button {
            border-radius: 6px;
            font-weight: 500;
            padding: 9px 20px;
          }
        }
      }
    }
  }
  
  // 训练对话框
  .training-config {
    .config-section {
  margin-bottom: 30px;
      
      h4 {
        margin-bottom: 15px;
        color: #303133;
      }
      
      .model-desc {
        font-size: 13px;
        color: #606266;
        margin-bottom: 15px;
        padding: 10px;
        background: #f0f9ff;
        border-left: 3px solid #409EFF;
        border-radius: 4px;
      }
      
      .model-selection {
  display: flex;
        flex-direction: column;
        gap: 10px;

        .el-checkbox {
          width: 100%;
  padding: 15px;
          position: relative;
          
          i {
            margin-right: 8px;
          }
          
          .model-tag {
            display: inline-block;
            margin-left: 8px;
            padding: 2px 8px;
            background: #ecf5ff;
            color: #409EFF;
            font-size: 12px;
            border-radius: 3px;
          }
        }
      }
      
      .slider-value {
        text-align: center;
        margin-top: 10px;
        color: #606266;
        
        b {
          color: #409EFF;
        }
      }
    }
  }
  
  .training-progress-container {
    .training-header {
  display: flex;
      justify-content: space-between;
  align-items: center;
      margin-bottom: 20px;
      
      h3 {
        margin: 0;
      }
    }
    
    .models-progress {
      margin-bottom: 30px;
      
      .model-progress-item {
        margin-bottom: 20px;
        padding: 20px;
        border-radius: 8px;
        background: #f5f7fa;
        transition: all 0.3s;
        
        &.completed {
          background: #f0f9ff;
          border: 1px solid #67C23A;
        }
        
        .model-progress-header {
  display: flex;
          justify-content: space-between;
  align-items: center;
          margin-bottom: 10px;
          
          .model-name {
            font-weight: bold;
            color: #303133;
            
            i {
              margin-right: 5px;
              color: #409EFF;
            }
          }
        }
        
        .el-progress {
          margin: 15px 0;
        }
        
        .model-progress-step {
          font-size: 13px;
          color: #606266;
          
          i {
            margin-right: 5px;
            color: #409EFF;
          }
        }
        
        .model-progress-meta {
          margin-top: 10px;
          font-size: 12px;
          color: #909399;
          
          b {
            color: #67C23A;
          }
        }
      }
    }
    
    .overall-progress {
      padding: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 10px;
      color: white;
      
      h4 {
        margin: 0 0 15px 0;
        text-align: center;
      }
      
      .progress-stats {
  display: flex;
        justify-content: space-around;
        margin-top: 15px;
        font-size: 14px;
      }
    }
  }
  
  // 分析部分
  .analytics-section {
    .el-descriptions {
      margin-top: 5px;
    }
  }
  
  // 测试部分极客沉浸式卡片流 (Phase 22)
  .test-section {
    .recommendation-showcase {
      min-height: 380px;
      max-height: 520px;
      overflow-y: auto;
      padding: 10px;
      background: #f8fafc;
      border-radius: 12px;
      box-shadow: inset 0 2px 12px rgba(0,0,0,0.02);

      &::-webkit-scrollbar {
        width: 6px;
      }
      &::-webkit-scrollbar-thumb {
        background: #dcdfe6;
        border-radius: 3px;
      }
      
      .showcase-empty {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 350px;
        color: #909399;
        font-size: 15px;
        
        .empty-animation {
          position: relative;
          width: 80px;
          height: 80px;
          display: flex;
          align-items: center;
          justify-content: center;
          margin-bottom: 20px;
          
          i {
            font-size: 40px;
            color: #c0c4cc;
            z-index: 2;
          }
          
          .pulse-ring {
            position: absolute;
            width: 100%;
            height: 100%;
            border-radius: 50%;
            border: 2px solid #e4e7ed;
            animation: pulse-ring 2s cubic-bezier(0.215, 0.61, 0.355, 1) infinite;
          }
        }
      }

      .food-cards-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
        gap: 16px;
        padding-bottom: 10px;
      }

      .food-magic-card {
        position: relative;
        background: #ffffff;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
        border: 1px solid rgba(0,0,0,0.03);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        animation: card-appear 0.5s ease backwards;

        &:hover {
          transform: translateY(-4px);
          box-shadow: 0 12px 24px rgba(64,158,255,0.12);
        }

        .card-glass-bg {
          position: absolute;
          top: -30px;
          right: -30px;
          width: 100px;
          height: 100px;
          background: radial-gradient(circle, rgba(64,158,255,0.05) 0%, rgba(255,255,255,0) 70%);
          border-radius: 50%;
          z-index: 0;
        }

        .card-content-wrapper {
          position: relative;
          z-index: 1;
          padding: 18px;
        }

        .food-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 15px;

          .food-title {
            margin: 0;
            font-size: 16px;
            font-weight: 700;
            color: #2c3e50;
          }

          .food-weight-badge {
            background: #f4f4f5;
            color: #909399;
            padding: 3px 8px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 600;
          }
        }

        .macros-grid {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 6px;
          margin-bottom: 15px;

          .macro-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 8px 4px;
            border-radius: 8px;
            background: #f8fafc;
            
            &.cal { background: rgba(245,108,108,0.06); color: #F56C6C; }
            &.prot { background: rgba(103,194,58,0.06); color: #67C23A; }
            &.carb { background: rgba(230,162,60,0.06); color: #E6A23C; }
            &.fat { background: rgba(144,147,153,0.06); color: #909399; }

            .m-val {
              font-size: 15px;
              font-weight: 800;
              line-height: 1.2;
              font-family: monospace;
            }
            .m-unit {
              font-size: 11px;
              opacity: 0.8;
              margin-top: 2px;
              white-space: nowrap;
            }
          }
        }

        .score-section {
          margin-bottom: 12px;
          
          .score-label {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #909399;
            margin-bottom: 6px;
            
            .score-number {
              font-weight: bold;
              color: #303133;
            }
          }
        }

        .reason-tooltip {
          font-size: 12px;
          color: #8c939d;
          background: #f4f4f5;
          padding: 8px 10px;
          border-radius: 6px;
          line-height: 1.4;
          display: flex;
          align-items: flex-start;
          
          i {
            margin-top: 2px;
            margin-right: 5px;
            color: #409EFF;
          }
        }
      }
    }
    
    @keyframes card-appear {
      from { opacity: 0; transform: translateY(15px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    @keyframes pulse-ring {
      0% { transform: scale(0.8); opacity: 0.5; }
      80%, 100% { transform: scale(1.5); opacity: 0; }
    }
  }
}
</style>
