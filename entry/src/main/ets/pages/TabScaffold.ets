import { BaseListDataSource } from '../model/BaseListDataSource';
import { ViewStatus } from '../Enum/ViewStatus';
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { TabModel } from '../model/TabModel';
import { TabScaffoldViewModel } from '../viewModel/TabScaffoldViewModel';
import { StringUtils } from '../utils/StringUtils';
import { TabsDetail } from './TabsDetail';
import { ContentType } from '../enum/ContentType';

@Entry
@Component
export struct TabScaffold {

  @Prop contentType: ContentType

  @State datas: TabModel[] = []

  @State status: ViewStatus = ViewStatus.loading

  viewModel!: TabScaffoldViewModel

  @State curentIndex: number = 0

  private tabsController = new TabsController()

  build() {

    Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
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
      this.curentIndex = index
      this.tabsController.changeIndex(index)
    })
    .onGestureSwipe((index, event) => {
      this.curentIndex = index
      this.tabsController.changeIndex(index)
    })
  }

  @Builder
  getPage(model: TabModel) {
    TabContent() {
      TabsDetail({contentType: this.contentType, tab: model})
    }.tabBar(StringUtils.replaceHtmlElement(model.name?.toString() ?? ""))
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel = new TabScaffoldViewModel(this.contentType)
    let response: AxiosResponse<BaseResponse<TabModel[]>> = await this.viewModel.getTabs()

    this.datas = response.data.data
    console.info(this.datas.length.toString())

    if (response.data.errorCode == 0) {
      this.status = ViewStatus.success
    } else {
      this.status = ViewStatus.error
    }
  }
}