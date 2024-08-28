import { getTitleByMyType, MyType } from '../enum/MyType'
import { allMyTypeCases } from '../enum/MyType'
import { UserInfoModel } from '../model/UserInfoModel'
import { Routes } from '../routes/Routes'
import { MyHeader } from '../views/MyHeader'

@Entry
@Component
export struct My {

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
        Routes.toRank()
        break
      case MyType.myCoin:
        Routes.toMyCoin()
        break
      case MyType.myCollect:
        Routes.toCollect()
        break
      case MyType.webExample:
        Routes.toWebExample()
        break
      case MyType.setting:
        Routes.toSetting()
        break
    }
  }

  aboutToAppear(): void {

  }

  update() {
    this.userInfo = this.loginSuccessUserInfo
  }
}