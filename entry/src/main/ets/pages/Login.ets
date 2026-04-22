import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { LoginViewModel, LoginResult } from '../viewModel/LoginViewModel'
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';

@Entry({routeName: RouterName.Login})
@ComponentV2
struct Login {

  @Local username: string = ""

  @Local password: string = ""

  viewModel = new LoginViewModel()

  private loadingHelper = new LoadingDialogHelper('正在登录...')

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
            .inputFilter('[0-9]', (_e) => {
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

          Row() {
            Blank()
              .layoutWeight(1)

            Text("还没有账号？进行注册")
              .decoration({
                type: TextDecorationType.Underline,
                color: $r('app.color.text_grey')
              })
              .fontColor($r('app.color.text_grey'))
              .fontSize(15)
              .maxLines(1)
              .onClick(() => {
                Router.toRegister()
              })
              .margin({ right: 20 })
          }

          Button($r('app.string.login_button'), { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor($r('app.color.login_button'))
            .width("95%")
            .margin({ top: 20, left: 16, right: 16, bottom: 16 })
            .height(40)
            .fontSize(20)
            .onClick(async () => {
              try {
                const result: LoginResult = await this.loadingHelper.wrap(
                  this.viewModel.loginWithUserInfo({
                    username: this.username,
                    password: this.password
                  })
                )

                if (result && result.success && result.userInfo) {
                  ToastUtil.showToast($r('app.string.login_success'))
                  Router.backWithParams("", result.userInfo)
                } else {
                  ToastUtil.showToast($r('app.string.login_failed'))
                }
              } catch (error) {
                ToastUtil.showToast($r('app.string.login_failed'))
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .height('100%')

    }
    .title($r('app.string.login'))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  aboutToDisappear(): void {
    this.loadingHelper.destroy()
  }

  onPageShow(): void {
    let userInfo = Router.getParams() as UserInfoModel
    if (userInfo) {
      Router.backWithParams("", userInfo)
    }
  }

}

@Builder
export function LoginBuilder() {
  Login()
}