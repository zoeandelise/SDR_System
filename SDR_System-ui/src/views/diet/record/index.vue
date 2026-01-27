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
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['diet:record:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-camera-solid"
          size="mini"
          @click="handleRecognition"
          v-hasPermi="['diet:record:add']"
        >拍照识别</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="info"
          plain
          icon="el-icon-s-data"
          size="mini"
          @click="handleStatistics"
        >营养统计</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-upload2"
          size="mini"
          @click="handleImport"
          v-hasPermi="['diet:record:import']"
        >导入</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['diet:record:export']"
        >导出</el-button>
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
            icon="el-icon-s-operation"
            @click="handleCalculateNutrition(scope.row)"
            v-hasPermi="['diet:record:edit']"
          >重算营养</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['diet:record:edit']"
          >修改</el-button>
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

    <!-- 添加或修改饮食记录对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="记录日期" prop="recordDate">
              <el-date-picker clearable
                v-model="form.recordDate"
                type="date"
                value-format="yyyy-MM-dd"
                placeholder="请选择记录日期">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="餐次类型" prop="mealType">
              <el-select v-model="form.mealType" placeholder="请选择餐次类型">
                <el-option
                  v-for="dict in dict.type.diet_meal_type"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8">
            <el-form-item label="总热量" prop="totalCalories">
              <el-input v-model="form.totalCalories" placeholder="请输入总热量" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="总蛋白质" prop="totalProtein">
              <el-input v-model="form.totalProtein" placeholder="请输入总蛋白质" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="总脂肪" prop="totalFat">
              <el-input v-model="form.totalFat" placeholder="请输入总脂肪" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="总碳水" prop="totalCarbohydrate">
              <el-input v-model="form.totalCarbohydrate" placeholder="请输入总碳水化合物" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="食物照片" prop="imageUrls">
              <image-upload 
                v-model="form.imageUrls"
                :file-type="['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']"
                :file-size="10"
                action="/common/upload"
                :limit="5"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="notes">
          <el-input v-model="form.notes" type="textarea" placeholder="请输入内容" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 食物识别对话框 -->
    <el-dialog title="拍照识别食物" :visible.sync="recognitionDialogVisible" width="600px">
      <div class="recognition-content">
        <el-upload
          class="upload-demo"
          drag
          :action="uploadAction"
          :before-upload="beforeUpload"
          :on-success="handleRecognitionSuccess"
          :on-error="handleRecognitionError"
          :show-file-list="false"
          accept="image/*"
        >
          <i class="el-icon-upload"></i>
          <div class="el-upload__text">将图片拖到此处，或<em>点击上传</em></div>
          <div class="el-upload__tip" slot="tip">只能上传jpg/png文件，且不超过10MB</div>
        </el-upload>
        
        <!-- 识别结果 -->
        <div v-if="recognitionResult" class="recognition-result">
          <h4>识别结果：</h4>
          <el-table :data="recognitionResult.recognizedFoods" style="width: 100%">
            <el-table-column prop="foodName" label="食物名称" width="180"></el-table-column>
            <el-table-column prop="confidence" label="置信度" width="100">
              <template slot-scope="scope">
                {{ (scope.row.confidence * 100).toFixed(1) }}%
              </template>
            </el-table-column>
            <el-table-column prop="estimatedWeight" label="估计重量(g)" width="120"></el-table-column>
            <el-table-column label="操作">
              <template slot-scope="scope">
                <el-button size="mini" @click="addRecognizedFood(scope.row)">添加到记录</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="recognitionDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>

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

    <!-- 营养统计对话框 -->
    <el-dialog title="营养统计报告" :visible.sync="statisticsDialogVisible" width="900px">
      <div class="statistics-content">
        <el-form :inline="true" class="mb20">
          <el-form-item label="统计时间">
            <el-date-picker
              v-model="statisticsDateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="yyyy-MM-dd"
              @change="loadStatistics"
            />
          </el-form-item>
        </el-form>
        
        <div v-if="statisticsData" class="statistics-data">
          <el-row :gutter="20" class="mb20">
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-item">
                  <div class="stat-value">{{ statisticsData.totalRecords }}</div>
                  <div class="stat-label">总记录数</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-item">
                  <div class="stat-value">{{ Math.round(statisticsData.avgDailyCalories || 0) }}</div>
                  <div class="stat-label">平均每日热量(kcal)</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-item">
                  <div class="stat-value">{{ Math.round(statisticsData.avgDailyProtein || 0) }}</div>
                  <div class="stat-label">平均每日蛋白质(g)</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-item">
                  <div class="stat-value">{{ Math.round(statisticsData.avgDailyFat || 0) }}</div>
                  <div class="stat-label">平均每日脂肪(g)</div>
                </div>
              </el-card>
            </el-col>
          </el-row>
          
          <!-- 营养趋势图 -->
          <el-card class="chart-card">
            <div slot="header">营养摄入趋势</div>
            <div id="nutritionTrendChart" style="height: 300px;"></div>
          </el-card>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="statisticsDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>

    <!-- 导入对话框 -->
    <el-dialog title="批量导入饮食记录" :visible.sync="importDialogVisible" width="500px">
      <div class="import-content">
        <div class="mb20">
          <el-button type="primary" @click="downloadImportTemplate">下载导入模板</el-button>
        </div>
        
        <el-upload
          class="upload-demo"
          :action="uploadAction.replace('/recognize', '/import')"
          :file-list="importFileList"
          :on-success="handleImportSuccess"
          :on-error="handleImportError"
          :before-upload="beforeUploadExcel"
          accept=".xlsx,.xls"
          :limit="1"
        >
          <el-button size="small" type="primary">点击上传</el-button>
          <div slot="tip" class="el-upload__tip">只能上传xlsx/xls文件，且不超过10MB</div>
        </el-upload>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="importDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { 
  listRecord, getRecord, delRecord, addRecord, updateRecord, recognizeFood,
  getRecordDetail, calculateNutrition, getStatisticsReport, createByFoods,
  importRecords, downloadTemplate
} from "@/api/diet/record";
import ImageUpload from "@/components/ImageUpload/index.vue";

