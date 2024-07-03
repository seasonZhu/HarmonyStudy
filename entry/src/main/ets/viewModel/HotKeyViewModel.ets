import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { HotKeyModel } from '../model/HotKeyModel';

export class HotKeyViewModel {
  getHotKey = (): Promise<AxiosResponse<BaseResponse<HotKeyModel[]>>> => {
    return httpClient.get<BaseResponse<HotKeyModel[]>>('hotkey/json')
  }
}