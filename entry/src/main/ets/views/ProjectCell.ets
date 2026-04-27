import { Article } from '../model/Article'
import { WebLink } from '../entity/WebLink'
import { navPathStack } from '../router/navPathStack'
import { ArticleMetaRow } from './ArticleMetaRow'
import { ArticleTitle } from './ArticleTitle'
import { CollectButton } from './CollectButton'
import { ImageKnifeComponent } from '@ohos/imageknife'

/**
 * 项目列表项组件
 * 用于项目Tab页，展示项目缩略图和描述
 */
@Component
export struct ProjectCell {
  @Prop article: Article

  onCollect?: (isCollect: boolean, article: Article) => void

  onItemClick?: (article: Article) => void

  onItemLongClick?: (article: Article, event: GestureEvent) => void

  build() {
    Column() {
      // 作者和TAG、时间
      ArticleMetaRow({
        article: this.article,
        showAuthor: true
      })

      // 标题内容 + 缩略图 + 描述
      Flex({ direction: FlexDirection.Row }) {
        // 项目缩略图
        ImageKnifeComponent({
          imageKnifeOption: {
            loadSrc: this.article.envelopePic,
            placeholderSrc: $r('app.media.pic_image_placeholder'),
            objectFit: ImageFit.Cover
          }
        })
          .width("20%")
          .height(120)
          .border({ radius: 4 })

        // 标题和描述
        Flex({ direction: FlexDirection.Column }) {
          // 标题
          ArticleTitle({
            title: this.article.title,
            maxLines: 1,
            fontSize: 18,
            titlePadding: 0
          })
          .margin({ top: 0, bottom: 0 })

          // 描述
          Text(this.article.desc)
            .width('100%')
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .margin({ top: 8 })
            .constraintSize({ maxWidth: '100%' })
            .maxLines(6)
            .textOverflow({ overflow: TextOverflow.Clip })
        }
        .layoutWeight(1)
        .height(120)
        .align(Alignment.TopStart)
        .margin({ left: 8 })
      }
      .padding(8)
      .width('100%')

      // 底部TAG以及收藏
      Row() {
        Text(this.article.superChapterName + '-' + this.article.chapterName)
          .fontSize(12)
          .padding(8)
          .fontColor($r('app.color.sf_Green'))

        Blank()

        CollectButton({
          article: this.article,
          isCollecting: this.article.extIsCollecting,
          onCollectToggle: (willCollect: boolean) => {
            if (this.onCollect) {
              this.onCollect(willCollect, this.article)
            }
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.article)
      }
      navPathStack.pushPath({ name: 'WebPage', param: this.article as WebLink })
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction((event: GestureEvent) => {
          if (this.onItemLongClick) {
            this.onItemLongClick(this.article, event)
          }
        })
        .onActionEnd(() => {
        })
    )
  }
}
