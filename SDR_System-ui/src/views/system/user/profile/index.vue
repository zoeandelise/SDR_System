<template>
  <div class="app-container profile-container">
    <el-row :gutter="20">
      <!-- 左侧 - 个人信息卡片 -->
      <el-col :span="6" :xs="24">
        <el-card class="user-card">
          <div class="user-card-header">
            <div class="avatar-wrapper">
              <userAvatar />
            </div>
            <h3 class="user-name">{{ user.userName }}</h3>
            <p class="user-role">{{ roleGroup }}</p>
          </div>
          <div class="user-info-list">
            <div class="info-item">
              <svg-icon icon-class="phone" class="info-icon" />
              <span class="info-label">手机号码</span>
              <span class="info-value">{{ user.phonenumber || '未设置' }}</span>
            </div>
            <div class="info-item">
              <svg-icon icon-class="email" class="info-icon" />
              <span class="info-label">邮箱</span>
              <span class="info-value">{{ user.email || '未设置' }}</span>
            </div>
            <div class="info-item">
              <svg-icon icon-class="date" class="info-icon" />
              <span class="info-label">注册时间</span>
              <span class="info-value">{{ user.createTime }}</span>
            </div>
          </div>
        </el-card>

        <!-- 健康概览卡片 -->
        <el-card class="health-overview-card" style="margin-top: 16px;">
          <div slot="header" class="card-header">
            <span><i class="el-icon-s-data" style="margin-right: 6px;"></i>健康概览</span>
          </div>
          <div v-if="healthInfo" class="health-stats">
            <div class="health-stat-item">
              <div class="health-stat-value" :class="bmiClass">{{ healthInfo.bmi || '--' }}</div>
              <div class="health-stat-label">BMI</div>
            </div>
            <div class="health-stat-item">
              <div class="health-stat-value calorie">{{ dailyCalorie || '--' }}</div>
              <div class="health-stat-label">每日热量(kcal)</div>
            </div>
            <div class="health-stat-item">
              <div class="health-stat-value goal">{{ healthGoalText }}</div>
              <div class="health-stat-label">健康目标</div>
            </div>
          </div>
          <div v-else class="no-health-data">
            <i class="el-icon-warning-outline"></i>
            <p>暂无健康信息</p>
            <el-button type="primary" size="mini" @click="selectedTab = 'health'">去完善</el-button>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧 - Tab页 -->
      <el-col :span="18" :xs="24">
        <el-card class="main-card">
          <el-tabs v-model="selectedTab" class="profile-tabs">
            <el-tab-pane label="基本资料" name="userinfo">
              <div class="tab-icon"><i class="el-icon-user"></i></div>
              <userInfo :user="user" />
            </el-tab-pane>

            <el-tab-pane label="健康信息" name="health">
              <div class="tab-icon"><i class="el-icon-first-aid-kit"></i></div>
              <div class="health-form-section">
                <el-form ref="healthForm" :model="healthForm" label-width="100px" class="health-form">
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="年龄">
                        <el-input-number v-model="healthForm.age" :min="1" :max="150" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="性别">
                        <el-select v-model="healthForm.gender" placeholder="请选择" style="width: 100%">
                          <el-option label="男" value="0" />
                          <el-option label="女" value="1" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="身高(cm)">
                        <el-input-number v-model="healthForm.height" :min="50" :max="250" :precision="1" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="体重(kg)">
                        <el-input-number v-model="healthForm.weight" :min="20" :max="300" :precision="1" style="width: 100%" />
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="活动水平">
                        <el-select v-model="healthForm.activityLevel" placeholder="请选择" style="width: 100%">
                          <el-option label="久坐（几乎不运动）" value="0" />
                          <el-option label="轻度活动（每周1-3次）" value="1" />
                          <el-option label="中等活动（每周3-5次）" value="2" />
                          <el-option label="高强度活动（每周6-7次）" value="3" />
                          <el-option label="极高强度（每天高强度）" value="4" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="健康目标">
                        <el-select v-model="healthForm.healthGoal" placeholder="请选择" style="width: 100%">
                          <el-option label="维持健康" value="0" />
                          <el-option label="减脂瘦身" value="1" />
                          <el-option label="增肌塑形" value="2" />
                          <el-option label="增重增肌" value="3" />
                        </el-select>
                      </el-form-item>
                    </el-col>
                  </el-row>
                  <el-form-item label="慢性病">
                    <el-input v-model="healthForm.diseases" placeholder="如：高血压、糖尿病（用逗号分隔）" />
                  </el-form-item>
                  <el-form-item label="过敏食物">
                    <el-input v-model="healthForm.allergies" placeholder="如：花生、海鲜（用逗号分隔）" />
                  </el-form-item>
                  <el-form-item label="饮食偏好">
                    <el-input v-model="healthForm.dietPreferences" placeholder="如：清淡、素食（用逗号分隔）" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" @click="saveHealthInfo" :loading="healthSaving">
                      <i class="el-icon-check"></i> 保存健康信息
                    </el-button>
                  </el-form-item>
                </el-form>
              </div>
            </el-tab-pane>

            <el-tab-pane label="修改密码" name="resetPwd">
              <div class="tab-icon"><i class="el-icon-lock"></i></div>
              <resetPwd />
            </el-tab-pane>

            <el-tab-pane label="我的饮食" name="diet">
              <div class="tab-icon"><i class="el-icon-food"></i></div>
              <div class="diet-shortcuts">
                <el-row :gutter="20">
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/dashboard')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #667eea, #764ba2);">
                        <i class="el-icon-data-analysis"></i>
                      </div>
                      <div class="shortcut-title">饮食仪表盘</div>
                      <div class="shortcut-desc">查看饮食统计和营养分析</div>
                    </div>
                  </el-col>
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/record')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #f093fb, #f5576c);">
                        <i class="el-icon-edit-outline"></i>
                      </div>
                      <div class="shortcut-title">饮食记录</div>
                      <div class="shortcut-desc">记录每日饮食情况</div>
                    </div>
                  </el-col>
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/recommendation')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #4facfe, #00f2fe);">
                        <i class="el-icon-magic-stick"></i>
                      </div>
                      <div class="shortcut-title">智能推荐</div>
                      <div class="shortcut-desc">获取个性化饮食推荐</div>
                    </div>
                  </el-col>
                </el-row>
                <el-row :gutter="20" style="margin-top: 20px;">
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/food')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #43e97b, #38f9d7);">
                        <i class="el-icon-search"></i>
                      </div>
                      <div class="shortcut-title">食物库</div>
                      <div class="shortcut-desc">查询食物营养成分</div>
                    </div>
                  </el-col>
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/goal')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #fa709a, #fee140);">
                        <i class="el-icon-trophy"></i>
                      </div>
                      <div class="shortcut-title">健康目标</div>
                      <div class="shortcut-desc">设置和追踪健康目标</div>
                    </div>
                  </el-col>
                  <el-col :span="8">
                    <div class="shortcut-card" @click="goTo('/diet/profile')">
                      <div class="shortcut-icon" style="background: linear-gradient(135deg, #a18cd1, #fbc2eb);">
                        <i class="el-icon-user"></i>
                      </div>
                      <div class="shortcut-title">用户画像</div>
                      <div class="shortcut-desc">查看个人饮食画像分析</div>
                    </div>
                  </el-col>
                </el-row>
              </div>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import userAvatar from "./userAvatar"
