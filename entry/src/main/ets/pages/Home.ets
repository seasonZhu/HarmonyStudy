import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh, PullToRefreshType } from '@ohos/pulltorefresh'
import { Banner } from '../model/Banner'
import { BaseResponse } from '../model/BaseResponse';
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
import { ListDataProcessor } from '../utils/ListDataProcessor';
import { ListConfig } from '../constants/StyleConstants';
import { navPathStack } from '../router/navPathStack';

@Entry
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
        const result: HomeRefreshResult = await this.viewModel.refreshRequest()
        ListDataProcessor.processMixedRefresh(
          this.dataSource,
          this.listDataSource,
          result.bannerResponse,
          result.hotArticleResponse,
          result.normalArticleResponse,
          (status: ViewStatus) => {
            this.status = status
          },
          (hotArticles: Article[], normalArticles: Article[]) => hotArticles.concat(normalArticles)
        )
        return '刷新成功'
      },
      // 可选项，上拉加载更多回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.loadMoreRequest()
            .then((normalArticleResponse: AxiosResponse<BaseResponse<PageModel<Article>>>) => {
              ListDataProcessor.processMixedLoadMore(
                this.listDataSource,
                normalArticleResponse,
                (status: ViewStatus) => {
                  this.status = status
                }
              )
              resolve('上拉完成');
            })
            .catch((error: AxiosError) => {
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
    List({ space: 0, scroller: this.scroller }) {
      ListItem() {
        BannerView({data: $dataSource,
          itemClick: (item) => {
            LogUtil.debug($r('app.string.click_banner'))
            LogUtil.debug(item.url)
            const webLink: WebLink = { id: item.id, title: item.title, link: item.url, originId: null }
            navPathStack.pushPath({ name: 'WebPage', param: webLink })
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
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel.refreshRequest()
      .then((result: HomeRefreshResult) => {
        ListDataProcessor.processMixedRefresh(
          this.dataSource,
          this.listDataSource,
          result.bannerResponse,
          result.hotArticleResponse,
          result.normalArticleResponse,
          (status: ViewStatus) => {
            this.status = status
          },
          (hotArticles: Article[], normalArticles: Article[]) => hotArticles.concat(normalArticles)
        )
      })
      .catch((error: AxiosError) => {
        LogUtil.debug("http error: " + JSON.stringify(error))
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