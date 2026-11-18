# HarmonyStudy 技术架构文档

> WanAndroid 鸿蒙客户端 | 版本 2.0.0 | 分析日期: 2026-04-28

---

## 1. 项目概述

**项目名称**: HarmonyStudy
**项目类型**: HarmonyOS 原生应用（ArkTS/ArkUI）
**核心功能**: WanAndroid 第三方客户端，提供文章浏览、搜索、收藏、积分等功能
**代码规模**: 98个 .ets 文件，约 9,638 行代码

---

## 2. 项目结构

```
entry/src/main/ets/
├── accountManager/          # 账户管理（单例模式）
│   └── AccountManager.ets
├── constants/               # 常量配置
│   └── StyleConstants.ets
├── entryability/            # 应用入口
│   └── EntryAbility.ets
├── entity/                  # 实体类（数据传输对象）
│   ├── LoginOrRegisterInfo.ets
│   ├── KeywordInfo.ets
│   ├── TreeDetailInfo.ets
│   └── WebLink.ets
├── enum/                    # 枚举定义
│   ├── CollectActionType.ets
│   ├── ContentType.ets
│   ├── MyType.ets
│   ├── ScrollActionType.ets
│   ├── TabType.ets
│   └── ViewStatus.ets
├── httpRequest/             # 网络请求封装
│   ├── BaseProvider.ets     # 抽象基类
│   ├── Provider.ets         # 具体实现
│   ├── Environment.ets       # 环境配置
│   ├── EnvironmentManager.ets
│   ├── LoadingDialog.ets
│   └── interceptors/        # 拦截器链
│       ├── AxiosClientRequestInterceptor.ets
│       ├── AxiosClientResponseInterceptor.ets
│       ├── HttpRequestLoggerInterceptor.ets
│       ├── HttpResponseLoggerInterceptor.ets
│       ├── LoadingInterceptor.ets
│       └── SetCookieRequestInterceptor.ets
├── model/                   # 数据模型
│   ├── Article.ets
│   ├── Banner.ets
│   ├── BaseListDataSource.ets  # 列表数据源
│   ├── BaseResponse.ets
│   ├── HotKeyModel.ets
│   ├── LoginModel.ets
│   ├── MyCoinModel.ets
│   ├── PageModel.ets
│   ├── RankModel.ets
│   ├── TabModel.ets
│   └── UserInfoModel.ets
├── native/                   # 原生能力示例
├── network/                  # 网络示例模块
│   └── examples/
├── pages/                    # 页面（23个）
│   ├── Index.ets             # 主容器（Navigation + Tabs）
│   ├── Home.ets
│   ├── My.ets
│   ├── Tree.ets
│   ├── TabScaffold.ets
│   ├── TabsDetail.ets
│   ├── Login.ets             # @ComponentV2
│   ├── Register.ets
│   ├── SearchResult.ets
│   ├── HotKey.ets
│   ├── Rank.ets
│   ├── MyCoin.ets
│   ├── MyCollect.ets
│   ├── Setting.ets
│   ├── TreeDetail.ets
│   ├── WebPage.ets           # @ComponentV2
│   ├── WebComponent.ets
│   ├── WebExample.ets
│   ├── EnvironmentSwitch.ets
│   ├── ObservedV2TestPage.ets
│   ├── NativeComponentsDemo.ets
│   └── Splash.ets
├── router/                   # 路由
│   └── navPathStack.ets      # 单例路由栈 + 登录拦截器
├── utils/                    # 工具类
│   ├── ErrorHandler.ets
│   ├── Immersion.ets
│   ├── ListDataProcessor.ets
│   ├── LoadingDialogHelper.ets
│   ├── StringUtils.ets
│   └── ToastUtil.ets
├── viewModel/                # ViewModel层（12个）
│   ├── HomeViewModel.ets
│   ├── IndexViewModel.ets
│   ├── LoginViewModel.ets
│   └── ...
└── views/                    # 复用组件
    ├── ArticleCell.ets
    ├── BannerView.ets
    ├── MyHeader.ets
    └── ...
```

---

## 3. 架构设计

### 3.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        View 层                               │
│   Pages (Index, Home, My, ...) + Views (ArticleCell, ...)  │
├─────────────────────────────────────────────────────────────┤
│                    ViewModel 层                              │
│   HomeViewModel, LoginViewModel, MyViewModel, ...          │
├─────────────────────────────────────────────────────────────┤
│                    Model / Entity 层                        │
│   Article, UserInfo, Banner, ...                           │
├─────────────────────────────────────────────────────────────┤
│                    Provider 层 (网络)                        │
│   BaseProvider + Interceptors (拦截器链)                    │
├─────────────────────────────────────────────────────────────┤
│                    Service 层                               │
│   AccountManager (单例)                                    │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 数据流向

