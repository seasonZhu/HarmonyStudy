import { RankRepository } from '../repository/RankRepository'
import { ScrollActionType } from '../enum/ScrollActionType'
import { RankModel } from '../model/RankModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 排行榜视图模型
 * @description 处理排行榜页面的业务逻辑
 */
export class RankViewModel {
  private pageNum = 1
  private rankRepo = new RankRepository()
  
  /**
   * 获取排行榜列表
   * @param type 滚动动作类型（刷新或加载更多）
   * @returns 排行榜数据列表
   */
  getRankList = async (type: ScrollActionType): Promise<RankModel[]> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }
    
    LogUtil.debug(`RankViewModel: 获取排行榜，页码=${this.pageNum}，动作=${type}`)
    return this.rankRepo.getRankList(this.pageNum)
  }
}
