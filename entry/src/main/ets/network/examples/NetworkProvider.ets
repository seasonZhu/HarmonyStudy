/**
 * NetworkProvider - 基于 network 模块的网络请求封装
 * @description 提供统一的网络请求接口，支持环境切换、Token管理、重试等功能
 */

import { HttpClient, getHttpClient, resetHttpClient, ApiResponse, ApiError, HttpConfig, RequestMethod } from 'network'
import { Environment, environmentService } from 'network'
import { LogUtil } from '@pura/harmony-utils'
import { preferences } from '@kit.ArkData'

/**
 * Token 存储管理
 */
class TokenManager {
  private static TOKEN_KEY = 'user_token'
  private static preferencesInstance: preferences.Preferences | null = null

  static async init(context: Context): Promise<void> {
    try {
      TokenManager.preferencesInstance = await preferences.getPreferences(context, 'user_prefs')
    } catch (error) {
      LogUtil.error('[TokenManager] 初始化失败', JSON.stringify(error))
    }
  }

  static async getToken(): Promise<string> {
    if (!TokenManager.preferencesInstance) {
      return ''
    }
    try {
      return await TokenManager.preferencesInstance.get(TokenManager.TOKEN_KEY, '') as string
    } catch (error) {
      LogUtil.error('[TokenManager] 获取Token失败', JSON.stringify(error))
      return ''
    }
  }

  static async setToken(token: string): Promise<void> {
    if (!TokenManager.preferencesInstance) {
      return
    }
    try {
      await TokenManager.preferencesInstance.put(TokenManager.TOKEN_KEY, token)
      await TokenManager.preferencesInstance.flush()
      LogUtil.info('[TokenManager] Token已保存')
    } catch (error) {
      LogUtil.error('[TokenManager] 保存Token失败', JSON.stringify(error))
    }
  }

  static async clearToken(): Promise<void> {
    if (!TokenManager.preferencesInstance) {
      return
    }
    try {
      await TokenManager.preferencesInstance.delete(TokenManager.TOKEN_KEY)
      await TokenManager.preferencesInstance.flush()
      LogUtil.info('[TokenManager] Token已清除')
    } catch (error) {
      LogUtil.error('[TokenManager] 清除Token失败', JSON.stringify(error))
    }
  }
}

/**
 * NetworkProvider 类
 * @description 提供统一的网络请求接口
 */
export class NetworkProvider {
  private static client: HttpClient | null = null
  private static isInitialized: boolean = false

  /**
   * 初始化 NetworkProvider
   * @param context 应用上下文
   */
  static async init(context: Context): Promise<void> {
    if (NetworkProvider.isInitialized) {
      LogUtil.warn('[NetworkProvider] 已经初始化，跳过重复初始化')
      return
    }

    try {
      // 初始化 TokenManager
      await TokenManager.init(context)

      // 初始化环境服务（使用默认开发环境）
      await environmentService.init(context)

      // 获取 HTTP 客户端实例
      NetworkProvider.client = getHttpClient()

      // 配置 Token 拦截器
      const token = await TokenManager.getToken()
      if (token) {
        LogUtil.info('[NetworkProvider] 使用已保存的 Token')
      }

      NetworkProvider.isInitialized = true
      LogUtil.info('[NetworkProvider] 初始化成功')
    } catch (error) {
      LogUtil.error('[NetworkProvider] 初始化失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 确保 NetworkProvider 已初始化
   */
  private static ensureInitialized(): void {
    if (!NetworkProvider.isInitialized || !NetworkProvider.client) {
      throw new Error('[NetworkProvider] 未初始化，请先调用 init() 方法')
    }
  }

  /**
   * 获取 HttpClient 实例
   */
  static getClient(): HttpClient {
    NetworkProvider.ensureInitialized()
    return NetworkProvider.client as HttpClient
  }

  /**
   * 设置 Token
   */
  static async setToken(token: string): Promise<void> {
    await TokenManager.setToken(token)
  }

  /**
   * 清除 Token
   */
  static async clearToken(): Promise<void> {
    await TokenManager.clearToken()
  }

  /**
   * 获取当前 Token
   */
  static async getToken(): Promise<string> {
    return await TokenManager.getToken()
  }

  /**
   * 切换环境
   */
  static async switchEnvironment(environment: Environment): Promise<void> {
    try {
      // 切换环境
      await environmentService.setCurrentEnvironment(environment)

      // 重置 HTTP 客户端
      resetHttpClient()
      NetworkProvider.client = getHttpClient()

      LogUtil.info('[NetworkProvider] 环境已切换为', environment)
    } catch (error) {
      LogUtil.error('[NetworkProvider] 切换环境失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * GET 请求
   */
  static async get<T>(
    url: string,
    params?: Record<string, string | number | boolean>,
    config?: Partial<HttpConfig>
  ): Promise<ApiResponse<T>> {
    return NetworkProvider.getClient().get<T>(url, params, config)
  }

  /**
   * POST 请求
   */
  static async post<T>(
    url: string,
    data?: object | string,
    config?: Partial<HttpConfig>
  ): Promise<ApiResponse<T>> {
    return NetworkProvider.getClient().post<T>(url, data, config)
  }

  /**
   * PUT 请求
   */
  static async put<T>(
    url: string,
    data?: object | string,
    config?: Partial<HttpConfig>
  ): Promise<ApiResponse<T>> {
    return NetworkProvider.getClient().put<T>(url, data, config)
  }

  /**
   * DELETE 请求
   */
  static async delete<T>(
    url: string,
    params?: Record<string, string | number | boolean>,
    config?: Partial<HttpConfig>
  ): Promise<ApiResponse<T>> {
    return NetworkProvider.getClient().delete<T>(url, params, config)
  }

  /**
   * PATCH 请求
   */
  static async patch<T>(
    url: string,
    data?: object | string,
    config?: Partial<HttpConfig>
  ): Promise<ApiResponse<T>> {
    return NetworkProvider.getClient().patch<T>(url, data, config)
  }
}

/**
 * 导出单例实例（直接使用静态方法即可）
 */
export default NetworkProvider
