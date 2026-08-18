import { Article } from '../model/Article'
import { ArticleCell } from './ArticleCell'
import { ProjectCell } from './ProjectCell'

/**
 * 文章/项目列表项组件（统一入口）
 * 根据 envelopePic 是否存在判断显示文章还是项目样式
 *
 * @deprecated 建议直接使用 ArticleCell 或 ProjectCell
 * 此组件保留用于向后兼容
 */
@Component
export struct InfoCell {
  @Prop article: Article

  onCollect?: (isCollect: boolean, article: Article) => void

  onItemClick?: (article: Article) => void

  onItemLongClick?: (article: Article, event: GestureEvent) => void

  private isProject(): boolean {
    return this.article.envelopePic !== ""
  }

  build() {
    if (this.isProject()) {
      ProjectCell({
        article: this.article,
        onCollect: this.onCollect,
        onItemClick: this.onItemClick,
        onItemLongClick: this.onItemLongClick
      })
    } else {
      ArticleCell({
        article: this.article,
        onCollect: this.onCollect,
        onItemClick: this.onItemClick,
        onItemLongClick: this.onItemLongClick
      })
    }
  }
}
