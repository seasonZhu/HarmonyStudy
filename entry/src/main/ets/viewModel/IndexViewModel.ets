import { LoginRepository } from '../repository/LoginRepository'
import { UserInfoModel } from '../model/UserInfoModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 主页视图模型
 * @description 处理主页的业务逻辑
 */
export class IndexViewModel {
  private loginRepo = new LoginRepository()

  /**
   * 获取用户信息
   * @returns 用户信息
   */
  getUserInfo = async (): Promise<UserInfoModel> => {
    LogUtil.debug('IndexViewModel: 获取用户信息')
    return this.loginRepo.getUserInfo()
  }
}
