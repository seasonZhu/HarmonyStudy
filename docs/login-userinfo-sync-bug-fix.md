# 登录后用户信息不更新 Bug 修复

## Bug 描述

**现象：** 登录成功后，"我的"页面中的排名、等级、积分数据显示为 `--`，没有更新为实际数据。

**影响范围：** 手动登录和自动登录两种场景

## 问题分析

### 原始代码结构

```
Index.ets (@Provide loginSuccessUserInfo, @State userInfo)
  ↓
My.ets (@Prop userInfo, @Consume @Watch("update") loginSuccessUserInfo)
  ↓
MyHeader.ets (@Prop userInfo)
```

### 根本原因

**My.ets:105-107** 中的 `update()` 方法试图给 `@Prop` 变量赋值：

```typescript
update() {
  this.userInfo = this.loginSuccessUserInfo  // ❌ @Prop 是只读的！
}
```

**核心问题：** `@Prop` 装饰的变量是**只读**的，不能在子组件中修改。即使 `@Watch("update")` 监听到了 `loginSuccessUserInfo` 的变化，赋值操作也不会生效。

### 数据流分析

| 场景 | 数据流 | 问题 |
|------|--------|------|
| 手动登录 | Login → Router.backWithParams → Index.onPageShow() → 更新 loginSuccessUserInfo → My.update() 失败 | `@Prop` 赋值无效 |
| 自动登录 | Index.aboutToAppear() → 更新 userInfo → 未更新 loginSuccessUserInfo | 数据未同步到 My 页面 |

## 修复方案

### 核心思路

**删除冗余的中间变量，直接使用 `@Consume` 实现数据同步。**

### 修复后的数据流

```
Index (@Provide loginSuccessUserInfo)
  ↓ 自动同步
My (@Consume loginSuccessUserInfo)
  ↓ @Prop 传递
MyHeader (@Prop userInfo)
```

### 代码变更

#### 1. My.ets - 简化数据接收

**修改前：**
```typescript
@Prop userInfo: UserInfoModel

@Consume
@Watch("update")
loginSuccessUserInfo: UserInfoModel

// 无效的更新方法
update() {
  this.userInfo = this.loginSuccessUserInfo  // ❌ 不生效
}

// 使用旧数据
MyHeader({userInfo: this.userInfo})
```

**修改后：**
```typescript
// 删除 @Prop 和 @Watch
@Consume
loginSuccessUserInfo: UserInfoModel

// 直接使用最新数据
MyHeader({userInfo: this.loginSuccessUserInfo})
```

#### 2. Index.ets - 修复自动登录场景

**修改前：**
```typescript
@State userInfo: UserInfoModel = {}
@Provide loginSuccessUserInfo: UserInfoModel = {}

// 自动登录成功后只更新 userInfo
if (result) {
  let response = await this.viewModel.getUserInfo()
  this.userInfo = response.data.data  // ❌ My 页面看不到
}
```

**修改后：**
```typescript
@State userInfo: UserInfoModel = {}
@Provide loginSuccessUserInfo: UserInfoModel = {}

// 同时更新两个变量
if (result) {
  let response = await this.viewModel.getUserInfo()
  this.userInfo = response.data.data
  this.loginSuccessUserInfo = response.data.data  // ✅ 同步到 My 页面
}

// My 组件不再传递参数
My()  // 移除 {userInfo: this.userInfo}
```

## @Provide/@Consume 原理

### 装饰器作用

| 装饰器 | 使用位置 | 作用 |
|--------|----------|------|
| `@Provide` | 祖先组件 | 向后代组件"提供"可观测的状态变量 |
| `@Consume` | 后代组件 | 从祖先组件"消费"状态变量 |

### 工作机制

```
Index (@Provide loginSuccessUserInfo)
  │
  ├── TabContent
  │
  └── My (@Consume loginSuccessUserInfo)
      │
      └── MyHeader
```

**关键点：**

1. **按名称匹配**：相同的变量名 `loginSuccessUserInfo` 自动建立绑定
2. **跨层级同步**：不受组件嵌套深度限制
3. **自动响应**：`@Provide` 变化时，所有 `@Consume` 自动更新

### 数据同步流程

