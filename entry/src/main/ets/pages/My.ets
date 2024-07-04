import { ToastUtil } from '@pura/harmony-utils'
import { getTitleByMyType, MyType } from '../enum/MyType'
import { allTabTypeCases } from '../enum/TabType'
import { proccessUserInfo, UserInfoModel } from '../model/UserInfoModel'
import { Routes } from '../routes/Routes'
import { MyHeader } from '../views/MyHeader'

@Entry
@Component
export struct My {

  @Consume
  @Watch("update")
  userInfo: UserInfoModel

  @State format: string = `排名：-- 等级：-- 积分：--`


  build() {
    Navigation() {
      List() {
        ForEach(allTabTypeCases, (type: MyType) => {
          ListItem() {
            if (type == MyType.header) {
              MyHeader({format: this.format})
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
      case MyType.setting:
        Routes.toSetting()
        break
    }
  }

  update() {
    let message = proccessUserInfo(this.userInfo)
    ToastUtil.showToast(message)
    this.format = message

    setTimeout(() => {
      this.format = "1323y47834yr783y4"
    }, 10000)
  }
}