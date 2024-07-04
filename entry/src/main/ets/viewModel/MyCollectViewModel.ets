import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { ScrollActionType } from '../Enum/ScrollActionType';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';

export class MyCollectViewModel {
  private pageNum = 0

  getMyCollectList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 0
    } else {
      this.pageNum = this.pageNum + 1
    }

    let api = "lg/collect/list/" + this.pageNum.toString() + "/json"
    return httpClient.get<BaseResponse<PageModel<Article>>>(api)
  }
}