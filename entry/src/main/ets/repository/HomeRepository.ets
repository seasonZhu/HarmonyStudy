import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { Banner } from '../model/Banner'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 首页数据仓库
 * @description 处理首页的数据请求（Banner、置顶文章、普通文章）
 */
export class HomeRepository extends BaseRepository {
  /**
   * 获取 Banner 列表
   * @returns Banner 列表
   */
  async getBannerList(): Promise<Banner[]> {
    try {
      const response = await this.httpClient.get<Banner[]>(
        ApiConstants.BANNER
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`HomeRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`HomeRepository: 获取 Banner 成功，数量=${response.data.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 获取置顶文章
   * @returns 置顶文章列表
   */
  async getHotArticleList(): Promise<Article[]> {
    try {
      const response = await this.httpClient.get<Article[]>(
        ApiConstants.ARTICLE_TOP
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`HomeRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`HomeRepository: 获取置顶文章成功，数量=${response.data.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 获取普通文章
   * @param page 页码
   * @returns 分页文章数据
   */
  async getNormalArticleList(page: number): Promise<PageModel<Article>> {
    try {
      const response = await this.httpClient.get<PageModel<Article>>(
        ApiConstants.articleList(page)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`HomeRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`HomeRepository: 获取普通文章成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
