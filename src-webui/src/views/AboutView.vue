<script setup>
import { ref, onMounted } from 'vue'
import { ElCard } from 'element-plus'
import {
  Box,
  TrendCharts,
  User,
  Calendar,
  Money,
  Collection,
  Histogram
} from '@element-plus/icons-vue'

const stats = ref({
  totalItems: 0,
  totalValue: 0,
  itemCategories: 0,
  lastUpdate: ''
})

// 模拟获取统计数据
const fetchStats = async () => {
  try {
    const response = await fetch('/api/items')
    const items = await response.json()

    stats.value = {
      totalItems: items.length,
      totalValue: items.reduce((sum, item) => sum + (item.purchaseValue || 0), 0),
      itemCategories: new Set(items.map(item => item.status)).size,
      lastUpdate: new Date().toLocaleDateString()
    }
  } catch (error) {
    console.error('获取统计数据失败:', error)
  }
}

onMounted(() => {
  fetchStats()
})
</script>

<template>
  <div class="about-container">
    <div class="header-section">
      <h1>关于物品管理系统</h1>
      <p class="subtitle">追踪、管理、优化你的物品清单</p>
    </div>

    <div class="stats-section">
      <el-card class="stat-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><Box /></el-icon>
            <span>总物品数</span>
          </div>
        </template>
        <div class="stat-value">{{ stats.totalItems }}</div>
        <div class="stat-label">件物品</div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><Money /></el-icon>
            <span>总价值</span>
          </div>
        </template>
        <div class="stat-value">¥{{ stats.totalValue.toFixed(2) }}</div>
        <div class="stat-label">资产总值</div>
      </el-card>

      <el-card class="stat-card" shadow="hover">
        <template #header>
          <div class="card-header">
            <el-icon><Collection /></el-icon>
            <span>物品分类</span>
          </div>
        </template>
        <div class="stat-value">{{ stats.itemCategories }}</div>
        <div class="stat-label">种类别</div>
      </el-card>
    </div>

    <div class="features-section">
      <h2>主要功能</h2>
      <div class="features-grid">
        <div class="feature-item">
          <el-icon><TrendCharts /></el-icon>
          <h3>数据追踪</h3>
          <p>实时监控物品状态和价值变化</p>
        </div>
        <div class="feature-item">
          <el-icon><Histogram /></el-icon>
          <h3>统计分析</h3>
          <p>多维度分析物品分布情况</p>
        </div>
        <div class="feature-item">
          <el-icon><User /></el-icon>
          <h3>便捷管理</h3>
          <p>简单直观的操作界面</p>
        </div>
        <div class="feature-item">
          <el-icon><Calendar /></el-icon>
          <h3>时间记录</h3>
          <p>完整的物品生命周期追踪</p>
        </div>
      </div>
    </div>

    <div class="footer-section">
      <p>最后更新时间：{{ stats.lastUpdate }}</p>
      <p class="copyright">© 2024 物品管理系统 - 让生活更有序</p>
    </div>
  </div>
</template>

<style scoped>
.about-container {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.header-section {
  text-align: center;
  margin-bottom: 3rem;
  animation: fadeInDown 0.8s ease;
}

.header-section h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 1rem;
}

.subtitle {
  font-size: 1.2rem;
  color: #606266;
}

.stats-section {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 4rem;
}

.stat-card {
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  color: #409eff;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #2c3e50;
  margin: 1rem 0;
}

.stat-label {
  color: #909399;
  font-size: 0.9rem;
}

.features-section {
  margin-bottom: 4rem;
  animation: fadeInUp 0.8s ease;
}

.features-section h2 {
  text-align: center;
  margin-bottom: 2rem;
  color: #2c3e50;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 2rem;
}

.feature-item {
  text-align: center;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.feature-item:hover {
  background: #fff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-5px);
}

.feature-item .el-icon {
  font-size: 2.5rem;
  color: #409eff;
  margin-bottom: 1rem;
}

.feature-item h3 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.feature-item p {
  color: #606266;
  font-size: 0.9rem;
}

.footer-section {
  text-align: center;
  color: #909399;
  font-size: 0.9rem;
  margin-top: 4rem;
  padding-top: 2rem;
  border-top: 1px solid #ebeef5;
}

.copyright {
  margin-top: 0.5rem;
  font-weight: 500;
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .about-container {
    padding: 1rem;
  }

  .header-section h1 {
    font-size: 2rem;
  }

  .stat-value {
    font-size: 2rem;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style>
