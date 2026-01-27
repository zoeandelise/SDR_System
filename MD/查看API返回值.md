# 查看API返回值 - 浏览器方法

## 问题

curl命令返回401认证错误，因为API需要登录

## 解决方案：使用浏览器开发者工具

### 方法1：查看Network标签（推荐）

1. **打开浏览器开发者工具**
   - 按 `F12` 键
   - 或右键点击页面 → "检查"

2. **切换到Network标签**
   - 点击顶部的 "Network" 或"网络"

3. **筛选请求**
   - 在Filter框中输入：`progress`
   - 这样只显示包含"progress"的请求

4. **查看最新的progress请求**
   - 点击最新的 `progress` 请求
   - 查看右侧的 "Response" 或"响应"标签

5. **关键检查点**

   **期望看到（修复成功）：**
   ```json
   {
     "code": 200,
     "data": {
       "isTraining": false,  ← 应该是false！
       "models": [
         {
           "trainingId": 128,
           "modelType": "collaborative_filtering",
           "trainingStatus": "completed",
           "progress": 100,
           "currentStep": "训练完成"
         },
         {
           "trainingId": 129,
           "modelType": "content_based",
           "trainingStatus": "completed",
           "progress": 100,
           "currentStep": "训练完成"
         }
       ],
       "overallProgress": 100,
       "completedModels": 2,
       "totalModels": 2
     }
   }
   ```

   **如果看到（还没修复）：**
   ```json
   {
     "code": 200,
     "data": {
       "isTraining": true,  ← 还是true，说明后端没重启
       "models": [],
       "overallProgress": 0
     }
   }
   ```

### 方法2：使用Console执行请求

1. **打开Console标签**
   - 按 `F12`
   - 点击 "Console" 或"控制台"

2. **执行以下代码**
   ```javascript
   fetch('/api/ml/training/progress')
     .then(res => res.json())
     .then(data => {
       console.log('isTraining:', data.data.isTraining)
       console.log('完整数据:', data)
     })
   ```

3. **查看输出**
   - 应该显示 `isTraining: false`

### 方法3：直接在页面上查看

如果前端已经显示了完成状态：

1. **前端显示"已完成"** → 说明API返回正确
2. **前端还在显示"训练中"** → API可能还返回isTraining=true

## 快速判断方法

### 观察轮询是否停止

**在浏览器Network标签中：**

1. 训练完成后，观察 `progress` 请求
2. **如果请求停止了** → ✅ 修复成功！isTraining=false
3. **如果还在持续请求** → ❌ 还没修复，isTraining=true

### 观察前端显示

**训练完成后：**

✅ **修复成功的表现：**
- 进度条：100%
- 状态：已完成
- 统计：已完成: 2/2
- Network请求：停止轮询
- 按钮："完成并关闭"可用

❌ **还没修复的表现：**
- 进度条：停在90%或其他值
- 状态：训练中
- 统计：已完成: 0/2
- Network请求：持续轮询
- 按钮：灰色不可用

## 如果Network显示请求已停止

说明修复成功！前端已经正确停止轮询。

## 如果Network显示还在持续请求

说明Java后端可能没有重启，请执行：

### 步骤1：确认Java后端已重启

在IDEA中：
1. 点击红色方块停止
2. 等待完全停止
3. 点击绿色三角启动
4. 等待看到 "Started SDRSystemApplication"

### 步骤2：清除浏览器缓存

```
Ctrl + Shift + Delete
选择"缓存的图片和文件"
点击"清除数据"
```

### 步骤3：刷新页面

```
Ctrl + F5 (强制刷新)
```

### 步骤4：重新训练

点击"训练模型"，观察是否能正确完成

## 添加调试日志（如果还是不行）

在 `MLDataService.java` 中添加：

```java
public Map<String, Object> getTrainingProgress() {
    Map<String, Object> result = new HashMap<>();
    try {
        List<Map<String, Object>> activeTrainings = getActiveTrainings();
        
        // 调试日志
        logger.info("=== 训练进度查询 ===");
        logger.info("查询到的记录数: {}", activeTrainings.size());
        
        boolean isTraining = activeTrainings.stream()
            .anyMatch(t -> "training".equals(t.get("trainingStatus")) || 
                          "pending".equals(t.get("trainingStatus")));
        
        logger.info("isTraining: {}", isTraining);
        
        for (Map<String, Object> t : activeTrainings) {
            logger.info("模型: {}, 状态: {}, 进度: {}%", 
                t.get("modelType"), 
                t.get("trainingStatus"), 
                t.get("progress"));
        }
        
        result.put("isTraining", isTraining);
        result.put("models", activeTrainings);
```

重启后，在Java后端日志中应该看到：
```
=== 训练进度查询 ===
查询到的记录数: 2
isTraining: false
模型: collaborative_filtering, 状态: completed, 进度: 100%
模型: content_based, 状态: completed, 进度: 100%
```

## 总结

**不要用curl测试**，因为需要登录认证。

**使用浏览器F12查看：**
1. Network标签 → 查看progress请求的Response
2. 检查 `isTraining` 字段
3. 观察请求是否停止

**最简单的判断方法：**
- 训练完成后，Network中的progress请求停止了 → ✅ 成功
- 训练完成后，Network中的progress请求还在继续 → ❌ 失败
