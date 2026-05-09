# 毕业论文全部图表 PlantUML 源码

> **使用方法**：将每段代码复制到 [PlantUML在线编辑器](https://www.plantuml.com/plantuml/uml/) 中，点击 Submit 即可生成图片并下载。

---

## 图2.1 普通用户用例图

```plantuml
@startuml
left to right direction
skinparam actorStyle awesome
skinparam usecase {
    BackgroundColor #FEFECE
    BorderColor #A80036
}

actor "普通用户" as user

rectangle "智能饮食推荐系统（用户端）" {
    usecase "注册登录" as UC1
    usecase "注册账号" as UC1a
    usecase "登录系统" as UC1b

    usecase "健康档案管理" as UC2
    usecase "填写身体参数" as UC2a
    usecase "设置疾病标签" as UC2b
    usecase "查看代谢率" as UC2c

    usecase "饮食记录" as UC3
    usecase "搜索食物" as UC3a
    usecase "添加记录" as UC3b
    usecase "删除记录" as UC3c

    usecase "饮食仪表盘" as UC4
    usecase "查看热量环形图" as UC4a
    usecase "查看趋势折线图" as UC4b

    usecase "智能推荐" as UC5
    usecase "获取推荐列表" as UC5a
    usecase "采纳推荐" as UC5b

    usecase "健康目标管理" as UC7
    usecase "设置目标体重" as UC7a
    usecase "查看达成进度" as UC7b

    usecase "饮食打卡" as UC8
    usecase "每日签到" as UC8a
    usecase "查看打卡日历" as UC8b

    usecase "营养数据分析" as UC9
    usecase "查看营养报表" as UC9a
    usecase "食物偏好分析" as UC9b

    usecase "个人中心" as UC6
    usecase "修改密码" as UC6a

    usecase "饮食历史回溯" as UC10
    usecase "按日期查看历史" as UC10a
    usecase "复用推荐方案" as UC10b

    usecase "食物营养查询" as UC11
    usecase "搜索食物库" as UC11a
    usecase "查看营养详情" as UC11b

    usecase "饮食交流社区" as UC12
    usecase "发布动态" as UC12a
    usecase "点赞评论" as UC12b

    usecase "健康雷达周报" as UC13
    usecase "查看六维评分" as UC13a

    usecase "食谱方案管理" as UC14
    usecase "查看食谱列表" as UC14a
    usecase "收藏食谱" as UC14b

    usecase "健康科普浏览" as UC15
    usecase "查看科普文章" as UC15a
}

user --> UC1
user --> UC2
user --> UC3
user --> UC4
user --> UC5
user --> UC6
user --> UC7
user --> UC8
user --> UC9
user --> UC10
user --> UC11
user --> UC12
user --> UC13
user --> UC14
user --> UC15

UC1 ..> UC1a : <<包含>>
UC1 ..> UC1b : <<包含>>

UC2 ..> UC2a : <<包含>>
UC2 ..> UC2b : <<包含>>
UC2 ..> UC2c : <<包含>>

UC3 ..> UC3a : <<包含>>
UC3 ..> UC3b : <<包含>>
UC3 ..> UC3c : <<包含>>

UC4 ..> UC4a : <<包含>>
UC4 ..> UC4b : <<包含>>

UC5 ..> UC5a : <<包含>>
UC5 ..> UC5b : <<包含>>

UC7 ..> UC7a : <<包含>>
UC7 ..> UC7b : <<包含>>

UC8 ..> UC8a : <<包含>>
UC8 ..> UC8b : <<包含>>

UC9 ..> UC9a : <<包含>>
UC9 ..> UC9b : <<包含>>

UC6 ..> UC6a : <<包含>>

UC10 ..> UC10a : <<包含>>
UC10 ..> UC10b : <<包含>>

UC11 ..> UC11a : <<包含>>
UC11 ..> UC11b : <<包含>>

UC12 ..> UC12a : <<包含>>
UC12 ..> UC12b : <<包含>>

UC13 ..> UC13a : <<包含>>

UC14 ..> UC14a : <<包含>>
UC14 ..> UC14b : <<包含>>

UC15 ..> UC15a : <<包含>>
@enduml
```

---

## 图2.2 管理员用例图

```plantuml
@startuml
left to right direction
skinparam actorStyle awesome
skinparam usecase {
    BackgroundColor #FEFECE
    BorderColor #A80036
}

actor "管理员" as admin

rectangle "智能饮食推荐系统（管理端）" {
    usecase "登录管理" as AC1

    usecase "食物信息管理" as AC2
    usecase "新增食物" as AC2a
    usecase "编辑食物" as AC2b
    usecase "删除食物" as AC2c

    usecase "用户信息管理" as AC3
    usecase "查看用户列表" as AC3a
    usecase "禁用/启用账号" as AC3b
    usecase "重置密码" as AC3c

    usecase "饮食记录审查" as AC4
    usecase "查看全部记录" as AC4a
    usecase "数据统计筛选" as AC4b

    usecase "推荐模型管理" as AC5
    usecase "模型训练监控" as AC5a
    usecase "算法对比测试" as AC5b
    usecase "查看推荐统计" as AC5c

    usecase "系统运营看板" as AC6
    usecase "查看运营指标" as AC6a
    usecase "查看趋势图表" as AC6b

    usecase "科普资讯管理" as AC7
    usecase "发布科普文章" as AC7a
    usecase "编辑文章内容" as AC7b

    usecase "社区内容管理" as AC8
    usecase "查看社区动态" as AC8a
    usecase "管理违规内容" as AC8b
}

admin --> AC1
admin --> AC2
admin --> AC3
admin --> AC4
admin --> AC5
admin --> AC6
admin --> AC7
admin --> AC8

AC2 ..> AC2a : <<包含>>
AC2 ..> AC2b : <<包含>>
AC2 ..> AC2c : <<包含>>

AC3 ..> AC3a : <<包含>>
AC3 ..> AC3b : <<包含>>
AC3 ..> AC3c : <<包含>>

AC4 ..> AC4a : <<包含>>
AC4 ..> AC4b : <<包含>>

AC5 ..> AC5a : <<包含>>
AC5 ..> AC5b : <<包含>>
AC5 ..> AC5c : <<包含>>

AC6 ..> AC6a : <<包含>>
AC6 ..> AC6b : <<包含>>

AC7 ..> AC7a : <<包含>>
AC7 ..> AC7b : <<包含>>

AC8 ..> AC8a : <<包含>>
AC8 ..> AC8b : <<包含>>
@enduml
```

---

## 图3.1 系统功能模块图

```plantuml
@startwbs
skinparam defaultFontName Microsoft YaHei
skinparam wbs {
    BackgroundColor #FFFFFF
    BorderColor #000000
}

* 智能饮食推荐系统
** 管理员
*** 登录
**** 管理员登录
*** 食物信息管理
**** 食物新增
**** 食物编辑
**** 食物删除
**** 分类管理
*** 用户信息管理
**** 用户列表查看
**** 账号禁用启用
**** 密码重置
*** 饮食记录审查
**** 全部记录查看
**** 数据统计筛选
*** 推荐模型管理
**** 模型训练监控
**** 算法对比测试
**** 推荐统计查看
*** 系统运营看板
**** 运营指标查看
**** 趋势图表查看
*** 系统设置
**** 角色权限管理
**** 菜单权限配置
*** 科普资讯管理
**** 文章发布编辑
**** 文章状态管理
*** 社区内容管理
**** 查看社区动态
**** 违规内容处理
** 用户
*** 注册登录
**** 账号注册
**** 用户登录
*** 健康档案管理
**** 身体参数填写
**** 疾病标签设置
**** 代谢率查看
*** 饮食记录
**** 食物搜索
**** 记录添加
**** 记录删除
*** 饮食仪表盘
**** 热量环形图
**** 趋势折线图
**** 营养素柱状图
*** 智能推荐
**** 推荐列表获取
**** 推荐采纳
*** 健康目标管理
**** 目标体重设置
**** 达成进度查看
*** 饮食打卡
**** 每日签到
**** 打卡日历查看
*** 营养数据分析
**** 营养报表查看
**** 食物偏好分析
*** 饮食历史回溯
**** 按日期查看历史
**** 复用推荐方案
*** 食物营养查询
**** 食物库搜索
**** 营养详情查看
*** 饮食交流社区
**** 发布图文动态
**** 点赞评论
*** 健康雷达周报
**** 六维度评分查看
*** 食谱方案管理
**** 食谱列表浏览
**** 食谱收藏
*** 健康科普浏览
**** 科普文章查看
*** 个人中心
**** 密码修改
**** 头像设置

@endwbs
```

---

## 图3.2 注册登录流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:访问系统首页;
if (是否已有账号?) then (是)
    :输入用户名和密码;
    :提交登录请求;
    if (账号密码是否正确?) then (是)
        :签发JWT令牌;
        :跳转至系统主页;
    else (否)
        :提示"账号或密码不正确";
        :返回登录页;
    endif
else (否)
    :填写用户名、昵称、密码;
    :提交注册请求;
    if (用户名是否已存在?) then (是)
        :提示"用户名已存在";
        :返回注册页;
    else (否)
        :加密密码并创建账号;
        :注册成功;
        :跳转至登录页;
    endif
endif
stop
@enduml
```

---

## 图3.3 健康档案建立流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:用户登录系统;
if (是否已建立健康档案?) then (是)
    :显示现有档案信息;
    if (是否需要修改?) then (是)
        :进入编辑页面;
    else (否)
        stop
    endif
else (否)
    :引导至档案填写页面;
endif
:填写身高、体重、年龄、性别;
:填写目标体重;
:选择疾病史标签;
:提交档案信息;
:调用BMR计算模块;
:计算基础代谢率;
:计算每日推荐摄入热量;
:保存档案至数据库;
:显示计算结果;
stop
@enduml
```

---

## 图3.4 每日饮食记录流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入饮食记录页面;
:选择就餐时段;
note right: 早餐/午餐/晚餐/加餐
:输入食物关键词;
:系统模糊匹配搜索;
:展示候选食物列表;
:选定目标食物;
:输入摄入克重;
:自动计算摄入热量;
if (确认提交?) then (是)
    :写入饮食记录表;
    :更新当日热量汇总;
    :刷新热量环形进度图;
else (否)
    :取消操作;
endif
stop
@enduml
```

---

## 图3.5 智能推荐流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:用户选择用餐时段;
:点击"获取推荐";

:==阶段一：用户画像加载==;
:读取健康档案和疾病标签;
:统计近期饮食偏好数据;

:==阶段二：安全过滤==;
:读取过敏源和疾病信息;
note right
  过敏源: 一票否决制
  高血压: 拦截红烧/爆炒/腌制/麻辣
end note
:逐条过滤食物候选池;
:生成安全候选食物集;

:==阶段三：推荐算法调度==;
if (ML服务是否可用?) then (是)
    :调用Python ML服务;
    :获取深度学习推荐结果;
else (否)
    :降级为规则推荐引擎;
    if (健康目标为减脂?) then (是)
        :过滤高热量食物;
    else (否)
    endif
    :营养匹配度评分排序;
    :食量偏好份量折算;
endif

:==阶段四：后置安全网校验==;
:再次核查过敏源禁忌;
:再次核查高血压禁忌;
:返回最终推荐列表;
stop
@enduml
```

---

## 图3.6 食物信息维护流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:管理员进入食物管理页面;
:查看食物列表;
if (是否执行新增操作?) then (是)
    :点击新增按钮;
    :填写食物营养参数;
    if (校验是否通过?) then (是)
        :保存至数据库;
        :列表刷新;
    else (否)
        :提示错误信息;
    endif
else (否)
    if (是否执行编辑操作?) then (是)
        :点击编辑按钮;
        :修改营养参数;
        :提交保存;
        :更新数据库;
    else (否)
        :选择待删除条目;
        if (是否被饮食记录引用?) then (是)
            :提示谨慎操作;
        else (否)
            :执行删除;
            :列表刷新;
        endif
    endif
endif
stop
@enduml
```

---

## 图3.7 健康目标管理流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入健康目标页面;
:加载健康档案数据;
:展示当前体重和目标体重;
:计算并展示差值和预计周期;

if (是否需要修改目标?) then (是)
    :修改目标体重;
    :修改期望达成周期;
    :系统重新计算每日推荐热量;
    :动态更新进度图表;
    :保存至健康档案表;
else (否)
    :查看当前目标达成进度;
endif
stop
@enduml
```

---

## 图3.8 饮食仪表盘展示流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入饮食仪表盘页面;

fork
    :请求当日热量汇总;
fork again
    :请求近七天趋势数据;
fork again
    :请求营养素构成数据;
end fork

:后端聚合查询饮食记录表;
:封装ECharts所需数据格式;
:返回统计结果;

:渲染环形图（当日热量进度）;
:渲染折线图（七天热量趋势）;
:渲染柱状图（营养素构成对比）;
stop
@enduml
```

---

## 图3.9 营养数据分析流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入营养分析页面;
:选择统计周期;
:提交分析请求;

:提取该用户时间范围内全部饮食记录;
:关联食物信息表获取营养参数;
:按日期和营养素维度聚合计算;

:生成热量日均值;
:生成营养素结构占比;
:生成食物分类偏好分布;

fork
    :面积图展示热量趋势;
fork again
    :饼图展示营养素占比;
fork again
    :雷达图展示分类偏好;
end fork

:用户审视饮食结构均衡度;
stop
@enduml
```

---

## 图3.10 饮食打卡签到流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入打卡页面;
:查询当日打卡状态;

if (今日是否已打卡?) then (是)
    :展示打卡时间;
    :展示累计成就;
else (否)
    :展示打卡按钮;
    :展示连续打卡天数;
    :用户点击打卡;
    :新增打卡记录;
    :更新连续打卡计数;
    :展示打卡成功提示;
endif

:以月历视图展示历史打卡;
:已打卡日期高亮标记;
stop
@enduml
```

---

## 图3.11 系统权限管理流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
skinparam ActivityBackgroundColor #FFFFFF
skinparam ActivityBorderColor #000000
skinparam DiamondBackgroundColor #FFFFFF
skinparam DiamondBorderColor #000000
skinparam ArrowColor #000000

start

:管理员进入权限管理页面;
:加载角色权限列表;

if (是否具备管理员权限?) then (是)
    :展示角色与菜单权限表;
    if (是否执行新增操作?) then (是)
        :填写角色名称与权限范围;
        :提交新增请求;
        if (角色名是否重复?) then (是)
            :提示"角色已存在";
        else (否)
            :保存角色权限至数据库;
            :列表刷新;
        endif
    else (否)
        if (是否执行删除操作?) then (是)
            :选择待删除角色;
            if (该角色是否已分配用户?) then (是)
                :提示"该角色下存在用户，不允许删除";
            else (否)
                :删除角色记录;
                :列表刷新;
            endif
        else (否)
            :选择待调整角色;
            :勾选或取消菜单权限;
            :提交保存;
            :更新角色菜单关联表;
            :列表刷新;
        endif
    endif
else (否)
    :返回无权限提示;
endif

stop
@enduml
```

---

## 图3.12 用户与健康档案关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; health [label="健康档案"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="拥有"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="密码"];
    u4 [label="昵称"]; u5 [label="性别"]; u6 [label="手机号"];

    h1 [label="健康主键"]; h2 [label="用户主键"]; h3 [label="身高"];
    h4 [label="体重"]; h5 [label="年龄"]; h6 [label="目标体重"];
    h7 [label="过敏史"]; h8 [label="病史"]; h9 [label="热量目标"];
    h10 [label="活动级别"]; h11 [label="创建时间"];

    user -- u1; user -- u2; user -- u3;
    user -- u4; user -- u5; user -- u6;
    health -- h1; health -- h2; health -- h3;
    health -- h4; health -- h5; health -- h6;
    health -- h7; health -- h8; health -- h9;
    health -- h10; health -- h11;

    user -- rel [label="1"]; rel -- health [label="1"];
}
@enddot
```

---

## 图3.13 用户与饮食记录关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; record [label="饮食记录"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="产生"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    r1 [label="记录ID"]; r2 [label="用户ID"]; r3 [label="记录日期"];
    r4 [label="餐次类型"]; r5 [label="总热量"]; r6 [label="总蛋白质"];
    r7 [label="总脂肪"]; r8 [label="创建时间"];

    user -- u1; user -- u2; user -- u3;
    record -- r1; record -- r2; record -- r3;
    record -- r4; record -- r5; record -- r6;
    record -- r7; record -- r8;

    user -- rel [label="1"]; rel -- record [label="n"];
}
@enddot
```

