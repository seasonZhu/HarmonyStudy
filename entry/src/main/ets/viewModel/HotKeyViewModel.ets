import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { HotKeyModel } from '../model/HotKeyModel';
import httpClient from '../httpRequest/Provider';
import { ApiConstants } from '../constants/ApiConstants';

export class HotKeyViewModel {
  getHotKey = (): Promise<AxiosResponse<BaseResponse<HotKeyModel[]>>> => {
    return httpClient.get(ApiConstants.HOTKEY)
  }
}