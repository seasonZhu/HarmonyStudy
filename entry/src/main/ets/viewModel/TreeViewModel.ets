import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { TabModel } from '../model/TabModel';

export class TreeViewModel {
  getTree = (): Promise<AxiosResponse<BaseResponse<TabModel[]>>> => {
    return httpClient.get<BaseResponse<TabModel[]>>("tree/json")
  }
}