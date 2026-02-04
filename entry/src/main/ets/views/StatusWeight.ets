import { ViewStatus } from '../enum/ViewStatus';

@Component
export struct StatusWeight {
  @Prop status: ViewStatus

  @BuilderParam contentBuilder: () => void

  @BuilderParam emptyBuilder?: () => void

  @BuilderParam loadingBuilder?: () => void

  @BuilderParam errorBuilder?: () => void

  onRetry?: () => void

  build() {
    this.statusUI()
  }

  @Builder
  private statusUI() {
    /// 这里居然不能使用switch进行区别性编写
    if (this.status === ViewStatus.loading) {
      if (this.loadingBuilder) {
        this.loadingBuilder()
      } else {
        this.loading()
      }
    } else if (this.status === ViewStatus.error) {
      if (this.errorBuilder) {
        this.errorBuilder()
      } else {
        this.error()
      }
    } else if (this.status === ViewStatus.empty) {
      if (this.emptyBuilder) {
        this.emptyBuilder()
      } else {
        this.empty()
      }
    } else {
      this.contentBuilder()
    }
  }

  @Builder
  private loading() {
    Column() {
      LoadingProgress()
        .color($r('app.color.app_blue'))
        .width(60)
        .height(60)

      Text($r('app.string.loading_request'))
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }

  @Builder
  private error() {
    Column() {
      Image($r('app.media.ic_error1'))
        .height(160)
        .width(280)
        .objectFit(ImageFit.Auto)
      Text($r('app.string.request_failed_retry'))
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onClick(this.onRetry)
  }

  @Builder
  private empty() {
    Column() {
      Image($r('app.media.pic_no_data'))
        .height(180)
        .width(180)
        .objectFit(ImageFit.Auto)
      Text($r('app.string.no_data'))
        .margin({
          top: 48
        })
        .fontSize(18)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onClick(this.onRetry)
  }
}