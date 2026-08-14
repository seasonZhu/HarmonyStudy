import { UserInfoModel } from '../model/UserInfoModel'
import { LoginViewModel } from './LoginViewModel'
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { ApiConstants } from '../constants/ApiConstants';

export class IndexViewModel {
  getUserInfo = (): Promise<AxiosResponse<BaseResponse<UserInfoModel>>> => {
    return httpClient.get(ApiConstants.USER_INFO)
  }
}