import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { UserInfoModel } from '../model/UserInfoModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 我的收藏数据仓库
 * @description 处理我的收藏页面的数据请求
 */
export class MyCollectRepository extends BaseRepository {
  /**
   * 获取收藏列表
   * @param page 页码
   * @returns 分页文章数据
   */
  async getCollectList(page: number): Promise<PageModel<Article>> {
    try {
      const response = await this.httpClient.get<PageModel<Article>>(
        ApiConstants.collectList(page)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`MyCollectRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`MyCollectRepository: 获取收藏列表成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 获取用户信息
   * @returns 用户信息
   */
  async getUserInfo(): Promise<UserInfoModel> {
    try {
      const response = await this.httpClient.get<UserInfoModel>(
        ApiConstants.USER_INFO
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`MyCollectRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`MyCollectRepository: 获取用户信息成功`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 收藏文章
   * @param id 文章ID
   * @returns 是否成功
   */
  async collectArticle(id: number): Promise<boolean> {
    try {
      const response = await this.httpClient.post<string>(
        ApiConstants.collectAdd(id)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`MyCollectRepository: 收藏失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        return false
      }
      
      LogUtil.debug(`MyCollectRepository: 收藏成功，文章ID=${id}`)
      return true
    } catch (error) {
      this.handleError(error as ApiError)
      return false
    }
  }

  /**
   * 取消收藏
   * @param id 文章ID
   * @returns 是否成功
   */
  async cancelCollect(id: number): Promise<boolean> {
    try {
      const response = await this.httpClient.post<string>(
        ApiConstants.collectCancel(id)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`MyCollectRepository: 取消收藏失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        return false
      }
      
      LogUtil.debug(`MyCollectRepository: 取消收藏成功，文章ID=${id}`)
      return true
    } catch (error) {
      this.handleError(error as ApiError)
      return false
    }
  }
}
