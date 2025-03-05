<script setup>
import { RouterLink, RouterView } from 'vue-router'
import { ref } from 'vue'
import { Search } from '@element-plus/icons-vue'

const searchQuery = ref('')

const handleSearch = () => {
  // 这里可以实现搜索逻辑
  console.log('Search query:', searchQuery.value)
}
</script>

<template>
  <div class="app-container">
    <h1 class="app-title">物品管理系统</h1>
    <div class="nav-container">
      <div class="nav-links">
        <RouterLink to="/" class="nav-item">首页</RouterLink>
        <RouterLink to="/about" class="nav-item">关于</RouterLink>
      </div>
      <div class="search-container">
        <el-input
          v-model="searchQuery"
          placeholder="搜索物品..."
          class="search-input"
          :prefix-icon="Search"
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button :icon="Search" @click="handleSearch" />
          </template>
        </el-input>
      </div>
    </div>
    <RouterView />
  </div>
</template>

<style>
:root {
  --el-color-primary: #6750A4;
  --el-color-primary-light-3: #8B7BB8;
  --el-color-primary-light-5: #A599C6;
  --el-color-primary-light-7: #BFB7D4;
  --el-color-primary-light-9: #E9E6F0;
  --el-color-primary-dark-2: #523F83;
}
</style>

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
  color: var(--el-color-primary);
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
  gap: 1rem;
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
  color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
}

.nav-item.router-link-active {
  color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
  font-weight: 500;
}

.search-container {
  flex: 1;
  max-width: 400px;
  margin-left: auto;
}

.search-input {
  width: 100%;
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

  .nav-container {
    flex-direction: column;
    align-items: stretch;
  }

  .search-container {
    max-width: none;
    margin-left: 0;
  }

  .nav-links {
    justify-content: center;
  }
}
</style>
