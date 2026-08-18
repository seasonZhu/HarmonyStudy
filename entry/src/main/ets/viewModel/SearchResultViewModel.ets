import { SearchResultRepository } from '../repository/SearchResultRepository'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { KeywordInfo } from '../entity/KeywordInfo'
import { ScrollActionType } from '../enum/ScrollActionType'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 搜索结果视图模型
 * @description 处理搜索结果页面的业务逻辑
 */
export class SearchResultViewModel {
  private searchRepo = new SearchResultRepository()
  private pageNum = 0
  
  /**
   * 搜索文章列表
   * @param type 滚动操作类型
   * @param keywordInfo 关键词信息
   * @returns 分页文章数据
   */
  searchArticles = async (type: ScrollActionType, keywordInfo: KeywordInfo): Promise<PageModel<Article>> => {
    if (type === ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }
    
    LogUtil.debug(`SearchResultViewModel: 搜索文章，页码=${this.pageNum}，关键词=${keywordInfo.k}`)
    return this.searchRepo.searchArticles(this.pageNum, keywordInfo)
  }
}
