# @Entry 装饰器最佳实践指南

## 问题概述

### 告警信息
```
It's not a recommended way to export struct with '@Entry' decorator,
which may cause ACE Engine error in component preview mode.
<ArkTSCheck>
```

### 根本原因

在 ArkTS 中，`@Entry` 装饰器标记组件为应用入口点，需要 ACE 引擎特殊处理。同时使用 `@Entry` 和 `export` 修饰符可能导致：

1. **组件预览模式冲突** - DevEco Studio 预览时可能出现初始化错误
2. **编译器警告** - ArkTSCheck 静态检查工具会发出警告
3. **潜在运行时问题** - 在某些场景下可能导致页面加载异常

---

## 修复方案

### ❌ 不推荐的写法（有问题）

```typescript
@Entry({routeName: RouterName.WebExample})
@Component
export struct WebExample {
  // 组件实现...
}
```

### ✅ 推荐写法（正确）

```typescript
// 先声明为入口组件
@Entry({routeName: RouterName.WebExample})
@Component
struct WebExample {
  // 组件实现...
}

// 然后单独导出
export { WebExample }
```

### 替代方案：使用默认导出

```typescript
@Entry({routeName: RouterName.WebExample})
@Component
export default struct WebExample {
  // 组件实现...
}
```

---

## 已修复文件清单

### entry 模块

| 文件路径 | 说明 |
|---------|------|
| `entry/src/main/ets/pages/WebExample.ets` | Web 与原生交互示例页 |
| `entry/src/main/ets/pages/Home.ets` | 首页 |
| `entry/src/main/ets/pages/Tree.ets` | 体系页 |
| `entry/src/main/ets/pages/My.ets` | 我的页 |
| `entry/src/main/ets/pages/TabsDetail.ets` | 标签详情页 |
| `entry/src/main/ets/pages/TabScaffold.ets` | 标签容器页 |
| `entry/src/main/ets/pages/ObservedV2TestPage.ets` | 状态管理测试页 |

### librarySDK 模块

| 文件路径 | 说明 |
|---------|------|
| `librarySDK/src/main/ets/components/MainPage.ets` | SDK 主页 |
| `librarySDK/src/main/ets/components/SecondPage.ets` | SDK 次页 |

---

## 技术原理

### 为什么需要分离？

1. **编译器处理顺序** - `@Entry` 装饰器需要在编译时先被处理，生成页面注册代码
2. **模块导出时机** - `export` 是 ES6 模块系统的关键字，在编译后的阶段处理
3. **组件预览机制** - DevEco Studio 的预览功能需要单独的入口声明，不依赖于模块导出

### 最佳实践

| 场景 | 推荐写法 |
|------|---------|
| 仅作为页面入口 | `@Entry @Component struct Name {}`（无需 export） |
| 页面入口 + 需要被其他模块引用 | 分离声明和导出 |
| 纯 UI 组件（非入口） | `@Component export struct Name {}`（无需 @Entry） |

---

## 验证方法

### 1. 检查编译警告
修复后，DevEco Studio 中不应再出现 `<ArkTSCheck>` 相关警告。

### 2. 验证组件预览
打开任意修复后的页面文件，点击预览按钮，确认能正常预览。

### 3. 运行时测试
```bash
# 清理构建缓存
hvigorw clean

# 重新构建
hvigorw assembleHap

# 运行应用测试各页面跳转
```

---

## 相关参考

- [HarmonyOS 页面路由官方文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/navigation-routing-V5)
- [ArkTS 装饰器官方文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-builder-V5)
