# 原生嵌入组件调试指南

> **目标**: 使用最小排除法定位 `Cannot read property observeComponentCreation2 of undefined` 错误

## 问题分析

### 错误信息
```
Error message: Cannot read property observeComponentCreation2 of undefined
Stacktrace:
    at NativeButtonBuilder entry (HarmonyNativeComponents.ets:243:30)
    at builder entry (HarmonyNativeComponents.ets:695:7)
```

### 可能的原因

1. **uni-app runtime 问题**
   - runtime 调用 builder 时传递的 options 格式不符合预期
   - runtime 对 builder 函数的签名有特殊要求
   - runtime 与 @dcloudio/uni-app-runtime 版本不兼容

2. **组件参数问题**
   - @Prop 装饰的属性接收 undefined 时处理不当
   - 必需参数未传递导致组件初始化失败
   - 参数类型不匹配

3. **Builder 函数问题**
   - 返回类型不符合 runtime 要求
   - 内部调用了 runtime 不支持的 API
   - 缺少必要的上下文

## 调试策略

使用**最小排除法**，从最简单的组件开始，逐步增加复杂度：

### 测试组件清单

| 测试 | 组件名 | 参数 | 回调 | 目的 |
|-----|-------|------|------|------|
| 测试1 | `simple-text` | 无 | 无 | 验证最基本的组件能否工作 |
| 测试2 | `text-with-message` | 1个字符串 | 无 | 验证参数传递是否正常 |
| 测试3 | `clickable-text` | 1个字符串 | 1个函数 | 验证回调函数是否正常 |
| 测试4 | `test-button` | 多个参数 | 1个函数 | 验证完整结构是否正常 |
| 测试5 | 无事件绑定 | 多个参数 | 无 | 验证不绑定事件是否报错 |

## 使用步骤

### 1. 编译并运行

```bash
# 编译 HarmonyOS 应用
hvigorw assembleHap

# 安装到设备/模拟器
# 然后打开 uni-app 小程序
```

### 2. 在 uni-app 小程序中使用测试页面

将 `examples/DebugNativeComponents.vue` 复制到你的 uni-app 项目中，并在 `pages.json` 中注册：

```json
{
  "pages": [
    {
      "path": "pages/debug-native-components",
      "style": {
        "navigationBarTitleText": "原生组件调试"
      }
    }
  ]
}
```

### 3. 观察测试结果

**如果测试1失败**：
- ❌ 说明是 uni-app runtime 或 @dcloudio/uni-app-runtime 的问题
- ✅ 需要检查 runtime 版本兼容性

**如果测试1成功，测试2失败**：
- ❌ 说明是参数传递的问题
- ✅ 需要调整 options 的处理方式

**如果测试1-2成功，测试3失败**：
- ❌ 说明是回调函数的问题
- ✅ 需要检查回调函数的绑定方式

**如果测试1-3成功，测试4失败**：
- ❌ 说明是复杂参数结构的问题
- ✅ 需要简化参数结构

**如果测试1-4成功，测试5失败**：
- ❌ 说明是不绑定事件时的问题
- ✅ 需要为所有回调提供默认值

### 4. 查看日志

```javascript
// 在 uni-app 小程序中
console.log('=== 开始测试 ===')
console.log('系统信息:', uni.getSystemInfoSync())

// 在 HarmonyOS 宿主应用中
LogUtil.debug('Builder 被调用，options:', JSON.stringify(options))
```

## 测试组件代码

### 组件1: 最简单的组件

```typescript
@Component
export struct SimpleTextComponent {
  build() {
    Text('Hello from Native')
      .fontSize(20)
  }
}

@Builder
function SimpleTextBuilder(options: ESObject) {
  SimpleTextComponent()
}
```

### 组件2: 带参数的组件

```typescript
@Component
export struct TextWithMessageComponent {
  @Prop message: string = 'Default';

  build() {
    Text(this.message)
      .fontSize(18)
  }
}

@Builder
function TextWithMessageBuilder(options: ESObject) {
  const message = (options as ESObject)?.['message'] as string ?? 'Default';
  TextWithMessageComponent({ message })
}
```

