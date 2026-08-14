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
import { ToastUtil, LogUtil } from '@pura/harmony-utils'
import { RouterName } from '../router/RouterName'
import { importHeadFile } from 'librarySDK';
import { navPathStack } from '../router/navPathStack';
import AccountManager from '../accountManager/AccountManager';

@Preview
@Entry({routeName: RouterName.Index})
@Component
struct Index {
  @State activeIndex: number = 0

  @State userInfo: UserInfoModel = {}

  @Provide loginSuccessUserInfo: UserInfoModel = {}

  private tabsController = new TabsController()

  private viewModel = new IndexViewModel()

  build() {
    Navigation(navPathStack) {
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
        this.activeIndex = index;
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  tabBarItem(model: TabTypeModel) {
    Column({space:4}) {
      Image(this.activeIndex == model.index ? model.selectedImage : model.normalImage)
        .height(24)
        .aspectRatio(1)
      Text(model.title)
        .fontColor(this.activeIndex == model.index ? $r('app.color.app_blue') : $r('app.color.text_secondary'))
        .fontSize(12)
    }
    .onClick(() => {
      this.activeIndex = model.index;
      this.tabsController.changeIndex(model.index);
    })
  }

  @Builder
  getPage(type: TabType) {
    TabContent() {
      if (type == TabType.home) {
        Home()
      } else if (type == TabType.project) {
        TabScaffold({contentType: ContentType.project})
      } else if (type == TabType.publicNumber) {
        TabScaffold({contentType: ContentType.publicNumber})
      } else if (type == TabType.tree) {
        Tree()
      } else {
        My()
      }
    }
    .tabBar(this.tabBarItem(getTabModel(type)))
  }

  async aboutToAppear(): Promise<void> {
    let loginModel = await AccountManager.shared().restoreLoginModel()
    if (loginModel) {
      ToastUtil.showToast($r('app.string.auto_login'))
      try {
        let response: AxiosResponse<BaseResponse<UserInfoModel>> = await this.viewModel.getUserInfo()
        if (response.data.errorCode == 0) {
          this.userInfo = response.data.data
          this.loginSuccessUserInfo = response.data.data
        }
      } catch (_error) {
        LogUtil.debug("auto login restore failed")
      }
    }
  }

  onPageShow(): void {
    /// 从模块传参过App侧
    let params: number[] = navPathStack.getParamByName('Index') as number[]
    if (params && params.length > 0) {
      let index: number = params[0]
      if (index != null) {
        this.activeIndex = index;
        this.tabsController.changeIndex(index)
      }
    }
  }
}

@Builder
export function IndexBuilder() {
  Index()
}