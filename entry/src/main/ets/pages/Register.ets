import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { IndexViewModel } from '../viewModel/IndexViewModel'
import { BaseResponse } from '../model/BaseResponse';
import { AxiosResponse } from '@ohos/axios';
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialog } from '../httpRequest/LoadingDialog';

@Entry({routeName: RouterName.Register})
@Component
struct Register {

  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({text: "正在注册..."}),
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

  @State username: string = ""

  @State password: string = ""

  @State repassword: string = ""

  viewModel = new IndexViewModel()

  build() {
    Navigation() {
      Column() {
        TextInput({ text: this.username, placeholder: '请输入手机号' })
          .type(InputType.PhoneNumber)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .caretColor($r('app.color.mainBlue'))
          .maxLength(11)
          .width('95%')
          .height(40)
          .margin(20)
          .fontSize(14)
          .fontColor(Color.Black)
          .inputFilter('[0-9]', (e) => {
            ToastUtil.showToast($r('app.string.phone_number_invalid'))
          })
          .onChange((value: string) => {
            this.username = value
          })

        TextInput({ text: this.password, placeholder: '请输入密码' })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .caretColor($r('app.color.mainBlue'))
          .maxLength(11)
          .width('95%')
          .height(40)
          .margin(20)
          .fontSize(14)
          .fontColor(Color.Black)
          .onChange((value: string) => {
            this.password = value
          })

        TextInput({ text: this.repassword, placeholder: '请再次输入密码' })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .caretColor($r('app.color.mainBlue'))
          .maxLength(11)
          .width('95%')
          .height(40)
          .margin(20)
          .fontSize(14)
          .fontColor(Color.Black)
          .onChange((value: string) => {
            this.repassword = value
          })

        Button($r('app.string.register_button'), { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor($r('app.color.login_button'))
          .width("95%")
          .margin({ top: 20, left: 16, right: 16, bottom: 16 })
          .height(40)
          .fontSize(20)
          .onClick(async () => {
              if (this.password === this.repassword) {
                this.loadingDialogController.open()
                let result = await this.viewModel.register({ username: this.username, password: this.password, repassword: this.repassword })
                this.loadingDialogController.close()
                if (result) {
                  let response: AxiosResponse<BaseResponse<UserInfoModel>> = await this.viewModel.getUserInfo()
                  let userInfo = response.data.data
                  if (response.data.errorCode == 0) {
                    Router.backWithParams("", userInfo)
                  } else {
                    ToastUtil.showToast($r('app.string.get_user_info_failed'))
                  }
                } else {
                  ToastUtil.showToast($r('app.string.register_failed'))
                }
              } else {
                ToastUtil.showToast($r('app.string.password_inconsistent'))
              }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .height('100%')

    }
    .title($r('app.string.register'))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  aboutToDisappear(): void {
    this.loadingDialogController.close()
  }

  mockBackToRoot() {
    let params: UserInfoModel = { coinCount: 1000, level: 1000, nickname: "nickname", rank: "1000", userId: 1000, username: "1000" }
    Router.backWithParams("", params)
  }
}