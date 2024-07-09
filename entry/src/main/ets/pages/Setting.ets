import { DialogUtil, ToastUtil } from '@pura/harmony-utils';
import { UserInfoModel } from '../model/UserInfoModel';
import { Routes } from '../routes/Routes';
import { LoginViewModel } from '../viewModel/LoginViewModel';
import { LoadingDialog } from '../httpRequest/LoadingDialog';
import { MainPage } from 'librarySDK/src/main/ets/components/MainPage';
import { SDKTools } from 'librarySDK/src/main/ets/components/SDKTools';

@Entry
@Component
struct Setting {
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({text: "正在登出..."}),
    // 点击遮障层退出时的回调
    cancel: () => {
    },
    //是否允许点击遮障层退出
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 2,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  viewModel = new LoginViewModel()

  build() {
    Navigation() {
      Column() {
        Image($r('app.media.pic_harmoney_logo_new'))// 直接加载网络地址，请填写一个具体的网络图片地址
          .objectFit(ImageFit.Auto)
          .width("100%")
          .backgroundColor(Color.Black)

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
    .title("设置")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {

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
    this.loadingDialogController.open()
    let result = await this.viewModel.logout()
    this.loadingDialogController.close()
    if (result) {
      ToastUtil.showToast("退出登录成功")
      let userInfo: UserInfoModel = {}
      Routes.back({ url:"", params: userInfo })
    } else {
      ToastUtil.showToast("退出登录失败")
    }
  }
}