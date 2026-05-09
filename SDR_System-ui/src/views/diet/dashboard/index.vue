<template>
  <div class="app-container dashboard-container">
    <div class="dashboard-header">
      <h2>饮食运营大盘</h2>
      <div class="header-actions">
        <span>实时数据流转监控中...</span>
        <el-button type="primary" size="small" icon="el-icon-refresh" @click="refreshMockData">手动刷新大盘</el-button>
      </div>
    </div>

    <!-- 顶层：四大核心宏观运营数据卡片 -->
    <el-row :gutter="20" class="panel-group">
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-people">
            <i class="el-icon-user-solid card-panel-icon" />
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">累计注册用户</div>
            <count-to :start-val="0" :end-val="overviewData.totalUsers" :duration="2000" class="card-panel-num" />
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-message">
            <i class="el-icon-s-order card-panel-icon" />
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">今日饮食记录流水</div>
            <count-to :start-val="0" :end-val="overviewData.todayRecords" :duration="3000" class="card-panel-num" />
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-money">
            <i class="el-icon-medal-1 card-panel-icon" />
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">正执行的健康目标</div>
            <count-to :start-val="0" :end-val="overviewData.activeGoals" :duration="2500" class="card-panel-num" />
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" :lg="6" class="card-panel-col">
        <div class="card-panel">
          <div class="card-panel-icon-wrapper icon-shopping">
            <i class="el-icon-s-data card-panel-icon" />
          </div>
          <div class="card-panel-description">
            <div class="card-panel-text">智能推荐API调动</div>
            <count-to :start-val="0" :end-val="overviewData.apiCalls" :duration="3600" class="card-panel-num" />
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 中部：两个占位的大盘统计图表 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 系统最近七日活跃折线图 -->
      <el-col :xs="24" :sm="24" :lg="16">
        <el-card class="box-card">
          <div slot="header" class="clearfix">
            <span>基础活跃度流水 (近十日)</span>
          </div>
          <div ref="activityLineChart" style="height: 380px;" />
        </el-card>
      </el-col>

      <!-- 全网被记录最多次的食物 TOP 分布 -->
      <el-col :xs="24" :sm="24" :lg="8">
        <el-card class="box-card">
          <div slot="header" class="clearfix">
            <span>热门登记食物品类 TOP 5</span>
          </div>
          <div ref="hotFoodPieChart" style="height: 380px;" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import CountTo from 'vue-count-to'
import * as echarts from 'echarts'
import { getGlobalOverview, getGlobalTrend, getGlobalHotFoods } from '@/api/diet/dashboard'

export default {
  name: 'GlobalDietDashboard',
  components: {
    CountTo
  },
  data() {
    return {
      overviewData: {
        totalUsers: 0,
        todayRecords: 0,
        activeGoals: 0,
        apiCalls: 0
      },
      activityChartInstance: null,
      hotFoodChartInstance: null
    }
  },
  mounted() {
    this.fetchOverviewData()
    this.fetchChartData()
    window.addEventListener('resize', this.resizeCharts)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeCharts)
    if (this.activityChartInstance) {
      this.activityChartInstance.dispose()
    }
    if (this.hotFoodChartInstance) {
      this.hotFoodChartInstance.dispose()
    }
  },
  methods: {
    // 拉取顶部四大数值大盘数据
    fetchOverviewData() {
      getGlobalOverview().then(response => {
        this.overviewData = response.data
      }).catch(err => {
        console.error("无法加载全局概览", err)
      })
    },
    // 并发拉取并挂载图表数据
    fetchChartData() {
      Promise.all([getGlobalTrend(), getGlobalHotFoods()]).then(([trendRes, hotFoodRes]) => {
        this.$nextTick(() => {
          this.initActivityChart(trendRes.data)
          this.initHotFoodChart(hotFoodRes.data)
        })
      }).catch(err => {
        console.error("图表数据装配失败", err)
      })
    },
    refreshMockData() {
      // 按钮被更名为【刷新当前大盘】借用原有的函数名
      this.fetchOverviewData()
      this.fetchChartData()
      this.$modal.msgSuccess("大盘数据已拉取并同步最新！");
    },
    resizeCharts() {
      if (this.activityChartInstance) this.activityChartInstance.resize()
      if (this.hotFoodChartInstance) this.hotFoodChartInstance.resize()
    },
    initActivityChart(trendData) {
      if (!this.activityChartInstance) {
        this.activityChartInstance = echarts.init(this.$refs.activityLineChart)
      }
      const lineOption = {
        tooltip: {
          trigger: 'axis',
        },
        legend: {
          data: ['系统全站每日流水量及跃迁']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          boundaryGap: false,
          data: trendData.dates
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: '系统全站每日流水量及跃迁',
            type: 'line',
            smooth: true,
            color: '#36a3f7',
            areaStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: 'rgba(54, 163, 247, 0.5)' },
                { offset: 1, color: 'rgba(54, 163, 247, 0.1)' }
              ])
            },
            data: trendData.counts
          }
        ]
      }
      this.activityChartInstance.setOption(lineOption)
    },
    initHotFoodChart(hotFoodsData) {
      if (!this.hotFoodChartInstance) {
        this.hotFoodChartInstance = echarts.init(this.$refs.hotFoodPieChart)
      }
      const pieOption = {
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c}次 ({d}%)'
        },
        legend: {
          bottom: '10',
          left: 'center'
        },
        series: [
          {
            name: '全服登记总数',
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: 20,
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            color: ['#36a3f7', '#f4516c', '#34bfa3', '#ffba00', '#67C23A'],
            data: hotFoodsData
          }
        ]
      }
      this.hotFoodChartInstance.setOption(pieOption)
    }
  }
}
</script>

<style scoped>
.dashboard-container {
  padding: 32px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 84px);
}
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  color: #333;
}
.header-actions span {
  font-size: 14px;
  color: #909399;
  margin-right: 15px;
}
.panel-group {
  margin-top: 18px;
}
.card-panel-col {
  margin-bottom: 32px;
}
.card-panel {
  height: 108px;
  cursor: pointer;
  font-size: 12px;
  position: relative;
  overflow: hidden;
  color: #666;
  background: #fff;
  box-shadow: 4px 4px 40px rgba(0, 0, 0, .05);
  border-color: rgba(0, 0, 0, .05);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  transition: all 0.38s ease-out;
  border-radius: 8px;
}
.card-panel:hover {
  box-shadow: 0 10px 20px rgba(0,0,0,0.1);
  transform: translateY(-5px);
}
.card-panel:hover .icon-people {
  background: #40c9c6;
  color: #fff;
}
.card-panel:hover .icon-message {
  background: #36a3f7;
  color: #fff;
}
.card-panel:hover .icon-money {
  background: #f4516c;
  color: #fff;
}
.card-panel:hover .icon-shopping {
  background: #34bfa3;
  color: #fff;
}
.card-panel-icon-wrapper {
  padding: 16px;
  transition: all 0.38s ease-out;
  border-radius: 6px;
  font-size: 48px;
}
.icon-people {
  color: #40c9c6;
}
.icon-message {
  color: #36a3f7;
}
.icon-money {
  color: #f4516c;
}
.icon-shopping {
  color: #34bfa3;
}
.card-panel-description {
  text-align: right;
  font-weight: bold;
}
.card-panel-text {
  line-height: 18px;
  color: rgba(0, 0, 0, 0.45);
  font-size: 16px;
  margin-bottom: 12px;
}
.card-panel-num {
  font-size: 28px;
  color: #40c9c6;
}
</style>
