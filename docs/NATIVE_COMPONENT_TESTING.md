# 原生组件调试 - 快速开始

## 📋 当前状态

✅ 测试组件已创建并成功编译
✅ EntryAbility 已配置为使用测试组件
⏳ 等待在 uni-app 小程序中测试

## 🚀 立即开始测试

### 步骤 1: 运行 HarmonyOS 应用

```bash
hvigorw assembleHap
```

安装到设备/模拟器并运行。

### 步骤 2: 在 uni-app 小程序中使用测试页面

复制 `examples/DebugNativeComponents.vue` 到你的 uni-app 项目中。

### 步骤 3: 观察结果

| 测试 | 预期结果 | 问题指示 |
|-----|---------|---------|
| 测试1: 最简单的组件 | 显示 "Hello from Native" | 如果失败 → runtime 问题 |
| 测试2: 带消息参数 | 显示自定义消息 | 如果失败 → 参数传递问题 |
| 测试3: 带点击回调 | 按钮可点击并触发事件 | 如果失败 → 回调函数问题 |
| 测试4: 完整按钮组件 | 显示完整按钮 | 如果失败 → 复杂结构问题 |
| 测试5: 无事件绑定 | 不报错 | 如果失败 → 默认值问题 |

## 🔍 问题定位指南

### 情况 1: 测试1就失败

**症状**: `Cannot read property observeComponentCreation2 of undefined`

**原因**: uni-app runtime 或 @dcloudio/uni-app-runtime 版本问题

**解决方案**:
1. 检查 `@dcloudio/uni-app-runtime` 版本（当前: 5.0.2026020301）
2. 尝试降级到稳定版本
3. 查阅 DCloud 官方文档
4. 向 DCloud 社区反馈

### 情况 2: 测试1-2成功，测试3失败

**症状**: 回调函数相关的错误

**原因**: 回调函数传递方式不正确

**解决方案**:
```typescript
// 正确的方式 ✅
onClickCallback: ((options as ESObject)?.['onClick'] as (() => void) | undefined)

// 错误的方式 ❌
onClickCallback: options?.on?.get('click')
```

### 情况 3: 所有测试都成功

**结论**: 原生组件机制本身工作正常

**下一步**:
对比 `SimpleNativeTest.ets` 和 `HarmonyNativeComponents.ets` 的差异，找出问题所在。

## 📊 测试组件说明

### simple-text（最简单）
```vue
<embed tag="simple-text" />
```
- 无参数
- 无回调
- 只显示文本

### text-with-message（带参数）
```vue
<embed
  tag="text-with-message"
  :options="{ message: 'Hello!' }"
/>
```
- 1个字符串参数
- 无回调

### clickable-text（带回调）
```vue
<embed
  tag="clickable-text"
  :options="{ text: '点击我' }"
  :onClick="handleClick"
/>
```
- 1个字符串参数
- 1个回调函数

### test-button（完整结构）
```vue
<embed
  tag="test-button"
  :options="{
    text: '按钮',
    type: 'primary'
  }"
  :onClick="handleClick"
/>
```
- 多个参数
- 1个回调函数
- 完整的组件结构

## 🛠️ 当前配置

### EntryAbility.ets
```typescript
// 已启用测试组件
registerSimpleTestComponents()

// 原有组件已暂时注释
// registerAllNativeComponents()
```

### 恢复原有组件
如果测试组件工作正常，可以这样恢复：

```typescript
// 方式1: 同时注册
registerSimpleTestComponents()  // 测试组件
registerAllNativeComponents()    // 原有组件

// 方式2: 只注册原有组件（修复后）
registerAllNativeComponents()
```

## 📝 关键差异对比

### 差异1: 回调函数传递

```typescript
// 测试组件（工作正常） ✅
onClickCallback: ((options as ESObject)?.['onClick'] as (() => void) | undefined)

// 原有组件（可能有问题） ❌
onButtonClick: (options?.on?.get('click') ?? (() => {})) as (detail: NativeButtonClickDetail) => void
```

**分析**:
- 测试组件直接从 options 对象获取回调
- 原有组件从 Map 中获取回调
- 可能 uni-app runtime 不支持 Map 结构

### 差异2: 参数获取

```typescript
// 测试组件 ✅
message: ((options as ESObject)?.['message'] as string) ?? 'Default'

// 原有组件 ❌
text: options.text  // 直接访问属性
```

## 🎯 下一步行动

1. **运行测试**: 在 uni-app 小程序中打开测试页面
2. **记录结果**: 哪个测试通过了，哪个失败了
3. **对比差异**: 对比测试组件和原有组件的代码差异
4. **逐步修复**: 根据测试结果逐步修复原有组件

## 📚 相关文档

- `docs/NATIVE_COMPONENT_DEBUG.md` - 详细调试指南
- `examples/DebugNativeComponents.vue` - 测试页面
- `entry/src/main/ets/native/SimpleNativeTest.ets` - 测试组件代码

---

**准备好了吗？开始测试吧！** 🚀
