<template>
  <div class="app-container home">
    <!-- 顶部欢迎横幅 -->
    <div class="welcome-banner">
      <div class="banner-content">
        <div class="banner-text">
          <h1 class="banner-title">
            <i class="el-icon-food"></i>
            基于协同过滤的个性化健康饮食推荐系统
          </h1>
          <p class="banner-desc">
            运用协同过滤算法，结合用户健康数据与饮食偏好，提供科学、个性化的健康饮食推荐方案
          </p>
          <div class="banner-tags">
            <span class="tag tag-primary">智能推荐</span>
            <span class="tag tag-success">营养分析</span>
            <span class="tag tag-warning">健康管理</span>
          </div>
        </div>
        <div class="banner-version">
          <span class="version-badge">v{{ version }}</span>
        </div>
      </div>
    </div>

    <!-- 数据概览卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="12" :sm="12" :md="8" v-for="(stat, index) in statsCards" :key="index">
        <div class="stat-card" :style="{ '--accent': stat.color, '--bg': stat.bg }">
          <div class="stat-icon-wrap">
            <i :class="stat.icon"></i>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 核心功能 + 快速导航 -->
    <el-row :gutter="20" class="content-row">
      <!-- 核心功能 -->
      <el-col :xs="24" :sm="24" :lg="14">
        <el-card class="feature-card" shadow="hover">
          <div slot="header" class="card-header">
            <span><i class="el-icon-star-on"></i> 核心功能</span>
          </div>
          <div class="feature-grid">
            <div class="feature-item" v-for="(feat, i) in features" :key="i">
              <div class="feature-icon" :style="{ background: feat.gradient }">
                <i :class="feat.icon"></i>
              </div>
              <div class="feature-content">
                <h4>{{ feat.title }}</h4>
                <p>{{ feat.desc }}</p>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 快速导航 -->
      <el-col :xs="24" :sm="24" :lg="10">
        <el-card class="nav-card" shadow="hover">
          <div slot="header" class="card-header">
            <span><i class="el-icon-guide"></i> 快速导航</span>
          </div>
          <div class="nav-grid">
            <div 
              class="nav-item" 
              v-for="(nav, i) in quickNavs" 
              :key="i"
              @click="goTo(nav.path)"
            >
              <div class="nav-icon" :style="{ background: nav.gradient }">
                <i :class="nav.icon"></i>
              </div>
              <span class="nav-label">{{ nav.label }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 技术栈 + 系统信息 -->
    <el-row :gutter="20" class="content-row">
      <!-- 技术栈 -->
      <el-col :xs="24" :sm="24" :lg="14">
        <el-card class="tech-card" shadow="hover">
          <div slot="header" class="card-header">
            <span><i class="el-icon-cpu"></i> 技术架构</span>
          </div>
          <div class="tech-grid">
            <div class="tech-group" v-for="(group, i) in techGroups" :key="i">
              <div class="tech-group-title">{{ group.title }}</div>
              <div class="tech-tags">
                <span class="tech-tag" v-for="(tech, j) in group.items" :key="j" :style="{ '--tag-color': tech.color }">
                  {{ tech.name }}
                </span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 系统信息 -->
      <el-col :xs="24" :sm="24" :lg="10">
        <el-card class="info-card" shadow="hover">
          <div slot="header" class="card-header">
            <span><i class="el-icon-info"></i> 系统信息</span>
          </div>
          <div class="info-list">
            <div class="info-item" v-for="(info, i) in systemInfo" :key="i">
              <span class="info-label">{{ info.label }}</span>
              <span class="info-value">{{ info.value }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { getQuickStats } from '@/api/diet/dashboard'

export default {
  name: "Index",
  data() {
    return {
      version: "3.9.0",
      statsCards: [
        { label: "饮食记录", value: "--", icon: "el-icon-document", color: "#6366f1", bg: "linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%)", key: 'recordCount' },
        { label: "记录天数", value: "--", icon: "el-icon-date", color: "#10b981", bg: "linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%)", key: 'recordDays' },
        { label: "健康目标", value: "--", icon: "el-icon-aim", color: "#f59e0b", bg: "linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%)", key: 'goalsCount' }
      ],
      features: [
        {
          title: "健康饮食推荐引擎",
          desc: "系统基于体征指标（BMR/BMI）静态档案为您精准分配推荐的每日摄入额度热量",
          icon: "el-icon-magic-stick",
          gradient: "linear-gradient(135deg, #6366f1, #818cf8)"
        },
        {
          title: "三餐结构打卡追踪",
          desc: "内置精细化到早、中、晚餐的独立打卡面板，直观通过热力色阶折射当月记录活跃度",
          icon: "el-icon-document-checked",
          gradient: "linear-gradient(135deg, #10b981, #34d399)"
        },
        {
          title: "高覆盖率热量名录",
          desc: "库内扩容了近百种常见中式与快餐硬核食材，涵盖基本的热量与三大宏量营养素计算",
          icon: "el-icon-pie-chart",
          gradient: "linear-gradient(135deg, #f59e0b, #fbbf24)"
        },
        {
          title: "双引擎冷启动分流",
          desc: "内置规则探针拦截缺量新用户，采用低门槛静态推荐，积累历史后采用协同引擎进阶推流",
          icon: "el-icon-data-line",
          gradient: "linear-gradient(135deg, #ef4444, #f87171)"
        }
      ],
      quickNavs: [
        { label: "饮食仪表盘", icon: "el-icon-odometer", path: "/diet/dashboard", gradient: "linear-gradient(135deg, #6366f1, #818cf8)" },
        { label: "食物管理", icon: "el-icon-food", path: "/diet/food", gradient: "linear-gradient(135deg, #10b981, #34d399)" },
        { label: "健康目标", icon: "el-icon-aim", path: "/diet/goal", gradient: "linear-gradient(135deg, #f59e0b, #fbbf24)" },
        { label: "饮食记录", icon: "el-icon-document", path: "/diet/record", gradient: "linear-gradient(135deg, #ec4899, #f472b6)" },
        { label: "智能推荐", icon: "el-icon-magic-stick", path: "/diet/recommendation", gradient: "linear-gradient(135deg, #8b5cf6, #a78bfa)" },
        { label: "健康画像", icon: "el-icon-user", path: "/diet/profile", gradient: "linear-gradient(135deg, #f97316, #fb923c)" },
        { label: "ML管理", icon: "el-icon-cpu", path: "/diet/ml/management", gradient: "linear-gradient(135deg, #ef4444, #f87171)" }
      ],
      techGroups: [
        {
          title: "后端",
          items: [
            { name: "Spring Boot", color: "#6db33f" },
            { name: "MyBatis", color: "#c0392b" },
            { name: "MySQL", color: "#4479a1" }
          ]
        },
        {
          title: "前端",
          items: [
            { name: "Vue.js 2", color: "#42b883" },
            { name: "Element UI", color: "#409eff" },
            { name: "ECharts", color: "#aa344d" },
            { name: "Axios", color: "#5a29e4" }
          ]
        },
        {
          title: "算法",
          items: [
            { name: "Python", color: "#3776ab" },
            { name: "协同过滤", color: "#e44d26" },
            { name: "外挂规则拦截", color: "#ff6d00" }
          ]
        }
      ],
      systemInfo: [
        { label: "系统名称", value: "健康饮食推荐系统" },
        { label: "系统版本", value: "v3.9.0" },
        { label: "框架版本", value: "Spring Boot 2.5.x" },
        { label: "前端框架", value: "Vue.js 2.6.x + Element UI" },
        { label: "数据标准", value: "《中国食物成分表2024》" },
        { label: "膳食指南", value: "《中国居民膳食指南2024》" }
      ]
    }
  },
  created() {
    this.loadQuickStats()
  },
  methods: {
    goTo(path) {
      this.$router.push(path).catch(() => {})
    },
    loadQuickStats() {
      getQuickStats().then(res => {
        if (res.code === 200 && res.data) {
          this.statsCards.forEach(card => {
            if (card.key && res.data[card.key] !== undefined) {
              card.value = res.data[card.key]
            }
          })
        }
      }).catch(() => {})
    }
  }
}
</script>

<style scoped lang="scss">
.home {
  padding: 0 20px 20px;
}

/* ===== 欢迎横幅 ===== */
.welcome-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 36px 40px;
  margin-bottom: 24px;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -10%;
    width: 400px;
    height: 400px;
    border-radius: 50%;
    background: rgba(255,255,255,0.08);
  }

  &::after {
    content: '';
    position: absolute;
    bottom: -40%;
    right: 15%;
    width: 250px;
    height: 250px;
    border-radius: 50%;
    background: rgba(255,255,255,0.05);
  }
}