```typescript
// Index.ets - 数据源
@Provide loginSuccessUserInfo: UserInfoModel = {}

// 数据更新
this.loginSuccessUserInfo = newUserData
  ↓
// ArkUI 框架检测到 @Provide 变化
  ↓
// 查找所有同名 @Consume 变量
  ↓
// My.ets - 自动同步更新
@Consume loginSuccessUserInfo: UserInfoModel  // 自动获取最新值
```

### vs 传统 Props 传递

**传统方式（繁琐）：**
```typescript
// 需要每一层都传递
Index ({userInfo: this.userInfo})
  → Tabs ({userInfo: userInfo})
    → TabContent ({userInfo: userInfo})
      → My ({userInfo: userInfo})
```

**@Provide/@Consume 方式（简洁）：**
```typescript
// 跨层级直接同步
Index @Provide
  → My @Consume  // 无需中间层传递
```

## 修复效果

### 场景 1：手动登录
```
用户输入账号密码
  → Login 页面登录成功
  → Router.backWithParams 传递用户信息
  → Index.onPageShow() 接收并更新 loginSuccessUserInfo
  → My 页面通过 @Consume 自动同步
  → MyHeader 显示最新数据 ✅
```

### 场景 2：自动登录
```
应用启动
  → Index.aboutToAppear() 检测本地账号密码
  → 自动登录并获取用户信息
  → 同时更新 userInfo 和 loginSuccessUserInfo
  → My 页面通过 @Consume 自动同步
  → MyHeader 显示最新数据 ✅
```

## 最佳实践

### ✅ 推荐做法

1. **跨层级状态传递使用 @Provide/@Consume**
   ```typescript
   // 祖先组件
   @Provide appState: AppState = {}

   // 后代组件（任意层级）
   @Consume appState: AppState
   ```

2. **父子组件直接通信使用 @Prop/@Link**
   ```typescript
   // 父组件
   Child({count: this.count})

   // 子组件
   @Prop count: number
   ```

3. **子组件向父组件通信使用事件回调**
   ```typescript
   // 父组件
   Child({onValueChange: (value) => { this.parentValue = value }})

   // 子组件
   onValueChange: (value: number) => void = () => {}

   // 触发
   this.onValueChange(newValue)
   ```

### ❌ 避免做法

1. **不要尝试修改 @Prop 变量**
   ```typescript
   @Prop data: UserData

   // ❌ 这样不会生效
   this.data = newData

   // ✅ 应该通过父组件更新或使用 @Link
   ```

2. **不要过度使用 @Provide/@Consume**
   - 仅用于真正的跨层级状态共享
   - 简单的父子传递优先使用 @Prop

3. **不要混用多种状态传递方式**
   - 保持清晰的数据流向
   - 避免状态管理混乱

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `entry/src/main/ets/pages/My.ets` | 删除 `@Prop userInfo`、`@Watch("update")`、`update()` 方法 |
| `entry/src/main/ets/pages/Index.ets:87` | 移除传递给 `My` 的 `userInfo` 参数 |
| `entry/src/main/ets/pages/Index.ets:103` | 新增 `this.loginSuccessUserInfo = response.data.data` |
| `entry/src/main/ets/entryability/EntryAbility.ets:8` | 修正 `NetworkProvider` 导入路径 |
| `entry/src/main/ets/network/examples/pages/NetworkExamplePage.ets:7` | 修正 `NetworkProvider` 导入路径 |

## 相关概念

### ArkUI 状态管理装饰器对比

| 装饰器 | 方向 | 作用域 | 可变性 |
|--------|------|--------|--------|
| `@State` | - | 当前组件 | 可变 |
| `@Prop` | 父→子 | 父子 | 只读 |
| `@Link` | 双向 | 父子 | 可变 |
| `@Provide` | 祖先→后代 | 跨层级 | 可变 |
| `@Consume` | 祖先→后代 | 跨层级 | 可变 |
| `@Watch` | - | 监听变化 | - |

### DRY 原则应用

本次修复遵循 **DRY（Don't Repeat Yourself）** 原则：

- **删除冗余**：移除了不必要的 `userInfo` 中间变量和 `update()` 方法
- **单一数据源**：使用 `loginSuccessUserInfo` 作为唯一数据源
- **框架自动化**：利用 ArkUI 的 `@Provide/@Consume` 自动同步机制

---

**文档版本：** v1.0
**创建日期：** 2026-02-03
**相关文件：**
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/pages/My.ets`
- `entry/src/main/ets/views/MyHeader.ets`
- `entry/src/main/ets/pages/Login.ets`
