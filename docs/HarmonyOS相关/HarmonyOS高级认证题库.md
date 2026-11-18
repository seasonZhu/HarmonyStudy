# HarmonyOS 应用开发者高级认证 - 理论考试题库

> **说明**：本题库基于 HarmonyOS 官方文档和常见考点整理，仅供参考。实际考试内容以官方为准。

---

## 一、ArkTS 语言基础

### 1.1 基础语法

**题目 1**：以下关于 ArkTS 的描述正确的是？
- A. ArkTS 是 TypeScript 的超集
- B. ArkTS 是 TypeScript 的子集，扩展了静态类型和其他特性
- C. ArkTS 完全兼容 JavaScript
- D. ArkTS 只支持运行时类型检查

**答案**：B

**解析**：ArkTS 是 TypeScript 的超集，在 TypeScript 基础上增加了静态类型检查、装饰器等特性，专为 HarmonyOS 应用开发设计。

---

**题目 2**：ArkTS 中以下哪个装饰器用于定义组件？
- A. @Component
- B. @Entry
- C. @Observed
- D. 以上都是

**答案**：D

**解析**：
- @Component：定义 UI 组件
- @Entry：标记入口组件
- @Observed：用于响应式状态管理

---

**题目 3**：ArkTS 支持的数据类型包括？
- A. number, string, boolean
- B. object, array
- C. enum, union type
- D. 以上都支持

**答案**：D

---

**题目 4**：以下哪个不是 ArkTS 的基本类型？
- A. string
- B. number
- C. boolean
- D. long

**答案**：D

**解析**：ArkTS 基本类型包括 number、string、boolean、void、null、undefined，不包含 long 类型。

---

**题目 5**： ArkTS 中 `any` 类型的描述正确的是？
- A. any 类型可以赋值给任何类型
- B. 任何类型都可以赋值给 any
- C. any 类型的变量可以调用任何方法
- D. 建议尽量避免使用 any 类型

**答案**：D

**解析**：虽然 any 可以接受任何类型，但会失去类型安全检查，生产环境中建议尽量避免使用。

---

### 1.2 装饰器

**题目 6**：@State 装饰器的作用是？
- A. 定义组件的内部状态
- B. 定义父子组件传递的状态
- C. 定义全局共享状态
- D. 定义持久化状态

**答案**：A

**解析**：@State 用于定义组件内部的响应式状态，当状态变化时会触发 UI 重新渲染。

---

**题目 7**：@Prop 装饰器的特点包括？
- A. 支持单向数据传递
- B. 父组件状态变化时同步到子组件
- C. 子组件变化不会影响父组件
- D. 以上都正确

**答案**：D

---

**题目 8**：@Link 装饰器与 @Prop 的区别是？
- A. @Link 是双向绑定
- B. @Link 支持子组件修改影响父组件
- C. @Link 需要使用 $ 前缀绑定
- D. 以上都正确

**答案**：D

---

**题目 9**：@Observed 装饰器的作用是？
- A. 标记类为可观察
- B. 用于监听对象属性变化
- C. 需要与 @Track 配合使用
- D. 以上都正确

**答案**：D

---

**题目 10**：@ObservedV2 和 @Observed 的主要区别是？
- A. @ObservedV2 支持嵌套对象的自动追踪
- B. @ObservedV2 性能更好
- C. @ObservedV2 是 HarmonyOS 4.0+ 新特性
- D. 以上都正确

**答案**：D

---

## 二、ArkUI 框架

### 2.1 组件基础

**题目 11**：以下哪个是 ArkUI 的基本布局组件？
- A. Text
- B. Image
- C. Column
- D. Button

**答案**：C

**解析**：Column 是列布局组件，Text 是文本组件，Image 是图片组件，Button 是按钮组件。

---

**题目 12**：Column 组件的默认主轴对齐方式是？
- Start
- Center
- End
- Stretch

**答案**：A

**解析**：Column 默认主轴（垂直方向）对齐方式是 Start（顶部对齐）。

---

**题目 13**：Row 组件的默认交叉轴对齐方式是？
- Start
- Center
- End
- Stretch

**答案**：B

---

**题目 14**：如何设置 Column 组件内部元素水平居中？
- A. justifyContent: HorizontalAlign.Center
- B. alignItems: HorizontalAlign.Center
- C. alignItems: ItemAlign.Center
- D. justifyContent: ItemAlign.Center

