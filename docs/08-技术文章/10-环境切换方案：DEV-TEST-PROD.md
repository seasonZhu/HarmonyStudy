# HarmonyOS 环境切换方案：开发/生产/测试一个配置搞定

> 咳咳，说到环境切换这个话题，我想起当年在 iOS 开发的时候，每次切换环境都得改代码——DEV、TEST、PROD 三个地址来回切换，一不小心上线前忘了改回生产地址，那可就尴尬了。后来我学聪明了，用 Build Configuration 来区分，但每次新建项目还是得折腾一套。到了 HarmonyOS 这边，我发现官方给了一个挺优雅的方案，结合 Preferences 做持久化，切换环境只需一行代码。今天就和大家好好聊聊这个话题。

## 1. 先说痛点

聊到环境切换，我们经常会遇到这么几个问题：

- **多环境配置散落**：DEV、TEST、PROD 的 baseURL、timeout、enableLog 各不一样
- **环境切换麻烦**：改代码太原始，一不小心就带到了生产环境
- **环境状态丢失**：App 重启后环境配置丢失，还得重新设置
- **调试困难**：生产环境出了问题，想切到测试环境看看，结果发现切不了

但是！但是！用了环境管理方案之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                        EntryAbility                                 │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              EnvironmentManager (单例)                         │  │
│  │                                                             │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │              Preferences 持久化                       │   │  │
│  │  │   Key: "current_environment"                         │   │  │
│  │  │   Value: "dev" | "test" | "prod"                    │   │  │
│  │  └─────────────────────────────────────────────────────┘   │  │
│  │                            │                                │  │
│  │                            ▼                                │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │              EnvironmentSwitch 页面                   │   │  │
│  │  │   [DEV]  [TEST]  [PROD]                            │   │  │
│  │  └─────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                            │                                      │
│                            ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                      Provider                                │  │
│  │                                                             │  │
│  │  baseURL = EnvConfig.getConfig(env).baseUrl                │  │
│  │  timeout = EnvConfig.getConfig(env).timeout                │  │
│  │  enableLog = EnvConfig.getConfig(env).enableLog            │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **EnvironmentManager + Preferences 持久化**。环境配置一旦设定，App 重启也不会丢失，非常适合调试场景。

## 3. 核心代码展示

### 3.1 环境枚举定义

**Talk is cheap, show me the code**

```typescript
// Environment.ets
export enum Environment {
  DEV = "dev",
  TEST = "test",
  PROD = "prod"
}
```

简单粗暴，三环境枚举，清晰明了。

### 3.2 环境配置类

```typescript
// Environment.ets
export class EnvConfig {
  baseUrl: string = ""
  timeout: number = 30000
  enableLog: boolean = true

  static getConfig(env: Environment): EnvConfig {
    const config = new EnvConfig()
    switch(env) {
      case Environment.DEV:
        config.baseUrl = "https://wanandroid.com"
        config.timeout = 30000
        config.enableLog = true
        break
      case Environment.TEST:
        config.baseUrl = "https://wanandroid.com"
        config.timeout = 60000
        config.enableLog = true
        break
      case Environment.PROD:
        config.baseUrl = "https://wanandroid.com"
        config.timeout = 30000
        config.enableLog = false
        break
    }
    return config
  }
}
```

| 环境 | baseUrl | timeout | enableLog |
|------|---------|---------|-----------|
| DEV | wanandroid.com | 30s | true |
| TEST | wanandroid.com | 60s | true |
| PROD | wanandroid.com | 30s | false |

这个设计思路之所以优雅，根本原因在于：

1. **配置集中管理**：所有环境配置在一个地方
2. **默认值明确**：每个环境都有明确的超时和日志配置
3. **扩展性强**：新增环境只需添加 case 分支

### 3.3 EnvironmentManager 单例

```typescript
// EnvironmentManager.ets
export class EnvironmentManager {
  private static instance: EnvironmentManager
  private readonly STORE_NAME = 'environment_store'
  private readonly KEY_ENV = 'current_environment'
  private preferences: preferences.Preferences | null = null

  static getInstance(): EnvironmentManager {
    if (!EnvironmentManager.instance) {
      EnvironmentManager.instance = new EnvironmentManager()
    }
    return EnvironmentManager.instance
  }

  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME)
    } catch (error) {
      LogUtil.error('EnvironmentManager: 初始化失败', JSON.stringify(error))
    }
  }

  async getCurrentEnvironment(): Promise<Environment> {
    if (!this.preferences) {
      return Environment.PROD
    }
    try {
      const envValue = await this.preferences.get(this.KEY_ENV, Environment.PROD)
      return envValue as Environment
    } catch (error) {
      return Environment.PROD
    }
  }

  async setCurrentEnvironment(env: Environment): Promise<void> {
    if (!this.preferences) {
      return
    }
    try {
      await this.preferences.put(this.KEY_ENV, env)
      await this.preferences.flush()
      LogUtil.info('EnvironmentManager: 环境已切换为', env)
    } catch (error) {
      LogUtil.error('EnvironmentManager: 设置环境失败', JSON.stringify(error))
    }
  }

  getEnvironmentDisplayName(env: Environment): string {
    switch (env) {
      case Environment.DEV: return "开发环境 (DEV)"
      case Environment.TEST: return "测试环境 (TEST)"
      case Environment.PROD: return "生产环境 (PROD)"
      default: return "未知环境"
    }
  }
}

export const environmentManager = EnvironmentManager.getInstance()
```

