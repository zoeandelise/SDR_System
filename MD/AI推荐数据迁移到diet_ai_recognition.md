# AI推荐数据迁移到diet_ai_recognition

**变更**：AI推荐方案从diet_recommendation迁移到diet_ai_recognition  
**状态**：✅ 已完成

---

## 📊 数据表职责

### diet_recommendation（通用推荐记录）
```
用途：存储各类推荐记录
内容：
- 快速推荐算法
- 规则推荐
- 其他推荐类型

不再存储：ML智能推荐全天方案
```

### diet_ai_recognition（AI识别和推荐）⭐
```
用途：存储AI相关的数据
内容：
- ML智能推荐全天方案 ⭐
- 图片识别结果
- AI分析数据

字段：
- recognition_id（主键）
- user_id（用户ID）
- recognition_date（识别/推荐日期）
- recognition_type（类型：ML全天方案）
- recognition_result（结果：推荐食物）
- confidence_score（置信度：0.95）
- is_applied（是否已应用：0/1）
- create_time（创建时间）
```

---

## ✅ 修改内容

### 1. 保存方案
```java
// 修改前
INSERT INTO diet_recommendation (...)

// 修改后
INSERT INTO diet_ai_recognition (
  user_id,
  recognition_date,
  recognition_type,  -- 'ML全天方案'
  recognition_result,  -- 推荐食物列表
  confidence_score,  -- 0.95
  create_time
)
```

### 2. 查询我的方案
```java
// 修改前
SELECT * FROM diet_recommendation WHERE user_id = ?

// 修改后
SELECT * FROM diet_ai_recognition 
WHERE user_id = ? 
AND recognition_type = 'ML全天方案'
```

### 3. 执行方案
```java
// 修改前
SELECT * FROM diet_recommendation WHERE recommendation_id = ?
UPDATE diet_recommendation SET is_accepted = '1'

// 修改后
SELECT * FROM diet_ai_recognition WHERE recognition_id = ?
UPDATE diet_ai_recognition SET is_applied = 1
```

### 4. 管理端查询
```java
// 修改前
SELECT * FROM diet_recommendation r
LEFT JOIN sys_user u ON r.user_id = u.user_id

// 修改后
SELECT * FROM diet_ai_recognition a
LEFT JOIN sys_user u ON a.user_id = u.user_id
WHERE a.recognition_type = 'ML全天方案'
```

---

## 🎯 数据迁移

### 迁移现有数据（可选）
```sql
-- 将现有的ML推荐从diet_recommendation迁移到diet_ai_recognition
INSERT INTO diet_ai_recognition 
  (user_id, recognition_date, recognition_type, recognition_result, confidence_score, is_applied, create_time)
SELECT 
  user_id,
  recommendation_date,
  'ML全天方案',
  recommended_foods,
  0.95,
  CASE WHEN is_accepted = '1' THEN 1 ELSE 0 END,
  create_time
FROM diet_recommendation
WHERE meal_type = '9' 
AND algorithm_type LIKE '%ML%';

-- 删除旧数据
DELETE FROM diet_recommendation 
WHERE meal_type = '9' 
AND algorithm_type LIKE '%ML%';
```

---

## 🚀 立即重启后端

```batch
taskkill /F /IM java.exe
timeout /t 3
cd E:\study\BISHE\SDR_System\SDR_System-admin
mvn spring-boot:run
```

**等待30秒启动成功**

---

## 🎯 重启后测试

### 1. 用户端生成新方案
```
http://localhost:3000/smart-recommendation
→ 一键生成全天方案
→ 保存方案

验证：
mysql> SELECT * FROM diet_ai_recognition WHERE user_id=1;
应该看到新记录！✓
```

### 2. 管理端查看
```
http://localhost:81/diet/recommendation
→ 刷新

应该看到：
✓ 从diet_ai_recognition表查询的数据
✓ 用户名
✓ 🤖全天方案
✓ ML智能推荐
```

### 3. 用户端执行
```
http://localhost:3000/health-goal
→ 应用方案

验证：
mysql> SELECT is_applied FROM diet_ai_recognition WHERE recognition_id=XX;
应该是1！✓
```

---

**数据表**：✅ 改为diet_ai_recognition  
**所有API**：✅ 已更新  
**编译打包**：✅ SUCCESS  

**立即重启后端！** 🚀  
**新方案将保存到diet_ai_recognition表！** ✅

