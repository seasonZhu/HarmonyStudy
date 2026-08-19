# HarmonyOS 快速参考手册

> **版本**: v2.0  
> **更新日期**: 2026-08-19

---

## 一、命名规范速查

### 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面 | PascalCase，无 Page 后缀 | `Login.ets`, `Profile.ets` |
| 组件 | PascalCase + 功能前缀 | `ArticleCell.ets`, `BannerView.ets` |
| ViewModel | 页面名 + ViewModel | `LoginViewModel.ets` |
| Repository | 功能名 + Repository | `LoginRepository.ets` |

### 变量命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 状态变量 | 语义清晰，布尔值用 is/has 前缀 | `isLoading`, `hasMore`, `articleList` |
| 私有变量 | private 修饰，无下划线 | `private httpClient` |
| 常量 | 全大写，下划线分隔 | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` |

---

## 二、路由配置速查

### 完整配置流程

```typescript
// 1. 创建页面（Profile.ets）
@Entry({ routeName: RouterName.Profile })
@Component
struct Profile {
  build() {
    NavDestination() {
      Column() {
        Text('个人中心')
      }
    }
  }
}

@Builder
export function ProfileBuilder() {
  Profile()
}

// 2. RouterName.ets
import ("entry/ets/pages/Profile")

export enum RouterName {
  Profile = "Profile"
}

// 3. routerMap.json
{
  "name": "Profile",
  "pageSourceFile": "src/main/ets/pages/Profile.ets",
  "buildFunction": "ProfileBuilder"
}

// 4. main_pages.json
{
  "src": [
    "pages/Profile"
  ]
}
```

### 路由跳转

```typescript
import { navPathStack } from '../router/navPathStack'
import { RouterName } from '../router/RouterName'

// 基本跳转
navPathStack.pushPath({ name: RouterName.Profile })

// 带参数跳转
navPathStack.pushPath({ 
  name: RouterName.WebBrowser,
  param: { url: 'https://example.com' }
})

// 返回
navPathStack.pop()

// 返回带参数
navPathStack.pop({ result: 'success' })
```

### 参数接收

```typescript
import { NavDestinationContext } from '@kit.ArkUI'

@Entry({ routeName: RouterName.WebBrowser })
@Component
struct WebBrowser {
  aboutToAppear(): void {
    const context = getContext(this) as NavDestinationContext
    const param = context.pathInfo.param as { url: string }
    console.log(param.url)
  }
}
```

---

## 三、网络请求速查

### 基本使用

```typescript
import { getHttpClient } from 'network'

// GET 请求
const response = await getHttpClient().get<Article[]>('/article/list/0/json')

// POST 请求
const response = await getHttpClient().post<LoginModel>('/user/login', {
  username: 'user',
  password: 'pass'
})
```

### Repository 模式

```typescript
// BaseRepository.ets
export abstract class BaseRepository {
  protected httpClient: HttpClient = getHttpClient()
  
  protected handleError(error: ApiError): void {
    LogUtil.error(`API Error: ${error.message}`)
  }
}