**答案**：B

**解析**：Row 是水平容器，主轴是水平方向，交叉轴是垂直方向；Column 是垂直容器，主轴是垂直方向，交叉轴是水平方向。

---

**题目 15**：Stack 组件的子组件排列顺序是？
- A. 先添加的在底层
- B. 先添加的在顶层
- C. 随机排列
- D. 无法确定

**答案**：B

**解析**：Stack 组件中后添加的子组件会覆盖先添加的。

---

### 2.2 列表组件

**题目 16**：List 组件中实现懒加载应使用？
- A. ForEach
- B. LazyForEach
- C. 两者都可以
- D. 两者都不行

**答案**：B

**解析**：LazyForEach 实现懒加载，只渲染可见区域的列表项，提高长列表性能。

---

**题目 17**：LazyForEach 的第三个参数（keyGenerator）作用是？
- A. 必填参数
- B. 可选，用于生成唯一标识
- C. 不起作用
- D. 用于排序

**答案**：B

**解析**：keyGenerator 是可选参数，用于为每个数据项生成唯一标识，帮助框架更高效地更新列表。

---

**题目 18**：以下关于 ForEach 和 LazyForEach 的说法正确的是？
- A. ForEach 性能更好
- B. LazyForEach 适合长列表
- C. 两者渲染行为相同
- D. LazyForEach 不支持数据变化

**答案**：B

---

**题目 19**：List 组件的 cachedCount 属性作用是？
- A. 设置缓存的列表项数量
- B. 设置列表项间距
- C. 设置列表项高度
- D. 设置预加载数量

**答案**：A

---

**题目 20**：在 List 中实现下拉刷新应使用？
- A. 自定义实现
- B. @ohos/pulltorefresh 库
- C. Swiper 组件
- D. Scroll 组件

**答案**：B

---

### 2.3 导航组件

**题目 21**：Navigation 组件的默认导航模式是？
- Stack
- Auto
- Split
- None

**答案**：A

---

**题目 22**：NavigationTitleMode.Mini 表示？
- 永久显示标题栏
- 滚动时标题栏收缩
- 不显示标题栏
- 自定义标题栏

**答案**：B

---

**题目 23**：router.push() 和 router.replace() 的区别是？
- push 会保留当前页面，replace 不会
- push 不能返回，replace 可以返回
- 两者没有区别
- push 用于跳转，replace 用于替换

**答案**：A

---

**题目 24**：如何获取 router 跳转时传递的参数？
- router.getParams()
- router.getParam()
- router.params
- router.getParams<T>()

**答案**：A

---

**题目 25**：Navigation 组件相比 router 模块的优势是？
- 支持路由拦截
- 支持页面转场动画自定义
- 支持深层路由
- 以上都是

**答案**：D

---

## 三、应用模型（Stage模型）

### 3.1 Stage 模型概念

**题目 26**：Stage 模型中，UIAbility 的主要职责是？
- A. 绘制 UI
- B. 管理应用生命周期和窗口
- C. 处理业务逻辑
- D. 存储数据

**答案**：B

**解析**：UIAbility 是应用组件，负责管理应用的生命周期和窗口，但不直接负责 UI 渲染。

---

**题目 27**：Stage 模型中，一个应用可以有多个 AbilityStage？
- A. 正确
- B. 错误
- C. 只有一个
- D. 取决于设备

**答案**：A

**解析**：每个模块都有一个 AbilityStage，所以一个应用可以有多个 AbilityStage。

---

**题目 28**：mainElement 必须在哪个配置文件中声明？
- module.json5
- app.json5
- package.json
- config.json

**答案**：A

---

**题目 29**：AbilityStage 的生命周期方法 onCreate 什么时候调用？
- 应用首次启动
- 每个模块首次加载
- 应用退出
- 任何时候

**答案**：B

---

**题目 30**：module.json5 中的 bundleName 表示？
- A. 应用唯一标识
- B. 模块名称
- C. 应用版本
- D. 供应商信息

**答案**：A

---

### 3.2 窗口管理

**题目 31**：WindowStage 的作用是？
- A. 管理应用窗口
- B. 加载页面
- C. 管理 UIAbility
- D. 处理用户输入

**答案**：A

**解析**：WindowStage 负责管理应用窗口，包括创建窗口、设置窗口属性等。

---

