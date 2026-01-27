<template>
  <div class="app-container">
    <el-card class="box-card">
      <div slot="header" class="clearfix">
        <span>系统集成状态</span>
        <el-button style="float: right; padding: 3px 0" type="text" @click="refreshStatus">刷新</el-button>
      </div>
      
      <!-- 系统概览 -->
      <el-row :gutter="20" class="mb-20">
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon" :class="overallStatus === 'healthy' ? 'success' : 'warning'">
              <i :class="overallStatus === 'healthy' ? 'el-icon-success' : 'el-icon-warning'"></i>
            </div>
            <div class="stat-content">
              <div class="stat-title">系统状态</div>
              <div class="stat-value">{{ overallStatus === 'healthy' ? '正常' : '异常' }}</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon success">
              <i class="el-icon-monitor"></i>
            </div>
            <div class="stat-content">
              <div class="stat-title">运行服务</div>
              <div class="stat-value">{{ healthyServices }}/{{ totalServices }}</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon info">
              <i class="el-icon-time"></i>
            </div>
            <div class="stat-content">
              <div class="stat-title">运行时间</div>
              <div class="stat-value">{{ uptime }}</div>
            </div>
          </div>
        </el-col>
        
        <el-col :span="6">
          <div class="stat-card">
            <div class="stat-icon primary">
              <i class="el-icon-user"></i>
            </div>
            <div class="stat-content">
              <div class="stat-title">在线用户</div>
              <div class="stat-value">{{ onlineUsers }}</div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 服务状态详情 -->
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card class="service-card">
            <div slot="header">
              <span>核心服务状态</span>
            </div>
            <div class="service-list">
              <div v-for="service in coreServices" :key="service.name" class="service-item">
                <div class="service-info">
                  <div class="service-name">
                    <i :class="getServiceIcon(service.status)"></i>
                    {{ service.name }}
                  </div>
                  <div class="service-url">{{ service.url }}</div>
                </div>
                <div class="service-status">
                  <el-tag :type="getServiceTagType(service.status)">
                    {{ getServiceStatusText(service.status) }}
                  </el-tag>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="12">
          <el-card class="service-card">
            <div slot="header">
              <span>前端应用状态</span>
            </div>
            <div class="service-list">
              <div v-for="app in frontendApps" :key="app.name" class="service-item">
                <div class="service-info">
                  <div class="service-name">
                    <i :class="getServiceIcon(app.status)"></i>
                    {{ app.name }}
                  </div>
                  <div class="service-url">{{ app.url }}</div>
                </div>
                <div class="service-status">
                  <el-tag :type="getServiceTagType(app.status)">
                    {{ getServiceStatusText(app.status) }}
                  </el-tag>
                  <el-button 
                    type="text" 
                    size="mini" 
                    @click="openApp(app.url)"
                    style="margin-left: 8px;"
                  >
                    访问
                  </el-button>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 系统监控图表 -->
      <el-row :gutter="20" class="mt-20">
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>API调用统计</span>
            </div>
            <div ref="apiChart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>服务响应时间</span>
            </div>
            <div ref="responseChart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 最近日志 -->
      <el-row class="mt-20">
        <el-col :span="24">
          <el-card>
            <div slot="header">
              <span>系统日志</span>
              <el-button style="float: right;" type="text" size="small" @click="viewAllLogs">查看全部</el-button>
            </div>
            <el-table :data="recentLogs" style="width: 100%">
              <el-table-column prop="timestamp" label="时间" width="180">
                <template slot-scope="scope">
                  {{ formatTime(scope.row.timestamp) }}
                </template>
              </el-table-column>
              <el-table-column prop="level" label="级别" width="80">
                <template slot-scope="scope">
                  <el-tag :type="getLogLevelType(scope.row.level)" size="mini">
                    {{ scope.row.level }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="service" label="服务" width="120"></el-table-column>
              <el-table-column prop="message" label="消息"></el-table-column>
            </el-table>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script>
import * as echarts from 'echarts'

export default {
  name: "SystemIntegration",
  data() {
    return {
      loading: false,
      overallStatus: 'healthy',
      totalServices: 4,
      healthyServices: 4,
      uptime: '2天 15小时',
      onlineUsers: 12,
      coreServices: [
        {
          name: '后端API服务',
          url: 'http://localhost:8080',
          status: 'healthy'
        },
        {
          name: 'ML推荐服务',
          url: 'http://localhost:8001',
          status: 'healthy'
        },
        {
          name: 'MySQL数据库',
          url: 'localhost:3306',
          status: 'healthy'
        },
        {
          name: 'MongoDB数据库',
          url: 'localhost:27017',
          status: 'healthy'
        }
      ],
      frontendApps: [
        {
          name: '管理员前端',
          url: 'http://localhost:81',
          status: 'healthy'
        },
        {
          name: '用户端应用',
          url: 'http://localhost:3000',
          status: 'healthy'
        }
      ],
      recentLogs: [
        {
          timestamp: new Date(),
          level: 'INFO',
          service: '后端服务',
          message: '用户登录成功'
        },
        {
          timestamp: new Date(Date.now() - 60000),
          level: 'INFO',
          service: 'ML服务',
          message: '模型训练完成'
        },
        {
          timestamp: new Date(Date.now() - 120000),
          level: 'WARN',
          service: '后端服务',
          message: 'API调用频率过高'
        }
      ]
    }
  },
  mounted() {
    this.initCharts()
    this.checkSystemStatus()
    // 定时刷新状态
    this.timer = setInterval(() => {
      this.checkSystemStatus()
    }, 30000)
  },
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  methods: {
    async checkSystemStatus() {
      try {
        // 检查各个服务状态
        const backendHealth = await this.checkServiceHealth('http://localhost:8080/actuator/health')
        const mlHealth = await this.checkServiceHealth('http://localhost:8001/health')
        
        // 更新服务状态
        this.updateServiceStatus('后端API服务', backendHealth)
        this.updateServiceStatus('ML推荐服务', mlHealth)
        
        // 计算整体状态
        this.calculateOverallStatus()
        
      } catch (error) {
        console.error('检查系统状态失败:', error)
      }
    },
    
    async checkServiceHealth(url) {
      try {
        const response = await fetch(url, { 
          method: 'GET',
          timeout: 5000 
        })
        return response.ok ? 'healthy' : 'unhealthy'
      } catch (error) {
        return 'error'
      }
    },
    
    updateServiceStatus(serviceName, status) {
      const service = this.coreServices.find(s => s.name === serviceName)
      if (service) {
        service.status = status
      }
    },
    
    calculateOverallStatus() {
      const allHealthy = this.coreServices.every(service => service.status === 'healthy')
      this.overallStatus = allHealthy ? 'healthy' : 'unhealthy'
      this.healthyServices = this.coreServices.filter(s => s.status === 'healthy').length
    },
    
    getServiceIcon(status) {
      switch (status) {
        case 'healthy':
          return 'el-icon-success'
        case 'unhealthy':
          return 'el-icon-warning'
        case 'error':
          return 'el-icon-error'
        default:
          return 'el-icon-question'
      }
    },
    
    getServiceTagType(status) {
      switch (status) {
        case 'healthy':
          return 'success'
        case 'unhealthy':
          return 'warning'
        case 'error':
          return 'danger'
        default:
          return 'info'
      }
    },
    
    getServiceStatusText(status) {
      switch (status) {
        case 'healthy':
          return '正常'
        case 'unhealthy':
          return '异常'
        case 'error':
          return '错误'
        default:
          return '未知'
      }
    },
    
    getLogLevelType(level) {
      switch (level) {
        case 'INFO':
          return 'success'
        case 'WARN':
          return 'warning'
        case 'ERROR':
          return 'danger'
        default:
          return 'info'
      }
    },
    
    formatTime(timestamp) {
      return new Date(timestamp).toLocaleString()
    },
    
    refreshStatus() {
      this.loading = true
      this.checkSystemStatus().finally(() => {
        this.loading = false
        this.$message.success('状态已刷新')
      })
    },
    
    openApp(url) {
      window.open(url, '_blank')
    },
    
    viewAllLogs() {
      this.$router.push('/monitor/operlog')
    },
    
    initCharts() {
      this.$nextTick(() => {
        this.initApiChart()
        this.initResponseChart()
      })
    },
    
    initApiChart() {
      const chart = echarts.init(this.$refs.apiChart)
      const option = {
        title: {
          text: 'API调用量',
          left: 'center',
          textStyle: {
            fontSize: 14
          }
        },
        tooltip: {
          trigger: 'axis'
        },
        xAxis: {
          type: 'category',
          data: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00']
        },
        yAxis: {
          type: 'value'
        },
        series: [{
          data: [120, 200, 150, 80, 70, 110],
          type: 'line',
          smooth: true,
          itemStyle: {
            color: '#409EFF'
          }
        }]
      }
      chart.setOption(option)
    },
    
    initResponseChart() {
      const chart = echarts.init(this.$refs.responseChart)
      const option = {
        title: {
          text: '响应时间(ms)',
          left: 'center',
          textStyle: {
            fontSize: 14
          }
        },
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['后端API', 'ML服务'],
          bottom: 0
        },
        xAxis: {
          type: 'category',
          data: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00']
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: '后端API',
            data: [45, 52, 48, 35, 42, 38],
            type: 'line',
            smooth: true,
            itemStyle: {
              color: '#67C23A'
            }
          },
          {
            name: 'ML服务',
            data: [120, 135, 142, 108, 125, 115],
            type: 'line',
            smooth: true,
            itemStyle: {
              color: '#E6A23C'
            }
          }
        ]
      }
      chart.setOption(option)
    }
  }
}
</script>

<style lang="scss" scoped>
.mb-20 {
  margin-bottom: 20px;
}

.mt-20 {
  margin-top: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  
  .stat-icon {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 15px;
    
    i {
      font-size: 24px;
      color: #fff;
    }
    
    &.success {
      background: #67C23A;
    }
    
    &.warning {
      background: #E6A23C;
    }
    
    &.info {
      background: #909399;
    }
    
    &.primary {
      background: #409EFF;
    }
  }
  
  .stat-content {
    .stat-title {
      font-size: 14px;
      color: #909399;
      margin-bottom: 5px;
    }
    
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #303133;
    }
  }
}

.service-card {
  .service-list {
    .service-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 0;
      border-bottom: 1px solid #EBEEF5;
      
      &:last-child {
        border-bottom: none;
      }
      
      .service-info {
        .service-name {
          font-size: 14px;
          font-weight: 500;
          color: #303133;
          margin-bottom: 4px;
          
          i {
            margin-right: 8px;
          }
        }
        
        .service-url {
          font-size: 12px;
          color: #909399;
        }
      }
      
      .service-status {
        display: flex;
        align-items: center;
      }
    }
  }
}
</style>