---

## 图3.14 饮食记录与食物信息关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] record [label="饮食记录"]; food [label="食物信息"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="关联"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    r1 [label="记录ID"]; r2 [label="用户ID"]; r3 [label="餐次类型"];
    r4 [label="总热量"]; r5 [label="记录日期"];

    f1 [label="食物ID"]; f2 [label="食物名称"]; f3 [label="分类ID"];
    f4 [label="食物编码"]; f5 [label="计量单位"]; f6 [label="标准重量"];

    record -- r1; record -- r2; record -- r3;
    record -- r4; record -- r5;
    food -- f1; food -- f2; food -- f3;
    food -- f4; food -- f5; food -- f6;

    record -- rel [label="n"]; rel -- food [label="1"];
}
@enddot
```

---

## 图3.15 用户与推荐记录关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; rec [label="推荐记录"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="获得"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    r1 [label="推荐ID"]; r2 [label="用户ID"]; r3 [label="推荐日期"];
    r4 [label="餐次类型"]; r5 [label="推荐食物"]; r6 [label="算法类型"];
    r7 [label="推荐评分"]; r8 [label="是否采纳"];

    user -- u1; user -- u2; user -- u3;
    rec -- r1; rec -- r2; rec -- r3;
    rec -- r4; rec -- r5; rec -- r6;
    rec -- r7; rec -- r8;

    user -- rel [label="1"]; rel -- rec [label="n"];
}
@enddot
```

