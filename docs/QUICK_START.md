# 原生组件快速入门

> 🚀 3分钟上手测试原生组件

## 📁 文件说明

| 文件 | 说明 | 推荐人群 |
|-----|------|---------|
| `MinimalTest.vue` | 极简版，只有最基础的调用 | 零基础快速测试 |
| `SimpleTest.vue` | 完整版，包含3个测试 | 完整功能测试 |

## ⚡ 快速开始（3步）

### 步骤 1: 复制文件

选择一个文件复制到你的 uni-app 项目：

```bash
# 方式1: 极简版（推荐新手）
cp examples/MinimalTest.vue your-uniapp-project/pages/

# 方式2: 完整版
cp examples/SimpleTest.vue your-uniapp-project/pages/
```

### 步骤 2: 注册页面

在 `pages.json` 中添加：

```json
{
  "pages": [
    {
      "path": "pages/MinimalTest",
      "style": {
        "navigationBarTitleText": "测试"
      }
    }
  ]
}
```

### 步骤 3: 运行测试

```bash
# 1. 编译 HarmonyOS 应用
cd HarmonyStudy
hvigorw assembleHap

# 2. 安装到设备并运行

# 3. 在 uni-app 中打开页面
# 导航到 pages/MinimalTest
```

## 🎯 核心代码（就这么简单）

```vue
<template>
  <view>
    <!-- 判断平台 -->
    <view v-if="isHarmonyOS">
      <!-- 调用原生组件 -->
      <embed tag="simple-text" />
    </view>
    <view v-else>
      <text>Hello World</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      isHarmonyOS: false
    }
  },

  created() {
    const systemInfo = uni.getSystemInfoSync()
    this.isHarmonyOS = systemInfo.platform === 'harmonyos'
  }
}
</script>
```

## ✅ 成功的标志

在 HarmonyOS 平台上，你应该看到：

```
┌────────────────────────┐
│   原生组件测试         │
│                        │
│  Hello from Native     │  ← 这就是原生组件！
│                        │
│ ✅ 如果上面显示了...   │
└────────────────────────┘
```

## ❌ 失败的表现

如果看到以下内容，说明有问题：

| 表现 | 可能原因 |
|------|---------|
| 页面空白 | 组件未注册 |
| "Hello World" | 不是 HarmonyOS 平台 |
| 报错 | 查看错误信息 |

## 🔧 前置条件

### 1. HarmonyOS 宿主应用

确保 `EntryAbility.ets` 中已注册组件：

```typescript
import { registerSimpleTestComponents } from '../native/SimpleNativeTest'

onWindowStageCreate(windowStage: window.WindowStage): void {
  init(this, windowStage, { debug: true })

  // 必须有这一行
  registerSimpleTestComponents()

  windowStage.loadContent('pages/Index')
}
```

### 2. 测试组件已创建

确认文件存在：
```
entry/src/main/ets/native/SimpleNativeTest.ets
```

### 3. 编译成功

```bash
hvigorw assembleHap
# 输出: BUILD SUCCESSFUL
```

## 📖 embed 标签详解

### 基本语法

```vue
<embed tag="组件名" />
```

### 带参数

```vue
<embed
  tag="组件名"
  :options="{ 参数名: 参数值 }"
/>
```

### 带事件

```vue
<embed
  tag="组件名"
  :options="{ 参数名: 参数值 }"
  :事件名="处理函数"
/>
```

## 🎨 可用的测试组件

| 标签名 | 功能 | 需要参数 |
|-------|------|---------|
| `simple-text` | 显示文本 | ❌ 无 |
| `text-with-message` | 显示自定义消息 | ✅ message |
| `clickable-text` | 可点击按钮 | ✅ text, onClick |
| `test-button` | 完整按钮 | ✅ text, type, onClick |

## 📝 使用示例

### 示例 1: 最简单

```vue
<embed tag="simple-text" />
```

### 示例 2: 传递消息

```vue
<embed
  tag="text-with-message"
  :options="{ message: '你好！' }"
/>
```

### 示例 3: 带点击事件

```vue
<embed
  tag="clickable-text"
  :options="{ text: '点我' }"
  :onClick="handleClick"
/>

<script>
export default {
  methods: {
    handleClick() {
      console.log('被点击了！')
    }
  }
}
</script>
```

## 🆚 两个测试文件对比

| 特性 | MinimalTest.vue | SimpleTest.vue |
|-----|----------------|----------------|
| 代码量 | ~80 行 | ~250 行 |
| 测试组件 | 1 个 | 3 个 |
| 界面美观度 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 适合场景 | 快速验证 | 完整测试 |
| 推荐人群 | 新手 | 所有用户 |

## 🔍 调试技巧

### 查看系统信息

```javascript
created() {
  const systemInfo = uni.getSystemInfoSync()
  console.log('平台:', systemInfo.platform)
  console.log('系统:', systemInfo.system)
  console.log('完整信息:', JSON.stringify(systemInfo, null, 2))
}
```

### 检查组件是否注册

在 HarmonyOS 应用的 `onWindowStageCreate` 中：

```typescript
onWindowStageCreate(windowStage: window.WindowStage): void {
  init(this, windowStage, { debug: true })
  registerSimpleTestComponents()  // ← 必须有
}
```

## 💡 下一步

测试成功后，你可以：

1. ✅ 了解原生组件的基本使用方式
2. ✅ 创建自己的原生组件
3. ✅ 集成到实际项目中
4. ✅ 参考完整示例扩展功能

## 📚 相关文档

- [详细使用指南](./SIMPLE_TEST_GUIDE.md)
- [调试指南](./NATIVE_COMPONENT_DEBUG.md)
- [测试组件源码](../entry/src/main/ets/native/SimpleNativeTest.ets)

---

**准备好了吗？开始测试吧！** 🚀

有问题？查看 `docs/NATIVE_COMPONENT_DEBUG.md` 获取帮助。
