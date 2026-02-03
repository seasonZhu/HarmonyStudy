# Network 模块使用指南

> **版本**: v1.0
> **更新日期**: 2026-02-03
> **适用项目**: HarmonyStudy

---

## 目录

1. [快速开始](#快速开始)
2. [架构概览](#架构概览)
3. [初始化配置](#初始化配置)
4. [API 封装](#api-封装)
5. [ViewModel 使用](#viewmodel-使用)
6. [完整示例](#完整示例)
7. [日志查看](#日志查看)

---

## 快速开始

### 1. 在 EntryAbility 中初始化

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets
import { NetworkProvider } from './httpRequest/NetworkProvider'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化 NetworkProvider
    NetworkProvider.init(this.context)
  }
}
```

### 2. 在页面中使用

```typescript
// entry/src/main/ets/pages/MyPage.ets
import { NetworkProvider } from '../httpRequest/NetworkProvider'

struct MyPage {
  aboutToAppear(): void {
    // NetworkProvider 已在 EntryAbility 中初始化
    this.loadData()
  }

  async loadData(): Promise<void> {
    try {
      const response = await NetworkProvider.get<Article[]>('/article/list/0/json')
      // 使用数据
    } catch (error) {
      // 处理错误
    }
  }
}
```

---

## 架构概览

### 模块结构

```
┌─────────────────────────────────────────────────┐
│                   Entry Module                  │
│  ┌─────────────────────────────────────────┐   │
│  │         NetworkProvider                 │   │
│  │  - 统一的 HTTP 客户端接口                │   │
│  │  - Token 管理                           │   │
│  │  - 环境切换                             │   │
│  └──────────────┬──────────────────────────┘   │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│              Network HAR Module                 │
│  ┌─────────────────────────────────────────┐   │
│  │             HttpClient                   │   │
│  │  - GET/POST/PUT/DELETE/PATCH            │   │
│  │  - 统一错误处理                          │   │
│  │  - 自动重试机制                          │   │
│  └──────────────┬──────────────────────────┘   │
│  ┌─────────────────────────────────────────┐   │
│  │         InterceptorManager              │   │
│  │  - LoggingInterceptor (日志)            │   │
│  │  - TokenInterceptor (Token 管理)        │   │
│  │  - RetryInterceptor (重试)              │   │
│  └──────────────┬──────────────────────────┘   │
│  ┌─────────────────────────────────────────┐   │
│  │        EnvironmentService                │   │
│  │  - DEV/TEST/STAGING/PROD                │   │
│  │  - 环境配置持久化                        │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### 文件结构

```
entry/src/main/ets/
├── httpRequest/
│   └── NetworkProvider.ets         # NetworkProvider 封装
├── network/examples/
│   ├── api/
│   │   ├── WanAndroidApi.ets       # API 封装示例
│   │   └── WanAndroidModels.ets    # 数据模型
│   ├── viewModel/
│   │   └── NetworkExampleViewModel.ets  # ViewModel 示例
│   └── pages/
│       └── NetworkExamplePage.ets  # 示例页面
└── api/
    ├── ArticleApi.ets              # 文章 API
    └── UserApi.ets                 # 用户 API

network/src/main/ets/
├── models/                          # 数据模型
│   ├── ApiResponse.ets             # 统一响应模型
│   ├── ApiError.ets                # 错误类型定义
│   └── HttpConfig.ets              # HTTP 配置模型
├── core/                            # 核心功能
│   ├── HttpClient.ets              # HTTP 客户端
│   ├── InterceptorManager.ets      # 拦截器管理器
│   └── ErrorHandler.ets            # 错误处理器
├── interceptors/                    # 拦截器
│   ├── LoggingInterceptor.ets      # 日志拦截器
│   ├── TokenInterceptor.ets        # Token 拦截器
│   └── RetryInterceptor.ets        # 重试拦截器
├── services/                        # 服务
│   ├── EnvironmentService.ets      # 环境服务
│   └── LoadingService.ets          # 加载服务
└── Network.ets                      # 统一导出
```

---

## 初始化配置

### 环境配置

Network 模块支持多环境配置：

```typescript
import { Environment } from 'network'

// 切换到开发环境（启用日志）
await NetworkProvider.switchEnvironment(Environment.DEV)

// 切换到测试环境（启用日志）
await NetworkProvider.switchEnvironment(Environment.TEST)

// 切换到预发布环境（启用日志）
await NetworkProvider.switchEnvironment(Environment.STAGING)

// 切换到生产环境（启用日志）
await NetworkProvider.switchEnvironment(Environment.PROD)
```

### Token 管理

```typescript
// 设置 Token（登录成功后）
await NetworkProvider.setToken('your_token_here')

// 获取 Token
const token = await NetworkProvider.getToken()

// 清除 Token（退出登录）
await NetworkProvider.clearToken()
```

---

## API 封装

### 基本请求方法

```typescript
// GET 请求
const response = await NetworkProvider.get<UserInfo>('/user/info')

// POST 请求
const response = await NetworkProvider.post<LoginResponse>('/user/login', {
  username: 'admin',
  password: '123456'
})

// PUT 请求
const response = await NetworkProvider.put<void>('/user/profile', {
  nickname: '新昵称'
})

// DELETE 请求
const response = await NetworkProvider.delete<void>(`/user/${userId}`)

// PATCH 请求
const response = await NetworkProvider.patch<void>('/user/status', {
  status: 1
})
```

### 带配置的请求

```typescript
// 显示加载提示
const response = await NetworkProvider.get<Data>('/api/data', {}, {
  showLoading: true,
  loadingText: '加载中...'
})

// 设置超时时间
const response = await NetworkProvider.post<Data>('/api/data', data, {
  timeout: 30000
})

// 自定义请求头
const response = await NetworkProvider.get<Data>('/api/data', {}, {
  headers: {
    'Custom-Header': 'value'
  }
})
```

### 完整的 API 示例

参考以下文件：
- `entry/src/main/ets/api/UserApi.ets` - 用户相关 API
- `entry/src/main/ets/api/ArticleApi.ets` - 文章相关 API
- `entry/src/main/ets/network/examples/api/WanAndroidApi.ets` - WanAndroid API 封装

---

## ViewModel 使用

### 基本 ViewModel 模式

```typescript
export class MyViewModel {
  private data: MyData | null = null
  private viewState: ViewState = ViewState.IDLE
  private errorMessage: string = ''

  async loadData(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      const response = await NetworkProvider.get<MyData>('/api/data')
      if (isSuccess(response)) {
        this.data = response.data
        this.setViewState(ViewState.SUCCESS)
      } else {
        this.errorMessage = response.errorMsg || '加载失败'
        this.setViewState(ViewState.ERROR)
      }
    } catch (error) {
      this.handleError(error, '加载数据失败')
    }
  }

  private handleError(error: Error | unknown, defaultMessage: string): void {
    if (error instanceof ApiError) {
      // 根据错误类型处理
      switch (error.type) {
        case ApiErrorType.NETWORK_ERROR:
          this.errorMessage = '网络连接失败'
          break
        case ApiErrorType.TIMEOUT_ERROR:
          this.errorMessage = '请求超时'
          break
        case ApiErrorType.AUTH_ERROR:
          this.errorMessage = '请重新登录'
          break
        default:
          this.errorMessage = error.message || defaultMessage
      }
    }
  }
}
```

### 完整示例

参考以下文件：
- `entry/src/main/ets/viewModel/NetworkExampleViewModel.ets` - 完整的 ViewModel 示例
- `entry/src/main/ets/network/examples/viewModel/NetworkExampleViewModel.ets` - WanAndroid 示例

---

## 完整示例

### NetworkExamplePage

位置：`entry/src/main/ets/network/examples/pages/NetworkExamplePage.ets`

该页面展示了 Network 模块的完整功能：

1. **首页数据** - 并发请求多个接口
2. **用户登录** - POST 请求 + Token 管理
3. **积分排行榜** - 分页加载
4. **搜索功能** - 带参数的请求
5. **环境切换** - 动态切换环境

### 导航到示例页面

```typescript
// entry/src/main/ets/router/PagesConstant.ets
export const Pages = {
  NETWORK_EXAMPLE: 'NetworkExamplePage',
  // ...
}

// 使用路由跳转
router.pushUrl({ url: Pages.NETWORK_EXAMPLE })
```

---

## 日志查看

### 启用日志

日志功能默认在所有环境中启用。网络请求日志会输出到 DevEco Studio 的 Hilog 控制台。

### 日志内容

**请求日志**：
```
[HTTP] Request:
  GET https://www.wanandroid.com/banner/json
  Headers:
    Content-Type: application/json
```

**响应日志**：
```
[HTTP] Response:
  GET https://www.wanandroid.com/banner/json
  Status: 200 OK
  Duration: 325ms
  Body: {
    "data": [...],
    "errorCode": 0,
    "errorMsg": ""
  }
```

### 查看日志

1. 打开 DevEco Studio
2. 切换到 **Hilog** 选项卡
3. 确保日志级别设置为 **Debug** 或 **All**
4. 运行应用并进行网络请求

---

## API 参考

### NetworkProvider

| 方法 | 说明 |
|------|------|
| `init(context)` | 初始化 NetworkProvider |
| `getClient()` | 获取 HttpClient 实例 |
| `get(url, params?, config?)` | GET 请求 |
| `post(url, data?, config?)` | POST 请求 |
| `put(url, data?, config?)` | PUT 请求 |
| `delete(url, params?, config?)` | DELETE 请求 |
| `patch(url, data?, config?)` | PATCH 请求 |
| `setToken(token)` | 设置 Token |
| `getToken()` | 获取 Token |
| `clearToken()` | 清除 Token |
| `switchEnvironment(env)` | 切换环境 |

### ApiResponse

```typescript
interface ApiResponse<T> {
  data: T | null
  errorCode: number
  errorMsg: string
}
```

### 工具函数

```typescript
// 判断响应是否成功
isSuccess(response: ApiResponse): boolean

// 提取数据
extractData<T>(response: ApiResponse<T>): T | null
```

---

## 常见问题

### Q1: 如何处理 Token 刷新？

```typescript
// Token 由 TokenInterceptor 自动管理
// 登录成功后设置 Token
await NetworkProvider.setToken(loginResponse.data.token)

// 退出时清除 Token
await NetworkProvider.clearToken()
```

### Q2: 如何调试网络请求？

日志功能默认启用，在 Hilog 控制台查看即可。

### Q3: 如何上传文件？

```typescript
const formData = new FormData()
formData.append('file', fileUri)
formData.append('name', 'filename')

const response = await NetworkProvider.post<UploadResult>(
  '/upload',
  formData,
  {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }
)
```

---

## 最佳实践

1. **统一封装 API** - 将所有接口封装到 Api 类中
2. **使用 ViewModel** - 在 ViewModel 中处理业务逻辑
3. **错误处理** - 统一处理各种错误类型
4. **加载状态** - 使用 viewState 管理加载状态
5. **Token 管理** - 统一管理 Token 的存储和刷新
6. **环境切换** - 使用环境服务管理不同环境

---

## 技术支持

如有问题，请查看：
- 源码：`network/src/main/ets/`
- 示例：`entry/src/main/ets/network/examples/`
- API 示例：`entry/src/main/ets/api/`
- 文档：`docs/NETWORK_SDK_README.md`
