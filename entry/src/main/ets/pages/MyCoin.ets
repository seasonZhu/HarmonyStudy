import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { MyCoinModel } from '../model/MyCoinModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { MyCoinViewModel } from '../viewModel/MyCoinViewModel';
import { LogUtil } from '@pura/harmony-utils';
import { RouterName } from '../router/RouterName'
import { ListConfig } from '../constants/StyleConstants';

export let PageMyCoin = "PageMyCoin"

@Entry({routeName: RouterName.MyCoin})
@Component
struct MyCoin {
  @State listDataSource: BaseListDataSource<MyCoinModel> = new BaseListDataSource<MyCoinModel>()

  @State listData: MyCoinModel[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel = new MyCoinViewModel()

  build() {
    NavDestination() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getRefreshView()
        },
        onRetry: () => {
          this.reloadData()
        },
      })
    }
    .title($r('app.string.my_coin'))
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      pullToRefreshType: PullToRefreshType.LIST,
      refreshing: $refreshing,
      customList: () => {
        this.getListView()
      },
      onRefresh: async () => {
        try {
          const coins: MyCoinModel[] = await this.viewModel.getMyCoinList(ScrollActionType.refresh)
          this.listDataSource.refreshData(coins)
          this.status = ViewStatus.success
          return '刷新成功'
        } catch (error) {
          LogUtil.error("刷新失败: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getMyCoinList(ScrollActionType.loadMore)
            .then((coins: MyCoinModel[]) => {
              this.listDataSource.loadMoreData(coins)
              this.status = ViewStatus.success
              resolve('上拉完成');
            })
            .catch((error: Error) => {
              LogUtil.error("加载更多失败: " + JSON.stringify(error))
              this.status = ViewStatus.error
              reject(error)
            });
        });
      },
    })
  }

  @Builder
  private getListView() {
    List({ space: ListConfig.SPACE, scroller: this.scroller }) {
      LazyForEach(this.listDataSource, (item: MyCoinModel) => {
        ListItem() {
          Column() {
            Text(item.desc)
              .padding({top: 8, left: 16})

            Text(`获取积分原因：${item.reason}`)
              .padding({top: 8, left: 16})
          }
          .alignItems(HorizontalAlign.Start)
        }
        .height(66)
      })
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    this.viewModel.getMyCoinList(ScrollActionType.refresh)
      .then((coins: MyCoinModel[]) => {
        this.listDataSource.refreshData(coins)
        this.status = ViewStatus.success
      })
      .catch((error: Error) => {
        LogUtil.error("加载数据失败: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }
}

@Builder
export function MyCoinBuilder() {
  MyCoin()
}
