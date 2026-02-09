# HarmonyStudy

> 使用 ArkTS 与 ArkUI 构建的生产级 HarmonyOS 客户端

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-API%2010%2B-blue.svg)](https://developer.huawei.com/consumer/cn/harmonyos/)
[![ArkTS](https://img.shields.io/badge/language-ArkTS-orange.svg)](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-started-V5)

## 📖 项目简介

本项目是基于 [WanAndroid 开放 API](https://www.wanandroid.com/) 开发的 HarmonyOS 原生客户端，采用**响应式编程**架构设计，严格遵循 HarmonyOS 最佳实践。

### 与其他平台架构一脉相承

| 平台 | 项目地址 | 架构模式 |
|:----:|:---------|:---------|
| **iOS** | [RxStudy](https://github.com/seasonZhu/RxStudy) | RxSwift + MVVM |
| **Android** | [GetXStudy](https://github.com/seasonZhu/GetXStudy) | GetX + MVC |
| **跨平台** | [UniAppPlayAndroid](https://github.com/seasonZhu/UniAppPlayAndroid) | Vue3 + UniApp |
| **HarmonyOS** | [HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy) | ArkTS + MVVM |

### 核心设计原则

- 🎯 **纯原生开发**：UI 和组件全部使用 HarmonyOS 原生框架，无 WebView 混合
- 📦 **最小依赖**：仅引入必要的第三方库，保持项目轻量可控
- 🏗️ **清晰分层**：MVVM 架构，职责明确，易于维护和扩展
- 🌍 **国际化优先**：完整的中英文资源管理体系
- 🔄 **统一抽象**：ListDataProcessor 统一处理分页列表逻辑
- ✅ **测试覆盖**：单元测试与 UI 测试并行保障质量

## 🚀 功能特性

### 核心业务功能

| 功能模块 | 说明 |
|:--------|:-----|
| **用户系统** | 登录、注册、自动登录、积分排名 |
| **内容浏览** | 首页、项目、公众号、体系四大模块 |
| **文章系统** | 文章列表、WebView 详情页、收藏管理 |
| **搜索功能** | 热门搜索、实时搜索、历史记录 |
| **交互体验** | 下拉刷新、上拉加载更多、轮播图 |
| **多标签页** | 支持滑动切换的 Tab 布局 |

### UI/UX 特性

- 🎨 统一的 Loading 状态管理（弹窗式 + 页面式）
- 🌐 完整的中英文国际化支持
- 📱 响应式布局适配不同屏幕
- 🎭 自定义状态页面（加载中、错误、空数据、成功）
- 🖼️ 图片加载缓存与占位处理
- 🔔 Toast 消息提示

### 最新特性 (v2.0+)

- ✨ **原生组件集成**：支持在 UniApp 中调用 HarmonyOS 原生组件
- ✨ **网络模块封装**：独立的 network 模块，支持拦截器和配置管理
- ✨ **Toast 工具类**：统一的 Toast 消息管理
- ✨ **LoadingDialogHelper 重构**：基于 @jxt/xt_hud，支持静态/实例双模式

## 🏗️ 项目架构

### 技术栈

| 技术 | 版本 | 用途 |
|:----|:-----|:-----|
| **ArkTS** | - | HarmonyOS 官方推荐的开发语言 |
| **ArkUI** | - | 声明式 UI 框架 |
| **@ohos/axios** | ^2.2.7 | HTTP 网络请求 |
| **@ohos/pulltorefresh** | ^3.0.0 | 下拉刷新组件 |
| **@ohos/imageknife** | ^3.2.8 | 图片加载缓存 |
| **@pura/harmony-utils** | ^1.4.0 | 工具类库 |
| **@jxt/xt_hud** | ^3.4.0 | Loading/Toast 弹窗组件 |
| **@dcloudio/uni-app-runtime** | 5.x | UniApp 运行时（支持 Vue3） |

### 模块结构

```
HarmonyStudy/
├── entry/                      # 主应用模块
│   └── src/main/
│       ├── ets/
│       │   ├── accountManager/ # 账户管理
│       │   ├── constants/      # 常量定义
│       │   ├── enum/           # 枚举类型
│       │   ├── entity/         # 实体类
│       │   ├── httpRequest/    # 网络请求封装
│       │   │   ├── configuration/  # 网络配置
│       │   │   └── interceptors/   # 拦截器
│       │   ├── native/         # 原生组件（UniApp 调用入口）
│       │   ├── model/          # 数据模型
│       │   ├── pages/          # 页面组件
│       │   ├── router/         # 路由管理
│       │   ├── utils/          # 工具类
│       │   │   ├── LoadingDialogHelper.ets
│       │   │   └── ToastUtil.ets
│       │   ├── views/          # 自定义视图组件
│       │   └── viewModel/      # 视图模型
│       └── resources/          # 资源文件
│           ├── base/element/   # 通用资源
│           ├── zh_CN/element/  # 中文资源
│           └── en_US/element/  # 英文资源
├── network/                    # 网络模块（独立封装）
├── librarySDK/                 # 工具库模块（共享组件）
├── examples/                   # 示例代码
├── docs/                       # 项目文档
└── ScreenShots/                # 界面截图
```

### 分层架构

```
┌─────────────────────────────────────┐
│         Pages (UI 表现层)             │
├─────────────────────────────────────┤
│      ViewModels (业务逻辑层)          │
├─────────────────────────────────────┤
│    Models / Network (数据/网络层)     │
├─────────────────────────────────────┤
│     Utils / Constants (基础设施层)    │
└─────────────────────────────────────┘
```

### 核心组件

| 组件/工具 | 文件位置 | 说明 |
|:---------|:---------|:-----|
| **ListDataProcessor** | `entry/src/main/ets/utils/` | 统一处理分页列表数据 |
| **StatusWeight** | `entry/src/main/ets/views/` | 页面状态管理组件 |
| **LoadingDialogHelper** | `entry/src/main/ets/utils/` | Loading 弹窗工具 |
| **ToastUtil** | `entry/src/main/ets/utils/` | Toast 消息工具 |
| **ErrorHandler** | `entry/src/main/ets/utils/` | 统一错误处理 |
| **Router** | `entry/src/main/ets/router/` | 路由管理 |
| **AccountManager** | `entry/src/main/ets/accountManager/` | 账户管理 |

## 🎬 界面预览

| 首页 | 项目 | 公众号 |
|:----:|:----:|:----:|
| ![](ScreenShots/1.jpeg) | ![](ScreenShots/2.jpeg) | ![](ScreenShots/3.jpeg) |
| *首页 Banner 轮播与文章列表* | *项目分类与文章列表* | *公众号文章浏览* |

| 体系 | 我的 |
|:----:|:----:|
| ![](ScreenShots/4.jpeg) | ![](ScreenShots/5.jpeg) |
| *知识体系树形展示* | *用户中心与积分排行* |

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

**弹窗式 Loading**（适用于登录/网络请求）：
```typescript
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

// 方式3：实例方法（兼容旧代码）
private loadingHelper = new LoadingDialogHelper('加载中...')
await this.loadingHelper.wrap(someApi())
```

**页面式 Loading**（适用于列表页面）：
```typescript
StatusWeight({
  status: this.status,
  contentBuilder: () => this.getContentView()
})
```

### Toast 消息提示

```typescript
import { ToastUtil } from '../utils/ToastUtil'

// 显示 Toast
ToastUtil.showToast('操作成功')

// 自定义时长
ToastUtil.showToast('请稍候...', 2000)
```

## 🔗 相关项目

跨平台架构系列项目：

| 平台 | 技术栈 | 仓库地址 |
|:----:|:------|:---------|
| **iOS** | RxSwift + MVVM | [RxStudy](https://github.com/seasonZhu/RxStudy) |
| **Android** | GetX + MVC | [GetXStudy](https://github.com/seasonZhu/GetXStudy) |
| **跨平台** | Vue3 + UniApp | [UniAppPlayAndroid](https://github.com/seasonZhu/UniAppPlayAndroid) |
| **HarmonyOS** | ArkTS + MVVM | [HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy) |

## 📚 文档导航

| 文档 | 说明 |
|:-----|:-----|
| [快速开始指南](docs/QUICK_START.md) | 项目入门与基本配置 |
| [网络模块使用](docs/NETWORK_USAGE.md) | 网络请求封装与拦截器 |
| [原生组件集成](docs/NATIVE_COMPONENTS_GUIDE.md) | UniApp 调用原生组件指南 |
| [Loading 迁移指南](docs/LOADING_DIALOG_MIGRATION.md) | LoadingDialogHelper v2.0 迁移文档 |
| [API 迁移指南](docs/API_MIGRATION_GUIDE.md) | API 替换与迁移记录 |
| [简单测试指南](docs/SIMPLE_TEST_GUIDE.md) | 单元测试快速入门 |

## ✅ 测试

```bash
# 运行所有测试
npm test

# 运行单元测试
npm run test:unit

# 运行 UI 测试
npm run test:ohos

# 生成测试覆盖率报告
npm run test:coverage
```

### 测试覆盖

- ✅ 单元测试：工具类、ViewModel、数据处理
- ✅ UI 测试：页面交互、路由跳转
- ✅ 集成测试：网络请求、数据流

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

**重大升级**
- 🎉 LoadingDialogHelper 基于 @jxt/xt_hud 重写
- ✅ 解决 CustomDialogController 弹窗无法显示的问题
- ✨ 新增静态方法 API（show/hide/wrap）
- ✨ 保留实例方法兼容性，现有代码无需修改

**新增功能**
- ✨ 原生组件集成支持（UniApp 调用）
- ✨ ToastUtil 统一消息管理
- ✨ 网络模块独立封装

**文档完善**
- 📚 新增完整的迁移文档
- 📚 新增快速开始指南
- 📚 新增原生组件集成文档

**依赖升级**
- ⬆️ @ohos/pulltorefresh 至 3.0.0
- ⬆️ @ohos/imageknife 至 3.2.8

### v1.4.0

- ✨ 新增完整的国际化支持（中英文）
- ✨ 新增 ListDataProcessor 统一列表数据处理
- ✨ 新增 StatusWeight 状态管理组件
- ✨ 新增 ErrorHandler 统一错误处理
- 🎨 优化 Loading 弹窗样式统一
- 🔧 重构代码结构，移除冗余工具类

更多更新记录请查看 [CHANGELOG.md](CHANGELOG.md)

## 👨‍💻 作者

- **掘金主页**：[seasonZhu](https://juejin.cn/user/4353721778057997)
- **GitHub**：[seasonZhu](https://github.com/seasonZhu)

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证

---

**如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！**