.banner-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  position: relative;
  z-index: 1;
}

.banner-title {
  color: #fff;
  font-size: 26px;
  font-weight: 700;
  margin: 0 0 12px 0;

  i {
    margin-right: 8px;
  }
}

.banner-desc {
  color: rgba(255,255,255,0.85);
  font-size: 14px;
  margin: 0 0 18px 0;
  max-width: 600px;
  line-height: 1.6;
}

.banner-tags {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.tag {
  padding: 4px 14px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.5px;

  &.tag-primary { background: rgba(99,102,241,0.3); color: #e0e7ff; border: 1px solid rgba(99,102,241,0.4); }
  &.tag-success { background: rgba(16,185,129,0.3); color: #d1fae5; border: 1px solid rgba(16,185,129,0.4); }
  &.tag-warning { background: rgba(245,158,11,0.3); color: #fef3c7; border: 1px solid rgba(245,158,11,0.4); }
  &.tag-info    { background: rgba(139,92,246,0.3); color: #ede9fe; border: 1px solid rgba(139,92,246,0.4); }
}

.version-badge {
  background: rgba(255,255,255,0.2);
  color: #fff;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255,255,255,0.25);
}

/* ===== 数据概览 ===== */
.stats-row {
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg);
  border-radius: 14px;
  padding: 22px 20px;
  display: flex;
  align-items: center;
  gap: 18px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid rgba(0,0,0,0.04);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 24px rgba(0,0,0,0.08);
  }
}

.stat-icon-wrap {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: var(--accent);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  i {
    font-size: 24px;
    color: #fff;
  }
}

.stat-info {
  .stat-value {
    font-size: 28px;
    font-weight: 800;
    color: #1e293b;
    line-height: 1;
  }

  .stat-label {
    font-size: 13px;
    color: #64748b;
    margin-top: 4px;
  }
}

/* ===== 内容区 ===== */
.content-row {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;

  span {
    font-size: 16px;
    font-weight: 600;
    color: #1e293b;

    i {
      margin-right: 6px;
      color: #6366f1;
    }
  }
}

/* ===== 核心功能 ===== */
.feature-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 18px;
}

.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 18px;
  background: #f8fafc;
  border-radius: 12px;
  transition: all 0.3s;

  &:hover {
    background: #f1f5f9;
    transform: translateY(-2px);
  }
}

.feature-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;

  i {
    font-size: 20px;
    color: #fff;
  }
}

