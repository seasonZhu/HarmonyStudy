import { PullToRefresh, PullToRefreshConfigurator, PullToRefreshType } from '@ohos/pulltorefresh';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { TabModel } from '../model/TabModel';
import { TreeCell } from '../views/TreeCell';
import { TabScaffoldViewModel } from '../viewModel/TabScaffoldViewModel';
import { ContentType } from '../enum/ContentType';
import { LogUtil } from '@pura/harmony-utils';
import { ListConfig } from '../constants/StyleConstants';
import { RouterName } from '../router/RouterName';

@Entry({ routeName: RouterName.Tree })
@Component
struct Tree {

  @State listDataSource: BaseListDataSource<TabModel> = new BaseListDataSource<TabModel>()

  @State listData: TabModel[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel: TabScaffoldViewModel | null = null

  build() {
    NavDestination() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getRefreshView()
        },
        onRetry: async () => {
          try {
            const tabs: TabModel[] = await this.viewModel!.getTabs()
            this.listDataSource.refreshData(tabs)
            
            if (tabs.length === 0) {
              this.status = ViewStatus.empty
            } else {
              this.status = ViewStatus.success
            }
          } catch (error) {
            LogUtil.error("Tree retry error: " + JSON.stringify(error))
            this.status = ViewStatus.error
          }
        },
      })
    }
    .title("体系")
    .hideBackButton(true)
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      pullToRefreshType: PullToRefreshType.LIST,
      refreshing: $refreshing,
      customList: () => {
        this.getListView()
      },
      refreshConfigurator: this.setNoLoadMoreRefreshConfig(),
      onRefresh: async () => {
        try {
          const tabs: TabModel[] = await this.viewModel!.getTabs()
          this.listDataSource.refreshData(tabs)
          
          if (tabs.length === 0) {
            this.status = ViewStatus.empty
          } else {
            this.status = ViewStatus.success
          }
          return '刷新成功'
        } catch (error) {
          LogUtil.error("Tree refresh error: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
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
      .then((tabs: TabModel[]) => {
        this.listDataSource.refreshData(tabs)
        
        if (tabs.length === 0) {
          this.status = ViewStatus.empty
        } else {
          this.status = ViewStatus.success
        }
      })
      .catch((error: Error) => {
        LogUtil.error("Tree load error: " + JSON.stringify(error))
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
