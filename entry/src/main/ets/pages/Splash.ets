/// HarmonyOS NEXT开发中，startWindowIcon可以设置全屏显示吗？
/// https://developer.huawei.com/consumer/cn/forum/topic/0202161484354054962
/// 不能，目前切图1260*2720

@Entry
@ComponentV2
struct Splash {
  @Local message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('SplashHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}

@Builder
export function SplashBuilder() {
  Splash()
}