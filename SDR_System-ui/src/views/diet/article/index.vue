<template>
  <div class="app-container">
    <!-- 搜索区 -->
    <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="68px">
      <el-form-item label="关键词" prop="keyword">
        <el-input v-model="queryParams.keyword" placeholder="搜索标题或内容" clearable size="small" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="全部" clearable size="small">
          <el-option label="已发布" value="0" />
          <el-option label="已下架" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
        <el-button type="success" icon="el-icon-plus" size="mini" @click="handleAdd">新增文章</el-button>
      </el-form-item>
    </el-form>

    <!-- 文章列表 -->
    <el-table v-loading="loading" :data="articleList" border stripe>
      <el-table-column label="ID" prop="article_id" width="70" align="center" />
      <el-table-column label="标题" prop="title" min-width="200" show-overflow-tooltip />
      <el-table-column label="作者" prop="author" width="120" align="center" />
      <el-table-column label="浏览量" prop="view_count" width="80" align="center" />
      <el-table-column label="状态" width="90" align="center">
        <template slot-scope="scope">
          <el-switch :value="scope.row.status === '0'" active-color="#13ce66" inactive-color="#ff4949"
                     @change="toggleStatus(scope.row)" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="create_time" width="160" align="center" />
      <el-table-column label="操作" width="180" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" style="color: #f56c6c" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑对话框 -->
    <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="700px" append-to-body>
      <el-form :model="form" ref="articleForm" label-width="80px" :rules="rules">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入文章标题" />
        </el-form-item>
        <el-form-item label="作者" prop="author">
          <el-input v-model="form.author" placeholder="请输入作者" />
        </el-form-item>
        <el-form-item label="封面图" prop="coverImage">
          <el-input v-model="form.coverImage" placeholder="封面图URL（可选）" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="0">发布</el-radio>
            <el-radio label="1">草稿</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="正文" prop="content">
          <el-input type="textarea" v-model="form.content" :rows="12" placeholder="请输入文章正文内容" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'ArticleManagement',
  data() {
    return {
      loading: false,
      articleList: [],
      queryParams: { keyword: '', status: '' },
      dialogVisible: false,
      dialogTitle: '新增文章',
      isEdit: false,
      editId: null,
      form: { title: '', author: '系统管理员', content: '', coverImage: '', status: '0' },
      rules: {
        title: [{ required: true, message: '标题不能为空', trigger: 'blur' }],
        content: [{ required: true, message: '正文不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.loadArticles()
  },
  methods: {
    loadArticles() {
      this.loading = true
      const params = {}
      if (this.queryParams.keyword) params.keyword = this.queryParams.keyword
      if (this.queryParams.status) params.status = this.queryParams.status
      request({ url: '/api/user/diet/article/admin/list', method: 'get', params }).then(res => {
        this.articleList = res.data || []
      }).finally(() => { this.loading = false })
    },
    handleQuery() { this.loadArticles() },
    resetQuery() {
      this.queryParams = { keyword: '', status: '' }
      this.loadArticles()
    },
    handleAdd() {
      this.dialogTitle = '新增文章'
      this.isEdit = false
      this.editId = null
      this.form = { title: '', author: '系统管理员', content: '', coverImage: '', status: '0' }
      this.dialogVisible = true
    },
    handleEdit(row) {
      this.dialogTitle = '编辑文章'
      this.isEdit = true
      this.editId = row.article_id
      // 拉取详情
      request({ url: '/api/user/diet/article/admin/' + row.article_id, method: 'get' }).then(res => {
        const d = res.data
        this.form = {
          title: d.title || '',
          author: d.author || '',
          content: d.content || '',
          coverImage: d.cover_image || '',
          status: d.status || '0'
        }
        this.dialogVisible = true
      })
    },
    submitForm() {
      this.$refs.articleForm.validate(valid => {
        if (!valid) return
        if (this.isEdit) {
          request({ url: '/api/user/diet/article/admin/' + this.editId, method: 'put', data: this.form }).then(() => {
            this.$message.success('修改成功')
            this.dialogVisible = false
            this.loadArticles()
          })
        } else {
          request({ url: '/api/user/diet/article/admin', method: 'post', data: this.form }).then(() => {
            this.$message.success('发布成功')
            this.dialogVisible = false
            this.loadArticles()
          })
        }
      })
    },
    handleDelete(row) {
      this.$confirm('确认删除文章「' + row.title + '」？', '提示', { type: 'warning' }).then(() => {
        request({ url: '/api/user/diet/article/admin/' + row.article_id, method: 'delete' }).then(() => {
          this.$message.success('删除成功')
          this.loadArticles()
        })
      }).catch(() => {})
    },
    toggleStatus(row) {
      request({ url: '/api/user/diet/article/admin/toggle-status/' + row.article_id, method: 'put' }).then(res => {
        this.$message.success(res.msg)
        this.loadArticles()
      })
    }
  }
}
</script>