### 组件3: 带回调的组件

```typescript
@Component
export struct ClickableTextComponent {
  @Prop text: string = 'Click Me';
  onClickCallback?: () => void;

  build() {
    Button(this.text)
      .onClick(() => {
        if (this.onClickCallback) {
          this.onClickCallback();
        }
      })
  }
}

@Builder
function ClickableTextBuilder(options: ESObject) {
  const text = (options as ESObject)?.['text'] as string ?? 'Click Me';
  const onClick = (options as ESObject)?.['onClick'] as (() => void);

  ClickableTextComponent({
    text,
    onClickCallback: onClick ?? undefined
  })
}
```

## uni-app 小端使用示例

```vue
<template>
  <view>
    <!-- 测试1: 最简单的组件 -->
    <embed tag="simple-text" />

    <!-- 测试2: 带参数 -->
    <embed
      tag="text-with-message"
      :options="{ message: 'Hello!' }"
    />

    <!-- 测试3: 带回调 -->
    <embed
      tag="clickable-text"
      :options="{ text: '点击我' }"
      :onClick="handleClick"
    />

    <!-- 测试4: 完整参数 -->
    <embed
      tag="test-button"
      :options="{
        text: '按钮',
        type: 'primary'
      }"
      :onClick="handleButtonClick"
    />
  </view>
</template>

<script>
export default {
  methods: {
    handleClick() {
      console.log('点击了可点击文本')
    },
    handleButtonClick() {
      console.log('点击了测试按钮')
    }
  }
}
</script>
```

## 预期结果

### ✅ 成功的情况

```
[页面显示]
🔍 原生组件调试页面
━━━━━━━━━━━━━━━━━━━━━━━
测试1: 最简单的组件
Hello from Native ✅

测试2: 带消息参数
Hello from uni-app! ✅

测试3: 带点击回调
[点击测试按钮] ✅

测试4: 完整按钮组件
[完整测试按钮] ✅
```

### ❌ 失败的情况

如果测试1就报错，说明是更底层的问题：

```
Error: Cannot read property observeComponentCreation2 of undefined
```

**这意味着**：
- uni-app runtime 调用 builder 时出了问题
- 可能是版本不兼容
- 可能需要特殊的 builder 签名

## 下一步行动

### 如果所有测试都通过

说明原生组件本身没问题，问题出在原有的 `HarmonyNativeComponents.ets` 中。需要：

1. 对比测试组件和原有组件的差异
2. 逐步修复原有组件

### 如果测试1就失败

说明是 runtime 或版本问题，需要：

1. 检查 `@dcloudio/uni-app-runtime` 版本
2. 查看 uni-app runtime 官方文档
3. 尝试降级或升级 runtime 版本
4. 向 DCloud 社区提问

### 如果某个中间测试失败

说明问题出在特定的功能点：

- **测试2失败**: 参数传递问题
- **测试3失败**: 回调函数问题
- **测试4失败**: 复杂结构问题

针对性地修复该问题点。

## 相关文件

| 文件 | 说明 |
|-----|------|
| `entry/src/main/ets/native/SimpleNativeTest.ets` | 测试组件定义 |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 组件注册入口 |
| `examples/DebugNativeComponents.vue` | uni-app 测试页面 |
| `entry/src/main/ets/native/HarmonyNativeComponents.ets` | 原有组件（暂时注释） |

## 联系支持

如果问题依然无法解决，请收集以下信息：

1. 系统信息截图
2. 完整的错误堆栈
3. 哪个测试失败了
4. @dcloudio/uni-app-runtime 版本号
5. DevEco Studio 版本

然后：
- 查阅 [DCloud 社区](https://ask.dcloud.net.cn/)
- 提交 [GitHub Issue](https://github.com/dcloudio/uni-app/issues)

---

**调试愉快！🎯**
