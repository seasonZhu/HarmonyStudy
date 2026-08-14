import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { ApiConstants } from '../constants/ApiConstants';
import { ScrollActionType } from '../enum/ScrollActionType';
import { RankModel } from '../model/RankModel';
import { PageModel } from '../model/PageModel';

export class RankViewModel {
  private pageNum = 1

  getRankList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<RankModel>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }

    return httpClient.get(ApiConstants.coinRank(this.pageNum))
  }
}