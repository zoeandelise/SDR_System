<template>
  <div class="app-container">
    <el-alert
      title="用户健康信息管理"
      type="info"
      description="查看和管理所有用户的健康信息，包括基本信息、健康目标、营养目标等"
      :closable="false"
      show-icon
      class="mb20">
    </el-alert>

    <!-- 搜索 -->
    <el-form :model="queryParams" ref="queryForm" :inline="true" size="small">
      <el-form-item label="用户">
        <el-input
          v-model="queryParams.userName"
          placeholder="用户名或ID"
          clearable
          style="width: 180px"
        />
      </el-form-item>
      <el-form-item label="健康目标">
        <el-select v-model="queryParams.healthGoal" placeholder="全部" clearable>
          <el-option label="减脂" value="0" />
          <el-option label="增肌" value="1" />
          <el-option label="保持" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="userList">
      <el-table-column label="用户" width="120" align="center">
        <template slot-scope="scope">
          <el-tag type="primary">{{ scope.row.userName }}</el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="性别/年龄" width="100" align="center">
        <template slot-scope="scope">
          {{ scope.row.gender === '0' ? '男' : '女' }} / {{ scope.row.age }}岁
        </template>
      </el-table-column>
      
      <el-table-column label="身高/体重" width="120" align="center">
        <template slot-scope="scope">
          {{ scope.row.height }}cm / {{ scope.row.weight }}kg
        </template>
      </el-table-column>
      
      <el-table-column label="健康目标" width="100" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.healthGoal === '0'" type="danger">🔥 减脂</el-tag>
          <el-tag v-else-if="scope.row.healthGoal === '1'" type="success">💪 增肌</el-tag>
          <el-tag v-else type="info">⚖️ 保持</el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="每日热量目标" width="120" align="center">
        <template slot-scope="scope">
          {{ scope.row.dailyCalorieGoal }} kcal
        </template>
      </el-table-column>
      
      <el-table-column label="蛋白质/碳水/脂肪" width="180" align="center">
        <template slot-scope="scope">
          {{ scope.row.dailyProteinGoal }}g / {{ scope.row.dailyCarbGoal }}g / {{ scope.row.dailyFatGoal }}g
        </template>
      </el-table-column>
      
      <el-table-column label="疾病史" show-overflow-tooltip>
        <template slot-scope="scope">
          {{ scope.row.diseases || '无' }}
        </template>
      </el-table-column>
      
      <el-table-column label="过敏源" show-overflow-tooltip>
        <template slot-scope="scope">
          {{ scope.row.allergies || '无' }}
        </template>
      </el-table-column>
      
      <el-table-column label="操作" width="150" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="primary" @click="handleView(scope.row)">详情</el-button>
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
    <el-dialog title="用户健康信息详情" :visible.sync="detailVisible" width="900px">
      <div v-if="currentUser">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户名">{{ currentUser.userName }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ currentUser.userId }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ currentUser.gender === '0' ? '男' : '女' }}</el-descriptions-item>
          <el-descriptions-item label="年龄">{{ currentUser.age }} 岁</el-descriptions-item>
          <el-descriptions-item label="身高">{{ currentUser.height }} cm</el-descriptions-item>
          <el-descriptions-item label="体重">{{ currentUser.weight }} kg</el-descriptions-item>
          <el-descriptions-item label="目标体重">{{ currentUser.targetWeight || '-' }} kg</el-descriptions-item>
          <el-descriptions-item label="健康目标">
            <el-tag v-if="currentUser.healthGoal === '0'" type="danger">减脂</el-tag>
            <el-tag v-else-if="currentUser.healthGoal === '1'" type="success">增肌</el-tag>
            <el-tag v-else type="info">保持</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="每日热量目标">{{ currentUser.dailyCalorieGoal }} kcal</el-descriptions-item>
          <el-descriptions-item label="每日蛋白质目标">{{ currentUser.dailyProteinGoal }} g</el-descriptions-item>
          <el-descriptions-item label="每日碳水目标">{{ currentUser.dailyCarbGoal }} g</el-descriptions-item>
          <el-descriptions-item label="每日脂肪目标">{{ currentUser.dailyFatGoal }} g</el-descriptions-item>
          <el-descriptions-item label="疾病史" :span="2">{{ currentUser.diseases || '无' }}</el-descriptions-item>
          <el-descriptions-item label="过敏源" :span="2">{{ currentUser.allergies || '无' }}</el-descriptions-item>
          <el-descriptions-item label="饮食偏好" :span="2">{{ currentUser.dietPreferences || '无' }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: "UserHealthList",
  data() {
    return {
      loading: false,
      userList: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        healthGoal: null
      },
      detailVisible: false,
      currentUser: null
    };
  },
  created() {
    this.getList();
  },
  methods: {
    async getList() {
      this.loading = true;
      try {
        const response = await axios.get('http://localhost:8080/diet/health/all', {
          params: this.queryParams,
          headers: { 'Authorization': 'Bearer ' + this.$store.getters.token }
        });
        
        if (response.data.code === 200) {
          this.userList = response.data.rows || [];
          this.total = response.data.total || 0;
        }
      } catch (error) {
        this.$message.error('加载失败');
      } finally {
        this.loading = false;
      }
    },
    
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    
    handleReset() {
      this.queryParams = {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        healthGoal: null
      };
      this.getList();
    },
    
    handleView(row) {
      this.currentUser = row;
      this.detailVisible = true;
    }
  }
};
</script>

<style scoped>
.mb20 {
  margin-bottom: 20px;
}
</style>

