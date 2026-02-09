import { router } from '@kit.ArkUI';
import { RouteConstant } from './RouteConstant';
import { LogUtil, DialogUtil } from '@pura/harmony-utils';

/**
 * librarySDK 第二页面
 *
 * @description
 * 展示 SDK 第二页面，支持返回主页面
 */
@Entry({ routeName: RouteConstant.secondPage })
@Component
export struct SecondPage {
  @State message: string = 'This is librarySDK Second Page';

  /**
   * 显示返回确认对话框
   */
  private showBackDialog(): void {
    DialogUtil.showPrimaryDialog({
      title: "提示",
      message: "是否返回到首页？",
      primaryButton: {
        value: "取消",
        action: () => {
          LogUtil.debug('SecondPage: 取消返回');
        }
      },
      secondaryButton: {
        value: "确定",
        action: () => {
          this.backToIndex();
        }
      }
    });
  }

  /**
   * 返回到首页
   * 保持原有逻辑不变
   */
  private backToIndex(): void {
    LogUtil.debug('SecondPage: 返回到首页');
    try {
      /// 这里是entry项目中的注册的路由地址
      router.back({ url: "pages/Index", params: { "index": 0 } });
    } catch (error) {
      LogUtil.error('SecondPage: 返回失败', JSON.stringify(error));
    }
  }

  build() {
    Navigation() {
      Column() {
        // 顶部空白区域
        Blank()
          .width('100%')
          .layoutWeight(1)

        // 中间内容区域
        Column() {
          // 图标
          Text('📄')
            .fontSize(64)
            .margin({ bottom: 24 })

          // 标题
          Text('第二页面')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 8 })

          // 副标题
          Text(this.message)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 32 })

          // 信息卡片
          Column() {
            Text('页面信息')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 12 })

            Text('• 路由名称: librarySDK_SecondPage')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 8 })

            Text('• 点击返回按钮可返回首页')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ bottom: 24 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 底部按钮区域
        Column() {
          // 返回按钮
          Button('返回首页', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('app.color.mainBlue'))
            .width('90%')
            .height(44)
            .fontSize(16)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.showBackDialog();
            })

          // 直接返回按钮（无确认）
          Button('直接返回', { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('app.color.text_secondary'))
            .width('90%')
            .height(44)
            .fontSize(16)
            .margin({ bottom: 20 })
            .onClick(() => {
              this.backToIndex();
            })
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
    .title('第二页面')
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }
}
