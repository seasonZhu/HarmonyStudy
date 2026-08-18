import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { TabModel } from '../model/TabModel'
import { ContentType } from '../enum/ContentType'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 标签脚手架数据仓库
 * @description 处理标签列表的数据请求（项目、公众号、体系）
 */
export class TabScaffoldRepository extends BaseRepository {
  /**
   * 获取标签列表
   * @param contentType 内容类型
   * @returns 标签列表
   */
  async getTabs(contentType: ContentType): Promise<TabModel[]> {
    try {
      let api: string
      switch (contentType) {
        case ContentType.project:
          api = ApiConstants.PROJECT_TREE
          break
        case ContentType.publicNumber:
          api = ApiConstants.WX_ARTICLE_CHAPTERS
          break
        case ContentType.tree:
          api = ApiConstants.TREE
          break
      }
      
      const response = await this.httpClient.get<TabModel[]>(api)
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`TabScaffoldRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`TabScaffoldRepository: 获取标签列表成功，数量=${response.data.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
