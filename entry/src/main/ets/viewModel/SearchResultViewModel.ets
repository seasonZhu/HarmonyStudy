import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { ScrollActionType } from '../Enum/ScrollActionType';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { KeywordInfo } from '../entity/KeywordInfo';

export class SearchResultViewModel {
  private pageNum = 0

  postSearchResultList = (type: ScrollActionType, keywordInfo: KeywordInfo): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }

    let api = "article/query/" + this.pageNum.toString() + "/json"
    /// 奇葩的post入参
    let params = `k=${keywordInfo.k}`
    return httpClient.post(api, params)
  }
}