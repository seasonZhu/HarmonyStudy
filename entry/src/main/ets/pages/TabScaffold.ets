import { BaseListDataSource } from '../model/BaseListDataSource';
import { ViewStatus } from '../enum/ViewStatus';
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
    NavDestination() {
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
    .hideBackButton(true)
  }

  @Builder
  getPage(model: TabModel) {
    TabContent() {
      TabsDetail({contentType: this.contentType, tab: model})
    }
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
      const tabs: TabModel[] = await this.loadingHelper.wrap(
        this.viewModel.getTabs()
      )

      this.datas = tabs
      LogUtil.debug(this.datas.length.toString())
      this.status = ViewStatus.success
    } catch (error) {
      LogUtil.error("加载Tab失败: " + JSON.stringify(error))
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
