<template>
  <div class="app-container" style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 80vh;">
    <el-empty description="该模块已精简下线" :image-size="250">
      <div style="color: #909399; font-size: 15px; margin-top: 10px; line-height: 1.8;">
        按照业务收敛原则，此界面的前端图表源码与后端接口计算引擎均已被永久物理移除。<br/>
        为保证当前左侧菜单视觉的纯净度，请前往后台【系统管理】 - 【菜单管理】中彻底将其封禁删除。
      </div>
    </el-empty>
  </div>
</template>

<script>
export default {
  name: "DietAnalysisOffline"
}
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
