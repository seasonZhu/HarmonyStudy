// [Harmony 状态管理神器 @ObservedV2](https://juejin.cn/post/7391704406327164982)
import { openUniMP,isExistsUniMP, releaseWgtToRunPath } from '@dcloudio/uni-app-runtime';
import { FileUtil, LogUtil } from '@pura/harmony-utils';
import { Router } from '../router/Router';
import { PagesConstant } from '../router/PagesConstant';

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

@Entry
@Component
struct ObservedV2TestPage {
  person = new Person()

  build() {
    Navigation() {
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

        // UniApp 集成卡片
        Column() {
          Row() {
            Column() {
              Text('UniApp 小程序')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('集成运行本地小程序')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('集成')
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

          // 原有逻辑保持不变
          Button("Go to UniApp")
            .width('100%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#2C86EF')
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              this.openLocalUniApp()
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
              Router.push(PagesConstant.NetworkExample)
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F8F8')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })

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

          Text('• 支持运行本地UniApp小程序')
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
    .title('状态管理测试')
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
  }

  aboutToAppear(): void {
    let fileDir: string = getContext(this).filesDir
    let fileName = "__UNI__98AF8A0.wgt"//"__UNI__DF9D7DE.wgt"//

    getContext(this).resourceManager.getRawFileContent(fileName, (error, value) => {
      LogUtil.debug(`${"UniApp#"}[${"wgt File"}] ${"getRawFile:__UNI__.wgt"}`)
      if (error != null) {
        LogUtil.error("error is " + error.message)
        return
      }
      let filePath = fileDir + "/" + fileName
      let file = FileUtil.openSync(filePath)
      FileUtil.writeSync(file.fd, value.buffer)
      FileUtil.closeSync(file.fd) //关闭文件
      LogUtil.debug(`${"UniApp#"}[${"wgt File"}] ${"filePath:" + filePath}`)
    })
  }

  /// https://ohpm.openharmony.cn/#/cn/detail/@dcloudio%2Funi-app-runtime
  private async openLocalUniApp() {
    const mpId = "__UNI__98AF8A0"//"__UNI__DF9D7DE"//

    await new Promise<void>((resolve, reject) => {
      try {
        // 判断应用是否已释放到运行目录
        let isExists = isExistsUniMP(mpId)
        LogUtil.debug("isExists:"+isExists)

        let fileDir: string = getContext(this).filesDir
        // 拼接wgt包路径
        let path = fileDir + "/"+mpId+".wgt"
        // 释放 wgt 包到运行目录
        releaseWgtToRunPath(mpId, path, (code:number, error: Error|null)=>{
          LogUtil.debug(JSON.stringify({code, error}))
          resolve()
          // 启动小程序
          const mp = openUniMP(mpId, {
            capsuleMenuActionSheetItems: [
              {
                id: '1',
                title: 'test1'
              },
              {
                id: '2',
                title: 'test2'
              }
            ]
          })
          mp.on('close',()=>{
            LogUtil.debug('UniMP-close')
          })
          mp.on('show',()=>{
            LogUtil.debug('UniMP-show')
          })
          mp.on('hide',()=>{
            LogUtil.debug('UniMP-hide')
          })
          mp.on('menuItemClick', (id: string) => {
            LogUtil.debug('menuItemClick', id)

            // 宿主向小程序发送消息
            mp.sendUniMPEvent("NativeEvent", {msg: "native message"})
          })

          mp.on('uniMPEvent', (event: string, data: ESObject, notify: (result: string) => void) => {
            LogUtil.debug(`宿主收到小程序消息，事件：${event}，消息：${JSON.stringify(data)}`);
            notify('宿主成功接收小程序消息')
          })
        })
      } catch(err){
        reject(err)
      }
    }).then(() => {

    })
  }
}

export { ObservedV2TestPage }