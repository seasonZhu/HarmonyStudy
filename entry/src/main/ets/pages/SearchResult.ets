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

  private scroller = new Scroller()

  private viewModel = new SearchResultViewModel()

  private keywordInfo = (Router.getParams() as KeywordInfo)

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
      .title(this.keywordInfo.k)
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
              resolve('上拉失败');
            });
        });
      },
    })
  }

  @Builder
  private getListView() {
    List({ space: 20, scroller: this.scroller }) {
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
    .cachedCount(3)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.debug("重写该方法，改为异步，还是会走这里")

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