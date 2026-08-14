# HarmonyOS SaveButton：免权限保存图片的正确姿势

> 咳咳，说到保存图片到相册这个话题，我想起当年在 iOS 开发的时候，要保存一张图片到相册，得先请求相册权限——`PHPhotoLibrary.requestAuthorization`，然后还要判断授权状态，然后才能调用 `PHAssetChangeRequest.creationRequestAsset` 写入图片。一套流程下来，手指都酸了。到了 HarmonyOS 这边，官方给了我们 `SaveButton` 这个神器，直接跳过权限申请，爱了爱了。今天就和大家好好聊聊这个 SaveButton。

## 1. 先说痛点

聊到图片保存，我们经常会遇到这么几个问题：

- **权限申请繁琐**：传统方式需要申请 `ohos.permission.WRITE_IMAGE_VIDEO` 权限
- **权限被拒绝**：用户拒绝授权后，图片保存功能直接瘫痪
- **权限解释成本高**：用户看到"请求访问相册"就警觉，实际只是想保存个图片
- **多端实现不一致**：iOS、Android、HarmonyOS 三套权限逻辑，代码冗余

但是！但是！用了 SaveButton 之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SaveButton 核心原理                          │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                      SaveButton (系统组件)                     │  │
│  │                                                              │  │
│  │   用户点击 ──→ 系统弹窗 ──→ 用户授权 ──→ 保存成功              │  │
│  │       │              │                                    │  │
│  │       ↓              ↓                                    │  │
│  │   无需手动申请权限   系统内置权限对话框                       │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  对比传统方案：                                                       │
│  ┌───────────────────┐    ┌───────────────────────────────────┐  │
│  │   传统方案         │    │   SaveButton 方案                   │  │
│  ├───────────────────┤    ├───────────────────────────────────┤  │
│  │ 1. 申请权限        │    │ 1. 点击按钮                         │  │
│  │ 2. 判断授权状态    │    │ 2. 系统弹窗请求授权                  │  │
│  │ 3. 写入图片        │    │ 3. 保存成功                          │  │
│  │ 4. 错误处理        │    │                                     │  │
│  └───────────────────┘    └───────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **系统内置权限请求 + 回调通知**。用户感知到的就是一个按钮，点击、保存、完成。

## 3. 核心代码展示

### 3.1 HotKey.ets 中的实际使用

**Talk is cheap, show me the code**

```typescript
// HotKey.ets
import { CaptureTool } from 'utils'
import { SaveButton, SaveIconStyle, SaveDescription, SaveButtonOnClickResult } from '@kit.ArkUI'

build() {
  NavDestination() {
    Flex({ wrap: FlexWrap.Wrap }) {
      // 热词标签列表...
      ForEach(this.dataSource.originData, (item: HotKeyModel) => {
        Text(item.name)
          // ...
      })

      // 保存按钮
      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,  // 图标风格：填充
        text: SaveDescription.SAVE_IMAGE,  // 文字：保存图片
        buttonType: ButtonType.Normal
      })
        .fontColor(Color.White)
        .backgroundColor("#2C86EF")
        .borderRadius(4)
        .fontSize(16)
        .padding(8)
        .onClick((event, result) => {
          // 核心：判断保存结果
          if (result === SaveButtonOnClickResult.SUCCESS) {
            CaptureTool.saveImage("HotKey")
          }
        })
    }
  }
}
```

### 3.2 SaveButton 参数详解

| 参数 | 类型 | 说明 |
|------|------|------|
| icon | SaveIconStyle | 图标风格：`FULL_FILLED`（填充）/ `OUTLINE`（描边） |
| text | SaveDescription | 文字：`SAVE_IMAGE`（保存图片）/ `SAVE_VIDEO`（保存视频） |
| buttonType | ButtonType | 按钮类型：`Normal`（普通）/ `Capsule`（胶囊） |

