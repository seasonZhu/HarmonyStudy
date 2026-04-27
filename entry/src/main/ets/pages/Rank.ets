import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { RankModel } from '../model/RankModel';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { RankViewModel } from '../viewModel/RankViewModel';
import { LogUtil } from '@pura/harmony-utils';
import { ListDataProcessor } from '../utils/ListDataProcessor';
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
          LogUtil.debug("点击了重试按钮")
        },
      })
    }
    .title("积分排名")
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
      // 可选项，下拉刷新回调
      onRefresh: async () => {
        let result: AxiosResponse<BaseResponse<PageModel<RankModel>>> = await this.viewModel.getRankList(ScrollActionType.refresh)
        ListDataProcessor.processPagedListData(
          this.listDataSource,
          result,
          ScrollActionType.refresh,
          (status: ViewStatus) => {
            this.status = status
          }
        )
        return '刷新成功'
      },
      // 可选项，上拉加载更多回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getRankList(ScrollActionType.loadMore)
            .then((result: AxiosResponse<BaseResponse<PageModel<RankModel>>>) => {
              ListDataProcessor.processPagedListData(
                this.listDataSource,
                result,
                ScrollActionType.loadMore,
                (status: ViewStatus) => {
                  this.status = status
                }
              )
              resolve('上拉完成');
            })
            .catch((error: AxiosError) => {
              resolve('上拉失败');
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
    this.viewModel.getRankList(ScrollActionType.refresh)
      .then((result: AxiosResponse<BaseResponse<PageModel<RankModel>>>) => {
        ListDataProcessor.processPagedListData(
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
}

@Builder
export function RankBuilder() {
  Rank()
}