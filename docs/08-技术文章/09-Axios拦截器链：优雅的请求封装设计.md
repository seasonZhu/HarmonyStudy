# HarmonyOS Axios 拦截器链设计：让网络请求变得优雅

> 书接上回，之前我们聊了 NavPathStack 路由架构的那些坑，今天我们来聊聊网络请求封装这个老生常谈的话题。讲真，网络请求封装这玩意儿，iOS 开发那会儿我折腾过 Alamofire，Android 开发用 Retrofit，到了 HarmonyOS 这边，用的是 Axios for HarmonyOS。本质上都是请求库，但封装思路各有千秋。今天就以我项目中的实际代码为例，和大家好好掰扯掰扯拦截器链设计这个话题。

## 1. 先说痛点

聊到网络请求封装，我们经常会遇到这么几个问题：

- **通用参数处理**：每个接口都要加 token、cookie、userId，写得手都酸了
- **统一错误处理**：网络超时、服务器错误、解析失败，代码里到处都是 try-catch
- **日志打印**：调试的时候想看看请求参数和响应结果，还得手动 console.log
- **Loading 状态**：请求前显示 Loading，请求完关掉，UI 和业务逻辑耦合得乱七八糟
- **环境切换**：开发、测试、生产环境 baseURL 不一样，每次切换还得改代码

但是！但是！用了拦截器链之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         HTTP 请求发起                               │
│                           userViewModel.getData()                   │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        BaseProvider.instance                         │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    axios.create(config)                          │ │
│  │                                                                    │ │
│  │   ┌─────────────────┐     ┌─────────────────┐                  │ │
│  │   │  请求拦截器链     │     │  响应拦截器链    │                  │ │
│  │   │  (按顺序执行)    │     │  (按顺序执行)    │                  │ │
│  │   │                 │     │                 │                  │ │
│  │   │  1. SetCookie   │     │  1. HttpRespLog │                  │ │
│  │   │  2. HttpReqLog  │     │  2. ErrorHandle │                  │ │
│  │   │                 │     │                 │                  │ │
│  │   └────────┬────────┘     └────────┬────────┘                  │ │
│  └────────────┼──────────────────────┼────────────────────────────┘ │
└───────────────┼──────────────────────┼──────────────────────────────┘
                │                      │
                ▼                      ▼
        ┌───────────────┐      ┌───────────────┐
        │  请求拦截器    │      │  响应拦截器   │
        │  onFulfilled  │      │  onFulfilled │
        │  onRejected  │      │  onRejected  │
        └───────────────┘      └───────────────┘
```

这个架构图看起来清晰明了，核心就是那个**拦截器链**。请求拦截器负责"动手脚"——加 token、改参数；响应拦截器负责"善后"——统一错误处理、日志打印。

## 3. 核心代码展示

### 3.1 拦截器接口定义

**Talk is cheap, show me the code**

```typescript
// AxiosClientRequestInterceptor.ets
import { AxiosError, InternalAxiosRequestConfig } from '@ohos/axios';

export interface AxiosClientRequestInterceptor {
  onFulfilled?: (config: InternalAxiosRequestConfig) => InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>
  onRejected?: (error: AxiosError) => Error
}
```

```typescript
// AxiosClientResponseInterceptor.ets
import { AxiosError, AxiosResponse } from '@ohos/axios';

export interface AxiosClientResponseInterceptor {
  onFulfilled?: (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>
  onRejected?: (error: AxiosError) => AxiosError
}
```

这里我定义了两个接口，借鉴了 Axios 经典的拦截器设计理念：

| 接口 | 作用 | 执行时机 |
|------|------|----------|
| `AxiosClientRequestInterceptor` | 封装请求参数 | 请求发送前 |
| `AxiosClientResponseInterceptor` | 封装响应处理 | 响应返回后 |

### 3.2 BaseProvider 抽象基类

```typescript
// BaseProvider.ets
export abstract class BaseProvider {

  readonly instance: AxiosInstance

