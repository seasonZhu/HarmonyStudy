import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { ContentType } from '../enum/ContentType'
import { TabModel } from '../model/TabModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 标签详情数据仓库
 * @description 处理标签详情页面的数据请求（项目、公众号、体系）
 */
export class TabsDetailRepository extends BaseRepository {
  /**
   * 获取标签详情列表
   * @param page 页码
   * @param contentType 内容类型
   * @param tab 标签信息
   * @returns 分页文章数据
   */
  async getTabsDetailList(page: number, contentType: ContentType, tab: TabModel): Promise<PageModel<Article>> {
    try {
      let api: string
      switch (contentType) {
        case ContentType.project:
          api = ApiConstants.projectList(page, tab.id ?? 0)
          break
        case ContentType.publicNumber:
          api = ApiConstants.wxArticleList(tab.id ?? 0, page)
          break
        case ContentType.tree:
          api = ApiConstants.treeDetailList(page, tab.id ?? 0)
          break
      }
      
      const response = await this.httpClient.get<PageModel<Article>>(api)
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`TabsDetailRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`TabsDetailRepository: 获取标签详情成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
