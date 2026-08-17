import { HotKeyRepository } from '../repository/HotKeyRepository'
import { HotKeyModel } from '../model/HotKeyModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 热门关键词视图模型
 * @description 处理热门关键词页面的业务逻辑
 */
export class HotKeyViewModel {
  private hotKeyRepo = new HotKeyRepository()
  
  /**
   * 获取热门关键词列表
   * @returns 热门关键词列表
   */
  getHotKey = async (): Promise<HotKeyModel[]> => {
    LogUtil.debug('HotKeyViewModel: 获取热门关键词')
    return this.hotKeyRepo.getHotKeyList()
  }
}