**题目 32**：如何获取当前窗口的大小？
- A. window.getWindowProperties()
- B. window.getContext().windowSize
- C. display.getAllDisplays()
- D. 以上都不对

**答案**：A

---

**题目 33**：设置全屏显示应使用 Window 的哪个方法？
- setFullScreen(true)
- enableFullScreen(true)
- setWindowLayoutFullScreen(true)
- setFullScreen()

**答案**：A

---

**题目 34**：关于 Window 的说法正确的是？
- 每个 UIAbility 有一个主窗口
- 子窗口可以悬浮在主窗口上
- 窗口可以设置全屏
- 以上都正确

**答案**：D

---

**题目 35**：如何实现沉浸式状态栏？
- A. setStatusBarVisibility
- B. setSystemBarProperties
- C. setStatusBarColor
- D. setNavigationBar

**答案**：B

---

## 四、状态管理

### 4.1 基础状态管理

**题目 36**：AppStorage 的作用是？
- A. 应用级全局状态存储
- B. 临时数据存储
- C. 文件存储
- D. 数据库存储

**答案**：A

**解析**：AppStorage 是应用级的状态存储，可以在应用内所有 UIAbility 之间共享数据。

---

**题目 37**：LocalStorage 和 AppStorage 的区别是？
- A. LocalStorage 只在单个 UIAbility 内有效
- B. AppStorage 跨 UIAbility 共享
- C. LocalStorage 可以持久化
- D. 两者没有区别

**答案**：A

---

**题目 38**：@StorageLink 装饰器的特点是？
- A. 双向绑定 AppStorage
- B. 单向绑定 AppStorage
- C. 绑定 LocalStorage
- D. 不绑定任何存储

**答案**：A

---

**题目 39**：以下哪个不是常见的响应式状态管理方案？
- A. @State + @Prop
- B. @Observed + @Track
- C. @ObservedV2 + @Trace
- D. Redux

**答案**：D

**解析**：Redux 不是 HarmonyOS 原生的状态管理方案。

---

**题目 40**：状态变化的传播路径是？
- A. 状态变量 -> UI
- B. UI -> 状态变量
- C. 两者都可以
- D. 需要手动触发

**答案**：A

---

## 五、网络编程

### 5.1 网络请求

**题目 41**：@ohos/axios 中，以下哪个方法用于发送 POST 请求？
- A. axios.get()
- B. axios.post()
- C. axios.put()
- D. axios.delete()

**答案**：B

---

**题目 42**：axios 的请求拦截器在什么时候执行？
- A. 请求发送前
- B. 响应返回后
- C. 发生错误时
- D. 任何时候

**答案**：A

---

**题目 43**：axios 响应拦截器在什么时候执行？
- A. 请求发送前
- B. 响应返回后，传递给 then/catch 前
- C. 发生错误时
- D. 定时执行

**答案**：B

---

**题目 44**：如何设置 axios 的超时时间？
- A. timeout 配置项
- B. setTimeout 方法
- C. maxTimeout 配置
- D. requestTimeout 参数

**答案**：A

---

**题目 45**：处理 axios 错误的正确方式是？
- A. try-catch
- B. .catch()
- C. onError 回调
- D. error 事件

**答案**：B

---

## 六、数据管理

### 6.1 轻量级数据存储

**题目 46**：Preferences 的特点包括？
- A. 键值对存储
- B. 支持数据类型丰富
- C. 同步/异步 API
- D. 以上都是

**答案**：D

---

**题目 47**：如何获取 Preferences 实例？
- A. new Preferences()
- B. dataPreferences.getPreferences()
- C. Preference.getInstance()
- D. Preferences.create()

**答案**：B

---

**题目 48**：Preferences 适合存储什么类型的数据？
- A. 大量结构化数据
- B. 用户配置等轻量级数据
- C. 媒体文件
- D. 数据库

**答案**：B

---

**题目 49**：关于 relationalStore（关系型数据库）的说法正确的是？
- A. 支持 SQL 查询
- B. 支持事务
- C. 支持多表关联
- D. 以上都正确

**答案**：D

---

**题目 50**：RDB 的创建使用哪个方法？
- A. createRdbStore
- B. getRdbStore
- C. new RdbStore
- D. openDatabase

**答案**：B

---

## 七、分布式能力

### 7.1 分布式基础

**题目 51**：分布式调用的特点包括？
- A. 跨设备通信
- B. 透明化调用
- C. 支持数据同步
- D. 以上都是

