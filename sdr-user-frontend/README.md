# 健康饮食助手 - 用户端前端

这是一个基于 React + TailwindCSS + shadcn/ui 构建的健康饮食类网站用户端首页框架。

## 🌟 特性

- ✅ **现代化设计**：采用清新、优雅的视觉风格，适合健康饮食主题
- ✅ **响应式布局**：完美适配桌面端和移动端
- ✅ **组件化架构**：基于 shadcn/ui 的可复用组件系统
- ✅ **TypeScript 支持**：完整的类型安全保障
- ✅ **TailwindCSS**：实用优先的CSS框架，快速样式开发

## 🎨 设计亮点

### 配色方案
- **主色调**：清新的绿色系（健康、自然）
- **辅助色**：温暖的黄色系（活力、营养）
- **点缀色**：清爽的蓝色系（信任、专业）

### 布局结构
- **顶部导航栏**：品牌标识、搜索框、用户信息
- **左侧边栏**：导航菜单、快捷统计、设置入口
- **主内容区**：卡片式布局，展示仪表板数据

### 组件特点
- **卡片式设计**：圆角、阴影、渐变效果
- **图标系统**：Lucide React 图标库
- **动画效果**：平滑的过渡和悬停效果
- **渐变背景**：柔和的渐变色背景

## 📁 项目结构

```
sdr-user-frontend/
├── src/
│   ├── components/
│   │   ├── ui/              # 基础UI组件
│   │   │   ├── Button.tsx   # 按钮组件
│   │   │   └── Card.tsx     # 卡片组件
│   │   ├── DashboardCards.tsx  # 仪表板卡片
│   │   ├── Layout.tsx       # 主布局组件
│   │   ├── Navbar.tsx       # 顶部导航栏
│   │   └── Sidebar.tsx      # 侧边栏
│   ├── lib/
│   │   └── utils.ts         # 工具函数
│   ├── App.tsx              # 主应用组件
│   ├── index.css           # 全局样式
│   └── index.tsx           # 应用入口
├── tailwind.config.js      # Tailwind配置
├── postcss.config.js       # PostCSS配置
└── package.json            # 项目依赖
```

## 🚀 快速开始

### 1. 安装依赖

确保您已经在 `sdr-user-frontend` 目录中：

```bash
cd sdr-user-frontend
npm install
```

### 2. 启动开发服务器

```bash
npm start
```

应用将在 [http://localhost:3000](http://localhost:3000) 上运行。

### 3. 构建生产版本

```bash
npm run build
```

构建文件将输出到 `build` 目录。

## 🎯 主要功能模块

### 仪表板概览
- **营养摄入统计**：卡路里、水分、运动、健康评分
- **快捷操作**：记录饮食、扫码识别、智能推荐
- **饮食记录**：今日餐食记录和历史数据
- **趋势分析**：体重变化、营养达标情况

### 导航系统
- **首页**：个人健康仪表板
- **饮食记录**：详细的饮食日志
- **食物库**：营养成分查询
- **营养目标**：个性化目标设定
- **健康报告**：数据分析和趋势
- **食谱推荐**：AI驱动的智能推荐
- **社区**：用户交流平台
- **收藏**：个人收藏管理

### 用户体验
- **响应式设计**：移动端友好的交互体验
- **快捷统计**：侧边栏实时营养摄入显示
- **视觉反馈**：进度条、徽章、颜色编码
- **个性化内容**：基于用户数据的定制化展示

## 🛠️ 技术栈

- **React 18**：现代化的前端框架
- **TypeScript**：类型安全的JavaScript超集
- **TailwindCSS**：实用优先的CSS框架
- **Lucide React**：精美的图标库
- **shadcn/ui**：组件设计系统
- **Class Variance Authority**：条件样式管理
- **clsx & tailwind-merge**：CSS类名工具

## 🎨 自定义主题

您可以在 `tailwind.config.js` 中自定义主题：

```javascript
theme: {
  extend: {
    colors: {
      primary: {
        // 自定义主色调
      },
      secondary: {
        // 自定义辅助色
      }
    }
  }
}
```

## 📱 响应式断点

- **mobile**：< 768px
- **tablet**：768px - 1024px  
- **desktop**：> 1024px

## 🚀 部署建议

### 静态部署
推荐使用以下平台进行静态部署：
- Vercel
- Netlify
- GitHub Pages
- 腾讯云静态网站

### 构建优化
- 启用代码分割
- 压缩资源文件
- 配置CDN加速
- 开启Gzip压缩

## 📖 开发规范

### 组件开发
- 使用 TypeScript 进行类型定义
- 遵循 React Hooks 最佳实践
- 保持组件的单一职责原则
- 使用 forwardRef 支持ref传递

### 样式规范
- 优先使用 Tailwind 实用类
- 复杂样式可定义在 @layer components
- 保持设计系统的一致性
- 遵循移动优先的响应式设计

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。