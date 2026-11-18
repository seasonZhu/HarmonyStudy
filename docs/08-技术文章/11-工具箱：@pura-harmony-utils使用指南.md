# HarmonyOS 工具箱：@pura/harmony-utils 使用指南

> 咳咳，说到工具类这个话题，我想起当年在 iOS 开发的时候，自己封装了一堆静态工具方法——ToastUtil、LogUtil、PreferencesUtil，每个都写了好几遍。后来到了 Android/HarmonyOS 开发，发现官方的工具类 API 真的是...一言难尽。直到我发现了 @pura/harmony-utils 这个库，简直是救了我老命了。今天就和大家好好聊聊这个工具箱。

## 1. 先说痛点

聊到工具类封装，我们经常会遇到这么几个问题：

- **Toast 写法繁琐**：每次都要 new 一个 ToastBuilder，设置各种参数，代码一大堆
- **日志打印麻烦**：console.log 只能在真机调试看，发布后就没了
- **Preferences 存储麻烦**：getPreferences、put、flush，一大堆样板代码
- **重复封装**：每个项目都要自己封装一套工具类，费时费力

但是！但是！用了 @pura/harmony-utils 之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    @pura/harmony-utils                                │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                      工具大类                                 │  │
│  │                                                             │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌─────────┐ │  │
│  │  │ LogUtil   │  │ToastUtil  │  │Preferences│  │FileUtil │ │  │
│  │  │ 日志工具   │  │ 吐司工具  │  │ 存储工具   │  │文件工具 │ │  │
│  │  └───────────┘  └───────────┘  └───────────┘  └─────────┘ │  │
│  │                                                             │  │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────┐              │  │
│  │  │  Prompt   │  │  Action   │  │   JSON    │              │  │
│  │  │ 提示工具  │  │ 行为工具   │  │  JSON工具  │              │  │
│  │  └───────────┘  └───────────┘  └───────────┘              │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

这个工具箱提供了 **LogUtil**、**ToastUtil**、**PreferencesUtil** 等常用工具，开箱即用，省时省力。

## 3. 核心 API 展示

### 3.1 LogUtil 日志工具

**Talk is cheap, show me the code**

```typescript
import { LogUtil } from '@pura/harmony-utils';

// 基础日志
LogUtil.debug('这是一条调试日志')
LogUtil.info('这是一条信息日志')
LogUtil.warn('这是一条警告日志')
LogUtil.error('这是一条错误日志')

// 带参数的日志
LogUtil.debug('用户信息:', JSON.stringify(userInfo))
LogUtil.info('请求结果: ', response.data)

// 带标签的日志
LogUtil.debug('Network', '网络请求开始')
LogUtil.error('Network', '网络请求失败: ', error.message)
```

| 方法 | 用途 | 说明 |
|------|------|------|
| debug() | 调试日志 | 开发环境可见 |
| info() | 信息日志 | 记录重要信息 |
| warn() | 警告日志 | 警告信息 |
| error() | 错误日志 | 错误信息 |

> LogUtil 的好处是：**只在 DEBUG 模式下输出**，发布后自动不打印，避免日志泄露。

### 3.2 ToastUtil 吐司工具

```typescript
import { ToastUtil } from '@pura/harmony-utils';

// 基础用法
ToastUtil.showToast('操作成功')
ToastUtil.showToast('操作失败')

// 带时长的 Toast
ToastUtil.showToast('这是一条长提示', 3000)  // 3秒

// 项目中封装的 ToastUtil（项目中自己又封装了一层）
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'

// 成功提示
ToastUtil.success('操作成功')

// 错误提示
ToastUtil.error('操作失败')

// 信息提示
ToastUtil.info('这是一条信息')

// 警告提示
ToastUtil.warning('这是一条警告')

// 自定义提示
ToastUtil.show({ message: '自定义消息', duration: 3000 })
```

### 3.3 PreferencesUtil 存储工具

