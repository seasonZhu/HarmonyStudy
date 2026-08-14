import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { ScrollActionType } from '../enum/ScrollActionType';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { UserInfoModel } from '../model/UserInfoModel';
import { CollectActionType } from '../enum/CollectActionType';
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil';
import AccountManager from '../accountManager/AccountManager';
import { ApiConstants } from '../constants/ApiConstants';

export class MyCollectViewModel {
  private pageNum = 0

  getMyCollectList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }

    return httpClient.get(ApiConstants.collectList(this.pageNum))
  }

  getUserInfo = (): Promise<AxiosResponse<BaseResponse<UserInfoModel>>> => {
    return httpClient.get(ApiConstants.USER_INFO)
  }

  async collectAction(id: number, type: CollectActionType): Promise<boolean> {
    switch(type) {
      case CollectActionType.collect:
        let collectResponse: AxiosResponse<BaseResponse<string>> = await httpClient.post(ApiConstants.collectAdd(id))
        if (collectResponse.data.errorCode == 0) {
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
        let cancelCollectResponse: AxiosResponse<BaseResponse<string>> = await httpClient.post(ApiConstants.collectCancel(id))
        if (cancelCollectResponse.data.errorCode == 0) {
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
