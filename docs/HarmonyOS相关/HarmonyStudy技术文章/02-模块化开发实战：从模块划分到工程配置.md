# HarmonyOS Next 模块化开发实战：从模块划分到工程配置

## 写在前面

在上一篇文章 [01 - HarmonyOS 开发 wanandroid 客户端项目实践](./01-HarmonyOS开发wandroid客户端项目实践.md) 中，我们详细介绍了 **HarmonyStudy** 项目的整体架构设计、技术选型以及核心开发技巧。

本文作为续篇，将**以模块化设计为核心**，深入讲解 HarmonyOS 的模块化开发。与传统移动端开发不同，HarmonyOS 的模块化有其独特之处，特别是工程配置文件的设计。

> **适合谁看**：本文特别照顾 **iOS 开发者**，以及对模块化不太熟悉的同学。如果你有 Android 模块化开发经验，会发现很多概念非常相似。

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

这种"大杂烩"方式的痛点：

| 痛点 | 说明 |
|:-----|:-----|
| ❌ 代码耦合严重 | 修改一个文件，可能影响整个项目 |
| ❌ 难以复用 | 写过的网络封装换个项目又得重写 |
| ❌ 编译时间长 | 修改一行代码，要编译整个项目 |
| ❌ 不利于团队协作 | 多人同时改一个文件，冲突不断 |
| ❌ 权限边界模糊 | 不知道哪些代码该改，哪些不该改 |

### 1.2 模块化的价值

模块化后：

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

模块化的优势：

| 优势 | 说明 |
|:-----|:-----|
| ✅ 职责清晰 | 每个模块只专注一件事 |
| ✅ 便于复用 | network 模块可以直接引入到新项目 |
| ✅ 编译加速 | 修改 network 模块只需编译它自己 |
| ✅ 权限边界 | 明确知道该改哪个模块的代码 |
| ✅ 团队协作 | 不同模块分配给不同人负责 |

---

## 二、各平台模块化对比

### 2.1 iOS 的模块化

作为一个iOS开发者，这里我有话要说，早起只能使用CocoaPods也不是不能模块化，只是它的方式不像Android、HarmonyOS平台如此天然，它需要对Cocoapods有一定理解才能进行下去，这样导致iOS有时内心是想模块化的，但是又不想在模块化上面花费太多的时间。

iOS 开发中，模块化通常通过以下方式实现：

| 方式 | 说明 | 适用场景 | 推荐度 |
|:-----|:-----|:---------|:-------|
| **SPM (Swift Package Manager)** | Apple 官方包管理工具，Xcode 内置支持 | 新项目首选 | ⭐⭐⭐⭐⭐ |
| **Tuist** | 用 Swift 描述项目结构，声明式项目生成 | 大型项目、团队协作 | ⭐⭐⭐⭐⭐ |
| **CocoaPods** | 包管理工具，通过 Podfile 管理依赖 | 存量项目维护 | ⭐⭐⭐ |
| **Framework** | 编译成 .framework 供其他模块使用 | 需要编译缓存时 | ⭐⭐⭐ |

> ⚠️ **重要提示**：CocoaPods 从 2026年底就无法合入trunk分支，进入Read only状态，Apple 官方推荐使用 **SPM**，而 **Tuist** 因其声明式配置和优秀的团队协作体验，在大型 iOS 项目中越来越流行，但是在国内的推广并不理想。

**iOS 模块化工具对比**：

