# HarmonyOS 路由迁移实战：从 router.push() 到 NavPathStack

> 咳咳，说到路由迁移这个话题，我想起当年在 iOS 开发的时候，从 UINavigationController 迁移到 URLRouter，那叫一个痛苦——所有 push 都要改成 pushURL，pop 要改成 popToRoot，参数传递方式也全变了。到了 HarmonyOS 这边，官方从 `router.push()` API 升级到 `NavPathStack`，虽然都是路由，但思维模式完全不一样。今天就和大家好好聊聊这个迁移过程。

## 1. 先说痛点

聊到 HarmonyOS 的路由，我们经常会遇到这么几个问题：

- **API 风格不统一**：`router.push()` 和 `router.pushNamedRoute()` 两套 API，用法还不一样
- **参数传递麻烦**：push 带参数用 `params`，back 带参数用 `url`，容易混淆
- **拦截器不好做**：想做登录拦截，得在每个跳转的地方判断，太繁琐
- **生命周期模糊**：页面返回时，生命周期回调的时机不清楚
- **无法获取栈信息**：想知道自己当前在哪个页面，不好意思，没有这个 API

但是！但是！用了 NavPathStack 之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         router.push() 旧方案                         │
│                                                                      │
│  ┌─────────────────────┐      ┌─────────────────────┐              │
│  │       Page A        │ ───→ │       Page B        │              │
│  │  Router.push()     │      │                     │              │
│  └─────────────────────┘      └─────────────────────┘              │
│                                                                      │
│  问题：生命周期分散、拦截器难做、无法获取栈状态                         │
└─────────────────────────────────────────────────────────────────────┘

                              ↓ 迁移后

┌─────────────────────────────────────────────────────────────────────┐
│                        NavPathStack 新方案                           │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    navPathStack (单例)                        │  │
│  │                                                              │  │
│  │   ┌───────┐   ┌───────┐   ┌───────┐   ┌───────┐            │  │
│  │   │ Index │ → │ Home  │ → │ Login │ → │ My    │            │  │
│  │   └───────┘   └───────┘   └───────┘   └───────┘            │  │
│  │                                                              │  │
│  │   pushPath()          pop()           getParamByName()       │  │
│  │   setInterception()   pop(result)     onPageShow()           │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  优势：栈结构清晰、生命周期明确、内置拦截器、参数传递统一               │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **NavPathStack 栈式管理 + 拦截器配置**。路由状态一目了然，拦截器集中管理。

## 3. 核心代码对比

### 3.1 旧方案：Router 工具类

**Talk is cheap, show me the code**

```typescript
// Router.ets（旧方案）
import { router } from '@kit.ArkUI'

export class Router {
  // 跳转
  static push<T = object>(url: string, params?: T): void {
    router.push({ url, params })
  }

  // 返回
  static back(): void {
    router.back()
  }

  // 获取参数
  static getParams<T = object>(): T | null {
    return router.getParams() as T
  }

  // 需要登录的跳转
  static pushWithLogin<T = object>(url: string, params?: T): void {
    if (AccountManager.shared().isLogin()) {
      Router.push(url, params)
    } else {
      // 手动判断并跳转登录页
      AppStorage.setOrCreate('afterLoginTarget', { url, params })
      Router.push('/pages/Login/Login')
    }
  }
}
```

### 3.2 新方案：NavPathStack 单例

```typescript
// navPathStack.ets（新方案）
import { promptAction } from '@kit.ArkUI'
import AccountManager from '../accountManager/AccountManager'

// 直接导出 HarmonyOS 内置的 NavPathStack 实例
export const navPathStack: NavPathStack = new NavPathStack()

// 需要登录的页面列表
const AuthNames: string[] = [
  'MyCollect',
  'MyCoin',
  'Setting',
  'WebExample',
  'WebComponent'
]

// 配置路由拦截器
navPathStack.setInterception({
  willShow(from, to) {
    const pageName = to.pathInfo?.name
    if (!pageName) return

    // 检查是否需要登录
    if (AuthNames.includes(pageName)) {
      const accountManager = AccountManager.shared()
      if (!accountManager.isLogin()) {
        promptAction.showToast({ message: '当前用户未登录，请先登录' })
        to.pathStack.pop()
        to.pathStack.pushPath({ name: 'Login' })
      }
    }
  }
})
```

### 3.3 页面使用对比

| 操作 | 旧方案 (router) | 新方案 (NavPathStack) |
|------|----------------|---------------------|
| 跳转 | `Router.push(url, params)` | `navPathStack.pushPath({ name, params })` |
| 返回 | `Router.back()` | `navPathStack.pop()` |
| 带值返回 | `Router.backWithParams(url, params)` | `navPathStack.pop(result)` |
| 获取参数 | `Router.getParams<T>()` | `navPathStack.getParamByName(name)` |
| 登录拦截 | 手动判断每个页面 | `setInterception` 统一配置 |

```typescript
// 旧方案跳转
Router.push('/pages/WebPage/WebPage', webLink)

// 新方案跳转
navPathStack.pushPath({ name: 'WebPage', params: webLink })
```

## 4. 顺传值与逆传值

### 4.1 顺传值（父 → 子）

```typescript
// 跳转时传递参数
navPathStack.pushPath({
  name: 'Detail',
  params: { id: 1, title: '商品详情' }
})

// 接收方 - 方式1: aboutToAppear 中获取
aboutToAppear(): void {
  let params = navPathStack.getParamByName('Detail') as any[]
  if (params && params.length > 0) {
    this.id = params[0].id
  }
}

// 接收方 - 方式2: onReady 回调中获取（推荐）
NavDestination() {
  // ...
}
.onReady((context: NavDestinationContext) => {
  let params = context.pathStack.getParamByName('Detail') as any[]
})
```

