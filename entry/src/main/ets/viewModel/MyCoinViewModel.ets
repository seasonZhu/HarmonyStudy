import { MyCoinRepository } from '../repository/MyCoinRepository'
import { ScrollActionType } from '../enum/ScrollActionType'
import { MyCoinModel } from '../model/MyCoinModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 我的积分视图模型
 * @description 处理我的积分页面的业务逻辑
 */
export class MyCoinViewModel {
  private pageNum = 1
  private myCoinRepo = new MyCoinRepository()
  
  /**
   * 获取我的积分列表
   * @param type 滚动动作类型（刷新或加载更多）
   * @returns 积分记录列表
   */
  getMyCoinList = async (type: ScrollActionType): Promise<MyCoinModel[]> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }
    
    LogUtil.debug(`MyCoinViewModel: 获取积分列表，页码=${this.pageNum}，动作=${type}`)
    return this.myCoinRepo.getMyCoinList(this.pageNum)
  }
}
