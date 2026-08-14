import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { MyCoinModel } from '../model/MyCoinModel';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { MyCoinViewModel } from '../viewModel/MyCoinViewModel';
import { LogUtil } from '@pura/harmony-utils';
import { RouterName } from '../router/RouterName'
import { ListDataProcessor } from '../utils/ListDataProcessor';
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
        let result: AxiosResponse<BaseResponse<PageModel<MyCoinModel>>> = await this.viewModel.getMyCoinList(ScrollActionType.refresh)
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
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getMyCoinList(ScrollActionType.loadMore)
            .then((result: AxiosResponse<BaseResponse<PageModel<MyCoinModel>>>) => {
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
              LogUtil.debug("loadMore error: " + JSON.stringify(error))
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
      .then((result: AxiosResponse<BaseResponse<PageModel<MyCoinModel>>>) => {
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
export function MyCoinBuilder() {
  MyCoin()
}
