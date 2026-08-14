# HarmonyOS Next 模块化开发实战：从模块划分到工程配置

> 书接上文，上回书说到我开始了HarmonyOS开发之旅。咳咳，说到模块化这件事，之前做iOS开发的时候，我折腾过CocoaPods、SPM、Tuist，一顿操作猛如虎，结果项目还是耦合得像麻花卷。直到我开始做Android/HarmonyOS项目，才发现模块化可以这么简单。今天就和大家好好聊聊HarmonyOS的模块化开发。

---

## 一、为什么需要模块化？

### 1.1 单模块项目的痛点

想象一下，你的项目只有一个巨大的代码目录：

```
entry/src/main/ets/
├── pages/          # 100+ 个页面
├── viewModel/      # 100+ 个 ViewModel
├── model/          # 50+ 个 Model
├── httpRequest/    # 所有网络请求
├── utils/          # 各种工具类
└── ...
```

但是！但是！这种"大杂烩"方式的痛点：

| 痛点 | 说明 |
|:-----|:-----|
| ❌ 代码耦合严重 | 修改一个文件，可能影响整个项目 |
| ❌ 难以复用 | 写过的网络封装换个项目又得重写 |
| ❌ 编译时间长 | 修改一行代码，要编译整个项目 |
| ❌ 不利于团队协作 | 多人同时改一个文件，冲突不断 |

### 1.2 模块化的价值

```
┌─────────────────────────────────────────────┐
│                   主工程                      │
│  entry/                                      │
│  ├── 依赖 network 模块                        │
│  └── 依赖 librarySDK 模块                     │
├─────────────────────────────────────────────┤
│              network 模块                     │
│  ├── 封装所有网络请求                          │
│  ├── API 接口定义                              │
│  └── 拦截器逻辑                               │
├─────────────────────────────────────────────┤
│             librarySDK 模块                   │
│  ├── 公共工具类                               │
│  ├── 自定义组件                              │
│  └── 常量定义                                │
└─────────────────────────────────────────────┘
```

这个思路之所以...**根本原因在于**：模块化就是让专业的人做专业的事。

---

## 二、各平台模块化对比

### 2.1 iOS 的模块化

作为一个iOS开发者，我太懂这个痛了。CocoaPods 从 2026年底就无法合入trunk分支，Apple 官方推荐使用 **SPM**，而 **Tuist** 因其声明式配置和优秀的团队协作体验，在大型 iOS 项目中越来越流行。

| 方式 | 说明 | 推荐度 |
|:-----|:-----|:-------|
| **SPM** | Apple 官方包管理工具 | ⭐⭐⭐⭐⭐ |
| **Tuist** | 用 Swift 描述项目结构 | ⭐⭐⭐⭐⭐ |
| **CocoaPods** | 包管理工具 | ⭐⭐⭐ |

> ⚠️ **重要提示**：CocoaPods 即将进入 Read only 状态，新项目不推荐再使用。

### 2.2 Android vs HarmonyOS

Android 开发中，模块化是标配：

| 方式 | HarmonyOS | Android |
|:-----|:----------|:---------|
| 构建配置 | JSON5 | Groovy/Kotlin DSL |
| 配置复杂度 | 简洁 | 复杂（Gradle版本地狱） |
| 学习曲线 | 平缓 | 陡峭 |

**Gradle 版本地狱**：

```
❌ 常见 Gradle 错误组合：
- Gradle 8.0 + AGP 7.0 ❌ 不兼容
- Gradle 8.2 + Kotlin 1.8 ❌ 有警告
- 升级 Gradle → 报错 → 降级 → 又有新报错 → 循环...
```

但是！但是！HarmonyOS 的构建配置是 JSON5 格式，相比 Gradle 的 Groovy/Kotlin DSL，简单太多：

| 对比项 | Android (Gradle) | HarmonyOS |
|:-------|:-----------------|:---------|
| 配置文件数量 | 多 | 少（3个核心文件） |
| 配置格式 | Groovy/Kotlin DSL | JSON5 |
| 版本兼容性 | 经常冲突 | 统一管理 |
| 构建速度 | 较慢 | 较快 |

---

## 三、HarmonyOS 模块化实战

### 3.1 三个核心配置文件

```
HarmonyOS 项目结构
├── entry/                        ⬅️ 主模块
│   ├── oh-package.json5          ⬅️ 依赖配置
│   ├── build-profile.json5        ⬅️ 构建配置
│   └── src/main/module.json5     ⬅️ 模块能力配置
│
├── network/                      ⬅️ 网络模块
│   ├── oh-package.json5
│   └── build-profile.json5
│
└── librarySDK/                   ⬅️ 工具库模块
    ├── oh-package.json5
    └── build-profile.json5
```

### 3.2 oh-package.json5（依赖配置）

```json5
// entry/oh-package.json5
{
  "dependencies": {
    "@ohos/axios": "^2.2.7",
    "network": "file:../network",
    "librarySDK": "file:../librarySDK"
  }
}
```

### 3.3 build-profile.json5（构建配置）

```json5
// entry/build-profile.json5
{
  "app": {
    "compileSdkVersion": 12,
    "compatibleSdkVersion": 10,
    "products": [{ "name": "default" }]
  },
  "modules": [{
    "name": "entry",
    "srcPath": "./"
  }]
}
```

### 3.4 module.json5（模块能力配置）

```json5
// entry/src/main/module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "mainElement": "EntryAbility",
    "abilities": [{
      "name": "EntryAbility",
      "srcEntry": "./ets/entryability/EntryAbility.ets"
    }]
  }
}
```

---

## 四、iOS 开发者的模块化入门

### 4.1 概念对照

| iOS (SPM/Tuist) | HarmonyOS | 说明 |
|:-----------------|:----------|:-----|
| Package.swift | oh-package.json5 | 依赖管理 |
| build.gradle | build-profile.json5 | 构建配置 |
| Info.plist | module.json5 | 模块信息 |
| Framework | Static Library | 静态库 |

### 4.2 一个简单的比喻

```
你的 App 就像一个餐厅：

🍎 iOS 方式：
  - 厨房里所有东西都混在一起
  - 要改一道菜，整个厨房都要重新整理

🥗 HarmonyOS/Android 方式：
  - 把厨房分成：洗菜区、切菜区、炒菜区、打荷区
  - 改炒菜区不影响切菜区
```

说实话，这个比喻让我想起了那句名言：**"我之所以能成功，是因为我站在巨人的肩上"**。

---

## 五、总结

✅ **模块化的价值**：职责清晰、便于复用、编译加速、团队协作
✅ **HarmonyOS 更友好**：JSON5 配置比 Gradle 简单太多
✅ **三个核心文件**：oh-package.json5、build-profile.json5、module.json5

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)

---