```
┌────────────────────────────────────────────────────────────────────┐
│                    iOS 模块化工具演进                                │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  早期                现代                   未来                     │
│  ────               ─────                 ────                    │
│                                                                    │
│  CocoaPods    →    SPM / Tuist    →    官方主推 SPM               │
│  (包管理)          (声明式)              (原生集成)                │
│                                                                    │
│  ❌ 维护困难        ✅ 声明配置            ✅ Xcode 原生            │
│  ❌ 生态老化        ✅ 团队协作            ✅ 依赖解析快            │
│  ❌ 冲突频繁        ✅ 版本锁定            ✅ Swift 优先            │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

**各工具特点**：

- **SPM**：
  - Xcode 原生支持，无需额外安装
  - Swift 语言官方包管理
  - 缺点：对 Objective-C 项目支持一般
- **Tuist**：
  - 用 Swift 描述项目结构（Project.swift）
  - 支持模块缓存，编译速度快
  - 适合大型项目和团队协作
  - 学习曲线略陡
- **CocoaPods**（存量项目）：
  - 生态成熟，存量项目多
  - 但维护更新缓慢
  - 新项目不推荐再使用

### 2.2 Android 的模块化

Android 开发中，模块化是标配：

| 方式 | 说明 | 适用场景 |
|:-----|:-----|:---------|
| **Library Module** | 通过 settings.gradle 引入模块 | 项目内部模块化 |
| **Maven/Gradle** | 发布模块到仓库 | 跨项目复用 |
| **Kotlin Multiplatform** | 跨平台代码共享 | 多平台项目 |

**Android 模块化的特点**：
- ✅ 与 HarmonyOS **非常相似**！
- 通过 settings.gradle 管理模块依赖
- build.gradle 配置模块的构建规则
- 编译隔离是标配

### 2.3 HarmonyOS vs Android 构建配置对比

HarmonyOS 的模块化设计**与 Android 高度相似**，但在构建配置上更加简洁友好。

#### 2.3.1 Gradle 的复杂度（Android）

Android 项目通常有**多层级**的构建配置：

```
Android 项目结构（Gradle）
├── 项目根目录/
│   ├── build.gradle              ⬅️ 项目级构建脚本
│   ├── settings.gradle            ⬅️ 项目配置
│   ├── gradle.properties          ⬅️ Gradle 属性
│   └── build.gradle.kts          ⬅️ Kotlin DSL（可选）
│
├── app/                          ⬅️ 主模块
│   ├── build.gradle              ⬅️ 模块级构建脚本（内容上百行）
│   ├── proguard-rules.pro
│   └── src/
│
├── network/                      ⬅️ 网络库模块
│   ├── build.gradle              ⬅️ 又一个构建文件
│   └── src/
│
└── librarySDK/                   ⬅️ 工具库模块
    ├── build.gradle              ⬅️ 又一个构建文件
    └── src/
```

**每个模块的 build.gradle 可能包含**：

```groovy
// app/build.gradle（可能 100+ 行）
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'kotlin-kapt'
}

android {
    namespace 'com.example.app'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.app"
        minSdk 24
        targetSdk 34
        versionCode 1
        // ... 几十行配置
    }

    buildTypes {
        release { ... }
        debug { ... }
    }

    compileOptions { ... }
    kotlinOptions { ... }
    // ...
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    // ... 几十行依赖
}
```

> **Android 开发者日常**：每次新建模块都要复制粘贴一套模板，改几十行配置。

#### 2.3.2 HarmonyOS 的简洁（JSON5）

HarmonyOS 只需要 **3 个核心配置文件**：

```
HarmonyOS 项目结构
├── entry/                        ⬅️ 主模块
│   ├── oh-package.json5          ⬅️ 依赖配置（10+ 行）
│   ├── build-profile.json5        ⬅️ 构建配置（20+ 行）
│   └── src/main/module.json5     ⬅️ 模块能力配置
│
├── network/                      ⬅️ 网络模块
│   ├── oh-package.json5          ⬅️ 依赖配置
│   └── build-profile.json5        ⬅️ 构建配置
│
└── librarySDK/                   ⬅️ 工具库模块
    ├── oh-package.json5
    └── build-profile.json5
```

**每个模块的配置简洁明了**：

```json5
// entry/oh-package.json5（依赖配置）
{
  "name": "entry",
  "version": "1.0.0",
  "dependencies": {
    "@ohos/axios": "^2.2.7",
    "network": "file:../network"
  }
}
```

```json5
// entry/build-profile.json5（构建配置）
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