export default {
  name: "DietRecord",
  dicts: ['diet_meal_type'],
  components: {
    ImageUpload
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
      // 饮食记录表格数据
      recordList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: null,
        recordDate: null,
        mealType: null
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        recordDate: [
          { required: true, message: "记录日期不能为空", trigger: "blur" }
        ],
        mealType: [
          { required: true, message: "餐次类型不能为空", trigger: "change" }
        ],
      },
      // 识别对话框
      recognitionDialogVisible: false,
      recognitionResult: null,
      uploadAction: process.env.VUE_APP_BASE_API + '/diet/record/recognize',
      // 详情对话框
      detailDialogVisible: false,
      currentRecord: null,
      recordDetail: null,
      // 统计对话框
      statisticsDialogVisible: false,
      statisticsData: null,
      statisticsDateRange: [],
      // 导入对话框
      importDialogVisible: false,
      importFileList: []
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
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        recordId: null,
        recordDate: null,
        mealType: null,
        totalCalories: null,
        totalProtein: null,
        totalFat: null,
        totalCarbohydrate: null,
        imageUrls: null,
        notes: null
      };
      this.$nextTick(() => {
        if (this.$refs.form) {
          this.resetForm("form");
        }
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
      this.ids = selection.map(item => item.recordId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加饮食记录";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const recordId = row.recordId || this.ids
      getRecord(recordId).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改饮食记录";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.recordId != null) {
            updateRecord(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addRecord(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const recordIds = row.recordId || this.ids;
      this.$modal.confirm('是否确认删除饮食记录编号为"' + recordIds + '"的数据项？').then(function() {
        return delRecord(recordIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('diet/record/export', {
        ...this.queryParams
      }, `record_${new Date().getTime()}.xlsx`)
    },
    /** 拍照识别 */
    handleRecognition() {
      this.recognitionDialogVisible = true;
      this.recognitionResult = null;
    },
    /** 查看详情 */
    handleDetail(row) {
      this.currentRecord = row;
      this.detailDialogVisible = true;
    },
    beforeUpload(file) {
      const isImage = file.type.indexOf('image/') === 0;
      const isLt10M = file.size / 1024 / 1024 < 10;

      if (!isImage) {
        this.$modal.msgError('只能上传图片文件!');
        return false;
      }
      if (!isLt10M) {
        this.$modal.msgError('图片大小不能超过 10MB!');
        return false;
      }
      return true;
    },
    handleRecognitionSuccess(response) {
      if (response.code === 200) {
        this.recognitionResult = response.data;
        this.$modal.msgSuccess('识别成功');
      } else {
        this.$modal.msgError(response.msg || '识别失败');
      }
    },
    handleRecognitionError() {
      this.$modal.msgError('识别失败，请重试');
    },
    addRecognizedFood(food) {
      // 将识别的食物添加到记录表单中
      this.recognitionDialogVisible = false;
      this.reset();
      this.form.recordDate = this.parseTime(new Date(), '{y}-{m}-{d}');
      // 这里需要根据识别结果填充营养信息
      this.open = true;
      this.title = "添加饮食记录";
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
      if (!url) return ''
      
      // 如果已经是完整URL，直接返回
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url
      }
      
      // 如果是相对路径，加上baseUrl
      const baseApi = process.env.VUE_APP_BASE_API || '/dev-api'
      return baseApi + url
    },
    /** 重新计算营养信息 */
    handleCalculateNutrition(row) {
      this.$modal.confirm('是否重新计算该记录的营养信息？').then(() => {
        calculateNutrition(row.recordId).then(response => {
          this.$modal.msgSuccess("营养信息计算成功");
          this.getList();
        });
      }).catch(() => {});
    },
    /** 营养统计 */
    handleStatistics() {
      this.statisticsDateRange = [
        this.parseTime(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), '{y}-{m}-{d}'),
        this.parseTime(new Date(), '{y}-{m}-{d}')
      ];
      this.loadStatistics();
      this.statisticsDialogVisible = true;
    },
    loadStatistics() {
      if (this.statisticsDateRange.length === 2) {
        getStatisticsReport(this.statisticsDateRange[0], this.statisticsDateRange[1]).then(response => {
          this.statisticsData = response.data;
        });
      }
    },
    /** 导入数据 */
    handleImport() {
      this.importDialogVisible = true;
      this.importFileList = [];
    },
    /** 下载导入模板 */
    downloadImportTemplate() {
      downloadTemplate().then(response => {
        const blob = new Blob([response], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = '饮食记录导入模板.xlsx';
        link.click();
        window.URL.revokeObjectURL(url);
      });
    },
    /** 处理导入文件 */
    handleImportSuccess(response) {
      if (response.code === 200) {
        this.$modal.msgSuccess(response.msg || "导入成功");
        this.importDialogVisible = false;
        this.getList();
      } else {
        this.$modal.msgError(response.msg || "导入失败");
      }
    },
    handleImportError() {
      this.$modal.msgError("导入失败，请重试");
    },
    beforeUploadExcel(file) {
      const isExcel = file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || 
                      file.type === 'application/vnd.ms-excel';
      const isLt10M = file.size / 1024 / 1024 < 10;

      if (!isExcel) {
        this.$modal.msgError('只能上传Excel文件!');
        return false;
      }
      if (!isLt10M) {
        this.$modal.msgError('文件大小不能超过 10MB!');
        return false;
      }
      return true;
    }
  }
};
</script>

<style scoped>
.recognition-content {
  text-align: center;
}

.recognition-result {
  margin-top: 20px;
  text-align: left;
}

.stat-card {
  text-align: center;
}

.stat-item {
  padding: 10px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.chart-card {
  margin-top: 20px;
}

.mb20 {
  margin-bottom: 20px;
}

.statistics-data {
  margin-top: 20px;
}

.record-detail {
  padding: 20px;
}

.food-images {
  text-align: left;
}
</style>