```typescript
// 变体1: 保存视频
SaveButton({
  icon: SaveIconStyle.OUTLINE,
  text: SaveDescription.SAVE_VIDEO,
  buttonType: ButtonType.Capsule
})

// 变体2: 仅图标
SaveButton({
  icon: SaveIconStyle.FULL_FILLED,
  buttonType: ButtonType.Normal
})
```

### 3.3 回调结果判断

```typescript
SaveButton({ ... })
  .onClick((event: ClickEvent, result: SaveButtonOnClickResult) => {
    switch (result) {
      case SaveButtonOnClickResult.SUCCESS:
        // 保存成功
        ToastUtil.showToast('保存成功')
        break
      case SaveButtonOnClickResult.FAILURE:
        // 保存失败（通常是存储空间不足）
        ToastUtil.showToast('保存失败，请检查存储空间')
        break
      case SaveButtonOnClickResult.LIMITED:
        // 部分失败（如已达到设备保存数量上限）
        ToastUtil.showToast('保存数量已达上限')
        break
    }
  })
```

## 4. 对比 iOS 的 PHPicker

说实话，相比 iOS 的 `PHPickerViewController`，SaveButton 也是毫不逊色的：

| 特性 | iOS PHPicker | HarmonyOS SaveButton |
|------|--------------|---------------------|
| 权限 | 需先请求 `PHPhotoLibrary` 权限 | 无需申请，系统处理 |
| 弹窗 | 需自己实现 picker 界面 | 系统内置，风格统一 |
| 保存 | `PHAssetChangeRequest` | 直接写入，API 简洁 |
| 用户感知 | "请求访问相册" 弹窗 | "要保存图片吗？" 弹窗 |

iOS 方案胜在**生态成熟**，SaveButton 胜在**用户感知更轻量**。

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **权限来源** | SaveButton 的权限由系统管理，应用不需要在 module.json5 中声明权限 |
| **回调必须判断** | 必须判断 `result === SaveButtonOnClickResult.SUCCESS` 再保存 |
| **存储空间** | 保存失败可能是设备存储空间不足，需要提示用户 |
| **保存数量上限** | 某些设备有限制，达到上限时返回 `LIMITED` |
| **跨平台差异** | iOS/Android 需要单独处理权限，SaveButton 仅 HarmonyOS 可用 |
| **UI 定制** | 按钮样式（颜色、圆角、字体）可以自定义 |
| **captureTool** | 实际保存逻辑封装在 `CaptureTool.saveImage()` 中 |

## 6. 进阶用法

### 6.1 自定义样式

```typescript
SaveButton({
  icon: SaveIconStyle.FULL_FILLED,
  text: SaveDescription.SAVE_IMAGE,
  buttonType: ButtonType.Capsule
})
  .width(120)
  .height(36)
  .fontSize(14)
  .fontColor('#FFFFFF')
  .backgroundColor('#2C86EF')
  .borderRadius(18)
```

### 6.2 配合 BaseListDataSource 使用

```typescript
// 保存整个列表为图片
SaveButton({ ... })
  .onClick(async (event, result) => {
    if (result === SaveButtonOnClickResult.SUCCESS) {
      // 获取当前列表的截图
      await CaptureTool.saveImage("ListView")
    }
  })
```

## 7. 总结

HarmonyOS 的 SaveButton，我这段时间用下来是真的香：

1. **免权限**：无需在 module.json5 声明 WRITE_IMAGE_VIDEO 权限
2. **系统弹窗**：权限请求由系统处理，用户感知更轻量
3. **API 简洁**：只需判断结果，保存逻辑由系统处理
4. **体验一致**：所有使用 SaveButton 的应用，弹窗风格一致
5. **错误处理**：通过 `SaveButtonOnClickResult` 枚举值判断结果

推荐在需要**保存图片到相册**、**提升用户体验**、**简化权限逻辑**的场景下使用 SaveButton。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)