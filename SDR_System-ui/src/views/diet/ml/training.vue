<template>
  <div class="training-container">
    <el-dialog
      title="训练协同过滤模型"
      :visible.sync="visible"
      width="750px"
      :close-on-click-modal="false"
      @close="handleClose">
      
      <!-- 模型选择 -->
      <div class="model-selection" v-if="!isTraining">
        <h4>选择模型</h4>
        <el-checkbox-group v-model="selectedModels">
          <el-checkbox label="collaborative_filtering">协同过滤</el-checkbox>
          <el-checkbox label="content_based">内容推荐</el-checkbox>
          <el-checkbox label="deep_learning">深度学习</el-checkbox>
        </el-checkbox-group>
        
        <div class="data-days">
          <label>训练数据天数：</label>
          <el-input-number v-model="dataDays" :min="30" :max="365" :step="30"></el-input-number>
          <span class="tip">使用最近N天的数据进行训练</span>
        </div>
        
        <div class="estimated-time">
          <el-tag type="warning">预计训练时间：约 {{ estimatedMinutes }} 分钟</el-tag>
        </div>
      </div>

      <!-- 训练进度显示 -->
      <div class="training-progress" v-if="isTraining">
        <!-- 单个模型进度 -->
        <div v-for="model in models" :key="model.type" class="model-progress">
          <div class="model-header">
            <span class="model-name">{{ getModelName(model.type) }}</span>
            <el-tag :type="getStatusType(model.status)" size="small">
              {{ getStatusText(model.status) }}
            </el-tag>
          </div>
          
          <el-progress
            :percentage="model.progress"
            :status="model.status === 'completed' ? 'success' : model.status === 'failed' ? 'exception' : undefined"
            :stroke-width="18">
            <span class="progress-text">{{ model.currentStep }}</span>
          </el-progress>
          
          <div class="model-info">
            <span v-if="model.elapsedTime">已用时: {{ model.elapsedTime }}秒</span>
            <span v-if="model.accuracy">准确率: {{ (model.accuracy * 100).toFixed(1) }}%</span>
          </div>
        </div>

        <!-- 总体进度 -->
        <div class="overall-progress">
          <h4>总体训练进度</h4>
          <el-progress
            :percentage="overallProgress"
            :status="allCompleted ? 'success' : undefined"
            stroke-width="24"
            :color="customColors">
          </el-progress>
          <div class="overall-stats">
            <span>已完成: {{ completedCount }}/{{ totalCount }}</span>
            <span>总用时: {{ totalElapsedTime }}秒</span>
          </div>
        </div>
      </div>

      <!-- 底部按钮 -->
      <div slot="footer">
        <el-button @click="handleClose" v-if="!isTraining">取消</el-button>
        <el-button 
          type="primary" 
          @click="startTraining" 
          :disabled="selectedModels.length === 0 || isTraining"
          v-if="!isTraining">
          开始训练
        </el-button>
        <el-button @click="handleClose" v-if="isTraining && allCompleted">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'MLTrainingDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      selectedModels: ['collaborative_filtering', 'content_based', 'deep_learning'],
      dataDays: 180,
      isTraining: false,
      models: [],
      pollingTimer: null,
      customColors: [
        {color: '#f56c6c', percentage: 20},
        {color: '#e6a23c', percentage: 40},
        {color: '#6f7ad3', percentage: 60},
        {color: '#1989fa', percentage: 80},
        {color: '#5cb87a', percentage: 100}
      ]
    };
  },
  computed: {
    estimatedMinutes() {
      return this.selectedModels.length * 5 + '-' + (this.selectedModels.length * 8);
    },
    
    totalCount() {
      return this.models.length;
    },
    
    completedCount() {
      return this.models.filter(m => m.status === 'completed').length;
    },
    
    allCompleted() {
      return this.totalCount > 0 && this.completedCount === this.totalCount;
    },
    
    overallProgress() {
      if (this.totalCount === 0) return 0;
      
      // 计算总进度（completed状态强制100%）
      const total = this.models.reduce((sum, model) => {
        const progress = model.status === 'completed' ? 100 : (model.progress || 0);
        return sum + progress;
      }, 0);
      
      return Math.round(total / this.totalCount);
    },
    
    totalElapsedTime() {
      if (this.models.length === 0) return 0;
      return Math.max(...this.models.map(m => m.elapsedTime || 0));
    }
  },
  methods: {
    async startTraining() {
      if (this.selectedModels.length === 0) {
        this.$message.warning('请至少选择一个模型');
        return;
      }
      
      this.isTraining = true;
      
      // 初始化模型状态
      this.models = this.selectedModels.map(type => ({
        type: type,
        progress: 0,
        status: 'pending',
        currentStep: '等待开始...',
        elapsedTime: 0,
        accuracy: null
      }));
      
      try {
        // 调用后端开始训练
        const response = await axios.post('/dev-api/diet/ml/train', {
          modelTypes: this.selectedModels,
          dataDays: this.dataDays
        });
        
        if (response.data.code === 200) {
          // 开始轮询进度
          this.startPolling();
        } else {
          this.$message.error(response.data.msg || '启动训练失败');
          this.isTraining = false;
        }
      } catch (error) {
        console.error('启动训练失败:', error);
        this.$message.error('启动训练失败');
        this.isTraining = false;
      }
    },
    
    startPolling() {
      // 每1.5秒查询一次进度
      this.pollingTimer = setInterval(async () => {
        await this.fetchProgress();
      }, 1500);
    },
    
    async fetchProgress() {
      try {
        const response = await axios.get('/dev-api/diet/ml/training/progress', {
          params: { _t: Date.now() },  // 防止缓存
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
          }
        });
        
        if (response.data.code === 200 && response.data.data) {
          const progressData = response.data.data;
          
          // 更新每个模型的进度
          if (progressData.models && Array.isArray(progressData.models)) {
            progressData.models.forEach(serverModel => {
              const localModel = this.models.find(m => m.type === serverModel.model_type);
              if (localModel) {
                localModel.progress = serverModel.progress || 0;
                localModel.status = serverModel.training_status || 'pending';
                localModel.currentStep = serverModel.current_step || '等待开始...';
                localModel.elapsedTime = serverModel.elapsed_time || 0;
                localModel.accuracy = serverModel.accuracy;
                
                // 如果状态是completed但progress不是100，强制设置为100
                if (localModel.status === 'completed' && localModel.progress < 100) {
                  localModel.progress = 100;
                }
              }
            });
          }
          
          // 检查是否全部完成
          if (this.allCompleted) {
            this.completeTraining();
          }
        }
      } catch (error) {
        console.error('获取训练进度失败:', error);
      }
    },
    
    completeTraining() {
      // 停止轮询
      if (this.pollingTimer) {
        clearInterval(this.pollingTimer);
        this.pollingTimer = null;
      }
      
      this.isTraining = false;
      
      // 显示完成通知
      this.$notify({
        title: '训练完成',
        message: `所有${this.totalCount}个模型训练已完成！`,
        type: 'success',
        duration: 5000
      });
      
      // 通知父组件刷新数据
      this.$emit('training-completed');
    },
    
    handleClose() {
      // 如果正在训练，提示确认
      if (this.isTraining && !this.allCompleted) {
        this.$confirm('训练正在进行中，确定要关闭吗？', '提示', {
          type: 'warning'
        }).then(() => {
          this.forceClose();
        }).catch(() => {});
      } else {
        this.forceClose();
      }
    },
    
    forceClose() {
      // 清除定时器
      if (this.pollingTimer) {
        clearInterval(this.pollingTimer);
        this.pollingTimer = null;
      }
      
      this.$emit('update:visible', false);
      
      // 重置状态
      setTimeout(() => {
        this.isTraining = false;
        this.models = [];
      }, 300);
    },
    
    getModelName(type) {
      const names = {
        'collaborative_filtering': '协同过滤模型',
        'content_based': '内容推荐模型',
        'deep_learning': '深度学习模型'
      };
      return names[type] || type;
    },
    
    getStatusType(status) {
      const types = {
        'pending': 'info',
        'training': 'warning',
        'completed': 'success',
        'failed': 'danger'
      };
      return types[status] || 'info';
    },
    
    getStatusText(status) {
      const texts = {
        'pending': '等待中',
        'training': '训练中',
        'completed': '已完成',
        'failed': '失败'
      };
      return texts[status] || status;
    }
  },
  
  beforeDestroy() {
    // 组件销毁时清除定时器
    if (this.pollingTimer) {
      clearInterval(this.pollingTimer);
    }
  }
};
</script>

<style scoped>
.training-container {
  
}

.model-selection {
  padding: 20px;
}

.model-selection h4 {
  margin: 0 0 15px 0;
  color: #303133;
}

.data-days {
  margin-top: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.data-days label {
  font-weight: 500;
  color: #606266;
}

.tip {
  font-size: 12px;
  color: #909399;
}

.estimated-time {
  margin-top: 15px;
  text-align: center;
}

.training-progress {
  padding: 15px;
  min-height: 400px;
}

.model-progress {
  margin-bottom: 25px;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.model-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.model-name {
  font-weight: bold;
  font-size: 15px;
  color: #303133;
}

.progress-text {
  font-size: 13px;
  color: #909399;
}

.model-info {
  display: flex;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}

.overall-progress {
  margin-top: 30px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  color: white;
}

.overall-progress h4 {
  margin: 0 0 15px 0;
  text-align: center;
  color: white;
  font-size: 16px;
}

.overall-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 15px;
  font-size: 14px;
  color: white;
}
</style>