```typescript
import { PreferencesUtil } from '@pura/harmony-utils';

// 存储数据
await PreferencesUtil.put('username', 'zhangsan')
await PreferencesUtil.put('password', '123456')
await PreferencesUtil.put('isLogin', true)
await PreferencesUtil.put('userInfo', JSON.stringify(userInfo))

// 读取数据
const username = await PreferencesUtil.get('username', '') as string
const password = await PreferencesUtil.get('password', '') as string
const isLogin = await PreferencesUtil.get('isLogin', false) as boolean

// 删除数据
await PreferencesUtil.delete('password')

// 清空所有数据
await PreferencesUtil.clear()
```

| 方法 | 用途 |
|------|------|
| put() | 存储数据 |
| get() | 读取数据 |
| delete() | 删除指定数据 |
| clear() | 清空所有数据 |

### 3.4 FileUtil 文件工具

```typescript
import { FileUtil } from '@pura/harmony-utils';

// 打开文件
const file = FileUtil.openSync(filePath)

// 写入文件
FileUtil.writeSync(file.fd, content)

// 关闭文件
FileUtil.closeSync(file.fd)
```

## 4. 项目中的实际使用

### 4.1 自动登录逻辑

```typescript
// Index.ets
import { PreferencesUtil, ToastUtil } from '@pura/harmony-utils'

async aboutToAppear(): Promise<void> {
  let username = await PreferencesUtil.get("username", "") as string
  let password = await PreferencesUtil.get("password", "") as string

  if (username.length != 0 && password.length != 0) {
    ToastUtil.showToast($r('app.string.auto_login'))
    let result = await this.viewModel.login({username, password})
    if (result) {
      let response = await this.viewModel.getUserInfo()
      this.userInfo = response.data.data
    }
  }
}
```

### 4.2 日志打印

```typescript
// Provider.ets
import { LogUtil } from '@pura/harmony-utils';

static async initEnvironment(): Promise<void> {
  try {
    Provider.currentEnv = await environmentManager.getCurrentEnvironment()
    Provider.currentConfig = EnvConfig.getConfig(Provider.currentEnv)
    LogUtil.info('Provider: 当前环境已初始化为 ' + Provider.currentEnv)
    LogUtil.info('Provider: BaseURL = ' + Provider.currentConfig.baseUrl)
  } catch (error) {
    LogUtil.error('Provider: 初始化环境失败，使用默认环境')
  }
}
```

### 4.3 用户信息存储

```typescript
// LoginViewModel.ets
async saveLoginOrRegisterInfo(info: LoginOrRegisterInfo) {
  PreferencesUtil.put("username", info.username)
  PreferencesUtil.put("password", info.password)
}
```

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **LogUtil** | 只在 DEBUG 模式输出，生产环境自动关闭 |
| **ToastUtil** | duration 参数单位是毫秒，默认 2000ms |
| **PreferencesUtil** | 是异步的，需要 await |
| **get 默认值** | get 的第二个参数是默认值，类型要匹配 |
| **JSON 存储** | 对象需要 JSON.stringify，读取需要 JSON.parse |

## 6. 对比 iOS 的 UserDefaults

说实话，相比 iOS 的 UserDefaults，PreferencesUtil 也是毫不逊色的：

| 特性 | iOS UserDefaults | HarmonyOS PreferencesUtil |
|------|------------------|--------------------------|
| API 设计 | UserDefaults.standard | PreferencesUtil.put/get |
| 同步/异步 | 同步 | 异步 |
| 类型支持 | 基础类型 + 对象（需编码） | 基础类型 + 对象（需编码） |
| 持久化 | 直接持久化 | flush 后持久化 |
| 适用场景 | 小数据量存储 | 小数据量存储 |

iOS 方案胜在**同步 API 用起来方便**，PreferencesUtil 胜在**异步不阻塞主线程**。

## 总结

@pura/harmony-utils 这个工具箱，我这段时间用下来是真的香：

1. **LogUtil**：只在 DEBUG 模式输出，生产环境自动关闭
2. **ToastUtil**：一行代码搞定吐司提示
3. **PreferencesUtil**：封装了存储 API，用起来简单
4. **开箱即用**：无需自己封装，直接导入使用
5. **统一管理**：所有工具统一管理，避免散落

推荐在需要**快速开发**、**统一工具类**、**减少样板代码**的场景下使用这个工具箱。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
