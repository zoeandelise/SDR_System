<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="用户搜索" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="输入用户名或ID"
          clearable
          @keyup.enter.native="handleQuery"
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item label="记录日期" prop="recordDate">
        <el-date-picker clearable
          v-model="queryParams.recordDate"
          type="date"
          value-format="yyyy-MM-dd"
          placeholder="请选择记录日期">
        </el-date-picker>
      </el-form-item>
      <el-form-item label="餐次类型" prop="mealType">
        <el-select v-model="queryParams.mealType" placeholder="请选择餐次类型" clearable>
          <el-option
            v-for="dict in dict.type.diet_meal_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
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
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['diet:record:export']"
        >导出全站记录</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['diet:record:remove']"
        >批量清理</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="recordList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="用户" align="center" prop="userName" width="120">
        <template slot-scope="scope">
          <el-tag type="info" size="small">
            {{ scope.row.userName || 'ID:' + scope.row.userId }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="记录日期" align="center" prop="recordDate" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.recordDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="餐次类型" align="center" prop="mealType">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.diet_meal_type" :value="scope.row.mealType"/>
        </template>
      </el-table-column>
      <el-table-column label="总热量(kcal)" align="center" prop="totalCalories" />
      <el-table-column label="蛋白质(g)" align="center" prop="totalProtein" />
      <el-table-column label="脂肪(g)" align="center" prop="totalFat" />
      <el-table-column label="碳水化合物(g)" align="center" prop="totalCarbohydrate" />
      <el-table-column label="食物照片" align="center" prop="imageUrls" width="100">
        <template slot-scope="scope">
          <el-image
            v-if="scope.row.imageUrls"
            style="width: 50px; height: 50px"
            :src="getFirstImage(scope.row.imageUrls)"
            :preview-src-list="getImageList(scope.row.imageUrls)"
            fit="cover"
          ></el-image>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="notes" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleDetail(scope.row)"
            v-hasPermi="['diet:record:query']"
          >详情</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['diet:record:remove']"
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



    <!-- 详情对话框 -->
    <el-dialog title="饮食记录详情" :visible.sync="detailDialogVisible" width="800px">
      <div v-if="currentRecord" class="record-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="记录日期">
            {{ parseTime(currentRecord.recordDate, '{y}-{m}-{d}') }}
          </el-descriptions-item>
          <el-descriptions-item label="餐次类型">
            <dict-tag :options="dict.type.diet_meal_type" :value="currentRecord.mealType"/>
          </el-descriptions-item>
          <el-descriptions-item label="总热量">
            {{ currentRecord.totalCalories }} kcal
          </el-descriptions-item>
          <el-descriptions-item label="总蛋白质">
            {{ currentRecord.totalProtein }} g
          </el-descriptions-item>
          <el-descriptions-item label="总脂肪">
            {{ currentRecord.totalFat }} g
          </el-descriptions-item>
          <el-descriptions-item label="总碳水化合物">
            {{ currentRecord.totalCarbohydrate }} g
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">
            {{ currentRecord.notes || '无' }}
          </el-descriptions-item>
        </el-descriptions>
        
        <!-- 食物照片 -->
        <div v-if="currentRecord.imageUrls" class="food-images" style="margin-top: 20px;">
          <h4>食物照片：</h4>
          <el-image
            v-for="(image, index) in getImageList(currentRecord.imageUrls)"
            :key="index"
            style="width: 100px; height: 100px; margin-right: 10px;"
            :src="image"
            :preview-src-list="getImageList(currentRecord.imageUrls)"
            fit="cover"
          ></el-image>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>


  </div>
</template>

<script>
import { 
  listRecord, delRecord
} from "@/api/diet/record";

export default {
  name: "DietRecord",
  dicts: ['diet_meal_type'],
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
      // 饮食记录表格数据
      recordList: [],
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        recordDate: null,
        mealType: null
      },
      // 详情对话框
      detailDialogVisible: false,
      currentRecord: null
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询饮食记录列表 */
    getList() {
      this.loading = true;
      listRecord(this.queryParams).then(response => {
        this.recordList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    // 详情对话框重置
    reset() {
      // 保留空壳防错
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
      this.ids = selection.map(item => item.recordId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const recordIds = row.recordId || this.ids;
      this.$modal.confirm('是否确认删除这 ' + (row.recordId ? '1' : this.ids.length) + ' 条饮食记录数据？').then(function() {
        return delRecord(recordIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("处理成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('diet/record/export', {
        ...this.queryParams
      }, `record_${new Date().getTime()}.xlsx`)
    },
    /** 查看全局详情 */
    handleDetail(row) {
      this.currentRecord = row;
      this.detailDialogVisible = true;
    },
    getFirstImage(imageUrls) {
      if (!imageUrls) return '';
      const urls = imageUrls.split(',');
      return this.getImageUrl(urls[0]);
    },
    getImageList(imageUrls) {
      if (!imageUrls) return [];
      return imageUrls.split(',').map(url => this.getImageUrl(url));
    },
    getImageUrl(url) {
      if (!url) return '';
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
      const baseApi = process.env.VUE_APP_BASE_API || '/dev-api';
      return baseApi + url;
    }
  }
};
</script>

<style scoped>
</style>

.food-images {
  text-align: left;
}
</style>
