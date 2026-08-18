import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import { InfoCell } from '../views/InfoCell';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { TabsDetailViewModel } from '../viewModel/TabsDetailViewModel';
import { ContentType } from '../enum/ContentType';
import { TabModel } from '../model/TabModel';
import { LogUtil } from '@pura/harmony-utils';
import { ListConfig } from '../constants/StyleConstants';

@Entry
@Component
struct TabsDetail {

  @Prop contentType: ContentType

  @Prop tab: TabModel

  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  private viewModel!: TabsDetailViewModel

  build() {
    Column() {
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
          const pageData: PageModel<Article> = await this.viewModel.getTabsDetailList(ScrollActionType.refresh)
          this.listDataSource.refreshData(pageData.datas)
          
          if (this.listDataSource.originData.length === 0) {
            this.status = ViewStatus.empty
          } else {
            this.status = ViewStatus.success
          }
          return '刷新成功'
        } catch (error) {
          LogUtil.error("TabsDetail refresh error: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getTabsDetailList(ScrollActionType.loadMore)
            .then((pageData: PageModel<Article>) => {
              this.listDataSource.loadMoreData(pageData.datas)
              this.status = ViewStatus.success
              resolve('上拉完成');
            })
            .catch((error: Error) => {
              LogUtil.error("TabsDetail loadMore error: " + JSON.stringify(error))
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
    this.viewModel = new TabsDetailViewModel(this.contentType, this.tab)
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    this.viewModel.getTabsDetailList(ScrollActionType.refresh)
      .then((pageData: PageModel<Article>) => {
        this.listDataSource.refreshData(pageData.datas)
        
        if (this.listDataSource.originData.length === 0) {
          this.status = ViewStatus.empty
        } else {
          this.status = ViewStatus.success
        }
      })
      .catch((error: Error) => {
        LogUtil.error("TabsDetail load error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }
}

@Builder
export function TabsDetailBuilder() {
  TabsDetail()
}

export { TabsDetail }
