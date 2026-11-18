# HarmonyOS NavPathStack 路由架构：我趟过的那些坑

咳咳，说到路由这个话题，真的是一把辛酸泪。之前做iOS开发的时候，路由可以说是我最不愿意碰的模块之一——逻辑散落在各个地方，页面跳转耦合得一塌糊涂，一个不小心就陷入了callback地狱。

直到后来我开始接触HarmonyOS，发现官方竟然直接给我们提供了一个现成的路由栈方案——NavPathStack。这不，今天就和大家好好聊聊这个话题。

## 1. 先说痛点

聊到页面跳转，我们经常会遇到这么几个问题：

- 页面之间传参太麻烦，字符串硬编码满天飞
- 登录状态校验散落在各个页面，漏了哪个就完蛋
- 跨Tab页面传值更是一言难尽，AppStorage用着用着就乱了
- 逆传值（子页面返回数据给父页面）生命周期错乱，不知道该在哪获取

但是！但是！在HarmonyOS里面，这些问题NavPathStack给我们封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        EntryAbility                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  routerMap (routerMap.json)            │  │
│  │   "Login"    → LoginBuilder()                         │  │
│  │   "Index"    → IndexBuilder()                          │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              navPathStack (单例)                         │  │
│  │   ┌─────────┐  ┌─────────┐                             │  │
│  │   │  Index  │→│  Login  │                             │  │
│  │   └────┬────┘  └────┬────┘                             │  │
│  │        │           │ pop() → 逆传值                    │  │
│  │        ↓           ↓                                   │  │
│  │   getParamByName() 获取参数                             │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个`navPathStack`单例。我们直接使用HarmonyOS内置的`NavPathStack`，不自己封装，这波啊，这波是站在巨人的肩膀上。

## 3. 核心代码展示

### 3.1 路由栈单例

```typescript
// navPathStack.ets
import { promptAction } from '@kit.ArkUI'
import AccountManager from '../accountManager/AccountManager'

/**
 * NavPathStack 单例
 * 在模块加载时创建并配置拦截器
 */
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
    if (typeof to === 'string') {
      return
    }
    const pageName = to.pathInfo?.name
    if (!pageName) {
      return
    }

    // 检查是否需要登录
    if (AuthNames.includes(pageName)) {
      const accountManager = AccountManager.shared()
      if (!accountManager.isLogin()) {
        promptAction.showToast({
          message: '当前用户未登录，请先登录'
        })
        to.pathStack.pop()
        to.pathStack.pushPath({
          name: 'Login'
        })
      }
    }
  }
})
```

这个代码里面，我特别喜欢这个`setInterception`——登录拦截一次性搞定，不用在每个页面单独判断，舒服。

### 3.2 顺传值（父→子）

```typescript
// 跳转并传递参数
navPathStack.pushPath({ name: 'Detail', params: { id: 1, title: '商品' } })

// 注意：参数用 params，不是 param
```

```typescript
// 接收方 - 方式1: aboutToAppear 中获取
aboutToAppear(): void {
  let params = navPathStack.getParamByName('Detail') as any[]
  if (params && params.length > 0) {
    this.id = params[0].id
  }
}

// 接收方 - 方式2: onReady 回调中获取
NavDestination() {
  ...
}
.onReady((context: NavDestinationContext) => {
  let params = context.pathStack.getParamByName('Detail') as any[]
})
```

这里有个小坑要提醒大家：**参数用 `params`，不是 `param`**！这个我一开始写的时候愣是搞错了，调了半天都不知道为啥参数传不过去。

### 3.3 逆传值（子→父）

```typescript
// Detail页面 - 带值返回
navPathStack.pop({ result: 'success', data: { id: 1 } })

// Detail页面 - 不带值返回
navPathStack.pop()
```

```typescript
// Index页面 - onPageShow 中获取（推荐）
onPageShow(): void {
  let params = navPathStack.getParamByName('Index') as any[]
  if (params && params.length > 0) {
    this.result = params[0]
  }
}

// aboutToAppear 中获取（pop返回时不会触发）
aboutToAppear(): void {
  let params = navPathStack.getParamByName('Index') as any[]
}
```

这个思路之所以...根本原因在于：`pop`返回时不会触发`aboutToAppear`，但会触发`onPageShow`！所以获取逆传值要在`onPageShow`里面搞。

## 4. 跨Tab页面传值——重头戏来了

这个问题是真的让我头疼了好久。

### 4.1 问题分析

```
┌─────────────────────────────────────────────────────────┐
│                     Index (Tab容器)                     │
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

你说烦不烦，Login页面和My页面压根不在同一个栈里面，Login pop回去根本不会触发Index的生命周期，所以@Provide/@Consume这套机制直接歇菜。

### 4.2 解决方案：emitter事件总线

**Talk is cheap, show me the code**

#### 第一步：定义事件常量（Login.ets）

```typescript
import { emitter } from '@kit.BasicServicesKit';

// 导出事件常量，供其他页面引用
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"
```

#### 第二步：登录成功时发送事件（Login.ets）

```typescript
if (result && result.success && result.userInfo) {
  ToastUtil.showToast($r('app.string.login_success'))

  // 发送登录成功事件，携带用户信息
  emitter.emit(LOGIN_SUCCESS_EVENT, { data: { userInfo: result.userInfo } })

  // 返回上一页
  navPathStack.pop()
}
```

#### 第三步：订阅事件（My.ets）

```typescript
import { emitter } from '@kit.BasicServicesKit';
import { LOGIN_SUCCESS_EVENT } from './Login'

