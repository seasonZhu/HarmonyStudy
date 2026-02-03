import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError } from '@ohos/axios'
import { HttpConfig, RequestMethod, HttpGlobalConfig, defaultGlobalConfig, mergeConfig } from '../models/HttpConfig'
import { ApiResponse } from '../models/ApiResponse'
import { ApiError, ApiErrorType, convertToApiError, createNetworkError, createTimeoutError, createServerError, createAuthError, createClientError } from '../models/ApiError'
import { InterceptorManager } from './InterceptorManager'
import { ErrorHandler } from './ErrorHandler'
import { LoadingService } from '../services/LoadingService'
import { LogUtil } from '@pura/harmony-utils'

/**
 * HTTP客户端类
 * @description 核心HTTP请求客户端，提供统一的请求接口
 */
export class HttpClient {
  /**
   * Axios实例
   */
  private axiosInstance: AxiosInstance

  /**
   * 全局配置
   */
  private globalConfig: HttpGlobalConfig

  /**
   * 拦截器管理器
   */
  private interceptorManager: InterceptorManager

  /**
   * 错误处理器
   */
  private errorHandler: ErrorHandler

  /**
   * 加载服务
   */
  private loadingService: LoadingService

  /**
   * 请求计数器（用于管理加载提示）
   */
  private requestCount: number = 0

  /**
   * 构造函数
   * @param config 全局配置
   */
  constructor(config: Partial<HttpGlobalConfig> = {}) {
    this.globalConfig = { ...defaultGlobalConfig, ...config }
    this.axiosInstance = axios.create({
      baseURL: this.globalConfig.baseURL,
      timeout: this.globalConfig.timeout
    })

    this.interceptorManager = new InterceptorManager()
    this.errorHandler = new ErrorHandler()
    this.loadingService = LoadingService.getInstance()

    this.setupInterceptors()
  }

  /**
   * 设置拦截器
   */
  private setupInterceptors(): void {
    // 请求拦截器
    this.axiosInstance.interceptors.request.use(
      (config) => {
        return this.interceptorManager.executeRequestInterceptors(config)
      },
      (error) => {
        return Promise.reject(this.interceptorManager.executeRequestErrorInterceptors(error))
      }
    )

    // 响应拦截器
    this.axiosInstance.interceptors.response.use(
      (response) => {
        return this.interceptorManager.executeResponseInterceptors(response)
      },
      (error) => {
        return Promise.reject(this.interceptorManager.executeResponseErrorInterceptors(error))
      }
    )
  }

  /**
   * 更新全局配置
   * @param config 新的配置
   */
  updateGlobalConfig(config: Partial<HttpGlobalConfig>): void {
    this.globalConfig = { ...this.globalConfig, ...config }
    this.axiosInstance.defaults.baseURL = this.globalConfig.baseURL
    this.axiosInstance.defaults.timeout = this.globalConfig.timeout
  }

  /**
   * 获取全局配置
   */
  getGlobalConfig(): HttpGlobalConfig {
    return { ...this.globalConfig }
  }

  /**
   * 获取Axios实例
   */
  getAxiosInstance(): AxiosInstance {
    return this.axiosInstance
  }

  /**
   * 通用请求方法
   * @param config 请求配置
   * @returns Promise<ApiResponse<T>>
   */
  async request<T>(config: HttpConfig): Promise<ApiResponse<T>> {
    const mergedConfig = mergeConfig(this.globalConfig, config)

    // 记录请求日志
    if (mergedConfig.enableLog) {
      LogUtil.debug(`[HTTP] ${mergedConfig.method || 'GET'} ${mergedConfig.url}`)
      if (mergedConfig.data) {
        LogUtil.debug(`[HTTP] Request Data: ${JSON.stringify(mergedConfig.data)}`)
      }
    }

    // 显示加载提示
    if (mergedConfig.showLoading) {
      this.requestCount++
      this.loadingService.show(mergedConfig.loadingText || '加载中...')
    }

    try {
      const axiosConfig: AxiosRequestConfig = {
        url: mergedConfig.url,
        method: mergedConfig.method,
        baseURL: mergedConfig.baseURL,
        headers: mergedConfig.headers,
        params: mergedConfig.params,
        data: mergedConfig.data,
        timeout: mergedConfig.timeout,
        responseType: mergedConfig.responseType
      }

      const response: AxiosResponse<ApiResponse<T>> = await this.axiosInstance.request(axiosConfig)

      // 记录响应日志
      if (mergedConfig.enableLog) {
        LogUtil.debug(`[HTTP] Response: ${JSON.stringify(response.data)}`)
      }

      return response.data
    } catch (error) {
      const apiError = this.handleRequestError(error as Error, mergedConfig)
      throw apiError
    } finally {
      // 隐藏加载提示
      if (mergedConfig.showLoading) {
        this.requestCount--
        if (this.requestCount <= 0) {
          this.requestCount = 0
          this.loadingService.hide()
        }
      }
    }
  }

  /**
   * GET请求
   * @param url 请求URL
   * @param params 查询参数
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async get<T>(url: string, params?: Record<string, unknown>, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: RequestMethod.GET,
      params,
      ...config
    })
  }

  /**
   * POST请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async post<T>(url: string, data?: unknown, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: RequestMethod.POST,
      data,
      ...config
    })
  }

  /**
   * PUT请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async put<T>(url: string, data?: unknown, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: RequestMethod.PUT,
      data,
      ...config
    })
  }

  /**
   * DELETE请求
   * @param url 请求URL
   * @param params 查询参数
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async delete<T>(url: string, params?: Record<string, unknown>, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: RequestMethod.DELETE,
      params,
      ...config
    })
  }

  /**
   * PATCH请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async patch<T>(url: string, data?: unknown, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    return this.request<T>({
      url,
      method: RequestMethod.PATCH,
      data,
      ...config
    })
  }

  /**
   * 处理请求错误
   * @param error 原始错误
   * @param config 请求配置
   * @returns ApiError
   */
  private handleRequestError(error: Error, config: HttpConfig): ApiError {
    if (this.errorHandler.canRetry(error, config)) {
      LogUtil.debug(`[HTTP] Request failed, retrying...`)
      // 重试逻辑由重试拦截器处理
    }

    return this.errorHandler.handleError(error, config.url, config.method)
  }

  /**
   * 添加请求拦截器
   * @param interceptor 拦截器函数
   * @returns 拦截器ID
   */
  addRequestInterceptor(interceptor: (config: AxiosRequestConfig) => AxiosRequestConfig): number {
    return this.axiosInstance.interceptors.request.use(interceptor)
  }

  /**
   * 添加响应拦截器
   * @param interceptor 拦截器函数
   * @returns 拦截器ID
   */
  addResponseInterceptor(interceptor: (response: AxiosResponse) => AxiosResponse): number {
    return this.axiosInstance.interceptors.response.use(interceptor)
  }

  /**
   * 移除请求拦截器
   * @param id 拦截器ID
   */
  removeRequestInterceptor(id: number): void {
    this.axiosInstance.interceptors.request.eject(id)
  }

  /**
   * 移除响应拦截器
   * @param id 拦截器ID
   */
  removeResponseInterceptor(id: number): void {
    this.axiosInstance.interceptors.response.eject(id)
  }
}
