import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import AccountManager from '../accountManager/AccountManager';
import httpClient from '../httpRequest/Provider';
import { LoginOrRegisterInfo } from '../entity/LoginOrRegisterInfo';
import { PreferencesUtil, LogUtil } from '@pura/harmony-utils';

export class LoginViewModel {
  public login(info: LoginOrRegisterInfo): Promise<boolean> {
    let api = 'user/login?username=' + info.username + '&password=' + info.password
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.post(api)
        .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
          // 处理成功情况
          if (response.data.errorCode == 0) {
            /// errorCode为0，业务上的登录成功
            LogUtil.debug("loginModel" + response.data.data)
            response.data.data.password = info.password
            AccountManager.shared().loginModel = response.data.data
            this.saveLoginOrRegisterInfo(info)
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          // 处理错误情况
          LogUtil.debug(JSON.stringify(error))
          resolve(false)
        })
    });
  }

  public register(info: LoginOrRegisterInfo): Promise<boolean> {
    let api = 'user/register?username=' + info.username + '&password=' + info.password+ '&repassword=' + info.repassword
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.post(api)
        .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
          // 处理成功情况
          if (response.data.errorCode == 0) {
            LogUtil.debug("loginModel" + response.data.data)
            response.data.data.password = info.password
            AccountManager.shared().loginModel = response.data.data
            this.saveLoginOrRegisterInfo(info)
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          // 处理错误情况
          LogUtil.debug(JSON.stringify(error))
          resolve(false)
        })
    });
  }

  public logout(): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.get("user/logout/json")
        .then((response: AxiosResponse<BaseResponse<string>>)=> {
          // 处理成功情况
          if (response.data.errorCode == 0) {
            AccountManager.shared().toDestroy()
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          // 处理错误情况
          LogUtil.debug(JSON.stringify(error))
          resolve(false)
        })
    });
  }

  async saveLoginOrRegisterInfo(info: LoginOrRegisterInfo) {
    PreferencesUtil.put("username", info.username)
    PreferencesUtil.put("password", info.password)
  }
}