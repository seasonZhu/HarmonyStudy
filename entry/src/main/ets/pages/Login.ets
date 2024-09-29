import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { IndexViewModel } from '../viewModel/IndexViewModel'
import { BaseResponse } from '../model/BaseResponse';
import { AxiosResponse } from '@ohos/axios';
import { RouterName, Routes } from '../routes/Routes'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialog } from '../httpRequest/LoadingDialog';

@Entry({routeName: RouterName.Login})
@Component
struct Login {

  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({text: "正在登录..."}),
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
              ToastUtil.showToast("请输入11位手机号")
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
                color: "#3079FF"
              })
              .fontColor("#3079FF")
              .fontSize(15)
              .maxLines(1)
              .onClick(() => {
                Routes.toRegister()
              })
              .margin({ right: 20 })
          }

          Button("登 录", { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(0x317aff)
            .width("95%")
            .margin({ top: 40, left: 20, right: 20, bottom: 20 })
            .height(40)
            .fontSize(17)
            .onClick(async () => {
              this.loadingDialogController.open()
              let result = await this.viewModel.login({ username: "13437156081", password: "z19871031" })
              this.loadingDialogController.close()
              if (result) {
                let response: AxiosResponse<BaseResponse<UserInfoModel>> = await this.viewModel.getUserInfo()
                let userInfo = response.data.data
                Routes.back({ params: userInfo, url: "" })
              } else {
                ToastUtil.showToast("登录失败")
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .height('100%')

    }
    .title("登录")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  aboutToDisappear(): void {
    this.loadingDialogController.close()
  }

  onPageShow(): void {
    let userInfo = Routes.getParams() as UserInfoModel
    if (userInfo) {
      Routes.back({url: "", params: userInfo})
    }
  }

}