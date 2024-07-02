import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { PullToRefresh } from '@ohos/pulltorefresh'
import { Banner } from '../model/Banner'
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { BannerView } from '../views/BannerView';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { HomeViewModel } from '../viewModel/HomeViewModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import provider from '../httpRequest/Provider';
import { LoadingDialog } from '../httpRequest/LoadingDialog';
import { InfoCell } from '../views/InfoCell';
import { StatusWeight } from '../views/StatusWeight';
import { PagesConstant, Router } from '../router/Router';
import { ViewStatus } from '../enum/ViewStatus';

@Entry
@Component
export struct Home {

  @State message: string = "正在加载"

  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog(),
    // 点击遮障层退出时的回调
    cancel: () => {
    },
    //是否允许点击遮障层退出
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 2,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  @State dataSource: BaseListDataSource<Banner> = new BaseListDataSource<Banner>()

  /// 这个地方我写个空数组还是this.dataSource.originData，好像都没有关系
  @State data: Banner[] = this.dataSource.originData

  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  @State listData: Article[] = this.listDataSource.originData

  @State status: ViewStatus = ViewStatus.loading

  private scroller = new Scroller()

  viewModel = new HomeViewModel()

  build() {
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          // 这个地方不能直接将一个组件放在里面，必须使用一个@Builder装饰器修饰的函数
          this.getRefreshView()
        },
        onRetry: () => {
          console.log("点击了重试按钮")
        },
      })
    }
    .title("首页")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .hideBackButton(true)
    .menus(this.getIcon())
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      // 必传项，列表组件所绑定的数据
      data: $data,
      // 必传项，需绑定传入主体布局内的列表或宫格组件，不然可能滑不动
      scroller: this.scroller,
      // 必传项，自定义主体布局，内部有列表或宫格组件
      customList: () => {
        // 一个用@Builder修饰过的UI方法
        this.getListView()
      },
      // 可选项，下拉刷新回调
      onRefresh: async () => {
        //this.loadingDialogController.open()
        let results: AxiosResponse[] = await this.viewModel.networkRequest(ScrollActionType.refresh)
        //this.loadingDialogController.close()
        this.processResponseData(results, ScrollActionType.refresh)
        return '刷新成功'
      },
      // 可选项，上拉加载更多回调
      onLoadMore: () => {
        return new Promise<string>((resolve, reject) => {
          this.viewModel.networkRequest(ScrollActionType.loadMore)
            .then((results: AxiosResponse[]) => {
              this.processResponseData(results, ScrollActionType.loadMore)
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
  getIcon() {
    Image($r('app.media.pic_search_article'))
      .width(60)
      .height(60)
      .padding(16)
      .onClick(() => {
        Router.push({url: PagesConstant.Hotkey, success: () => {}, fail: () => {}})
      })
  }

  @Builder
  private getListView() {
    List({ space: 20, scroller: this.scroller }) {
      ListItem() {
        BannerView({data: $dataSource})
      }
      LazyForEach(this.listDataSource, (item: Article) => {
        ListItem() {
          InfoCell({
            article: item,
            onItemClick: (article: Article) => {
              console.log("点击了cell " + article.link)
              Router.push({url: PagesConstant.NavigationBar})
            },
            onCollect: (isCollect: boolean, article: Article) => {

            }
          })
        }
      })
    }
    .width("100%")
    .backgroundColor('#FFFFFF')
    .divider({ strokeWidth: 0.5, color: "#2F2F2F" })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  async aboutToAppear(): Promise<void> {
    console.log("重写该方法，改为异步，还是会走这里")
    this.viewModel.networkRequest(ScrollActionType.refresh)
      .then((results: AxiosResponse[]) => {
        this.processResponseData(results, ScrollActionType.refresh)
      })
      .catch((error: AxiosError) => {
        console.log("http error: " + JSON.stringify(error))
        this.status = ViewStatus.error
      });

    this.viewModel.loginAction("13437156081", "z19871031")
  }

  processResponseData(results: AxiosResponse[], type: ScrollActionType) {
    if (type == ScrollActionType.refresh) {
      this.dataSource.removeAll()
      this.listDataSource.removeAll()

      let responseBanners = results[0].data as BaseResponse<Banner[]>
      let responseHotArticle = results[1].data as BaseResponse<Article[]>
      let responseNormalArticle = results[2].data as BaseResponse<PageModel<Article>>

      let allArticle = responseHotArticle.data.concat(responseNormalArticle.data.datas)

      if (type == ScrollActionType.refresh) {
        responseBanners.data.forEach((item) => {
          this.dataSource.addData(item)
        })
      }

      allArticle.forEach((item) => {
        this.listDataSource.addData(item)
      })

      if (this.listDataSource.originData.length == 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }

    } else {
      let responseNormalArticle = results[0].data as BaseResponse<PageModel<Article>>

      responseNormalArticle.data.datas.forEach((item) => {
        this.listDataSource.addData(item)
      })

      this.status = ViewStatus.success
    }
  }
}