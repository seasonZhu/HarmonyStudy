import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { RankModel } from '../model/RankModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { RankViewModel } from '../viewModel/RankViewModel';
import { LogUtil } from '@pura/harmony-utils';
import { ListConfig } from '../constants/StyleConstants';
import { RouterName } from '../router/RouterName'

@Entry({routeName: RouterName.Rank})
@Component
struct Rank {
  @State listDataSource: BaseListDataSource<RankModel> = new BaseListDataSource<RankModel>()

  @State listData: RankModel[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel = new RankViewModel()

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
    .title("积分排名")
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
          const ranks: RankModel[] = await this.viewModel.getRankList(ScrollActionType.refresh)
          this.listDataSource.refreshData(ranks)
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
          this.viewModel.getRankList(ScrollActionType.loadMore)
            .then((ranks: RankModel[]) => {
              this.listDataSource.loadMoreData(ranks)
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
      LazyForEach(this.listDataSource, (item: RankModel) => {
        ListItem() {
          Column() {
            Text(item.username)
              .padding({top: 8, left: 16})

            Text(`排名：${item.rank} 等级：${item.level} 积分：${item.coinCount}`)
              .padding({top: 8, left: 16})
          }
          .alignItems(HorizontalAlign.Start)
        }
        .height(66)
      })
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .height("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    this.viewModel.getRankList(ScrollActionType.refresh)
      .then((ranks: RankModel[]) => {
        this.listDataSource.refreshData(ranks)
        this.status = ViewStatus.success
      })
      .catch((error: Error) => {
        LogUtil.error("加载数据失败: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }
}

@Builder
export function RankBuilder() {
  Rank()
}
