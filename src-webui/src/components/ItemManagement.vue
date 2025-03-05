<script setup>
import { ref, onMounted, computed } from 'vue'
import { Edit, Delete, More } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const items = ref([])

const statusOptions = [
  { value: 'IN_USE', label: '使用中' },
  { value: 'STORED', label: '已存储' },
  { value: 'DISPOSED', label: '已处理' }
]

// 获取所有物品
const fetchItems = async () => {
  try {
    const response = await fetch('/api/items')
    if (!response.ok) throw new Error('获取数据失败')
    const data = await response.json()
    items.value = data.map(item => ({
      ...item,
      tags: Array.isArray(item.tags) ? item.tags.join(',') : ''
    }))
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 删除物品
const deleteItem = async (id) => {
  try {
    const response = await fetch(`/api/items/${id}`, {
      method: 'DELETE'
    })

    if (!response.ok) throw new Error('删除失败')

    ElMessage.success('删除成功')
    await fetchItems()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 编辑相关的状态
const editDialogVisible = ref(false)
const editingItem = ref({
  id: null,
  name: '',
  description: '',
  status: '',
  purchaseValue: '',
  purchaseDate: '',
  tags: ''
})

// 打开编辑对话框
const handleEdit = (item) => {
  editingItem.value = {
    id: item.id,
    name: item.name,
    description: item.description,
    status: item.status,
    purchaseValue: item.purchaseValue,
    purchaseDate: new Date(item.purchaseDate).toISOString().split('T')[0],
    tags: Array.isArray(item.tags) ? item.tags.join(',') : item.tags
  }
  editDialogVisible.value = true
}

// 保存编辑
const saveEdit = async () => {
  try {
    const itemData = {
      name: editingItem.value.name,
      description: editingItem.value.description,
      status: editingItem.value.status,
      purchaseValue: Number(editingItem.value.purchaseValue),
      purchaseDate: new Date(editingItem.value.purchaseDate).toISOString(),
      tags: editingItem.value.tags.split(',').map(tag => tag.trim()).filter(tag => tag)
    }

    const response = await fetch(`/api/items/${editingItem.value.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(itemData)
    })

    if (!response.ok) throw new Error('更新失败')

    ElMessage.success('更新成功')
    editDialogVisible.value = false
    await fetchItems()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 页面加载时获取数据
onMounted(() => {
  fetchItems()
})

// 暴露方法给父组件
defineExpose({
  fetchItems
})

const isMobile = computed(() => {
  return window.innerWidth <= 768
})

const expandedItems = ref(new Set())

const toggleItem = (itemId) => {
  if (expandedItems.value.has(itemId)) {
    expandedItems.value.delete(itemId)
  } else {
    expandedItems.value = new Set([itemId])
  }
}
</script>

<template>
  <div class="table-container">
    <!-- 桌面端表格 -->
    <el-table
      v-if="!isMobile"
      :data="items"
      style="width: 100%"
    >
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="description" label="描述" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'IN_USE' ? 'success' : row.status === 'STORED' ? 'info' : 'warning'">
            {{ statusOptions.find(opt => opt.value === row.status)?.label }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="购买价格" width="120">
        <template #default="{ row }">
          ¥{{ row.purchaseValue }}
        </template>
      </el-table-column>
      <el-table-column label="购买日期" width="120">
        <template #default="{ row }">
          {{ new Date(row.purchaseDate).toLocaleDateString() }}
        </template>
      </el-table-column>
      <el-table-column label="标签">
        <template #default="{ row }">
          <el-tag
            v-for="tag in (Array.isArray(row.tags) ? row.tags : row.tags.split(','))"
            :key="tag"
            size="small"
            class="mx-1"
          >
            {{ tag.trim() }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="{ row }">
          <el-button-group>
            <el-button
              type="primary"
              :icon="Edit"
              size="small"
              @click="handleEdit(row)"
            />
            <el-button
              type="danger"
              :icon="Delete"
              size="small"
              @click="deleteItem(row.id)"
            />
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- 移动端列表 -->
    <div v-else class="mobile-item-list">
      <!-- 表头 -->
      <div class="mobile-list-header">
        <div class="basic-info-row">
          <div class="name">名称</div>
          <div class="description">描述</div>
          <div class="price">价格</div>
        </div>
      </div>

      <!-- 列表内容 -->
      <div
        v-for="item in items"
        :key="item.id"
        class="mobile-item"
        @click="toggleItem(item.id)"
      >
        <div class="mobile-item-header">
          <div class="mobile-item-basic">
            <div class="basic-info-row">
              <h3 class="name">{{ item.name }}</h3>
              <p class="description">{{ item.description }}</p>
              <div class="price">¥{{ item.purchaseValue }}</div>
            </div>
          </div>
        </div>

        <!-- 展开后显示的详细信息 -->
        <div v-show="expandedItems.has(item.id)" class="mobile-item-details">
          <div class="info-row">
            <span class="label">状态:</span>
            <el-tag :type="item.status === 'IN_USE' ? 'success' : item.status === 'STORED' ? 'info' : 'warning'">
              {{ statusOptions.find(opt => opt.value === item.status)?.label }}
            </el-tag>
          </div>

          <div class="info-row">
            <span class="label">购买日期:</span>
            <span>{{ new Date(item.purchaseDate).toLocaleDateString() }}</span>
          </div>

          <div class="tags-row" v-if="item.tags && item.tags.length">
            <span class="label">标签:</span>
            <div class="tags-container">
              <el-tag
                v-for="tag in (Array.isArray(item.tags) ? item.tags : item.tags.split(','))"
                :key="tag"
                size="small"
                class="mx-1"
              >
                {{ tag.trim() }}
              </el-tag>
            </div>
          </div>

          <div class="action-row">
            <el-button
              type="primary"
              :icon="Edit"
              @click.stop="handleEdit(item)"
            >编辑</el-button>
            <el-button
              type="danger"
              :icon="Delete"
              @click.stop="deleteItem(item.id)"
            >删除</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑物品"
      :width="isMobile ? '95%' : '500px'"
      class="edit-item-dialog"
    >
      <el-form @submit.prevent="saveEdit" label-position="top">
        <el-form-item label="名称">
          <el-input v-model="editingItem.name" placeholder="请输入物品名称" />
        </el-form-item>

        <el-form-item label="描述">
          <el-input
            v-model="editingItem.description"
            type="textarea"
            placeholder="请输入物品描述"
          />
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="editingItem.status" placeholder="请选择状态" style="width: 100%">
            <el-option
              v-for="option in statusOptions"
              :key="option.value"
              :label="option.label"
              :value="option.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="购买价格">
          <el-input
            v-model="editingItem.purchaseValue"
            type="number"
            placeholder="请输入购买价格"
          >
            <template #prefix>¥</template>
          </el-input>
        </el-form-item>

        <el-form-item label="购买日期">
          <el-date-picker
            v-model="editingItem.purchaseDate"
            type="date"
            placeholder="选择日期"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="标签">
          <el-input
            v-model="editingItem.tags"
            placeholder="使用逗号分隔多个标签"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveEdit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.table-container {
  background-color: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-tag) {
  margin: 2px;
}

/* 移动端样式 */
.mobile-item-list {
  background: #fff;
}

.mobile-item {
  padding: 12px 16px;
  border-bottom: 1px solid #EBEEF5;
  cursor: pointer;
  transition: background-color 0.2s;
}

.mobile-item:active {
  background-color: #f5f7fa;
}

.mobile-item-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.mobile-item-basic {
  flex: 1;
}

.basic-info-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.mobile-item-basic h3.name {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  white-space: nowrap;
}

.mobile-item-basic .description {
  margin: 0;
  color: #606266;
  font-size: 14px;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mobile-item-basic .price {
  color: #409EFF;
  font-weight: bold;
  font-size: 16px;
  white-space: nowrap;
}

.mobile-item-details {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #EBEEF5;
}

.info-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.info-row .label {
  width: 70px;
  color: #909399;
  font-size: 14px;
}

.tags-row {
  display: flex;
  margin-bottom: 12px;
}

.tags-row .label {
  width: 70px;
  color: #909399;
  font-size: 14px;
}

.tags-container {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.action-row {
  display: flex;
  gap: 8px;
  margin-top: 16px;
}

.action-row .el-button {
  position: relative;
  z-index: 1;
}

.mobile-list-header {
  background-color: #f5f7fa;
  padding: 12px 16px;
  border-bottom: 1px solid #EBEEF5;
  font-size: 14px;
  color: #909399;
  position: sticky;
  top: 0;
  z-index: 1;
}

.mobile-list-header .basic-info-row {
  padding-right: 0; /* 移除之前为更多按钮预留的空间 */
}

.mobile-list-header .name {
  width: 80px; /* 根据实际内容调整宽度 */
}

.mobile-list-header .description {
  flex: 1;
}

.mobile-list-header .price {
  width: 60px; /* 根据实际内容调整宽度 */
  text-align: right;
}

.mobile-item-basic .name {
  width: 80px; /* 与表头对齐 */
  overflow: hidden;
  text-overflow: ellipsis;
}

.mobile-item-basic .price {
  width: 60px; /* 与表头对齐 */
  text-align: right;
}

/* 确保表头和内容的布局一致 */
.basic-info-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
}

.description {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

@media screen and (max-width: 768px) {
  .table-container {
    padding: 0;
    background: #fff;
  }

  .mobile-item {
    padding: 12px 16px;
    border-bottom: 1px solid #EBEEF5;
  }

  .mobile-item:last-child {
    border-bottom: none;
  }

  .mobile-item:hover {
    background-color: #fafafa;
  }
}
</style>
