<template>
  <div class="app-container">
    <!-- 用户基本信息 -->
    <el-row :gutter="20">
      <el-col :xs="24" :sm="24" :md="8" :lg="6" :xl="6">
        <el-card class="user-info-card">
          <div class="user-avatar">
            <el-avatar :size="80" :src="userProfile.avatar" icon="el-icon-user-solid"></el-avatar>
          </div>
          <div class="user-basic">
            <h3>{{ userProfile.nickName || userProfile.userName }}</h3>
            <p>{{ userProfile.email }}</p>
            <el-button type="primary" size="small" @click="handleEditProfile">编辑资料</el-button>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="16" :lg="18" :xl="18">
        <el-card class="profile-stats">
          <div slot="header" class="card-header">
            <span>健康档案</span>
            <el-button type="text" size="small" @click="refreshProfile">刷新</el-button>
          </div>
          <el-row :gutter="20">
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.age || '--' }}</div>
                <div class="stat-label">年龄</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.height || '--' }} cm</div>
                <div class="stat-label">身高</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.weight || '--' }} kg</div>
                <div class="stat-label">体重</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.bmi || '--' }}</div>
                <div class="stat-label">BMI</div>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" style="margin-top: 20px;">
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.activityLevel || '--' }}</div>
                <div class="stat-label">活动水平</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.targetCalories || '--' }} kcal</div>
                <div class="stat-label">目标热量</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-item">
                <div class="stat-value">{{ userProfile.healthGoals ? userProfile.healthGoals.length : 0 }}</div>
                <div class="stat-label">健康目标</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>

    <!-- 营养摄入分析 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span>近30天营养摄入趋势</span>
            <el-date-picker
              v-model="chartDateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              size="mini"
              @change="updateNutritionChart"
            >
            </el-date-picker>
          </div>
          <div ref="nutritionTrendChart" style="height: 350px;"></div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="chart-card">
          <div slot="header" class="card-header">
            <span>饮食偏好分析</span>
          </div>
          <div ref="dietPreferenceChart" style="height: 350px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 健康指标 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <el-card class="health-indicators">
          <div slot="header" class="card-header">
            <span>健康指标</span>
            <el-button type="primary" size="small" @click="handleAddIndicator">添加指标</el-button>
          </div>
          <el-row :gutter="20">
            <el-col :xs="24" :sm="12" :md="8" :lg="6" :xl="6" v-for="indicator in healthIndicators" :key="indicator.type">
              <div class="indicator-card" :class="getIndicatorStatus(indicator)">
                <div class="indicator-icon">
                  <i :class="getIndicatorIcon(indicator.type)"></i>
                </div>
                <div class="indicator-info">
                  <div class="indicator-name">{{ getIndicatorName(indicator.type) }}</div>
                  <div class="indicator-value">{{ indicator.value }} {{ indicator.unit }}</div>
                  <div class="indicator-time">{{ parseTime(indicator.recordTime, '{m}-{d} {h}:{i}') }}</div>
                </div>
                <div class="indicator-trend">
                  <i :class="getTrendIcon(indicator.trend)" :style="{ color: getTrendColor(indicator.trend) }"></i>
                </div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>

    <!-- 饮食习惯分析 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="habit-analysis">
          <div slot="header" class="card-header">
            <span>饮食习惯分析</span>
          </div>
          <div class="habit-list">
            <div v-for="habit in dietHabits" :key="habit.type" class="habit-item">
              <div class="habit-header">
                <span class="habit-name">{{ habit.name }}</span>
                <el-tag :type="getHabitTagType(habit.score)" size="mini">{{ getHabitLevel(habit.score) }}</el-tag>
              </div>
              <el-progress :percentage="habit.score" :color="getHabitColor(habit.score)" :stroke-width="6"></el-progress>
              <div class="habit-description">{{ habit.description }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
        <el-card class="recommendations">
          <div slot="header" class="card-header">
            <span>个性化建议</span>
            <el-button type="text" size="small" @click="generateRecommendations">重新生成</el-button>
          </div>
          <div class="recommendation-list">
            <div v-for="(rec, index) in personalRecommendations" :key="index" class="recommendation-item">
              <div class="rec-type" :class="rec.type">
                <i :class="getRecommendationIcon(rec.type)"></i>
                {{ getRecommendationType(rec.type) }}
              </div>
              <div class="rec-content">{{ rec.content }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 编辑资料对话框 -->
    <el-dialog title="编辑个人资料" :visible.sync="profileDialogVisible" width="600px">
      <el-form ref="profileForm" :model="profileForm" :rules="profileRules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="年龄" prop="age">
              <el-input-number v-model="profileForm.age" :min="1" :max="120" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-radio-group v-model="profileForm.gender">
                <el-radio label="male">男</el-radio>
                <el-radio label="female">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="身高(cm)" prop="height">
              <el-input-number v-model="profileForm.height" :min="100" :max="250" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="体重(kg)" prop="weight">
              <el-input-number v-model="profileForm.weight" :min="30" :max="300" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="活动水平" prop="activityLevel">
          <el-select v-model="profileForm.activityLevel" placeholder="请选择活动水平" style="width: 100%">
            <el-option
              v-for="dict in dict.type.diet_activity_level"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="健康目标" prop="healthGoals">
          <el-checkbox-group v-model="profileForm.healthGoals">
            <el-checkbox
              v-for="dict in dict.type.diet_goal_type"
              :key="dict.value"
              :label="dict.value"
            >{{ dict.label }}</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="过敏食物" prop="allergicFoods">
          <el-input v-model="profileForm.allergicFoods" type="textarea" placeholder="请输入过敏食物，用逗号分隔" />
        </el-form-item>
        <el-form-item label="不喜欢的食物" prop="dislikedFoods">
          <el-input v-model="profileForm.dislikedFoods" type="textarea" placeholder="请输入不喜欢的食物，用逗号分隔" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="profileDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="submitProfile">确 定</el-button>
      </div>
    </el-dialog>

    <!-- 添加健康指标对话框 -->
    <el-dialog title="添加健康指标" :visible.sync="indicatorDialogVisible" width="400px">
      <el-form ref="indicatorForm" :model="indicatorForm" :rules="indicatorRules" label-width="100px">
        <el-form-item label="指标类型" prop="type">
          <el-select v-model="indicatorForm.type" placeholder="请选择指标类型" style="width: 100%">
            <el-option label="血压" value="blood_pressure"></el-option>
            <el-option label="血糖" value="blood_sugar"></el-option>
            <el-option label="心率" value="heart_rate"></el-option>
            <el-option label="体脂率" value="body_fat"></el-option>
            <el-option label="肌肉量" value="muscle_mass"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="数值" prop="value">
          <el-input-number v-model="indicatorForm.value" :precision="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="单位" prop="unit">
          <el-input v-model="indicatorForm.unit" placeholder="如：mmHg、mg/dL、bpm等" />
        </el-form-item>
        <el-form-item label="记录时间" prop="recordTime">
          <el-date-picker
            v-model="indicatorForm.recordTime"
            type="datetime"
            value-format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择记录时间"
            style="width: 100%"
          >
          </el-date-picker>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="indicatorDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="submitIndicator">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getUserProfile, updateUserProfile, getHealthIndicators, addHealthIndicator, getDietHabits, getPersonalRecommendations } from "@/api/diet/profile";
import * as echarts from 'echarts';

export default {
  name: "DietProfile",
  dicts: ['diet_activity_level', 'diet_goal_type'],
  data() {
    return {
      // 用户档案数据
      userProfile: {},
      // 健康指标
      healthIndicators: [],
      // 饮食习惯
      dietHabits: [],
      // 个性化建议
      personalRecommendations: [],
      // 图表日期范围
      chartDateRange: [],
      // 图表实例
      nutritionTrendChart: null,
      dietPreferenceChart: null,
      // 对话框
      profileDialogVisible: false,
      indicatorDialogVisible: false,
      // 表单数据
      profileForm: {},
      indicatorForm: {
        type: '',
        value: null,
        unit: '',
        recordTime: null
      },
      // 表单校验
      profileRules: {
        age: [{ required: true, message: "年龄不能为空", trigger: "blur" }],
        height: [{ required: true, message: "身高不能为空", trigger: "blur" }],
        weight: [{ required: true, message: "体重不能为空", trigger: "blur" }]
      },
      indicatorRules: {
        type: [{ required: true, message: "指标类型不能为空", trigger: "change" }],
        value: [{ required: true, message: "数值不能为空", trigger: "blur" }],
        unit: [{ required: true, message: "单位不能为空", trigger: "blur" }],
        recordTime: [{ required: true, message: "记录时间不能为空", trigger: "blur" }]
      }
    };
  },
  created() {
    this.initDateRange();
    this.loadUserProfile();
    this.loadHealthIndicators();
    this.loadDietHabits();
    this.loadPersonalRecommendations();
  },
  mounted() {
    this.initCharts();
  },
  beforeDestroy() {
    if (this.nutritionTrendChart) {
      this.nutritionTrendChart.dispose();
    }
    if (this.dietPreferenceChart) {
      this.dietPreferenceChart.dispose();
    }
  },
  methods: {
    initDateRange() {
      const end = new Date();
      const start = new Date();
      start.setTime(start.getTime() - 3600 * 1000 * 24 * 30);
      this.chartDateRange = [start, end];
    },
    
    async loadUserProfile() {
      try {
        const response = await getUserProfile();
        this.userProfile = response.data || {};
        // 计算BMI
        if (this.userProfile.height && this.userProfile.weight) {
          const heightInMeters = this.userProfile.height / 100;
          this.userProfile.bmi = (this.userProfile.weight / (heightInMeters * heightInMeters)).toFixed(1);
        }
      } catch (error) {
        console.error('加载用户档案失败:', error);
      }
    },
    
    async loadHealthIndicators() {
      try {
        const response = await getHealthIndicators();
        this.healthIndicators = response.data || [];
      } catch (error) {
        console.error('加载健康指标失败:', error);
      }
    },
    
    async loadDietHabits() {
      try {
        const response = await getDietHabits();
        this.dietHabits = response.data || [];
      } catch (error) {
        console.error('加载饮食习惯失败:', error);
        // 示例数据
        this.dietHabits = [
          { type: 'regularity', name: '饮食规律性', score: 75, description: '基本能按时吃饭，偶尔会错过餐点' },
          { type: 'balance', name: '营养均衡性', score: 60, description: '蛋白质摄入不足，建议增加优质蛋白' },
          { type: 'water', name: '饮水习惯', score: 45, description: '饮水量偏少，建议每日至少8杯水' },
          { type: 'snack', name: '零食控制', score: 80, description: '零食摄入控制良好，继续保持' }
        ];
      }
    },
    
    async loadPersonalRecommendations() {
      try {
        const response = await getPersonalRecommendations();
        this.personalRecommendations = response.data || [];
      } catch (error) {
        console.error('加载个性化建议失败:', error);
        // 示例数据
        this.personalRecommendations = [
          { type: 'nutrition', content: '建议增加深色蔬菜的摄入，补充维生素和矿物质' },
          { type: 'exercise', content: '结合您的活动水平，建议每周进行3-4次中等强度运动' },
          { type: 'hydration', content: '您的饮水量偏少，建议每日饮水2000-2500ml' },
          { type: 'sleep', content: '保证充足睡眠，有助于新陈代谢和体重管理' }
        ];
      }
    },
    
    initCharts() {
      this.$nextTick(() => {
        this.initNutritionTrendChart();
        this.initDietPreferenceChart();
      });
    },
    
    initNutritionTrendChart() {
      this.nutritionTrendChart = echarts.init(this.$refs.nutritionTrendChart);
      
      // 示例数据
      const dates = [];
      const calories = [];
      const protein = [];
      const fat = [];
      const carb = [];
      
      for (let i = 29; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        dates.push(this.parseTime(date, '{m}-{d}'));
        calories.push(Math.random() * 500 + 1500);
        protein.push(Math.random() * 30 + 50);
        fat.push(Math.random() * 20 + 30);
        carb.push(Math.random() * 50 + 150);
      }
      
      const option = {
        tooltip: {
          trigger: 'axis'
        },
        legend: {
          data: ['热量', '蛋白质', '脂肪', '碳水化合物']
        },
        xAxis: {
          type: 'category',
          data: dates
        },
        yAxis: [
          {
            type: 'value',
            name: '热量 (kcal)',
            position: 'left'
          },
          {
            type: 'value',
            name: '营养素 (g)',
            position: 'right'
          }
        ],
        series: [
          {
            name: '热量',
            type: 'line',
            yAxisIndex: 0,
            data: calories
          },
          {
            name: '蛋白质',
            type: 'line',
            yAxisIndex: 1,
            data: protein
          },
          {
            name: '脂肪',
            type: 'line',
            yAxisIndex: 1,
            data: fat
          },
          {
            name: '碳水化合物',
            type: 'line',
            yAxisIndex: 1,
            data: carb
          }
        ]
      };
      
      this.nutritionTrendChart.setOption(option);
    },
    
    initDietPreferenceChart() {
      this.dietPreferenceChart = echarts.init(this.$refs.dietPreferenceChart);
      
      const option = {
        tooltip: {
          trigger: 'item'
        },
        legend: {
          top: '5%',
          left: 'center'
        },
        series: [
          {
            name: '饮食偏好',
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '40',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            data: [
              { value: 35, name: '蔬菜类' },
              { value: 25, name: '肉类' },
              { value: 20, name: '谷物类' },
              { value: 10, name: '水果类' },
              { value: 10, name: '其他' }
            ]
          }
        ]
      };
      
      this.dietPreferenceChart.setOption(option);
    },
    
    refreshProfile() {
      this.loadUserProfile();
      this.loadHealthIndicators();
    },
    
    handleEditProfile() {
      this.profileForm = { ...this.userProfile };
      this.profileDialogVisible = true;
    },
    
    submitProfile() {
      this.$refs["profileForm"].validate(valid => {
        if (valid) {
          updateUserProfile(this.profileForm).then(response => {
            this.$modal.msgSuccess("资料更新成功");
            this.profileDialogVisible = false;
            this.loadUserProfile();
          });
        }
      });
    },
    
    handleAddIndicator() {
      this.indicatorForm = {
        type: '',
        value: null,
        unit: '',
        recordTime: this.parseTime(new Date(), '{y}-{m}-{d} {h}:{i}:{s}')
      };
      this.indicatorDialogVisible = true;
    },
    
    submitIndicator() {
      this.$refs["indicatorForm"].validate(valid => {
        if (valid) {
          addHealthIndicator(this.indicatorForm).then(response => {
            this.$modal.msgSuccess("健康指标添加成功");
            this.indicatorDialogVisible = false;
            this.loadHealthIndicators();
          });
        }
      });
    },
    
    generateRecommendations() {
      this.loadPersonalRecommendations();
    },
    
    updateNutritionChart() {
      // 根据新的日期范围更新图表
      this.initNutritionTrendChart();
    },
    
    getIndicatorStatus(indicator) {
      // 根据指标类型和数值判断状态
      return 'normal'; // 示例返回
    },
    
    getIndicatorIcon(type) {
      const icons = {
        'blood_pressure': 'el-icon-heart',
        'blood_sugar': 'el-icon-sugar',
        'heart_rate': 'el-icon-time',
        'body_fat': 'el-icon-pie-chart',
        'muscle_mass': 'el-icon-trophy'
      };
      return icons[type] || 'el-icon-data-analysis';
    },
    
    getIndicatorName(type) {
      const names = {
        'blood_pressure': '血压',
        'blood_sugar': '血糖',
        'heart_rate': '心率',
        'body_fat': '体脂率',
        'muscle_mass': '肌肉量'
      };
      return names[type] || type;
    },
    
    getTrendIcon(trend) {
      const icons = {
        'up': 'el-icon-top',
        'down': 'el-icon-bottom',
        'stable': 'el-icon-minus'
      };
      return icons[trend] || 'el-icon-minus';
    },
    
    getTrendColor(trend) {
      const colors = {
        'up': '#F56C6C',
        'down': '#67C23A',
        'stable': '#909399'
      };
      return colors[trend] || '#909399';
    },
    
    getHabitTagType(score) {
      if (score >= 80) return 'success';
      if (score >= 60) return 'warning';
      return 'danger';
    },
    
    getHabitLevel(score) {
      if (score >= 80) return '优秀';
      if (score >= 60) return '良好';
      return '需改善';
    },
    
    getHabitColor(score) {
      if (score >= 80) return '#67C23A';
      if (score >= 60) return '#E6A23C';
      return '#F56C6C';
    },
    
    getRecommendationIcon(type) {
      const icons = {
        'nutrition': 'el-icon-food',
        'exercise': 'el-icon-bicycle',
        'hydration': 'el-icon-coffee-cup',
        'sleep': 'el-icon-moon-night'
      };
      return icons[type] || 'el-icon-info';
    },
    
    getRecommendationType(type) {
      const types = {
        'nutrition': '营养建议',
        'exercise': '运动建议',
        'hydration': '饮水建议',
        'sleep': '睡眠建议'
      };
      return types[type] || '健康建议';
    }
  }
};
</script>

<style scoped>
.user-info-card {
  text-align: center;
  height: 200px;
}

.user-avatar {
  margin-bottom: 15px;
}

.user-basic h3 {
  margin: 10px 0 5px 0;
  color: #333;
}

.user-basic p {
  color: #666;
  margin-bottom: 15px;
}

.profile-stats {
  height: 200px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-item {
  text-align: center;
  padding: 10px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.chart-card {
  margin-bottom: 20px;
}

.health-indicators {
  margin-bottom: 20px;
}

.indicator-card {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 1px solid #eee;
  border-radius: 8px;
  margin-bottom: 15px;
  background: #fff;
  transition: all 0.3s;
}

.indicator-card:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.indicator-card.normal {
  border-left: 4px solid #67C23A;
}

.indicator-card.warning {
  border-left: 4px solid #E6A23C;
}

.indicator-card.danger {
  border-left: 4px solid #F56C6C;
}

.indicator-icon {
  font-size: 24px;
  margin-right: 15px;
  color: #409EFF;
}

.indicator-info {
  flex: 1;
}

.indicator-name {
  font-weight: bold;
  margin-bottom: 5px;
}

.indicator-value {
  font-size: 18px;
  color: #333;
  margin-bottom: 2px;
}

.indicator-time {
  font-size: 12px;
  color: #999;
}

.indicator-trend {
  font-size: 20px;
}

.habit-analysis, .recommendations {
  margin-bottom: 20px;
}

.habit-list {
  max-height: 400px;
  overflow-y: auto;
}

.habit-item {
  margin-bottom: 20px;
  padding: 15px;
  background: #fafafa;
  border-radius: 8px;
}

.habit-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.habit-name {
  font-weight: bold;
}

.habit-description {
  font-size: 12px;
  color: #666;
  margin-top: 5px;
}

.recommendation-list {
  max-height: 400px;
  overflow-y: auto;
}

.recommendation-item {
  margin-bottom: 15px;
  padding: 15px;
  border-left: 3px solid #409EFF;
  background: #f8f9fa;
  border-radius: 4px;
}

.rec-type {
  font-weight: bold;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
}

.rec-type.nutrition {
  color: #67C23A;
}

.rec-type.exercise {
  color: #409EFF;
}

.rec-type.hydration {
  color: #20A0FF;
}

.rec-type.sleep {
  color: #909399;
}

.rec-type i {
  margin-right: 5px;
}

.rec-content {
  color: #666;
  line-height: 1.5;
}

@media (max-width: 768px) {
  .stat-item {
    margin-bottom: 15px;
  }
  
  .indicator-card {
    flex-direction: column;
    text-align: center;
  }
  
  .indicator-icon {
    margin-right: 0;
    margin-bottom: 10px;
  }
}
</style>
