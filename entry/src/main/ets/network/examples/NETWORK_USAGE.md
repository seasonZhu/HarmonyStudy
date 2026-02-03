# Network 模块使用指南

## 目录

1. [快速开始](#快速开始)
2. [初始化配置](#初始化配置)
3. [API 封装](#api-封装)
4. [ViewModel 使用](#viewmodel-使用)
5. [完整示例](#完整示例)
6. [日志查看](#日志查看)

---

## 快速开始

### 1. 在 EntryAbility 中初始化

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets
import { NetworkProvider } from '../httpRequest/NetworkProvider'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化 NetworkProvider
    NetworkProvider.init(this.context)
  }
}
```

### 2. 创建 API 文件

```typescript
// entry/src/main/ets/api/UserApi.ets
import { NetworkProvider } from '../httpRequest/NetworkProvider'
import { isSuccess } from 'network'

export interface LoginRequest {
  username: string
  password: string
}

export class UserApi {
  private static readonly BASE_PATH = '/user'

  static async login(request: LoginRequest): Promise<void> {
    const response = await NetworkProvider.post<void>(
      `${this.BASE_PATH}/login`,
      request,
      { showLoading: true, loadingText: '登录中...' }
    )

    if (!isSuccess(response)) {
      throw new Error(response.errorMsg || '登录失败')
    }
  }
}
```

### 3. 在 ViewModel 中使用

```typescript
// entry/src/main/ets/viewModel/LoginViewModel.ets
import { UserApi } from '../api/UserApi'
import { ApiError } from 'network'

export class LoginViewModel {
  async login(username: string, password: string): Promise<void> {
    try {
      await UserApi.login({ username, password })
    } catch (error) {
      if (error instanceof ApiError) {
        // 处理特定类型的错误
      }
      throw error
    }
  }
}
```

---

## 初始化配置

### 环境配置

Network 模块支持多环境配置：

```typescript
import { Environment, environmentService } from 'network'

// 切换到开发环境
await NetworkProvider.switchEnvironment(Environment.DEV)

// 切换到测试环境
await NetworkProvider.switchEnvironment(Environment.TEST)

// 切换到预发布环境
await NetworkProvider.switchEnvironment(Environment.STAGING)

// 切换到生产环境
await NetworkProvider.switchEnvironment(Environment.PROD)
```

**环境配置**：
- DEV（开发环境）- 默认环境，启用日志
- TEST（测试环境）- 启用日志
- STAGING（预发布环境）- 启用日志
- PROD（生产环境）- 启用日志

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
- `entry/src/main/ets/network/examples/api/WanAndroidApi.ets` - WanAndroid API

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
      const response = await MyApi.getData()
      this.data = response.data
      this.setViewState(ViewState.SUCCESS)
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

### 分页加载示例

```typescript
export class ArticleListViewModel {
  private articleList: Article[] = []
  private currentPage: number = 1
  private hasMore: boolean = true

  async loadArticles(refresh: boolean = false): Promise<void> {
    if (refresh) {
      this.currentPage = 1
      this.articleList = []
    }

    if (!this.hasMore) {
      return
    }

    const response = await ArticleApi.getArticleList({
      page: this.currentPage,
      pageSize: 20
    })

    if (refresh) {
      this.articleList = response.list
    } else {
      this.articleList = [...this.articleList, ...response.list]
    }

    this.hasMore = response.hasMore
    this.currentPage = response.page + 1
  }
}
```

### 并发请求示例

```typescript
async loadCompleteData(): Promise<void> {
  try {
    // 并发请求多个接口
    const [userInfo, userCoin, userArticles] = await Promise.all([
      UserApi.getUserInfo(),
      UserApi.getUserCoin(),
      ArticleApi.getUserArticles()
    ])

    // 处理返回数据
  } catch (error) {
    // 处理错误
  }
}
```

---

## 完整示例

参考以下文件：
- `entry/src/main/ets/network/examples/viewModel/NetworkExampleViewModel.ets` - ViewModel 完整示例
- `entry/src/main/ets/network/examples/pages/NetworkExamplePage.ets` - 页面完整示例

### 主要功能演示

1. **登录示例** - POST 请求
2. **获取首页数据** - GET 请求 + 并发请求
3. **搜索文章** - 带参数的 GET 请求
4. **积分排行榜** - 分页加载
5. **环境切换** - 动态切换环境
6. **错误处理** - 统一的错误处理

---

## 日志查看

### 启用日志

日志功能默认在所有环境中启用。网络请求日志会输出到 **DevEco Studio Hilog 控制台**。

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

## API 参考

### NetworkProvider

| 方法 | 说明 |
|------|------|
| `init(context)` | 初始化 |
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
- 完整示例页面：`entry/src/main/ets/network/examples/pages/NetworkExamplePage.ets`
- 文档：`docs/NETWORK_SDK_README.md`
