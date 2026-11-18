# 网络层迁移注意事项

## 概述

本文档记录从 `httpRequest` 模块迁移到 `network` 模块的注意事项和最佳实践。

## 关键差异

### 1. 返回类型差异

#### httpRequest 模块

```typescript
// 返回 AxiosResponse
const response: AxiosResponse<BaseResponse<T>> = await provider.get(url)

// 访问数据需要多层解包
const data = response.data.data
```

#### network 模块

```typescript
// 返回 ApiResponse
const response: ApiResponse<T> = await httpClient.get(url)

// 访问数据更直接
const data = response.data
```

**迁移注意**：
- `httpRequest` 返回的是 `AxiosResponse<BaseResponse<T>>`
- `network` 返回的是 `ApiResponse<T>`（已解包一层）
- 需要调整数据访问路径

### 2. 错误处理差异

#### httpRequest 模块

```typescript
try {
  const response = await provider.get(url)
  // 处理成功
} catch (error) {
  // 错误类型不明确，需要判断
  if (error instanceof AxiosError) {
    // 处理网络错误
  }
}
```

#### network 模块

```typescript
try {
  const response = await httpClient.get(url)
  // 处理成功
} catch (error) {
  // 错误类型明确
  if (error instanceof ApiError) {
    switch (error.type) {
      case ApiErrorType.NETWORK:
        // 网络错误
        break
      case ApiErrorType.TIMEOUT:
        // 超时错误
        break
      case ApiErrorType.AUTH:
        // 认证错误
        break
      case ApiErrorType.SERVER:
        // 服务器错误
        break
    }
  }
}
```

**迁移注意**：
- network 模块提供更细粒度的错误类型
- 可以根据错误类型进行不同的处理
- 建议在 Repository 层统一处理错误

### 3. 拦截器配置差异

#### httpRequest 模块

```typescript
// 在 Provider.ets 中配置
configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
  let interceptors = new List<AxiosClientRequestInterceptor>()
  interceptors.add(new SetCookieRequestInterceptor())
  interceptors.add(new HttpRequestLoggerInterceptor())
  return interceptors
}
```

#### network 模块

```typescript
// 使用拦截器管理器
const loggingInterceptor = createLoggingInterceptor({ enabled: true })
client.getAxiosInstance().interceptors.request.use(
  loggingInterceptor.request.bind(loggingInterceptor)
)

// 或自定义拦截器
class CustomInterceptor implements RequestInterceptor {
  async intercept(config: AxiosRequestConfig): Promise<AxiosRequestConfig> {
    // 自定义逻辑
    return config
  }
}
```

**迁移注意**：
- 需要将现有拦截器迁移到 network 模块
- Cookie 拦截器需要特别处理
- Token 拦截器已有现成实现

### 4. 环境管理差异

#### httpRequest 模块

```typescript
// 在 Environment.ets 中定义
export enum Environment {
  DEV,
  TEST,
  PROD
}

// 在 Provider 中使用
static async initEnvironment(): Promise<void> {
  Provider.currentEnv = await environmentManager.getCurrentEnvironment()
  Provider.currentConfig = EnvConfig.getConfig(Provider.currentEnv)
}
```

#### network 模块

```typescript
// 使用 EnvironmentService
import { environmentService } from 'network'

// 切换环境
environmentService.setEnvironment(Environment.DEV)

// 获取当前配置
const config = environmentService.getCurrentConfig()
```

**迁移注意**：
- network 模块的环境管理更灵活
- 可以在运行时切换环境
- 需要确保环境配置一致

## 迁移步骤

### 步骤 1：创建 Repository 层

```typescript
// repository/base/BaseRepository.ets
import { getHttpClient, HttpClient, ApiError } from 'network'

export abstract class BaseRepository {
  protected httpClient: HttpClient
  
  constructor() {
    this.httpClient = getHttpClient()
  }
  
  protected handleError(error: ApiError): void {
    // 统一错误处理
    LogUtil.error('API Error:', error.message)
    ToastUtil.showToast(error.message)
  }
}
```

### 步骤 2：创建具体 Repository

```typescript
// repository/ArticleRepository.ets
import { BaseRepository } from './base/BaseRepository'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { ApiConstants } from '../constants/ApiConstants'

export class ArticleRepository extends BaseRepository {
  async getArticleList(page: number): Promise<Article[]> {
    try {
      const response = await this.httpClient.get<PageModel<Article>>(
        ApiConstants.articleList(page)
      )
      return response.data.datas
    } catch (error) {
      this.handleError(error as ApiError)
      throw error
    }
  }
}
```

### 步骤 3：修改 ViewModel

```typescript
// viewModel/RankViewModel.ets (迁移前)
import provider from '../httpRequest/Provider'
import { AxiosResponse } from '@ohos/axios'
import { BaseResponse } from '../model/BaseResponse'
import { PageModel } from '../model/PageModel'
import { RankModel } from '../model/RankModel'
import { ApiConstants } from '../constants/ApiConstants'

export class RankViewModel {
  async getRank(page: number): Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>> {
    return provider.get(ApiConstants.coinRank(page))
  }
}
```

