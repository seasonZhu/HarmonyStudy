import { TabType, TabTypeModel, allTabTypeCases, getTabModel, } from '../enum/TabType';
import { Home } from './Home';
import { My } from './My';
import { TabScaffold } from './TabScaffold';
import { Tree } from './Tree';
import { ContentType } from '../enum/ContentType';
import { IndexViewModel } from '../viewModel/IndexViewModel';
import { UserInfoModel } from '../model/UserInfoModel';
import { BaseResponse } from '../model/BaseResponse';
import { AxiosResponse } from '@ohos/axios';
import { PreferencesUtil, ToastUtil } from '@pura/harmony-utils'
import { Routes } from '../routes/Routes'

@Preview
@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  @State userInfo: UserInfoModel = {}

  @Provide loginSuccessUserInfo: UserInfoModel = {}

  private tabsController = new TabsController()

  private viewModel = new IndexViewModel()
  
  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      ForEach(allTabTypeCases, (type: TabType) => {
        this.getPage(type)
      })
    }
    .scrollable(false)
    .vertical(false)
    .barWidth('100%')
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder
  tabBarItem(model: TabTypeModel) {
    Column({space:4}) {
      Image(this.currentIndex == model.index ? model.selectedImage : model.normalImage)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(model.title)
        .fontColor(this.currentIndex == model.index ? '#1698CE' : '#6B6B6B')
        .fontSize(12)
    }
    .onClick(() => {
      this.currentIndex = model.index;
      this.tabsController.changeIndex(model.index);
    })
  }

  @Builder
  getPage(type: TabType) {
    if (type == TabType.home) {
      TabContent() {
        Home()
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.project) {
      TabContent() {
        TabScaffold({contentType: ContentType.project})
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.publicNumber) {
      TabContent() {
        TabScaffold({contentType: ContentType.publicNumber})
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.tree) {
      TabContent() {
        Tree()
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else {
      TabContent() {
        My({userInfo: this.userInfo })
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    }
  }

  async aboutToAppear(): Promise<void> {
    let username = await PreferencesUtil.get("username", "") as string
    let password = await PreferencesUtil.get("password", "") as string

    if (username.length != 0 && password.length != 0) {
      ToastUtil.showToast("进行自动登录")
      let result = await this.viewModel.login({username: username, password: password})
      if (result) {
        let response: AxiosResponse<BaseResponse<UserInfoModel>> = await this.viewModel.getUserInfo()
        this.userInfo = response.data.data
      }
    }
  }

  onPageShow(): void {
    let userInfo = Routes.getParams() as UserInfoModel
    if (userInfo) {
      this.loginSuccessUserInfo = userInfo
    }
  }
}