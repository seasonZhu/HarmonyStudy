import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh } from '@ohos/pulltorefresh'
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

@Entry
@Component
export struct TabsDetail {

  @Prop contentType: ContentType

  @Prop tab: TabModel

  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  private scroller = new Scroller()

  private viewModel!: TabsDetailViewModel

  build() {
    Column() {
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
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $listData,
      // 必传项，需绑定传入主体布局内的列表或宫格组件，不然可能滑不动
      scroller: this.scroller,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      customList: () => {
        // 一个用@Builder修饰过的UI方法
        this.getListView()
      },
      // 可选项，下拉刷新回调
      onRefresh: async () => {
        let result: AxiosResponse<BaseResponse<PageModel<Article>>> = await this.viewModel.getTabsDetailList(ScrollActionType.refresh)
        this.processResponseData(result, ScrollActionType.refresh)
        return '刷新成功'
      },
      // 可选项，上拉加载更多回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.getTabsDetailList(ScrollActionType.loadMore)
            .then((result: AxiosResponse<BaseResponse<PageModel<Article>>>) => {
              this.processResponseData(result, ScrollActionType.loadMore)
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
    .width("100%")
    .backgroundColor('#FFFFFF')
    .divider({ strokeWidth: 0.25, color: "#2F2F2F" })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.debug("重写该方法，改为异步，还是会走这里")

    this.viewModel = new TabsDetailViewModel(this.contentType, this.tab)

    this.viewModel.getTabsDetailList(ScrollActionType.refresh)
      .then((result: AxiosResponse<BaseResponse<PageModel<Article>>>) => {
        this.processResponseData(result, ScrollActionType.refresh)
      })
      .catch((error: AxiosError) => {
        LogUtil.debug("http error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });

  }

  processResponseData(result: AxiosResponse<BaseResponse<PageModel<Article>>>, type: ScrollActionType) {

    let response = result.data as BaseResponse<PageModel<Article>>

    if (type == ScrollActionType.refresh) {
      this.listDataSource.removeAll()

      response.data.datas.forEach((item) => {
        this.listDataSource.addData(item)
      })

      if (this.listDataSource.originData.length == 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }

    } else {
      response.data.datas.forEach((item) => {
        this.listDataSource.addData(item)
      })

      this.status = ViewStatus.success
    }
  }
}