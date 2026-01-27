<template>
  <div class="user-profile-card">
    <el-row :gutter="20">
      <!-- 用户基本信息 -->
      <el-col :span="8">
        <el-card class="profile-basic">
          <div slot="header">
            <span>基本信息</span>
          </div>
          <div class="user-avatar">
            <el-avatar :size="80" :src="userData.avatar" icon="el-icon-user-solid"></el-avatar>
          </div>
          <div class="user-info">
            <h3>{{ userData.nickName || userData.userName }}</h3>
            <p class="user-meta">ID: {{ userData.userId }}</p>
            <p class="user-meta">用户名: {{ userData.userName }}</p>
            <p class="user-meta">邮箱: {{ userData.email || '未设置' }}</p>
            <p class="user-meta">手机: {{ userData.phonenumber || '未设置' }}</p>
            <p class="user-meta">性别: {{ getSexText(userData.sex) }}</p>
            <p class="user-meta">状态: 
              <el-tag :type="userData.status === '0' ? 'success' : 'danger'" size="mini">
                {{ userData.status === '0' ? '正常' : '停用' }}
              </el-tag>
            </p>
            <p class="user-meta">注册时间: {{ parseTime(userData.createTime, '{y}-{m}-{d}') }}</p>
            <p class="user-meta">最后登录: {{ parseTime(userData.loginDate, '{y}-{m}-{d} {h}:{i}') || '从未登录' }}</p>
          </div>
        </el-card>
      </el-col>

      <!-- 饮食统计 -->
      <el-col :span="8">
        <el-card class="profile-stats">
          <div slot="header">
            <span>饮食统计 (最近30天)</span>
          </div>
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-value">{{ profileData.recentRecordsCount || 0 }}</div>
              <div class="stat-label">记录次数</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ (profileData.avgCalories || 0).toFixed(0) }}</div>
              <div class="stat-label">平均热量 (kcal)</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ (profileData.avgProtein || 0).toFixed(1) }}</div>
              <div class="stat-label">平均蛋白质 (g)</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ (profileData.avgFat || 0).toFixed(1) }}</div>
              <div class="stat-label">平均脂肪 (g)</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ (profileData.avgCarbohydrate || 0).toFixed(1) }}</div>
              <div class="stat-label">平均碳水 (g)</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ profileData.activeGoals || 0 }}</div>
              <div class="stat-label">活跃目标</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 健康目标 -->
      <el-col :span="8">
        <el-card class="profile-goals">
          <div slot="header">
            <span>健康目标</span>
          </div>
          <div v-if="profileData.goalsList && profileData.goalsList.length > 0" class="goals-list">
            <div v-for="goal in profileData.goalsList.slice(0, 3)" :key="goal.goalId" class="goal-item">
              <div class="goal-header">
                <span class="goal-name">{{ goal.goalName }}</span>
                <el-tag :type="getGoalStatusType(goal.status)" size="mini">{{ getGoalStatusText(goal.status) }}</el-tag>
              </div>
              <div class="goal-progress">
                <el-progress :percentage="getGoalProgress(goal)" :stroke-width="6" :show-text="false"></el-progress>
                <span class="progress-text">{{ getGoalProgress(goal) }}%</span>
              </div>
              <div class="goal-meta">
                <span>{{ goal.currentValue || 0 }} / {{ goal.targetValue || 0 }} {{ goal.unit || '' }}</span>
              </div>
            </div>
            <div v-if="profileData.goalsList.length > 3" class="more-goals">
              还有 {{ profileData.goalsList.length - 3 }} 个目标...
            </div>
          </div>
          <div v-else class="no-goals">
            <i class="el-icon-document-remove"></i>
            <p>暂无健康目标</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 营养摄入趋势图 -->
    <el-row style="margin-top: 20px;">
      <el-col :span="24">
        <el-card>
          <div slot="header">
            <span>营养摄入趋势</span>
          </div>
          <div ref="nutritionChart" style="height: 300px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { parseTime } from "@/utils/ruoyi";
import * as echarts from 'echarts';

