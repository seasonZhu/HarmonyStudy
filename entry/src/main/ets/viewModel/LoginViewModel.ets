import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { LoginModel } from '../model/LoginModel';
import { UserInfoModel } from '../model/UserInfoModel';
import AccountManager from '../accountManager/AccountManager';
import httpClient from '../httpRequest/Provider';
import { LoginOrRegisterInfo } from '../entity/LoginOrRegisterInfo';
import { PreferencesUtil, LogUtil } from '@pura/harmony-utils';
import { ErrorHandler } from '../utils/ErrorHandler';

/**
 * 登录结果
 */
export interface LoginResult {
  success: boolean
  userInfo?: UserInfoModel
  errorCode?: number
}

/**
 * 注册结果
 */
export interface RegisterResult {
  success: boolean
  userInfo?: UserInfoModel
  errorCode?: number
}

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
          ErrorHandler.handle(error, '登录失败', false)
          resolve(false)
        })
    });
  }

  /**
   * 登录并获取用户信息 - 封装完整的登录流程
   * @param info 登录信息
   * @returns 登录结果，包含成功状态和用户信息
   */
  public async loginWithUserInfo(info: LoginOrRegisterInfo): Promise<LoginResult> {
    try {
      // 执行登录
      const loginSuccess = await this.login(info)
      if (!loginSuccess) {
        return { success: false }
      }

      // 获取用户信息
      const response: AxiosResponse<BaseResponse<UserInfoModel>> = await httpClient.get("lg/coin/userinfo/json")

      if (response.data.errorCode == 0) {
        return {
          success: true,
          userInfo: response.data.data
        }
      } else {
        return {
          success: false,
          errorCode: response.data.errorCode
        }
      }
    } catch (error) {
      ErrorHandler.handle(error, '登录流程失败')
      return { success: false }
    }
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
          ErrorHandler.handle(error, '注册失败', false)
          resolve(false)
        })
    });
  }

  /**
   * 注册并获取用户信息 - 封装完整的注册流程
   * @param info 注册信息
   * @returns 注册结果，包含成功状态和用户信息
   */
  public async registerWithUserInfo(info: LoginOrRegisterInfo): Promise<RegisterResult> {
    try {
      // 执行注册
      const registerSuccess = await this.register(info)
      if (!registerSuccess) {
        return { success: false }
      }

      // 获取用户信息
      const response: AxiosResponse<BaseResponse<UserInfoModel>> = await httpClient.get("lg/coin/userinfo/json")

      if (response.data.errorCode == 0) {
        return {
          success: true,
          userInfo: response.data.data
        }
      } else {
        return {
          success: false,
          errorCode: response.data.errorCode
        }
      }
    } catch (error) {
      ErrorHandler.handle(error, '注册流程失败')
      return { success: false }
    }
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
          ErrorHandler.handle(error, '登出失败', false)
          resolve(false)
        })
    });
  }

  async saveLoginOrRegisterInfo(info: LoginOrRegisterInfo) {
    PreferencesUtil.put("username", info.username)
    PreferencesUtil.put("password", info.password)
  }
}