---

## 图3.16 食物分类与食物信息关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] cat [label="食物分类"]; food [label="食物信息"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="包含"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    c1 [label="分类ID"]; c2 [label="分类名称"]; c3 [label="排序号"]; c4 [label="状态"];

    f1 [label="食物ID"]; f2 [label="食物名称"]; f3 [label="分类ID"];
    f4 [label="食物编码"]; f5 [label="计量单位"]; f6 [label="标准重量"];

    cat -- c1; cat -- c2; cat -- c3; cat -- c4;
    food -- f1; food -- f2; food -- f3;
    food -- f4; food -- f5; food -- f6;

    cat -- rel [label="1"]; rel -- food [label="n"];
}
@enddot
```

---

## 图3.17 食物信息与营养信息关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] food [label="食物信息"]; nut [label="营养信息"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="对应"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    f1 [label="食物ID"]; f2 [label="食物名称"]; f3 [label="分类ID"];

    n1 [label="营养ID"]; n2 [label="食物ID"]; n3 [label="热量"];
    n4 [label="蛋白质"]; n5 [label="脂肪"]; n6 [label="碳水"];
    n7 [label="膳食纤维"]; n8 [label="钠"]; n9 [label="胆固醇"];

    food -- f1; food -- f2; food -- f3;
    nut -- n1; nut -- n2; nut -- n3;
    nut -- n4; nut -- n5; nut -- n6;
    nut -- n7; nut -- n8; nut -- n9;

    food -- rel [label="1"]; rel -- nut [label="1"];
}
@enddot
```

