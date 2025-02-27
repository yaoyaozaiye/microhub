<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div class="app-container">
    <h1 class="app-title">物品管理系统</h1>
    <div class="nav-container">
      <div class="nav-links">
        <RouterLink to="/" class="nav-item">首页</RouterLink>
        <RouterLink to="/about" class="nav-item">关于</RouterLink>
      </div>
    </div>
    <RouterView />
  </div>
</template>

<style scoped>
.app-container {
  padding: 2rem 4rem;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  max-width: 1920px;
  margin: 0 auto;
}

.app-title {
  font-size: 2rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 1rem;
  letter-spacing: 1px;
}

.nav-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #e8e8e8;
  padding-bottom: 1rem;
  margin-bottom: 2rem;
}

.nav-links {
  display: flex;
  gap: 1rem;
}

.nav-item {
  text-decoration: none;
  color: #606266;
  margin-right: 1.5rem;
  padding: 0.5rem 1.2rem;
  font-size: 1rem;
  transition: all 0.3s ease;
  border-radius: 6px;
}

.nav-item:hover {
  color: #409eff;
  background-color: #ecf5ff;
}

.nav-item.router-link-active {
  color: #409eff;
  background-color: #ecf5ff;
  font-weight: 500;
}

@media (max-width: 1440px) {
  .app-container {
    padding: 2rem;
  }
}

@media (max-width: 768px) {
  .app-container {
    padding: 1rem;
  }
}
</style>
