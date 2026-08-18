# LoadingDialogHelper 优化迁移文档

> **文档版本**: v2.0.0
> **创建日期**: 2026-02-05
> **适用版本**: HarmonyOS Next (API 12+)
> **项目**: HarmonyStudy

---

## 📋 目录

- [一、问题背景](#一问题背景)
- [二、技术方案](#二技术方案)
- [三、实施步骤](#三实施步骤)
- [四、API 使用指南](#四api-使用指南)
- [五、迁移检查清单](#五迁移检查清单)
- [六、常见问题](#六常见问题)

---

## 一、问题背景

### 1.1 原始问题

在使用 `CustomDialogController` 封装的 `LoadingDialogHelper` 出现了**弹窗无法显示**的问题：

```typescript
// 原始实现（无法正常显示）
export class LoadingDialogHelper {
  private controller: CustomDialogController

  constructor(defaultText: string = '加载中...') {
    this.controller = new CustomDialogController({
      builder: LoadingDialog({ text: this.defaultText }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: false,
    })
  }

  show(): void {
    this.controller.open()  // ❌ 调用后弹窗不显示
  }
}
```

**问题现象**：
- ✅ 代码编译通过
- ✅ `show()` 方法正常执行
- ❌ 弹窗完全不显示
- ❌ 无任何错误提示

### 1.2 根本原因分析

经过深入分析，发现问题的根本原因是：

**HarmonyOS 的 `CustomDialogController` 必须在组件的 UI 上下文中创建才能正确绑定**

```
CustomDialogController 生命周期要求：
├── 必须在 @Component 组件内部创建
├── 必须绑定正确的 UIContext
├── 不能在全局单例中创建
└── 不能在辅助类中提前创建
```

**失败尝试**：

| 方案 | 说明 | 结果 |
|------|------|------|
| 全局单例 `LoadingDialogManager` | 在全局创建 `CustomDialogController` | ❌ 无法绑定 UIContext |
| 每页实例 `LoadingDialogHelper` | 在构造函数中创建 `CustomDialogController` | ❌ 仍无法正确绑定 |
| 延迟创建控制器 | 在 `show()` 时创建控制器 | ❌ 仍然不显示 |

### 1.3 最终解决方案

采用 **@jxt/xt_hud** 第三方库，该库通过**全局 UIContext 初始化**解决了这个问题。

**核心原理**：
```typescript
// 在 EntryAbility.onWindowStageCreate 中全局初始化
windowStage.loadContent('pages/Index', (err) => {
  if (!err.code) {
    // 关键：获取并初始化 UIContext
    LoadingDialogHelper.init(windowStage)
  }
})

// 使用静态方法调用
LoadingDialogHelper.show('加载中...')
LoadingDialogHelper.hide()
```

---

## 二、技术方案

### 2.1 @jxt/xt_hud 库介绍

**库信息**：
- **包名**: `@jxt/xt_hud`
- **版本**: `^3.4.0`
- **仓库**: [ohpm](https://ohpm.openharmony.cn/)
- **作者**: jxt
- **许可证**: 开源

**功能特性**：
- ✅ Toast 提示（文字、成功、失败、警告）
- ✅ Loading 加载动画（系统样式、圆环样式）
- ✅ Progress 进度条（圆环、水平）
- ✅ 全局配置（样式、颜色、字体等）
- ✅ 队列模式（同时只显示一个）
- ✅ 模态窗口（屏蔽交互）

### 2.2 架构对比

#### 旧架构（失败）

```
┌─────────────────────────────────────┐
│          Page Component             │
│  private loadingHelper =             │
│    new LoadingDialogHelper()         │
│                                     │
│  .onClick(() => {                    │
│    this.loadingHelper.show() ❌      │
│  })                                  │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│   LoadingDialogHelper               │
│  constructor() {                     │
│    this.controller =                 │
│      new CustomDialogController(...) │
│      ❌ 无法绑定 UIContext           │
│  }                                   │
└─────────────────────────────────────┘
```

#### 新架构（成功）

```
┌─────────────────────────────────────┐
│      EntryAbility                   │
│  onWindowStageCreate() {             │
│    windowStage.loadContent(...)      │
│    LoadingDialogHelper.init(         │
│      windowStage) ✅                 │
│  }                                   │
└─────────────────────────────────────┘
           ↓ 初始化 UIContext
┌─────────────────────────────────────┐
│   XTPromptHUD (全局)                 │
│  .globalConfigLoading(context)       │
│  .showLoading(text)                  │
│  .hideAllLoading()                   │
└─────────────────────────────────────┘
           ↑ 调用
┌─────────────────────────────────────┐
│          Page Component             │
│  .onClick(() => {                    │
│    LoadingDialogHelper               │
│      .show('加载中...') ✅            │
│  })                                  │
└─────────────────────────────────────┘
```

### 2.3 技术栈更新

| 组件 | 旧方案 | 新方案 |
|------|--------|--------|
| **UIContext** | ❌ 无 | ✅ 全局初始化 |
| **实现方式** | CustomDialogController | XTPromptHUD |
| **调用方式** | 实例方法 | 静态方法 |
| **第三方库** | 无 | @jxt/xt_hud ^3.4.0 |

---

## 三、实施步骤

### 3.1 安装依赖

```bash
cd entry
ohpm install @jxt/xt_hud
```

### 3.2 重写 LoadingDialogHelper

**文件**: `entry/src/main/ets/utils/LoadingDialogHelper.ets`

**核心代码**：
```typescript
import { XTPromptHUD } from '@jxt/xt_hud'
import { window } from '@kit.ArkUI'

export class LoadingDialogHelper {
  private static initialized = false

  /**
   * 全局初始化 - 必须在 windowStage.loadContent 之后调用
   */
  public static init(windowStage: window.WindowStage): void {
    const context = windowStage.getMainWindowSync().getUIContext()
    LoadingDialogHelper.initUIConfig(context)
    this.initialized = true
  }

  /**
   * 显示加载对话框
   */
  public static show(text: string = '加载中...'): void {
    XTPromptHUD.showLoading(text)
  }

  /**
   * 隐藏加载对话框
   */
  public static hide(): void {
    XTPromptHUD.hideAllLoading()
  }

  /**
   * 包装异步任务，自动显示/隐藏加载对话框
   */
  public static async wrap<T>(
    task: Promise<T>,
    text: string = '加载中...'
  ): Promise<T | null> {
    LoadingDialogHelper.show(text)
    try {
      return await task
    } catch (error) {
      throw new Error(error instanceof Error ? error.message : String(error))
    } finally {
      LoadingDialogHelper.hide()
    }
  }

  // 兼容旧API的实例方法（内部调用静态方法）
  private instanceText: string = '加载中...'
  constructor(defaultText: string = '加载中...') {
    this.instanceText = defaultText
  }
  show(text?: string): void {
    LoadingDialogHelper.show(text ?? this.instanceText)
  }
  hide(): void {
    LoadingDialogHelper.hide()
  }
  async wrap<T>(task: Promise<T>, text?: string): Promise<T> {
    return LoadingDialogHelper.wrap(task, text ?? this.instanceText) as Promise<T>
  }
  destroy(): void {
    // 静态方法无需销毁
  }
}
```

### 3.3 初始化 EntryAbility

**文件**: `entry/src/main/ets/entryability/EntryAbility.ets`

**修改位置**: `onWindowStageCreate()` 方法

```typescript
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // ... 其他初始化代码

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content.');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      // ✅ 初始化 LoadingDialogHelper
      LoadingDialogHelper.init(windowStage)
    })

    // ...
  }
}
```

### 3.4 现有代码兼容

**由于保留了实例方法兼容性，现有页面无需修改**：

```typescript
// 旧代码（继续有效）
private loadingHelper = new LoadingDialogHelper('正在登录...')

async doSomething() {
  await this.loadingHelper.wrap(this.viewModel.login(info))
  aboutToDisappear() {
    this.loadingHelper.destroy()
  }
}
```

**推荐逐步迁移到新API**：

```typescript
// 新代码（推荐）
async doSomething() {
  await LoadingDialogHelper.wrap(
    this.viewModel.login(info),
    '正在登录...'
  )
  // 无需调用 destroy()
}
```

---

## 四、API 使用指南

### 4.1 静态方法（推荐）

#### show() - 显示加载框

```typescript
// 基础用法
LoadingDialogHelper.show()

// 自定义文字
LoadingDialogHelper.show('请稍候...')

// 加载网络请求
LoadingDialogHelper.show('加载中...')
try {
  await this.viewModel.loadData()
} finally {
  LoadingDialogHelper.hide()
}
```

#### hide() - 隐藏加载框

```typescript
LoadingDialogHelper.hide()
```

#### wrap() - 自动包装异步任务

```typescript
// 自动管理显示/隐藏
const result = await LoadingDialogHelper.wrap(
  this.viewModel.login({ username, password }),
  '正在登录...'
)

// 如果失败，自动抛出错误
try {
  const user = await LoadingDialogHelper.wrap(
    this.getUserInfo(),
    '获取用户信息...'
  )
  console.log('用户信息:', user)
} catch (error) {
  console.error('获取失败:', error)
}
```

### 4.2 实例方法（兼容）

```typescript
@Component
struct MyPage {
  private loadingHelper = new LoadingDialogHelper('加载中...')

  async loadData() {
    // 使用实例方法
    await this.loadingHelper.wrap(
      this.viewModel.fetchData()
    )
  }

  aboutToDisappear() {
    // 虽然 destroy() 是空操作，但保留可以提醒开发者
    this.loadingHelper.destroy()
  }
}
```

### 4.3 完整示例

#### 示例1：登录页面

```typescript
@Entry({routeName: RouterName.Login})
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  private viewModel = new LoginViewModel()

  async handleLogin() {
    try {
      const result: LoginResult = await LoadingDialogHelper.wrap(
        this.viewModel.loginWithUserInfo({
          username: this.username,
          password: this.password
        }),
        '正在登录...'
      )

      if (result.success && result.userInfo) {
        Router.backWithParams('', result.userInfo)
      } else {
        ToastUtil.showToast($r('app.string.login_failed'))
      }
    } catch (error) {
      ErrorHandler.handle(error, '登录失败')
    }
  }

  build() {
    // ...
    Button($r('app.string.login_button'))
      .onClick(() => this.handleLogin())
  }
}
```

#### 示例2：网络请求

```typescript
@Component
struct Home {
  @State status: ViewStatus = ViewStatus.loading
  private viewModel = new HomeViewModel()

  async aboutToAppear(): Promise<void> {
    try {
      const results = await LoadingDialogHelper.wrap(
        this.viewModel.networkRequest(ScrollActionType.refresh),
        '加载首页数据...'
      )

      ListDataProcessor.processMixedData(
        this.dataSource,
        this.listDataSource,
        results,
        ScrollActionType.refresh,
        (status) => this.status = status
      )
    } catch (error) {
      ErrorHandler.handle(error, '加载失败')
      this.status = ViewStatus.error
    }
  }

  build() {
    StatusWeight({
      status: this.status,
      contentBuilder: () => this.getContentView()
    })
  }
}
```

---

## 五、迁移检查清单

### 5.1 迁移前检查

```
依赖环境
□ 已执行 ohpm install @jxt/xt_hud
□ entry/oh-package.json5 中包含依赖
□ 项目编译通过

代码准备
□ 已阅读本文档
□ 了解新 API 使用方法
□ 已备份关键代码
```

### 5.2 迁移步骤检查

```
步骤1：安装依赖
□ cd entry
□ ohpm install @jxt/xt_hud
□ 验证安装成功

步骤2：重写 LoadingDialogHelper
□ 复制新代码到 utils/LoadingDialogHelper.ets
□ 保留实例方法兼容性
□ 编译通过

步骤3：初始化 EntryAbility
□ 添加 import LoadingDialogHelper
□ 在 loadContent 回调中调用 init()
□ 编译通过

步骤4：测试验证
□ 应用正常启动
□ Loading 正常显示
□ Loading 正常隐藏
□ 无错误日志
```

### 5.3 迁移后验证

```
功能验证
□ 登录页面 Loading 显示正常
□ 注册页面 Loading 显示正常
□ 网络请求 Loading 显示正常
□ 所有使用 Loading 的页面正常

性能验证
□ Loading 显示无延迟
□ 内存占用无明显增加
□ 应用流畅度正常

代码质量
□ 编译无警告
□ 无错误日志
□ 代码审查通过
```

---

## 六、常见问题

### Q1: 为什么 CustomDialogController 不显示？

**A**: HarmonyOS 的 `CustomDialogController` 必须在正确的 UI 上下文中创建。当在辅助类的构造函数中创建时，无法正确绑定到组件的 UIContext，导致弹窗无法显示。

**解决方案**: 使用 `@jxt/xt_hud` 库，通过全局初始化 UIContext 来解决这个问题。

### Q2: 可以继续使用旧的实例方法吗？

**A**: 可以。新的 `LoadingDialogHelper` 保留了实例方法兼容性，现有代码无需修改即可继续工作。

**推荐**: 逐步迁移到静态方法，代码更简洁。

### Q3: wrap() 方法中发生错误会自动隐藏 Loading 吗？

**A**: 会的。`wrap()` 方法使用 `try-finally` 确保无论成功或失败，都会调用 `hide()`。

```typescript
public static async wrap<T>(task: Promise<T>, text: string): Promise<T | null> {
  LoadingDialogHelper.show(text)
  try {
    return await task
  } catch (error) {
    throw error  // 错误会重新抛出
  } finally {
    LoadingDialogHelper.hide()  // ✅ 无论如何都会执行
  }
}
```

### Q4: 必须在 EntryAbility 中初始化吗？

**A**: 是的。`LoadingDialogHelper.init()` 必须在 `windowStage.loadContent()` 的回调中调用，这是获取正确 UIContext 的关键时机。

### Q5: 如何自定义 Loading 样式？

**A**: 在 `initUIConfig()` 方法中修改配置：

```typescript
private static initUIConfig(context: UIContext): void {
  XTPromptHUD.globalConfigLoading(context, (options) => {
    options.backgroundColor = '#CC000000'  // 背景色
    options.fontSize = 16.0                   // 字体大小
    options.borderRadius = 8.0                // 圆角
    options.iconSize = { width: 50, height: 50 }  // 图标大小
    // ... 更多配置
  })
}
```

### Q6: 可以同时显示多个 Loading 吗？

**A**: 不可以。`@jxt/xt_hud` 使用队列模式，同时只会显示一个 Loading。这是为了防止多个 Loading 叠加显示。

### Q7: 需要调用 destroy() 吗？

**A**: 使用静态方法时不需要。`destroy()` 方法保留只是为了兼容旧代码，实际上是空操作。

---

## 七、总结

### 7.1 关键改进

| 方面 | 改进前 | 改进后 |
|------|--------|--------|
| **显示问题** | ❌ 弹窗不显示 | ✅ 正常显示 |
| **实现方式** | CustomDialogController | XTPromptHUD |
| **API 风格** | 实例方法 | 静态方法（兼容实例） |
| **初始化** | 无需初始化 | 全局 UIContext 初始化 |
| **依赖** | 无 | @jxt/xt_hud ^3.4.0 |

### 7.2 技术收益

1. ✅ **彻底解决弹窗显示问题** - 使用成熟的三方库，经过社区验证
2. ✅ **代码更简洁** - 静态方法调用，无需实例管理
3. ✅ **向后兼容** - 保留实例方法，现有代码无需修改
4. ✅ **功能更丰富** - 支持 Toast、Success、Error、Progress 等
5. ✅ **统一配置** - 全局样式配置，一次设置全局生效

### 7.3 经验总结

1. **UIContext 的重要性** - HarmonyOS 的 UI 组件必须正确绑定 UIContext
2. **第三方库的价值** - 对于复杂功能，优先考虑成熟的第三方库
3. **兼容性设计** - 保留旧 API 兼容性，降低迁移成本
4. **全局初始化模式** - 某些组件需要在应用启动时全局初始化

---

## 附录

### A. 参考文档

- [@jxt/xt_hud 文档](https://ohpm.openharmony.cn/#/cn/package/pkg-detail?name=@jxt%2Fxt_hud)
- [HarmonyOS UIContext 指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5)
- [CustomDialogController 最佳实践](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5)

### B. 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v2.0.0 | 2026-02-05 | 重写为基于 @jxt/xt_hud 的实现 |
| v1.0.0 | 2025-xx-xx | 初始版本（CustomDialogController 实现） |

### C. 相关文件

```
HarmonyStudy/
├── entry/
│   ├── oh-package.json5          # 添加 @jxt/xt_hud 依赖
│   └── src/main/ets/
│       ├── entryability/
│       │   └── EntryAbility.ets  # 添加 LoadingDialogHelper.init()
│       ├── utils/
│       │   └── LoadingDialogHelper.ets  # 重写实现
│       └── pages/
│           ├── Login.ets         # 使用 LoadingDialogHelper
│           ├── Register.ets      # 使用 LoadingDialogHelper
│           ├── WebPage.ets       # 使用 LoadingDialogHelper
│           ├── Home.ets          # 使用 LoadingDialogHelper
│           ├── Setting.ets       # 使用 LoadingDialogHelper
│           └── TabScaffold.ets   # 使用 LoadingDialogHelper
└── docs/
    └── LOADING_DIALOG_MIGRATION.md  # 本文档
```

---

**文档结束**

> 本文档记录了 LoadingDialogHelper 从 CustomDialogController 到 @jxt/xt_hud 的完整迁移过程。如有任何问题或建议，请及时反馈。
