import { router } from '@kit.ArkUI';
import { RouteConstant } from './RouteConstant';
import { LogUtil } from '@pura/harmony-utils';

/**
 * librarySDK 主页面
 *
 * @description
 * 展示 SDK 主功能入口
 */
@Entry({ routeName: RouteConstant.mainPage })
@Component
export struct MainPage {
  @State message: string = 'This is librarySDK Main Page';

  build() {
    Navigation() {
      Column() {
        // 顶部空白区域
        Blank()
          .width('100%')
          .layoutWeight(1)

        // 中间内容区域
        Column() {
          // Logo/图标
          Image($r('app.media.pic_harmoney_logo_new'))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 24 })

          // 标题
          Text('librarySDK')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 8 })

          // 副标题
          Text(this.message)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 32 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 底部按钮区域
        Column() {
          // 跳转到第二页面按钮
          Button('跳转到第二页面', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('app.color.mainBlue'))
            .width('90%')
            .height(44)
            .fontSize(16)
            .margin({ bottom: 12 })
            .onClick(() => {
              LogUtil.debug('MainPage: 跳转到 SecondPage');
              try {
                router.pushNamedRoute({ name: "librarySDK_SecondPage" });
              } catch (error) {
                LogUtil.error('MainPage: 跳转失败', JSON.stringify(error));
              }
            })

          // 功能按钮占位（可扩展）
          Button('更多功能', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('app.color.text_secondary'))
            .width('90%')
            .height(44)
            .fontSize(16)
            .margin({ bottom: 20 })
            .enabled(false)
            .opacity(0.5)
        }
        .width('100%')

        // 底部空白
        Blank()
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.bg_grey'))
    }
    .title('librarySDK 主页')
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }
}
