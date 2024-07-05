import { ToastUtil } from '@pura/harmony-utils';
import { UserInfoModel } from '../model/UserInfoModel';
import { Routes } from '../routes/Routes';
import { LoginViewModel } from '../viewModel/LoginViewModel';

@Entry
@Component
struct Setting {
  @State message: string = 'Hello World';

  viewModel = new LoginViewModel()

  build() {
    Navigation() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick( () => {
            this.logout()
          })
      }
      .width('100%')
      .height('100%')
    }
    .title("关于")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {

  }

  aboutToDisappear(): void {

  }

  async logout() {
    let result = await this.viewModel.logout()
    if (result) {
      ToastUtil.showToast("退出登录成功")
      let userInfo: UserInfoModel = {}
      Routes.back({ url:"", params: userInfo })
    } else {
      ToastUtil.showToast("退出登录失败")
    }
  }
}