// LoginRepository.ets
export class LoginRepository extends BaseRepository {
  async login(username: string, password: string): Promise<LoginModel> {
    try {
      const response = await this.httpClient.post<LoginModel>(
        ApiConstants.userLogin(username, password)
      )
      
      if (response.errorCode !== 0) {
        throw new Error(response.errorMsg || '登录失败')
      }
      
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
```

### 错误处理

```typescript
import { ApiError, ApiErrorType } from 'network'

try {
  const data = await repository.getData()
} catch (error) {
  const apiError = error as ApiError
  
  switch (apiError.type) {
    case ApiErrorType.NETWORK:
      ToastUtil.showToast('网络连接失败')
      break
    case ApiErrorType.AUTH:
      navPathStack.pushPath({ name: RouterName.Login })
      break
  }
}
```

---

## 四、状态管理速查

### @State / @Local

```typescript
// @Component 中使用 @State
@Component
struct MyComponent {
  @State count: number = 0
}

// @ComponentV2 中使用 @Local
@ComponentV2
struct MyComponentV2 {
  @Local count: number = 0
}
```

### @Prop / @Link

```typescript
// @Prop：单向数据流
@Component
struct ChildComponent {
  @Prop title: string
}

// @Link：双向数据流
@Component
struct ChildComponent {
  @Link count: number
}

// 使用
ChildComponent({ count: $count })  // 使用 $ 语法
```

### @Provide / @Consume

```typescript
// 父组件提供
@Component
struct ParentComponent {
  @Provide userInfo: UserInfo = {}
}

// 子组件消费（任意层级）
@Component
struct ChildComponent {
  @Consume userInfo: UserInfo
}
```

---

## 五、生命周期速查

### 组件生命周期

```typescript
@Component
struct MyComponent {
  aboutToAppear(): void {
    console.log('组件即将出现')
  }
  
  aboutToDisappear(): void {
    console.log('组件即将消失')
  }
}
```

### 页面生命周期

```typescript
@Entry
struct MyPage {
  onPageShow(): void {
    console.log('页面即将显示')
  }
  
  onPageHide(): void {
    console.log('页面即将隐藏')
  }
  
  aboutToAppear(): void {
    console.log('组件即将出现')
  }
}
```

---

## 六、HSP 模块速查

### 创建 HSP 模块

```bash
# 1. 创建目录
mkdir -p network/src/main/ets

# 2. 创建配置文件
# - build-profile.json5
# - oh-package.json5
# - module.json5
# - Index.ets
```

### 配置文件模板

```json5
// build-profile.json5
{
  "apiType": 'stageMode',
  "buildOptionHar": {
    "enableBuildHar": true,
    "buildHarConfig": {
      "name": "network",
      "version": "1.0.0"
    }
  }
}

// oh-package.json5
{
  "name": "network",
  "version": "1.0.0",
  "main": "Index.ets",
  "dependencies": {
    "@ohos/axios": "2.2.14"
  }
}

// module.json5
{
  "module": {
    "name": "network",
    "type": "har",
    "deviceTypes": ["default", "tablet"]
  }
}
```

### 导出和使用

```typescript
// Index.ets
export * from './src/main/ets/Network'

// 使用
import { getHttpClient } from 'network'
const client = getHttpClient()
```

---

## 七、常用代码片段

### 页面模板

```typescript
import { RouterName } from '../router/RouterName'

@Entry({ routeName: RouterName.PageName })
@Component
struct PageName {
  @State isLoading: boolean = false
  
  aboutToAppear(): void {
    this.loadData()
  }
  
  async loadData(): Promise<void> {
    this.isLoading = true
    try {
      // 加载数据
    } catch (error) {
      // 处理错误
    } finally {
      this.isLoading = false
    }
  }
  
  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          LoadingIndicator()
        } else {
          // 内容
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('页面标题')
  }
}

@Builder
export function PageNameBuilder() {
  PageName()
}
```

### 列表模板

```typescript
@Component
struct ListPage {
  @State dataList: Article[] = []
  @State hasMore: boolean = true
  
  build() {
    List() {
      ForEach(this.dataList, (item: Article) => {
        ListItem() {
          ArticleCell({ article: item })
        }
      }, (item: Article) => item.id.toString())
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
  }
}
```

### 下拉刷新模板

```typescript
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'

@Component
struct RefreshPage {
  @State refreshing: boolean = false
  
  build() {
    PullToRefresh({
      pullToRefreshType: PullToRefreshType.LIST,
      refreshing: $refreshing,
      customList: () => {
        this.getListContent()
      },
      onRefresh: async () => {
        await this.refreshData()
        return '刷新成功'
      },
      onLoadMore: async () => {
        await this.loadMoreData()
        return '加载完成'
      }
    })
  }
  
  @Builder
  getListContent() {
    List() {
      // 列表内容
    }
  }
}
```

---

## 八、常见错误速查

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `Cannot use 'this' in standalone function` | 静态方法中使用 this | 使用全局函数或实例方法 |
| `Object literals cannot be used as type declarations` | 使用对象字面量作为类型 | 定义接口类型 |
| `Use of 'any' is not allowed` | 使用 any 类型 | 使用具体类型 |
| `buildFunction does not exist` | Builder 函数名不匹配 | 确保 Builder 函数名 = struct 名 + Builder |
| 路由无法跳转 | routerMap.json 缺失 | 添加路由配置 |

---

## 九、调试技巧速查

### 日志输出

```typescript
import { LogUtil } from '@pura/harmony-utils'

LogUtil.debug('调试信息')
LogUtil.info('一般信息')
LogUtil.warn('警告信息')
LogUtil.error('错误信息')
```

### 断点调试

1. 设置断点
2. 点击调试按钮
3. 查看变量和调用栈

### 网络调试

```typescript
// 开启日志拦截器
const loggingInterceptor = createLoggingInterceptor({
  enabled: true,
  logLevel: 'debug'
})
```

---

**快速参考完成！ 🎉**
