# 如何在 uni-app 中使用 SimpleTest.vue

## 📋 快速步骤

### 步骤 1: 复制文件到 uni-app 项目

将 `examples/SimpleTest.vue` 复制到你的 uni-app 项目的 `pages` 目录：

```bash
# 假设你的 uni-app 项目结构如下
your-uniapp-project/
├── pages/
│   └── index/
│       └── index.vue
└── pages.json

# 复制文件
cp examples/SimpleTest.vue your-uniapp-project/pages/
```

### 步骤 2: 在 pages.json 中注册页面

打开 `pages.json`，添加新页面：

```json
{
  "pages": [
    {
      "path": "pages/index/index",
      "style": {
        "navigationBarTitleText": "首页"
      }
    },
    {
      "path": "pages/SimpleTest",
      "style": {
        "navigationBarTitleText": "原生组件测试",
        "navigationStyle": "default"
      }
    }
  ]
}
```

### 步骤 3: 运行 HarmonyOS 宿主应用

```bash
# 在 HarmonyStudy 项目目录
hvigorw assembleHap

# 安装到设备/模拟器
# 然后运行应用
```

### 步骤 4: 在 uni-app 中打开页面

在首页或其他页面添加跳转按钮：

```vue
<template>
  <view>
    <button @click="goToTest">测试原生组件</button>
  </view>
</template>

<script>
export default {
  methods: {
    goToTest() {
      uni.navigateTo({
        url: '/pages/SimpleTest'
      })
    }
  }
}
</script>
```

## 🔍 测试内容

### 测试1: 最简单的组件

```vue
<embed tag="simple-text" />
```

**预期结果**: 显示 "Hello from Native" 文本

**如果失败**: 说明 uni-app runtime 或组件注册有问题

---

### 测试2: 带消息的组件

```vue
<embed
  tag="text-with-message"
  :options="{ message: 'Hello from uni-app 小程序！' }"
/>
```

**预期结果**: 显示自定义消息和 "Native Component Works!"

**如果失败**: 说明参数传递有问题

---

### 测试3: 带回调的组件

```vue
<embed
  tag="clickable-text"
  :options="{ text: '点击我试试' }"
  :onClick="handleClick"
/>
```

**预期结果**: 点击按钮显示 Toast 提示

**如果失败**: 说明回调函数传递有问题

## 🎯 核心代码说明

### 1. 平台检测

```javascript
created() {
  const systemInfo = uni.getSystemInfoSync()
  this.platform = systemInfo.platform

  // 判断是否是 HarmonyOS
  this.isHarmonyOS = systemInfo.platform === 'harmonyos' ||
                    (systemInfo.system && systemInfo.system.toLowerCase().includes('harmonyos'))
}
```

### 2. 条件渲染

```vue
<!-- HarmonyOS: 显示原生组件 -->
<view v-if="isHarmonyOS">
  <embed tag="simple-text" />
</view>

<!-- 其他平台: 显示替代内容 -->
<view v-else>
  <text>Hello World</text>
</view>
```

### 3. 调用原生组件

```vue
<!-- 无参数 -->
<embed tag="simple-text" />

<!-- 有参数 -->
<embed
  tag="text-with-message"
  :options="{ message: 'Hello!' }"
/>

<!-- 有回调 -->
<embed
  tag="clickable-text"
  :options="{ text: '点击我' }"
  :onClick="handleClick"
/>
```

## 📊 预期效果

### 在 HarmonyOS 平台

```
┌─────────────────────────────┐
│      🔍 原生组件测试        │
│    当前平台: harmonyos      │
└─────────────────────────────┘

┌─────────────────────────────┐
│ 测试1: 最简单的组件         │
│ 无参数、无回调，只显示文本  │
│                             │
│  ┌───────────────────────┐ │
│  │  Hello from Native   │ │
│  └───────────────────────┘ │
│                             │
│ ✅ 组件工作正常！          │
└─────────────────────────────┘
```

### 在其他平台（iOS/Android/Web）

```
┌─────────────────────────────┐
│      🔍 原生组件测试        │
│    当前平台: ios           │
└─────────────────────────────┘

┌─────────────────────────────┐
│                             │
│       Hello World          │
│                             │
│   当前平台: ios            │
│   原生组件仅在 HarmonyOS   │
│   平台可用                 │
│                             │
└─────────────────────────────┘
```

## 🛠️ 调试技巧

### 1. 查看控制台日志

```javascript
created() {
  const systemInfo = uni.getSystemInfoSync()
  console.log('=== 系统信息 ===', systemInfo)
  console.log('平台:', systemInfo.platform)
  console.log('系统:', systemInfo.system)
}
```

### 2. 测试组件是否注册

在 HarmonyOS 宿主应用的 `EntryAbility.ets` 中：

```typescript
onWindowStageCreate(windowStage: window.WindowStage): void {
  init(this, windowStage, { debug: true })

  // 必须调用注册函数
  registerSimpleTestComponents()

  windowStage.loadContent('pages/Index')
}
```

### 3. 验证组件标签

确保使用的标签名称与注册时一致：

```typescript
// 注册时
defineNativeEmbed('simple-text', { builder: SimpleTextBuilder })

// 使用时 ✅
<embed tag="simple-text" />

// 使用时 ❌ (错误：标签名不匹配)
<embed tag="simpleText" />
```

## ❓ 常见问题

### Q1: 页面显示空白？

**检查项**：
1. 确认宿主应用已运行
2. 确认 `registerSimpleTestComponents()` 已调用
3. 查看控制台是否有错误

### Q2: 显示 "Hello World" 而不是原生组件？

**原因**: 当前不是 HarmonyOS 平台

**解决**: 在 HarmonyOS 设备/模拟器上运行

### Q3: 点击按钮没有反应？

**检查项**：
1. 确认 `:onClick` 已正确绑定
2. 查看 `handleClick` 方法是否定义
3. 查看控制台是否有错误

### Q4: 报错 "Cannot read property observeComponentCreation2"？

**说明**: 这是我们要排查的问题！

**操作**:
1. 记录完整的错误堆栈
2. 记录哪个测试失败了
3. 查看控制台的系统信息

## 📝 测试清单

使用此清单记录测试结果：

- [ ] 测试1: 最简单的组件是否显示 "Hello from Native"？
- [ ] 测试2: 带消息的组件是否显示自定义消息？
- [ ] 测试3: 可点击的组件点击后是否触发 Toast？
- [ ] 当前平台是否正确识别为 HarmonyOS？

## 🎓 学习要点

### embed 标签语法

```vue
<!-- 基本语法 -->
<embed
  tag="组件标签名"
  :options="{ /* 组件参数 */ }"
  @事件名="处理函数"
/>

<!-- 示例 -->
<embed
  tag="clickable-text"
  :options="{ text: '按钮文字' }"
  :onClick="handleClick"
/>
```

### 参数传递

```vue
<!-- 字符串参数 -->
:options="{ message: 'Hello' }"

<!-- 多个参数 -->
:options="{ text: '按钮', type: 'primary' }"

<!-- 带回调 -->
:options="{ text: '按钮' }"
:onClick="handleClick"
```

### 事件处理

```javascript
methods: {
  handleClick() {
    console.log('按钮被点击')
    uni.showToast({
      title: '点击成功',
      icon: 'success'
    })
  }
}
```

---

**祝你测试顺利！** 🚀

如有问题，请查看控制台日志或参考 `docs/NATIVE_COMPONENT_DEBUG.md`。
