# uni-app 原生嵌入组件使用指南

> **版本**: v1.0.0
> **更新日期**: 2026-02-05
> **项目**: HarmonyStudy

---

## 📋 目录

- [一、组件概述](#一组件概述)
- [二、已注册组件](#二已注册组件)
- [三、小程序端使用](#三小程序端使用)
- [四、API 参考](#四api-参考)
- [五、开发调试](#五开发调试)

---

## 一、组件概述

### 1.1 什么是原生嵌入组件？

原生嵌入组件（Native Embed Component）是 **uni-app 运行时提供的一种能力**，允许：

- ✅ 在小程序中直接使用 HarmonyOS 原生组件
- ✅ 调用 HarmonyOS 原生 API（相机、定位、扫码等）
- ✅ 双向事件通信（小程序 ↔ 宿主应用）
- ✅ 类型安全的事件回调

### 1.2 架构原理

```
┌──────────────────────────────────────────────────────┐
│            uni-app 小程序 (.vue)                      │
│  <embed tag="native-camera" :options="..." @result="..." />  │
└──────────────────────────────────────────────────────┘
                          ↕ 通过事件通信
┌──────────────────────────────────────────────────────┐
│         HarmonyOS 宿主应用 (EntryAbility.ets)           │
│  ├─ defineNativeEmbed() 注册组件                       │
│  ├─ @Component 实现原生逻辑                           │
│  └─ 调用 HarmonyOS 原生 API                           │
└──────────────────────────────────────────────────────┘
                          ↕
┌──────────────────────────────────────────────────────┐
│            HarmonyOS 系统服务                          │
│  ├─ photoAccessHelper (相册)                          │
│  ├─ geoLocationManager (定位)                          │
│  └─ scanKit (扫码)                                     │
└──────────────────────────────────────────────────────┘
```

---

## 二、已注册组件

### 组件列表

| 标签名称 | 组件名称 | 功能说明 |
|---------|---------|---------|
| `native-button` | 原生按钮 | 增强版按钮，支持防抖、触觉反馈 |
| `native-camera` | 相机组件 | 调用系统相册选择图片 |
| `native-location` | 定位组件 | 获取设备当前位置信息 |
| `native-scanner` | 扫码组件 | 扫描二维码/条形码 |
| `native-system-info` | 系统信息 | 获取设备系统信息 |

---

## 三、小程序端使用

### 3.1 原生按钮组件

**功能**：增强版按钮，支持防抖（500ms）、触觉反馈

```vue
<template>
  <view class="container">
    <!-- 基础用法 -->
    <embed
      tag="native-button"
      :options="{
        text: '点击我',
        type: 'primary',
        width: 200,
        height: 50
      }"
      @click="onButtonClick"
    />

    <!-- 成功按钮 -->
    <embed
      tag="native-button"
      :options="{
        text: '成功',
        type: 'success',
        width: 200,
        height: 50
      }"
      @click="onSuccessClick"
    />

    <!-- 禁用按钮 -->
    <embed
      tag="native-button"
      :options="{
        text: '禁用状态',
        type: 'warning',
        width: 200,
        height: 50,
        disabled: true
      }"
    />
  </view>
</template>

<script>
export default {
  data() {
    return {}
  },

  methods: {
    onButtonClick(e) {
      console.log('按钮点击:', e.detail);
      // e.detail = { type: 'primary', text: '点击我', timestamp: xxx }
      uni.showToast({
        title: '点击了按钮',
        icon: 'success'
      });
    },

    onSuccessClick(e) {
      console.log('成功按钮点击:', e.detail);
    }
  }
}
</script>

<style scoped>
.container {
  padding: 20px;
}

embed {
  display: block;
  margin: 10px auto;
}
</style>
```

### 3.2 相机组件

**功能**：调用 HarmonyOS 系统相册选择图片

```vue
<template>
  <view class="container">
    <embed
      tag="native-camera"
      :options="{
        quality: 80,    // 图片质量 1-100
        edit: false,    // 是否允许编辑
        width: 200,
        height: 200
      }"
      @result="onCameraResult"
    />

    <!-- 显示选择的图片 -->
    <image v-if="selectedImage" :src="selectedImage" mode="aspectFit" />
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
      console.log('相机结果:', e.detail);

      if (e.detail.success) {
        this.selectedImage = e.detail.uri;
        uni.showToast({
          title: '图片选择成功',
          icon: 'success'
        });
      } else {
        uni.showToast({
          title: e.detail.errorMessage || '选择失败',
          icon: 'error'
        });
      }
    }
  }
}
</script>

<style scoped>
.image {
  width: 200px;
  height: 200px;
  margin: 20px auto;
  border-radius: 8px;
}
</style>
```

### 3.3 定位组件

**功能**：获取设备当前位置信息

```vue
<template>
  <view class="container">
    <embed
      tag="native-location"
      :options="{
        accuracy: 'high',     // low | medium | high
        timeout: 10000,       // 超时时间（毫秒）
        width: 200,
        height: 200
      }"
      @result="onLocationResult"
    />

    <!-- 显示位置信息 -->
    <view v-if="locationInfo" class="location-info">
      <text>纬度: {{ locationInfo.latitude }}</text>
      <text>经度: {{ locationInfo.longitude }}</text>
      <text>地址: {{ locationInfo.address }}</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      locationInfo: null
    }
  },

  methods: {
    onLocationResult(e) {
      console.log('定位结果:', e.detail);

      if (e.detail.success) {
        this.locationInfo = e.detail;
        uni.showToast({
          title: '定位成功',
          icon: 'success'
        });
      } else {
        uni.showToast({
          title: e.detail.errorMessage || '定位失败',
          icon: 'error'
        });
      }
    }
  }
}
</script>
```

### 3.4 扫码组件

**功能**：扫描二维码和条形码

```vue
<template>
  <view class="container">
    <embed
      tag="native-scanner"
      :options="{
        scanType: 'all',      // qr | bar | all
        width: 200,
        height: 200
      }"
      @result="onScannerResult"
    />

    <!-- 显示扫码结果 -->
    <view v-if="scanResult" class="scan-result">
      <text>扫码结果: {{ scanResult.code }}</text>
      <text>格式: {{ scanResult.format }}</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      scanResult: null
    }
  },

  methods: {
    onScannerResult(e) {
      console.log('扫码结果:', e.detail);

      if (e.detail.success) {
        this.scanResult = e.detail;

        // 解析二维码内容
        if (e.detail.code.startsWith('http')) {
          // 这是一个网址，可以打开
          uni.showModal({
            title: '打开链接',
            content: e.detail.code,
            success: (res) => {
              if (res.confirm) {
                // 打开网址
                plus.runtime.openURL(e.detail.code);
              }
            }
          });
        } else {
          uni.showToast({
            title: '扫码成功',
            icon: 'success'
          });
        }
      } else {
        uni.showToast({
          title: e.detail.errorMessage || '扫码失败',
          icon: 'error'
        });
      }
    }
  }
}
</script>
```

### 3.5 系统信息组件

**功能**：获取设备系统信息

```vue
<template>
  <view class="container">
    <embed
      tag="native-system-info"
      :options="{
        infoType: 'all',     // basic | network | storage | all
        width: 200,
        height: 200
      }"
      @result="onSystemInfoResult"
    />

    <!-- 显示系统信息 -->
    <view v-if="systemInfo" class="system-info">
      <view class="info-item" v-if="systemInfo.systemInfo">
        <text class="label">系统:</text>
        <text>{{ systemInfo.systemInfo.system }}</text>
      </view>
      <view class="info-item" v-if="systemInfo.networkInfo">
        <text class="label">网络:</text>
        <text>{{ systemInfo.networkInfo.isConnected ? '已连接' : '未连接' }}</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      systemInfo: null
    }
  },

  methods: {
    onSystemInfoResult(e) {
      console.log('系统信息:', e.detail);

      if (e.detail.success) {
        this.systemInfo = e.detail;
      } else {
        uni.showToast({
          title: '获取失败',
          icon: 'error'
        });
      }
    }
  }
}
</script>
```

---

## 四、API 参考

### 4.1 native-button

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

### 4.2 native-camera

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

### 4.3 native-location

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| accuracy | string | 否 | 'medium' | 定位精度：low/medium/high |
| timeout | number | 否 | 10000 | 超时时间（毫秒） |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

#### 事件

| 事件名 | 说明 | 返回值 |
|--------|------|--------|
| result | 定位结果 | { success, latitude, longitude, address, errorMessage } |

### 4.4 native-scanner

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| scanType | string | 否 | 'all' | 扫码类型：qr/bar/all |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

#### 事件

| 事件名 | 说明 | 返回值 |
|--------|------|--------|
| result | 扫码结果 | { success, code, format, errorMessage } |

### 4.5 native-system-info

#### options 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| infoType | string | 否 | 'basic' | 信息类型：basic/network/storage/all |
| width | number | 是 | - | 宽度（px） |
| height | number | 是 | - | 高度（px） |

#### 事件

| 事件名 | 说明 | 返回值 |
|--------|------|--------|
| result | 系统信息 | { success, systemInfo, networkInfo, storageInfo, errorMessage } |

---

## 五、开发调试

### 5.1 在宿主应用中测试

```typescript
// 1. 查看已注册组件
// EntryAbility.onWindowStageCreate 中已调用
registerAllNativeComponents()

// 2. 运行 HarmonyOS 应用
hvigorw assembleHap

// 3. 在应用中找到原生组件演示页面
// 路由: RouterName.NativeComponentsDemo
```

### 5.2 在小程序中使用

1. **准备小程序 wgt 包**
2. **在小程序 manifest.json 中声明权限**
3. **使用 <embed> 标签调用组件**
4. **监听组件事件处理结果**

### 5.3 常见问题

**Q1: 组件不显示？**
- 确认宿主应用已调用 `registerAllNativeComponents()`
- 确认组件标签名称正确
- 检查 width 和 height 是否设置

**Q2: 事件不触发？**
- 确认事件名称正确（如 @result、@click）
- 检查回调函数是否正确定义
- 查看控制台是否有错误日志

**Q3: 权限错误？**
- 在 module.json5 中声明相应权限
- 相机权限: ohos.permission.READ_IMAGEVIDEO
- 定位权限: ohos.permission.APPROXIMATELY_LOCATION
- 相机权限: ohos.permission.CAMERA

---

## 附录

### A. 权限声明示例

```json5
// module.json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.READ_IMAGEVIDEO",
        "reason": "$string:permission_camera_reason",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:permission_location_reason",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      }
    ]
  }
}
```

### B. 相关文档

- **📘 [uni-app 小程序端完整使用指南](./UNI_APP_NATIVE_USAGE.md)** - 包含平台检测、完整示例、最佳实践
- [uni-app 官方文档](https://uniapp.dcloud.net.cn/)
- [@dcloudio/uni-app-runtime](https://ohpm.openharmony.cn/#/cn/detail/@dcloudio%2Funi-app-runtime)
- [HarmonyOS 相册 API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ks-media-image-V5)
- [HarmonyOS 定位 API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ks-location-geolocation-V5)

### C. 快速开始示例

如果你想直接在 uni-app 小程序中使用这些组件，请参考以下示例文件：

1. **完整版示例**: `examples/NativeComponentsExample.vue`
   - 包含所有 5 个组件的演示
   - 完整的平台检测逻辑
   - 结果展示和图片预览

2. **简化版示例**: `examples/SimpleNativeButton.vue`
   - 单个按钮组件演示
   - 最小化实现
   - 适合快速测试

3. **使用教程**: `docs/UNI_APP_NATIVE_USAGE.md`
   - 详细的平台检测方法
   - 每个组件的使用示例
   - 常见问题解答

---

**文档结束**

> 本文档持续更新中，如有问题请参考项目源码或提交 Issue。
