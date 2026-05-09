<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="食物名称" prop="foodName">
        <el-input
          v-model="queryParams.foodName"
          placeholder="请输入食物名称"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="所属类别" prop="categoryId">
        <el-select v-model="queryParams.categoryId" placeholder="按系统字典类别筛选" clearable>
          <el-option
            v-for="dict in dict.type.food_category"
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
          v-hasPermi="['diet:food:add']"
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
          v-hasPermi="['diet:food:edit']"
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
          v-hasPermi="['diet:food:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['diet:food:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="foodList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="食物名称" align="center" prop="foodName" />
      <el-table-column label="所属类别" align="center" prop="categoryId">
        <template slot-scope="scope">
          <!-- 优先展示底层联表获取的真实分类名，降级展示字典匹配 -->
          <el-tag type="info" v-if="scope.row.categoryName">{{ scope.row.categoryName }}</el-tag>
          <dict-tag v-else :options="dict.type.food_category" :value="scope.row.categoryId || scope.row.category"/>
        </template>
      </el-table-column>
      <el-table-column label="热量(kcal/100g)" align="center" prop="caloriesPer100g" />
      <el-table-column label="蛋白质(g/100g)" align="center" prop="proteinPer100g" />
      <el-table-column label="脂肪(g/100g)" align="center" prop="fatPer100g" />
      <el-table-column label="碳水化合物(g/100g)" align="center" prop="carbohydratePer100g" />
      <el-table-column label="纤维(g/100g)" align="center" prop="fiberPer100g" />
      <el-table-column label="状态" align="center" prop="status">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-view"
            @click="handleDetail(scope.row)"
            v-hasPermi="['diet:food:query']"
          >详情</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['diet:food:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['diet:food:remove']"
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

    <!-- 添加或修改食物对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="800px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="食物名称" prop="foodName">
              <el-input v-model="form.foodName" placeholder="请输入食物名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属类别" prop="categoryId">
              <el-select v-model="form.categoryId" placeholder="选择预设食物类别">
                <el-option
                  v-for="dict in dict.type.food_category"
                  :key="dict.value"
                  :label="`${dict.label} (代码:${dict.value})`"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="热量(kcal/100g)" prop="caloriesPer100g">
              <el-input-number v-model="form.caloriesPer100g" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="蛋白质(g/100g)" prop="proteinPer100g">
              <el-input-number v-model="form.proteinPer100g" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="脂肪(g/100g)" prop="fatPer100g">
              <el-input-number v-model="form.fatPer100g" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="碳水化合物(g/100g)" prop="carbohydratePer100g">
              <el-input-number v-model="form.carbohydratePer100g" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="纤维(g/100g)" prop="fiberPer100g">
              <el-input-number v-model="form.fiberPer100g" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio
                  v-for="dict in dict.type.sys_normal_disable"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" placeholder="请输入食物描述" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 食物详情对话框 -->
    <el-dialog title="食物详情" :visible.sync="detailDialogVisible" width="600px">
      <div v-if="currentFood" class="food-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="食物名称">{{ currentFood.foodName }}</el-descriptions-item>
          <el-descriptions-item label="所属类别">
            <el-tag type="info" v-if="currentFood.categoryName" size="small">{{ currentFood.categoryName }}</el-tag>
            <dict-tag v-else :options="dict.type.food_category" :value="currentFood.categoryId || currentFood.category"/>
          </el-descriptions-item>
          <el-descriptions-item label="热量">{{ currentFood.caloriesPer100g }} kcal/100g</el-descriptions-item>
          <el-descriptions-item label="蛋白质">{{ currentFood.proteinPer100g }} g/100g</el-descriptions-item>
          <el-descriptions-item label="脂肪">{{ currentFood.fatPer100g }} g/100g</el-descriptions-item>
          <el-descriptions-item label="碳水化合物">{{ currentFood.carbohydratePer100g }} g/100g</el-descriptions-item>
          <el-descriptions-item label="纤维">{{ currentFood.fiberPer100g }} g/100g</el-descriptions-item>
          <el-descriptions-item label="状态">
            <dict-tag :options="dict.type.sys_normal_disable" :value="currentFood.status"/>
          </el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">{{ currentFood.description || '无' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listFood, getFood, delFood, addFood, updateFood } from "@/api/diet/food";

export default {
  name: "DietFood",
  dicts: ['food_category', 'sys_normal_disable'],
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
      // 食物表格数据
      foodList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        foodName: null,
        categoryId: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        foodName: [
          { required: true, message: "食物名称不能为空", trigger: "blur" }
        ],
        categoryId: [
          { required: true, message: "所属类别不能为空", trigger: "change" }
        ],
        caloriesPer100g: [
          { required: true, message: "热量不能为空", trigger: "blur" }
        ],
      },
      // 详情对话框
      detailDialogVisible: false,
      currentFood: null
    };
  },
  created() {
    this.getList();
  },
  methods: {
    /** 查询食物列表 */
    getList() {
      this.loading = true;
      listFood(this.queryParams).then(response => {
        this.foodList = response.rows;
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
        foodId: null,
        foodName: null,
        categoryId: null,
        caloriesPer100g: null,
        proteinPer100g: null,
        fatPer100g: null,
        carbohydratePer100g: null,
        fiberPer100g: null,
        status: "0",
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
      this.ids = selection.map(item => item.foodId)
      this.single = selection.length!==1
      this.multiple = !selection.length
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加食物";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const foodId = row.foodId || this.ids
      getFood(foodId).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改食物";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (valid) {
          if (this.form.foodId != null) {
            updateFood(this.form).then(response => {
              this.$modal.msgSuccess("修改成功");
              this.open = false;
              this.getList();
            });
          } else {
            addFood(this.form).then(response => {
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
      const foodIds = row.foodId || this.ids;
      this.$modal.confirm('是否确认删除食物编号为"' + foodIds + '"的数据项？').then(function() {
        return delFood(foodIds);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {});
    },
    /** 导出按钮操作 */
    handleExport() {
      this.download('diet/food/export', {
        ...this.queryParams
      }, `food_${new Date().getTime()}.xlsx`)
    },
    /** 查看详情 */
    handleDetail(row) {
      this.currentFood = row;
      this.detailDialogVisible = true;
    }
  }
};
</script>

<style scoped>
.food-detail {
  padding: 20px;
}
</style>
