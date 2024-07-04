import { UserInfoModel } from '../model/UserInfoModel'
import { LoginViewModel } from './LoginViewModel'
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import provider from '../HttpRequest/Provider';

export class IndexViewModel extends LoginViewModel {
  getUserInfo = (): Promise<AxiosResponse<BaseResponse<UserInfoModel>>> => {
    return provider.get<BaseResponse<UserInfoModel>, AxiosResponse<BaseResponse<UserInfoModel>>>("lg/coin/userinfo/json")
  }
}