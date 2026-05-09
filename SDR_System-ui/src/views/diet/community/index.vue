<template>
  <div class="app-container">
    <!-- 搜索区 -->
    <el-form :model="queryParams" ref="queryForm" :inline="true" label-width="68px">
      <el-form-item label="关键词" prop="keyword">
        <el-input v-model="queryParams.keyword" placeholder="搜索帖子内容" clearable size="small" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="delFlag">
        <el-select v-model="queryParams.delFlag" placeholder="全部" clearable size="small">
          <el-option label="正常" value="0" />
          <el-option label="已删除" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 帖子列表 -->
    <el-table v-loading="loading" :data="postList" border stripe>
      <el-table-column label="ID" prop="post_id" width="70" align="center" />
      <el-table-column label="用户" width="120" align="center">
        <template slot-scope="scope">{{ scope.row.nick_name || scope.row.user_name || '-' }}</template>
      </el-table-column>
      <el-table-column label="内容" prop="content" min-width="300" show-overflow-tooltip />
      <el-table-column label="点赞" prop="like_count" width="70" align="center" />
      <el-table-column label="评论" prop="comment_count" width="70" align="center" />
      <el-table-column label="状态" width="80" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.del_flag === '0' ? 'success' : 'danger'" size="small">
            {{ scope.row.del_flag === '0' ? '正常' : '已删除' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" prop="create_time" width="160" align="center" />
      <el-table-column label="操作" width="200" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="viewComments(scope.row)">评论</el-button>
          <el-button v-if="scope.row.del_flag === '0'" size="mini" type="text" icon="el-icon-delete" style="color: #f56c6c" @click="handleDelete(scope.row)">删除</el-button>
          <el-button v-else size="mini" type="text" icon="el-icon-refresh-right" @click="handleRestore(scope.row)">恢复</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 评论抽屉 -->
    <el-drawer :title="'帖子评论管理 #' + (currentPost ? currentPost.post_id : '')" :visible.sync="commentDrawerVisible" size="50%">
      <div style="padding: 0 20px">
        <div v-if="currentPost" style="margin-bottom: 16px; padding: 12px; background: #f5f7fa; border-radius: 8px; font-size: 14px; color: #606266; line-height: 1.6">
          <strong>{{ currentPost.nick_name || '匿名' }}：</strong>{{ currentPost.content }}
        </div>
        <el-table v-loading="commentLoading" :data="commentList" border stripe size="small">
          <el-table-column label="ID" prop="comment_id" width="70" align="center" />
          <el-table-column label="用户" width="100" align="center">
            <template slot-scope="scope">{{ scope.row.nick_name || scope.row.user_name || '-' }}</template>
          </el-table-column>
          <el-table-column label="评论内容" prop="content" min-width="200" show-overflow-tooltip />
          <el-table-column label="点赞" prop="like_count" width="60" align="center" />
          <el-table-column label="时间" prop="create_time" width="150" align="center" />
          <el-table-column label="操作" width="80" align="center">
            <template slot-scope="scope">
              <el-button size="mini" type="text" icon="el-icon-delete" style="color: #f56c6c" @click="deleteComment(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-drawer>

    <!-- 敏感词管理 -->
    <el-divider content-position="left">敏感词管理</el-divider>
    <div style="margin-bottom: 12px">
      <el-input v-model="newWord" placeholder="输入新增敏感词" size="small" style="width: 200px; margin-right: 10px" @keyup.enter.native="addWord" />
      <el-button type="primary" size="mini" icon="el-icon-plus" @click="addWord">添加</el-button>
    </div>
    <div>
      <el-tag v-for="item in sensitiveWords" :key="item.word_id" closable type="danger" style="margin: 0 8px 8px 0" @close="deleteWord(item)">
        {{ item.word }}
      </el-tag>
      <span v-if="sensitiveWords.length === 0" style="color: #909399; font-size: 13px">暂无敏感词</span>
    </div>
  </div>
</template>

<script>
import request from '@/utils/request'

export default {
  name: 'CommunityManagement',
  data() {
    return {
      loading: false,
      postList: [],
      queryParams: { keyword: '', delFlag: '' },
      // 评论
      commentDrawerVisible: false,
      currentPost: null,
      commentLoading: false,
      commentList: [],
      // 敏感词
      sensitiveWords: [],
      newWord: ''
    }
  },
  created() {
    this.loadPosts()
    this.loadSensitiveWords()
  },
  methods: {
    loadPosts() {
      this.loading = true
      const params = {}
      if (this.queryParams.keyword) params.keyword = this.queryParams.keyword
      if (this.queryParams.delFlag) params.delFlag = this.queryParams.delFlag
      request({ url: '/api/user/diet/community/admin/list', method: 'get', params }).then(res => {
        this.postList = res.data || []
      }).finally(() => { this.loading = false })
    },
    handleQuery() { this.loadPosts() },
    resetQuery() {
      this.queryParams = { keyword: '', delFlag: '' }
      this.loadPosts()
    },
    handleDelete(row) {
      this.$confirm('确认删除该帖子？', '提示', { type: 'warning' }).then(() => {
        request({ url: '/api/user/diet/community/admin/' + row.post_id, method: 'delete' }).then(() => {
          this.$message.success('删除成功')
          this.loadPosts()
        })
      }).catch(() => {})
    },
    handleRestore(row) {
      request({ url: '/api/user/diet/community/admin/restore/' + row.post_id, method: 'put' }).then(() => {
        this.$message.success('恢复成功')
        this.loadPosts()
      })
    },
    // 评论管理
    viewComments(row) {
      this.currentPost = row
      this.commentDrawerVisible = true
      this.loadComments(row.post_id)
    },
    loadComments(postId) {
      this.commentLoading = true
      request({ url: '/api/user/diet/community/admin/comments/' + postId, method: 'get' }).then(res => {
        this.commentList = res.data || []
      }).finally(() => { this.commentLoading = false })
    },
    deleteComment(row) {
      this.$confirm('确认删除该评论？', '提示', { type: 'warning' }).then(() => {
        request({ url: '/api/user/diet/community/admin/comment/' + row.comment_id, method: 'delete' }).then(() => {
          this.$message.success('删除成功')
          this.loadComments(this.currentPost.post_id)
          this.loadPosts()
        })
      }).catch(() => {})
    },
    // 敏感词
    loadSensitiveWords() {
      request({ url: '/api/user/diet/community/admin/sensitive-words', method: 'get' }).then(res => {
        this.sensitiveWords = res.data || []
      })
    },
    addWord() {
      if (!this.newWord.trim()) return
      request({ url: '/api/user/diet/community/admin/sensitive-words', method: 'post', data: { word: this.newWord.trim() } }).then(() => {
        this.$message.success('添加成功')
        this.newWord = ''
        this.loadSensitiveWords()
      }).catch(() => { this.$message.error('添加失败，可能已存在') })
    },
    deleteWord(item) {
      request({ url: '/api/user/diet/community/admin/sensitive-words/' + item.word_id, method: 'delete' }).then(() => {
        this.$message.success('删除成功')
        this.loadSensitiveWords()
      })
    }
  }
}
</script>
