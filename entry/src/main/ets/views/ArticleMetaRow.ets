import { Article, ArticleTag } from '../model/Article'
import { CardStyle } from '../constants/StyleConstants'

@Component
export struct ArticleMetaRow {
  @Prop article: Article
  @Prop showAuthor: boolean = true

  build() {
    Row() {
      if (this.showAuthor) {
        Text(this.getAuthorName())
          .fontSize(12)
          .fontColor($r('app.color.text_primary'))
      }

      this.TagComponent()

      Blank()

      Text(this.article.niceShareDate)
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ left: 8 })
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 4, bottom: 4 })
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
  TagComponent() {
    Row() {
      if (this.article.type === 1) {
        Text('置顶')
          .margin({ left: 6 })
          .padding({
            left: CardStyle.TAG_PADDING_LEFT,
            right: CardStyle.TAG_PADDING_RIGHT,
            top: CardStyle.TAG_PADDING_TOP,
            bottom: CardStyle.TAG_PADDING_BOTTOM
          })
          .textAlign(TextAlign.Center)
          .fontColor('#D32F2F')
          .backgroundColor('#FFEBEE')
          .borderRadius(CardStyle.TAG_BORDER_RADIUS)
          .fontSize(CardStyle.TAG_FONT_SIZE)
      }

      if (this.article.fresh) {
        Text('新')
          .margin({ left: 6 })
          .padding({
            left: CardStyle.TAG_PADDING_LEFT,
            right: CardStyle.TAG_PADDING_RIGHT,
            top: CardStyle.TAG_PADDING_TOP,
            bottom: CardStyle.TAG_PADDING_BOTTOM
          })
          .textAlign(TextAlign.Center)
          .fontColor('#7B1FA2')
          .backgroundColor('#F3E5F5')
          .borderRadius(CardStyle.TAG_BORDER_RADIUS)
          .fontSize(CardStyle.TAG_FONT_SIZE)
      }

      ForEach(this.article.tags, (value: ArticleTag, index: number) => {
        Text(value.name)
          .margin({ left: 6 })
          .padding({
            left: CardStyle.TAG_PADDING_LEFT,
            right: CardStyle.TAG_PADDING_RIGHT,
            top: CardStyle.TAG_PADDING_TOP,
            bottom: CardStyle.TAG_PADDING_BOTTOM
          })
          .textAlign(TextAlign.Center)
          .fontColor('#1565C0')
          .backgroundColor('#E3F2FD')
          .borderRadius(CardStyle.TAG_BORDER_RADIUS)
          .fontSize(CardStyle.TAG_FONT_SIZE)
      })
    }
  }
}
