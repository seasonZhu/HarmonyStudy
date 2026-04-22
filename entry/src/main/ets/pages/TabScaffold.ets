import { BaseListDataSource } from '../model/BaseListDataSource';
import { ViewStatus } from '../enum/ViewStatus';
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { TabModel } from '../model/TabModel';
import { TabScaffoldViewModel } from '../viewModel/TabScaffoldViewModel';
import { StringUtils } from '../utils/StringUtils';
import { TabsDetail } from './TabsDetail';
import { ContentType, getTitle } from '../enum/ContentType';
import { LogUtil } from '@pura/harmony-utils';
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';

@Entry
@Component
struct TabScaffold {

  @Prop contentType: ContentType

  @State datas: TabModel[] = []

  @State status: ViewStatus = ViewStatus.loading

  viewModel!: TabScaffoldViewModel

  @State currentIndex: number = 0

  private tabsController = new TabsController()

  private loadingHelper = new LoadingDialogHelper('加载中...')

  build() {

    Navigation() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.tabsController }) {
        ForEach(this.datas, (item: TabModel) => {
          this.getPage(item)
        })
      }
      .scrollable(true)
      .vertical(false)
      .barWidth('100%')
      .barHeight(44)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.currentIndex = index
        this.tabsController.changeIndex(index)
      })
      .onGestureSwipe((index, event) => {
        this.currentIndex = index
        this.tabsController.changeIndex(index)
      })
    }
    .title(getTitle(this.contentType))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .hideBackButton(true)
  }

  @Builder
  getPage(model: TabModel) {
    TabContent() {
      TabsDetail({contentType: this.contentType, tab: model})
    }
    //.tabBar(new SubTabBarStyle(StringUtils.replaceHtmlElement(model.name?.toString() ?? "")))
    .tabBar(StringUtils.replaceHtmlElement(model.name?.toString() ?? ""))
  }

  @Builder
  getTabBarText(model: TabModel) {
    Text(StringUtils.replaceHtmlElement(model.name?.toString() ?? ""))
      .fontColor($r("app.color.mainBlue"))
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel = new TabScaffoldViewModel(this.contentType)

    try {
      let response: AxiosResponse<BaseResponse<TabModel[]>> = await this.loadingHelper.wrap(
        this.viewModel.getTabs()
      )

      this.datas = response.data.data
      LogUtil.debug(this.datas.length.toString())

      if (response.data.errorCode == 0) {
        this.status = ViewStatus.success
      } else {
        this.status = ViewStatus.error
      }
    } catch (error) {
      LogUtil.debug("加载Tab失败: " + JSON.stringify(error))
      this.status = ViewStatus.error
    }
  }

  aboutToDisappear(): void {
    this.loadingHelper.destroy()
  }
}

@Builder
export function TabScaffoldBuilder() {
  TabScaffold()
}

export { TabScaffold }