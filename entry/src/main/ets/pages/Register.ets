import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { LoginViewModel, RegisterResult } from '../viewModel/LoginViewModel'
import { RouterName } from '../router/RouterName'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';
import { navPathStack } from '../router/navPathStack';

@Entry({routeName: RouterName.Register})
@ComponentV2
struct Register {

  @Local username: string = ""

  @Local password: string = ""

  @Local repassword: string = ""

  viewModel = new LoginViewModel()

  private loadingHelper = new LoadingDialogHelper('正在注册...')

  build() {
    NavDestination() {
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
                try {
                  const result: RegisterResult = await this.loadingHelper.wrap(
                    this.viewModel.registerWithUserInfo({
                      username: this.username,
                      password: this.password,
                      repassword: this.repassword
                    })
                  )

                  if (result && result.success && result.userInfo) {
                    navPathStack.pop(result.userInfo)
                  } else if (result && result.errorCode != null) {
                    ToastUtil.showToast($r('app.string.get_user_info_failed'))
                  } else {
                    ToastUtil.showToast($r('app.string.register_failed'))
                  }
                } catch (error) {
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
  }

  aboutToDisappear(): void {
    this.loadingHelper.destroy()
  }

  mockBackToRoot() {
    let params: UserInfoModel = { coinCount: 1000, level: 1000, nickname: "nickname", rank: "1000", userId: 1000, username: "1000" }
    navPathStack.pop(params)
  }
}

@Builder
export function RegisterBuilder() {
  Register()
}