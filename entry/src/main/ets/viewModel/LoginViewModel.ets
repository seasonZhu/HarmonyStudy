import { LoginRepository } from '../repository/LoginRepository'
import { LoginModel } from '../model/LoginModel';
import { UserInfoModel } from '../model/UserInfoModel';
import AccountManager from '../accountManager/AccountManager';
import { LoginOrRegisterInfo } from '../entity/LoginOrRegisterInfo';
import { LogUtil } from '@pura/harmony-utils';
import { ErrorHandler } from '../utils/ErrorHandler';

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

/**
 * 认证视图模型
 * @description 处理登录、注册、登出相关的业务逻辑
 */
export class LoginViewModel {
  private loginRepo = new LoginRepository()

  /**
   * 用户登录
   * @param info 登录信息
   * @returns 是否成功
   */
  public login(info: LoginOrRegisterInfo): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      this.loginRepo.login(info.username, info.password)
        .then((loginModel: LoginModel)=> {
          LogUtil.debug("loginModel" + loginModel)
          loginModel.password = info.password
          AccountManager.shared().saveLoginModel(loginModel)
          resolve(true)
        })
        .catch((error: Error)=> {
          ErrorHandler.handle(error, '登录失败', false)
          resolve(false)
        })
    });
  }

  /**
   * 用户登录并获取用户信息
   * @param info 登录信息
   * @returns 登录结果
   */
  public async loginWithUserInfo(info: LoginOrRegisterInfo): Promise<LoginResult> {
    try {
      const loginSuccess = await this.login(info)
      if (!loginSuccess) {
        return { success: false }
      }
      const userInfo: UserInfoModel = await this.loginRepo.getUserInfo()
      return { success: true, userInfo: userInfo }
    } catch (error) {
      ErrorHandler.handle(error, '登录流程失败')
      return { success: false }
    }
  }

  /**
   * 用户注册
   * @param info 注册信息
   * @returns 是否成功
   */
  public register(info: LoginOrRegisterInfo): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      if (info.repassword == null) {
        resolve(false)
        return
      }
      this.loginRepo.register(info.username, info.password, info.repassword!)
        .then((loginModel: LoginModel)=> {
          LogUtil.debug("loginModel" + loginModel)
          loginModel.password = info.password
          AccountManager.shared().saveLoginModel(loginModel)
          resolve(true)
        })
        .catch((error: Error)=> {
          ErrorHandler.handle(error, '注册失败', false)
          resolve(false)
        })
    });
  }

  /**
   * 用户注册并获取用户信息
   * @param info 注册信息
   * @returns 注册结果
   */
  public async registerWithUserInfo(info: LoginOrRegisterInfo): Promise<RegisterResult> {
    try {
      const registerSuccess = await this.register(info)
      if (!registerSuccess) {
        return { success: false }
      }
      const userInfo: UserInfoModel = await this.loginRepo.getUserInfo()
      return { success: true, userInfo: userInfo }
    } catch (error) {
      ErrorHandler.handle(error, '注册流程失败')
      return { success: false }
    }
  }

  /**
   * 用户登出
   * @returns 是否成功
   */
  public logout(): Promise<boolean> {
    return new Promise<boolean>((resolve, _reject) => {
      this.loginRepo.logout()
        .then((success: boolean)=> {
          if (success) {
            AccountManager.shared().toDestroy()
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error: Error)=> {
          ErrorHandler.handle(error, '登出失败', false)
          resolve(false)
        })
    });
  }
}
