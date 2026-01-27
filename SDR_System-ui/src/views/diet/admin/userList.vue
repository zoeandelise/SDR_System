<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :span="6" v-for="(stat, index) in statisticsCards" :key="index">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon">
              <i :class="stat.icon" :style="{ color: stat.color }"></i>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stat.value }}</div>
              <div class="stat-label">{{ stat.label }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索区域 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="日期范围" prop="dateRange">
        <el-date-picker
          v-model="queryParams.dateRange"
          style="width: 240px"
          value-format="yyyy-MM-dd"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
      </el-form-item>
      <el-form-item label="用户名" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="请输入用户名"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="用户状态" clearable>
          <el-option label="正常" value="0"/>
          <el-option label="停用" value="1"/>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-refresh"
          size="mini"
          @click="handleRefresh"
        >刷新统计</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExportAll"
        >导出全部</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 用户数据表格 -->
    <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="用户编号" align="center" prop="userId" width="80"/>
      <el-table-column label="用户名" align="center" prop="userName" :show-overflow-tooltip="true"/>
      <el-table-column label="昵称" align="center" prop="nickName" :show-overflow-tooltip="true"/>
      <el-table-column label="邮箱" align="center" prop="email" :show-overflow-tooltip="true"/>
      <el-table-column label="手机号" align="center" prop="phonenumber" width="120"/>
      <el-table-column label="性别" align="center" prop="sex" width="80">
        <template slot-scope="scope">
          <span v-if="scope.row.sex === '0'">男</span>
          <span v-else-if="scope.row.sex === '1'">女</span>
          <span v-else>未知</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" width="80">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
            {{ scope.row.status === '0' ? '正常' : '停用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="记录数量" align="center" prop="recordCount" width="100"/>
      <el-table-column label="平均热量" align="center" prop="avgCalories" width="100">
        <template slot-scope="scope">
          {{ scope.row.avgCalories ? scope.row.avgCalories.toFixed(1) : '0.0' }} kcal
        </template>
      </el-table-column>
      <el-table-column label="最后记录" align="center" prop="lastRecordDate" width="120">
        <template slot-scope="scope">
          <span v-if="scope.row.lastRecordDate">{{ parseTime(scope.row.lastRecordDate, '{y}-{m}-{d}') }}</span>
          <span v-else class="text-muted">无记录</span>
        </template>
      </el-table-column>
      <el-table-column label="最后登录" align="center" prop="loginDate" width="120">
        <template slot-scope="scope">
          <span v-if="scope.row.loginDate">{{ parseTime(scope.row.loginDate, '{y}-{m}-{d}') }}</span>
          <span v-else class="text-muted">从未登录</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="200">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleViewProfile(scope.row)"
          >画像</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-s-data"
            @click="handleViewData(scope.row)"
          >数据</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-download"
            @click="handleExportUser(scope.row)"
          >导出</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 用户画像对话框 -->
    <el-dialog title="用户健康画像" :visible.sync="profileDialogVisible" width="80%" append-to-body>
      <user-profile-card v-if="selectedUser" :user-data="selectedUser" :profile-data="userProfileData"/>
    </el-dialog>

    <!-- 用户数据对话框 -->
    <el-dialog title="用户饮食数据" :visible.sync="dataDialogVisible" width="90%" append-to-body>
      <user-data-tabs v-if="selectedUser" :user-id="selectedUser.userId" :user-name="selectedUser.userName"/>
    </el-dialog>
  </div>
</template>

<script>
import { getAllUsersRecordsOverview, getUserProfile, exportUserDietData } from "@/api/diet/admin";
import { parseTime } from "@/utils/ruoyi";
import UserProfileCard from './components/UserProfileCard';
import UserDataTabs from './components/UserDataTabs';

export default {
  name: "AdminUserList",
  components: {
    UserProfileCard,
    UserDataTabs
  },
  data() {
    return {
      // 遮罩层
      loading: true,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 用户列表
      userList: [],
      // 统计数据
      statistics: {},
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        status: null,
        dateRange: []
      },
      // 对话框
      profileDialogVisible: false,
      dataDialogVisible: false,
      selectedUser: null,
      userProfileData: {}
    };
  },
  computed: {
    statisticsCards() {
      return [
        {
          label: '总用户数',
          value: this.statistics.totalUsers || 0,
          icon: 'el-icon-user',
          color: '#409EFF'
        },
        {
          label: '今日活跃',
          value: this.statistics.activeUsersToday || 0,
          icon: 'el-icon-s-data',
          color: '#67C23A'
        },
        {
          label: '今日记录',
          value: this.statistics.totalRecordsToday || 0,
          icon: 'el-icon-document',
          color: '#E6A23C'
        },
        {
          label: '活跃率',
          value: this.statistics.userActivityRate ? this.statistics.userActivityRate.toFixed(1) + '%' : '0%',
          icon: 'el-icon-pie-chart',
          color: '#F56C6C'
        }
      ];
    }
  },
  created() {
    this.initDateRange();
    this.getList();
  },
  methods: {
    parseTime,
    
    /** 初始化日期范围 */
    initDateRange() {
      const end = new Date();
      const start = new Date();
      start.setDate(end.getDate() - 7); // 默认查询最近7天
      this.queryParams.dateRange = [this.parseTime(start, '{y}-{m}-{d}'), this.parseTime(end, '{y}-{m}-{d}')];
    },

    /** 查询用户列表 */
    getList() {
      this.loading = true;
      const startDate = this.queryParams.dateRange && this.queryParams.dateRange[0] ? this.queryParams.dateRange[0] : null;
      const endDate = this.queryParams.dateRange && this.queryParams.dateRange[1] ? this.queryParams.dateRange[1] : null;
      
      getAllUsersRecordsOverview({
        startDate: startDate,
        endDate: endDate
      }).then(response => {
        this.userList = response.data.users || [];
        this.statistics = response.data.statistics || {};
        this.total = this.userList.length;
        this.loading = false;
      }).catch(() => {
        this.loading = false;
      });
    },

    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },

    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.initDateRange();
      this.handleQuery();
    },

    /** 刷新统计 */
    handleRefresh() {
      this.getList();
      this.$message.success("统计数据已刷新");
    },

    /** 多选框选中数据 */
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.userId);
      this.single = selection.length !== 1;
      this.multiple = !selection.length;
    },

    /** 查看用户画像 */
    handleViewProfile(user) {
      this.selectedUser = user;
      getUserProfile(user.userId).then(response => {
        this.userProfileData = response.data;
        this.profileDialogVisible = true;
      });
    },

    /** 查看用户数据 */
    handleViewData(user) {
      this.selectedUser = user;
      this.dataDialogVisible = true;
    },

    /** 导出用户数据 */
    handleExportUser(user) {
      this.$modal.confirm('是否确认导出用户"' + user.userName + '"的饮食数据？').then(() => {
        const startDate = this.queryParams.dateRange && this.queryParams.dateRange[0] ? this.queryParams.dateRange[0] : null;
        const endDate = this.queryParams.dateRange && this.queryParams.dateRange[1] ? this.queryParams.dateRange[1] : null;
        
        return exportUserDietData(user.userId, {
          startDate: startDate,
          endDate: endDate
        });
      }).then(() => {
        this.$modal.msgSuccess("导出成功");
      });
    },

    /** 导出全部数据 */
    handleExportAll() {
      this.$modal.confirm('是否确认导出所有用户的饮食数据？').then(() => {
        // 这里可以实现批量导出逻辑
        this.$modal.msgSuccess("导出功能正在开发中");
      });
    }
  }
};
</script>

<style lang="scss" scoped>
.stat-card {
  margin-bottom: 20px;
  
  .stat-content {
    display: flex;
    align-items: center;
    
    .stat-icon {
      margin-right: 15px;
      
      i {
        font-size: 40px;
      }
    }
    
    .stat-info {
      .stat-value {
        font-size: 24px;
        font-weight: bold;
        color: #303133;
      }
      
      .stat-label {
        font-size: 14px;
        color: #909399;
        margin-top: 5px;
      }
    }
  }
}

.text-muted {
  color: #909399;
}
</style>
