import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { Banner } from '../model/Banner'
import { BaseListDataSource } from '../model/BaseListDataSource';
import { BannerView } from '../views/BannerView';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { HomeViewModel, HomeRefreshResult } from '../viewModel/HomeViewModel';
import { InfoCell } from '../views/InfoCell';
import { StatusWeight } from '../views/StatusWeight';
import { ViewStatus } from '../enum/ViewStatus';
import { LogUtil } from '@pura/harmony-utils';
import { immersion } from '../utils/Immersion';
import { WebLink } from '../entity/WebLink';
import { ListConfig } from '../constants/StyleConstants';
import { navPathStack } from '../router/navPathStack';
import { RouterName } from '../router/RouterName';

@Entry({ routeName: RouterName.Home })
@Component
struct Home {

  @State message: string = 'loading'

  @State dataSource: BaseListDataSource<Banner> = new BaseListDataSource<Banner>()

  @State data: Banner[] = this.dataSource.originData

  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  @State refreshing: boolean = false

  private scroller = new Scroller()

  viewModel = new HomeViewModel()

  build() {
    NavDestination() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getRefreshView()
        },
        onRetry: () => {
          LogUtil.debug($r('app.string.click_retry'))
        },
      })
    }
    .title($r('app.string.home'))
    .hideBackButton(true)
    .menus(this.getIcon())
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
          const result: HomeRefreshResult = await this.viewModel.refreshRequest()
          
          // 处理 Banner 数据
          this.dataSource.refreshData(result.banners)
          
          // 合并置顶文章和普通文章
          const allArticles: Article[] = result.hotArticles.concat(result.normalArticles.datas)
          this.listDataSource.refreshData(allArticles)
          
          if (this.listDataSource.originData.length === 0) {
            this.status = ViewStatus.empty
          } else {
            this.status = ViewStatus.success
          }
          
          return '刷新成功'
        } catch (error) {
          LogUtil.error("Home refresh error: " + JSON.stringify(error))
          this.status = ViewStatus.error
          throw error as Error
        }
      },
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.loadMoreRequest()
            .then((pageData: PageModel<Article>) => {
              this.listDataSource.loadMoreData(pageData.datas)
              this.status = ViewStatus.success
              resolve('上拉完成');
            })
            .catch((error: Error) => {
              LogUtil.error("Home loadMore error: " + JSON.stringify(error))
              reject(error);
            });
        });
      },
    })
  }

  @Builder
  getIcon() {
    SearchIcon()
  }

  @Builder
  private getListView() {
    List({ space: ListConfig.SPACE, scroller: this.scroller }) {
      ListItem() {
        BannerView({data: $dataSource,
          itemClick: (item) => {
            LogUtil.debug($r('app.string.click_banner'))
            LogUtil.debug(item.url)
            const webLink: WebLink = { id: item.id, title: item.title, link: item.url, originId: null }
            navPathStack.pushPath({ name: 'WebBrowser', param: webLink })
          }})
      }
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
    this.viewModel.refreshRequest()
      .then((result: HomeRefreshResult) => {
        // 处理 Banner 数据
        this.dataSource.refreshData(result.banners)
        
        // 合并置顶文章和普通文章
        const allArticles: Article[] = result.hotArticles.concat(result.normalArticles.datas)
        this.listDataSource.refreshData(allArticles)
        
        if (this.listDataSource.originData.length === 0) {
          this.status = ViewStatus.empty
        } else {
          this.status = ViewStatus.success
        }
      })
      .catch((error: Error) => {
        LogUtil.error("Home load error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });
  }

  aboutToDisappear(): void {
    // 清理资源
  }

}

export { Home }

@Component
struct SearchIcon {
  build() {
    Image($r('app.media.search'))
      .width(60)
      .height(60)
      .padding(16)
      .onClick(() => {
        navPathStack.pushPath({ name: 'HotKey' })
      })
  }
  /// 沉浸式开与关
  immersionAction() {
    if (immersion.onOrOff == true) {
      immersion.onOrOffFullScreen(false, getContext(this))
    } else {
      immersion.onOrOffFullScreen(true, getContext(this))
    }
  }
}

@Builder
export function HomeBuilder() {
  Home()
}
