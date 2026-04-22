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
import { TabsDetailViewModel } from '../viewModel/TabsDetailViewModel';
import { ContentType } from '../enum/ContentType';
import { TabModel } from '../model/TabModel';
import { LogUtil } from '@pura/harmony-utils';
import { ListDataProcessor } from '../utils/ListDataProcessor';
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
          LogUtil.debug("点击了重试按钮")
        },
      })
    }
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
        let result: AxiosResponse<BaseResponse<PageModel<Article>>> = await this.viewModel.getTabsDetailList(ScrollActionType.refresh)
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
          this.viewModel.getTabsDetailList(ScrollActionType.loadMore)
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
      })
    }
    .cachedCount(ListConfig.CACHED_COUNT)
    .width("100%")
    .backgroundColor($r('app.color.white'))
    .divider({ strokeWidth: ListConfig.DIVIDER_STROKE_WIDTH, color: $r('app.color.divider_color') })
    .edgeEffect(EdgeEffect.None)
  }

  async aboutToAppear(): Promise<void> {
    this.viewModel = new TabsDetailViewModel(this.contentType, this.tab)

    this.viewModel.getTabsDetailList(ScrollActionType.refresh)
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
export function TabsDetailBuilder() {
  TabsDetail()
}

export { TabsDetail }