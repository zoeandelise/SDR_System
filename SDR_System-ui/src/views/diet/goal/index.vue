<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="目标类型" prop="goalType">
        <el-select v-model="queryParams.goalType" placeholder="请选择目标类型" clearable>
          <el-option
            v-for="dict in dict.type.diet_goal_type"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option
            v-for="dict in dict.type.goal_status"
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
          v-hasPermi="['diet:goal:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['diet:goal:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['diet:goal:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 目标概览卡片 -->
    <el-row :gutter="20" class="mb8" v-if="goalSummary">
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="goal-card active">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-trophy"></i>
            </div>
            <div class="info">
              <div class="title">进行中</div>
              <div class="value">{{ goalSummary.activeGoals || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="goal-card completed">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-success"></i>
            </div>
            <div class="info">
              <div class="title">已完成</div>
              <div class="value">{{ goalSummary.completedGoals || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="goal-card paused">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-video-pause"></i>
            </div>
            <div class="info">
              <div class="title">已暂停</div>
              <div class="value">{{ goalSummary.pausedGoals || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" :lg="6" :xl="6">
        <el-card class="goal-card progress">
          <div class="card-content">
            <div class="icon">
              <i class="el-icon-odometer"></i>
            </div>
            <div class="info">
              <div class="title">平均进度</div>
              <div class="value">{{ goalSummary.avgProgress || 0 }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-table v-loading="loading" :data="goalList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="目标名称" align="center" prop="goalName" />
      <el-table-column label="目标类型" align="center" prop="goalType">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.diet_goal_type" :value="scope.row.goalType"/>
        </template>
      </el-table-column>
      <el-table-column label="目标值" align="center" prop="targetValue" />
      <el-table-column label="当前值" align="center" prop="currentValue" />
      <el-table-column label="进度" align="center" prop="progress" width="150">
        <template slot-scope="scope">
          <el-progress 
            :percentage="scope.row.progress" 
            :color="getProgressColor(scope.row.progress)"
            :stroke-width="8"
          ></el-progress>
        </template>
      </el-table-column>
      <el-table-column label="开始日期" align="center" prop="startDate" width="120">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.startDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="目标日期" align="center" prop="targetDate" width="120">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.targetDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.goal_status" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleDetail(scope.row)"
            v-hasPermi="['diet:goal:query']"
          >详情</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['diet:goal:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-refresh"
            @click="handleUpdateProgress(scope.row)"
            v-hasPermi="['diet:goal:edit']"
          >更新进度</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['diet:goal:remove']"
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

    <!-- 添加或修改健康目标对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="600px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="目标名称" prop="goalName">
          <el-input v-model="form.goalName" placeholder="请输入目标名称" />
        </el-form-item>
        <el-form-item label="目标类型" prop="goalType">
          <el-select v-model="form.goalType" placeholder="请选择目标类型" style="width: 100%">
            <el-option
              v-for="dict in dict.type.diet_goal_type"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="目标值" prop="targetValue">
              <el-input-number v-model="form.targetValue" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="单位" prop="unit">
              <el-input v-model="form.unit" placeholder="如：kg、%、次" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="开始日期" prop="startDate">
              <el-date-picker
                v-model="form.startDate"
                type="date"
                value-format="yyyy-MM-dd"
                placeholder="请选择开始日期"
                style="width: 100%"
              >
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="目标日期" prop="targetDate">
              <el-date-picker
                v-model="form.targetDate"
                type="date"
                value-format="yyyy-MM-dd"
                placeholder="请选择目标日期"
                style="width: 100%"
              >
              </el-date-picker>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="当前值" prop="currentValue">
          <el-input-number v-model="form.currentValue" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio
              v-for="dict in dict.type.goal_status"
              :key="dict.value"
              :label="dict.value"
            >{{dict.label}}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入目标描述" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 更新进度对话框 -->
    <el-dialog title="更新目标进度" :visible.sync="progressDialogVisible" width="400px">
      <el-form ref="progressForm" :model="progressForm" :rules="progressRules" label-width="100px">
        <el-form-item label="当前值" prop="currentValue">
          <el-input-number 
            v-model="progressForm.currentValue" 
            :min="0" 
            :precision="2" 
            style="width: 100%" 
            placeholder="请输入当前值"
          />
        </el-form-item>
        <el-form-item label="备注" prop="notes">
          <el-input 
            v-model="progressForm.notes" 
            type="textarea" 
            placeholder="请输入更新说明" 
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="progressDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="submitProgressUpdate">确 定</el-button>
      </div>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog title="健康目标详情" :visible.sync="detailDialogVisible" width="700px">
      <div v-if="currentGoal" class="goal-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="目标名称">{{ currentGoal.goalName }}</el-descriptions-item>
          <el-descriptions-item label="目标类型">
            <dict-tag :options="dict.type.diet_goal_type" :value="currentGoal.goalType"/>
          </el-descriptions-item>
          <el-descriptions-item label="目标值">{{ currentGoal.targetValue }} {{ currentGoal.unit }}</el-descriptions-item>
          <el-descriptions-item label="当前值">{{ currentGoal.currentValue }} {{ currentGoal.unit }}</el-descriptions-item>
          <el-descriptions-item label="完成进度">
            <el-progress 
              :percentage="currentGoal.progress" 
              :color="getProgressColor(currentGoal.progress)"
              :stroke-width="8"
            ></el-progress>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <dict-tag :options="dict.type.goal_status" :value="currentGoal.status"/>
          </el-descriptions-item>
          <el-descriptions-item label="开始日期">
            {{ parseTime(currentGoal.startDate, '{y}-{m}-{d}') }}
          </el-descriptions-item>
          <el-descriptions-item label="目标日期">
            {{ parseTime(currentGoal.targetDate, '{y}-{m}-{d}') }}
          </el-descriptions-item>
          <el-descriptions-item label="剩余天数">
            {{ getRemainingDays(currentGoal.targetDate) }} 天
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">
            {{ parseTime(currentGoal.createTime, '{y}-{m}-{d} {h}:{i}:{s}') }}
          </el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">
            {{ currentGoal.description || '无' }}
          </el-descriptions-item>
        </el-descriptions>
        
        <!-- 进度历史图表 -->
        <div class="progress-chart" style="margin-top: 20px;">
          <h4>进度历史</h4>
          <div ref="progressChart" style="height: 300px;"></div>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="handleUpdateProgress(currentGoal)">更新进度</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listGoal, getGoal, delGoal, addGoal, updateGoal, updateGoalProgress, getGoalSummary } from "@/api/diet/goal";
import * as echarts from 'echarts';

export default {
  name: "DietGoal",
  dicts: ['diet_goal_type', 'goal_status'],
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
      // 健康目标表格数据
      goalList: [],
      // 目标概览数据
      goalSummary: null,
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 进度更新对话框
      progressDialogVisible: false,
      // 详情对话框
      detailDialogVisible: false,
      currentGoal: null,
      progressChart: null,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        goalType: null,
        status: null
      },
      // 表单参数
      form: {},
      // 进度更新表单
      progressForm: {
        goalId: null,
        currentValue: null,
        notes: ''
      },
      // 表单校验
      rules: {
        goalName: [
          { required: true, message: "目标名称不能为空", trigger: "blur" }
        ],
        goalType: [
          { required: true, message: "目标类型不能为空", trigger: "change" }
        ],
        targetValue: [
          { required: true, message: "目标值不能为空", trigger: "blur" }
        ],
        startDate: [
          { required: true, message: "开始日期不能为空", trigger: "blur" }
        ],
        targetDate: [
          { required: true, message: "目标日期不能为空", trigger: "blur" }
        ]
      },
      // 进度更新校验
      progressRules: {
        currentValue: [
          { required: true, message: "当前值不能为空", trigger: "blur" }
        ]
      }
    };
  },
  created() {
    this.getList();
    this.loadGoalSummary();
  },
  beforeDestroy() {
    if (this.progressChart) {
      this.progressChart.dispose();
    }
  },
  methods: {
    /** 查询健康目标列表 */
    getList() {
      this.loading = true;
      listGoal(this.queryParams).then(response => {
        this.goalList = response.rows;
        this.total = response.total;
        this.loading = false;
      });
    },
    
    /** 加载目标概览 */
    async loadGoalSummary() {
      try {
        const response = await getGoalSummary();
        this.goalSummary = response.data;
      } catch (error) {
        console.error('加载目标概览失败:', error);
      }
    },
    
    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        goalId: null,
        goalName: null,
        goalType: null,
        targetValue: null,
        currentValue: 0,
        unit: null,
        startDate: null,
        targetDate: null,
        status: "active",
        description: null
      };
      this.resetForm("form");
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
      this.ids = selection.map(item => item.goalId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.form.startDate = this.formatDate(new Date());
      this.open = true;
      this.title = "添加健康目标";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const goalId = row.goalId || this.ids
      getGoal(goalId).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改健康目标";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          // 计算进度
          if (this.form.targetValue && this.form.currentValue) {
            this.form.progress = Math.min(100, Math.round((this.form.currentValue / this.form.targetValue) * 100));
          }
          
          if (this.form.goalId != null) {
            updateGoal(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
              this.loadGoalSummary();
            });
          } else {
            addGoal(this.form).then(response => {
              this.$modal.msgSuccess("新增成功");
              this.open = false;
              this.getList();
              this.loadGoalSummary();
            });
          }
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const goalIds = row.goalId || this.ids;
      this.$modal.confirm('是否确认删除健康目标编号为"' + goalIds + '"的数据项？').then(function() {
        return delGoal(goalIds);
      }).then(() => {
        this.getList();
        this.loadGoalSummary();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 查看详情 */
    handleDetail(row) {
      this.currentGoal = row;
      this.detailDialogVisible = true;
      this.$nextTick(() => {
        this.initProgressChart();
      });
    },
    /** 更新进度 */
    handleUpdateProgress(row) {
      this.progressForm = {
        goalId: row.goalId,
        currentValue: row.currentValue,
        notes: ''
      };
      this.progressDialogVisible = true;
    },
    /** 提交进度更新 */
    submitProgressUpdate() {
      this.$refs["progressForm"].validate(valid => {
        if (valid) {
          updateGoalProgress(this.progressForm).then(response => {
            this.$modal.msgSuccess("进度更新成功");
            this.progressDialogVisible = false;
            this.getList();
            this.loadGoalSummary();
          });
        }
      });
    },
    /** 获取进度颜色 */
    getProgressColor(percentage) {
      if (percentage < 30) return '#F56C6C';
      if (percentage < 70) return '#E6A23C';
      return '#67C23A';
    },
    /** 获取剩余天数 */
    getRemainingDays(targetDate) {
      if (!targetDate) return 0;
      const today = new Date();
      const target = new Date(targetDate);
      const diffTime = target - today;
      return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    },
    /** 初始化进度图表 */
    initProgressChart() {
      if (!this.$refs.progressChart) return;
      
      this.progressChart = echarts.init(this.$refs.progressChart);
      
      // 示例数据，实际应该从API获取
      const dates = [];
      const values = [];
      
      for (let i = 30; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        dates.push(this.parseTime(date, '{m}-{d}'));
        values.push(Math.random() * 50 + 20); // 示例数据
      }
      
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        xAxis: {
          type: 'category',
          data: dates
        },
        yAxis: {
          type: 'value',
          name: '进度值'
        },
        series: [{
          name: '进度',
          type: 'line',
          smooth: true,
          data: values,
          areaStyle: {
            opacity: 0.3
          }
        }]
      };
      
      this.progressChart.setOption(option);
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
.goal-card {
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

.active .icon {
  background-color: #409eff20;
  color: #409eff;
}

.completed .icon {
  background-color: #67c23a20;
  color: #67c23a;
}

.paused .icon {
  background-color: #e6a23c20;
  color: #e6a23c;
}

.progress .icon {
  background-color: #f56c6c20;
  color: #f56c6c;
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
}

.goal-detail {
  padding: 20px;
}

.progress-chart {
  border-top: 1px solid #eee;
  padding-top: 20px;
}

@media (max-width: 768px) {
  .goal-card {
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
