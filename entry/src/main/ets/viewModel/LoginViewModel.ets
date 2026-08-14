import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import { UserInfoModel } from '../model/UserInfoModel';
import AccountManager from '../accountManager/AccountManager';
import httpClient from '../httpRequest/Provider';
import { LoginOrRegisterInfo } from '../entity/LoginOrRegisterInfo';
import { LogUtil } from '@pura/harmony-utils';
import { ErrorHandler } from '../utils/ErrorHandler';
import { ApiConstants } from '../constants/ApiConstants';

export interface LoginResult {
  success: boolean
  userInfo?: UserInfoModel
  errorCode?: number
}

export interface RegisterResult {
  success: boolean
  userInfo?: UserInfoModel
  errorCode?: number
}

export class LoginViewModel {
  public login(info: LoginOrRegisterInfo): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.post(ApiConstants.userLogin(info.username, info.password))
        .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
          if (response.data.errorCode == 0) {
            LogUtil.debug("loginModel" + response.data.data)
            response.data.data.password = info.password
            AccountManager.shared().saveLoginModel(response.data.data)
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          ErrorHandler.handle(error, '登录失败', false)
          resolve(false)
        })
    });
  }

  public async loginWithUserInfo(info: LoginOrRegisterInfo): Promise<LoginResult> {
    try {
      const loginSuccess = await this.login(info)
      if (!loginSuccess) {
        return { success: false }
      }
      const response: AxiosResponse<BaseResponse<UserInfoModel>> = await httpClient.get(ApiConstants.USER_INFO)
      if (response.data.errorCode == 0) {
        return { success: true, userInfo: response.data.data }
      } else {
        return { success: false, errorCode: response.data.errorCode }
      }
    } catch (error) {
      ErrorHandler.handle(error, '登录流程失败')
      return { success: false }
    }
  }

  public register(info: LoginOrRegisterInfo): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      if (info.repassword == null) {
        resolve(false)
      }
      httpClient.post(ApiConstants.userRegister(info.username, info.password, info.repassword!))
        .then((response: AxiosResponse<BaseResponse<LoginModel>>)=> {
          if (response.data.errorCode == 0) {
            LogUtil.debug("loginModel" + response.data.data)
            response.data.data.password = info.password
            AccountManager.shared().saveLoginModel(response.data.data)
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          ErrorHandler.handle(error, '注册失败', false)
          resolve(false)
        })
    });
  }

  public async registerWithUserInfo(info: LoginOrRegisterInfo): Promise<RegisterResult> {
    try {
      const registerSuccess = await this.register(info)
      if (!registerSuccess) {
        return { success: false }
      }
      const response: AxiosResponse<BaseResponse<UserInfoModel>> = await httpClient.get(ApiConstants.USER_INFO)
      if (response.data.errorCode == 0) {
        return { success: true, userInfo: response.data.data }
      } else {
        return { success: false, errorCode: response.data.errorCode }
      }
    } catch (error) {
      ErrorHandler.handle(error, '注册流程失败')
      return { success: false }
    }
  }

  public logout(): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.get(ApiConstants.USER_LOGOUT)
        .then((response: AxiosResponse<BaseResponse<string>>)=> {
          if (response.data.errorCode == 0) {
            AccountManager.shared().toDestroy()
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: AxiosError)=> {
          ErrorHandler.handle(error, '登出失败', false)
          resolve(false)
        })
    });
  }
}