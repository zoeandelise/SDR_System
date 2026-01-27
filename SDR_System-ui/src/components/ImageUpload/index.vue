<template>
  <div class="upload-image">
    <el-upload
      multiple
      :action="uploadImageUrl"
      :before-upload="handleBeforeUpload"
      :file-list="fileList"
      :data="data"
      :limit="limit"
      :on-error="handleUploadError"
      :on-exceed="handleExceed"
      :on-success="handleUploadSuccess"
      :show-file-list="false"
      :headers="headers"
      class="upload-image-uploader"
      ref="imageUpload"
      v-if="!disabled"
    >
      <!-- 上传按钮 -->
      <el-button size="mini" type="primary" icon="el-icon-camera">选择图片</el-button>
      <!-- 上传提示 -->
      <div class="el-upload__tip" slot="tip" v-if="showTip">
        请上传
        <template v-if="fileSize"> 大小不超过 <b style="color: #f56c6c">{{ fileSize }}MB</b> </template>
        <template v-if="fileType"> 格式为 <b style="color: #f56c6c">{{ fileType.join("/") }}</b> </template>
        的图片文件
      </div>
    </el-upload>

    <!-- 图片列表 -->
    <div class="upload-image-list" v-if="fileList.length > 0">
      <div 
        class="upload-image-item" 
        v-for="(file, index) in fileList" 
        :key="file.url"
      >
        <el-image
          :src="getImageUrl(file.url)"
          :preview-src-list="previewList"
          fit="cover"
          class="upload-image-preview"
        ></el-image>
        <div class="upload-image-mask">
          <div class="upload-image-actions">
            <span class="upload-image-preview-btn" @click="handlePreview(index)">
              <i class="el-icon-zoom-in"></i>
            </span>
            <span 
              class="upload-image-delete-btn" 
              @click="handleDelete(index)"
              v-if="!disabled"
            >
              <i class="el-icon-delete"></i>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getToken } from "@/utils/auth"

