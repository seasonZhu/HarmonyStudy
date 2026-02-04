import { Article } from '../model/Article'

/**
 * 收藏按钮组件
 * 统一处理收藏/取消收藏的UI和交互
 */
@Component
export struct CollectButton {
  @Prop article: Article
  @Prop isCollecting: boolean
  onCollectToggle?: (willCollect: boolean) => void

  build() {
    if (this.isCollecting) {
      LoadingProgress()
        .width(30)
        .height(30)
        .margin({ right: 8 })
    } else {
      if (this.article.collect) {
        Image($r('app.media.ic_collected'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Auto)
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onCollectToggle) {
              this.onCollectToggle(false)
            }
          })
          .visibility(Visibility.Hidden)
      } else {
        Image($r('app.media.ic_uncollect'))
          .width(26)
          .height(26)
          .objectFit(ImageFit.Auto)
          .margin({ right: 8 })
          .onClick(() => {
            if (this.onCollectToggle) {
              this.onCollectToggle(true)
            }
          })
          .visibility(Visibility.Hidden)
      }
    }
  }
}
