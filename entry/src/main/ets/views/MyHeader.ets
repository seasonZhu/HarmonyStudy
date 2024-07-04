import AccountManager from '../accountManager/AccountManager';

@Component
export struct MyHeader {

  @Prop userInfoFormat: string

  build() {
    Row() {
      Column() {
        Image($r("app.media.icon_76"))
          .width(60)
          .width(60)
          .borderWidth(0.5)
          .borderColor(Color.Grey)
          .borderRadius(30)

        Text(this.userInfoFormat)
          .fontSize(17)
          .textAlign(TextAlign.Center)
          .padding({ top: 16 })
      }
      .width('100%')
    }
    .height('100%')
  }
}