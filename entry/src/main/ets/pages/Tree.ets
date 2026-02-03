import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshConfigurator, PullToRefreshType } from '@ohos/pulltorefresh';
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { TabModel } from '../model/TabModel';
import { TreeCell } from '../views/TreeCell';
import { TabScaffoldViewModel } from '../viewModel/TabScaffoldViewModel';
import { ContentType } from '../enum/ContentType';
import { LogUtil } from '@pura/harmony-utils';

@Entry
@Component
struct Tree {

  @State listDataSource: BaseListDataSource<TabModel> = new BaseListDataSource<TabModel>()

  @State listData: TabModel[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  viewModel!: TabScaffoldViewModel

  build() {
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          // 这个地方不能直接将一个组件放在里面，必须使用一个@Builder装饰器修饰的函数
          this.getRefreshView()
        },
        onRetry: async () => {
          let result: AxiosResponse = await this.viewModel.getTabs()
          this.processResponseData(result, ScrollActionType.refresh)
        },
      })
    }
    .title("体系")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .hideBackButton(true)
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      // 必传项，容器主体布局类型
      pullToRefreshType: PullToRefreshType.LIST,
      // 必传项，控制是否进行下拉刷新
      refreshing: $refreshing,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      customList: () => {
        // 一个用@Builder修饰过的UI方法
        this.getListView()
      },
      refreshConfigurator: this.setNoLoadMoreRefreshConfig(),
      // 可选项，下拉刷新回调
      onRefresh: async () => {
        let result: AxiosResponse = await this.viewModel.getTabs()
        this.processResponseData(result, ScrollActionType.refresh)
        return '刷新成功'
      },
    })
  }

  @Builder
  private getListView() {
    List({ space: 20, scroller: this.scroller }) {
      LazyForEach(this.listDataSource, (item: TabModel) => {
        TreeCell({item: item})
      })
    }
    .width("100%")
    .backgroundColor('#FFFFFF')
    .divider({ strokeWidth: 0.25, color: "#2F2F2F" })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel = new TabScaffoldViewModel(ContentType.tree)
    this.viewModel.getTabs()
      .then((result: AxiosResponse) => {
        this.processResponseData(result, ScrollActionType.refresh)
      })
      .catch((error: AxiosError) => {
        LogUtil.debug("http error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }

  setNoLoadMoreRefreshConfig(): PullToRefreshConfigurator {
    let config = new PullToRefreshConfigurator()
    config.setHasLoadMore(false)
    return config
  }

  processResponseData(result: AxiosResponse<BaseResponse<TabModel[]>>, type: ScrollActionType) {
    if (type == ScrollActionType.refresh) {
      this.listDataSource.removeAll()

      let response = result.data

      response.data.forEach((item) => {
        this.listDataSource.addData(item)
      })

      if (this.listDataSource.originData.length == 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }
    }
  }
}

export { Tree }