.feature-content {
  h4 {
    margin: 0 0 6px 0;
    font-size: 15px;
    font-weight: 600;
    color: #1e293b;
  }

  p {
    margin: 0;
    font-size: 12px;
    color: #64748b;
    line-height: 1.6;
  }
}

/* ===== 快速导航 ===== */
.nav-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 18px 8px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    background: #f1f5f9;
    transform: translateY(-3px);
  }
}

.nav-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;

  i {
    font-size: 22px;
    color: #fff;
  }
}

.nav-label {
  font-size: 13px;
  color: #475569;
  font-weight: 500;
  text-align: center;
}

/* ===== 技术栈 ===== */
.tech-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.tech-group-title {
  font-size: 13px;
  font-weight: 600;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 8px;
}

.tech-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tech-tag {
  padding: 6px 14px;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  color: var(--tag-color);
  background: color-mix(in srgb, var(--tag-color) 10%, transparent);
  border: 1px solid color-mix(in srgb, var(--tag-color) 20%, transparent);
  transition: all 0.2s;

  &:hover {
    background: color-mix(in srgb, var(--tag-color) 18%, transparent);
    transform: translateY(-1px);
  }
}

/* ===== 系统信息 ===== */
.info-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 0;
  border-bottom: 1px solid #f1f5f9;

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  font-size: 14px;
  color: #64748b;
}

.info-value {
  font-size: 14px;
  color: #1e293b;
  font-weight: 500;
}

/* ===== 响应式 ===== */
@media (max-width: 768px) {
  .welcome-banner {
    padding: 24px 20px;
  }

  .banner-title {
    font-size: 20px;
  }

  .banner-content {
    flex-direction: column;
  }

  .version-badge {
    margin-top: 12px;
  }

  .feature-grid {
    grid-template-columns: 1fr;
  }

  .nav-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
