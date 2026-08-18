import { TabsDetailRepository } from '../repository/TabsDetailRepository'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { ContentType } from '../enum/ContentType'
import { ScrollActionType } from '../enum/ScrollActionType'
import { TabModel } from '../model/TabModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 标签详情视图模型
 * @description 处理标签详情页面的业务逻辑（项目、公众号、体系）
 */
export class TabsDetailViewModel {
  private tabsDetailRepo = new TabsDetailRepository()
  private pageNum = 0
  private contentType: ContentType
  private tab: TabModel

  constructor(contentType: ContentType, tab: TabModel) {
    this.contentType = contentType
    this.tab = tab
  }

  /**
   * 获取标签详情列表
   * @param type 滚动操作类型
   * @returns 分页文章数据
   */
  getTabsDetailList = async (type: ScrollActionType): Promise<PageModel<Article>> => {
    if (type === ScrollActionType.refresh) {
      if (this.contentType === ContentType.tree) {
        this.pageNum = 0
      } else {
        this.pageNum = 1
      }
    } else {
      this.pageNum = this.pageNum + 1
    }
    
    LogUtil.debug(`TabsDetailViewModel: 获取标签详情，页码=${this.pageNum}，类型=${this.contentType}`)
    return this.tabsDetailRepo.getTabsDetailList(this.pageNum, this.contentType, this.tab)
  }
}
