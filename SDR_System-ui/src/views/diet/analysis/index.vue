<template>
  <div class="app-container">
    <!-- 查询条件 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="分析时间" prop="dateRange">
        <el-date-picker
          v-model="queryParams.dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="yyyy-MM-dd"
        >
        </el-date-picker>
      </el-form-item>
      <el-form-item label="用户" prop="userId" v-if="isAdmin">
        <el-select v-model="queryParams.userId" placeholder="请选择用户" clearable filterable>
          <el-option
            v-for="user in userList"
            :key="user.userId"
            :label="user.nickName || user.userName"
            :value="user.userId"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 营养概览卡片 -->
    <el-row :gutter="20" class="mb8">
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="nutrition-card calories">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-lightning"></i>
            </div>
            <div class="info">
              <div class="title">平均热量</div>
              <div class="value">{{ nutritionSummary.avgCalories || 0 }} kcal</div>
              <div class="subtitle">每日平均</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="nutrition-card protein">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-chicken"></i>
            </div>
            <div class="info">
              <div class="title">平均蛋白质</div>
              <div class="value">{{ nutritionSummary.avgProtein || 0 }} g</div>
              <div class="subtitle">每日平均</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="nutrition-card fat">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-ice-cream-round"></i>
            </div>
            <div class="info">
              <div class="title">平均脂肪</div>
              <div class="value">{{ nutritionSummary.avgFat || 0 }} g</div>
              <div class="subtitle">每日平均</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="nutrition-card carb">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-food"></i>
            </div>
            <div class="info">
              <div class="title">平均碳水</div>
              <div class="value">{{ nutritionSummary.avgCarbohydrate || 0 }} g</div>
              <div class="subtitle">每日平均</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20">
      <!-- 营养素趋势图 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span>营养素趋势分析</span>
            <el-button-group size="mini">
              <el-button :type="trendType === 'calories' ? 'primary' : ''" @click="changeTrendType('calories')">热量</el-button>
              <el-button :type="trendType === 'protein' ? 'primary' : ''" @click="changeTrendType('protein')">蛋白质</el-button>
              <el-button :type="trendType === 'fat' ? 'primary' : ''" @click="changeTrendType('fat')">脂肪</el-button>
              <el-button :type="trendType === 'carb' ? 'primary' : ''" @click="changeTrendType('carb')">碳水</el-button>
            </el-button-group>
          </div>
          <div ref="trendChart" style="height: 400px;"></div>
        </el-card>
      </el-col>

      <!-- 营养分布饼图 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span>营养素分布</span>
          </div>
          <div ref="pieChart" style="height: 400px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 餐次分析 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span>餐次热量分布</span>
          </div>
          <div ref="mealChart" style="height: 350px;"></div>
        </el-card>
      </el-col>

      <!-- 营养建议 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="advice-card">
          <div slot="header" class="card-header">
            <span>营养建议</span>
            <el-button type="text" size="small" @click="generateAdvice">重新生成</el-button>
          </div>
          <div class="advice-content">
            <div v-if="nutritionAdvice.length > 0">
              <div v-for="(advice, index) in nutritionAdvice" :key="index" class="advice-item">
                <div class="advice-type" :class="advice.type">
                  <i :class="getAdviceIcon(advice.type)"></i>
                  {{ getAdviceTypeName(advice.type) }}
                </div>
                <div class="advice-text">{{ advice.content }}</div>
              </div>
            </div>
            <div v-else class="no-advice">
              <el-empty description="暂无营养建议" :image-size="60"></el-empty>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 详细数据表格 -->
    <el-card class="table-card" style="margin-top: 20px;">
      <div slot="header" class="card-header">
        <span>详细数据</span>
        <el-button type="primary" size="mini" icon="el-icon-download" @click="handleExport">导出报告</el-button>
      </div>
      
      <el-table v-loading="loading" :data="analysisData" style="width: 100%">
        <el-table-column label="日期" align="center" prop="date" width="120">
          <template slot-scope="scope">
            <span>{{ parseTime(scope.row.date, '{y}-{m}-{d}') }}</span>
          </template>
        </el-table-column>
        <el-table-column label="总热量(kcal)" align="center" prop="totalCalories" />
        <el-table-column label="蛋白质(g)" align="center" prop="totalProtein" />
        <el-table-column label="脂肪(g)" align="center" prop="totalFat" />
        <el-table-column label="碳水化合物(g)" align="center" prop="totalCarbohydrate" />
        <el-table-column label="膳食纤维(g)" align="center" prop="totalFiber" />
        <el-table-column label="记录次数" align="center" prop="recordCount" />
        <el-table-column label="目标完成度" align="center">
          <template slot-scope="scope">
            <el-progress
              :percentage="getCompletionRate(scope.row.totalCalories)"
              :color="getProgressColor(getCompletionRate(scope.row.totalCalories))"
              :stroke-width="8"
            ></el-progress>
          </template>
        </el-table-column>
      </el-table>
      
      <pagination
        v-show="total > 0"
        :total="total"
        :page.sync="queryParams.pageNum"
        :limit.sync="queryParams.pageSize"
        @pagination="getList"
      />
    </el-card>
  </div>
