# HarmonyOS emitter 事件总线：跨组件通信 so easy

> 咳咳，说到跨组件通信这个话题，我想起当年在 iOS 开发的时候，用 NotificationCenter 发通知，那叫一个方便——postName:object:，一行代码搞定。但问题来了，NotificationCenter 是同步的，发完通知所有监听者都执行完了才返回，有时候会导致奇怪的 bug。到了 HarmonyOS 这边，官方给了我们 emitter 这个事件总线，也是挺好用的。今天就和大家好好聊聊 emitter 事件总线这个话题。

## 1. 先说痛点

聊到跨组件通信，我们经常会遇到这么几个问题：

- **跨 Tab 传值**：Login 页面登录成功后，My 页面要刷新用户信息，但它们不在同一个栈里
- **兄弟组件通信**：两个平级的组件，一个变了，另一个要跟着变
- **多层嵌套传值**：组件层级太深，props 一层层传递，代码耦合严重
- **AppStorage 乱用**：@StorageLink 用着用着就乱了，不知道谁改了哪个值

但是！但是！用了 emitter 事件总线之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         emitter 事件总线                              │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐  │
│   │  事件池 (EventPool)                                          │  │
│   │                                                             │  │
│   │  "LOGIN_SUCCESS_EVENT"  →  [callback1, callback2, ...]     │  │
│   │  "LOGOUT_EVENT"         →  [callback3, ...]               │  │
│   │  "REFRESH_DATA_EVENT"   →  [callback4, ...]               │  │
│   └─────────────────────────────────────────────────────────────┘  │
│                              │                                      │
│          ┌───────────────────┼───────────────────┐                 │
│          ▼                   ▼                   ▼                 │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐        │
│   │  Login.ets  │     │   My.ets    │     │  Home.ets   │        │
│   │             │     │             │     │             │        │
│   │ emitter.emit│     │ emitter.on  │     │ emitter.on  │        │
│   └─────────────┘     └─────────────┘     └─────────────┘        │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **emitter 事件总线**。发送者只管发，接收者只管收，两边互不依赖，完美解耦。

## 3. 核心代码展示

### 3.1 定义事件常量

**Talk is cheap, show me the code**

```typescript
// Login.ets
import { emitter } from '@kit.BasicServicesKit';

// 导出事件常量，供其他页面引用
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"
export const LOGOUT_EVENT = "LOGOUT_EVENT"
```

> 这里有个小技巧：**事件常量定义在发送方页面**，接收方导入使用。这样做的好处是类型安全，一眼就能看出这个事件是谁发的。

### 3.2 发送事件

```typescript
// Login.ets - 登录成功时发送事件
if (result && result.success && result.userInfo) {
  ToastUtil.showToast($r('app.string.login_success'))

  // 发送登录成功事件，携带用户信息
  emitter.emit(LOGIN_SUCCESS_EVENT, {
    data: {
      userInfo: result.userInfo,
      loginTime: Date.now()
    }
  })

  // 返回上一页
  navPathStack.pop()
}
```

### 3.3 订阅事件

```typescript
// My.ets - 订阅登录成功事件
import { emitter } from '@kit.BasicServicesKit';
import { LOGIN_SUCCESS_EVENT } from './Login'

@Entry({routeName: 'My'})
@Component
struct My {

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

  build() {
    NavDestination() {
      // 页面内容...
    }
  }
}
```

### 3.4 项目中的完整示例

```typescript
// Login.ets
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"

@Entry({routeName: RouterName.Login})
@ComponentV2
struct Login {

  @Local username: string = ""
  @Local password: string = ""

  build() {
    NavDestination() {
      Column() {
        // 登录表单...
      }
    }
    .title($r('app.string.login'))
    .onReady((context: NavDestinationContext) => {
      // 页面准备好后处理参数...
    })
  }

  async login() {
    const result = await this.viewModel.loginWithUserInfo({
      username: this.username,
      password: this.password
    })

    if (result.success && result.userInfo) {
      ToastUtil.showToast($r('app.string.login_success'))

      // 发送登录成功事件
      emitter.emit(LOGIN_SUCCESS_EVENT, {
        data: { userInfo: result.userInfo }
      })

      navPathStack.pop()
    }
  }
}

@Builder
export function LoginBuilder() {
  Login()
}
```