---

## 图3.18 用户与健康目标关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; goal [label="健康目标"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="设置"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    g1 [label="目标ID"]; g2 [label="用户ID"]; g3 [label="目标类型"];
    g4 [label="目标名称"]; g5 [label="目标值"]; g6 [label="当前值"];
    g7 [label="完成百分比"]; g8 [label="状态"];

    user -- u1; user -- u2; user -- u3;
    goal -- g1; goal -- g2; goal -- g3;
    goal -- g4; goal -- g5; goal -- g6;
    goal -- g7; goal -- g8;

    user -- rel [label="1"]; rel -- goal [label="n"];
}
@enddot
```

---

## 图3.19 用户与饮食打卡关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; checkin [label="饮食打卡"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="记录"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    c1 [label="打卡ID"]; c2 [label="用户ID"]; c3 [label="打卡日期"];
    c4 [label="饮食摘要"]; c5 [label="总热量"]; c6 [label="心情"];
    c7 [label="打卡心得"];

    user -- u1; user -- u2; user -- u3;
    checkin -- c1; checkin -- c2; checkin -- c3;
    checkin -- c4; checkin -- c5; checkin -- c6;
    checkin -- c7;

    user -- rel [label="1"]; rel -- checkin [label="n"];
}
@enddot
```

---

