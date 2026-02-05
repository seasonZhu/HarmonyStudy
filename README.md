# HarmonyStudy

> 使用 ArkTS 与 ArkUI 编写的 HarmonyOS WanAndroid 客户端

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-API%2010%2B-blue.svg)](https://developer.huawei.com/consumer/cn/harmonyos/)
[![ArkTS](https://img.shields.io/badge/language-ArkTS-orange.svg)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-started-V5)

## 📖 简介

本项目是基于 [WanAndroid 开放 API](https://www.wanandroid.com/) 开发的 HarmonyOS 原生客户端，采用**响应式编程**架构设计，遵循 HarmonyOS 最佳实践。

项目架构与其他平台的 WanAndroid 客户端（[Swift版](https://github.com/seasonZhu/RxStudy)、[Flutter版](https://github.com/seasonZhu/GetXStudy)）一脉相承，体现了跨平台架构设计的一致性。

### 技术特点

- 🎯 **纯原生开发**：UI 和组件全部使用 HarmonyOS 原生框架
- 📦 **轻量依赖**：仅引入必要的第三方库，保持项目简洁
- 🏗️ **分层架构**：清晰的 MVVM 架构，易于维护和扩展
- 🌍 **国际化支持**：完整的中英文资源管理
- 🔄 **统一数据处理**：ListDataProcessor 统一处理列表数据逻辑

## 🚀 功能特性

### 核心功能

- ✅ **五大模块**：首页、项目、公众号、体系、我的
- ✅ **用户系统**：登录、注册、自动登录
- ✅ **搜索功能**：热门搜索、实时搜索
- ✅ **文章系统**：文章列表、WebView 详情页
- ✅ **交互体验**：下拉刷新、上拉加载更多
- ✅ **轮播图**：自动轮播的 Banner 展示
- ✅ **Tab 切换**：多标签页滑动切换
- ✅ **收藏管理**：文章收藏/取消收藏
- ✅ **积分排名**：积分排行榜查看

### UI/UX 特性

- 🎨 统一的 Loading 状态管理
- 🌐 完整的中英文国际化支持
- 📱 响应式布局适配
- 🎭 自定义状态页面（加载中、错误、空数据）

## 🏗️ 项目架构

### 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| ArkTS | - | HarmonyOS 官方推荐的开发语言 |
| ArkUI | - | 声明式 UI 框架 |
| @ohos/axios | ^2.2.7 | HTTP 网络请求 |
| @ohos/pulltorefresh | ^3.0.0 | 下拉刷新组件 |
| @ohos/imageknife | ^3.2.8 | 图片加载缓存 |
| @pura/harmony-utils | ^1.4.0 | 工具类库 |
| @jxt/xt_hud | ^3.4.0 | Loading/Toast 弹窗组件 |
| @dcloudio/uni-app-runtime | 5.0.2026020301 | UniApp 运行时（支持 Vue3） |

### 项目结构

```
HarmonyStudy/
├── entry/                      # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── accountManager/ # 账户管理
│       │   ├── constants/      # 常量定义
│       │   ├── enum/           # 枚举类型
│       │   ├── entity/         # 实体类
│       │   ├── httpRequest/    # 网络请求封装
│       │   │   ├── configuration/  # 网络配置
│       │   │   └── interceptors/   # 拦截器
│       │   ├── model/          # 数据模型
│       │   ├── pages/          # 页面组件
│       │   ├── router/         # 路由管理
│       │   ├── utils/          # 工具类
│       │   ├── views/          # 自定义视图组件
│       │   └── viewModel/      # 视图模型
│       └── resources/          # 资源文件
│           ├── base/element/   # 通用资源
│           ├── zh_CN/element/  # 中文资源
│           └── en_US/element/  # 英文资源
├── network/                    # 网络模块（HarmonyOS 网络）
└── Utils/                      # 工具模块（UniApp 相关）
```

### 架构设计

```
┌─────────────────────────────────────┐
│            Pages (UI层)              │
├─────────────────────────────────────┤
│         ViewModels (业务层)          │
├─────────────────────────────────────┤
│   Models / Network (数据/网络层)     │
├─────────────────────────────────────┤
│        Utils / Constants (工具层)    │
└─────────────────────────────────────┘
```

### 核心组件说明

| 组件/工具 | 说明 |
|----------|------|
| **ListDataProcessor** | 统一处理分页列表数据，支持刷新/加载更多 |
| **StatusWeight** | 页面状态管理（loading/error/empty/success） |
| **LoadingDialogHelper** | 基于 @jxt/xt_hud 的加载弹窗工具类（支持静态/实例方法） |
| **ErrorHandler** | 统一的错误处理和日志记录工具类 |
| **Router** | 路由管理，支持页面跳转和参数传递 |
| **AccountManager** | 用户账户管理，支持自动登录 |

## 🎬 界面预览

| ![](ScreenShots/1.jpeg) | ![](ScreenShots/2.jpeg) | ![](ScreenShots/3.jpeg) | ![](ScreenShots/4.jpeg) | ![](ScreenShots/5.jpeg) |
|:----------------------:|:----------------------:|:----------------------:|:----------------------:|:----------------------:|

## 📦 快速开始

### 环境要求

- DevEco Studio 4.0+
- HarmonyOS API 10+
- Node.js 14+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/seasonZhu/HarmonyStudy.git
   cd HarmonyStudy
   ```

2. **安装依赖**
   ```bash
   # 安装主模块依赖
   cd entry
   ohpm install

   # 安装 network 模块依赖
   cd ../network
   ohpm install

   # 安装 Utils 模块依赖
   cd ../Utils
   ohpm install
   ```

3. **打开项目**
   - 使用 DevEco Studio 打开项目根目录
   - 等待依赖同步完成

4. **运行项目**
   - 连接 HarmonyOS 设备或启动模拟器
   - 点击 Run 按钮或按 `Shift + F10`

## 🔧 开发指南

### 资源管理

项目使用 HarmonyOS 原生资源管理系统：

- **颜色**：`resources/base/element/color.json`
- **字符串**：`resources/base/element/string.json`
- **国际化**：`resources/zh_CN/`、`resources/en_US/`

使用方式：
```typescript
// 在代码中引用资源
.color($r('app.color.mainBlue'))
.text($r('app.string.loading_request'))
```

### 列表数据处理

使用 `ListDataProcessor` 统一处理列表数据：

```typescript
ListDataProcessor.processPagedListData(
  this.listDataSource,
  response,
  ScrollActionType.refresh,
  (status: ViewStatus) => {
    this.status = status
  }
)
```

### Loading 状态管理

**弹窗式 Loading**（登录/网络请求）：
```typescript
// 推荐：使用静态方法
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper'

// 方式1：手动控制
LoadingDialogHelper.show('加载中...')
try {
  await someApi()
} finally {
  LoadingDialogHelper.hide()
}

// 方式2：自动包装（推荐）
const result = await LoadingDialogHelper.wrap(
  someApi(),
  '加载中...'
)

// 兼容：使用实例方法（旧代码无需修改）
private loadingHelper = new LoadingDialogHelper('加载中...')
await this.loadingHelper.wrap(someApi())
```

**页面式 Loading**（列表页面）：
```typescript
StatusWeight({
  status: this.status,
  contentBuilder: () => { this.getContentView() }
})
```

## 🔗 相关项目

| 平台 | 项目地址 | 架构 |
|------|---------|------|
| **Swift** | [RxStudy](https://github.com/seasonZhu/RxStudy) | RxSwift + MVVM |
| **Flutter** | [GetXStudy](https://github.com/seasonZhu/GetXStudy) | GetX + MVC |
| **UniApp** | [UniAppPlayAndroid](https://github.com/seasonZhu/UniAppPlayAndroid) | Vue3 + UniApp |
| **HarmonyOS** | [HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy) | ArkTS + MVVM |

## 📚 学习资源

### 华为官方最佳实践

- [架构设计最佳实践](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-architecture-design-V5)
- [状态管理最佳实践](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-status-management-V5)
- [长列表加载性能优化](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-best-practices-long-list-V5)
- [应用隐私保护](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-app-privacy-protection-V5)
- [页面间转场最佳实践](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-page-transition-V5)
- [合理使用动画](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-fair-use-animation-V5)
- [帧率和丢帧分析实践](https://developer.huawei.com/consumer/cn/doc/best-practices-V5/bpta-frame-practice-V5)

### 版本管理说明

> 注意：0.x.x 版本被视为非稳定版本（unstable），在语义化版本控制中，小版本号可能不向下兼容。

```bash
# ^ 符号：允许小版本和补丁版本更新
^2.2.7  # >=2.2.0; <3.0.0

# ~ 符号：仅允许补丁版本更新
~2.2.7  # >=2.2.7; <2.3.0

# 0.x 版本特别注意（非稳定版本）
^0.3.0  # >=0.3.0; <0.4.0 (不是 <1.0.0)
```

## 📝 更新日志

### v2.0.0 (最新)
- 🎉 重大升级：LoadingDialogHelper 基于 @jxt/xt_hud 重写
- ✅ 解决 CustomDialogController 弹窗无法显示的问题
- ✨ 新增静态方法 API（show/hide/wrap）
- ✨ 保留实例方法兼容性，现有代码无需修改
- 📚 新增完整的迁移文档（docs/LOADING_DIALOG_MIGRATION.md）
- 🔧 在 EntryAbility 中添加全局 UIContext 初始化
- ⬆️ 升级 @ohos/pulltorefresh 至 3.0.0
- ⬆️ 升级 @ohos/imageknife 至 3.2.8

### v1.4.0
- ✨ 新增完整的国际化支持（中英文）
- ✨ 新增 ListDataProcessor 统一列表数据处理
- ✨ 新增 StatusWeight 状态管理组件
- ✨ 新增 ErrorHandler 统一错误处理
- 🎨 优化 Loading 弹窗样式统一
- 🔧 重构代码结构，移除冗余工具类（BaseViewModel）

## 👨‍💻 作者

- **掘金主页**：[seasonZhu](https://juejin.cn/user/4353721778057997)
- **GitHub**：[seasonZhu](https://github.com/seasonZhu)

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证

---

**如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！**