**答案**：D

---

**题目 52**：分布式数据管理的特点是？
- A. 跨设备数据同步
- B. 最终一致性
- C. 支持多种数据结构
- D. 以上都是

**答案**：D

---

**题目 53**：FeatureAbility 的作用是？
- A. 发起分布式调用
- B. 管理数据库
- C. 处理网络请求
- D. 渲染 UI

**答案**：A

---

**题目 54**：如何实现跨设备数据同步？
- A. 使用 distributedKVStore
- B. 使用 Preferences
- C. 使用 文件系统
- D. 使用 网络请求

**答案**：A

---

**题目 55**：分布式数据管理支持的数据类型包括？
- A. string
- B. number
- C. boolean
- D. 以上都是

**答案**：D

---

## 八、性能优化

### 8.1 渲染优化

**题目 56**：减少 UI 重绘的方法包括？
- A. 使用 @State 而非 @Observed
- B. 使用 LazyForEach
- C. 减少不必要的状态变化
- D. 以上都是

**答案**：D

---

**题目 57**：以下哪个不是有效的性能优化手段？
- A. 使用懒加载
- B. 减少组件嵌套
- C. 频繁调用 forceUpdate
- D. 合理使用缓存

**答案**：C

---

**题目 58**：@lazyTure 属性用于？
- A. 延迟加载组件
- B. 条件渲染
- C. 懒加载图片
- D. 延迟初始化

**答案**：D

---

**题目 59**：图片加载优化建议包括？
- A. 使用合适的图片格式
- B. 按需加载
- C. 图片缓存
- D. 以上都是

**答案**：D

---

**题目 60**：减少 JS 线程压力的方法包括？
- A. 减少复杂计算
- B. 使用 WebWorker
- C. 合理使用异步
- D. 以上都是

**答案**：D

---

## 九、安全与权限

### 9.1 权限管理

**题目 61**：HarmonyOS 的权限类型包括？
- A. system_grant（系统授权）
- B. user_grant（用户授权）
- C. both_grant
- D. A 和 B

**答案**：D

---

**题目 62**：user_grant 类型权限需要在什么时候申请？
- A. 应用安装时
- B. 首次使用功能时
- C. 任何时候
- D. 不需要申请

**答案**：B

**解析**：user_grant 类型权限需要用户在运行时授权。

---

**题目 63**：权限申请使用哪个方法？
- A. requestPermissions
- B. requestPermission
- C. verifyPermission
- D. checkPermission

**答案**：A

---

**题目 64**：ohos.permission.INTERNET 属于什么权限类型？
- A. user_grant
- B. system_grant
- C. 不需要权限
- D. 特殊权限

**答案**：B

---

**题目 65**：如何检查权限是否已授权？
- A. canRequestPermission
- B. checkPermission
- C. verifyPermission
- D. hasPermission

**答案**：A

---

## 十、ArkTS 高级特性

### 10.1 并发编程

**题目 66**：ArkTS 中创建异步任务应使用？
- A. async/await
- B. Promise
- C. callback
- D. 以上都可以

**答案**：D

---

**题目 67**：TaskPool 的作用是？
- A. 任务调度
- B. 后台任务执行
- C. 线程池管理
- D. 以上都是

**答案**：D

---

**题目 68**：Worker 的主要用途是？
- A. 处理耗时任务
- B. 不阻塞主线程
- C. 多线程编程
- D. 以上都是

**答案**：D

---

**题目 69**：以下哪个不是 ArkTS 的并发方案？
- A. async/await
- B. TaskPool
- C. Worker
- D. Thread

**答案**：D

---

**题目 70**：TaskPool 和 Worker 的区别是？
- A. TaskPool 适合短任务
- B. Worker 适合长任务
- C. TaskPool 自动管理线程
- D. 以上都正确

**答案**：D

---

### 10.2 模块化

**题目 71**：Har（Harmony Archive）的作用是？
- A. 代码共享
- B. 静态库
- C. 动态部署
- D. 资源打包

**答案**：A

**解析**：Har 用于代码共享，类似静态库。

---

**题目 72**：HSP（Harmony Shared Package）的特点是？
- A. 动态共享
- B. 按需加载
- C. 资源共享
- D. 以上都是

**答案**：D

---

**题目 73**：模块间的依赖应在哪个文件中配置？
- module.json5
- oh-package.json5
- package.json
- build.gradle

