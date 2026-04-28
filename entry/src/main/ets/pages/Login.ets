import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { LoginViewModel, LoginResult } from '../viewModel/LoginViewModel'
import { RouterName } from '../router/RouterName'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';
import { navPathStack } from '../router/navPathStack';
import { emitter } from '@kit.BasicServicesKit';
import { LogUtil } from '@pura/harmony-utils';

export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"

@Entry({routeName: RouterName.Login})
@ComponentV2
struct Login {

  @Local username: string = ""

  @Local password: string = ""

  viewModel = new LoginViewModel()

  private loadingHelper = new LoadingDialogHelper('正在登录...')

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
              navPathStack.pushPath({ name: 'Register' })
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
                emitter.emit(LOGIN_SUCCESS_EVENT, { data: { userInfo: result.userInfo } })
                navPathStack.pop()
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
    .onReady((context: NavDestinationContext) => {
      /// 就算什么都不传,params里面也不为空，里面
      let params = context.pathStack.getParamByName('Login') as UserInfoModel[]
      LogUtil.debug(`params: ${params}`)
      if (params && params.length > 0) {
        let some = params[0]!
        if (some === undefined) {
          LogUtil.debug("some is undefined")
        }
      }
    })
  }

  aboutToDisappear(): void {
    this.loadingHelper.destroy()
  }

}

@Builder
export function LoginBuilder() {
  Login()
}