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
            <div class="status-icon">
              <i :class="serviceStatusIcon"></i>
            </div>
            <div class="status-info">
              <div class="status-title">服务状态</div>
              <div class="status-value">{{ getServiceStatusText(serviceStatus.serviceStatus) }}</div>
              <div class="status-time">{{ formatLastCheckTime(serviceStatus.lastCheckTime) }}</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card models-card">
            <div class="status-icon">
              <i class="el-icon-cpu"></i>
            </div>
            <div class="status-info">
              <div class="status-title">已加载模型</div>
              <div class="status-value">{{ loadedModelsCount }}/2</div>
                <el-progress 
                :percentage="Math.round((loadedModelsCount / 2) * 100)"
                :stroke-width="6"
                  :show-text="false"
                ></el-progress>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card analytics-card">
            <div class="status-icon">
              <i class="el-icon-data-analysis"></i>
            </div>
            <div class="status-info">
              <div class="status-title">推荐接受率</div>
              <div class="status-value">{{ formatPercentage(analyticsData.acceptanceRate) }}%</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="status-card performance-card">
            <div class="status-icon">
              <i class="el-icon-timer"></i>
            </div>
            <div class="status-info">
              <div class="status-title">平均响应时间</div>
              <div class="status-value">{{ analyticsData.avgResponseTime || 0 }}ms</div>
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
              <el-row :gutter="20">
                <el-col :span="12">
                <el-card>
                  <div slot="header">推荐统计</div>
                  <el-descriptions :column="2" border>
                    <el-descriptions-item label="总推荐数">
                      {{ analyticsData.totalRecommendations || 0 }}
                    </el-descriptions-item>
                    <el-descriptions-item label="接受推荐数">
                      {{ analyticsData.acceptedRecommendations || 0 }}
                    </el-descriptions-item>
                    <el-descriptions-item label="接受率">
                      {{ formatPercentage(analyticsData.acceptanceRate) }}%
                    </el-descriptions-item>
                    <el-descriptions-item label="平均评分">
                      {{ formatScore(analyticsData.avgScore) }}
                    </el-descriptions-item>
                    <el-descriptions-item label="活跃用户">
                      {{ analyticsData.activeUsers || 0 }}
                    </el-descriptions-item>
                    <el-descriptions-item label="响应时间">
                      {{ analyticsData.avgResponseTime || 0 }}ms
                    </el-descriptions-item>
                  </el-descriptions>
                  </el-card>
                </el-col>
                
                <el-col :span="12">
                <el-card>
                  <div slot="header">算法性能对比</div>
                  <el-table :data="algorithmPerformanceList" size="small">
                    <el-table-column prop="algorithmType" label="算法类型" width="150">
                <template slot-scope="scope">
                        <el-tag size="mini">{{ scope.row.algorithmType }}</el-tag>
                </template>
              </el-table-column>
                    <el-table-column prop="totalRecommendations" label="推荐数" width="100"></el-table-column>
                    <el-table-column prop="acceptanceRate" label="接受率" width="100">
                <template slot-scope="scope">
                        {{ formatPercentage(scope.row.acceptanceRate) }}%
                </template>
              </el-table-column>
                    <el-table-column prop="avgScore" label="平均评分">
                <template slot-scope="scope">
                        {{ formatScore(scope.row.avgScore) }}
                </template>
              </el-table-column>
            </el-table>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- 推荐测试 -->
        <el-tab-pane label="推荐测试" name="test">
          <div class="test-section">
            <el-card>
              <div slot="header">测试推荐功能</div>
              <el-form :model="testForm" label-width="100px">
              <el-form-item label="用户ID">
                  <el-input v-model="testForm.userId" placeholder="请输入用户ID" style="width: 300px"></el-input>
              </el-form-item>
              <el-form-item label="餐次类型">
                  <el-select v-model="testForm.mealType" style="width: 300px">
                    <el-option label="早餐" value="1"></el-option>
                    <el-option label="午餐" value="2"></el-option>
                    <el-option label="晚餐" value="3"></el-option>
                    <el-option label="加餐" value="4"></el-option>
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="testRecommendation" :loading="testLoading">
                    获取推荐
                </el-button>
              </el-form-item>
            </el-form>

            <div v-if="testResult" class="test-result">
                <h4>推荐结果</h4>
                <el-table :data="testResult.recommendations" size="small">
                  <el-table-column prop="foodName" label="食物名称"></el-table-column>
                  <el-table-column prop="score" label="推荐分数" width="120">
                    <template slot-scope="scope">
                      <el-progress 
                        :percentage="Math.round(scope.row.score * 100)" 
                        :stroke-width="10"
                      ></el-progress>
                    </template>
                  </el-table-column>
                  <el-table-column prop="reason" label="推荐理由"></el-table-column>
                </el-table>
            </div>
            </el-card>
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
import { getMLStatus, refreshMLStatus, trainMLModels, getMLAnalytics, testMLRecommendation, getTrainingProgress, stopTraining } from "@/api/diet/ml"