  constructor() {
    // 创建 Axios 实例
    this.instance = axios.create(this.configurationAxios())

    // 配置请求拦截器
    try {
      this.configurationRequestInterceptor().forEach((interceptor: AxiosClientRequestInterceptor) => {
        this.instance.interceptors.request.use(interceptor.onFulfilled, interceptor.onRejected)
      })
    } catch (error) {
      ErrorHandler.handle(error, '请求拦截器配置失败')
    }

    // 配置响应拦截器
    try {
      this.configurationResponseInterceptor().forEach((interceptor: AxiosClientResponseInterceptor) => {
        this.instance.interceptors.response.use(interceptor.onFulfilled, interceptor.onRejected)
      })
    } catch (error) {
      ErrorHandler.handle(error, '响应拦截器配置失败')
    }
  }

  // 抽象方法：子类实现
  abstract configurationAxios(): ConfigurationAxiosClient
  abstract configurationRequestInterceptor(): List<AxiosClientRequestInterceptor>
  abstract configurationResponseInterceptor(): List<AxiosClientResponseInterceptor>
}
```

这个设计思路之所以优雅，根本原因在于：

1. **模板方法模式**：基类定义骨架，子类实现细节
2. **开闭原则**：新增拦截器只需添加，不用修改基类
3. **单一职责**：每个拦截器只负责一件事

### 3.3 请求拦截器实现

#### Cookie 拦截器

```typescript
// SetCookieRequestInterceptor.ets
export class SetCookieRequestInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    // 配置Cookie
    let cookie = getCookieHeaderValue()
    config.headers.set('Cookie', cookie)
    return config
  }
}

export function getCookieHeaderValue(): string {
  let username = AccountManager.shared().loginModel?.username ?? ""
  let password = AccountManager.shared().loginModel?.password ?? ""

  if (username.length == 0 && password.length == 0) {
    return ""
  } else {
    return "loginUserName=" + username + ";loginUserPassword=" + password
  }
}
```

> 这里有个小坑要提醒大家：**Cookie 相关的函数不能写在拦截器类内部**，否则所有网络请求都会报错。原因在于 ArkTS 的模块加载机制，建议将工具函数单独导出。

#### 日志拦截器

```typescript
// HttpRequestLoggerInterceptor.ets
export class HttpRequestLoggerInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    LogUtil.debug("<--- http request " + config.baseURL + config.url + "   " + config.method + ' --->')
    LogUtil.debug("http request config: " + JSON.stringify(config))
    LogUtil.debug("<--------------------------------------------------------------------->")
    return config
  }
}
```

```typescript
// HttpResponseLoggerInterceptor.ets
export class HttpResponseLoggerInterceptor implements AxiosClientResponseInterceptor {
  onFulfilled(response: AxiosResponse) {
    LogUtil.debug("<--- http response " + response.config.baseURL + response.config.url + " --->")
    LogUtil.debug("http response status: " + response.status)
    LogUtil.debug("http response data: " + JSON.stringify(response.data))
    LogUtil.debug("<--------------------------------------------------------------------->")
    return response
  }
}
```

### 3.4 Provider 配置

```typescript
// Provider.ets
export class Provider extends BaseProvider {

  configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
    let interceptors = new List<AxiosClientRequestInterceptor>()
    interceptors.add(new SetCookieRequestInterceptor())
    interceptors.add(new HttpRequestLoggerInterceptor())
    return interceptors
  }

  configurationResponseInterceptor(): List<AxiosClientResponseInterceptor> {
    let interceptors = new List<AxiosClientResponseInterceptor>()
    interceptors.add(new HttpResponseLoggerInterceptor())
    return interceptors
  }

  configurationAxios(): ConfigurationAxiosClient {
    const config: ConfigurationAxiosClient = {
      baseURL: Provider.getBaseUrl(),
      timeout: Provider.getTimeout(),
    }
    return config
  }
}
```

你说妙不妙？拦截器的配置化带来的最大好处就是**可插拔**。想要什么拦截器，`add` 一下就行，不想要了，`remove` 掉就行。

## 4. 拦截器执行顺序

```
请求流程：
┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────┐
│  请求1  │ -> │ SetCookie   │ -> │ HttpReqLog  │ -> │  发送   │
└─────────┘    └─────────────┘    └─────────────┘    └─────────┘

