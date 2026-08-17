import { MyCollectRepository } from '../repository/MyCollectRepository'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { UserInfoModel } from '../model/UserInfoModel'
import { ScrollActionType } from '../enum/ScrollActionType'
import { CollectActionType } from '../enum/CollectActionType'
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import AccountManager from '../accountManager/AccountManager'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 我的收藏视图模型
 * @description 处理我的收藏页面的业务逻辑
 */
export class MyCollectViewModel {
  private collectRepo = new MyCollectRepository()
  private pageNum = 0

  /**
   * 获取收藏列表
   * @param type 滚动操作类型
   * @returns 分页文章数据
   */
  getMyCollectList = async (type: ScrollActionType): Promise<PageModel<Article>> => {
    if (type === ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }
    
    LogUtil.debug(`MyCollectViewModel: 获取收藏列表，页码=${this.pageNum}`)
    return this.collectRepo.getCollectList(this.pageNum)
  }

  /**
   * 获取用户信息
   * @returns 用户信息
   */
  getUserInfo = async (): Promise<UserInfoModel> => {
    LogUtil.debug('MyCollectViewModel: 获取用户信息')
    return this.collectRepo.getUserInfo()
  }

  /**
   * 收藏操作
   * @param id 文章ID
   * @param type 收藏操作类型
   * @returns 是否成功
   */
  async collectAction(id: number, type: CollectActionType): Promise<boolean> {
    switch(type) {
      case CollectActionType.collect:
        const collectSuccess = await this.collectRepo.collectArticle(id)
        if (collectSuccess) {
          ToastUtil.showToast($r('app.string.collect_success'))
          if (AccountManager.shared().loginModel && AccountManager.shared().loginModel?.collectIds) {
            let newLoginModel = AccountManager.shared().loginModel!
            let collectIds = AccountManager.shared().loginModel?.collectIds!
            collectIds.push(id)
            newLoginModel.collectIds = collectIds
            AccountManager.shared().saveLoginModel(newLoginModel)
          }
          return true
        } else {
          ToastUtil.showToast($r('app.string.collect_failed'))
          return false
        }
      case CollectActionType.cancel:
        const cancelSuccess = await this.collectRepo.cancelCollect(id)
        if (cancelSuccess) {
          ToastUtil.showToast($r('app.string.uncollect_success'))
          if (AccountManager.shared().loginModel && AccountManager.shared().loginModel?.collectIds) {
            let newLoginModel = AccountManager.shared().loginModel!
            let collectIds = AccountManager.shared().loginModel?.collectIds!
            let index = collectIds.indexOf(id)
            if (index >= 0) {
              collectIds.splice(index, 1)
              newLoginModel.collectIds = collectIds
              AccountManager.shared().saveLoginModel(newLoginModel)
            }
          }
          return true
        } else {
          ToastUtil.showToast($r('app.string.uncollect_failed'))
          return false
        }
    }
  }
}
