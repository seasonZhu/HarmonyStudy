import { Article, ArticleTag } from '../model/Article'

/**
 * 文章元信息行组件
 * 显示：作者、标签、时间
 */
@Component
export struct ArticleMetaRow {
  @Prop article: Article
  @Prop showAuthor: boolean = true

  build() {
    Row() {
      if (this.showAuthor) {
        Text(this.getAuthorName())
          .fontSize(12)
      }

      this.TagComponent()

      Blank()

      Text(this.article.niceShareDate)
        .fontSize(12)
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(8)
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
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .border({ color: Color.Red, radius: 6, width: 1 })
          .fontSize(10)
      }

      if (this.article.fresh) {
        Text('新')
          .margin({ left: 6 })
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.purple500'))
          .border({ color: Color.Orange, radius: 6, width: 1 })
          .fontSize(10)
      }

      ForEach(this.article.tags, (value: ArticleTag, index: number) => {
        Text(value.name)
          .margin({ left: 6 })
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.app_blue'))
          .border({ color: $r('app.color.app_blue'), radius: 8, width: 1 })
          .fontSize(10)
      })
    }
  }
}
