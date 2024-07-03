

@CustomDialog
export struct LoadingDialog {
  controller?: CustomDialogController
  text?: string

  build() {
    Column() {
      LoadingProgress()
        .color('#FFFFFF')
        .width(60)
        .height(60)
        .margin({
          top: 10,
        })

      if (this.text) {
        Text(this.text)
          .fontSize(20)
          .fontColor('#FFFFFF')
          .margin({
            top: 20,
            bottom: 40,
          })
      }
    }
    .align(Alignment.Center)
    .width('100%')
    .backgroundColor('#2F2F2F')
  }
}