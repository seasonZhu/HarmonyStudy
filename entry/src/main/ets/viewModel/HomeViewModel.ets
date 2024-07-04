import { BaseViewModel } from './BaseViewModel';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { Banner } from '../model/Banner'
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import AccountManager from '../AccountManager/AccountManager';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { ScrollActionType } from '../Enum/ScrollActionType';
import provider from '../HttpRequest/Provider';
import { MyCoinModel } from '../model/MyCoinModel';
import { HotKeyModel } from '../model/HotKeyModel';

export class HomeViewModel {

  private pageNum = 1

  getBanner = (): Promise<AxiosResponse<BaseResponse<Banner[]>>> => {
    return provider.get<BaseResponse<Banner[]>, AxiosResponse<BaseResponse<Banner[]>>>('banner/json')
  }

  getHotArticle = (): Promise<AxiosResponse<BaseResponse<Article[]>>> => {
    return provider.get<BaseResponse<Article[]>, AxiosResponse<BaseResponse<Article[]>>>('article/top/json')
  }

  getNormalArticle = (page: number): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    let pageString = page.toString()
    let api = 'article/list/' + pageString + '/json'
    return provider.get<BaseResponse<PageModel<Article>>, AxiosResponse<BaseResponse<PageModel<Article>>>>(api)
  }

  getMyCoinList = (page: number): Promise<AxiosResponse<BaseResponse<PageModel<MyCoinModel>>>> => {
    let pageString = page.toString()
    let api = `lg/coin/list/${pageString}/json`
    return provider.get<BaseResponse<PageModel<MyCoinModel>>, AxiosResponse<BaseResponse<PageModel<MyCoinModel>>>>(api)
  }

  /// 这个地方的返回值写了很久，另外大写的Object与object是两个东西
  public networkRequest(type: ScrollActionType): Promise<AxiosResponse<Object>[]>  {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
      return Promise.all<AxiosResponse>([this.getBanner(), this.getHotArticle(), this.getNormalArticle(this.pageNum)])
    } else {
      this.pageNum = this.pageNum + 1
      return Promise.all<AxiosResponse>([this.getNormalArticle(this.pageNum)])
    }
  }

  public loginAction(username: string, password: string) {
    console.info("按钮点击了，准备进行做登录")
    let api = 'user/login?username=' + username + '&password=' + password
    provider.post<BaseResponse<LoginModel>, AxiosResponse<BaseResponse<LoginModel>>>(api)
      .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
        // 处理成功情况
        console.info("loginModel" + response.data.data)
        response.data.data.password = password
        AccountManager.shared().loginModel = response.data.data
      })
      .catch((error: AxiosError)=> {
        // 处理错误情况
        console.info(JSON.stringify(error))
      })
  }
}