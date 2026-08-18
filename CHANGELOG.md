# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-05

### Added
- LoadingDialogHelper 静态方法 API (show/hide/wrap)
- 全局 UIContext 初始化支持
- @jxt/xt_hud 依赖 (^3.4.0)
- 完整的迁移文档 (docs/LOADING_DIALOG_MIGRATION.md)
- WebPage 收藏功能 Loading 弹窗支持

### Changed
- LoadingDialogHelper 从 CustomDialogController 重写为基于 @jxt/xt_hud 的实现
- 保留实例方法兼容性，现有代码无需修改
- 升级 @ohos/pulltorefresh 从 ^2.0.5 到 ^3.0.0
- 升级 @ohos/imageknife 从 ^3.1.0 到 ^3.2.8
- 升级 @dcloudio/uni-app-runtime 从 4.84.2025110301 到 5.0.2026020301

### Fixed
- 修复 CustomDialogController 弹窗无法显示的问题
- 修复 UIContext 绑定问题导致的弹窗显示失败

### Technical Details
- **根本原因**: CustomDialogController 必须在正确的 UI 上下文中创建
- **解决方案**: 使用 @jxt/xt_hud 库，通过全局初始化 UIContext
- **影响范围**: 6 个页面文件（Login, Register, WebPage, Home, Setting, TabScaffold）
- **兼容性**: 完全向后兼容，现有代码无需修改

## [1.4.0] - 2025-XX-XX

### Added
- 完整的国际化支持（中英文）
- ListDataProcessor 统一列表数据处理
- StatusWeight 状态管理组件
- ErrorHandler 统一错误处理工具类

### Changed
- 优化 Loading 弹窗样式统一

### Removed
- BaseViewModel 空类（YAGNI 原则）

### Fixed
- 修复多个 TODO 错误处理问题
- 修复 LoginViewModel 类型安全问题

## [1.0.0] - 2024-XX-XX

### Added
- 首次发布
- 五大模块：首页、项目、公众号、体系、我的
- 用户系统：登录、注册、自动登录
- 搜索功能：热门搜索、实时搜索
- 文章系统：文章列表、WebView 详情页
- 交互体验：下拉刷新、上拉加载更多
- 收藏管理：文章收藏/取消收藏

---

## 版本说明

### 语义化版本控制 (Semantic Versioning)

```
主版本号.次版本号.修订号 (MAJOR.MINOR.PATCH)

MAJOR: 不兼容的 API 变更
MINOR: 向下兼容的功能新增
PATCH: 向下兼容的问题修复
```

### 版本示例

- `2.0.0` - 重大架构升级（LoadingDialogHelper 重写）
- `1.4.0` - 新增功能（国际化、状态管理）
- `1.0.0` - 首次发布

---

## 链接

- [迁移文档](./docs/LOADING_DIALOG_MIGRATION.md) - LoadingDialogHelper 迁移指南
- [API 迁移指南](./docs/API_MIGRATION_GUIDE.md) - 废弃 API 迁移方案
- [README](./README.md) - 项目介绍
