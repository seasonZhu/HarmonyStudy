import { Article } from '../model/Article'
import { WebLink } from '../entity/WebLink'
import { Router } from '../router/Router'
import { ArticleMetaRow } from './ArticleMetaRow'
import { ArticleTitle } from './ArticleTitle'
import { CollectButton } from './CollectButton'

/**
 * 文章列表项组件
 * 用于首页、公众号、收藏等文章列表
 */
@Component
export struct ArticleCell {
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

      // 标题内容
      ArticleTitle({
        title: this.article.title,
        maxLines: 2,
        fontSize: 18
      })

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
    .backgroundColor($r('app.color.white'))
    .width('100%')
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.article)
      }
      Router.toWebPage((this.article as WebLink))
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
