/**
 * 原生嵌入组件演示页面
 *
 * @description
 * 展示如何使用定义的原生嵌入组件
 * 这些组件可以在 uni-app 小程序中直接使用
 *
 * @author NativeComponentsDemo
 * @version 1.0.0
 */

import { RouterName } from '../router/RouterName'
import { LogUtil } from '@pura/harmony-utils'

@Entry({routeName: RouterName.NativeComponentsDemo})
@ComponentV2
struct NativeComponentsDemo {
  @Local buttonResult: string = ''
  @Local cameraResult: string = ''
  @Local locationResult: string = ''
  @Local scannerResult: string = ''
  @Local systemInfoResult: string = ''

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 页面标题
          this.HeaderSection()

          // 使用说明
          this.UsageSection()

          // 1. 原生按钮组件
          this.NativeButtonSection()

          // 2. 相机组件
          this.NativeCameraSection()

          // 3. 定位组件
          this.NativeLocationSection()

          // 4. 扫码组件
          this.NativeScannerSection()

          // 5. 系统信息组件
          this.NativeSystemInfoSection()

          // 组件列表
          this.ComponentsListSection()

          // 说明区域
          this.InfoSection()
        }
        .width('100%')
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('原生组件演示')
  }

  @Builder
  HeaderSection() {
    Column() {
      Text('原生嵌入组件')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('uni-app 小程序可直接使用这些组件')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 20, left: 16, right: 16 })
  }

  @Builder
  UsageSection() {
    Column() {
      Text('使用说明')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      this.UsageItem('1. 在 HarmonyOS 端定义并注册组件')
      this.UsageItem('2. 在小程序端使用 <embed> 标签调用')
      this.UsageItem('3. 通过事件进行双向通信')
      this.UsageItem('4. 组件会调用 HarmonyOS 原生能力')

      Text('示例代码：')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })

      Text(`<embed
  tag="native-camera"
  :options="{ width: 200, height: 200 }"
  @result="onCameraResult"
/>`)
        .fontSize(12)
        .fontColor('#2C86EF')
        .fontFamily('monospace')
        .margin({ top: 8 })
        .padding(12)
        .width('100%')
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
  }

  @Builder
  UsageItem(text: string) {
    Text(text)
      .fontSize(14)
      .fontColor('#666666')
      .margin({ top: 4 })
  }

  @Builder
  NativeButtonSection() {
    Column() {
      Row() {
        Column() {
          Text('原生按钮')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('增强版按钮，支持防抖、触觉反馈')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('按钮')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#2C86EF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })

      // 结果展示
      if (this.buttonResult) {
        Text(this.buttonResult)
          .fontSize(14)
          .fontColor('#2C86EF')
          .padding(12)
          .width('100%')
          .backgroundColor('#E3F2FD')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16 })
      }
    }
  }

  @Builder
  NativeCameraSection() {
    Column() {
      Row() {
        Column() {
          Text('原生相机')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('调用系统相册选择图片')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('相机')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })

      if (this.cameraResult) {
        Text(this.cameraResult)
          .fontSize(14)
          .fontColor('#4CAF50')
          .padding(12)
          .width('100%')
          .backgroundColor('#E8F5E9')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16 })
      }
    }
  }

  @Builder
  NativeLocationSection() {
    Column() {
      Row() {
        Column() {
          Text('原生定位')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('调用 HarmonyOS 位置服务')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('定位')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF9800')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })

      if (this.locationResult) {
        Text(this.locationResult)
          .fontSize(14)
          .fontColor('#FF9800')
          .padding(12)
          .width('100%')
          .backgroundColor('#FFF3E0')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16 })
      }
    }
  }

  @Builder
  NativeScannerSection() {
    Column() {
      Row() {
        Column() {
          Text('原生扫码')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('支持二维码和条形码扫描')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('扫码')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#9C27B0')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })

      if (this.scannerResult) {
        Text(this.scannerResult)
          .fontSize(14)
          .fontColor('#9C27B0')
          .padding(12)
          .width('100%')
          .backgroundColor('#F3E5F5')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16 })
      }
    }
  }

  @Builder
  NativeSystemInfoSection() {
    Column() {
      Row() {
        Column() {
          Text('系统信息')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('获取设备系统信息')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('信息')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#607D8B')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16, left: 16, right: 16 })

      if (this.systemInfoResult) {
        Text(this.systemInfoResult)
          .fontSize(14)
          .fontColor('#607D8B')
          .padding(12)
          .width('100%')
          .backgroundColor('#ECEFF1')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16 })
      }
    }
  }

  @Builder
  ComponentsListSection() {
    Column() {
      Text('已注册的组件标签')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 16 })

      this.ComponentTagItem('native-button', '原生按钮组件')
      this.ComponentTagItem('native-camera', '相机组件')
      this.ComponentTagItem('native-location', '定位组件')
      this.ComponentTagItem('native-scanner', '扫码组件')
      this.ComponentTagItem('native-system-info', '系统信息组件')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
  }

  @Builder
  ComponentTagItem(tag: string, description: string) {
    Row() {
      Text(tag)
        .fontSize(14)
        .fontColor('#2C86EF')
        .fontFamily('monospace')
        .layoutWeight(1)

      Text(description)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor('#F8F8F8')
    .margin({ top: 8 })
  }

  @Builder
  InfoSection() {
    Column() {
      Text('特点说明')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text('• 所有组件都是 HarmonyOS 原生实现')
        .fontSize(12)
        .fontColor('#666666')

      Text('• 支持双向事件通信')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 自动处理权限请求')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 统一的错误处理机制')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 支持自定义配置参数')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Text('• 完整的类型定义支持')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E3F2FD')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 20 })
  }
}

@Builder
export function NativeComponentsDemoBuilder() {
  NativeComponentsDemo()
}

export { NativeComponentsDemo }
