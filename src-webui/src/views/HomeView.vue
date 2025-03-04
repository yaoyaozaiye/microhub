<script setup>
import { ref, computed } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import ItemManagement from '../components/ItemManagement.vue'
import { ElMessage } from 'element-plus'

const showAddItemDialog = ref(false)
const newItem = ref({
  name: '',
  description: '',
  status: 'IN_USE',
  price: '',
  purchaseDate: '',
  tags: ''
})

const statusOptions = [
  { value: 'IN_USE', label: '使用中' },
  { value: 'STORED', label: '已存储' },
  { value: 'DISPOSED', label: '已处理' }
]

const itemManagementRef = ref(null)

const isMobile = computed(() => {
  return window.innerWidth <= 768
})

const handleSubmit = async () => {
  try {
    const itemData = {
      name: newItem.value.name,
      description: newItem.value.description,
      status: newItem.value.status,
      purchaseValue: Number(newItem.value.price),
      purchaseDate: new Date(newItem.value.purchaseDate).toISOString(),
      tags: newItem.value.tags.split(',').map(tag => tag.trim()).filter(tag => tag)
    }

    const response = await fetch('/api/items', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(itemData)
    })

    if (!response.ok) throw new Error('添加物品失败')

    ElMessage.success('添加成功')
    showAddItemDialog.value = false

    // 重置表单
    newItem.value = {
      name: '',
      description: '',
      status: 'IN_USE',
      price: '',
      purchaseDate: '',
      tags: ''
    }

    // 刷新列表
    await itemManagementRef.value.fetchItems()
  } catch (error) {
    ElMessage.error(error.message)
  }
}
</script>

<template>
  <div class="home-container">
    <div class="home-header">
      <h2>物品列表</h2>
      <el-button type="primary" @click="showAddItemDialog = true">
        <el-icon><Plus /></el-icon>
        添加物品
      </el-button>
    </div>

    <ItemManagement ref="itemManagementRef" />

    <!-- 添加物品的对话框 -->
    <el-dialog
      v-model="showAddItemDialog"
      title="添加新物品"
      :width="isMobile ? '95%' : '500px'"
      class="add-item-dialog"
    >
      <el-form @submit.prevent="handleSubmit" label-position="top">
        <el-form-item label="名称">
          <el-input v-model="newItem.name" placeholder="请输入物品名称" />
        </el-form-item>

        <el-form-item label="描述">
          <el-input
            v-model="newItem.description"
            type="textarea"
            placeholder="请输入物品描述"
          />
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="newItem.status" placeholder="请选择状态">
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
            v-model="newItem.price"
            type="number"
            placeholder="请输入购买价格"
          >
            <template #prefix>¥</template>
          </el-input>
        </el-form-item>

        <el-form-item label="购买日期">
          <el-date-picker
            v-model="newItem.purchaseDate"
            type="date"
            placeholder="选择日期"
          />
        </el-form-item>

        <el-form-item label="标签">
          <el-input
            v-model="newItem.tags"
            placeholder="使用逗号分隔多个标签"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddItemDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.home-container {
  padding: 1rem;
}

.home-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.home-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #2c3e50;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-dialog__body) {
  padding: 20px 30px;
}

/* 移动端适配样式 */
@media screen and (max-width: 768px) {
  .home-container {
    padding: 0;
  }

  .home-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
    padding: 1rem;
  }

  .home-header h2 {
    text-align: center;
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

  :deep(.el-input),
  :deep(.el-textarea__inner),
  :deep(.el-date-picker),
  :deep(.el-select) {
    width: 100% !important;
    max-width: 100%;
  }

  :deep(.el-form-item__label) {
    padding-bottom: 4px;
  }

  :deep(.dialog-footer) {
    padding: 10px 0;
  }

  :deep(.el-button) {
    width: 100%;
    margin-left: 0 !important;
  }

  .dialog-footer {
    flex-direction: column;
    width: 100%;
  }
}
</style>
