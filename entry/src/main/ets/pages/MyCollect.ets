import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { MyCollectViewModel } from '../viewModel/MyCollectViewModel';
import { InfoCell } from '../views/InfoCell';
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil';
import { CollectActionType } from '../enum/CollectActionType';
import { LogUtil } from '@pura/harmony-utils';
import { ListDataProcessor } from '../utils/ListDataProcessor';
import { ListConfig } from '../constants/StyleConstants';
import { RouterName } from '../router/RouterName'

@Entry({routeName: RouterName.MyCollect})
@Component
struct MyCollect {
  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel = new MyCollectViewModel()

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
    .title($r('app.string.my_collect'))
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
        let result: AxiosResponse<BaseResponse<PageModel<Article>>> = await this.viewModel.getMyCollectList(ScrollActionType.refresh)
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
          this.viewModel.getMyCollectList(ScrollActionType.loadMore)
            .then((result: AxiosResponse<BaseResponse<PageModel<Article>>>) => {
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
      LazyForEach(this.listDataSource, (item: Article) => {
        ListItem() {
          InfoCell({
            article: item,
            onItemClick: (article: Article) => {
              LogUtil.debug("点击了cell " + article.link)
            },
            onCollect: (isCollect: boolean, article: Article) => {

            }
          })
        }
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          end: {
            builder: () => { this.itemEnd(item) },
            onAction: () => {
              animateTo({ duration: 1000 }, async  () => {
                /// 这里做网络请求，然后再进行数组的删除
                // let index = this.listDataSource.originData.indexOf(item)
                // this.listDataSource.remove(index)
                let result = await this.viewModel.collectAction(item.originId, CollectActionType.cancel)
                if (result) {
                  let index = this.listDataSource.originData.indexOf(item)
                  this.listDataSource.remove(index)
                }
              })
            },
            actionAreaDistance: 66,
            onEnterActionArea: () => {

            },
            onExitActionArea: () => {

            }
          }
        })
      }, (item: Article, index) => item.id.toString())
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  @Builder
  itemEnd(item: Article) {
    Row() {
      Button("取消收藏")
        .margin("4vp")
        .backgroundColor(Color.Red)
        .onClick( async  () => {
          let result = await this.viewModel.collectAction(item.originId, CollectActionType.cancel)
          if (result) {
            let index = this.listDataSource.originData.indexOf(item)
            this.listDataSource.remove(index)
          }
        })
    }
    .padding("4vp")
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel.getMyCollectList(ScrollActionType.refresh)
      .then((result: AxiosResponse<BaseResponse<PageModel<Article>>>) => {
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
export function MyCollectBuilder() {
  MyCollect()
}