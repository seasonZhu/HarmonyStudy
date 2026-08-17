import { Article } from '../model/Article'
import { WebLink } from '../entity/WebLink'
import { navPathStack } from '../router/navPathStack'
import { ArticleMetaRow } from './ArticleMetaRow'
import { ArticleTitle } from './ArticleTitle'
import { CollectButton } from './CollectButton'
import { CardStyle } from '../constants/StyleConstants'
import { ImageKnifeComponent } from '@ohos/imageknife'

@Component
export struct ProjectCell {
  @Prop article: Article

  onCollect?: (isCollect: boolean, article: Article) => void

  onItemClick?: (article: Article) => void

  onItemLongClick?: (article: Article, event: GestureEvent) => void

  build() {
    Column() {
      ArticleMetaRow({
        article: this.article,
        showAuthor: true
      })

      Row() {
        ImageKnifeComponent({
          imageKnifeOption: {
            loadSrc: this.article.envelopePic,
            placeholderSrc: $r('app.media.pic_image_placeholder'),
            objectFit: ImageFit.Cover
          }
        })
          .width(80)
          .height(80)
          .borderRadius(8)

        Column() {
          ArticleTitle({
            title: this.article.title,
            maxLines: 2,
            fontSize: 16,
            titlePadding: 0
          })
          .margin({ top: 0, bottom: 0 })

          Text(this.article.desc)
            .width('100%')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .textAlign(TextAlign.Start)
            .margin({ top: 6 })
            .lineHeight(18)
            .constraintSize({ maxWidth: '100%' })
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: CardStyle.SECTION_GAP })

      Row() {
        if (this.article.superChapterName != null) {
          Text(this.article.superChapterName + '-' + this.article.chapterName)
            .fontSize(CardStyle.TAG_FONT_SIZE)
            .fontColor($r('app.color.sf_Green'))
            .backgroundColor('#E8F5E9')
            .borderRadius(CardStyle.TAG_BORDER_RADIUS)
            .padding({
              left: CardStyle.TAG_PADDING_LEFT,
              right: CardStyle.TAG_PADDING_RIGHT,
              top: CardStyle.TAG_PADDING_TOP,
              bottom: CardStyle.TAG_PADDING_BOTTOM
            })
        } else {
          Text(this.article.chapterName)
            .fontSize(CardStyle.TAG_FONT_SIZE)
            .fontColor($r('app.color.sf_Green'))
            .backgroundColor('#E8F5E9')
            .borderRadius(CardStyle.TAG_BORDER_RADIUS)
            .padding({
              left: CardStyle.TAG_PADDING_LEFT,
              right: CardStyle.TAG_PADDING_RIGHT,
              top: CardStyle.TAG_PADDING_TOP,
              bottom: CardStyle.TAG_PADDING_BOTTOM
            })
        }

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
      .margin({ top: CardStyle.SECTION_GAP })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(CardStyle.BORDER_RADIUS)
    .shadow({ radius: 16, color: '#30000000', offsetX: 0, offsetY: 0 })
    .padding(CardStyle.INNER_PADDING)
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
