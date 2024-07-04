import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { ScrollActionType } from '../Enum/ScrollActionType';
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

    let api = "lg/coin/list/" + this.pageNum.toString() + "/json"
    return httpClient.get<BaseResponse<PageModel<MyCoinModel>>>(api)
  }
}