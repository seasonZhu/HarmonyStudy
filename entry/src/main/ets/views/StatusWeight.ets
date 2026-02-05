import { ViewStatus } from '../enum/ViewStatus'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 页面状态布局组件
 *
 * @description
 * 统一管理页面的 loading、error、empty、success 四种状态显示
 * 支持自定义状态 UI，提供默认实现
 *
 * @example
 * ```typescript
 * // 基础用法
 * StatusWeight({
 *   status: this.status,
 *   contentBuilder: () => this.getContent()
 * })
 *
 * // 自定义错误页面
 * StatusWeight({
 *   status: this.status,
 *   errorText: '网络连接失败',
 *   errorIcon: $r('app.media.ic_network_error'),
 *   contentBuilder: () => this.getContent(),
 *   onRetry: () => this.loadData()
 * })
 * ```
 *
 * @author StatusWeight
 * @version 2.0.0
 */
@Component
export struct StatusWeight {
  @Prop status: ViewStatus

  /** 内容构建器（success 状态显示） */
  @BuilderParam contentBuilder: () => void

  /** 自定义 loading 构建器 */
  @BuilderParam loadingBuilder?: () => void

  /** 自定义 error 构建器 */
  @BuilderParam errorBuilder?: () => void

  /** 自定义 empty 构建器 */
  @BuilderParam emptyBuilder?: () => void

  /** 错误提示文字 */
  @Prop errorText: ResourceStr = $r('app.string.request_failed_retry')

  /** 空状态提示文字 */
  @Prop emptyText: ResourceStr = $r('app.string.no_data')

  /** 加载提示文字 */
  @Prop loadingText: ResourceStr = $r('app.string.loading_request')

  /** 错误图标 */
  @Prop errorIcon: ResourceStr = $r('app.media.ic_error1')

  /** 空状态图标 */
  @Prop emptyIcon: ResourceStr = $r('app.media.pic_no_data')

  /** 图标大小 */
  @Prop iconSize: number = 160

  /** 文字大小 */
  @Prop textSize: number = 18

  /** 图标与文字间距 */
  @Prop textMarginTop: number = 48

  /** 重试回调（仅 error 状态） */
  onRetry?: () => void

  /** 空状态操作回调 */
  onEmptyAction?: () => void

  build() {
    Column() {
      this.statusUI()
    }
    .width('100%')
    .height('100%')
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  @Builder
  private statusUI() {
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

      Text(this.loadingText)
        .margin({ top: this.textMarginTop })
        .fontSize(this.textSize)
        .fontColor($r('app.color.text_secondary'))
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }

  @Builder
  private error() {
    Column() {
      Image(this.errorIcon)
        .height(this.iconSize)
        .width(this.iconSize)
        .objectFit(ImageFit.Contain)
        .opacity(0.8)

      Text(this.errorText)
        .margin({ top: this.textMarginTop })
        .fontSize(this.textSize)
        .fontColor($r('app.color.text_secondary'))

      if (this.onRetry) {
        Button($r('app.string.retry'))
          .margin({ top: 24 })
          .onClick(() => {
            LogUtil.debug('StatusWeight: 点击重试按钮')
            this.onRetry?.()
          })
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ left: 32, right: 32 })
  }

  @Builder
  private empty() {
    Column() {
      Image(this.emptyIcon)
        .height(this.iconSize)
        .width(this.iconSize)
        .objectFit(ImageFit.Contain)
        .opacity(0.6)

      Text(this.emptyText)
        .margin({ top: this.textMarginTop })
        .fontSize(this.textSize)
        .fontColor($r('app.color.text_secondary'))

      if (this.onEmptyAction) {
        Button($r('app.string.go_add'))
          .margin({ top: 24 })
          .onClick(() => {
            LogUtil.debug('StatusWeight: 点击空状态操作按钮')
            this.onEmptyAction?.()
          })
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ left: 32, right: 32 })
  }
}