#### 2.3.3 HarmonyOS 构建更友好的原因

| 对比项 | Android (Gradle) | HarmonyOS |
|:-------|:-----------------|:---------|
| **配置文件数量** | 多（build.gradle + proguard + ...） | 少（3 个核心文件） |
| **配置格式** | Groovy/Kotlin DSL（学习曲线陡） | JSON5（声明式、易读） |
| **版本兼容性** | 经常冲突（Gradle + AGP + Kotlin + ...） | 统一管理、兼容性好 |
| **构建速度** | 较慢（依赖解析耗时） | 较快 |
| **错误排查** | 错误信息复杂（版本冲突最头疼） | 清晰直接 |
| **增量构建** | 需要手动配置 | 默认支持 |

**Gradle 版本地狱**：

```
❌ 常见 Gradle 错误组合：
- Gradle 8.0 + AGP 7.0 ❌ 不兼容
- Gradle 8.2 + Kotlin 1.8 ❌ 有警告
- 升级 Gradle → 报错 → 降级 → 又有新报错 → 循环...
- "Could not resolve" "Could not find" "Conflicting"
```

**HarmonyOS 的优势**：

```
✅ HarmonyOS 构建体验：
- 一套 SDK 版本走天下
- ohpm 自动处理依赖兼容
- 错误信息清晰明了
- 很少出现"明明上周还能编译"的诡异问题
```

> **Android 开发者福音**：再也不用记 AGP 版本和 Gradle 版本的对应关系表了！

#### 2.3.4 配置对照表

| Android (Gradle) | HarmonyOS | 说明 |
|:-----------------|:----------|:-----|
| 项目根 build.gradle | - | HarmonyOS 无需项目级配置 |
| settings.gradle | oh-package.json5 | 依赖管理 |
| app/build.gradle | build-profile.json5 | 构建配置 |
| AndroidManifest.xml | module.json5 | 模块能力 |
| gradle.properties | build-profile.json5 | 构建属性 |

---

### 2.4 对比总结

```
┌─────────────┬──────────────┬──────────────┬───────────────┐
│   特性       │    iOS       │    Android   │  HarmonyOS   │
├─────────────┼──────────────┼──────────────┼───────────────┤
│ 首选方案     │ SPM / Tuist  │   Gradle     │     ohpm     │
│ 模块类型     │ Framework    │   Library    │Static Library│
│ 依赖管理     │ SPM/Tuist    │   Gradle     │    ohpm      │
│ 配置格式     │ Swift/JSON   │ Groovy/Kotlin│    JSON5     │
│ 编译隔离     │   可选        │    必须      │    必须      │
│ 学习曲线     │  中等        │    较平缓    │  与 Android  │
│              │              │              │   基本一致    │
└─────────────┴──────────────┴──────────────┴───────────────┘
```

> **iOS 开发者别慌**：虽然上面一堆概念你可能没听过，但 HarmonyOS 的模块化配置是**声明式**的（写配置文件），比 CocoaPods 的运行时加载方式简单很多，更接近 Tuist 的声明式理念。

---

## 三、HarmonyOS 模块化实战

### 3.1 创建项目模块

在 DevEco Studio 中，创建多模块项目的步骤：

#### Step 1：创建主工程（entry）

创建项目时，默认会生成 **entry** 模块，这是应用的主入口：

```
entry/                          # 主模块（类似 Android 的 app）
├── src/main/
│   ├── ets/                   # ArkTS 代码
│   ├── resources/             # 资源文件
│   └── module.json5           # 模块配置
├── oh-package.json5           # 依赖配置
├── build-profile.json5        # 构建配置
└── src/main/module.json5      # Ability 配置
```

#### Step 2：创建 network 模块

1. **File → New → Module**
2. 选择 **Static Library**（静态库）
3. 填写信息：

```
Module name: network
Package name: com.example.network
```

4. 创建后结构：