```typescript
// viewModel/RankViewModel.ets (迁移后)
import { RankRepository } from '../repository/RankRepository'
import { RankModel } from '../model/RankModel'

export class RankViewModel {
  private rankRepo = new RankRepository()
  
  async getRank(page: number): Promise<RankModel[]> {
    return this.rankRepo.getRankList(page)
  }
}
```

### 步骤 4：修改 Page

```typescript
// pages/Rank.ets (迁移前)
const result = await this.viewModel.getRank(page)
const ranks = result.data.data.datas
```

```typescript
// pages/Rank.ets (迁移后)
const ranks = await this.viewModel.getRank(page)
```

## 常见问题

### Q1: 如何处理登录态？

**A**: 使用 network 模块的 Token 拦截器

```typescript
import { createTokenInterceptor } from 'network'

const tokenInterceptor = createTokenInterceptor({
  getToken: () => AccountManager.shared().getToken(),
  onTokenExpired: () => {
    // Token 过期处理
    Router.toLogin()
  }
})

httpClient.getAxiosInstance().interceptors.request.use(
  tokenInterceptor.request.bind(tokenInterceptor)
)
```

### Q2: 如何处理 Cookie？

**A**: 需要自定义拦截器

```typescript
class CookieInterceptor implements RequestInterceptor {
  async intercept(config: AxiosRequestConfig): Promise<AxiosRequestConfig> {
    // 从存储中获取 Cookie
    const cookie = await StorageUtil.get('cookie')
    if (cookie) {
      config.headers = {
        ...config.headers,
        'Cookie': cookie
      }
    }
    return config
  }
}
```

### Q3: 如何处理文件上传/下载？

**A**: network 模块支持，但需要特殊配置

```typescript
// 文件上传
const formData = new FormData()
formData.append('file', file)

const response = await httpClient.post('/upload', formData, {
  headers: {
    'Content-Type': 'multipart/form-data'
  }
})

// 文件下载
const response = await httpClient.get('/download', {
  responseType: 'blob'
})
```

### Q4: 如何处理并发请求？

**A**: 使用 Promise.all

```typescript
const [articles, banners, hotKeys] = await Promise.all([
  articleRepo.getArticleList(0),
  bannerRepo.getBanners(),
  hotKeyRepo.getHotKeys()
])
```

### Q5: 如何处理请求取消？

**A**: 使用 AbortController

```typescript
const controller = new AbortController()

// 发起请求
const response = await httpClient.get(url, {
  signal: controller.signal
})

// 取消请求
controller.abort()
```

## 最佳实践

### 1. 错误处理统一在 Repository 层

```typescript
export class ArticleRepository extends BaseRepository {
  async getArticleList(page: number): Promise<Article[]> {
    try {
      const response = await this.httpClient.get<PageModel<Article>>(
        ApiConstants.articleList(page)
      )
      return response.data.datas
    } catch (error) {
      // 在 Repository 层统一处理错误
      this.handleError(error as ApiError)
      // 重新抛出，让 ViewModel 知道
      throw error
    }
  }
}
```

### 2. ViewModel 返回业务模型，而非 HTTP 响应

```typescript
// ❌ 错误：返回 HTTP 响应
async getRank(page: number): Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>> {
  return provider.get(ApiConstants.coinRank(page))
}

// ✅ 正确：返回业务模型
async getRank(page: number): Promise<RankModel[]> {
  return this.rankRepo.getRankList(page)
}
```

### 3. Page 只负责 UI 渲染

```typescript
// ❌ 错误：Page 处理 HTTP 错误
const result = await this.viewModel.getRank(page)
if (result.data.errorCode !== 0) {
  ToastUtil.showToast(result.data.errorMsg)
  return
}

// ✅ 正确：Page 只处理 UI
try {
  const ranks = await this.viewModel.getRank(page)
  this.rankList = ranks
} catch (error) {
  // 错误已在 Repository 层处理，这里只需要更新 UI 状态
  this.status = ViewStatus.error
}
```

### 4. 使用依赖注入（可选）

```typescript
// 使用依赖注入管理 Repository
export class ViewModelFactory {
  private static articleRepo = new ArticleRepository()
  private static rankRepo = new RankRepository()
  
  static getArticleRepository(): ArticleRepository {
    return this.articleRepo
  }
  
  static getRankRepository(): RankRepository {
    return this.rankRepo
  }
}

// 在 ViewModel 中使用
export class HomeViewModel {
  private articleRepo = ViewModelFactory.getArticleRepository()
}
```

## 测试清单

在迁移每个 ViewModel 时，请确保：

- [ ] 创建对应的 Repository
- [ ] Repository 正确处理错误
- [ ] ViewModel 返回业务模型
- [ ] Page 正确使用新数据结构
- [ ] 所有功能正常工作
- [ ] 错误场景正确处理
- [ ] 性能无明显下降

---

**文档版本**：v1.0  
**最后更新**：2026-08-17  
**负责人**：开发团队
