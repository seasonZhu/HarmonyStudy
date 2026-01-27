import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
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

    let api = "coin/rank/" + this.pageNum.toString() + "/json"
    return httpClient.get(api)
  }
}