## 图3.20 管理员与食物信息关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] admin [label="管理员"]; food [label="食物信息"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="管理"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    a1 [label="用户ID"]; a2 [label="用户名"]; a3 [label="密码"]; a4 [label="角色权限"];

    f1 [label="食物ID"]; f2 [label="食物名称"]; f3 [label="分类ID"];
    f4 [label="食物编码"]; f5 [label="计量单位"]; f6 [label="状态"];
    f7 [label="创建者"]; f8 [label="创建时间"];

    admin -- a1; admin -- a2; admin -- a3; admin -- a4;
    food -- f1; food -- f2; food -- f3;
    food -- f4; food -- f5; food -- f6;
    food -- f7; food -- f8;

    admin -- rel [label="1"]; rel -- food [label="n"];
}
@enddot
```

---

## 图3.12 饮食社区互动流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入社区页面;
:拉取最新动态列表;
:浏览动态内容;

if (是否发布动态?) then (是)
    :填写文字内容;
    if (内容是否为空?) then (是)
        :提示"内容不能为空";
    else (否)
        :写入社区动态表;
        :列表刷新显示新动态;
    endif
else (否)
    if (是否进行点赞?) then (是)
        :查询点赞关联表;
        if (是否已点赞?) then (是)
            :删除点赞记录;
            :点赞数减1;
        else (否)
            :新增点赞记录;
            :点赞数加1;
        endif
    else (否)
        :输入评论内容;
        :写入评论关联表;
        :更新评论计数;
        :评论列表刷新;
    endif
endif
stop
@enduml
```