```
network/                       # 网络模块（类似 Android 的 network lib）
├── src/main/
│   ├── ets/                  # 源码目录
│   │   └── index.ets         # 导出入口
│   └── resources/            # 资源目录
├── oh-package.json5          # 依赖配置
└── build-profile.json5       # 构建配置
```

#### Step 3：创建 librarySDK 模块

重复上述步骤，创建工具库模块：

```
librarySDK/                   # 工具库模块
├── src/main/
│   ├── ets/
│   │   ├── utils/            # 工具类
│   │   ├── components/       # 公共组件
│   │   └── constants/        # 常量
│   └── resources/
├── oh-package.json5
└── build-profile.json5
```

### 3.2 模块依赖关系

```
┌─────────────────────────────────────────┐
│            entry (主应用模块)             │
│  - 负责页面展示和用户交互                 │
│  - 依赖 network 模块                      │
│  - 依赖 librarySDK 模块                   │
├─────────────────────────────────────────┤
│           network (网络模块)              │
│  - 负责所有网络请求                       │
│  - 提供 API 接口                          │
│  - 管理拦截器                             │
├─────────────────────────────────────────┤
│         librarySDK (工具库模块)           │
│  - 公共工具类                             │
│  - 自定义组件                            │
│  - 常量定义                              │
└─────────────────────────────────────────┘
```

---

## 四、工程配置文件详解

这是本文的重点！iOS 开发者可能对这部分比较陌生，我会详细解释每个文件的作用。

### 4.1 文件对比一览

| 文件位置 | 作用 | 类似概念 |
|:---------|:-----|:---------|
| entry/oh-package.json5 | 主模块的依赖配置 | iOS: Podfile |
| network/oh-package.json5 | 网络模块的依赖配置 | Android: network/build.gradle |
| entry/build-profile.json5 | 主模块的构建配置 | Android: app/build.gradle |
| entry/module.json5 | 模块能力配置 | Android: AndroidManifest.xml |

### 4.2 oh-package.json5（依赖配置）

这是 HarmonyOS 的**依赖管理文件**，类似 iOS 的 Podfile：

#### entry/oh-package.json5（主模块）

```json5
{
  "name": "entry",
  "version": "1.0.0",
  "description": "主应用模块",
  "main": "",
  "author": "",
  "license": "",
  "dependencies": {
    // 第三方依赖
    "@ohos/axios": "^2.2.7",           // 网络请求库
    "@ohos/pulltorefresh": "^3.0.0",    // 下拉刷新
    "@pura/harmony-utils": "^1.4.0",   // 工具库

    // 本地模块依赖（重点！）
    "network": "file:../network",       // 相对路径引用
    "librarySDK": "file:../librarySDK"  // 相对路径引用
  }
}
```

> **解释**：`"network": "file:../network"` 告诉项目："network 模块就在上级目录的 network 文件夹里"。

#### network/oh-package.json5（网络模块）

```json5
{
  "name": "network",
  "version": "1.0.0",
  "description": "网络请求模块",
  "main": "",
  "dependencies": {
    // 网络模块只需要 axios
    "@ohos/axios": "^2.2.7"
  }
}
```

> **原则**：每个模块只声明**自己需要**的依赖，不要把整个项目的依赖都写在这里。

### 4.3 build-profile.json5（构建配置）

这是 HarmonyOS 的**构建配置文件**，类似 Android 的 build.gradle：

#### entry/build-profile.json5（主模块）

```json5
{
  "app": {
    "compileSdkVersion": 12,          // 编译 SDK 版本
    "compatibleSdkVersion": 10,      // 兼容最低版本
    "products": [
      {
        "name": "default",          // 默认产品
        "signingConfig": "default"  // 签名配置
      }
    ]
  },
  "modules": [
    {
      "name": "entry",              // 模块名
      "srcPath": "./",              // 源码路径
      "targets": [
        "default"                    // 构建目标
      ]
    }
  ]
}
```

#### network/build-profile.json5（网络模块）

