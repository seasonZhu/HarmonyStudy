import { DialogUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import { UserInfoModel } from '../model/UserInfoModel';
import { RouterName } from '../router/RouterName'
import { LoginViewModel } from '../viewModel/LoginViewModel';
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';
import { MainPage } from 'librarySDK/src/main/ets/components/MainPage';
import { SDKTools } from 'librarySDK/src/main/ets/components/SDKTools';
import { router } from '@kit.ArkUI';
import { RouteConstant } from 'librarySDK';
import { navPathStack } from '../router/navPathStack';

@Entry({routeName: RouterName.Setting})
@Component
struct Setting {

  viewModel = new LoginViewModel()

  private loadingHelper = new LoadingDialogHelper('正在登出...')

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.pic_harmoney_logo_new'))// 直接加载网络地址，请填写一个具体的网络图片地址
          .objectFit(ImageFit.Auto)
          .width("100%")
          .backgroundColor(Color.Black)
          .onClick(() => {
            LogUtil.debug("跳转到SDK页面")
            try {
              router.pushNamedRoute({ name: RouteConstant.mainPage})
            } catch (error) {
              LogUtil.debug('跳转SDK页面失败: ' + JSON.stringify(error))
            }
          })

        Blank()
          .width("100")
          .height(100)

        Button("登 出", { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(0x317aff)
          .width("95%")
          .margin({ top: 40, left: 20, right: 20, bottom: 20 })
          .height(40)
          .fontSize(17)
          .onClick(() => {
            this.alertShow()
          })
      }
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.settings'))
  }

  aboutToDisappear(): void {

  }

  alertShow() {
    DialogUtil.showPrimaryDialog({
      title: "温馨提示",
      message: "是否退出登录？",
      primaryButton: {
        value: "取消",
        action: () => {

        }
      },
      secondaryButton: {
        value: "确定",
        action: () => {
          this.logout()
        }
      }
    })
  }

  async logout() {
    try {
      let result = await this.loadingHelper.wrap(this.viewModel.logout())
      if (result) {
        ToastUtil.showToast($r('app.string.logout_success'))
        let userInfo: UserInfoModel = {}
        navPathStack.pop(userInfo)
      } else {
        ToastUtil.showToast($r('app.string.logout_failed'))
      }
    } catch (error) {
      ToastUtil.showToast($r('app.string.logout_failed'))
    }
  }
}

@Builder
export function SettingBuilder() {
  Setting()
}