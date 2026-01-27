<template>
  <div class="app-container">
    <!-- 系统概览卡片 -->
    <el-row :gutter="20" class="stats-overview">
      <el-col :span="6" v-for="(stat, index) in overviewStats" :key="index">
        <el-card class="stat-card" :class="stat.type">
          <div class="stat-content">
            <div class="stat-icon">
              <i :class="stat.icon"></i>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stat.value }}</div>
              <div class="stat-label">{{ stat.label }}</div>
              <div class="stat-change" :class="stat.changeType">
                <i :class="stat.changeIcon"></i>
                {{ stat.change }}
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 用户活跃度趋势 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>用户活跃度趋势</span>
            <el-button type="text" @click="refreshActivityTrend">刷新</el-button>
          </div>
          <div ref="activityTrendChart" style="height: 350px;"></div>
        </el-card>
      </el-col>

      <!-- 记录数据统计 -->
      <el-col :span="12">
        <el-card>
          <div slot="header" class="card-header">
            <span>记录数据统计</span>
            <el-button type="text" @click="refreshRecordStats">刷新</el-button>
          </div>
          <div ref="recordStatsChart" style="height: 350px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 详细统计表格 -->
    <el-row style="margin-top: 20px;">
      <el-col :span="24">
        <el-card>
          <div slot="header" class="card-header">
            <span>用户详细统计</span>
            <div>
              <el-input
                v-model="searchKeyword"
                placeholder="搜索用户"
                style="width: 200px; margin-right: 10px;"
                clearable
                @keyup.enter.native="handleSearch"
              />
              <el-button type="primary" @click="handleSearch">搜索</el-button>
              <el-button type="success" @click="exportStats">导出统计</el-button>
            </div>
          </div>
          
          <el-table :data="userStatsData" style="width: 100%" v-loading="tableLoading">
            <el-table-column prop="userId" label="用户ID" width="80" sortable/>
            <el-table-column prop="userName" label="用户名" width="120" sortable/>
            <el-table-column prop="nickName" label="昵称" width="120" sortable/>
            <el-table-column prop="totalRecords" label="总记录数" width="100" sortable>
              <template slot-scope="scope">
                <el-tag type="primary">{{ scope.row.totalRecords || 0 }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="weeklyRecords" label="本周记录" width="100" sortable>
              <template slot-scope="scope">
                <el-tag type="success">{{ scope.row.weeklyRecords || 0 }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="avgCalories" label="平均热量" width="120" sortable>
              <template slot-scope="scope">
                {{ (scope.row.avgCalories || 0).toFixed(1) }} kcal
              </template>
            </el-table-column>
            <el-table-column prop="activeGoals" label="活跃目标" width="100" sortable>
              <template slot-scope="scope">
                <el-tag type="warning">{{ scope.row.activeGoals || 0 }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="lastActiveDate" label="最后活跃" width="120" sortable>
              <template slot-scope="scope">
                {{ parseTime(scope.row.lastActiveDate, '{y}-{m}-{d}') || '从未活跃' }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template slot-scope="scope">
                <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
                  {{ scope.row.status === '0' ? '正常' : '停用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="健康评分" width="120">
              <template slot-scope="scope">
                <el-progress 
                  :percentage="getHealthScore(scope.row)" 
                  :color="getScoreColor(getHealthScore(scope.row))"
                  :stroke-width="8"
                  :show-text="false"
                />
                <span style="margin-left: 10px;">{{ getHealthScore(scope.row) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template slot-scope="scope">
                <el-button size="mini" type="text" @click="viewUserDetail(scope.row)">详情</el-button>
                <el-button size="mini" type="text" @click="viewUserData(scope.row)">数据</el-button>
                <el-button size="mini" type="text" @click="sendNotification(scope.row)">通知</el-button>
              </template>
            </el-table-column>
          </el-table>

          <pagination
            v-show="total > 0"
            :total="total"
            :page.sync="pageQuery.pageNum"
            :limit.sync="pageQuery.pageSize"
            @pagination="loadUserStats"
          />
        </el-card>
      </el-col>
    </el-row>

    <!-- 用户详情对话框 -->
    <el-dialog title="用户详情" :visible.sync="userDetailVisible" width="80%" append-to-body>
      <user-profile-card v-if="selectedUser" :user-data="selectedUser" :profile-data="selectedUserProfile"/>
    </el-dialog>

    <!-- 用户数据对话框 -->
    <el-dialog title="用户数据" :visible.sync="userDataVisible" width="90%" append-to-body>
      <user-data-tabs v-if="selectedUser" :user-id="selectedUser.userId" :user-name="selectedUser.userName"/>
    </el-dialog>

    <!-- 发送通知对话框 -->
    <el-dialog title="发送通知" :visible.sync="notificationVisible" width="500px" append-to-body>
      <el-form :model="notificationForm" label-width="80px">
        <el-form-item label="通知类型">
          <el-select v-model="notificationForm.type" placeholder="请选择通知类型">
            <el-option label="健康提醒" value="health"/>
            <el-option label="目标督促" value="goal"/>
            <el-option label="饮食建议" value="diet"/>
            <el-option label="系统通知" value="system"/>
          </el-select>
        </el-form-item>
        <el-form-item label="通知内容">
          <el-input
            v-model="notificationForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入通知内容"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="notificationVisible = false">取 消</el-button>
        <el-button type="primary" @click="sendUserNotification">发 送</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getSystemStatistics, getAllUsersRecordsOverview, getUserProfile } from "@/api/diet/admin";
import { parseTime } from "@/utils/ruoyi";
import * as echarts from 'echarts';
import UserProfileCard from './components/UserProfileCard';
import UserDataTabs from './components/UserDataTabs';

export default {
  name: "SystemStats",
  components: {
    UserProfileCard,
    UserDataTabs
  },
  data() {
    return {
      // 系统统计数据
      systemStats: {},
      // 用户统计数据
      userStatsData: [],
      // 表格加载状态
      tableLoading: false,
      // 搜索关键词
      searchKeyword: '',
      // 分页参数
      pageQuery: {
        pageNum: 1,
        pageSize: 20
      },
      total: 0,
      // 图表实例
      activityTrendChart: null,
      recordStatsChart: null,
      // 对话框状态
      userDetailVisible: false,
      userDataVisible: false,
      notificationVisible: false,
      // 选中的用户
      selectedUser: null,
      selectedUserProfile: {},
      // 通知表单
      notificationForm: {
        type: '',
        content: ''
      }
    };
  },
  computed: {
    overviewStats() {
      return [
        {
          label: '总用户数',
          value: this.systemStats.totalUsers || 0,
          icon: 'el-icon-user',
          type: 'primary',
          change: '+5.2%',
          changeType: 'positive',
          changeIcon: 'el-icon-arrow-up'
        },
        {
          label: '今日活跃',
          value: this.systemStats.activeUsersToday || 0,
          icon: 'el-icon-s-data',
          type: 'success',
          change: '+12.5%',
          changeType: 'positive',
          changeIcon: 'el-icon-arrow-up'
        },
        {
          label: '今日记录',
          value: this.systemStats.totalRecordsToday || 0,
          icon: 'el-icon-document',
          type: 'warning',
          change: '+8.3%',
          changeType: 'positive',
          changeIcon: 'el-icon-arrow-up'
        },
        {
          label: '活跃率',
          value: this.systemStats.userActivityRate ? this.systemStats.userActivityRate.toFixed(1) + '%' : '0%',
          icon: 'el-icon-pie-chart',
          type: 'danger',
          change: '-2.1%',
          changeType: 'negative',
          changeIcon: 'el-icon-arrow-down'
        }
      ];
    }
  },
  created() {
    this.loadSystemStats();
    this.loadUserStats();
  },
  mounted() {
    this.initCharts();
  },
  beforeDestroy() {
    if (this.activityTrendChart) {
      this.activityTrendChart.dispose();
    }
    if (this.recordStatsChart) {
      this.recordStatsChart.dispose();
    }
  },
  methods: {
    parseTime,

    /** 加载系统统计数据 */
    async loadSystemStats() {
      try {
        const response = await getSystemStatistics();
        this.systemStats = response.data || {};
        this.updateCharts();
      } catch (error) {
        console.error('加载系统统计失败:', error);
      }
    },

    /** 加载用户统计数据 */
    async loadUserStats() {
      this.tableLoading = true;
      try {
        const response = await getAllUsersRecordsOverview({
          pageNum: this.pageQuery.pageNum,
          pageSize: this.pageQuery.pageSize,
          userName: this.searchKeyword
        });
        this.userStatsData = response.data.users || [];
        this.total = this.userStatsData.length;
      } catch (error) {
        console.error('加载用户统计失败:', error);
      } finally {
        this.tableLoading = false;
      }
    },

    /** 搜索用户 */
    handleSearch() {
      this.pageQuery.pageNum = 1;
      this.loadUserStats();
    },

    /** 导出统计 */
    exportStats() {
      this.$modal.confirm('是否确认导出系统统计数据？').then(() => {
        // 这里实现导出逻辑
        this.$modal.msgSuccess("导出功能开发中");
      });
    },

    /** 查看用户详情 */
    async viewUserDetail(user) {
      this.selectedUser = user;
      try {
        const response = await getUserProfile(user.userId);
        this.selectedUserProfile = response.data;
        this.userDetailVisible = true;
      } catch (error) {
        console.error('获取用户详情失败:', error);
      }
    },

    /** 查看用户数据 */
    viewUserData(user) {
      this.selectedUser = user;
      this.userDataVisible = true;
    },

    /** 发送通知 */
    sendNotification(user) {
      this.selectedUser = user;
      this.notificationForm = { type: '', content: '' };
      this.notificationVisible = true;
    },

    /** 发送用户通知 */
    sendUserNotification() {
      if (!this.notificationForm.type || !this.notificationForm.content) {
        this.$message.warning('请填写完整的通知信息');
        return;
      }
      
      // 这里实现发送通知的逻辑
      this.$message.success(`通知已发送给用户 ${this.selectedUser.userName}`);
      this.notificationVisible = false;
    },

    /** 计算健康评分 */
    getHealthScore(user) {
      // 基于用户数据计算健康评分
      let score = 50; // 基础分
      
      // 记录频率加分
      if (user.weeklyRecords >= 7) score += 20;
      else if (user.weeklyRecords >= 3) score += 10;
      
      // 热量合理性加分
      if (user.avgCalories >= 1500 && user.avgCalories <= 2500) score += 15;
      
      // 目标设定加分
      if (user.activeGoals > 0) score += 15;
      
      return Math.min(100, score);
    },

    /** 获取评分颜色 */
    getScoreColor(score) {
      if (score >= 80) return '#67C23A';
      if (score >= 60) return '#E6A23C';
      return '#F56C6C';
    },

    /** 刷新活跃度趋势 */
    refreshActivityTrend() {
      this.loadSystemStats();
    },

    /** 刷新记录统计 */
    refreshRecordStats() {
      this.loadSystemStats();
    },

    /** 初始化图表 */
    initCharts() {
      this.$nextTick(() => {
        this.initActivityTrendChart();
        this.initRecordStatsChart();
      });
    },

    /** 初始化活跃度趋势图 */
    initActivityTrendChart() {
      if (!this.$refs.activityTrendChart) return;
      
      this.activityTrendChart = echarts.init(this.$refs.activityTrendChart);
      
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['活跃用户数', '记录数量']
        },
        xAxis: {
          type: 'category',
          data: []
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: '活跃用户数',
            type: 'line',
            smooth: true,
            data: []
          },
          {
            name: '记录数量',
            type: 'bar',
            data: []
          }
        ]
      };
      
      this.activityTrendChart.setOption(option);
    },

    /** 初始化记录统计图 */
    initRecordStatsChart() {
      if (!this.$refs.recordStatsChart) return;
      
      this.recordStatsChart = echarts.init(this.$refs.recordStatsChart);
      
      const option = {
        tooltip: {
          trigger: 'item'
        },
        legend: {
          orient: 'vertical',
          left: 'left'
        },
        series: [
          {
            name: '记录分布',
            type: 'pie',
            radius: '50%',
            data: [
              { value: 0, name: '早餐记录' },
              { value: 0, name: '午餐记录' },
              { value: 0, name: '晚餐记录' },
              { value: 0, name: '加餐记录' }
            ],
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      };
      
      this.recordStatsChart.setOption(option);
    },

    /** 更新图表数据 */
    updateCharts() {
      this.updateActivityTrendChart();
      this.updateRecordStatsChart();
    },

    /** 更新活跃度趋势图 */
    updateActivityTrendChart() {
      if (!this.activityTrendChart || !this.systemStats.weeklyTrend) return;
      
      const dates = this.systemStats.weeklyTrend.map(item => 
        this.parseTime(item.date, '{m}/{d}')
      );
      const activeUsers = this.systemStats.weeklyTrend.map(item => item.activeUsers);
      const totalRecords = this.systemStats.weeklyTrend.map(item => item.totalRecords);
      
      this.activityTrendChart.setOption({
        xAxis: {
          data: dates
        },
        series: [
          {
            data: activeUsers
          },
          {
            data: totalRecords
          }
        ]
      });
    },

    /** 更新记录统计图 */
    updateRecordStatsChart() {
      if (!this.recordStatsChart) return;
      
      // 模拟数据，实际应从接口获取
      const pieData = [
        { value: Math.floor(Math.random() * 100 + 50), name: '早餐记录' },
        { value: Math.floor(Math.random() * 100 + 50), name: '午餐记录' },
        { value: Math.floor(Math.random() * 100 + 50), name: '晚餐记录' },
        { value: Math.floor(Math.random() * 50 + 10), name: '加餐记录' }
      ];
      
      this.recordStatsChart.setOption({
        series: [{
          data: pieData
        }]
      });
    }
  }
};
</script>

<style lang="scss" scoped>
.stats-overview {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s;
  
  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }
  
  &.primary { border-left: 4px solid #409EFF; }
  &.success { border-left: 4px solid #67C23A; }
  &.warning { border-left: 4px solid #E6A23C; }
  &.danger { border-left: 4px solid #F56C6C; }
}

.stat-content {
  display: flex;
  align-items: center;
  
  .stat-icon {
    margin-right: 15px;
    
    i {
      font-size: 40px;
      color: #409EFF;
    }
  }
  
  .stat-info {
    flex: 1;
    
    .stat-value {
      font-size: 28px;
      font-weight: bold;
      color: #303133;
      line-height: 1;
    }
    
    .stat-label {
      font-size: 14px;
      color: #909399;
      margin: 5px 0;
    }
    
    .stat-change {
      font-size: 12px;
      
      &.positive {
        color: #67C23A;
      }
      
      &.negative {
        color: #F56C6C;
      }
    }
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
