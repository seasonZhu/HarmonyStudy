# 原生嵌入组件修复总结

> **问题根源**: 没有遵循 `NativeEmbedBuilderOptions` 的正确使用模式

## 🔍 关键差异对比

### ❌ 之前的错误写法

```typescript
// 1. 接口不继承基础接口
export interface NativeButtonOptions {
  text: string;
  width: number;
  height: number;
  on?: Map<string, (event?: ESObject) => void>;  // ❌ 手动定义 on Map
}

// 2. 回调使用具体类型
onButtonClick?: (detail: NativeButtonClickDetail) => void;  // ❌ 具体类型

// 3. 直接调用回调
this.onButtonClick(detail);  // ❌ 没有包装在 { detail } 中

// 4. 获取回调的方式
onButtonClick: options?.onClick  // ❌ 直接从 options 获取
```

### ✅ 正确的写法（你的工作代码）

```typescript
// 1. 接口继承 NativeEmbedBuilderOptions
export interface NativeButtonOptions extends NativeEmbedBuilderOptions {
  text: string;
  // width 和 height 已经在基类中定义
  // on Map 已经在基类中定义
}

// 2. 回调使用 Function 类型
onButtonClick?: Function;  // ✅ 使用通用 Function 类型

// 3. 包装在 { detail } 中
this.onButtonClick({
  detail  // ✅ 包装在 detail 对象中
});

// 4. 从 on Map 中获取回调
onButtonClick: options?.on?.get('click')  // ✅ 从 Map 中获取
```

---

## 📝 修复清单

### 1. 接口定义

| 项目 | 修复前 | 修复后 |
|------|--------|--------|
| 基础接口 | ❌ 无继承 | ✅ `extends NativeEmbedBuilderOptions` |
| width/height | ❌ 手动定义 | ✅ 从基类继承 |
| on Map | ❌ 手动定义 | ✅ 从基类继承 |

### 2. 组件回调

| 项目 | 修复前 | 修复后 |
|------|--------|--------|
| 类型 | ❌ `onButtonClick?: (detail: Xxx) => void` | ✅ `onButtonClick?: Function` |
| 调用方式 | ❌ `this.onButtonClick(detail)` | ✅ `this.onButtonClick({ detail })` |

### 3. Builder 函数

| 项目 | 修复前 | 修复后 |
|------|--------|--------|
| 参数类型 | ❌ `options: ESObject` | ✅ `options: XxxOptions extends NativeEmbedBuilderOptions` |
| 回调获取 | ❌ `options?.onClick` | ✅ `options?.on?.get('click')` |

---

## 🎯 完整示例

### HarmonyOS 端（.ets）

```typescript
import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"

// 1. 定义选项接口（必须继承）
interface MyButtonOptions extends NativeEmbedBuilderOptions {
  label: string;
  color?: string;
}

// 2. 定义事件详情
interface MyButtonClickDetail {
  label: string;
  color: string;
  timestamp: number;
}

// 3. 定义组件
@Component
struct MyButtonComponent {
  @Prop label: string = 'Button';
  @Prop color: string = 'blue';
  onClickCallback?: Function;

  build() {
    Button(this.label)
      .backgroundColor(this.color)
      .onClick(() => {
        if (this.onClickCallback) {
          // 4. 包装在 { detail } 中
          const detail: MyButtonClickDetail = {
            label: this.label,
            color: this.color,
            timestamp: Date.now()
          };
          this.onClickCallback({
            detail
          });
        }
      })
  }
}

// 5. 定义 Builder
@Builder
function MyButtonBuilder(options: MyButtonOptions) {
  MyButtonComponent({
    label: options.label,
    color: options.color ?? 'blue',
    // 6. 从 on Map 获取回调
    onClickCallback: options?.on?.get('click')
  })
  // 7. width/height 从基类继承
  .width(options.width)
  .height(options.height)
}

// 8. 注册组件
defineNativeEmbed('my-button', {
  builder: MyButtonBuilder
})
```

### uni-app 端

```vue
<template>
  <embed
    tag="my-button"
    :options="{
      label: '点击我',
      color: '#2C86EF',
      width: 200,
      height: 50
    }"
    @click="handleClick"
  />
</template>

<script>
export default {
  methods: {
    handleClick(e) {
      console.log('detail:', e.detail)
      // e.detail = { label: '点击我', color: '#2C86EF', timestamp: xxx }
    }
  }
}
</script>
```

---

## 📊 NativeEmbedBuilderOptions 基类属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `width` | `number` | 组件宽度 |
| `height` | `number` | 组件高度 |
| `on` | `Map<string, Function>` | 事件回调映射 |

---

## ✅ 修复后的组件列表

| 标签名称 | 组件 | 功能 |
|---------|------|------|
| `button` | ButtonComponent | 你的工作代码（正确示例） |
| `simple-text` | SimpleTextComponent | 最简单的组件 |
| `text-with-message` | TextWithMessageComponent | 带消息的组件 |
| `clickable-text` | ClickableTextComponent | 可点击的组件 |
| `test-button` | TestButtonComponent | 完整按钮组件 |
| `native-button` | NativeButtonComponent | 原生按钮（已修复） |
| `native-camera` | NativeCameraComponent | 相机组件（已修复） |
| `native-location` | NativeLocationComponent | 定位组件（已修复） |
| `native-scanner` | NativeScannerComponent | 扫码组件（已修复） |
| `native-system-info` | NativeSystemInfoComponent | 系统信息（已修复） |

---

## 🔧 已修复的文件

| 文件 | 状态 |
|------|------|
| `entry/src/main/ets/native/HarmonyNativeComponents.ets` | ✅ 已修复 |
| `entry/src/main/ets/native/SimpleNativeTest.ets` | ✅ 已修复 |
| `entry/src/main/ets/entryability/EntryAbility.ets` | ✅ 已恢复 |

---

## 🎓 核心要点

### 1. 必须继承 NativeEmbedBuilderOptions

```typescript
// ✅ 正确
interface MyOptions extends NativeEmbedBuilderOptions {
  myProp: string;
}

// ❌ 错误
interface MyOptions {
  myProp: string;
  width: number;  // 不需要手动定义
}
```

### 2. 回调类型必须是 Function

```typescript
// ✅ 正确
onCallback?: Function

// ❌ 错误
onCallback?: (detail: XxxDetail) => void
```

### 3. 事件数据必须包装在 { detail } 中

```typescript
// ✅ 正确
this.onCallback({
  detail: eventData
})

// ❌ 错误
this.onCallback(eventData)
```

### 4. 从 options.on.get() 获取回调

```typescript
// ✅ 正确
onCallback: options?.on?.get('click')

// ❌ 错误
onCallback: options?.onClick
```

---

## 📖 参考资源

- [uni-app runtime 官方文档](https://ohpm.openharmony.cn/#/cn/detail/@dcloudio%2Funi-app-runtime)
- [原生组件开发指南](./NATIVE_COMPONENTS_GUIDE.md)
- [你的工作代码](../entry/src/main/ets/native/SimpleNativeTest.ets) - 最好的示例

---

**感谢你提供了正确的工作代码！** 🎉

通过对比你的代码，我们找到了正确的使用模式，所有组件现在都应该可以正常工作了。
