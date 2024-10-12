import { Article, ArticleTag } from '../model/Article'
import { WebLink } from '../entity/WebLink'
import { Router } from '../router/Router'
import { StringUtils } from '../utils/StringUtils'
import { ImageKnifeComponent, ImageKnifeOption } from '@ohos/imageknife'

@Component
export struct InfoCell {
  @Prop article: Article

  onCollect?: (isCollect: boolean, article: Article) => void

  onItemClick?: (article: Article) => void

  onItemLongClick?: (article: Article, event: GestureEvent) => void

  private subTagColors = [
    $r('app.color.blue500'),
    $r('app.color.green500'),
    $r('app.color.orange500'),
    $r('app.color.yellow500'),
  ]

  private title: string[] = []

  private isProject(): boolean {
    return this.article.envelopePic !== ""
  }

  aboutToAppear() {
    this.title = this.splitHighlightedText(this.article.title)
  }

  build() {
    if (this.isProject()) {
      this.projectCell()
    } else {
      this.articleCell()
    }
  }

  /// 用于首页与公众号
  @Builder
  private articleCell() {
    Column() {
      //作者和TAG、时间
      Row() {
        Text(this.getAuthorName())
          .fontSize(12)
        this.tagComponent()

        Blank()

        Text(this.article.niceShareDate)
          .fontSize(12)
          .margin({
            left: 8,
          })
      }
      .width('100%')
      .padding(8)

      //标题内容
      Text() {
        ForEach(this.title, (value: string, index: number) => {
          if (index === 1) {
            Span(StringUtils.replaceHtmlElement(value)).fontSize(18).fontColor("#2C86EF")
          } else {
            Span(StringUtils.replaceHtmlElement(value))
          }
        })
      }
      .constraintSize({
        maxWidth: '100%'
      })
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(2)
      .fontSize(18)
      .width('100%')
      .padding({
        left: 8
      })
      .margin({
        top: 12,
        bottom: 12,
      })

      //底部TAG以及like
      Row() {
        Text(this.article.superChapterName + '-' + this.article.chapterName)
          .fontSize(12)
          .padding(8)
          .fontColor("#02965E")
        Blank()
        if (this.article.extIsCollecting) {
          LoadingProgress()
            .width(30)
            .height(30)
            .margin({
              right: 8,
            })
        } else {
          if (this.article.collect) {
            Image($r('app.media.ic_collected'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                if (this.onCollect) {
                  this.onCollect(false, this.article)
                }
              })
              .visibility(Visibility.Hidden)
          } else {
            Image($r('app.media.ic_uncollect'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                if (this.onCollect) {
                  this.onCollect(true, this.article)
                }
              })
              .visibility(Visibility.Hidden)
          }
        }
      }
      .width('100%')
    }
    .backgroundColor("#FFFFFF")
    .width('100%')
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.article)
      }
      Router.toWebPage((this.article as WebLink))
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => { //长按触发
          if (this.onItemLongClick) {
            this.onItemLongClick(this.article, event)
          }
        })
        .onActionEnd(() => { // 长按动作一结束触发

        })
    )
  }

  /// 用于项目
  @Builder
  private projectCell() {
    Column() {
      //作者和TAG、时间
      Row() {
        Text(this.getAuthorName())
          .fontSize(12)
        this.tagComponent()

        Blank()

        Text(this.article.niceShareDate)
          .fontSize(12)
          .margin({
            left: 8,
          })
      }
      .width('100%')
      .padding(8)

      //标题内容
      Flex({ direction: FlexDirection.Row }) {

        ImageKnifeComponent({
          imageKnifeOption: new ImageKnifeOption({
            loadSrc:this.article.envelopePic,
            placeholderSrc:$r('app.media.pic_image_placeholder'),
            objectFit: ImageFit.Cover
          })
        })
          .width("20%")
          .height(120)
          .border({ radius: 4 })

        Flex({ direction: FlexDirection.Column }) {
          Text() {
            ForEach(this.title, (value: string, index: number) => {
              if (index === 1) {
                Span(StringUtils.replaceHtmlElement(value)).fontSize(18).fontColor("#2C86EF")
              } else {
                Span(StringUtils.replaceHtmlElement(value))
              }
            })
          }
          .constraintSize({
            maxWidth: '100%'
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .width('100%')
          .fontSize(18)
          .textAlign(TextAlign.Start)

          Text(this.article.desc)
            .width('100%')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .margin({
              top: 8,
            })
            .constraintSize({
              maxWidth: '100%'
            })
            .maxLines(6)
            .textOverflow({ overflow: TextOverflow.Clip })
        }
        .layoutWeight(1)
        .height(120)
        .align(Alignment.TopStart)
        .margin({
          left: 8
        })
      }
      .padding(8)
      .width('100%')

      //底部TAG以及like
      Row() {
        Text(this.article.superChapterName + '-' + this.article.chapterName)
          .fontSize(12)
          .padding(8)
          .fontColor("#02965E")
        Blank()
        if (this.article.extIsCollecting) {
          LoadingProgress()
            .width(30)
            .height(30)
            .margin({
              right: 8,
            })
        } else {
          if (this.article.collect) {
            Image($r('app.media.ic_collected'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                if (this.onCollect) {
                  this.onCollect(false, this.article)
                }
              })
              .visibility(Visibility.Hidden)
          } else {
            Image($r('app.media.ic_uncollect'))
              .width(26)
              .height(26)
              .objectFit(ImageFit.Auto)
              .margin({
                right: 8,
              })
              .onClick(() => {
                if (this.onCollect) {
                  this.onCollect(true, this.article)
                }
              })
              .visibility(Visibility.Hidden)
          }
        }
      }
      .width('100%')
    }
    .width('100%')
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.article)
      }
      Router.toWebPage((this.article as WebLink))
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => { //长按触发
          if (this.onItemLongClick) {
            this.onItemLongClick(this.article, event)
          }
        })
        .onActionEnd(() => { // 长按动作一结束触发

        })
    )
  }

  private getAuthorName(): string {
    if (this.article.author !== "") {
      return this.article.author
    } else if (this.article.shareUser !== "") {
      return this.article.shareUser
    } else {
      return "佚名"
    }
  }

  @Builder
  tagComponent() {
    Row() {
      if (this.article.type === 1) {
        Text('置顶')
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .border({ color: Color.Red, radius: 6, width: 1 })
          .fontSize(10)
      }

      if (this.article.fresh) {
        Text('新')
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.purple500'))
          .border({ color: Color.Orange, radius: 6, width: 1 })
          .fontSize(10)
      }

      ForEach(this.article.tags, (value: ArticleTag, index: number) => {
        Text(value.name)
          .margin({
            left: 6
          })
          .padding({
            left: 4,
            right: 4,
            top: 2,
            bottom: 2
          })
          .textAlign(TextAlign.Center)
          .fontColor("#2C86EF")
          .border({ color: "#2C86EF", radius: 8, width: 1 })
          .fontSize(10)
      })

    }
  }

  /**
   * 处理高亮title
   * @param input
   * @returns
   */
  private splitHighlightedText(input: string): string[] {
    // 正则表达式匹配 <em class='highlight'> 和 </em>
    const regex = /<em class='highlight'>(.*?)<\/em>/

    // 提取高亮部分和前后文本
    const match = input.match(regex)
    if (!match) return [input]; // 如果没有匹配到，返回原字符串

    const highlightedText = match[1]
    const parts = input.split(regex) // 分割原字符串，移除匹配的部分

    // parts 数组中，index 为 0 的是前面的文本，index 为 2 的是后面的文本
    return [parts[0], highlightedText, parts[2]].map(part => part.trim())
  }
}