export default {
  name: "MLManagement",
  data() {
    return {
      loading: false,
      activeTab: 'models',
      
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
      
      // 推荐测试
      testForm: {
        userId: '',
        mealType: '1'
      },
      testLoading: false,
      testResult: null,
      
      // 定时刷新
      refreshTimer: null
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
      const loaded = Object.values(this.serviceStatus.modelsLoaded)
      return loaded.filter(Boolean).length
    },
    
    modelsList() {
      return [
        {
          type: 'collaborative_filtering',
          name: '协同过滤模型',
          icon: 'el-icon-s-data',
          description: '基于用户行为相似度的推荐（核心算法）',
          loaded: this.serviceStatus.modelsLoaded?.collaborative_filtering || false,
          lastTrained: this.serviceStatus.models?.collaborative_filtering?.last_trained || null
        },
        {
          type: 'content_based',
          name: '内容推荐模型',
          icon: 'el-icon-document',
          description: '基于食物营养特征的推荐（结合营养学约束）',
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
  },
  
  beforeDestroy() {
    this.stopPolling()
    this.stopAutoRefresh()
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
        }
      } catch (error) {
        console.error('加载分析数据失败:', error)
      }
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
    
    // 测试推荐
    async testRecommendation() {
      if (!this.testForm.userId) {
        this.$message.warning('请输入用户ID')
        return
      }
      
      this.testLoading = true
      try {
        const response = await testMLRecommendation({
          userId: parseInt(this.testForm.userId),
          mealType: this.testForm.mealType,
          nRecommendations: 8
        })
        
        if (response.code === 200) {
          this.testResult = response.data
          this.$message.success('推荐获取成功')
        } else {
          this.$message.error('推荐获取失败: ' + response.msg)
        }
      } catch (error) {
        this.$message.error('推荐获取失败: ' + error.message)
      } finally {
        this.testLoading = false
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
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
    
    .title {
      font-size: 18px;
      font-weight: bold;
      color: #303133;
      
      i {
        margin-right: 8px;
        color: #409EFF;
      }
    }
  }
  
  // 状态卡片
.status-overview {
    margin-bottom: 30px;

.status-card {
  padding: 20px;
  border-radius: 8px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
      transition: transform 0.3s;
      
      &:hover {
        transform: translateY(-5px);
      }
      
      &.status-healthy {
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
      }
      
      &.status-degraded {
        background: linear-gradient(135deg, #f2994a 0%, #f2c94c 100%);
      }
      
      &.status-offline {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      }
      
      .status-icon {
        font-size: 32px;
        margin-bottom: 10px;
      }
      
      .status-title {
        font-size: 14px;
        opacity: 0.9;
        margin-bottom: 5px;
      }
      
      .status-value {
        font-size: 24px;
  font-weight: bold;
  margin-bottom: 5px;
}

      .status-time, .status-detail {
  font-size: 12px;
        opacity: 0.8;
      }
      
      .el-progress {
        margin-top: 10px;
      }
    }
    
    .models-card {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    .analytics-card {
      background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
    
    .performance-card {
      background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    }
  }
  
  // 模型卡片
.models-section {
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
      
      h3 {
        margin: 0;
        color: #303133;
      }
    }
    
    .model-cards {
      .model-card {
  margin-bottom: 20px;
        transition: all 0.3s;
        border: 2px solid transparent;
        
        &:hover {
          border-color: #409EFF;
          box-shadow: 0 4px 20px rgba(64, 158, 255, 0.2);
        }
        
        &.model-loaded {
          border-color: #67C23A;
        }
        
        .model-header {
  display: flex;
  align-items: center;
          margin-bottom: 15px;
          
          .model-icon {
            font-size: 32px;
            color: #409EFF;
            margin-right: 12px;
          }
          
          .model-title {
            font-size: 16px;
  font-weight: bold;
            color: #303133;
          }
        }
        
        .model-body {
          .model-desc {
            margin: 10px 0;
            color: #606266;
            font-size: 14px;
          }
          
          .model-meta {
  font-size: 12px;
            color: #909399;
            margin-top: 8px;
          }
        }
        
        .model-actions {
          margin-top: 15px;
          text-align: right;
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
      margin-top: 20px;
    }
  }
  
  // 测试部分
  .test-section {
    .test-result {
      margin-top: 30px;
      
      h4 {
        margin-bottom: 15px;
      }
    }
  }
}
</style>
