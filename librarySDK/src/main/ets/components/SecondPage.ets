import { router } from '@kit.ArkUI';
import { RouteConstant } from './RouteConstant';

@Entry({routeName: RouteConstant.secondPage})
@Component
export struct SecondPage {
  @State message: string = 'This is librarySDK Second Page';

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
      router.back({url: "pages/Index"})
    })
  }
}