<script setup>
import { ref, onMounted } from 'vue'
import { Edit, Delete } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const items = ref([])

const newItem = ref({
  name: '',
  description: '',
  status: 'IN_USE',
  purchaseValue: '',
  purchaseDate: '',
  tags: ''
})

const statusOptions = [
  { value: 'IN_USE', label: '使用中' },
  { value: 'STORED', label: '已存储' },
  { value: 'DISPOSED', label: '已处理' }
]

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

// 获取所有物品
const fetchItems = async () => {
  try {
    const response = await fetch('/api/items')
    if (!response.ok) throw new Error('获取数据失败')
    const data = await response.json()
    items.value = data.map(item => ({
      ...item,
      price: item.purchaseValue,
      tags: Array.isArray(item.tags) ? item.tags.join(',') : ''
    }))
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 添加新物品
const addItem = async () => {
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
    await fetchItems() // 重新获取列表

    // 重置表单
    newItem.value = {
      name: '',
      description: '',
      status: 'IN_USE',
      price: '',
      purchaseDate: '',
      tags: ''
    }
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
    await fetchItems() // 重新获取列表
  } catch (error) {
    ElMessage.error(error.message)
  }
}

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
    await fetchItems() // 重新获取列表
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 页面加载时获取数据
onMounted(() => {
  fetchItems()
})
</script>

<template>
  <div class="content-container">
    <div class="content-wrapper">
      <div class="list-section">
        <h2>物品列表</h2>
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>名称</th>
                <th>描述</th>
                <th>状态</th>
                <th>购买价格</th>
                <th>购买日期</th>
                <th>标签</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in items" :key="item.id">
                <td>{{ item.name }}</td>
                <td>{{ item.description }}</td>
                <td>
                  <span :class="['status-tag', item.status.toLowerCase()]">
                    {{ statusOptions.find(opt => opt.value === item.status)?.label || item.status }}
                  </span>
                </td>
                <td>¥{{ item.purchaseValue }}</td>
                <td>{{ new Date(item.purchaseDate).toLocaleDateString() }}</td>
                <td>
                  <span v-for="tag in (Array.isArray(item.tags) ? item.tags : item.tags.split(','))"
                        :key="tag"
                        class="tag">
                    {{ tag.trim() }}
                  </span>
                </td>
                <td class="actions">
                  <el-button
                    type="primary"
                    circle
                    class="action-btn"
                    @click="handleEdit(item)"
                    title="编辑"
                  >
                    <el-icon><Edit /></el-icon>
                  </el-button>
                  <el-button
                    type="danger"
                    circle
                    class="action-btn"
                    @click="deleteItem(item.id)"
                    title="删除"
                  >
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="form-section">
        <h2>添加新物品</h2>
        <form @submit.prevent="addItem">
          <div class="form-group">
            <label>名称</label>
            <input v-model="newItem.name" required placeholder="请输入物品名称">
          </div>

          <div class="form-group">
            <label>描述</label>
            <textarea v-model="newItem.description" placeholder="请输入物品描述"></textarea>
          </div>

          <div class="form-group">
            <label>状态</label>
            <select v-model="newItem.status">
              <option v-for="option in statusOptions" :key="option.value" :value="option.value">
                {{ option.label }}
              </option>
            </select>
          </div>

          <div class="form-group">
            <label>购买价格</label>
            <div class="price-input">
              <span class="currency-symbol">¥</span>
              <input type="number" v-model="newItem.price" step="0.01" placeholder="0.00">
            </div>
          </div>

          <div class="form-group">
            <label>购买日期</label>
            <input type="date" v-model="newItem.purchaseDate">
          </div>

          <div class="form-group">
            <label>标签</label>
            <input v-model="newItem.tags" placeholder="使用逗号分隔多个标签">
          </div>

          <button type="submit" class="btn save">
            <span class="icon">+</span>
            添加物品
          </button>
        </form>
      </div>
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑物品"
      width="500px"
    >
      <div class="form-group">
        <label>名称</label>
        <input v-model="editingItem.name" required placeholder="请输入物品名称">
      </div>

      <div class="form-group">
        <label>描述</label>
        <textarea v-model="editingItem.description" placeholder="请输入物品描述"></textarea>
      </div>

      <div class="form-group">
        <label>状态</label>
        <select v-model="editingItem.status">
          <option v-for="option in statusOptions" :key="option.value" :value="option.value">
            {{ option.label }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label>购买价格</label>
        <div class="price-input">
          <span class="currency-symbol">¥</span>
          <input type="number" v-model="editingItem.purchaseValue" step="0.01" placeholder="0.00">
        </div>
      </div>

      <div class="form-group">
        <label>购买日期</label>
        <input type="date" v-model="editingItem.purchaseDate">
      </div>

      <div class="form-group">
        <label>标签</label>
        <input v-model="editingItem.tags" placeholder="使用逗号分隔多个标签">
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveEdit">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.content-container {
  background-color: #fafafa;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  min-width: 1200px;
  margin: 0 auto;
}

.content-wrapper {
  display: flex;
  gap: 2rem;
}

.list-section {
  flex: 3;
  background-color: #ffffff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.form-section {
  flex: 1;
  min-width: 380px;
  background-color: #ffffff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

h2 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 1.5rem;
}

.table-container {
  margin-top: 1rem;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

th, td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #ebeef5;
  font-size: 0.875rem;
}

th {
  background-color: #f8f9fa;
  color: #606266;
  font-weight: 500;
}

.status-tag {
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
}

.status-tag.in_use {
  background-color: #e1f3d8;
  color: #67c23a;
}

.status-tag.stored {
  background-color: #e8f4ff;
  color: #409eff;
}

.status-tag.disposed {
  background-color: #fef0f0;
  color: #f56c6c;
}

.tag {
  display: inline-block;
  padding: 0.2rem 0.5rem;
  background-color: #f0f2f5;
  color: #606266;
  border-radius: 4px;
  margin: 0.1rem;
  font-size: 0.75rem;
}

.form-group {
  margin-bottom: 1.25rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  color: #606266;
  font-size: 0.875rem;
}

input, select, textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 0.875rem;
  transition: all 0.3s;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #409eff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

textarea {
  height: 100px;
  resize: vertical;
}

.price-input {
  position: relative;
}

.currency-symbol {
  position: absolute;
  left: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: #606266;
}

.price-input input {
  padding-left: 1.5rem;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.3s;
}

.edit {
  background-color: #409eff;
  color: white;
}

.edit:hover {
  background-color: #66b1ff;
}

.delete {
  background-color: #f56c6c;
  color: white;
  margin-left: 0.5rem;
}

.delete:hover {
  background-color: #f78989;
}

.save {
  background-color: #67c23a;
  color: white;
  width: 100%;
  padding: 0.75rem;
  font-size: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.save:hover {
  background-color: #85ce61;
}

.icon {
  font-size: 1.2rem;
  font-weight: bold;
}

/* 响应式设计优化 */
@media (max-width: 1440px) {
  .content-container {
    min-width: auto;
    width: 100%;
    padding: 1.5rem;
  }

  .content-wrapper {
    gap: 1.5rem;
  }

  .list-section, .form-section {
    padding: 1.5rem;
  }
}

@media (max-width: 1200px) {
  .content-wrapper {
    flex-direction: column;
  }

  .list-section, .form-section {
    flex: none;
    width: 100%;
    min-width: auto;
  }

  .form-section {
    margin-top: 1.5rem;
  }
}

@media (max-width: 768px) {
  .content-container {
    padding: 1rem;
  }

  .list-section, .form-section {
    padding: 1rem;
  }
}

.actions {
  white-space: nowrap;
}

.action-btn {
  padding: 6px;
  margin: 0 3px;
}

.action-btn :deep(.el-icon) {
  font-size: 14px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 确保对话框中的表单样式与主表单一致 */
:deep(.el-dialog) {
  border-radius: 8px;
}

:deep(.el-dialog__header) {
  margin-bottom: 20px;
}

:deep(.el-dialog__body) {
  padding: 0 20px;
}

:deep(.el-dialog__footer) {
  padding: 20px;
}
</style>
