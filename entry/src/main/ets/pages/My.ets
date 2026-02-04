import { getTitleByMyType, MyType } from '../enum/MyType'
import { allMyTypeCases } from '../enum/MyType'
import { UserInfoModel } from '../model/UserInfoModel'
import { Router } from '../router/Router'
import { MyHeader } from '../views/MyHeader'
import { LogUtil } from '@pura/harmony-utils'

@Entry
@Component
struct My {

  @Consume
  loginSuccessUserInfo: UserInfoModel


  build() {
    Navigation() {
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
    }
    .title($r('app.string.my'))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .hideBackButton(true)
  }

  routesAction(type: MyType) {
    switch (type) {
      case MyType.header:
        break
      case MyType.ranking:
        Router.toRank()
        break
      case MyType.myCoin:
        Router.toMyCoin()
        break
      case MyType.myCollect:
        Router.toCollect()
        break
      case MyType.webExample:
        Router.toWebExample()
        break
      case MyType.webComponent:
        Router.toWebComponent()
        break
      case MyType.uniApp:
        Router.toObservedV2TestPage()
        break
      case MyType.environmentSwitch:
        LogUtil.debug("点击了切换环境")
        Router.toEnvironmentSwitch()
        break
      case MyType.setting:
        Router.toSetting()
        break
    }
  }
}

export { My }