import userInfo from "./userInfo"
import resetPwd from "./resetPwd"
import { getUserProfile } from "@/api/system/user"
import request from '@/utils/request'

export default {
  name: "Profile",
  components: { userAvatar, userInfo, resetPwd },
  data() {
    return {
      user: {},
      roleGroup: {},
      postGroup: {},
      selectedTab: "userinfo",
      healthInfo: null,
      dailyCalorie: null,
      healthForm: {
        age: null,
        gender: null,
        height: null,
        weight: null,
        activityLevel: null,
        healthGoal: null,
        diseases: '',
        allergies: '',
        dietPreferences: ''
      },
      healthSaving: false
    }
  },
  computed: {
    healthGoalText() {
      if (!this.healthInfo) return '--'
      const map = { '0': '维持健康', '1': '减脂瘦身', '2': '增肌塑形', '3': '增重增肌' }
      return map[this.healthInfo.healthGoal] || '维持健康'
    },
    bmiClass() {
      if (!this.healthInfo || !this.healthInfo.bmi) return ''
      const bmi = parseFloat(this.healthInfo.bmi)
      if (bmi < 18.5) return 'bmi-low'
      if (bmi < 24) return 'bmi-normal'
      if (bmi < 28) return 'bmi-high'
      return 'bmi-danger'
    }
  },
  created() {
    const activeTab = this.$route.params && this.$route.params.activeTab
    if (activeTab) {
      this.selectedTab = activeTab
    }
    this.getUser()
    this.loadHealthInfo()
  },
  methods: {
    getUser() {
      getUserProfile().then(response => {
        this.user = response.data
        this.roleGroup = response.roleGroup
        this.postGroup = response.postGroup
      })
    },
    loadHealthInfo() {
      request({ url: '/diet/health/my', method: 'get' }).then(res => {
        if (res.code === 200 && res.data) {
          this.healthInfo = res.data
          // 填充健康表单
          this.healthForm = {
            age: res.data.age,
            gender: res.data.gender,
            height: res.data.height,
            weight: res.data.weight,
            activityLevel: res.data.activityLevel,
            healthGoal: res.data.healthGoal,
            diseases: res.data.diseases || '',
            allergies: res.data.allergies || '',
            dietPreferences: res.data.dietPreferences || ''
          }
          // 计算BMI
          if (res.data.height && res.data.weight) {
            const h = res.data.height / 100
            this.healthInfo.bmi = (res.data.weight / (h * h)).toFixed(1)
          }
        }
      }).catch(() => {})

      // 获取每日热量需求
      request({ url: '/diet/health/calorie-need', method: 'get' }).then(res => {
        if (res.code === 200 && res.data) {
          this.dailyCalorie = res.data
        }
      }).catch(() => {})
    },
    saveHealthInfo() {
      this.healthSaving = true
      request({
        url: '/diet/health/my',
        method: 'post',
        data: this.healthForm
      }).then(res => {
        if (res.code === 200) {
          this.$modal.msgSuccess("健康信息保存成功")
          this.loadHealthInfo()
        } else {
          this.$modal.msgError(res.msg || "保存失败")
        }
      }).catch(() => {
        this.$modal.msgError("保存失败")
      }).finally(() => {
        this.healthSaving = false
      })
    },
    goTo(path) {
      this.$router.push(path)
    }
  }
}
</script>