### 4.2 逆传值（子 → 父）

```typescript
// 发送方 (Detail页面) - 带值返回
navPathStack.pop({ result: 'success', data: { id: 1 } })

// 接收方 (Index页面) - 在 onPageShow 中获取
onPageShow(): void {
  let params = navPathStack.getParamByName('Index') as any[]
  if (params && params.length > 0) {
    this.result = params[0]
  }
}
```

> ⚠️ 注意：`pop()` 返回时不会触发 `aboutToAppear`，但会触发 `onPageShow`。

## 5. 跨 Tab 传值：emitter 事件总线

这是最容易踩坑的地方。

```
┌─────────────────────────────────────────────────────────┐
│                     Index (Tab容器)                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │  TabContent: Home | Project | Tree | My          │   │
│  │                                          ↑        │   │
│  │                                          │        │   │
│  │  @Provide loginSuccessUserInfo ──────────┘        │   │
│  └─────────────────────────────────────────────────┘   │
│                           ↑                             │
│                           │ pop()                       │
│  ┌────────────────────────┼────────────────────────┐  │
│  │        Login页面        │                        │  │
│  │    (另一个NavDestination栈)                       │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘

问题：Login pop() 返回 Index 时，不会触发 Index 的生命周期回调
```

### 解决方案：emitter 事件总线

```typescript
// Login.ets - 定义事件常量
import { emitter } from '@kit.BasicServicesKit';

export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"

// Login.ets - 登录成功时发送事件
if (result && result.success && result.userInfo) {
  ToastUtil.showToast($r('app.string.login_success'))

  // 发送登录成功事件
  emitter.emit(LOGIN_SUCCESS_EVENT, {
    data: { userInfo: result.userInfo }
  })

  navPathStack.pop()
}

// My.ets - 订阅事件
import { LOGIN_SUCCESS_EVENT } from './Login'

@Entry({routeName: 'My'})
@Component
struct My {
  @Consume loginSuccessUserInfo: UserInfoModel = {}

  aboutToAppear(): void {
    emitter.on(LOGIN_SUCCESS_EVENT, (data: emitter.EventData) => {
      if (data?.data?.["userInfo"]) {
        this.loginSuccessUserInfo = data.data["userInfo"] as UserInfoModel
      }
    })
  }

  aboutToDisappear(): void {
    emitter.off(LOGIN_SUCCESS_EVENT)  // 取消订阅，避免内存泄漏
  }
}
```

## 6. 页面改造实战

### 6.1 改造前（使用 Router）

```typescript
// My.ets
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'

@Entry({routeName: RouterName.My})
@Component
struct My {
  build() {
    Column() {
      // 跳转到收藏页
      Button('跳转收藏').onClick(() => {
        Router.pushWithLogin(RouterName.MyCollect)
      })
    }
  }
}
```

### 6.2 改造后（使用 NavPathStack）

```typescript
// My.ets
import { navPathStack } from '../router/navPathStack'

@Entry({routeName: 'My'})
@Component
struct My {
  build() {
    Column() {
      Button('跳转收藏').onClick(() => {
        navPathStack.pushPath({ name: 'MyCollect' })
      })
    }
  }
}

// 导出 Builder 函数
@Builder
export function MyBuilder() {
  My()
}
```

### 6.3 routerMap.json 配置

```json
{
  "routerMap": [
    {
      "name": "My",
      "pageSourceFile": "src/main/ets/pages/My.ets",
      "buildFunction": "MyBuilder"
    },
    {
      "name": "MyCollect",
      "pageSourceFile": "src/main/ets/pages/MyCollect.ets",
      "buildFunction": "MyCollectBuilder"
    }
  ]
}
```

## 7. 对比 iOS 的 UINavigationController

说实话，相比 iOS 的 UINavigationController，NavPathStack 也是毫不逊色的：

| 特性 | iOS UINavigationController | HarmonyOS NavPathStack |
|------|---------------------------|------------------------|
| 栈管理 | pushViewController/popViewController | pushPath/pop |
| 拦截器 | delegate 的 shouldShow | setInterception |
| 参数传递 | prepareForSegue / performSegue | params 对象 |
| 生命周期 | viewWillAppear / viewDidAppear | aboutToAppear / onReady / onPageShow |
| Tab 嵌套 | child navigationController | NavDestination 嵌套 |

iOS 方案胜在**生态成熟**，NavPathStack 胜在**声明式配置 + 内置拦截器**。

## 8. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **params vs param** | NavPathStack 用 `params`，不是 `param` |
| **生命周期** | `pop()` 返回时触发 `onPageShow`，不触发 `aboutToAppear` |
| **跨 Tab 传值** | ❌ 不要用 AppStorage + @StorageLink<br>✅ 使用 emitter.emit / emitter.on |
| **emitter.emit** | 参数2必须是 `{ data: {...} }` 格式 |
| **取消订阅** | 在 `aboutToDisappear` 中调用 `emitter.off()` |
| **Builder 导出** | 页面必须导出 Builder 函数供 routerMap 使用 |
| **NavDestination** | 页面内容必须包裹在 `NavDestination()` 中 |

## 9. 总结

HarmonyOS 的 NavPathStack，我这段时间用下来是真的香：

1. **栈式管理**：路由状态一目了然，push/pop 语义清晰
2. **内置拦截器**：通过 `setInterception` 统一配置登录拦截
3. **参数传递统一**：顺传用 `params`，逆传用 `pop(result)`
4. **生命周期清晰**：aboutToAppear、onReady、onPageShow 各司其职
5. **跨 Tab 传值**：配合 emitter 事件总线，解决登录回调难题

推荐在需要**声明式路由**、**统一拦截器**、**清晰生命周期**的场景下使用 NavPathStack。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)