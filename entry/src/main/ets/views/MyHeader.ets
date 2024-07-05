import AccountManager from '../accountManager/AccountManager';
import { proccessUserInfo, UserInfoModel } from '../model/UserInfoModel'

@Component
export struct MyHeader {

  @Prop userInfo: UserInfoModel

  build() {
    Row() {
      Column() {
        Image($r("app.media.icon_76"))
          .width(60)
          .width(60)
          .borderWidth(0.5)
          .borderColor(Color.Grey)
          .borderRadius(30)

        if (this.userInfo.username) {
          Text(this.userInfo.username)
            .fontSize(17)
            .textAlign(TextAlign.Center)
            .padding({ top: 8 })
        }

        Text(proccessUserInfo(this.userInfo))
          .fontSize(17)
          .textAlign(TextAlign.Center)
          .padding({ top: 16 })
      }
      .width('100%')
    }
    .height('100%')
  }
}