</template>

<script>
import { getNutritionAnalysis, getNutritionAdvice, exportAnalysisReport } from "@/api/diet/analysis";
import { listUser } from "@/api/system/user";
import * as echarts from 'echarts';

export default {
  name: "DietAnalysis",
  data() {
    return {
      // 遮罩层
      loading: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 分析数据
      analysisData: [],
      // 营养概览
      nutritionSummary: {},
      // 营养建议
      nutritionAdvice: [],
      // 用户列表
      userList: [],
      // 当前用户是否为管理员
      isAdmin: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        dateRange: [],
        userId: null
      },
      // 趋势图类型
      trendType: 'calories',
      // 图表实例
      trendChart: null,
      pieChart: null,
      mealChart: null,
      // 目标热量（示例值，实际应从用户设置获取）
      targetCalories: 2000
    };
  },
  created() {
    this.initDateRange();
    this.checkUserRole();
    this.loadUserList();
    this.getList();
    this.loadNutritionAdvice();
  },
  mounted() {
    this.initCharts();
  },
  beforeDestroy() {
    if (this.trendChart) {
      this.trendChart.dispose();
    }
    if (this.pieChart) {
      this.pieChart.dispose();
    }
    if (this.mealChart) {
      this.mealChart.dispose();
    }
  },
  methods: {
    initDateRange() {
      const end = new Date();
      const start = new Date();
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 30); // 默认30天
      this.queryParams.dateRange = [this.formatDate(start), this.formatDate(end)];
    },
    
    checkUserRole() {
      // 检查当前用户是否为管理员
      const roles = this.$store.getters.roles;
      this.isAdmin = roles.includes('admin');
      
      // 如果不是管理员，清空userId参数
      if (!this.isAdmin) {
        this.queryParams.userId = null;
      }
    },
    
    async loadUserList() {
      if (this.isAdmin) {
        try {
          const response = await listUser({ pageNum: 1, pageSize: 1000 });
          this.userList = response.rows || [];
        } catch (error) {
          console.error('加载用户列表失败:', error);
        }
      }
    },
    
    /** 查询分析数据 */
    async getList() {
      this.loading = true;
      try {
        const params = {
          ...this.queryParams,
          startDate: this.queryParams.dateRange[0],
          endDate: this.queryParams.dateRange[1]
        };
        delete params.dateRange;
        
        const response = await getNutritionAnalysis(params);
        this.analysisData = response.rows || [];
        this.total = response.total || 0;
        this.nutritionSummary = response.summary || {};
        
        // 更新图表
        this.updateCharts();
      } catch (error) {
        console.error('加载分析数据失败:', error);
      } finally {
        this.loading = false;
      }
    },
    
    async loadNutritionAdvice() {
      try {
        const params = {
          startDate: this.queryParams.dateRange[0],
          endDate: this.queryParams.dateRange[1],
          userId: this.queryParams.userId
        };
        const response = await getNutritionAdvice(params);
        this.nutritionAdvice = response.data || [];
      } catch (error) {
        console.error('加载营养建议失败:', error);
      }
    },
    
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
      this.loadNutritionAdvice();
    },
    
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.initDateRange();
      this.handleQuery();
    },
    
    /** 导出报告 */
    handleExport() {
      const params = {
        startDate: this.queryParams.dateRange[0],
        endDate: this.queryParams.dateRange[1],
        userId: this.queryParams.userId
      };
      this.download('diet/analysis/export', params, `nutrition_analysis_${new Date().getTime()}.xlsx`);
    },
    
    /** 生成建议 */
    generateAdvice() {
      this.loadNutritionAdvice();
    },
    
    initCharts() {
      this.$nextTick(() => {
        this.initTrendChart();
        this.initPieChart();
        this.initMealChart();
      });
    },
    
    initTrendChart() {
      this.trendChart = echarts.init(this.$refs.trendChart);
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        xAxis: {
          type: 'category',
          data: []
        },
        yAxis: {
          type: 'value'
        },
        series: [{
          name: '热量',
          type: 'line',
          smooth: true,
          data: []
        }]
      };
      this.trendChart.setOption(option);
    },
    
    initPieChart() {
      this.pieChart = echarts.init(this.$refs.pieChart);
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
            data: [
              { value: 0, name: '蛋白质' },
              { value: 0, name: '脂肪' },
              { value: 0, name: '碳水化合物' }
            ]
          }
        ]
      };
      this.pieChart.setOption(option);
    },
    
    initMealChart() {
      this.mealChart = echarts.init(this.$refs.mealChart);
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['早餐', '午餐', '晚餐', '加餐']
        },
        xAxis: {
          type: 'category',
          data: []
        },
        yAxis: {
          type: 'value'
        },
        series: [
          { name: '早餐', type: 'bar', stack: '总量', data: [] },
          { name: '午餐', type: 'bar', stack: '总量', data: [] },
          { name: '晚餐', type: 'bar', stack: '总量', data: [] },
          { name: '加餐', type: 'bar', stack: '总量', data: [] }
        ]
      };
      this.mealChart.setOption(option);
    },
    
    updateCharts() {
      if (this.analysisData.length === 0) return;
      
      this.updateTrendChart();
      this.updatePieChart();
      this.updateMealChart();
    },
    
    updateTrendChart() {
      if (!this.trendChart) return;
      
      const dates = this.analysisData.map(item => this.parseTime(item.date, '{m}-{d}'));
      let data = [];
      let name = '';
      
      switch (this.trendType) {
        case 'calories':
          data = this.analysisData.map(item => item.totalCalories);
          name = '热量(kcal)';
          break;
        case 'protein':
          data = this.analysisData.map(item => item.totalProtein);
          name = '蛋白质(g)';
          break;
        case 'fat':
          data = this.analysisData.map(item => item.totalFat);
          name = '脂肪(g)';
          break;
        case 'carb':
          data = this.analysisData.map(item => item.totalCarbohydrate);
          name = '碳水化合物(g)';
          break;
      }
      
      const option = {
        xAxis: {
          data: dates
        },
        series: [{
          name: name,
          data: data
        }]
      };
      
      this.trendChart.setOption(option);
    },
    
    updatePieChart() {
      if (!this.pieChart) return;
      
      const option = {
        series: [{
          data: [
            { value: this.nutritionSummary.avgProtein || 0, name: '蛋白质' },
            { value: this.nutritionSummary.avgFat || 0, name: '脂肪' },
            { value: this.nutritionSummary.avgCarbohydrate || 0, name: '碳水化合物' }
          ]
        }]
      };
      
      this.pieChart.setOption(option);
    },
    
    updateMealChart() {
      if (!this.mealChart) return;
      
      // 这里需要根据实际的餐次数据来更新
      // 示例数据，实际应该从API获取
      const dates = this.analysisData.map(item => this.parseTime(item.date, '{m}-{d}'));
      
      const option = {
        xAxis: {
          data: dates
        },
        series: [
          { name: '早餐', data: this.analysisData.map(() => Math.random() * 500 + 300) },
          { name: '午餐', data: this.analysisData.map(() => Math.random() * 600 + 400) },
          { name: '晚餐', data: this.analysisData.map(() => Math.random() * 600 + 400) },
          { name: '加餐', data: this.analysisData.map(() => Math.random() * 200 + 100) }
        ]
      };
      
      this.mealChart.setOption(option);
    },
    
    changeTrendType(type) {
      this.trendType = type;
      this.updateTrendChart();
    },
    
    getCompletionRate(actualCalories) {
      if (!this.targetCalories) return 0;
      return Math.min(100, Math.round((actualCalories / this.targetCalories) * 100));
    },
    
    getProgressColor(percentage) {
      if (percentage < 60) return '#F56C6C';
      if (percentage < 90) return '#E6A23C';
      return '#67C23A';
    },
    
    getAdviceIcon(type) {
      const icons = {
        'warning': 'el-icon-warning',
        'success': 'el-icon-success',
        'info': 'el-icon-info',
        'danger': 'el-icon-error'
      };
      return icons[type] || 'el-icon-info';
    },
    
    getAdviceTypeName(type) {
      const names = {
        'warning': '注意',
        'success': '良好',
        'info': '建议',
        'danger': '警告'
      };
      return names[type] || '提示';
    },
    
    formatDate(date) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    }
  }
};
</script>