export default {
  name: "UserProfileCard",
  props: {
    userData: {
      type: Object,
      required: true
    },
    profileData: {
      type: Object,
      default: () => ({})
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.initNutritionChart();
    });
  },
  beforeDestroy() {
    if (this.nutritionChart) {
      this.nutritionChart.dispose();
    }
  },
  methods: {
    parseTime,

    getSexText(sex) {
      const sexMap = {
        '0': '男',
        '1': '女',
        '2': '未知'
      };
      return sexMap[sex] || '未知';
    },

    getGoalStatusType(status) {
      const typeMap = {
        '0': 'primary',  // 进行中
        '1': 'success',  // 已完成
        '2': 'warning',  // 已暂停
        '3': 'danger'    // 已取消
      };
      return typeMap[status] || 'info';
    },

    getGoalStatusText(status) {
      const textMap = {
        '0': '进行中',
        '1': '已完成',
        '2': '已暂停',
        '3': '已取消'
      };
      return textMap[status] || '未知';
    },

    getGoalProgress(goal) {
      if (!goal.targetValue || goal.targetValue === 0) return 0;
      const progress = (goal.currentValue || 0) / goal.targetValue * 100;
      return Math.min(100, Math.max(0, progress));
    },

    initNutritionChart() {
      if (!this.$refs.nutritionChart) return;
      
      this.nutritionChart = echarts.init(this.$refs.nutritionChart);
      
      // 模拟最近7天的营养数据
      const dates = [];
      const caloriesData = [];
      const proteinData = [];
      const fatData = [];
      const carbData = [];
      
      for (let i = 6; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        dates.push(date.getMonth() + 1 + '/' + date.getDate());
        
        // 模拟数据，实际应该从接口获取
        caloriesData.push(Math.floor(Math.random() * 500 + 1500));
        proteinData.push(Math.floor(Math.random() * 50 + 50));
        fatData.push(Math.floor(Math.random() * 30 + 30));
        carbData.push(Math.floor(Math.random() * 100 + 150));
      }
      
      const option = {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'cross'
          }
        },
        legend: {
          data: ['热量', '蛋白质', '脂肪', '碳水化合物']
        },
        xAxis: {
          type: 'category',
          data: dates
        },
        yAxis: [
          {
            type: 'value',
            name: '热量 (kcal)',
            position: 'left'
          },
          {
            type: 'value',
            name: '营养素 (g)',
            position: 'right'
          }
        ],
        series: [
          {
            name: '热量',
            type: 'line',
            yAxisIndex: 0,
            data: caloriesData,
            lineStyle: { color: '#409EFF' },
            itemStyle: { color: '#409EFF' }
          },
          {
            name: '蛋白质',
            type: 'line',
            yAxisIndex: 1,
            data: proteinData,
            lineStyle: { color: '#67C23A' },
            itemStyle: { color: '#67C23A' }
          },
          {
            name: '脂肪',
            type: 'line',
            yAxisIndex: 1,
            data: fatData,
            lineStyle: { color: '#E6A23C' },
            itemStyle: { color: '#E6A23C' }
          },
          {
            name: '碳水化合物',
            type: 'line',
            yAxisIndex: 1,
            data: carbData,
            lineStyle: { color: '#F56C6C' },
            itemStyle: { color: '#F56C6C' }
          }
        ]
      };
      
      this.nutritionChart.setOption(option);
    }
  }
};
</script>

<style lang="scss" scoped>
.user-profile-card {
  .profile-basic {
    .user-avatar {
      text-align: center;
      margin-bottom: 20px;
    }
    
    .user-info {
      h3 {
        text-align: center;
        margin: 10px 0;
        color: #303133;
      }
      
      .user-meta {
        margin: 8px 0;
        font-size: 14px;
        color: #606266;
      }
    }
  }

  .profile-stats {
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 15px;
      
      .stat-item {
        text-align: center;
        padding: 10px;
        border: 1px solid #EBEEF5;
        border-radius: 4px;
        
        .stat-value {
          font-size: 20px;
          font-weight: bold;
          color: #409EFF;
        }
        
        .stat-label {
          font-size: 12px;
          color: #909399;
          margin-top: 5px;
        }
      }
    }
  }

  .profile-goals {
    .goals-list {
      .goal-item {
        margin-bottom: 15px;
        padding: 10px;
        border: 1px solid #EBEEF5;
        border-radius: 4px;
        
        .goal-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 8px;
          
          .goal-name {
            font-weight: bold;
            color: #303133;
          }
        }
        
        .goal-progress {
          display: flex;
          align-items: center;
          margin-bottom: 5px;
          
          .el-progress {
            flex: 1;
            margin-right: 10px;
          }
          
          .progress-text {
            font-size: 12px;
            color: #606266;
          }
        }
        
        .goal-meta {
          font-size: 12px;
          color: #909399;
        }
      }
      
      .more-goals {
        text-align: center;
        color: #909399;
        font-size: 12px;
        margin-top: 10px;
      }
    }
    
    .no-goals {
      text-align: center;
      color: #909399;
      padding: 40px 20px;
      
      i {
        font-size: 48px;
        margin-bottom: 10px;
        display: block;
      }
    }
  }
}
</style>