```typescript
// My.ets
import { LOGIN_SUCCESS_EVENT } from './Login'

@Entry({routeName: 'My'})
@Component
struct My {

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
    // 取消订阅
    emitter.off(LOGIN_SUCCESS_EVENT)
  }

  build() {
    NavDestination() {
      Column() {
        // 用户信息头部
        MyHeader({ userInfo: this.loginSuccessUserInfo })

        // 列表内容...
      }
    }
    .title($r('app.string.my'))
  }
}
```

## 4. emitter 正确用法总结

| 操作 | 代码 | 说明 |
|------|------|------|
| 定义事件 | `export const XXX_EVENT = "xxx_event"` | 定义在发送方页面 |
| 发送事件 | `emitter.emit(eventName, { data: {...} })` | 参数2必须是EventData对象 |
| 订阅事件 | `emitter.on(eventName, callback)` | 在aboutToAppear中调用 |
| 取消订阅 | `emitter.off(eventName)` | 在aboutToDisappear中调用 |

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
    const value = data.data["key1"]
  }
})

// 取消订阅（通常在aboutToDisappear中调用）
aboutToDisappear(): void {
  emitter.off(LOGIN_SUCCESS_EVENT)
}
```

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **事件常量定义位置** | 定义在**发送方页面**，接收方导入使用 |
| **订阅时机** | 在 `aboutToAppear` 中订阅，不要在 `build` 中订阅 |
| **取消订阅** | 在 `aboutToDisappear` 中取消订阅，避免内存泄漏 |
| **emitter.emit** | 参数1：事件名字符串，参数2：`{ data: {...} }` |
| **emitter.on** | 回调函数接收 `emitter.EventData` 类型参数 |
| **跨 Tab 传值** | ✅ 用 emitter，不要用 AppStorage + @StorageLink |
| **同步 vs 异步** | emitter 是**异步**的，不会阻塞当前代码执行 |

## 6. 对比 iOS 的 NotificationCenter

说实话，相比 iOS 的 NotificationCenter，HarmonyOS 的 emitter 也是毫不逊色的：

| 特性 | iOS NotificationCenter | HarmonyOS emitter |
|------|------------------------|-------------------|
| 同步/异步 | 同步 | 异步 |
| 类型安全 | 弱 | 弱（但可通过常量约定） |
| 内存管理 | 需手动 removeObserver | 需手动 off |
| 跨线程 | 需切换到主线程 | 自动在当前线程 |
| API 设计 | postName:object:userInfo: | emit/on/off |

iOS 方案胜在**生态成熟**，emitter 胜在**异步不阻塞**。

## 7. 进阶用法

### 7.1 带多个参数的事件

```typescript
// 发送
emitter.emit("USER_ACTION", {
  data: {
    action: "login",
    userId: 123,
    timestamp: Date.now()
  }
})

// 接收
emitter.on("USER_ACTION", (data) => {
  const action = data.data?.["action"]
  const userId = data.data?.["userId"]
  const timestamp = data.data?.["timestamp"]
})
```

### 7.2 一次性事件订阅

```typescript
// 只监听一次，收到后自动取消订阅
emitter.once(LOGIN_SUCCESS_EVENT, (data) => {
  // 处理一次性事件...
})
```

### 7.3 全局事件 vs 局部事件

```typescript
// 全局事件（任何页面都可以订阅）
export const GLOBAL_EVENT = "global_event"

// 局部事件（只在特定场景使用）
const LOCAL_EVENT = "local_event"  // 不 export
```

## 总结

HarmonyOS 的 emitter 事件总线，我这段时间用下来是真的香：

1. **解耦设计**：发送者和接收者互不依赖
2. **跨组件通信**：跨 Tab、跨页面、跨组件都能用
3. **异步执行**：不会阻塞当前代码执行
4. **类型约定**：通过事件常量约定，保证类型安全
5. **生命周期管理**：订阅在 aboutToAppear，取消在 aboutToDisappear

推荐在需要**跨组件通信**、**跨 Tab 传值**、**事件通知**的场景下使用 emitter 事件总线。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
