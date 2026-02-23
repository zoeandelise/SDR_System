<template>
  <div class="app-container">
    <!-- 页面标题 -->
    <el-row class="mb20">
      <el-col :span="24">
        <el-alert
          title="🤖 AI智能推荐方案管理"
          type="success"
          description="查看和管理用户端生成的全天饮食方案，追踪方案执行情况"
          :closable="false"
          show-icon>
        </el-alert>
      </el-col>
    </el-row>

    <!-- 统计卡片 -->
    <el-row :gutter="15" class="mb20">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-document stat-icon" style="color: #409EFF"></i>
            <div>
              <div class="stat-value">{{ statistics.total }}</div>
              <div class="stat-label">总方案数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-user stat-icon" style="color: #67C23A"></i>
            <div>
              <div class="stat-value">{{ statistics.users }}</div>
              <div class="stat-label">推荐用户数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-check stat-icon" style="color: #67C23A"></i>
            <div>
              <div class="stat-value">{{ statistics.executed }}</div>
              <div class="stat-label">已执行</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <i class="el-icon-time stat-icon" style="color: #E6A23C"></i>
            <div>
              <div class="stat-value">{{ statistics.pending }}</div>
              <div class="stat-label">待执行</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索栏 -->
    <el-form :model="queryParams" ref="queryForm" :inline="true" size="small" class="mb20">
      <el-form-item label="用户">
        <el-input
          v-model="queryParams.userName"
          placeholder="用户名或ID"
          clearable
          style="width: 150px"
        />
      </el-form-item>
      <el-form-item label="日期范围">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="yyyy-MM-dd"
          style="width: 240px">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="queryParams.isAccepted" placeholder="全部" clearable style="width: 120px">
          <el-option label="已执行" value="1" />
          <el-option label="待执行" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 数据列表 -->
    <el-table v-loading="loading" :data="planList" style="width: 100%">
      <el-table-column type="index" label="序号" width="60" align="center" />
      
      <el-table-column label="推荐用户" width="120" align="center">
        <template slot-scope="scope">
          <el-tag type="primary" size="small">
            {{ scope.row.userName || 'ID:' + scope.row.userId }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="生成日期" width="120" align="center">
        <template slot-scope="scope">
          {{ parseTime(scope.row.recommendationDate, '{y}-{m}-{d}') }}
        </template>
      </el-table-column>
      
      <el-table-column label="方案类型" width="110" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.mealType === '9'" type="warning">
            <i class="el-icon-food"></i> 全天方案
          </el-tag>
          <el-tag v-else type="info">
            {{ getMealTypeName(scope.row.mealType) }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="推荐食物" min-width="300" show-overflow-tooltip>
        <template slot-scope="scope">
          <span style="color: #606266; font-size: 13px;">
            {{ scope.row.recommendedFoods }}
          </span>
        </template>
      </el-table-column>
      
      <el-table-column label="执行状态" width="100" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.isAccepted === '1'" type="success" size="small">
            <i class="el-icon-check"></i> 已执行
          </el-tag>
          <el-tag v-else type="info" size="small">
            <i class="el-icon-time"></i> 待执行
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="操作" width="180" align="center">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="primary"
            icon="el-icon-view"
            @click="handleViewDetail(scope.row)"
          >详情</el-button>
          <el-button
            size="mini"
            type="danger"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
          >删除</el-button>
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

    <!-- 详情对话框 -->
    <el-dialog title="推荐方案详情" :visible.sync="detailVisible" width="900px">
      <div v-if="currentPlan">
        <el-descriptions :column="2" border size="medium">
          <el-descriptions-item label="推荐用户">
            <el-tag type="primary">{{ currentPlan.userName || 'ID:' + currentPlan.userId }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="生成日期">
            {{ currentPlan.recommendationDate }}
          </el-descriptions-item>
          <el-descriptions-item label="方案类型">
            <el-tag v-if="currentPlan.mealType === '9'" type="warning">全天方案</el-tag>
            <el-tag v-else>{{ getMealTypeName(currentPlan.mealType) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="算法类型">
            <el-tag type="success">{{ currentPlan.algorithmType }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="执行状态" :span="2">
            <el-tag v-if="currentPlan.isAccepted === '1'" type="success">
              <i class="el-icon-check"></i> 已执行
            </el-tag>
            <el-tag v-else type="info">
              <i class="el-icon-time"></i> 待执行
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <div style="margin-top: 20px;">
          <h3 style="margin-bottom: 15px;">
            <i class="el-icon-food"></i> 推荐食物详情
          </h3>
          <div class="food-detail">
            {{ currentPlan.recommendedFoods }}
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listRecommendation, delRecommendation } from "@/api/diet/recommendation";
import { parseTime } from "@/utils/ruoyi";

export default {
  name: "DietRecommendationManagement",
  data() {
    return {
      loading: false,
      planList: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        isAccepted: null
      },
      dateRange: [],
      statistics: {
        total: 0,
        users: 0,
        executed: 0,
        pending: 0
      },
      detailVisible: false,
      currentPlan: null
    };
  },
  created() {
    this.getList();
  },
  methods: {
    parseTime,
    
    /** 查询列表 */
    getList() {
      this.loading = true;
      const params = { ...this.queryParams };
      if (this.dateRange && this.dateRange.length === 2) {
        params.startDate = this.dateRange[0];
        params.endDate = this.dateRange[1];
      }
      listRecommendation(params).then(response => {
        this.planList = response.rows || [];
        this.total = response.total || 0;
        this.calculateStatistics(this.planList);
      }).catch(() => {
        this.$message.error('加载失败');
      }).finally(() => {
        this.loading = false;
      });
    },
    
    /** 计算统计 */
    calculateStatistics(list) {
      this.statistics.total = list.length;
      this.statistics.users = new Set(list.map(r => r.userId)).size;
      this.statistics.executed = list.filter(r => r.isAccepted === '1').length;
      this.statistics.pending = list.filter(r => r.isAccepted !== '1').length;
    },
    
    /** 搜索 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    
    /** 重置 */
    handleReset() {
      this.queryParams = {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        isAccepted: null
      };
      this.dateRange = [];
      this.getList();
    },
    
    /** 查看详情 */
    handleViewDetail(row) {
      this.currentPlan = row;
      this.detailVisible = true;
    },
    
    /** 删除 */
    handleDelete(row) {
      this.$confirm('确定删除该推荐方案吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        delRecommendation(row.recommendationId).then(() => {
          this.$message.success('删除成功');
          this.getList();
        }).catch(() => {
          this.$message.error('删除失败');
        });
      });
    },
    
    /** 获取餐次名称 */
    getMealTypeName(mealType) {
      const names = {
        '0': '早餐',
        '1': '午餐',
        '2': '晚餐',
        '3': '加餐',
        '9': '全天方案'
      };
      return names[mealType] || '未知';
    }
  }
};
</script>

<style scoped>
.mb20 {
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 10px;
}

.stat-icon {
  font-size: 48px;
  margin-right: 20px;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  line-height: 1.2;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.food-detail {
  background-color: #f5f7fa;
  padding: 20px;
  border-radius: 8px;
  line-height: 1.8;
  font-size: 14px;
  white-space: pre-wrap;
  border-left: 4px solid #67C23A;
}
</style>