```
用户操作
    ↓
Page 页面
    ↓
ViewModel 处理业务逻辑
    ↓
Provider 发起网络请求（携带拦截器）
    ↓
服务器响应
    ↓
响应拦截器处理
    ↓
ViewModel 解析 BaseResponse
    ↓
更新 @State/@Local 状态
    ↓
UI 自动刷新
```

---

## 4. 技术栈

| 分类 | 技术 | 版本/详情 |
|------|------|----------|
| **框架** | ArkUI | HarmonyOS 原生 UI 框架 |
| **语言** | ArkTS | TypeScript 静态类型扩展 |
| **状态装饰器** | @State, @Local, @Prop, @Provide, @Consume | ArkUI 状态管理 |
| **网络库** | @ohos/axios | HTTP 客户端 |
| **工具库** | @pura/harmony-utils | Toast、Preferences、LogUtil |
| **事件总线** | @kit.BasicServicesKit emitter | 跨页面事件通信 |
| **Web容器** | @kit.ArkWeb | 网页展示 |
| **分享** | @kit.ShareKit | 系统分享 |
| **数据存储** | @kit.ArkData | 结构化数据 |
| **路由** | NavPathStack | HarmonyOS 原生路由 |

---

## 5. 核心模块详解

### 5.1 路由设计

**核心文件**: `router/navPathStack.ets`

```typescript
export const navPathStack: NavPathStack = new NavPathStack()

// 登录拦截器
navPathStack.setInterception({
  willShow(from, to) {
    if (AuthNames.includes(pageName) && !accountManager.isLogin()) {
      to.pathStack.pop()
      to.pathStack.pushPath({ name: 'Login' })
    }
  }
})
```

**路由跳转模式**:
```typescript
// 跳转
navPathStack.pushPath({ name: 'PageName', params: data })

// 返回
navPathStack.pop()

// 带值返回
navPathStack.pop(result)
```

**页面导出模式**:
```typescript
@Builder
export function PageNameBuilder() {
  PageName()
}
```

**需登录页面**: MyCollect, MyCoin, Setting, WebExample, WebComponent

### 5.2 状态管理

| 方式 | 作用域 | 示例 |
|------|--------|------|
| @State/@Local | 页面内 | `@State count: number = 0` |
| @Provide/@Consume | 跨组件 | `@Provide loginSuccessUserInfo` |
| emitter | 全局事件 | `emitter.emit(LOGIN_SUCCESS_EVENT, ...)` |
| AppStorage | 持久化 | `@StorageLink('key')` |

**emitter 事件总线**:
```typescript
// 定义事件常量 (Login.ets)
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"

// 发送事件
emitter.emit(LOGIN_SUCCESS_EVENT, { data: { userInfo } })

// 订阅事件 (My.ets)
emitter.on(LOGIN_SUCCESS_EVENT, (data) => {
  this.loginSuccessUserInfo = data.data["userInfo"]
})
```

### 5.3 网络封装

**BaseProvider 架构**:
```
BaseProvider (抽象基类)
├── instance: AxiosInstance
├── configurationAxios(): ConfigurationAxiosClient  # 抽象方法
├── configurationRequestInterceptor(): List<Interceptor>  # 抽象方法
└── configurationResponseInterceptor(): List<Interceptor>  # 抽象方法

Provider (具体实现)
├── 配置 baseURL/timeout
├── 添加 SetCookieRequestInterceptor
├── 添加 HttpRequestLoggerInterceptor
└── 添加 HttpResponseLoggerInterceptor
```

**拦截器类型**:
- `SetCookieRequestInterceptor` - 自动注入登录 Cookie
- `HttpRequestLoggerInterceptor` - 请求日志
- `HttpResponseLoggerInterceptor` - 响应日志
- `LoadingOpenInterceptor/LoadingCloseInterceptor` - 加载对话框

---

## 6. 设计模式

