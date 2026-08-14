import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { Banner } from '../model/Banner'
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import AccountManager from '../accountManager/AccountManager';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import httpClient from '../httpRequest/Provider';
import { LogUtil } from '@pura/harmony-utils';
import { ApiConstants } from '../constants/ApiConstants';

export interface HomeRefreshResult {
  bannerResponse: AxiosResponse<BaseResponse<Banner[]>>
  hotArticleResponse: AxiosResponse<BaseResponse<Article[]>>
  normalArticleResponse: AxiosResponse<BaseResponse<PageModel<Article>>>
}

export class HomeViewModel {

  private pageNum = 1

  getBanner = (): Promise<AxiosResponse<BaseResponse<Banner[]>>> => {
    return httpClient.get(ApiConstants.BANNER)
  }

  getHotArticle = (): Promise<AxiosResponse<BaseResponse<Article[]>>> => {
    return httpClient.get(ApiConstants.ARTICLE_TOP)
  }

  getNormalArticle = (page: number): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    return httpClient.get(ApiConstants.articleList(page))
  }

  public async refreshRequest(): Promise<HomeRefreshResult> {
    this.pageNum = 1
    const bannerResponse: AxiosResponse<BaseResponse<Banner[]>> = await this.getBanner()
    const hotArticleResponse: AxiosResponse<BaseResponse<Article[]>> = await this.getHotArticle()
    const normalArticleResponse: AxiosResponse<BaseResponse<PageModel<Article>>> = await this.getNormalArticle(this.pageNum)
    return {
      bannerResponse: bannerResponse,
      hotArticleResponse: hotArticleResponse,
      normalArticleResponse: normalArticleResponse
    }
  }

  public async loadMoreRequest(): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> {
    this.pageNum = this.pageNum + 1
    return this.getNormalArticle(this.pageNum)
  }

  public loginAction(username: string, password: string) {
    LogUtil.debug("按钮点击了，准备进行做登录")
    httpClient.post<BaseResponse<LoginModel>>(ApiConstants.userLogin(username, password))
      .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
        LogUtil.debug("loginModel" + response.data.data)
        response.data.data.password = password
        AccountManager.shared().saveLoginModel(response.data.data)
      })
      .catch((error: AxiosError)=> {
        LogUtil.debug(JSON.stringify(error))
      })
  }
}