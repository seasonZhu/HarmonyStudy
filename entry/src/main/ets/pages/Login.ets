import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { IndexViewModel } from '../viewModel/IndexViewModel'
import { BaseResponse } from '../model/BaseResponse';
import { AxiosResponse } from '@ohos/axios';
import { Routes } from '../routes/Routes'
import { UserInfoModel } from '../model/UserInfoModel';
import { LoadingDialog } from '../httpRequest/LoadingDialog';

@Entry
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

  @State username: string = "13437156081"

  @State password: string = "z19871031"

  viewModel = new IndexViewModel()

  build() {
    Navigation() {
        Column() {
          TextInput({ text: this.username, placeholder: '请输入手机号' })
            .type(InputType.Number)
            .placeholderColor(Color.Grey)
            .placeholderFont({ size: 14, weight: 400 })
            .caretColor(Color.Blue)
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
            .caretColor(Color.Blue)
            .maxLength(11)
            .width('95%')
            .height(40)
            .margin(20)
            .fontSize(14)
            .fontColor(Color.Black)
            .onChange((value: string) => {
              this.password = value
            })

          Button("登 录", { type: ButtonType.Capsule, stateEffect: true })
            .backgroundColor(0x317aff)
            .width("95%")
            .margin(20)
            .height(40)
            .fontSize(17)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .height('100%')
        .onClick( async () => {
          this.loadingDialogController.open()
          let result = await this.viewModel.login({username: "13437156081", password: "z19871031"})
          this.loadingDialogController.close()
          if (result) {
            let response: AxiosResponse<BaseResponse<UserInfoModel>> = await this.viewModel.getUserInfo()
            let userInfo = response.data.data
            Routes.back({params: userInfo, url: ""})
          } else {
            ToastUtil.showToast("登录失败")
          }
        })
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
}