响应流程：
┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────┐
│  响应1  │ -> │ HttpRespLog  │ -> │ ErrorHandle │ -> │  返回   │
└─────────┘    └─────────────┘    └─────────────┘    └─────────┘
```

拦截器是**按添加顺序执行**的，这点非常重要！

- 请求拦截器：1 -> 2 -> 3（最先添加的最先执行）
- 响应拦截器：1 -> 2 -> 3（最后添加的最先执行，类似于"栈"的概念）

## 5. Loading 拦截器封装

有时候我们需要在请求时显示 Loading，请求结束后关闭 Loading。这时候可以封装一个 Loading 拦截器：

```typescript
// LoadingInterceptor.ets
export class LoadingOpenInterceptor implements AxiosClientRequestInterceptor {
  openCallback?: () => void

  constructor(openCallback?: () => void) {
    this.openCallback = openCallback
  }

  onFulfilled(config: InternalAxiosRequestConfig) {
    // 可以根据 URL 判断是否需要 Loading
    if (config.url == "banner/json") {
      if (this.openCallback) {
        this.openCallback()
      }
    }
    return config
  }
}

export class LoadingCloseInterceptor implements AxiosClientResponseInterceptor {
  closeCallback?: () => void

  onFulfilled(response: AxiosResponse) {
    if (this.closeCallback) {
      this.closeCallback()
    }
    return response
  }

  onRejected(error: AxiosError) {
    if (this.closeCallback) {
      this.closeCallback()
    }
    return error
  }
}
```

使用时：

```typescript
// 在 ViewModel 中
private loadingHelper = new LoadingDialogHelper('正在加载...')

async fetchData() {
  await this.loadingHelper.wrap(
    this.provider.get<T>('/api/data')
  )
}
```

## 6. 错误处理拦截器

```typescript
// ErrorHandleInterceptor.ets
export class ErrorHandleInterceptor implements AxiosClientResponseInterceptor {

  onFulfilled(response: AxiosResponse) {
    // 业务错误码处理
    if (response.data.errorCode != 0) {
      // 统一处理业务错误
      ErrorHandler.handle(new Error(response.data.errorMsg), '业务错误')
    }
    return response
  }

  onRejected(error: AxiosError) {
    // 网络错误处理
    if (error.code == 'ERR_NETWORK') {
      ErrorHandler.handle(error, '网络连接失败')
    } else if (error.code == 'ECONNABORTED') {
      ErrorHandler.handle(error, '请求超时')
    }
    return error
  }
}
```

## 7. 对比 iOS 的 Alamofire

说实话，相比 iOS 的 Alamofire 拦截器设计，HarmonyOS 这套 Axios 拦截器也是毫不逊色的：

| 特性 | Alamofire | Axios for HarmonyOS |
|------|-----------|---------------------|
| 请求拦截 | RequestInterceptor | AxiosClientRequestInterceptor |
| 响应拦截 | ResponseInterceptor | AxiosClientResponseInterceptor |
| 适配器 | Adapter | - |
| 合并器 | Retrier | onRejected |
| 链式执行 | 闭包链式调用 | forEach + use |

Alamofire 胜在生态成熟，Axios 胜在**上手简单**、**配置灵活**。

## 总结

HarmonyOS 的 Axios 拦截器链设计，我这段时间用下来是真的香：

1. **接口设计**：请求/响应分离，职责明确
2. **模板方法模式**：BaseProvider 定义骨架，子类实现细节
3. **配置化**：拦截器按需添加，灵活可插拔
4. **统一错误处理**：响应拦截器集中处理错误
5. **日志透明**：请求/响应自动打印日志

推荐在需要**统一处理网络请求**、**解耦 UI 和业务**的场景下使用这套拦截器链方案。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
