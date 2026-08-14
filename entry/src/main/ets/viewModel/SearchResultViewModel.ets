import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { ScrollActionType } from '../enum/ScrollActionType';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import { KeywordInfo } from '../entity/KeywordInfo';
import { ApiConstants } from '../constants/ApiConstants';

export class SearchResultViewModel {
  private pageNum = 0

  postSearchResultList = (type: ScrollActionType, keywordInfo: KeywordInfo): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }

    let params = `k=${keywordInfo.k}`
    return httpClient.post(ApiConstants.articleQuery(this.pageNum), params)
  }
}