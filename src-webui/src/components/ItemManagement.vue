<script setup>
import { ref, onMounted, computed } from 'vue'
import { Edit, Delete } from '@element-plus/icons-vue'
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

    <!-- 移动端卡片列表 -->
    <div v-else class="mobile-item-list">
      <el-card v-for="item in items" :key="item.id" class="mobile-item-card">
        <div class="mobile-item-header">
          <h3>{{ item.name }}</h3>
          <el-tag :type="item.status === 'IN_USE' ? 'success' : item.status === 'STORED' ? 'info' : 'warning'">
            {{ statusOptions.find(opt => opt.value === item.status)?.label }}
          </el-tag>
        </div>

        <div class="mobile-item-content">
          <p v-if="item.description" class="description">{{ item.description }}</p>

          <div class="info-row">
            <span class="label">购买价格:</span>
            <span class="value">¥{{ item.purchaseValue }}</span>
          </div>

          <div class="info-row">
            <span class="label">购买日期:</span>
            <span class="value">{{ new Date(item.purchaseDate).toLocaleDateString() }}</span>
          </div>

          <div class="tags-row" v-if="item.tags && item.tags.length">
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

        <div class="mobile-item-actions">
          <el-button type="primary" :icon="Edit" @click="handleEdit(item)">编辑</el-button>
          <el-button type="danger" :icon="Delete" @click="deleteItem(item.id)">删除</el-button>
        </div>
      </el-card>
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑物品"
      :width="isMobile ? '95%' : '500px'"
    >
      <el-form>
        <el-form-item label="名称">
          <el-input v-model="editingItem.name" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="editingItem.description"
            type="textarea"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingItem.status">
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
          >
            <template #prefix>¥</template>
          </el-input>
        </el-form-item>
        <el-form-item label="购买日期">
          <el-date-picker
            v-model="editingItem.purchaseDate"
            type="date"
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
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.mobile-item-card {
  margin-bottom: 0;
}

.mobile-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.mobile-item-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.mobile-item-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.description {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.info-row .label {
  color: #909399;
}

.tags-row {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-top: 8px;
}

.mobile-item-actions {
  display: flex;
  gap: 8px;
  margin-top: 16px;
}

.mobile-item-actions .el-button {
  flex: 1;
}

@media screen and (max-width: 768px) {
  .table-container {
    padding: 12px;
  }

  :deep(.el-dialog) {
    margin: 0 !important;
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    border-radius: 20px 20px 0 0;
    max-height: 90vh;
    overflow-y: auto;
  }

  :deep(.el-dialog__body) {
    padding: 15px;
    max-height: calc(90vh - 120px);
    overflow-y: auto;
  }

  :deep(.el-form-item) {
    margin-bottom: 15px;
  }
}
</style>
