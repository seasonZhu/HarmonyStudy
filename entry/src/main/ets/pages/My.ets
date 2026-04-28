import { getTitleByMyType, MyType } from '../enum/MyType'
import { allMyTypeCases } from '../enum/MyType'
import { UserInfoModel } from '../model/UserInfoModel'
import { navPathStack } from '../router/navPathStack'
import { MyHeader } from '../views/MyHeader'
import { LogUtil } from '@pura/harmony-utils'
import { emitter } from '@kit.BasicServicesKit'
import { LOGIN_SUCCESS_EVENT } from './Login'

@Entry({routeName: 'My'})
@Component
struct My {

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
        ForEach(allMyTypeCases, (type: MyType) => {
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
                  Text(getTitleByMyType(type))
                    .margin({
                      left: 32
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
        navPathStack.pushPath({ name: 'ObservedV2TestPage' })
        break
      case MyType.environmentSwitch:
        LogUtil.debug("点击了切换环境")
        navPathStack.pushPath({ name: 'EnvironmentSwitch' })
        break
      case MyType.setting:
        navPathStack.pushPath({ name: 'Setting' })
        break
    }
  }
}

@Builder
export function MyBuilder() {
  My()
}

export { My }