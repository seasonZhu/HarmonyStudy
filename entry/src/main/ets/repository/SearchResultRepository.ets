import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { KeywordInfo } from '../entity/KeywordInfo'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 搜索结果数据仓库
 * @description 处理搜索结果相关的数据请求
 */
export class SearchResultRepository extends BaseRepository {
  /**
   * 搜索文章
   * @param page 页码
   * @param keywordInfo 关键词信息
   * @returns 分页文章数据
   */
  async searchArticles(page: number, keywordInfo: KeywordInfo): Promise<PageModel<Article>> {
    try {
      const params = `k=${encodeURIComponent(keywordInfo.k)}`
      const response = await this.httpClient.post<PageModel<Article>>(
        ApiConstants.articleQuery(page),
        params,
        { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`SearchResultRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`SearchResultRepository: 搜索成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