---

## 图3.13 健康雷达周报生成流程图

```plantuml
@startuml
skinparam defaultFontName Microsoft YaHei
start
:进入健康雷达周报页面;
:调用后端周报接口;
:从饮食记录表聚合近7天数据;
note right
  聚合维度:
  热量、蛋白质、
  碳水、脂肪
end note
:根据评分规则计算六维度得分;
note right
  碳水结构 / 脂肪控量
  蛋白达标 / 维生素
  水分代谢 / 饮食规律
end note
:返回评分数据给前端;
:前端通过ECharts渲染雷达图;
:展示多维度评分雷达图;
stop
@enduml
```

---

## 图3.22 用户与社区动态关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; post [label="社区动态"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="发布"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    p1 [label="动态ID"]; p2 [label="用户ID"]; p3 [label="正文内容"];
    p4 [label="图片链接"]; p5 [label="点赞数"]; p6 [label="评论数"];
    p7 [label="创建时间"];

    user -- u1; user -- u2; user -- u3;
    post -- p1; post -- p2; post -- p3;
    post -- p4; post -- p5; post -- p6;
    post -- p7;

    user -- rel [label="1"]; rel -- post [label="n"];
}
@enddot
```

---

## 图3.23 管理员与科普资讯关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] admin [label="管理员"]; article [label="科普资讯"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="发布"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    a1 [label="用户ID"]; a2 [label="用户名"]; a3 [label="角色权限"];

    ar1 [label="文章ID"]; ar2 [label="标题"]; ar3 [label="作者"];
    ar4 [label="封面图"]; ar5 [label="正文内容"]; ar6 [label="浏览次数"];
    ar7 [label="发布状态"]; ar8 [label="创建时间"];

    admin -- a1; admin -- a2; admin -- a3;
    article -- ar1; article -- ar2; article -- ar3;
    article -- ar4; article -- ar5; article -- ar6;
    article -- ar7; article -- ar8;

    admin -- rel [label="1"]; rel -- article [label="n"];
}
@enddot
```

---

## 图3.24 用户与收藏记录关系E-R图

```plantuml
@startdot
graph ER {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF";
    node [fontname="Microsoft YaHei"];
    edge [fontname="Microsoft YaHei"];

    node [shape=box, style=filled, fillcolor="#FEFECE"] user [label="用户"]; fav [label="收藏记录"];
    node [shape=diamond, style=filled, fillcolor="#FFFFFF"] rel [label="收藏"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF"]
    u1 [label="用户ID"]; u2 [label="用户名"]; u3 [label="昵称"];

    f1 [label="收藏ID"]; f2 [label="用户ID"]; f3 [label="收藏类型"];
    f4 [label="目标ID"]; f5 [label="目标名称"]; f6 [label="创建时间"];

    user -- u1; user -- u2; user -- u3;
    fav -- f1; fav -- f2; fav -- f3;
    fav -- f4; fav -- f5; fav -- f6;

    user -- rel [label="1"]; rel -- fav [label="n"];
}
@enddot
```

---

## 图3.25 系统总体E-R图（更新版）

```plantuml
@startuml
skinparam defaultFontSize 12
skinparam linetype ortho
skinparam rectangle {
  BackgroundColor #FEFECE
  BorderColor #A80036
  FontStyle bold
}
skinparam entity {
  BackgroundColor #DDEEFF
  BorderColor #336699
}

entity "用户" as user {
}
entity "健康档案" as health {
}
entity "饮食记录" as record {
}
entity "食物信息" as food {
}
entity "食物分类" as cat {
}
entity "营养信息" as nut {
}
entity "推荐记录" as rec {
}
entity "健康目标" as goal {
}
entity "饮食打卡" as checkin {
}
entity "管理员" as admin {
}
entity "社区动态" as post {
}
entity "科普资讯" as article {
}
entity "收藏记录" as fav {
}

user ||--o{ health : "拥有"
user ||--o{ record : "产生"
record }o--|| food : "关联"
cat ||--o{ food : "包含"
food ||--|| nut : "对应"
user ||--o{ rec : "获得"
user ||--o{ goal : "设置"
user ||--o{ checkin : "记录"
user ||--o{ post : "发布"
user ||--o{ fav : "收藏"
admin ||--o{ food : "管理"
admin ||--o{ article : "发布"
@enduml
```

