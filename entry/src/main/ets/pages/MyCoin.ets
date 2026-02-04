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
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'
import { ListDataProcessor } from '../utils/ListDataProcessor';
import { ListConfig } from '../constants/StyleConstants';

export let PageMyCoin = "PageMyCoin"

// @Entry({routeName: PageMyCoin})
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
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          // 这个地方不能直接将一个组件放在里面，必须使用一个@Builder装饰器修饰的函数
          this.getRefreshView()
        },
        onRetry: () => {
          LogUtil.debug("点击了重试按钮")
        },
      })
    }
    .title($r('app.string.my_coin'))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
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
      // 可选项，上拉加载更多回调
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
              resolve('上拉失败');
            });
        });
      },
    })
  }

  @Builder
  private getListView() {
    List({ space: 20, scroller: this.scroller }) {
      LazyForEach(this.listDataSource, (item: MyCoinModel) => {
        ListItem() {
          Column() {
            Text(item.desc)
              .padding({top: 8, left: 16})

            Text(`获取积分原因：${item.reason}`)
              .padding({top: 8, left: 16})
          }
          .alignItems(HorizontalAlign.Start)

          //MyCoinCell({item: item})

          //MyCoinCellBuilder(item)
        }
        .height(66)
      })
    }
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.debug("重写该方法，改为异步，还是会走这里")

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

@Reusable
@Component
struct MyCoinCell {
  @Prop item: MyCoinModel

  build() {
    Column() {
      Text(this.item.desc)
        .padding({top: 8, left: 16})

      Text(`获取积分原因：${this.item.reason}`)
        .padding({top: 8, left: 16})
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Builder
function MyCoinCellBuilder(item: MyCoinModel) {
  Column() {
    Text(item.desc)
      .padding({top: 8, left: 16})

    Text(`获取积分原因：${item.reason}`)
      .padding({top: 8, left: 16})
  }
  .alignItems(HorizontalAlign.Start)
}