这里我采用了**单例模式**来管理环境：

1. **Preferences 持久化**：环境配置存储在本地，重启不丢失
2. **异步初始化**：init() 方法需要在 EntryAbility 中调用
3. **便捷获取**：getInstance() 获取单例，chain 式调用

### 3.4 Provider 集成

```typescript
// Provider.ets
export class Provider extends BaseProvider {

  static async initEnvironment(): Promise<void> {
    try {
      Provider.currentEnv = await environmentManager.getCurrentEnvironment()
      Provider.currentConfig = EnvConfig.getConfig(Provider.currentEnv)
      LogUtil.info('Provider: 当前环境已初始化为 ' + Provider.currentEnv)
    } catch (error) {
      LogUtil.error('Provider: 初始化环境失败，使用默认环境')
    }
  }

  static async refreshEnvironment(): Promise<void> {
    await Provider.initEnvironment()
  }

  static getBaseUrl(): string {
    return Provider.currentConfig.baseUrl
  }

  static getTimeout(): number {
    return Provider.currentConfig.timeout
  }

  static isLogEnabled(): boolean {
    return Provider.currentConfig.enableLog
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

## 4. 使用流程

### 4.1 EntryAbility 初始化

```typescript
// EntryAbility.ets
import { environmentManager } from './httpRequest/EnvironmentManager'
import { Provider } from './httpRequest/Provider'

async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
  // 初始化环境管理器
  await environmentManager.init(this.context)

  // 初始化网络层环境配置
  await Provider.initEnvironment()
}
```

### 4.2 环境切换页面

```typescript
// EnvironmentSwitch.ets
@Entry
@Component
struct EnvironmentSwitch {

  @State currentEnv: Environment = Environment.PROD

  async aboutToAppear(): Promise<void> {
    this.currentEnv = await environmentManager.getCurrentEnvironment()
  }

  async switchEnvironment(env: Environment) {
    await environmentManager.setCurrentEnvironment(env)
    await Provider.refreshEnvironment()
    this.currentEnv = env
    promptAction.showToast({ message: '环境已切换为: ' + environmentManager.getEnvironmentDisplayName(env) })
  }

  build() {
    Column() {
      Text('当前环境: ' + environmentManager.getEnvironmentDisplayName(this.currentEnv))
        .fontSize(20)

      Row() {
        Button('开发环境')
          .onClick(() => this.switchEnvironment(Environment.DEV))
        Button('测试环境')
          .onClick(() => this.switchEnvironment(Environment.TEST))
        Button('生产环境')
          .onClick(() => this.switchEnvironment(Environment.PROD))
      }
    }
  }
}
```

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **初始化时机** | EnvironmentManager.init() 必须在 Provider.initEnvironment() 之前调用 |
| **异步操作** | getCurrentEnvironment() 和 setCurrentEnvironment() 都是异步的，需要 await |
| **默认值** | 如果 preferences 未初始化，默认返回 PROD 环境 |
| **日志控制** | PROD 环境的 enableLog 为 false，避免生产环境日志泄露 |
| **超时配置** | TEST 环境 timeout 最长，方便测试人员调试 |

## 6. 对比 iOS 的环境方案

说实话，相比 iOS 的环境方案（Build Configuration + xcconfig），HarmonyOS 这套方案也是毫不逊色的：

| 特性 | iOS xcconfig | HarmonyOS Preferences |
|------|---------------|----------------------|
| 配置方式 | Build Configuration | Environment 枚举 |
| 持久化 | 编译时固定 | 运行时可切换 |
| 用户可控 | 否（编译时决定） | 是（运行时切换） |
| 切换难度 | 需重新编译 | 一行代码搞定 |
| 调试友好度 | 一般 | 非常友好 |

iOS 方案胜在**安全**（编译时锁定），HarmonyOS 方案胜在**灵活**（运行时切换）。

## 7. 进阶用法

### 7.1 每次启动自动检测环境

```typescript
// EntryAbility.ets
async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
  await environmentManager.init(this.context)
  await Provider.initEnvironment()

  // 每次启动打印当前环境
  const currentEnv = await environmentManager.getCurrentEnvironment()
  console.info('App started with environment: ' + currentEnv)
}
```

### 7.2 环境变更监听

```typescript
// 可以通过 emitter 事件机制通知全局环境变更
emitter.emit('ENVIRONMENT_CHANGED', {
  data: {
    env: newEnv,
    baseUrl: EnvConfig.getConfig(newEnv).baseUrl
  }
})
```

## 总结

HarmonyOS 的环境切换方案，我这段时间用下来是真的香：

1. **单例模式**：EnvironmentManager 全局唯一
2. **Preferences 持久化**：环境配置不丢失
3. **运行时切换**：无需重新编译，一行代码搞定
4. **配置集中管理**：所有环境配置在一个地方
5. **日志可控**：生产环境自动关闭日志

推荐在需要**多环境调试**、**灵活切换环境**、**持久化环境状态**的场景下使用这套环境管理方案。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