@Entry({routeName: 'My'})
@Component
struct My {
  // 使用 @Consume 从 Index 的 @Provide 获取数据
  @Consume loginSuccessUserInfo: UserInfoModel = {}

  aboutToAppear(): void {
    // 订阅登录成功事件
    emitter.on(LOGIN_SUCCESS_EVENT, (data: emitter.EventData) => {
      if (data?.data?.["userInfo"]) {
        this.loginSuccessUserInfo = data.data["userInfo"] as UserInfoModel
      }
    })
  }

  aboutToDisappear(): void {
    // 取消订阅，避免内存泄漏
    emitter.off(LOGIN_SUCCESS_EVENT)
  }
}
```

你说妙不妙？emitter事件总线一出，跨Tab传值问题迎刃而解。这个思路之所以有效，根本原因在于emitter是全局的事件总线，不依赖组件树的生命周期。

## 5. emitter正确用法总结

| 操作 | 代码 |
|------|------|
| 发送事件 | `emitter.emit(eventName, { data: {...} })` |
| 订阅事件 | `emitter.on(eventName, (data) => { ... })` |
| 取消订阅 | `emitter.off(eventName)` |

```typescript
// 发送事件
emitter.emit("MY_EVENT", {
  data: {
    key1: value1,
    key2: value2
  }
})

// 订阅事件
emitter.on("MY_EVENT", (data) => {
  if (data?.data?.["key1"]) {
    // 处理数据
  }
})

// 取消订阅（通常在aboutToDisappear中调用）
aboutToDisappear(): void {
  emitter.off(LOGIN_SUCCESS_EVENT)
}
```

## 6. 避坑指南

| 场景 | 注意事项 |
|------|----------|
| **顺传值** | `params` vs `param`，NavPathStack用`params` |
| **逆传值** | `pop(result)`时在`onPageShow`中获取，不会在`aboutToAppear`触发 |
| **跨Tab传值** | ❌ 不要用AppStorage + @StorageLink<br>✅ 使用emitter.emit / emitter.on |
| **emitter.emit** | 参数1：事件名字符串，参数2：EventData对象`{ data: {...} }` |
| **emitter.on** | 在aboutToAppear中订阅，在aboutToDisappear中取消订阅 |
| **NavDestination** | 页面必须包裹在`NavDestination()`中，不能用`Navigation()` |
| **@Provide/@Consume** | 父子组件数据共享，跨Tab需要配合emitter事件 |
| **事件常量** | 在发送方页面定义并导出，接收方导入使用 |

## 7. 对比iOS的路由设计

说实话，相比iOS的路由方案，HarmonyOS这个NavPathStack真的是省心太多了：

| 特性 | iOS传统方案 | HarmonyOS NavPathStack |
|------|------------|------------------------|
| 路由栈管理 | 第三方库或自封装 | 系统内置，开箱即用 |
| 登录拦截 | 各页面分散判断 | 统一拦截器，配置化 |
| 页面传值 | delegate/callback/Notification | pushPath/pop带参 |
| 跨Tab传值 | NotificationCenter/广播 | emitter事件总线 |

iOS开发那会儿，我光一个路由封装就折腾了好几周，现在看看HarmonyOS这套方案，成熟度相当可以。

## 8. 完整数据流图

```
┌─────────────────────────────────────────────────────────────────────┐
│                            Login.ets                                 │
│                                                                      │
│  emitter.emit(LOGIN_SUCCESS_EVENT, {                                │
│    data: { userInfo: result.userInfo }                              │
│  })                                                                  │
│         │                                                            │
│         └──────────────────┐                                         │
│                            ↓                                         │
│                     ┌──────────────┐                                  │
│                     │   emitter    │                                  │
│                     │   事件总线    │                                  │
│                     └───────┬──────┘                                  │
│                             │                                        │
│              emitter.on ←────┘                                       │
│                   │                                                  │
│                   ↓                                                  │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                          My.ets                              │    │
│  │                                                              │    │
│  │  aboutToAppear(): void {                                    │    │
│  │    emitter.on(LOGIN_SUCCESS_EVENT, (data) => {             │    │
│  │      this.loginSuccessUserInfo = data.data.userInfo         │    │
│  │    })                                                       │    │
│  │  }                                                          │    │
│  │                             ↓                               │    │
│  │  @Consume loginSuccessUserInfo ←──── @Provide (Index)      │    │
│  │                             ↓                               │    │
│  │  MyHeader({ userInfo: this.loginSuccessUserInfo })         │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  navPathStack.pop()  → 返回 Index                                   │
└─────────────────────────────────────────────────────────────────────┘
```

## 总结

HarmonyOS的NavPathStack路由方案，我这段时间用下来是真的香：

1. **单例模式**直接导出，不用自己封装路由管理类
2. **setInterception**登录拦截统一处理，配置化贼方便
3. **pushPath/pop**参数传递简洁直观
4. **emitter事件总线**解决跨Tab传值难题
5. **生命周期清晰**，onPageShow vs aboutToAppear各司其职

推荐在需要登录校验、跨页面/跨Tab传值的场景下使用这套方案。

大家有什么好的思路与想法欢迎分享，我们下期见！