```json5
{
  "app": {
    "compileSdkVersion": 12,
    "compatibleSdkVersion": 10,
    "products": []
  },
  "modules": [
    {
      "name": "network",
      "srcPath": "./",
      "targets": [
        "default"
      ]
    }
  ]
}
```

> **注意**：library 模块（network、librarySDK）的 products 是**空数组**，因为它们不是直接运行的 App。

### 4.4 module.json5（模块能力配置）

这是 HarmonyOS 的**模块清单**，类似 Android 的 AndroidManifest.xml：

#### entry/src/main/module.json5（主模块）

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",                  // 类型：entry 表示可运行
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",    // 入口 Ability
    "deviceTypes": [
      "phone"                         // 支持的设备类型
    ],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",  // 页面配置文件
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:entry_ability_desc",
        "icon": "$media:icon",
        "label": "$string:entry_ability_label",
        "startWindowIcon": "$media:icon",
        "startWindowBackground": "$color:start_window_background"
      }
    ]
  }
}
```

#### network/src/main/module.json5（网络模块）

```json5
{
  "module": {
    "name": "network",
    "type": "shared",                 // 类型：shared 表示共享库
    "description": "网络请求模块",
    "deviceTypes": [
      "phone"
    ]
  }
}
```

> **type 字段区别**：
> - `entry`：可运行的应用模块
> - `shared`：共享库模块（其他模块可以依赖它）

---

## 五、iOS 开发者的模块化入门

### 5.1 概念对照

如果你来自 iOS，以下是概念对照：

| iOS (SPM/Tuist) | HarmonyOS | 说明 |
|:-----------------|:----------|:-----|
| Xcode Project | DevEco Studio | IDE |
| Package.swift / Project.swift | oh-package.json5 | 依赖管理 |
| build.gradle | build-profile.json5 | 构建配置 |
| Info.plist | module.json5 | 模块信息 |
| Framework / XCFramework | Static Library | 静态库 |
| App Target | entry | 主应用 |
| Framework Target | library 模块 | 库模块 |

> **iOS 现代方案对比**：
> - **SPM** → 类似 HarmonyOS 的 ohpm，都是声明式依赖管理
> - **Tuist** → 类似 HarmonyOS 的模块化理念，用配置文件描述项目结构

### 5.2 一个简单的比喻

```
你的 App 就像一个餐厅：

🍎 iOS 方式：
  - 厨房里所有东西都混在一起
  - 要改一道菜，整个厨房都要重新整理

🥗 HarmonyOS/Android 方式：
  - 把厨房分成：洗菜区、切菜区、炒菜区、打荷区
  - 改炒菜区不影响切菜区
  - 每个区可以独立"供货"给其他餐厅

模块化就是：把混乱的厨房，变成分工明确的流水线
```

### 5.3 iOS 开发者如何快速上手？

1. **先把项目跑起来**：不要纠结配置，先让 Hello World 运行
2. **记住三个核心文件**：
   - `oh-package.json5` = Package.swift / Podfile（管依赖）
   - `build-profile.json5` = build.gradle（管构建）
   - `module.json5` = Info.plist（管配置）
3. **先写单模块代码**：熟练后再拆分模块

> **SPM/Tuist 用户看过来**：如果你熟悉 Swift Package Manager 或 Tuist，HarmonyOS 的模块化会让你感到很亲切——都是声明式配置，都是用配置文件描述项目结构。

---

## 六、HarmonyStudy 项目模块实践

### 6.1 项目模块划分

基于上述理论，HarmonyStudy 项目的实际模块划分：

```
HarmonyStudy/
├── entry/                      # 主应用模块（101 个页面）
│   ├── src/main/ets/
│   │   ├── pages/              # 页面
│   │   ├── views/             # 可复用视图
│   │   └── viewModel/         # 视图模型
│   ├── oh-package.json5       # 依赖：axios, pulltorefresh, network, librarySDK
│   └── build-profile.json5
│
├── network/                   # 网络模块
│   ├── src/main/ets/
│   │   ├── examples/          # 示例代码
│   │   │   ├── api/           # API 接口定义
│   │   │   ├── pages/         # 示例页面
│   │   │   └── viewModel/     # 示例 ViewModel
│   │   └── index.ets         # 导出入口
│   └── oh-package.json5      # 依赖：axios
│
└── librarySDK/                # 工具库模块（待建设）
    └── ...
