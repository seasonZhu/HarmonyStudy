import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { InfoCell } from '../views/InfoCell';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { SearchResultViewModel } from '../viewModel/SearchResultViewModel';
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'
import { KeywordInfo } from '../entity/KeywordInfo';
import { LogUtil } from '@pura/harmony-utils';
import { ListDataProcessor } from '../utils/ListDataProcessor';
import { ListConfig } from '../constants/StyleConstants';

@Entry({routeName: RouterName.SearchResult})
@Component
struct SearchResult {
  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  @State keywordInfo: KeywordInfo = { k: '' }

  private scroller = new Scroller()

  private viewModel = new SearchResultViewModel()

  build() {
      NavDestination() {
        StatusWeight({
          status: this.status,
          contentBuilder: () => {
            this.getRefreshView()
          },
        onRetry: () => {
          this.loadData()
        },
        })
      }
      .title(this.keywordInfo.k)
      .onReady((context: NavDestinationContext) => {
        this.keywordInfo = context.pathInfo.param as KeywordInfo
        this.loadData()
      })
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
        let result: AxiosResponse<BaseResponse<PageModel<Article>>> = await this.viewModel.postSearchResultList(ScrollActionType.refresh, this.keywordInfo)
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
          this.viewModel.postSearchResultList(ScrollActionType.loadMore, this.keywordInfo)
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
      })
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .padding({ left: ListConfig.HORIZONTAL_PADDING, right: ListConfig.HORIZONTAL_PADDING })
    //.divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    // 数据加载在 onReady 中调用
  }

  private loadData(): void {
    this.viewModel.postSearchResultList(ScrollActionType.refresh, this.keywordInfo)
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
export function SearchResultBuilder() {
  SearchResult()
}