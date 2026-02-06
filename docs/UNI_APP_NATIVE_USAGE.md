# uni-app 中使用 HarmonyOS 原生嵌入组件指南

> **版本**: v1.0.0
> **更新日期**: 2026-02-06

## 目录

- [快速开始](#快速开始)
- [平台检测](#平台检测)
- [组件使用](#组件使用)
- [完整示例](#完整示例)
- [常见问题](#常见问题)

---

## 快速开始

### 1. 前置条件

确保你的 HarmonyOS 宿主应用已经注册了原生组件：

```typescript
// EntryAbility.ets
import { registerAllNativeComponents } from '../native/HarmonyNativeComponents'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 初始化 uni-app runtime
    init(this, windowStage, { debug: true })

    // 注册原生组件（必须）
    registerAllNativeComponents()

    windowStage.loadContent('pages/Index')
  }
}
```

### 2. 创建 uni-app 页面

在 uni-app 项目中创建 Vue 页面，使用 `<embed>` 标签调用原生组件：

```vue
<template>
  <view class="container">
    <!-- 判断平台 -->
    <view v-if="isHarmonyOS">
      <!-- HarmonyOS: 使用原生组件 -->
      <embed
        tag="native-button"
        :options="buttonOptions"
        @click="handleClick"
      />
    </view>
    <view v-else>
      <!-- 其他平台: 显示替代内容 -->
      <text>Hello World</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      isHarmonyOS: false,
      buttonOptions: {
        text: '点击我',
        type: 'primary',
        width: 300,
        height: 50
      }
    }
  },

  created() {
    // 检测平台
    const systemInfo = uni.getSystemInfoSync()
    this.isHarmonyOS = systemInfo.platform === 'harmonyos'
  },

  methods: {
    handleClick(e) {
      console.log('按钮点击:', e.detail)
    }
  }
}
</script>
```

---

## 平台检测

### 方法一：通过 platform 字段

```javascript
const systemInfo = uni.getSystemInfoSync()
const isHarmonyOS = systemInfo.platform === 'harmonyos'
```

### 方法二：通过 system 字段

```javascript
const systemInfo = uni.getSystemInfoSync()
const isHarmonyOS = systemInfo.system?.toLowerCase().includes('harmonyos')
```

### 方法三：综合判断（推荐）

```javascript
function checkIsHarmonyOS(systemInfo) {
  // 1. 检查 platform
  if (systemInfo.platform === 'harmonyos') {
    return true
  }

  // 2. 检查 system 字符串
  if (systemInfo.system?.toLowerCase().includes('harmonyos')) {
    return true
  }

  // 3. 检查品牌 + 系统
  if ((systemInfo.brand === 'HUAWEI' || systemInfo.brand === 'HONOR') &&
      systemInfo.system?.toLowerCase().includes('harmonyos')) {
    return true
  }

  return false
}

// 使用
const systemInfo = uni.getSystemInfoSync()
const isHarmonyOS = checkIsHarmonyOS(systemInfo)
```

### 系统信息示例

```javascript
{
  brand: "HUAWEI",
  model: "NEXT",
  platform: "harmonyos",     // 关键字段
  system: "HarmonyOS NEXT 5.0",
  screenWidth: 1080,
  screenHeight: 2400,
  SDKVersion: "API 12"
}
```

---

## 组件使用

### 1. 原生按钮 (native-button)

#### 功能
- 多种主题色（primary/success/warning/danger）
- 防抖处理（500ms）
- 触觉反馈

#### 使用示例

```vue
<template>
  <embed
    tag="native-button"
    :options="{
      text: '提交',
      type: 'primary',
      disabled: false,
      width: 300,
      height: 50
    }"
    @click="onClick"
  />
</template>

<script>
export default {
  methods: {
    onClick(e) {
      const detail = e.detail || e
      console.log('按钮类型:', detail.type)
      console.log('按钮文字:', detail.text)
      console.log('时间戳:', detail.timestamp)
    }
  }
}
</script>
```

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| text | string | 是 | - | 按钮文字 |
| type | string | 否 | 'primary' | 按钮类型：primary/success/warning/danger |
| disabled | boolean | 否 | false | 是否禁用 |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

#### 事件

| 事件名 | 说明 | 返回值 |
|--------|------|--------|
| click | 点击事件 | { type, text, timestamp } |

---

### 2. 相机组件 (native-camera)

#### 功能
- 调用系统相册
- 获取图片信息

#### 使用示例

```vue
<template>
  <view>
    <embed
      tag="native-camera"
      :options="{
        quality: 80,
        edit: false,
        width: 200,
        height: 200
      }"
      @result="onCameraResult"
    />

    <image v-if="selectedImage" :src="selectedImage" />
  </view>
</template>

<script>
export default {
  data() {
    return {
      selectedImage: ''
    }
  },

  methods: {
    onCameraResult(e) {
      const detail = e.detail || e
      if (detail.success) {
        this.selectedImage = detail.uri
        console.log('图片尺寸:', detail.width, 'x', detail.height)
        console.log('图片大小:', detail.size)
      } else {
        console.error('选择失败:', detail.errorMessage)
      }
    }
  }
}
</script>
```

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| quality | number | 否 | 80 | 图片质量（1-100） |
| edit | boolean | 否 | false | 是否允许编辑 |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

#### 事件

| 事件名 | 说明 | 返回值 |
|--------|------|--------|
| result | 选择结果 | { success, uri, width, height, size, errorMessage } |

---

### 3. 定位组件 (native-location)

#### 使用示例

```vue
<template>
  <embed
    tag="native-location"
    :options="{
      accuracy: 'high',
      timeout: 10000,
      width: 200,
      height: 200
    }"
    @result="onLocationResult"
  />
</template>

<script>
export default {
  methods: {
    onLocationResult(e) {
      const detail = e.detail || e
      if (detail.success) {
        console.log('纬度:', detail.latitude)
        console.log('经度:', detail.longitude)
        console.log('地址:', detail.address)
      }
    }
  }
}
</script>
```

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| accuracy | string | 否 | 'medium' | 定位精度：low/medium/high |
| timeout | number | 否 | 10000 | 超时时间（毫秒） |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

---

### 4. 扫码组件 (native-scanner)

#### 使用示例

```vue
<template>
  <embed
    tag="native-scanner"
    :options="{
      scanType: 'all',
      width: 200,
      height: 200
    }"
    @result="onScannerResult"
  />
</template>

<script>
export default {
  methods: {
    onScannerResult(e) {
      const detail = e.detail || e
      if (detail.success) {
        console.log('扫码结果:', detail.code)
        console.log('码类型:', detail.format)

        // 如果是网址，打开它
        if (detail.code.startsWith('http')) {
          plus?.runtime?.openURL?.(detail.code)
        }
      }
    }
  }
}
</script>
```

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| scanType | string | 否 | 'all' | 扫码类型：qr/bar/all |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

---

### 5. 系统信息组件 (native-system-info)

#### 使用示例

```vue
<template>
  <embed
    tag="native-system-info"
    :options="{
      infoType: 'all',
      width: 200,
      height: 200
    }"
    @result="onSystemInfoResult"
  />
</template>

<script>
export default {
  methods: {
    onSystemInfoResult(e) {
      const detail = e.detail || e
      if (detail.success) {
        console.log('系统:', detail.systemInfo)
        console.log('网络:', detail.networkInfo)
        console.log('存储:', detail.storageInfo)
      }
    }
  }
}
</script>
```

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| infoType | string | 否 | 'basic' | 信息类型：basic/network/storage/all |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

---

## 完整示例

### 示例文件位置

- **完整版**: `examples/NativeComponentsExample.vue`
- **简化版**: `examples/SimpleNativeButton.vue`

### 完整版功能

1. ✅ 平台自动检测
2. ✅ 5个原生组件演示
3. ✅ 结果展示
4. ✅ 图片预览
5. ✅ 系统信息卡片
6. ✅ 非 HarmonyOS 平台 Hello World

### 简化版功能

1. ✅ 平台检测
2. ✅ 单个按钮组件演示
3. ✅ 结果展示
4. ✅ 渐变背景 UI

---

## 常见问题

### Q1: 组件不显示？

**检查项：**
1. 确认宿主应用已调用 `registerAllNativeComponents()`
2. 确认组件标签名称正确
3. 检查 width 和 height 是否设置
4. 确认当前是 HarmonyOS 平台

### Q2: 事件不触发？

**检查项：**
1. 确认事件名称正确（如 `@result`、`@click`）
2. 检查回调函数是否正确定义
3. 使用 `console.log` 查看 `e` 和 `e.detail` 的内容

### Q3: 如何在不同平台使用不同组件？

```vue
<template>
  <view>
    <!-- HarmonyOS -->
    <embed v-if="isHarmonyOS" tag="native-button" :options="..." @click="..." />

    <!-- 其他平台 -->
    <button v-else @click="...">点击我</button>
  </view>
</template>
```

### Q4: platform 为什么不是 'harmonyos'？

可能原因：
1. uni-app 版本过旧，需要升级到最新版本
2. 需要在 manifest.json 中配置 HarmonyOS 相关设置
3. 使用备用检测方法（通过 system 字符串）

### Q5: 如何调试原生组件？

```javascript
// 1. 启用 debug 模式
init(this, windowStage, { debug: true })

// 2. 查看宿主应用日志
LogUtil.debug('组件信息:', ...)

// 3. 小程序端使用 console.log
console.log('事件数据:', e)
```

---

## 最佳实践

### 1. 组件封装

```vue
<!-- components/NativeButton.vue -->
<template>
  <embed v-if="isHarmonyOS" tag="native-button" v-bind="$attrs" v-on="$listeners" />
  <button v-else v-bind="$attrs" v-on="$listeners">
    <slot />
  </button>
</template>

<script>
export default {
  computed: {
    isHarmonyOS() {
      return this.$store.state.isHarmonyOS
    }
  }
}
</script>
```

### 2. Mixin 复用

```javascript
// mixins/harmonyOS.js
export default {
  computed: {
    isHarmonyOS() {
      const systemInfo = uni.getSystemInfoSync()
      return systemInfo.platform === 'harmonyos' ||
             (systemInfo.system && systemInfo.system.toLowerCase().includes('harmonyos'))
    }
  }
}

// 使用
import harmonyOSMixin from '@/mixins/harmonyOS'

export default {
  mixins: [harmonyOSMixin]
}
```

### 3. TypeScript 支持

```typescript
// types/native.d.ts
declare interface NativeButtonClickDetail {
  type: string
  text: string
  timestamp: number
}

declare interface NativeCameraResult {
  success: boolean
  uri?: string
  width?: number
  height?: number
  size?: number
  errorMessage?: string
}
```

---

## 相关文档

- [原生组件开发指南](./NATIVE_COMPONENTS_GUIDE.md)
- [uni-app 官方文档](https://uniapp.dcloud.net.cn/)
- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)

---

**文档结束**
