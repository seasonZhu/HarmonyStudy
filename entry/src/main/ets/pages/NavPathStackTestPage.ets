@Entry
@Component
struct NavPathStackTestPage {
  @State message: string = 'Hello World';
  @State receivedValue: number = 0;
  pathStack: NavPathStack | undefined = undefined;

  build() {
    NavDestination() {
      RelativeContainer() {
        Column() {
          Text('顺传值: ' + this.receivedValue)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 20 })

          Text(this.message)
            .id('NavPathStackTestPageHelloWorld')
            .fontSize($r('app.float.page_text_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor('#666666')

          Button('返回（逆传值 +100）')
            .width('80%')
            .height(44)
            .fontSize(16)
            .backgroundColor('#FF9800')
            .borderRadius(8)
            .margin({ top: 30 })
            .onClick(() => {
              // 逆传：通过 pop 返回值
              let result = this.receivedValue + 100
              this.pathStack?.pop(result)
            })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      }
      .height('100%')
      .width('100%')
    }
    .title('NavPathStackTest')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      // 接收顺传参数
      this.receivedValue = context.pathInfo.param as number
    })
  }
}

@Builder
export function NavPathStackTestPageBuilder() {
  NavPathStackTestPage()
}