| 模式 | 位置 | 说明 |
|------|------|------|
| **单例模式** | AccountManager.ets | 全局用户状态管理 |
| **单例模式** | navPathStack.ets | 全局路由栈 |
| **模板方法** | BaseProvider.ets | 抽象 get/post，具体子类实现 |
| **拦截器链** | httpRequest/interceptors/* | 链式调用请求/响应拦截器 |
| **观察者模式** | BaseListDataSource.ets | DataChangeListener 列表 |
| **Builder模式** | 各页面 | `export function PageNameBuilder()` |
| **环境配置** | Environment.ets | DEV/TEST/PROD 三种环境 |

---

## 7. 架构评分

| 维度 | 评分 | 说明 |
|------|------|------|
| **分层架构** | 7/10 | ViewModel/Model/View 分离，但部分页面逻辑较重 |
| **路由设计** | 8/10 | NavPathStack 单例 + 拦截器，改造较完整 |
| **状态管理** | 6/10 | @State/@Local/@Provide/@Consume 混用，V1/V2 过渡期 |
| **网络封装** | 9/10 | 拦截器链模式，Environment 环境切换设计优秀 |
| **代码复用** | 8/10 | BaseListDataSource 抽象良好，组件化完整 |
| **设计模式** | 8/10 | 单例、拦截器、模板方法、观察者模式均有体现 |
| **类型安全** | 7/10 | 有 BaseResponse 泛型封装，但部分类型断言较多 |

**综合评分: 7.5/10**

---

## 8. 优点

1. **清晰的 MVVM 分层**: ViewModel 封装业务逻辑，Model 处理数据，View 专注 UI
2. **优秀的网络层设计**: 拦截器链模式支持请求/响应拦截，环境切换设计合理
3. **NavPathStack 单例路由**: 全局路由栈统一管理，配合拦截器实现登录验证
4. **BaseListDataSource 抽象**: 通用的列表数据源，支持 LazyForEach 高效渲染
5. **组件化程度高**: ArticleCell、ProjectCell、TreeCell 等可复用组件
6. **登录拦截器**: 集中式登录验证，无需在各页面重复判断
7. **工具库使用**: 善用 harmony-utils 简化 Toast/Log/Preferences 操作
8. **环境分离**: DEV/TEST/PROD 环境配置支持不同服务器

---

## 9. 改进建议

### 9.1 状态管理统一
**问题**: 当前 @State 和 @Local 混用，处于 V1/V2 过渡期
**建议**: 统一到 @ComponentV2 + @Local，使用 V2 装饰器获得更好的性能

### 9.2 旧路由代码清理
**问题**: Router.ets / RouterName.ets / PagesConstant.ets 废弃但未删除
**建议**: 确认新路由稳定后，删除旧路由文件

### 9.3 类型安全增强
**问题**: 部分代码使用 `as Xxx` 类型断言
**建议**: 使用更严格的泛型约束，减少类型断言

### 9.4 ViewModel 抽象
**问题**: 部分 ViewModel 逻辑重复
**建议**: 抽象 BaseViewModel，统一错误处理和加载状态管理

### 9.5 错误处理统一
**问题**: ErrorHandler 使用较零散
**建议**: 统一封装错误处理 централизованный

---

## 10. 路由图

```
Index (主容器 Navigation)
├── Home (首页)
│   └── WebPage (文章详情)
├── TabScaffold (项目/公众号 Tab 页)
│   ├── TabScaffold (列表)
│   └── TabsDetail (详情)
├── Tree (体系)
│   └── TreeDetail (知识体系详情)
└── My (个人中心)
    ├── Rank (排行榜)
    ├── MyCoin (积分)
    │   └── WebPage (积分详情)
    ├── MyCollect (收藏)
    │   └── WebPage (收藏文章)
    ├── WebExample / WebComponent (WebView 示例)
    ├── Setting (设置)
    └── EnvironmentSwitch (环境切换)
        ├── Login (登录)
        └── Register (注册)
```

---

## 11. 依赖关系

```
EntryAbility (入口)
    ↓
Index (加载 navPathStack)
    ↓
各 Tab 页 → 子页面 → WebPage
    ↓
AccountManager (单例用户状态)
    ↓
httpClient (Provider 单例)
    ↓
Axios Instance (拦截器链)
    ↓
WanAndroid API
```

---

## 12. 总结

HarmonyStudy 是一个架构清晰的 HarmonyOS 应用，采用 MVVM 模式分层设计，网络层使用拦截器链模式实现了良好的扩展性。路由已完成 NavPathStack 改造，状态管理处于 V1 向 V2 过渡期。主要改进方向为统一状态管理装饰器、清理废弃代码、增强类型安全。