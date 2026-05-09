<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="用户账号" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="请输入用户账号"
          clearable
          size="small"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="餐次类型" prop="mealType">
        <el-select v-model="queryParams.mealType" placeholder="请选择餐次" clearable size="small">
          <el-option label="早餐" value="breakfast" />
          <el-option label="午餐" value="lunch" />
          <el-option label="晚餐" value="dinner" />
        </el-select>
      </el-form-item>
      <el-form-item label="打卡心情" prop="mood">
        <el-select v-model="queryParams.mood" placeholder="请选择心情" clearable size="small">
          <el-option label="超棒" value="great" />
          <el-option label="不错" value="good" />
          <el-option label="一般" value="normal" />
          <el-option label="不太好" value="bad" />
        </el-select>
      </el-form-item>
      <el-form-item label="打卡日期" prop="checkinDate">
        <el-date-picker clearable size="small"
          v-model="queryParams.checkinDate"
          type="date"
          value-format="yyyy-MM-dd"
          placeholder="选择打卡日期">
        </el-date-picker>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['diet:checkin:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['diet:checkin:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="checkinList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="打卡ID" align="center" prop="checkinId" />
      <el-table-column label="用户账号" align="center" prop="userName" />
      <el-table-column label="打卡日期" align="center" prop="checkinDate" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.checkinDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="餐次类型" align="center" prop="mealType">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.mealType === 'breakfast'" type="success">早餐</el-tag>
          <el-tag v-else-if="scope.row.mealType === 'lunch'" type="warning">午餐</el-tag>
          <el-tag v-else-if="scope.row.mealType === 'dinner'" type="info">晚餐</el-tag>
          <el-tag v-else>{{scope.row.mealType}}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="打卡心情" align="center" prop="mood">
        <template slot-scope="scope">
          <span v-if="scope.row.mood === 'great'">😄 超棒</span>
          <span v-else-if="scope.row.mood === 'good'">😊 不错</span>
          <span v-else-if="scope.row.mood === 'normal'">😐 一般</span>
          <span v-else-if="scope.row.mood === 'bad'">😔 不太好</span>
          <span v-else>{{scope.row.mood}}</span>
        </template>
      </el-table-column>
      <el-table-column label="打卡心得" align="center" prop="notes" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['diet:checkin:remove']"
          >删除</el-button>
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
  </div>
</template>

<script>
import { listCheckin, getCheckin, delCheckin, exportCheckin } from "@/api/diet/checkin";

export default {
  name: "Checkin",
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
      // 饮食打卡记录表格数据
      checkinList: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        checkinDate: null,
        mealType: null,
        mood: null
      }
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询饮食打卡记录列表 */
    getList() {
      this.loading = true;
      listCheckin(this.queryParams).then(response => {
        this.checkinList = response.rows;
        this.total = response.total;
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
      this.handleQuery();
    },
    // 多选框选中数据
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.checkinId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const checkinIds = row.checkinId || this.ids;
      this.$modal.confirm('是否确认删除饮食打卡记录编号为"' + checkinIds + '"的数据项？').then(function() {
        return delCheckin(checkinIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      const queryParams = this.queryParams;
      this.$modal.confirm('是否确认导出所有饮食打卡记录数据项？').then(() => {
        return exportCheckin(queryParams);
      }).then(response => {
        this.download(response.msg);
      }).catch(() => {});
    }
  }
};
</script>
