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

export class MyCollectViewModel {
  private pageNum = 0

  getMyCollectList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }

    let api = "lg/collect/list/" + this.pageNum.toString() + "/json"
    return httpClient.get(api)
  }

  getUserInfo = (): Promise<AxiosResponse<BaseResponse<UserInfoModel>>> => {
    return httpClient.get("lg/coin/userinfo/json")
  }

  async collectAction(id: number, type: CollectActionType): Promise<boolean> {
    let api: string
    switch(type) {
      case CollectActionType.collect:
        api = "lg/collect/" + id + "/json"
        let collectResponse: AxiosResponse<BaseResponse<string>> = await httpClient.post(api)
        if (collectResponse.data.errorCode == 0) {
          ToastUtil.showToast("收藏成功")
          if (AccountManager.shared().loginModel && AccountManager.shared().loginModel?.collectIds) {
            let newLoginModel = AccountManager.shared().loginModel!
            let collectIds = AccountManager.shared().loginModel?.collectIds!
            collectIds.push(id)
            newLoginModel.collectIds = collectIds
            AccountManager.shared().loginModel = newLoginModel
          }
          return true
        } else {
          ToastUtil.showToast("收藏失败")
          return false
        }
        break
      case CollectActionType.cancel:
        api = "lg/uncollect_originId/" + id + "/json"
        let cancelCollectResponse: AxiosResponse<BaseResponse<string>> = await httpClient.post(api)
        if (cancelCollectResponse.data.errorCode == 0) {
          ToastUtil.showToast("取消收藏成功")
          if (AccountManager.shared().loginModel && AccountManager.shared().loginModel?.collectIds) {
            let newLoginModel = AccountManager.shared().loginModel!
            let collectIds = AccountManager.shared().loginModel?.collectIds!
            let index = collectIds.indexOf(id)
            if (index) {
              collectIds.splice(index, 1)
              newLoginModel.collectIds = collectIds
              AccountManager.shared().loginModel = newLoginModel
            }
          }
          return true
        } else {
          ToastUtil.showToast("取消收藏失败")
          return false
        }
        break
    }
  }
}