import { BaseRepository } from './base/BaseRepository'
import { HotKeyModel } from '../model/HotKeyModel'
import { ApiConstants } from '../constants/ApiConstants'
import { ApiError } from 'network'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 热门关键词数据仓库
 * @description 封装热门关键词相关的数据访问逻辑
 */
export class HotKeyRepository extends BaseRepository {
  /**
   * 获取热门关键词列表
   * @returns 热门关键词列表
   */
  async getHotKeyList(): Promise<HotKeyModel[]> {
    try {
      const response = await this.httpClient.get<HotKeyModel[]>(
        ApiConstants.HOTKEY
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`HotKeyRepository: API 错误，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '请求失败')
      }
      
      LogUtil.debug(`HotKeyRepository: 获取热门关键词成功，数量=${response.data.length}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
