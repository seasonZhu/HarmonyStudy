import { openUniMP, releaseWgtToRunPath } from '@dcloudio/uni-app-runtime'
import { FileUtil } from '@pura/harmony-utils'
import { getTitleByMyType, MyType, getIconByMyType } from '../enum/MyType'
import { getVisibleMyTypes } from '../enum/MyType'
import { UserInfoModel } from '../model/UserInfoModel'
import { navPathStack } from '../router/navPathStack'
import { MyHeader } from '../views/MyHeader'
import { LogUtil } from '@pura/harmony-utils'
import { emitter } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { LOGIN_SUCCESS_EVENT } from './Login'
import { RouterName } from '../router/RouterName'


@Entry({routeName: RouterName.Profile})
@Component
struct Profile {

  @Consume loginSuccessUserInfo: UserInfoModel = {}

  aboutToAppear(): void {
    emitter.on(LOGIN_SUCCESS_EVENT, (data: emitter.EventData) => {
      if (data?.data?.["userInfo"]) {
        this.loginSuccessUserInfo = data.data["userInfo"] as UserInfoModel
      }
    })
  }

  aboutToDisappear(): void {
    emitter.off(LOGIN_SUCCESS_EVENT)
  }

  build() {
    NavDestination() {
      List() {
        ForEach(getVisibleMyTypes(), (type: MyType) => {
          ListItem() {
            if (type == MyType.header) {
              MyHeader({userInfo: this.loginSuccessUserInfo})
                .height(150)
                .width('100%')
            } else {
              Column() {
                Divider()
                  .vertical(false)
                  .strokeWidth(0.5)
                  .width("100%")
                Row() {
                  SymbolGlyph(getIconByMyType(type))
                    .fontSize(20)
                    .fontColor([$r('app.color.text_primary')])
                    .margin({ left: 16 })
                  Text(getTitleByMyType(type))
                    .margin({
                      left: 8
                    })
                    .fontSize(20)
                  Blank()
                }
                .align(Alignment.Start)
                .alignItems(VerticalAlign.Center)
                .height(58)
                .width('100%')
              }
            }
          }.onClick(() => {
              this.routesAction(type)
          })
        })
      }
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.my'))
    .hideBackButton(true)
  }

  /// https://ohpm.openharmony.cn/#/cn/detail/@dcloudio%2Funi-app-runtime
  private async openLocalUniApp() {
    const context = getContext(this)
    const fileName = '__UNI__98AF8A0.wgt'
    const value = await context.resourceManager.getRawFileContent(fileName)
    const file = FileUtil.openSync(context.filesDir + '/' + fileName,
      fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
    try {
      FileUtil.writeSync(file.fd, value.buffer)
    } finally {
      FileUtil.closeSync(file.fd)
    }
    const mpId = "__UNI__98AF8A0"//"__UNI__DF9D7DE"//

    await new Promise<void>((resolve, reject) => {
      const path = context.filesDir + '/' + fileName
      releaseWgtToRunPath(mpId, path, (code: number, error?: Error) => {
        // 当前 SDK 使用 1 表示释放成功，-1 表示失败。
        if (code !== 1 || error) {
          reject(error ?? new Error('释放小程序资源失败，错误码: ' + code))
          return
        }
        resolve()
      })
    })
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
  }

  routesAction(type: MyType) {
    switch (type) {
      case MyType.header:
        break
      case MyType.ranking:
        navPathStack.pushPath({ name: 'Rank' })
        break
      case MyType.myCoin:
        navPathStack.pushPath({ name: 'MyCoin' })
        break
      case MyType.myCollect:
        navPathStack.pushPath({ name: 'MyCollect' })
        break
      case MyType.webExample:
        navPathStack.pushPath({ name: 'WebExample' })
        break
      case MyType.webComponent:
        navPathStack.pushPath({ name: 'WebComponent' })
        break
      case MyType.uniApp:
        navPathStack.pushPath({ name: RouterName.ObservedV2Test })
        break
      case MyType.environmentSwitch:
        LogUtil.debug("点击了切换环境")
        navPathStack.pushPath({ name: 'EnvironmentSwitch' })
        break
      case MyType.uniAppMiniProgram:
        this.openLocalUniApp().catch((error: Error) => {
          LogUtil.error("打开 UniApp 小程序失败: " + error.message)
          promptAction.showToast({ message: "打开小程序失败: " + error.message })
        })
        break
      case MyType.setting:
        navPathStack.pushPath({ name: 'Setting' })
        break
    }
  }
}

@Builder
export function ProfileBuilder() {
  Profile()
}

export { Profile }