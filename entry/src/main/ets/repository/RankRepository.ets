import { BaseRepository } from './base/BaseRepository'
import { RankModel } from '../model/RankModel'
import { PageModel } from '../model/PageModel'
import { ApiConstants } from '../constants/ApiConstants'
import { ApiError } from 'network'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 排行榜数据仓库
 * @description 封装排行榜相关的数据访问逻辑
 */
export class RankRepository extends BaseRepository {
  /**
   * 获取排行榜列表
   * @param page 页码（从 1 开始）
   * @returns 排行榜数据列表
   */
  async getRankList(page: number): Promise<RankModel[]> {
    try {
      const response = await this.httpClient.get<PageModel<RankModel>>(
        ApiConstants.coinRank(page)
      )
      
      LogUtil.debug(`RankRepository: 获取排行榜成功，页码=${page}，数量=${response.data.datas.length}`)
      return response.data.datas
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
