import { webview } from '@kit.ArkWeb'
import { RouterName } from '../router/RouterName'
import { LoadingDialogHelper } from '../utils/LoadingDialogHelper';
import { WebLink } from '../entity/WebLink';
import AccountManager from '../accountManager/AccountManager';
import { LogUtil } from '@pura/harmony-utils';
import { CollectActionType } from '../enum/CollectActionType';
import { MyCollectViewModel } from '../viewModel/MyCollectViewModel';
import { common } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { ErrorHandler } from '../utils/ErrorHandler'

@Entry({routeName: RouterName.Web})
@ComponentV2
struct WebPage {
  private controller: webview.WebviewController = new webview.WebviewController()

  @Local private loadingProgress: number = 0

  @Local private showLoadingProgress: boolean = true

  @Local private title: string = '加载中...'

  @Local private collectIds: number[] = []

  private webLink: WebLink = { id: null, title: null, link: null, originId: null }

  private viewModel = new MyCollectViewModel()

  private loadingHelper = new LoadingDialogHelper('加载中...')

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
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
            this.loadingHelper.show('加载中...')
          })
          .onPageEnd((_event) => {
            //网页加载完成时触发该回调，且只在主frame触发。
            this.showLoadingProgress = false
            this.loadingHelper.hide()
          })
          .onProgressChange((event) => {
            //网页加载进度变化时触发该回调。
            if (event?.newProgress) {
              this.loadingProgress = event.newProgress
            }
          })
          .onErrorReceive(() => {
            this.loadingHelper.hide()
          })
          .onHttpErrorReceive(() => {
            this.loadingHelper.hide()
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
    .menus(this.getRightItems())
    .onReady((context: NavDestinationContext) => {
      this.webLink = context.pathInfo.param as WebLink
    })
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
          try {
            this.shareAction()
          } catch (error) {
            ErrorHandler.handle(error, '分享功能调用失败')
          }
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
          let actionText = type === CollectActionType.collect ? '收藏中...' : '取消收藏...'
          try {
            let result = await LoadingDialogHelper.wrap(
              this.viewModel.collectAction(this.getRealCollectId(), type),
              actionText
            )
            if (result) {
              this.collectIds = AccountManager.shared().loginModel?.collectIds ?? []
            }
          } catch (error) {
            ErrorHandler.handle(error, '收藏操作失败')
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
      .margin({left: 8})
      .width('100%')
    }
    .height('100%')
  }

  aboutToDisappear(): void {
    this.loadingHelper.destroy()
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
      return collectId ?? 0
    }
  }

  /**
   * @throws
   */
  shareAction() {
    // https://ost.51cto.com/posts/29508

    // 构造ShareData，需配置一条有效数据信息
    let data: systemShare.SharedData = new systemShare.SharedData({
      //设置传输文件的类型(更多类型查看上方表格)
      utd: utd.UniformDataType.TEXT,
      title: this.title,
      uri: this.webLink.link ?? "",
    });

    // 构建ShareController
    let controller: systemShare.ShareController = new systemShare.ShareController(data);
    // 获取UIAbility上下文对象
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 注册分享面板关闭监听
    controller.on('dismiss', () => {
      LogUtil.info('Share panel closed');
      // 分享结束，可处理其他业务。
    });
    // 进行分享面板显示
    controller.show(context, {
      // DETAIL为详细预览图模式
      previewMode: systemShare.SharePreviewMode.DETAIL,
      // SINGLE为单选模式，传入一个记录则单传，多个则n选1；BATCH为批量模式
      selectionMode: systemShare.SelectionMode.SINGLE
    });
  }
}

@Builder
export function WebPageBuilder() {
  WebPage()
}