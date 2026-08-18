import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { LoginModel } from '../model/LoginModel'
import { UserInfoModel } from '../model/UserInfoModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 认证数据仓库
 * @description 处理登录、注册、登出相关的数据请求
 */
export class LoginRepository extends BaseRepository {
  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   * @returns 登录模型
   */
  async login(username: string, password: string): Promise<LoginModel> {
    try {
      const response = await this.httpClient.post<LoginModel>(
        ApiConstants.userLogin(username, password)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`LoginRepository: 登录失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '登录失败')
      }
      
      LogUtil.debug(`LoginRepository: 登录成功，用户=${username}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param repassword 确认密码
   * @returns 登录模型
   */
  async register(username: string, password: string, repassword: string): Promise<LoginModel> {
    try {
      const response = await this.httpClient.post<LoginModel>(
        ApiConstants.userRegister(username, password, repassword)
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`LoginRepository: 注册失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '注册失败')
      }
      
      LogUtil.debug(`LoginRepository: 注册成功，用户=${username}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 用户登出
   * @returns 是否成功
   */
  async logout(): Promise<boolean> {
    try {
      const response = await this.httpClient.get<string>(
        ApiConstants.USER_LOGOUT
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`LoginRepository: 登出失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '登出失败')
      }
      
      LogUtil.debug('LoginRepository: 登出成功')
      return true
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }

  /**
   * 获取用户信息
   * @returns 用户信息
   */
  async getUserInfo(): Promise<UserInfoModel> {
    try {
      const response = await this.httpClient.get<UserInfoModel>(
        ApiConstants.USER_INFO
      )
      
      // 检查是否有错误
      if (response.errorCode !== 0) {
        LogUtil.error(`LoginRepository: 获取用户信息失败，errorCode=${response.errorCode}, errorMsg=${response.errorMsg}`)
        throw new Error(response.errorMsg || '获取用户信息失败')
      }
      
      LogUtil.debug('LoginRepository: 获取用户信息成功')
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
