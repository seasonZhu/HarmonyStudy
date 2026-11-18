# HarmonyOS NavPathStack 路由架构设计

## 一、整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        EntryAbility                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  routerMap (routerMap.json)            │  │
│  │   "Login"    → LoginBuilder()                         │  │
│  │   "Index"    → IndexBuilder()                          │  │
│  │   "My"       → MyBuilder()                            │  │
│  │   "Register" → RegisterBuilder()                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              navPathStack (单例)                         │  │
│  │   直接导出 HarmonyOS 内置的 NavPathStack 实例            │  │
│  │   ┌─────────┐  ┌─────────┐                             │  │
│  │   │  Index  │→│  Login  │                             │  │
│  │   └────┬────┘  └────┬────┘                             │  │
│  │        │           │ pop() → 逆传值                    │  │
│  │        ↓           ↓                                   │  │
│  │   getParamByName() 获取参数                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    Index (主容器)                       │  │
│  │   @Provide loginSuccessUserInfo                        │  │
│  │                                                          │  │
│  │   Navigation(navPathStack) {                            │  │
│  │     Tabs {                                              │  │
│  │       TabContent: Home │ Project │ Tree │ My            │  │
│  │     }                                                  │  │
│  │   }                                                    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 二、核心文件

### 1. navPathStack.ets (路由栈单例)

项目直接使用 HarmonyOS 内置的 `NavPathStack`，不封装。

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

### 2. 路由拦截说明

通过 `setInterception` 配置登录拦截：
- 访问 `AuthNames` 列表中的页面时，若未登录则跳转到登录页
- 使用 `promptAction.showToast` 提示用户

## 三、顺传值 (父→子)

### 调用方
```typescript
// 跳转并传递参数
navPathStack.pushPath({ name: 'Detail', params: { id: 1, title: '商品' } })

// 注意：参数用 params，不是 param
```

### 接收方
```typescript
// 方式1: aboutToAppear 中获取
aboutToAppear(): void {
  let params = navPathStack.getParamByName('Detail') as any[]
  if (params && params.length > 0) {
    this.id = params[0].id
  }
}

// 方式2: onReady 回调中获取
NavDestination() {
  ...
}
.onReady((context: NavDestinationContext) => {
  let params = context.pathStack.getParamByName('Detail') as any[]
})
```

## 四、逆传值 (子→父)

### 发送方 (Detail页面)
```typescript
// 带值返回
navPathStack.pop({ result: 'success', data: { id: 1 } })

// 不带值返回
navPathStack.pop()
```

### 接收方 (Index页面)
```typescript
// onPageShow 中获取（推荐，因为pop返回时会触发onPageShow）
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

## 五、跨Tab页面传值 (Login → My)

### 问题分析
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

### 解决方案：emitter 事件总线

#### 1. 定义事件常量 (Login.ets)
```typescript
import { emitter } from '@kit.BasicServicesKit';

// 导出事件常量，供其他页面引用
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"
```

#### 2. 登录成功时发送事件 (Login.ets)
```typescript
if (result && result.success && result.userInfo) {
  ToastUtil.showToast($r('app.string.login_success'))

  // 发送登录成功事件，携带用户信息
  emitter.emit(LOGIN_SUCCESS_EVENT, { data: { userInfo: result.userInfo } })

  // 返回上一页
  navPathStack.pop()
}
```

#### 3. 订阅事件 (My.ets)
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
}
```

#### 4. 提供数据 (Index.ets)
```typescript
@Entry({routeName: RouterName.Index})
@Component
struct Index {
  // 向子组件提供登录用户信息
  @Provide loginSuccessUserInfo: UserInfoModel = {}

  aboutToAppear(): void {
    // 自动登录逻辑
    let username = await PreferencesUtil.get("username", "") as string
    let password = await PreferencesUtil.get("password", "") as string

    if (username.length != 0 && password.length != 0) {
      let result = await this.viewModel.login({username, password})
      if (result) {
        let response = await this.viewModel.getUserInfo()
        this.loginSuccessUserInfo = response.data.data
      }
    }
  }
}
```

## 六、emitter 正确用法

### API 概览
```typescript
// 发送事件
emitter.emit(eventName: string, data: EventData)

// 订阅事件
emitter.on(eventName: string, callback: (data: EventData) => void)

// 取消订阅（通常在aboutToDisappear中调用）
emitter.off(eventName: string)
```

### 发送事件
```typescript
emitter.emit("MY_EVENT", {
  data: {
    key1: value1,
    key2: value2
  }
})
```

### 订阅事件
```typescript
emitter.on("MY_EVENT", (data) => {
  if (data?.data?.["key1"]) {
    // 处理数据
  }
})
```

### 取消订阅
```typescript
aboutToDisappear(): void {
  emitter.off(LOGIN_SUCCESS_EVENT)
}
```

### 事件常量定义位置
- 事件常量定义在**发送方页面**，供接收方导入使用
- 如 `LOGIN_SUCCESS_EVENT` 定义在 `Login.ets`，`My.ets` 导入使用

## 七、注意事项

| 场景 | 注意事项 |
|------|----------|
| **顺传值** | `params` vs `param`，NavPathStack 用 `params` |
| **逆传值** | `pop(result)` 时在 `onPageShow` 中获取，不会在 `aboutToAppear` 触发 |
| **跨Tab传值** | ❌ 不要用 AppStorage + @StorageLink<br>✅ 使用 emitter.emit / emitter.on |
| **emitter.emit** | 参数1：事件名字符串，参数2：EventData对象 `{ data: {...} }` |
| **emitter.on** | 在 aboutToAppear 中订阅，在 aboutToDisappear 中取消订阅 |
| **NavDestination** | 页面必须包裹在 `NavDestination()` 中，不能用 `Navigation()` |
| **@Provide/@Consume** | 父子组件数据共享，跨Tab需要配合 emitter 事件 |
| **事件常量** | 在发送方页面定义并导出，接收方导入使用 |

## 八、完整数据流图

### Login → My 数据流
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

## 九、代码示例

### 路由跳转型代码模式
```typescript
// 跳转
navPathStack.pushPath({ name: 'PageName', params: data })

// 返回
navPathStack.pop()

// 返回带值
navPathStack.pop(resultData)

// 获取参数
let params = navPathStack.getParamByName('PageName')
```

### 页面模板
```typescript
// 页面.ets
import { navPathStack } from '../router/navPathStack'

@Entry({routeName: 'PageName'})
@Component
struct PageName {
  @State data: DataType = {}

  aboutToAppear(): void {
    let params = navPathStack.getParamByName('PageName') as DataType[]
    if (params && params.length > 0) {
      this.data = params[0]
    }
  }

  build() {
    NavDestination() {
      // 页面内容
    }
    .title('页面标题')
  }
}

@Builder
export function PageNameBuilder() {
  PageName()
}
```