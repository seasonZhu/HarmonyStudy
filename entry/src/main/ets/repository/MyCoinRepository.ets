import { BaseRepository } from './base/BaseRepository'
import { MyCoinModel } from '../model/MyCoinModel'
import { PageModel } from '../model/PageModel'
import { ApiConstants } from '../constants/ApiConstants'
import { ApiError } from 'network'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 我的积分数据仓库
 * @description 封装我的积分相关的数据访问逻辑
 */
export class MyCoinRepository extends BaseRepository {
  /**
   * 获取我的积分列表
   * @param page 页码（从 1 开始）
   * @returns 积分记录列表
   */
  async getMyCoinList(page: number): Promise<MyCoinModel[]> {
    try {
      const response = await this.httpClient.get<PageModel<MyCoinModel>>(
        ApiConstants.coinList(page)
      )
      
      LogUtil.debug(`MyCoinRepository: 获取积分列表成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data.datas
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
