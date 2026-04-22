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
import { ListDataProcessor } from '../utils/ListDataProcessor';
import { ListConfig } from '../constants/StyleConstants';

@Entry
@Component
struct Tree {

  @State listDataSource: BaseListDataSource<TabModel> = new BaseListDataSource<TabModel>()

  @State listData: TabModel[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel: TabScaffoldViewModel | null = null

  build() {
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getRefreshView()
        },
        onRetry: async () => {
          let result: AxiosResponse = await this.viewModel!.getTabs()
          ListDataProcessor.processArrayListData(
            this.listDataSource,
            result,
            ScrollActionType.refresh,
            (status: ViewStatus) => {
              this.status = status
            }
          )
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
        let result: AxiosResponse = await this.viewModel!.getTabs()
        ListDataProcessor.processArrayListData(
          this.listDataSource,
          result,
          ScrollActionType.refresh,
          (status: ViewStatus) => {
            this.status = status
          }
        )
        return '刷新成功'
      },
    })
  }

  @Builder
  private getListView() {
    List({ space: ListConfig.SPACE, scroller: this.scroller }) {
      LazyForEach(this.listDataSource, (item: TabModel) => {
        TreeCell({item: item})
      })
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel = new TabScaffoldViewModel(ContentType.tree)
    this.viewModel.getTabs()
      .then((result: AxiosResponse) => {
        ListDataProcessor.processArrayListData(
          this.listDataSource,
          result,
          ScrollActionType.refresh,
          (status: ViewStatus) => {
            this.status = status
          }
        )
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
}

@Builder
export function TreeBuilder() {
  Tree()
}

export { Tree }
