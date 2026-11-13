// [Harmony 状态管理神器 @ObservedV2](https://juejin.cn/post/7391704406327164982)
import { LogUtil } from '@pura/harmony-utils';
import { navPathStack } from '../router/navPathStack';
import { RouterName } from '../router/RouterName';

@ObservedV2
class Person {
  @Trace
  age: number = 100

  son = new Son()
}

@ObservedV2
class Son {
  @Trace
  weight: number = 200
}

@Entry({ routeName: RouterName.ObservedV2Test })
@Component
struct ObservedV2Test {
  person = new Person()

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 标题说明卡片
          Column() {
          Text('@ObservedV2 状态管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          Text('HarmonyOS 新一代状态管理方案')
            .fontSize(14)
            .fontColor('#999999')

          Text('支持嵌套对象自动追踪，无需手动刷新')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .margin({ top: 20, left: 16, right: 16 })

        // Person 状态卡片
        Column() {
          Row() {
            Column() {
              Text('Person 对象')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('父级对象，包含嵌套的 Son 对象')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(`${this.person.age} 岁`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2C86EF')
          }
          .width('100%')
          .height(80)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 原有逻辑保持不变
          Button("person的age" + this.person.age)
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#2C86EF')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              this.person.age++
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // Son 状态卡片
        Column() {
          Row() {
            Column() {
              Text('Son 对象')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('嵌套对象，自动响应变化')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(`${this.person.son.weight} kg`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B6B')
          }
          .width('100%')
          .height(80)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          // 原有逻辑保持不变
          Button("son的weight" + this.person.son.weight)
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#FF6B6B')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              this.person.son.weight++
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // 网络层对比测试卡片
        Column() {
          Row() {
            Column() {
              Text('网络层对比测试')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('对比两种网络层的请求结果')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('测试')
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

          Button('查看网络层对比测试')
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#2C86EF')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              navPathStack.pushPath({ name: RouterName.NetworkComparison })
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16, bottom: 16 })

        // 网络请求示例卡片
        Column() {
          Row() {
            Column() {
              Text('网络请求示例')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('完整的 HTTP 请求示例')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('示例')
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

          Button('查看网络请求示例')
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#9C27B0')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              navPathStack.pushPath({ name: RouterName.NetworkExample })
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

        // NavPathStack 测试卡片
        Column() {
          Row() {
            Column() {
              Text('NavPathStack 双向传值')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('顺传 + 逆传示例')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('测试')
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

          Button('Go to NavPathStackTest')
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#FF9800')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              // 顺传：传递 person.age 作为参数
              navPathStack.pushPathByName(RouterName.NavPathStackTest, this.person.age, (popInfo) => {
                // 逆传：接收返回值
                LogUtil.debug(`NavPathStackTest 返回值: ${popInfo.result}`)
              })
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16, bottom: 16 })

        // 说明区域
        Column() {
          Text('功能说明')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ bottom: 8 })

          Text('• 点击按钮观察状态自动更新')
            .fontSize(12)
            .fontColor('#666666')

          Text('• 嵌套对象无需手动刷新')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })

          Text('• 支持网络层对比测试')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })

          Text('• 网络请求完整示例页面')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFF8E1')
        .borderRadius(12)
        .margin({ left: 16, right: 16, bottom: 20 })
      }
      .width('100%')
      .backgroundColor('#F8F8F8')
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .onReady((context: NavDestinationContext) => {
      let result = context.pathInfo.param as number
      LogUtil.debug(`onReady result: ${result}`)
    })
    .title('状态管理测试')
  }

  onPageShow(): void {
    LogUtil.debug(`onPageShow`)
  }


}

@Builder
export function ObservedV2TestBuilder() {
  ObservedV2Test()
}

export { ObservedV2Test }