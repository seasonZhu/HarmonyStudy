import { router } from '@kit.ArkUI';
import { RouteConstant } from './RouteConstant';

@Entry({routeName: RouteConstant.mainPage})
@Component
struct MainPage {
  @State message: string = 'This is librarySDK Main Page';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(20)
      }
      .width('100%')
    }
    .height('100%')
    .onClick(() => {
      router.pushNamedRoute({ name: "librarySDK_SecondPage" })
    })
  }
}

export { MainPage }
