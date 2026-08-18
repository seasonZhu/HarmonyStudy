# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

HarmonyStudy 是基于 WanAndroid 开放 API 开发的 HarmonyOS 原生客户端，采用 ArkTS + MVVM 架构。

**跨平台架构对照**：
| 平台 | 项目 | 架构 |
|------|------|------|
| iOS | RxStudy | RxSwift + MVVM |
| Android | GetXStudy | GetX + MVC |
| 跨平台 | UniAppPlayAndroid | Vue3 + UniApp |
| HarmonyOS | HarmonyStudy | ArkTS + MVVM |

---

## 模块架构

```
HarmonyStudy/
├── entry/              # 主应用模块（主入口）
├── librarySDK/         # 工具库模块（可复用的SDK组件）
├── network/            # 独立网络模块
├── Utils/              # 工具函数模块
├── docs/               # 项目文档
└── examples/           # 示例代码
```

### entry 模块结构

```
entry/src/main/ets/
├── pages/              # 页面组件（22个页面）
├── views/              # 可复用视图组件（InfoCell, ArticleCell, StatusWeight等）
├── viewModel/          # 视图模型（HomeViewModel, LoginViewModel等）
├── router/             # 路由管理（navPathStack）
├── httpRequest/         # 网络请求封装
│   ├── Provider.ets    # HTTP客户端实例
│   ├── interceptors/   # 拦截器（Loading, Cookie, Logger）
│   └── configuration/  # 网络配置
├── utils/              # 工具类（LoadingDialogHelper, ToastUtil, ListDataProcessor）
├── model/              # 数据模型（Article, Banner, User等）
├── entity/             # 实体类
├── enum/               # 枚举类型
├── accountManager/     # 账户管理（单例模式）
├── constants/          # 常量定义
└── native/             # 原生组件（UniApp调用入口）
```

### librarySDK 模块

导出可复用的SDK组件：
```typescript
export { MainPage, SDKTools, RouteConstant, importHeadFile } from './components/...'
```

### network 模块

独立封装的完整HTTP模块：
- `core/HttpClient` - HTTP客户端核心
- `core/InterceptorManager` - 拦截器管理
- `core/ErrorHandler` - 错误处理
- `services/EnvironmentService` - 环境管理（DEV/PROD）
- `services/LoadingService` - Loading服务
- `interceptors/` - 拦截器实现

### Utils 模块

导出的工具函数：
```typescript
export { AreaHeight, FullScreen, SaveContext, StatusBar, CaptureTool, Skeleton }
```

---

## 核心模式

### 路由模式（NavPathStack）

使用 `NavPathStack` 进行路由管理，**页面必须导出 Builder 函数**：

```typescript
// 页面定义
@Entry({routeName: RouterName.Home})
@Component
struct Home {
  build() {
    NavDestination() { /* ... */ }
  }
}

// ✅ 导出 Builder 函数（路由注册用）
@Builder
export function HomeBuilder() {
  Home()
}
```

**路由配置文件**：`entry/src/main/module.json5` 中的 routerMap

**登录拦截**：在 `navPathStack.ets` 中配置路由拦截器，检查 `AuthNames` 列表

### MVVM 架构

```
Pages (UI层) → ViewModels (业务逻辑) → Models (数据层)
```

ViewModel 示例：
```typescript
export class HomeViewModel {
  getBanner = (): Promise<...> => httpClient.get('banner/json')
  getNormalArticle = (page: number): Promise<...> => httpClient.get(`article/list/${page}/json`)
}
```

### 列表数据处理

使用 `ListDataProcessor` 统一处理分页列表：
```typescript
ListDataProcessor.processMixedData(
  this.dataSource,           // Banner数据源
  this.listDataSource,       // 文章数据源
  results,                   // 网络响应
  ScrollActionType.refresh,  // 刷新/加载更多
  (status) => this.status = status
)
```

### @Builder 组件封装模式

**@Builder**：方法级UI封装，适合页面内复用
```typescript
struct Home {
  @Builder
  private getListView() { /* ... */ }

  build() {
    Column() {
      this.getListView()  // 调用Builder方法
    }
  }
}
```

**@Component + export**：独立组件，适合跨文件复用
```typescript
@Component
export struct StatusWeight {
  @BuilderParam contentBuilder: () => void  // 接收外部Builder
  build() { this.contentBuilder() }
}
```

---

## 常用命令

### 安装依赖
```bash
cd entry && ohpm install
cd ../network && ohpm install
cd ../Utils && ohpm install
```

### 运行项目
在 DevEco Studio 中连接设备后点击 Run，或：
```bash
# DevEco Studio CLI
hvigor --mode module -p product=default -p module=entry build
```

### 测试
```bash
# 单元测试
cd Utils && npm run test:unit

# UI测试
cd entry && npm run test:ohos
```

---

## 关键文件

| 文件 | 用途 |
|------|------|
| `entry/src/main/ets/router/navPathStack.ets` | 路由栈单例 + 登录拦截 |
| `entry/src/main/ets/httpRequest/Provider.ets` | HTTP客户端实例 |
| `entry/src/main/ets/utils/ListDataProcessor.ets` | 列表数据处理器 |
| `entry/src/main/ets/views/StatusWeight.ets` | 页面状态组件（loading/error/empty/success） |
| `entry/src/main/ets/utils/LoadingDialogHelper.ets` | Loading弹窗工具 |
| `network/src/main/ets/Network.ets` | 独立网络模块入口 |

---

## 第三方依赖

| 库 | 版本 | 用途 |
|----|------|------|
| @ohos/axios | ^2.2.7 | HTTP请求 |
| @ohos/pulltorefresh | ^3.0.0 | 下拉刷新 |
| @ohos/imageknife | ^3.2.8 | 图片加载 |
| @pura/harmony-utils | ^1.4.0 | 工具类（LogUtil） |
| @jxt/xt_hud | ^3.4.0 | Loading/Toast弹窗 |

---

## 注意事项

1. **NavPathStack 路由**：页面必须使用 `@Builder export function XxxBuilder()` 导出，否则路由无法找到页面
2. **环境切换**：`EnvironmentSwitch.ets` 页面可切换 DEV/PROD 环境
3. **登录拦截**：`AuthNames` 数组中的页面需要登录才能访问
4. **@Component vs @Builder**：
   - `@Builder` 用于方法内UI片段封装
   - `@Component` 用于独立可复用组件
