import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import provider from '../HttpRequest/Provider';
import { HotKeyModel } from '../model/HotKeyModel';

export class HotKeyViewModel {
  getHotKey = (): Promise<AxiosResponse<BaseResponse<HotKeyModel[]>>> => {
    return provider.get<BaseResponse<HotKeyModel[]>, AxiosResponse<BaseResponse<HotKeyModel[]>>>('hotkey/json')
  }
}