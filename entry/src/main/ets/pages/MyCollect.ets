import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { MyCollectViewModel } from '../viewModel/MyCollectViewModel';
import { InfoCell } from '../views/InfoCell';
import { CollectActionType } from '../enum/CollectActionType';
import { LogUtil } from '@pura/harmony-utils';
import { ListConfig } from '../constants/StyleConstants';
import { RouterName } from '../router/RouterName'
import { Skeleton, SkeletonItem } from 'utils';

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
        loadingBuilder: () => {
          this.getLoadingView()
        },
        onRetry: () => {
          this.reloadData()
        },
      })
    }
    .title($r('app.string.my_collect'))
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
          const pageData: PageModel<Article> = await this.viewModel.getMyCollectList(ScrollActionType.refresh)
          this.listDataSource.refreshData(pageData.datas)
          
          if (this.listDataSource.originData.length === 0) {
            this.status = ViewStatus.empty
          } else {
            this.status = ViewStatus.success
          }
          return '刷新成功'
        } catch (error) {
          LogUtil.error("MyCollect refresh error: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getMyCollectList(ScrollActionType.loadMore)
            .then((pageData: PageModel<Article>) => {
              this.listDataSource.loadMoreData(pageData.datas)
              this.status = ViewStatus.success
              resolve('上拉完成');
            })
            .catch((error: Error) => {
              LogUtil.error("MyCollect loadMore error: " + JSON.stringify(error))
              reject(error)
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
    .padding({ left: ListConfig.HORIZONTAL_PADDING, right: ListConfig.HORIZONTAL_PADDING })
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

  @Builder
  getLoadingView() {
    Skeleton() {
      Column() {
        Row({ space: 15 }) {
          SkeletonItem({ widthValue: 60 })
          SkeletonItem({ widthValue: 100 })
          SkeletonItem({ widthValue: 80 })
          SkeletonItem({ widthValue: 40 })
        }
        .padding(10)
        .width('100%')

        ForEach([1,2,3,4,5,6], () => {
          Column({ space: 20 }) {
            SkeletonItem()
            SkeletonItem({ widthValue: 200 })
          }
          .alignItems(HorizontalAlign.Start)
          .height(90)
          .padding(10)
        })
      }
      .padding(16)
    }
  }

  async aboutToAppear(): Promise<void> {
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    this.viewModel.getMyCollectList(ScrollActionType.refresh)
      .then((pageData: PageModel<Article>) => {
        this.listDataSource.refreshData(pageData.datas)
        
        if (this.listDataSource.originData.length === 0) {
          this.status = ViewStatus.empty
        } else {
          this.status = ViewStatus.success
        }
      })
      .catch((error: Error) => {
        LogUtil.error("MyCollect load error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }
}

@Builder
export function MyCollectBuilder() {
  MyCollect()
}
