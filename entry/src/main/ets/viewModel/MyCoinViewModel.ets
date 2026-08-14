import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { ApiConstants } from '../constants/ApiConstants';
import { ScrollActionType } from '../enum/ScrollActionType';
import { MyCoinModel } from '../model/MyCoinModel';
import { PageModel } from '../model/PageModel';

export class MyCoinViewModel {
  private pageNum = 1

  getMyCoinList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<MyCoinModel>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }

    return httpClient.get(ApiConstants.coinList(this.pageNum))
  }
}