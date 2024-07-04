import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { ScrollActionType } from '../Enum/ScrollActionType';
import { RankModel } from '../model/RankModel';
import { PageModel } from '../model/PageModel';
import { KeywordInfo } from '../entity/KeywordInfo';

export class RankViewModel {
  private pageNum = 1

  postSearchResultList = (type: ScrollActionType, keywordInfo: KeywordInfo): Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }

    let api = "coin/rank/" + this.pageNum.toString() + "/json"
    return httpClient.get<BaseResponse<PageModel<RankModel>>>(api)
  }
}