**答案**：B

---

**题目 74**：关于 ABC 文件的说法正确的是？
- A. ArkTS 编译产物
- B. 可在运行时加载
- C. 字节码文件
- D. 以上都正确

**答案**：D

---

**题目 75**：NAPI 的主要作用是？
- A. 调用 C++ 原生代码
- B. 性能优化
- C. 系统能力扩展
- D. 以上都是

**答案**：D

---

## 十一、综合应用

### 11.1 应用架构

**题目 76**：以下哪种是推荐的 MVVM 架构实现？
- A. View: UI 组件
- B. ViewModel: 业务逻辑 + 状态
- C. Model: 数据模型 + 仓库
- D. 以上都是

**答案**：D

---

**题目 77**：Repository 模式的作用是？
- A. 数据源抽象
- B. 统一数据访问
- C. 缓存管理
- D. 以上都是

**答案**：D

---

**题目 78**：以下关于路由的说法正确的是？
- A. 推荐使用 Navigation 组件
- B. router 模块适合简单场景
- C. 需要考虑登录拦截
- D. 以上都是

**答案**：D

---

**题目 79**：应用启动优化可以从哪些方面入手？
- A. 减少主线程阻塞
- B. 延迟非必要初始化
- C. 合理使用 Splash Screen
- D. 以上都是

**答案**：D

---

**题目 80**：关于 AOT 编译的说法正确的是？
- A. 提前编译字节码
- B. 提升运行性能
- C. 需要配置
- D. 以上都正确

**答案**：D

---

## 十二、常用 API

### 12.1 基础 API

**题目 81**：如何获取应用上下文？
- A. getContext()
- B. this.context
- C. applicationContext
- D. A 和 C

**答案**：D

---

**题目 82**：如何获取屏幕密度？
- A. display.getDensityDPI()
- B. window.getDensity()
- C. screen.getDPI()
- D. metrics.getDensity()

**答案**：A

---

**题目 83**：如何获取设备信息？
- A. deviceInfo
- B. systemParameter
- C. device.getInfo()
- D. A 和 B

**答案**：D

---

**题目 84**：如何发送应用内事件？
- A. emitter.emit
- B. eventBus.emit
- C. sendEvent
- D. postEvent

**答案**：A

---

**题目 85**：emitter 的主要用途是？
- A. 组件间通信
- B. 跨 Ability 通信
- C. 线程间通信
- D. 跨设备通信

**答案**：A

---

## 答案汇总

| 题号 | 答案 | 题号 | 答案 | 题号 | 答案 |
|:----:|:----:|:----:|:----:|:----:|:----:|
| 1 | B | 31 | A | 61 | D |
| 2 | D | 32 | A | 62 | B |
| 3 | D | 33 | A | 63 | A |
| 4 | D | 34 | D | 64 | B |
| 5 | D | 35 | B | 65 | A |
| 6 | A | 36 | A | 66 | D |
| 7 | D | 37 | A | 67 | D |
| 8 | D | 38 | A | 68 | D |
| 9 | D | 39 | D | 69 | D |
| 10 | D | 40 | A | 70 | D |
| 11 | C | 41 | B | 71 | A |
| 12 | A | 42 | A | 72 | D |
| 13 | B | 43 | B | 73 | B |
| 14 | B | 44 | A | 74 | D |
| 15 | B | 45 | B | 75 | D |
| 16 | B | 46 | D | 76 | D |
| 17 | B | 47 | B | 77 | D |
| 18 | B | 48 | B | 78 | D |
| 19 | A | 49 | D | 79 | D |
| 20 | B | 50 | B | 80 | D |
| 21 | A | 51 | D | 81 | D |
| 22 | B | 52 | D | 82 | A |
| 23 | A | 53 | A | 83 | D |
| 24 | A | 54 | A | 84 | A |
| 25 | D | 55 | D | 85 | A |

---

## 参考资料

- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- [ArkTS API 参考](https://developer.huawei.com/consumer/cn/doc/arkts-api)
- [ArkUI API 参考](https://developer.huawei.com/consumer/cn/doc/arkui-api)
- [HarmonyOS 应用模型](https://developer.huawei.com/consumer/cn/doc/application-models)

---

> **声明**：本题库由 AI 基于 HarmonyOS 官方文档整理，仅供学习参考，实际考试内容请以官方发布为准。
