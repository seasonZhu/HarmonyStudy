import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { InfoCell } from '../views/InfoCell';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { SearchResultViewModel } from '../viewModel/SearchResultViewModel';
import { RouterName } from '../router/RouterName'
import { KeywordInfo } from '../entity/KeywordInfo';
import { LogUtil } from '@pura/harmony-utils';
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
      pullToRefreshType: PullToRefreshType.LIST,
      refreshing: $refreshing,
      customList: () => {
        this.getListView()
      },
      onRefresh: async () => {
        try {
          const pageData: PageModel<Article> = await this.viewModel.searchArticles(ScrollActionType.refresh, this.keywordInfo)
          this.listDataSource.refreshData(pageData.datas)
          
          if (this.listDataSource.originData.length === 0) {
            this.status = ViewStatus.empty
          } else {
            this.status = ViewStatus.success
          }
          return '刷新成功'
        } catch (error) {
          LogUtil.error("SearchResult refresh error: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.searchArticles(ScrollActionType.loadMore, this.keywordInfo)
            .then((pageData: PageModel<Article>) => {
              this.listDataSource.loadMoreData(pageData.datas)
              this.status = ViewStatus.success
              resolve('上拉完成');
            })
            .catch((error: Error) => {
              LogUtil.error("SearchResult loadMore error: " + JSON.stringify(error))
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
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    // 数据加载在 onReady 中调用
  }

  private loadData(): void {
    this.viewModel.searchArticles(ScrollActionType.refresh, this.keywordInfo)
      .then((pageData: PageModel<Article>) => {
        this.listDataSource.refreshData(pageData.datas)
        
        if (this.listDataSource.originData.length === 0) {
          this.status = ViewStatus.empty
        } else {
          this.status = ViewStatus.success
        }
      })
      .catch((error: Error) => {
        LogUtil.error("SearchResult load error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }
}

@Builder
export function SearchResultBuilder() {
  SearchResult()
}