<style scoped>
.nutrition-card {
  margin-bottom: 20px;
}

.card-content {
  display: flex;
  align-items: center;
}

.icon {
  font-size: 40px;
  margin-right: 15px;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
}

.calories .icon {
  background-color: #ff6b6b20;
  color: #ff6b6b;
}

.protein .icon {
  background-color: #4ecdc420;
  color: #4ecdc4;
}

.fat .icon {
  background-color: #ffe06620;
  color: #ffe066;
}

.carb .icon {
  background-color: #74b9ff20;
  color: #74b9ff;
}

.info .title {
  font-size: 14px;
  color: #999;
  margin-bottom: 5px;
}

.info .value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.info .subtitle {
  font-size: 12px;
  color: #666;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-card, .advice-card, .table-card {
  margin-bottom: 20px;
}

.advice-content {
  max-height: 320px;
  overflow-y: auto;
}

.advice-item {
  margin-bottom: 15px;
  padding: 10px;
  border-left: 3px solid #e6e6e6;
  background-color: #fafafa;
}

.advice-type {
  font-weight: bold;
  margin-bottom: 5px;
  display: flex;
  align-items: center;
}

.advice-type.warning {
  color: #E6A23C;
}

.advice-type.success {
  color: #67C23A;
}

.advice-type.info {
  color: #409EFF;
}

.advice-type.danger {
  color: #F56C6C;
}

.advice-type i {
  margin-right: 5px;
}

.advice-text {
  color: #666;
  line-height: 1.5;
}

.no-advice {
  text-align: center;
  padding: 40px 0;
}

@media (max-width: 768px) {
  .nutrition-card {
    margin-bottom: 10px;
  }
  
  .card-content {
    flex-direction: column;
    text-align: center;
  }
  
  .icon {
    margin-right: 0;
    margin-bottom: 10px;
  }
}
</style>
