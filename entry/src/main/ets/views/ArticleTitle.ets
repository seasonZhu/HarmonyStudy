import { StringUtils } from '../utils/StringUtils'

/**
 * 文章标题组件
 * 支持高亮文本显示
 */
@Component
export struct ArticleTitle {
  @Prop title: string
  @Prop maxLines: number = 2
  @Prop fontSize: number = 18
  @Prop highlightColor: Resource = $r('app.color.app_blue')
  @Prop titlePadding: number | string = 8

  private titleParts: string[] = []

  aboutToAppear() {
    this.titleParts = this.splitHighlightedText(this.title)
  }

  build() {
    Text() {
      ForEach(this.titleParts, (value: string, index: number) => {
        if (index === 1) {
          Span(StringUtils.replaceHtmlElement(value))
            .fontSize(this.fontSize)
            .fontColor(this.highlightColor)
        } else {
          Span(StringUtils.replaceHtmlElement(value))
        }
      })
    }
    .constraintSize({ maxWidth: '100%' })
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .maxLines(this.maxLines)
    .fontSize(this.fontSize)
    .width('100%')
    .padding({ left: this.titlePadding })
    .margin({ top: 12, bottom: 12 })
  }

  /**
   * 处理高亮title
   * @param input 输入文本
   * @returns 分割后的文本数组
   */
  private splitHighlightedText(input: string): string[] {
    const regex = /<em class='highlight'>(.*?)<\/em>/
    const match = input.match(regex)
    if (!match) return [input]

    const highlightedText = match[1]
    const parts = input.split(regex)
    return [parts[0], highlightedText, parts[1]].map(part => part.trim())
  }
}