---

## ========== 3.4.1 独立实体属性图（不含关系，每个实体单独一张） ==========

> 以下是老师要求的"独立实体属性图"，每张图只展示一个实体及其全部属性，不建立任何实体间关系。用于论文3.4.1节。

---

### (1) 系统用户实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="系统用户"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>用户ID</U>>]; a2 [label="用户名"]; a3 [label="密码"];
    a4 [label="昵称"]; a5 [label="邮箱"]; a6 [label="手机号"];
    a7 [label="性别"]; a8 [label="头像"]; a9 [label="状态"];
    a10 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8; e -- a9;
    e -- a10;
}
@enddot
```

---

### (2) 用户健康档案实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.5]
    e [label="用户健康档案"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>档案ID</U>>]; a2 [label="用户ID"]; a3 [label="身高"];
    a4 [label="体重"]; a5 [label="年龄"]; a6 [label="目标体重"];
    a7 [label="基础代谢率"]; a8 [label="每日推荐摄入热量"];
    a9 [label="是否糖尿病"]; a10 [label="是否高血压"];
    a11 [label="是否痛风"]; a12 [label="是否高血脂"];
    a13 [label="创建时间"]; a14 [label="更新时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8; e -- a9;
    e -- a10; e -- a11; e -- a12;
    e -- a13; e -- a14;
}
@enddot
```

---

### (3) 食物分类实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="食物分类"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>分类ID</U>>]; a2 [label="分类名称"]; a3 [label="排序号"];
    a4 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4;
}
@enddot
```

---

### (4) 食物信息实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="食物信息"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>食物ID</U>>]; a2 [label="食物名称"]; a3 [label="分类ID"];
    a4 [label="每百克热量"]; a5 [label="蛋白质"]; a6 [label="脂肪"];
    a7 [label="碳水化合物"]; a8 [label="升糖指数"]; a9 [label="嘌呤含量"];
    a10 [label="钠含量"]; a11 [label="胆固醇"]; a12 [label="数据来源"];
    a13 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8; e -- a9;
    e -- a10; e -- a11; e -- a12;
    e -- a13;
}
@enddot
```

---

### (5) 食物营养信息实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.5]
    e [label="食物营养信息"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>营养ID</U>>]; a2 [label="食物ID"]; a3 [label="热量"];
    a4 [label="蛋白质"]; a5 [label="脂肪"]; a6 [label="碳水化合物"];
    a7 [label="膳食纤维"]; a8 [label="钠"]; a9 [label="胆固醇"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8; e -- a9;
}
@enddot
```

---

### (6) 饮食记录实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="饮食记录"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>记录ID</U>>]; a2 [label="用户ID"]; a3 [label="食物ID"];
    a4 [label="就餐时段"]; a5 [label="摄入克重"]; a6 [label="摄入热量"];
    a7 [label="记录日期"]; a8 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8;
}
@enddot
```

---

### (7) 推荐记录实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="推荐记录"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>推荐ID</U>>]; a2 [label="用户ID"]; a3 [label="推荐食物列表"];
    a4 [label="算法类型"]; a5 [label="是否被采纳"]; a6 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
}
@enddot
```

---

### (8) 健康目标实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="健康目标"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>目标ID</U>>]; a2 [label="用户ID"]; a3 [label="目标类型"];
    a4 [label="目标名称"]; a5 [label="目标值"]; a6 [label="当前值"];
    a7 [label="完成百分比"]; a8 [label="状态"]; a9 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8; e -- a9;
}
@enddot
```

---

### (9) 饮食打卡实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="饮食打卡"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>打卡ID</U>>]; a2 [label="用户ID"]; a3 [label="打卡日期"];
    a4 [label="饮食摘要"]; a5 [label="总热量"]; a6 [label="心情"];
    a7 [label="打卡心得"]; a8 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8;
}
@enddot
```

---

### (10) 社区动态实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="社区动态"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>动态ID</U>>]; a2 [label="用户ID"]; a3 [label="正文内容"];
    a4 [label="图片链接"]; a5 [label="点赞数"]; a6 [label="评论数"];
    a7 [label="删除标记"]; a8 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8;
}
@enddot
```

