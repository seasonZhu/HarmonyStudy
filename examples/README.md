# uni-app 示例代码

本目录包含 uni-app 小程序中使用 HarmonyOS 原生嵌入组件的示例代码。

## 📁 文件列表

### 1. NativeComponentsExample.vue（完整版）

**路径**: `examples/NativeComponentsExample.vue`

**功能**:
- ✅ 自动检测当前平台（HarmonyOS / 其他）
- ✅ 演示所有 5 个原生组件
- ✅ 完整的事件处理和结果展示
- ✅ 图片预览功能
- ✅ 系统信息卡片展示
- ✅ 非 HarmonyOS 平台显示 Hello World

**使用场景**: 作为完整示例参考，了解所有原生组件的使用方法

**核心代码**:
```vue
<template>
  <view v-if="isHarmonyOS">
    <!-- 原生按钮 -->
    <embed tag="native-button" :options="buttonOptions" @click="onButtonClick" />
    <!-- 相机组件 -->
    <embed tag="native-camera" :options="cameraOptions" @result="onCameraResult" />
    <!-- 定位组件 -->
    <embed tag="native-location" :options="locationOptions" @result="onLocationResult" />
    <!-- 扫码组件 -->
    <embed tag="native-scanner" :options="scannerOptions" @result="onScannerResult" />
    <!-- 系统信息 -->
    <embed tag="native-system-info" :options="systemInfoOptions" @result="onSystemInfoResult" />
  </view>
  <view v-else>
    <text>Hello World</text>
  </view>
</template>
```

---

### 2. SimpleNativeButton.vue（简化版）

**路径**: `examples/SimpleNativeButton.vue`

**功能**:
- ✅ 平台检测（HarmonyOS / 其他）
- ✅ 单个原生按钮组件演示
- ✅ 最小化实现，代码简洁
- ✅ 美观的渐变背景 UI

**使用场景**: 快速测试原生组件是否正常工作

**核心代码**:
```vue
<template>
  <view class="container">
    <view v-if="isHarmonyOS">
      <embed
        tag="native-button"
        :options="{ text: '我是原生按钮', type: 'primary', width: 300, height: 50 }"
        @click="handleClick"
      />
      <text v-if="result">{{ result }}</text>
    </view>
    <view v-else>
      <text class="hello">Hello World</text>
    </view>
  </view>
</template>
```

---

## 🚀 如何使用

### 方式一：直接复制使用

1. 将示例文件复制到你的 uni-app 项目的 `pages` 或 `components` 目录
2. 根据需要修改组件配置
3. 在 `pages.json` 中注册页面（如果是页面）

### 方式二：参考实现

1. 阅读示例代码，理解平台检测逻辑
2. 参考组件配置和事件处理方式
3. 在你的项目中实现类似功能

---

## 📖 相关文档

- **[uni-app 小程序端完整使用指南](../docs/UNI_APP_NATIVE_USAGE.md)** - 详细的使用教程
- **[原生组件开发指南](../docs/NATIVE_COMPONENTS_GUIDE.md)** - 组件 API 参考
- **[项目 README](../README.md)** - 项目整体介绍

---

## 🔍 平台检测逻辑

所有示例都使用相同的平台检测逻辑：

```javascript
// 获取系统信息
const systemInfo = uni.getSystemInfoSync()

// 判断是否是 HarmonyOS
const isHarmonyOS = systemInfo.platform === 'harmonyos' ||
                    (systemInfo.system && systemInfo.system.toLowerCase().includes('harmonyos'))

console.log('当前平台:', systemInfo.platform)
console.log('是否HarmonyOS:', isHarmonyOS)
```

---

## 📱 不同平台的表现

### HarmonyOS 平台
- 显示原生嵌入组件
- 调用 HarmonyOS 原生能力
- 完整的功能支持

### 其他平台（iOS、Android、Web 等）
- 显示 "Hello World" 替代内容
- 或者显示平台兼容性提示
- 不会尝试调用原生组件

---

## ⚠️ 注意事项

1. **宿主应用必须先注册组件**
   ```typescript
   // EntryAbility.ets
   onWindowStageCreate(windowStage: window.WindowStage): void {
     init(this, windowStage, { debug: true })
     registerAllNativeComponents() // 必须调用
   }
   ```

2. **权限声明**
   在 `module.json5` 中声明所需权限：
   ```json
   {
     "requestPermissions": [
       { "name": "ohos.permission.READ_IMAGEVIDEO" },
       { "name": "ohos.permission.APPROXIMATELY_LOCATION" },
       { "name": "ohos.permission.CAMERA" }
     ]
   }
   ```

3. **options 参数必须完整**
   ```vue
   <!-- 正确 ✅ -->
   <embed
     tag="native-button"
     :options="{ text: '按钮', type: 'primary', width: 300, height: 50 }"
   />

   <!-- 错误 ❌ 缺少必需参数 -->
   <embed
     tag="native-button"
     :options="{ text: '按钮' }"
   />
   ```

---

## 🛠️ 调试技巧

### 1. 查看系统信息
```javascript
const systemInfo = uni.getSystemInfoSync()
console.log('完整系统信息:', JSON.stringify(systemInfo, null, 2))
```

### 2. 检查事件数据
```javascript
onClick(e) {
  console.log('事件对象:', e)
  console.log('事件详情:', e.detail)
  console.log('事件详情（备选）:', e.detail || e)
}
```

### 3. 启用 debug 模式
```typescript
// EntryAbility.ets
init(this, windowStage, { debug: true })
```

---

**示例代码持续更新中，如有问题请参考项目源码或提交 Issue。**
