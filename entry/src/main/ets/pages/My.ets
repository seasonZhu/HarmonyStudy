import { getTitleByMyType, MyType } from '../enum/MyType'
import { allMyTypeCases } from '../enum/MyType'
import { UserInfoModel } from '../model/UserInfoModel'
import { Router } from '../router/Router'
import { MyHeader } from '../views/MyHeader'
import { router } from '@kit.ArkUI'
import { RouterName } from '../router/RouterName'
import { PageMyCoin } from './MyCoin'
import { LogUtil } from '@pura/harmony-utils'

@Entry
@Component
struct My {

  @Prop userInfo: UserInfoModel

  @Consume
  @Watch("update")
  loginSuccessUserInfo: UserInfoModel


  build() {
    Navigation() {
      List() {
        ForEach(allMyTypeCases, (type: MyType) => {
          ListItem() {
            if (type == MyType.header) {
              MyHeader({userInfo: this.userInfo})
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
    .title("我的")
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
        // router.pushNamedRoute({ name: PageMyCoin})
        // router.pushNamedRoute({ name: RouterName.MyCoin})
        // Router.pushName({url: PageMyCoin})
        // Router.pushName({url: RouterName.MyCoin})
        break
    }
  }

  aboutToAppear(): void {

  }

  update() {
    this.userInfo = this.loginSuccessUserInfo
  }
}

export { My }