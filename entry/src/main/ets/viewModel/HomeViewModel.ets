import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { Banner } from '../model/Banner'
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import AccountManager from '../accountManager/AccountManager';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../enum/ScrollActionType';
import httpClient from '../httpRequest/Provider';
import { LogUtil } from '@pura/harmony-utils';

/**
 * 网络请求响应联合类型
 * 明确定义所有可能的响应类型，增强类型安全
 */
type HomeNetworkResponseType =
  | AxiosResponse<BaseResponse<Banner[]>>
  | AxiosResponse<BaseResponse<Article[]>>
  | AxiosResponse<BaseResponse<PageModel<Article>>>

export class HomeViewModel {

  private pageNum = 1

  getBanner = (): Promise<AxiosResponse<BaseResponse<Banner[]>>> => {
    return httpClient.get('banner/json')
  }

  getHotArticle = (): Promise<AxiosResponse<BaseResponse<Article[]>>> => {
    return httpClient.get('article/top/json')
  }

  getNormalArticle = (page: number): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    let pageString = page.toString()
    let api = 'article/list/' + pageString + '/json'
    return httpClient.get(api)
  }

  /**
   * 网络请求 - 使用明确的联合类型保证类型安全
   * @param type 滚动操作类型
   * @returns 响应数组，类型明确
   */
  public networkRequest(type: ScrollActionType): Promise<HomeNetworkResponseType[]>  {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
      return Promise.all<HomeNetworkResponseType>([
        this.getBanner(),
        this.getHotArticle(),
        this.getNormalArticle(this.pageNum)
      ])
    } else {
      this.pageNum = this.pageNum + 1
      return Promise.all<HomeNetworkResponseType>([this.getNormalArticle(this.pageNum)])
    }
  }

  public loginAction(username: string, password: string) {
    LogUtil.debug("按钮点击了，准备进行做登录")
    let api = 'user/login?username=' + username + '&password=' + password
    httpClient.post<BaseResponse<LoginModel>>(api)
      .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
        // 处理成功情况
        LogUtil.debug("loginModel" + response.data.data)
        response.data.data.password = password
        AccountManager.shared().loginModel = response.data.data
      })
      .catch((error: AxiosError)=> {
        // 处理错误情况
        LogUtil.debug(JSON.stringify(error))
      })
  }
}