import { UserInfoModel } from '../model/UserInfoModel'
import { LoginViewModel } from './LoginViewModel'
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';

export class IndexViewModel extends LoginViewModel {
  getUserInfo = (): Promise<AxiosResponse<BaseResponse<UserInfoModel>>> => {
    return httpClient.get("lg/coin/userinfo/json")
  }
}