---

### (11) 科普资讯实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="科普资讯"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>文章ID</U>>]; a2 [label="标题"]; a3 [label="作者"];
    a4 [label="封面图"]; a5 [label="正文内容"]; a6 [label="浏览次数"];
    a7 [label="发布状态"]; a8 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8;
}
@enddot
```

---

### (12) 收藏记录实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="收藏记录"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>收藏ID</U>>]; a2 [label="用户ID"]; a3 [label="收藏类型"];
    a4 [label="目标ID"]; a5 [label="目标名称"]; a6 [label="目标描述"];
    a7 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7;
}
@enddot
```

---

### (13) 管理员实体属性图

```plantuml
@startdot
graph {
    fontname="Microsoft YaHei"; bgcolor="#FFFFFF"; layout=neato;
    node [fontname="Microsoft YaHei"];
    edge [len=1.8];

    node [shape=box, style=filled, fillcolor="#FEFECE", width=1.2]
    e [label="管理员"];

    node [shape=ellipse, style="", fillcolor="#FFFFFF", width=0.8]
    a1 [label=<<U>用户ID</U>>]; a2 [label="用户名"]; a3 [label="登录密码"];
    a4 [label="昵称"]; a5 [label="角色权限"]; a6 [label="手机号"];
    a7 [label="状态"]; a8 [label="创建时间"];

    e -- a1; e -- a2; e -- a3;
    e -- a4; e -- a5; e -- a6;
    e -- a7; e -- a8;
}
@enddot
```

---

## 图3.21 系统总体E-R图

```plantuml
@startdot
graph ER {
    fontname="SimSun"; bgcolor="#FFFFFF"; layout=neato; overlap=false; splines=true;
    node [fontname="SimSun"];
    edge [fontname="SimSun", len=2.0];

    node [shape=box, style=filled, fillcolor="#FEFECE"] 
    user [label="用户"]; health [label="健康档案"]; goal [label="健康目标"];
    record [label="饮食记录"]; rec [label="推荐记录"]; checkin [label="饮食打卡"];
    post [label="社区动态"]; fav [label="收藏记录"]; admin [label="管理员"];
    cat [label="食物分类"]; food [label="食物信息"]; nut [label="营养信息"];
    art [label="科普资讯"];

    node [shape=diamond, style=filled, fillcolor="#FFFFFF"]
    r_has [label="拥有"]; r_set [label="设定"]; r_prod [label="产生"];
    r_get [label="获取"]; r_log [label="记录"]; r_pub [label="发布"];
    r_fav [label="收藏"]; r_inc [label="包含"]; r_ref [label="对应"]; 
    r_rec_f [label="关联"]; r_admin [label="管理"];

    user -- r_has [label="1"]; r_has -- health [label="1"];
    user -- r_set [label="1"]; r_set -- goal [label="n"];
    user -- r_prod [label="1"]; r_prod -- record [label="n"];
    user -- r_get [label="1"]; r_get -- rec [label="n"];
    user -- r_log [label="1"]; r_log -- checkin [label="n"];
    user -- r_pub [label="1"]; r_pub -- post [label="n"];
    user -- r_fav [label="1"]; r_fav -- fav [label="n"];

    cat -- r_inc [label="1"]; r_inc -- food [label="n"];
    food -- r_ref [label="1"]; r_ref -- nut [label="1"];
    record -- r_rec_f [label="n"]; r_rec_f -- food [label="1"];
    
    admin -- r_admin [label="1"]; 
    r_admin -- cat [label="n"];
    r_admin -- food [label="n"];
    r_admin -- art [label="n"];
    r_admin -- user [label="n"];
}
@enddot
```

---

## 使用说明

1. 打开 https://www.plantuml.com/plantuml/uml/
2. 将上方某段 `@startdot ... @enddot` 或 `@startuml ... @enduml` 之间的代码复制粘贴进去
3. 点击 **Submit** 生成图片
4. 右键保存PNG图片
5. 在Word中"插入图片"即可

> **提示**：如果中文显示为方块，在代码开头加一行 `skinparam defaultFontName SimSun` 替换字体。
> 
> **属性图使用说明**：属性图使用 Graphviz DOT 的 `neato` 布局引擎，会自动将椭圆属性节点均匀散布在中心实体方框四周，生成的图片即为标准的"独立实体属性图"。

