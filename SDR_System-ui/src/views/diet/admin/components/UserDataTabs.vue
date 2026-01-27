<template>
  <div class="user-data-tabs">
    <el-tabs v-model="activeTab" type="border-card">
      <!-- 饮食记录 -->
      <el-tab-pane label="饮食记录" name="records">
        <div class="tab-toolbar">
          <el-date-picker
            v-model="recordDateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="yyyy-MM-dd"
            @change="loadRecords"
          />
          <el-button type="primary" size="small" @click="loadRecords">刷新</el-button>
          <el-button type="success" size="small" @click="exportRecords">导出</el-button>
        </div>
        
        <el-table :data="recordList" style="width: 100%" v-loading="recordLoading">
          <el-table-column prop="recordDate" label="记录日期" width="120">
            <template slot-scope="scope">
              {{ parseTime(scope.row.recordDate, '{y}-{m}-{d}') }}
            </template>
          </el-table-column>
          <el-table-column prop="mealType" label="餐次" width="80">
            <template slot-scope="scope">
              {{ getMealTypeText(scope.row.mealType) }}
            </template>
          </el-table-column>
          <el-table-column prop="totalCalories" label="热量(kcal)" width="100">
            <template slot-scope="scope">
              {{ (scope.row.totalCalories || 0).toFixed(1) }}
            </template>
          </el-table-column>
          <el-table-column prop="totalProtein" label="蛋白质(g)" width="100">
            <template slot-scope="scope">
              {{ (scope.row.totalProtein || 0).toFixed(1) }}
            </template>
          </el-table-column>
          <el-table-column prop="totalFat" label="脂肪(g)" width="100">
            <template slot-scope="scope">
              {{ (scope.row.totalFat || 0).toFixed(1) }}
            </template>
          </el-table-column>
          <el-table-column prop="totalCarbohydrate" label="碳水(g)" width="100">
            <template slot-scope="scope">
              {{ (scope.row.totalCarbohydrate || 0).toFixed(1) }}
            </template>
          </el-table-column>
          <el-table-column prop="foodItems" label="食物" min-width="200">
            <template slot-scope="scope">
              {{ scope.row.foodItems || '暂无详情' }}
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="150">
            <template slot-scope="scope">
              {{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}') }}
            </template>
          </el-table-column>
        </el-table>
        
        <el-pagination
          @size-change="handleRecordSizeChange"
          @current-change="handleRecordCurrentChange"
          :current-page="recordQuery.pageNum"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="recordQuery.pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="recordTotal">
        </el-pagination>
      </el-tab-pane>

      <!-- 健康目标 -->
      <el-tab-pane label="健康目标" name="goals">
        <div class="tab-toolbar">
          <el-button type="primary" size="small" @click="loadGoals">刷新</el-button>
        </div>
        
        <el-table :data="goalList" style="width: 100%" v-loading="goalLoading">
          <el-table-column prop="goalName" label="目标名称" min-width="150"/>
          <el-table-column prop="goalType" label="目标类型" width="100">
            <template slot-scope="scope">
              {{ getGoalTypeText(scope.row.goalType) }}
            </template>
          </el-table-column>
          <el-table-column prop="targetValue" label="目标值" width="100">
            <template slot-scope="scope">
              {{ scope.row.targetValue }} {{ scope.row.unit }}
            </template>
          </el-table-column>
          <el-table-column prop="currentValue" label="当前值" width="100">
            <template slot-scope="scope">
              {{ scope.row.currentValue || 0 }} {{ scope.row.unit }}
            </template>
          </el-table-column>
          <el-table-column label="进度" width="200">
            <template slot-scope="scope">
              <el-progress :percentage="getGoalProgress(scope.row)" :stroke-width="8"/>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template slot-scope="scope">
              <el-tag :type="getGoalStatusType(scope.row.status)">
                {{ getGoalStatusText(scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="startDate" label="开始日期" width="120">
            <template slot-scope="scope">
              {{ parseTime(scope.row.startDate, '{y}-{m}-{d}') }}
            </template>
          </el-table-column>
          <el-table-column prop="targetDate" label="目标日期" width="120">
            <template slot-scope="scope">
              {{ parseTime(scope.row.targetDate, '{y}-{m}-{d}') }}
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 推荐记录 -->
      <el-tab-pane label="推荐记录" name="recommendations">
        <div class="tab-toolbar">
          <el-button type="primary" size="small" @click="loadRecommendations">刷新</el-button>
        </div>
        
        <el-table :data="recommendationList" style="width: 100%" v-loading="recommendationLoading">
          <el-table-column prop="recommendationDate" label="推荐日期" width="120">
            <template slot-scope="scope">
              {{ parseTime(scope.row.recommendationDate, '{y}-{m}-{d}') }}
            </template>
          </el-table-column>
          <el-table-column prop="mealType" label="餐次" width="80">
            <template slot-scope="scope">
              {{ getMealTypeText(scope.row.mealType) }}
            </template>
          </el-table-column>
          <el-table-column prop="algorithmType" label="推荐算法" width="120"/>
          <el-table-column prop="recommendedFoods" label="推荐食物" min-width="200"/>
          <el-table-column prop="reason" label="推荐理由" min-width="250"/>
          <el-table-column prop="score" label="评分" width="80">
            <template slot-scope="scope">
              {{ scope.row.score || 0 }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template slot-scope="scope">
              <el-tag :type="scope.row.status === '1' ? 'success' : 'info'">
                {{ scope.row.status === '1' ? '已应用' : '未应用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="150">
            <template slot-scope="scope">
              {{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}') }}
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <!-- 营养分析 -->
      <el-tab-pane label="营养分析" name="analysis">
        <div class="tab-toolbar">
          <el-date-picker
            v-model="analysisDateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="yyyy-MM-dd"
            @change="loadAnalysis"
          />
          <el-button type="primary" size="small" @click="loadAnalysis">刷新</el-button>
        </div>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card title="营养摄入趋势">
              <div ref="nutritionTrendChart" style="height: 300px;"></div>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card title="营养分布">
              <div ref="nutritionPieChart" style="height: 300px;"></div>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import { getUserDietRecords, getUserDietGoals, getUserRecommendations, exportUserDietData } from "@/api/diet/admin";
import { getNutritionAnalysis } from "@/api/diet/analysis";
import { parseTime } from "@/utils/ruoyi";
import * as echarts from 'echarts';

export default {
  name: "UserDataTabs",
  props: {
    userId: {
      type: [String, Number],
      required: true
    },
    userName: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      activeTab: 'records',
      
      // 饮食记录
      recordList: [],
      recordLoading: false,
      recordTotal: 0,
      recordDateRange: [],
      recordQuery: {
        pageNum: 1,
        pageSize: 10
      },
      
      // 健康目标
      goalList: [],
      goalLoading: false,
      
      // 推荐记录
      recommendationList: [],
      recommendationLoading: false,
      
      // 营养分析
      analysisDateRange: [],
      nutritionTrendChart: null,
      nutritionPieChart: null
    };
  },
  created() {
    this.initDateRanges();
    this.loadRecords();
  },
  mounted() {
    this.$nextTick(() => {
      this.initCharts();
    });
  },
  beforeDestroy() {
    if (this.nutritionTrendChart) {
      this.nutritionTrendChart.dispose();
    }
    if (this.nutritionPieChart) {
      this.nutritionPieChart.dispose();
    }
  },
  methods: {
    parseTime,

    initDateRanges() {
      const end = new Date();
      const start = new Date();
      start.setDate(end.getDate() - 30); // 默认最近30天
      
      const startStr = this.parseTime(start, '{y}-{m}-{d}');
      const endStr = this.parseTime(end, '{y}-{m}-{d}');
      
      this.recordDateRange = [startStr, endStr];
      this.analysisDateRange = [startStr, endStr];
    },

    // 饮食记录相关方法
    loadRecords() {
      this.recordLoading = true;
      const params = {
        pageNum: this.recordQuery.pageNum,
        pageSize: this.recordQuery.pageSize
      };
      
      if (this.recordDateRange && this.recordDateRange.length === 2) {
        params.startDate = this.recordDateRange[0];
        params.endDate = this.recordDateRange[1];
      }
      
      getUserDietRecords(this.userId, params).then(response => {
        this.recordList = response.rows || [];
        this.recordTotal = response.total || 0;
        this.recordLoading = false;
      }).catch(() => {
        this.recordLoading = false;
      });
    },

    handleRecordSizeChange(val) {
      this.recordQuery.pageSize = val;
      this.loadRecords();
    },

    handleRecordCurrentChange(val) {
      this.recordQuery.pageNum = val;
      this.loadRecords();
    },

    exportRecords() {
      const params = {};
      if (this.recordDateRange && this.recordDateRange.length === 2) {
        params.startDate = this.recordDateRange[0];
        params.endDate = this.recordDateRange[1];
      }
      
      exportUserDietData(this.userId, params).then(() => {
        this.$message.success('导出成功');
      });
    },

    // 健康目标相关方法
    loadGoals() {
      this.goalLoading = true;
      getUserDietGoals(this.userId).then(response => {
        this.goalList = response.rows || [];
        this.goalLoading = false;
      }).catch(() => {
        this.goalLoading = false;
      });
    },

    // 推荐记录相关方法
    loadRecommendations() {
      this.recommendationLoading = true;
      getUserRecommendations(this.userId).then(response => {
        this.recommendationList = response.rows || [];
        this.recommendationLoading = false;
      }).catch(() => {
        this.recommendationLoading = false;
      });
    },

    // 营养分析相关方法
    loadAnalysis() {
      if (this.analysisDateRange && this.analysisDateRange.length === 2) {
        getNutritionAnalysis({
          startDate: this.analysisDateRange[0],
          endDate: this.analysisDateRange[1],
          userId: this.userId
        }).then(response => {
          this.updateCharts(response.data);
        });
      }
    },

    initCharts() {
      if (this.$refs.nutritionTrendChart) {
        this.nutritionTrendChart = echarts.init(this.$refs.nutritionTrendChart);
      }
      if (this.$refs.nutritionPieChart) {
        this.nutritionPieChart = echarts.init(this.$refs.nutritionPieChart);
      }
      this.loadAnalysis();
    },

    updateCharts(data) {
      // 更新趋势图
      if (this.nutritionTrendChart && data.rows) {
        const dates = data.rows.map(item => this.parseTime(item.recordDate, '{m}-{d}'));
        const calories = data.rows.map(item => item.totalCalories || 0);
        const protein = data.rows.map(item => item.totalProtein || 0);
        const fat = data.rows.map(item => item.totalFat || 0);
        const carbs = data.rows.map(item => item.totalCarbohydrate || 0);

        const option = {
          tooltip: { trigger: 'axis' },
          legend: { data: ['热量', '蛋白质', '脂肪', '碳水'] },
          xAxis: { type: 'category', data: dates },
          yAxis: { type: 'value' },
          series: [
            { name: '热量', type: 'line', data: calories },
            { name: '蛋白质', type: 'line', data: protein },
            { name: '脂肪', type: 'line', data: fat },
            { name: '碳水', type: 'line', data: carbs }
          ]
        };
        this.nutritionTrendChart.setOption(option);
      }

      // 更新饼图
      if (this.nutritionPieChart && data.summary) {
        const total = (data.summary.totalProtein || 0) + (data.summary.totalFat || 0) + (data.summary.totalCarbohydrate || 0);
        const pieData = [
          { value: data.summary.totalProtein || 0, name: '蛋白质' },
          { value: data.summary.totalFat || 0, name: '脂肪' },
          { value: data.summary.totalCarbohydrate || 0, name: '碳水化合物' }
        ];

        const option = {
          tooltip: { trigger: 'item' },
          legend: { orient: 'vertical', left: 'left' },
          series: [{
            name: '营养分布',
            type: 'pie',
            radius: '50%',
            data: pieData,
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }]
        };
        this.nutritionPieChart.setOption(option);
      }
    },

    // 工具方法
    getMealTypeText(type) {
      const mealTypes = {
        '0': '早餐',
        '1': '午餐',
        '2': '晚餐',
        '3': '加餐'
      };
      return mealTypes[type] || '未知';
    },

    getGoalTypeText(type) {
      const goalTypes = {
        '0': '减重',
        '1': '增重',
        '2': '维持',
        '3': '增肌',
        '4': '减脂',
        '5': '改善血糖',
        '6': '改善血压'
      };
      return goalTypes[type] || '其他';
    },

    getGoalProgress(goal) {
      if (!goal.targetValue || goal.targetValue === 0) return 0;
      const progress = (goal.currentValue || 0) / goal.targetValue * 100;
      return Math.min(100, Math.max(0, progress));
    },

    getGoalStatusType(status) {
      const typeMap = {
        '0': 'primary',
        '1': 'success',
        '2': 'warning',
        '3': 'danger'
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
    }
  },

  watch: {
    activeTab(newTab) {
      if (newTab === 'goals' && this.goalList.length === 0) {
        this.loadGoals();
      } else if (newTab === 'recommendations' && this.recommendationList.length === 0) {
        this.loadRecommendations();
      } else if (newTab === 'analysis') {
        this.$nextTick(() => {
          this.initCharts();
        });
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.user-data-tabs {
  .tab-toolbar {
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .el-pagination {
    margin-top: 15px;
    text-align: right;
  }
}
</style>
