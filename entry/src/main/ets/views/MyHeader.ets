import AccountManager from '../accountManager/AccountManager';

@Component
export struct MyHeader {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Image($r("app.media.icon_76"))
          .width(60)
          .width(60)
          .borderWidth(0.5)
          .borderColor(Color.Grey)
          .borderRadius(30)

        Text("等级 --  排名 --  积分 --")
          .fontSize(17)
          .textAlign(TextAlign.Center)
          .padding({ top: 16 })
      }
      .width('100%')
    }
    .height('100%')
  }
}