export default {
  name: "ImageUpload",
  props: {
    // 值
    value: [String, Object, Array],
    // 上传接口地址
    action: {
      type: String,
      default: "/common/upload"
    },
    // 上传携带的参数
    data: {
      type: Object
    },
    // 数量限制
    limit: {
      type: Number,
      default: 5
    },
    // 大小限制(MB)
    fileSize: {
      type: Number,
      default: 10
    },
    // 文件类型, 例如['png', 'jpg', 'jpeg']
    fileType: {
      type: Array,
      default: () => ["jpg", "jpeg", "png", "gif", "bmp", "webp"]
    },
    // 是否显示提示
    isShowTip: {
      type: Boolean,
      default: true
    },
    // 禁用组件（仅查看图片）
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      number: 0,
      uploadList: [],
      baseUrl: process.env.VUE_APP_BASE_API || '/dev-api',
      uploadImageUrl: (process.env.VUE_APP_BASE_API || '/dev-api') + this.action, // 上传图片服务器地址
      headers: {
        Authorization: "Bearer " + getToken(),
      },
      fileList: []
    }
  },
  watch: {
    value: {
      handler(val) {
        if (val) {
          let temp = 1
          // 首先将值转为数组
          const list = Array.isArray(val) ? val : this.value.split(',')
          // 然后将数组转为对象数组
          this.fileList = list.map(item => {
            if (typeof item === "string") {
              item = { name: item, url: item }
            }
            item.uid = item.uid || new Date().getTime() + temp++
            return item
          })
        } else {
          this.fileList = []
          return []
        }
      },
      deep: true,
      immediate: true
    }
  },
  computed: {
    // 是否显示提示
    showTip() {
      return this.isShowTip && (this.fileType || this.fileSize)
    },
    // 预览图片列表
    previewList() {
      return this.fileList.map(file => this.getImageUrl(file.url))
    }
  },
  methods: {
    // 上传前校检格式和大小
    handleBeforeUpload(file) {
      // 校检文件类型
      if (this.fileType && this.fileType.length > 0) {
        const fileName = file.name.split('.')
        const fileExt = fileName[fileName.length - 1].toLowerCase()
        const isTypeOk = this.fileType.indexOf(fileExt) >= 0
        if (!isTypeOk) {
          this.$modal.msgError(`文件格式不正确，请上传${this.fileType.join("/")}格式的图片文件!`)
          return false
        }
      }
      
      // 校检是否为图片文件
      const isImage = file.type.indexOf('image/') === 0
      if (!isImage) {
        this.$modal.msgError('只能上传图片文件!')
        return false
      }
      
      // 校检文件大小
      if (this.fileSize) {
        const isLt = file.size / 1024 / 1024 < this.fileSize
        if (!isLt) {
          this.$modal.msgError(`上传图片大小不能超过 ${this.fileSize} MB!`)
          return false
        }
      }
      
      this.$modal.loading("正在上传图片，请稍候...")
      this.number++
      return true
    },
    
    // 文件个数超出
    handleExceed() {
      this.$modal.msgError(`上传图片数量不能超过 ${this.limit} 个!`)
    },
    
    // 上传失败
    handleUploadError(err) {
      this.$modal.msgError("上传图片失败，请重试")
      this.$modal.closeLoading()
    },
    
    // 上传成功回调
    handleUploadSuccess(res, file) {
      if (res.code === 200) {
        this.uploadList.push({ 
          name: res.fileName, 
          url: res.fileName,
          originalName: file.name
        })
        this.uploadedSuccessfully()
      } else {
        this.number--
        this.$modal.closeLoading()
        this.$modal.msgError(res.msg)
        this.$refs.imageUpload.handleRemove(file)
        this.uploadedSuccessfully()
      }
    },
    
    // 删除图片
    handleDelete(index) {
      this.fileList.splice(index, 1)
      this.$emit("input", this.listToString(this.fileList))
    },
    
    // 预览图片
    handlePreview(index) {
      // Element UI 的 el-image 组件会自动处理预览
    },
    
    // 上传结束处理
    uploadedSuccessfully() {
      if (this.number > 0 && this.uploadList.length === this.number) {
        this.fileList = this.fileList.concat(this.uploadList)
        this.uploadList = []
        this.number = 0
        this.$emit("input", this.listToString(this.fileList))
        this.$modal.closeLoading()
      }
    },
    
    // 获取图片完整URL
    getImageUrl(url) {
      if (!url) return ''
      
      // 如果已经是完整URL，直接返回
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url
      }
      
      // 如果是相对路径，加上baseUrl
      const baseApi = process.env.VUE_APP_BASE_API || '/dev-api'
      return baseApi + url
    },
    
    // 对象转成指定字符串分隔
    listToString(list, separator) {
      let strs = ""
      separator = separator || ","
      for (let i in list) {
        strs += list[i].url + separator
      }
      return strs != '' ? strs.substr(0, strs.length - 1) : ''
    }
  }
}
</script>

<style scoped lang="scss">
.upload-image {
  .upload-image-uploader {
    margin-bottom: 10px;
  }
  
  .upload-image-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 10px;
  }
  
  .upload-image-item {
    position: relative;
    width: 100px;
    height: 100px;
    border: 1px solid #dcdfe6;
    border-radius: 6px;
    overflow: hidden;
    
    .upload-image-preview {
      width: 100%;
      height: 100%;
    }
    
    .upload-image-mask {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.3s;
    }
    
    &:hover .upload-image-mask {
      opacity: 1;
    }
    
    .upload-image-actions {
      display: flex;
      gap: 15px;
      
      .upload-image-preview-btn,
      .upload-image-delete-btn {
        color: white;
        font-size: 16px;
        cursor: pointer;
        transition: transform 0.3s;
        
        &:hover {
          transform: scale(1.2);
        }
      }
    }
  }
}
</style>