<style scoped lang="scss">
.profile-container {
  padding: 20px;
}

/* 用户卡片 */
.user-card {
  border-radius: 12px;
  overflow: hidden;
  border: none;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);

  .user-card-header {
    text-align: center;
    padding: 30px 20px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;

    .avatar-wrapper {
      margin-bottom: 12px;
    }

    .user-name {
      font-size: 20px;
      font-weight: 600;
      margin: 0 0 4px;
    }

    .user-role {
      font-size: 13px;
      opacity: 0.85;
      margin: 0;
    }
  }

  .user-info-list {
    padding: 16px 20px;

    .info-item {
      display: flex;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid #f0f0f0;
      font-size: 14px;

      &:last-child {
        border-bottom: none;
      }

      .info-icon {
        color: #667eea;
        margin-right: 10px;
        font-size: 16px;
      }

      .info-label {
        color: #909399;
        min-width: 60px;
      }

      .info-value {
        color: #303133;
        margin-left: auto;
        text-align: right;
        max-width: 140px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }
  }
}

/* 健康概览卡片 */
.health-overview-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);

  .card-header {
    font-weight: 600;
    color: #303133;
    font-size: 15px;
  }

  .health-stats {
    display: flex;
    justify-content: space-around;
    text-align: center;
    padding: 4px 0;

    .health-stat-item {
      .health-stat-value {
        font-size: 22px;
        font-weight: 700;
        margin-bottom: 4px;
        color: #303133;

        &.bmi-normal { color: #67c23a; }
        &.bmi-low { color: #e6a23c; }
        &.bmi-high { color: #e6a23c; }
        &.bmi-danger { color: #f56c6c; }
        &.calorie { color: #667eea; }
        &.goal { color: #764ba2; font-size: 16px; }
      }

      .health-stat-label {
        font-size: 12px;
        color: #909399;
      }
    }
  }

  .no-health-data {
    text-align: center;
    padding: 20px 0;
    color: #909399;

    i { font-size: 32px; margin-bottom: 8px; display: block; }
    p { margin: 8px 0 12px; }
  }
}

/* 右侧主卡片 */
.main-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  min-height: 500px;
}

.profile-tabs {
  .tab-icon {
    display: none;
  }
}

/* 健康表单 */
.health-form-section {
  max-width: 700px;
  padding: 20px 0;
}

/* 饮食快捷入口 */
.diet-shortcuts {
  padding: 10px 0;

  .shortcut-card {
    background: #fff;
    border: 1px solid #ebeef5;
    border-radius: 12px;
    padding: 24px 16px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s ease;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
      border-color: transparent;
    }

    .shortcut-icon {
      width: 56px;
      height: 56px;
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 12px;

      i {
        font-size: 26px;
        color: white;
      }
    }

    .shortcut-title {
      font-size: 15px;
      font-weight: 600;
      color: #303133;
      margin-bottom: 6px;
    }

    .shortcut-desc {
      font-size: 12px;
      color: #909399;
    }
  }
}
</style>
