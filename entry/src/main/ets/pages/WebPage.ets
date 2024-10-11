import webview from '@ohos.web.webview'
import { Router } from '../router/Router'
import { RouterName } from '../router/RouterName'
import { LoadingDialog } from '../httpRequest/LoadingDialog';
import { WebLink } from '../entity/WebLink';
import AccountManager from '../accountManager/AccountManager';
import { LogUtil, ToastUtil } from '@pura/harmony-utils';
import { CollectActionType } from '../enum/CollectActionType';
import { MyCollectViewModel } from '../viewModel/MyCollectViewModel';

@Entry({routeName: RouterName.Web})
@Component
struct WebPage {
  private controller: WebviewController = new webview.WebviewController()

  @State private loadingProgress: number = 0

  @State private showLoadingProgress: boolean = true

  @State private title: string = '加载中...'

  @State private collectIds: number[] = AccountManager.shared().loginModel?.collectIds ?? []

  private webLink = Router.getParams() as WebLink

  private viewModel = new MyCollectViewModel()

  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({text: "加载中..."}),
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

  build() {
    Navigation() {
      Stack() {
        Web({ src: this.webLink.link, controller: this.controller })
          .mixedMode(MixedMode.All)
          .width("100%")
          .height("100%")
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .fileAccess(true)
          .imageAccess(true)
          .onlineImageAccess(true)
          .zoomAccess(true)
          .overviewModeAccess(true)
          .databaseAccess(true)
          .geolocationAccess(true)
          .multiWindowAccess(true)
          .mediaPlayGestureAccess(true)
          .blockNetwork(false)
          .pinchSmooth(true)
          .onPageBegin((event) => {
            //网页开始加载时触发该回调，且只在主frame触发，iframe或者frameset的内容加载时不会触发此回调。
            this.showLoadingProgress = true
            if (event?.url) {

            }
            this.loadingDialogController.open()
          })
          .onPageEnd((event) => {
            //网页加载完成时触发该回调，且只在主frame触发。
            this.showLoadingProgress = false
            this.loadingDialogController.close()
          })
          .onProgressChange((event) => {
            //网页加载进度变化时触发该回调。
            if (event?.newProgress) {
              this.loadingProgress = event.newProgress
            }
          })
          .onErrorReceive(() => {
            this.loadingDialogController.close()
          })
          .onHttpErrorReceive(() => {
            this.loadingDialogController.close()
          })
          .onTitleReceive((event) => {
            //网页document标题更改时触发该回调。
            if (event?.title) {
              this.title = event.title
            }
          })

        if (this.showLoadingProgress) {
          Progress({ value: 0, total: 100, type: ProgressType.Linear })
            .color($r("app.color.mainBlue"))
            .value(this.loadingProgress)
            .width('100%')
        }
      }
      .width('100%')
      .layoutWeight(1)
      .alignContent(Alignment.Top)
    }
    .title(this.getTitle())
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .menus(this.getRightItems())
  }

  @Builder
  getRightItems() {
    Row() {
      Image($r('app.media.ic_share'))
        .width(60)
        .height(60)
        .padding({ top: 16, bottom: 16 })
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          LogUtil.debug("点击了分享按钮")
        })

      Image(this.collectIcon())
        .width(60)
        .height(60)
        .padding({ top: 16, bottom: 16 })
        .objectFit(ImageFit.Contain)
        .visibility(AccountManager.shared().isLogin()? Visibility.Visible : Visibility.None)
        .onClick( async () => {
          LogUtil.debug("点击了收藏按钮" + this.getRealCollectId())
          let type = this.isCollected() ? CollectActionType.cancel : CollectActionType.collect
          let result = await this.viewModel.collectAction(this.getRealCollectId(), type)
          if (result) {
            this.collectIds = AccountManager.shared().loginModel?.collectIds!
          }
        })
    }
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  getTitle() {
    Row() {
      Column() {
        Text(this.title)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
      }
      .width('100%')
    }
    .height('100%')
  }

  aboutToDisappear(): void {
    this.loadingDialogController.close()
  }

  aboutToAppear(): void {

  }

  isCollected(): boolean {
    this.collectIds = AccountManager.shared().loginModel?.collectIds ?? []
    let originId = this.getRealCollectId()

    if (originId && this.collectIds.includes(originId)) {
      return true
    } else {
      return false
    }
  }

  collectIcon(): Resource {
    if (this.isCollected()) {
      return $r('app.media.collect_selected')
    } else {
      return $r('app.media.collect')
    }
  }

  getRealCollectId(): number {
    let id = this.webLink.id
    let collectId = this.webLink.originId

    if (collectId == null && id != null) {
      return id
    } else {
      return collectId!
    }
  }
}