```

### 6.2 依赖关系图

```json5
// entry/oh-package.json5
{
  "dependencies": {
    // 第三方
    "@ohos/axios": "^2.2.7",
    "@ohos/pulltorefresh": "^3.0.0",
    "@jxt/xt_hud": "^3.4.0",
    "@pura/harmony-utils": "^1.4.0",

    // 本地模块
    "network": "file:../network"
  }
}
```

### 6.3 目录结构（简化版）

```
entry/src/main/ets/
├── pages/                    # 页面层
│   ├── Home.ets
│   ├── Tree.ets
│   ├── My.ets
│   └── ...
├── views/                    # 视图层
│   ├── ArticleCell.ets
│   ├── BannerView.ets
│   └── ...
├── viewModel/               # 视图模型层
│   ├── HomeViewModel.ets
│   └── ...
├── model/                   # 数据模型层
│   ├── Article.ets
│   └── ...
├── httpRequest/             # 网络请求
│   ├── Provider.ets
│   └── interceptors/
├── router/                  # 路由管理
│   ├── Router.ets
│   └── PagesConstant.ets
├── accountManager/          # 账户管理
├── utils/                   # 工具类
└── enum/                    # 枚举
```

> **说明**：当前项目为了简化，network 模块虽然创建了，但主要网络代码还是放在 entry 中。这种"物理分离但逻辑耦合"是很多项目的常态，后续可以逐步迁移。

---

## 七、快速开始

### 7.1 安装依赖

```bash
# 在项目根目录
ohpm install

# 或者在 entry 目录
cd entry && ohpm install

# network 模块
cd ../network && ohpm install
```

### 7.2 编译运行

1. 打开 DevEco Studio
2. 选择模拟器
3. 点击 Run（或 Shift + F10）

### 7.3 验证模块化

修改 network 模块的代码，只编译 network 模块，验证是否生效。

---

## 八、常见问题

### Q1：模块依赖报错找不到？

```bash
# 错误：Module 'network' not found
# 解决：
1. 检查 oh-package.json5 路径： "network": "file:../network"
2. 确保 network 目录存在
3. File → Sync and Refresh Project
```

### Q2：编译报错说模块循环依赖？

```bash
# 错误：Circular dependency detected
# 解决：
# entry → network → librarySDK 是OK的
# 但不能：entry → network → entry
```

### Q3：第三方库找不到？

```bash
# 解决：
1. 检查 ohpm 是否安装正确
2. ohpm install --force
3. 或者设置镜像源
```

---

## 九、总结

本文我们学习了：

✅ **模块化的价值**：职责清晰、便于复用、编译加速、团队协作
✅ **各平台对比**：iOS（Framework）、Android（Library）、HarmonyOS（Static Library）
✅ **HarmonyOS 模块创建**：entry、network、librarySDK
✅ **核心配置文件**：
   - oh-package.json5 = 依赖管理（类似 Podfile）
   - build-profile.json5 = 构建配置（类似 build.gradle）
   - module.json5 = 模块清单（类似 AndroidManifest.xml）
✅ **iOS 开发者入门**：概念对照、快速上手建议

### 下一步

- 尝试在项目中创建自己的模块
- 学习 MVVM 架构的具体实现
- 探索 HarmonyOS Next 新特性

---

**相关文章**：
- [01 - HarmonyOS 开发 wanandroid 客户端项目实践](./01-HarmonyOS开发wandroid客户端项目实践.md)

**GitHub 项目**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)

**标签**：#HarmonyOS #模块化 #ArkTS #iOS开发 #Android开发 #DevEcoStudio
