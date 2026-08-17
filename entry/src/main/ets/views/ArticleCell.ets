import { Article } from '../model/Article'
import { WebLink } from '../entity/WebLink'
import { navPathStack } from '../router/navPathStack'
import { ArticleMetaRow } from './ArticleMetaRow'
import { ArticleTitle } from './ArticleTitle'
import { CollectButton } from './CollectButton'
import { CardStyle } from '../constants/StyleConstants'

@Component
export struct ArticleCell {
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

      ArticleTitle({
        title: this.article.title,
        maxLines: 2,
        fontSize: 16
      })
      .margin({ top: 4, bottom: 4 })

      Row() {
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
