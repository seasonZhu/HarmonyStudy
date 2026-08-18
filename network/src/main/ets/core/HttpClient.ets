import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError, InternalAxiosRequestConfig, ResponseType } from '@ohos/axios'
import { HttpConfig, RequestMethod, HttpGlobalConfig, defaultGlobalConfig, mergeConfig, HttpParams, HttpBody } from '../models/HttpConfig'
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
    // 手动合并配置，不使用Object.assign
    this.globalConfig = {
      baseURL: config.baseURL !== undefined ? config.baseURL : defaultGlobalConfig.baseURL,
      timeout: config.timeout !== undefined ? config.timeout : defaultGlobalConfig.timeout,
      headers: config.headers !== undefined ? config.headers : defaultGlobalConfig.headers,
      enableLog: config.enableLog !== undefined ? config.enableLog : defaultGlobalConfig.enableLog,
      showLoading: config.showLoading !== undefined ? config.showLoading : defaultGlobalConfig.showLoading,
      loadingText: config.loadingText !== undefined ? config.loadingText : defaultGlobalConfig.loadingText,
      enableRetry: config.enableRetry !== undefined ? config.enableRetry : defaultGlobalConfig.enableRetry,
      maxRetryCount: config.maxRetryCount !== undefined ? config.maxRetryCount : defaultGlobalConfig.maxRetryCount,
      retryDelay: config.retryDelay !== undefined ? config.retryDelay : defaultGlobalConfig.retryDelay,
      requireAuth: config.requireAuth !== undefined ? config.requireAuth : defaultGlobalConfig.requireAuth
    }
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
      async (config: InternalAxiosRequestConfig) => {
        const axiosConfig: AxiosRequestConfig = config as AxiosRequestConfig
        const result: AxiosRequestConfig = await this.interceptorManager.executeRequestInterceptors(axiosConfig)
        return result as InternalAxiosRequestConfig
      },
      (error: Error) => {
        const axiosError: AxiosError = error as AxiosError
        return this.interceptorManager.executeRequestErrorInterceptors(axiosError).then((e: Error) => {
          throw e
        })
      }
    )

    // 响应拦截器
    this.axiosInstance.interceptors.response.use(
      (response: AxiosResponse) => {
        return this.interceptorManager.executeResponseInterceptors(response)
      },
      (error: Error) => {
        return this.interceptorManager.executeResponseErrorInterceptors(error as AxiosError).catch((e: Error) => {
          throw e
        })
      }
    )
  }

  /**
   * 更新全局配置
   * @param config 新的配置
   */
  updateGlobalConfig(config: Partial<HttpGlobalConfig>): void {
    // 手动合并配置
    if (config.baseURL !== undefined) this.globalConfig.baseURL = config.baseURL
    if (config.timeout !== undefined) this.globalConfig.timeout = config.timeout
    if (config.headers !== undefined) this.globalConfig.headers = config.headers
    if (config.enableLog !== undefined) this.globalConfig.enableLog = config.enableLog
    if (config.showLoading !== undefined) this.globalConfig.showLoading = config.showLoading
    if (config.loadingText !== undefined) this.globalConfig.loadingText = config.loadingText
    if (config.enableRetry !== undefined) this.globalConfig.enableRetry = config.enableRetry
    if (config.maxRetryCount !== undefined) this.globalConfig.maxRetryCount = config.maxRetryCount
    if (config.retryDelay !== undefined) this.globalConfig.retryDelay = config.retryDelay
    if (config.requireAuth !== undefined) this.globalConfig.requireAuth = config.requireAuth

    this.axiosInstance.defaults.baseURL = this.globalConfig.baseURL
    this.axiosInstance.defaults.timeout = this.globalConfig.timeout
  }

  /**
   * 获取全局配置
   */
  getGlobalConfig(): HttpGlobalConfig {
    return {
      baseURL: this.globalConfig.baseURL,
      timeout: this.globalConfig.timeout,
      headers: this.globalConfig.headers,
      enableLog: this.globalConfig.enableLog,
      showLoading: this.globalConfig.showLoading,
      loadingText: this.globalConfig.loadingText,
      enableRetry: this.globalConfig.enableRetry,
      maxRetryCount: this.globalConfig.maxRetryCount,
      retryDelay: this.globalConfig.retryDelay,
      requireAuth: this.globalConfig.requireAuth
    }
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
      // 根据responseType设置正确的类型
      let responseTypeValue: ResponseType = 'json' as ResponseType
      if (mergedConfig.responseType === 'text') {
        responseTypeValue = 'text' as ResponseType
      } else if (mergedConfig.responseType === 'arraybuffer') {
        responseTypeValue = 'arraybuffer' as ResponseType
      } else if (mergedConfig.responseType === 'blob') {
        responseTypeValue = 'blob' as ResponseType
      }

      const axiosConfig: AxiosRequestConfig = {
        url: mergedConfig.url,
        method: mergedConfig.method,
        baseURL: mergedConfig.baseURL,
        headers: mergedConfig.headers,
        params: mergedConfig.params as Record<string, string | number | boolean>,
        data: mergedConfig.data as object | string,
        timeout: mergedConfig.timeout,
        responseType: responseTypeValue
      }

      const response: AxiosResponse<ApiResponse<T>> = await this.axiosInstance.request(axiosConfig)

      // 记录响应日志
      if (mergedConfig.enableLog) {
        LogUtil.debug(`[HTTP] Response: ${JSON.stringify(response.data)}`)
      }

      return response.data
    } catch (e) {
      const error = e instanceof Error ? e : new Error(String(e))
      const apiError = this.handleRequestError(error, mergedConfig)
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
  async get<T>(url: string, params?: HttpParams, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    const requestConfig: HttpConfig = {
      url,
      method: RequestMethod.GET,
      params: params
    }
    if (config) {
      if (config.baseURL !== undefined) requestConfig.baseURL = config.baseURL
      if (config.headers !== undefined) requestConfig.headers = config.headers
      if (config.data !== undefined) requestConfig.data = config.data
      if (config.timeout !== undefined) requestConfig.timeout = config.timeout
      if (config.showLoading !== undefined) requestConfig.showLoading = config.showLoading
      if (config.loadingText !== undefined) requestConfig.loadingText = config.loadingText
      if (config.enableRetry !== undefined) requestConfig.enableRetry = config.enableRetry
      if (config.maxRetryCount !== undefined) requestConfig.maxRetryCount = config.maxRetryCount
      if (config.retryDelay !== undefined) requestConfig.retryDelay = config.retryDelay
      if (config.requireAuth !== undefined) requestConfig.requireAuth = config.requireAuth
      if (config.enableLog !== undefined) requestConfig.enableLog = config.enableLog
      if (config.tag !== undefined) requestConfig.tag = config.tag
      if (config.responseType !== undefined) requestConfig.responseType = config.responseType
      if (config.customConfig !== undefined) requestConfig.customConfig = config.customConfig
    }
    return this.request<T>(requestConfig)
  }

  /**
   * POST请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async post<T>(url: string, data?: HttpBody, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    const requestConfig: HttpConfig = {
      url,
      method: RequestMethod.POST,
      data: data
    }
    if (config) {
      if (config.baseURL !== undefined) requestConfig.baseURL = config.baseURL
      if (config.headers !== undefined) requestConfig.headers = config.headers
      if (config.params !== undefined) requestConfig.params = config.params
      if (config.timeout !== undefined) requestConfig.timeout = config.timeout
      if (config.showLoading !== undefined) requestConfig.showLoading = config.showLoading
      if (config.loadingText !== undefined) requestConfig.loadingText = config.loadingText
      if (config.enableRetry !== undefined) requestConfig.enableRetry = config.enableRetry
      if (config.maxRetryCount !== undefined) requestConfig.maxRetryCount = config.maxRetryCount
      if (config.retryDelay !== undefined) requestConfig.retryDelay = config.retryDelay
      if (config.requireAuth !== undefined) requestConfig.requireAuth = config.requireAuth
      if (config.enableLog !== undefined) requestConfig.enableLog = config.enableLog
      if (config.tag !== undefined) requestConfig.tag = config.tag
      if (config.responseType !== undefined) requestConfig.responseType = config.responseType
      if (config.customConfig !== undefined) requestConfig.customConfig = config.customConfig
    }
    return this.request<T>(requestConfig)
  }

  /**
   * PUT请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async put<T>(url: string, data?: HttpBody, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    const requestConfig: HttpConfig = {
      url,
      method: RequestMethod.PUT,
      data: data
    }
    if (config) {
      if (config.baseURL !== undefined) requestConfig.baseURL = config.baseURL
      if (config.headers !== undefined) requestConfig.headers = config.headers
      if (config.params !== undefined) requestConfig.params = config.params
      if (config.timeout !== undefined) requestConfig.timeout = config.timeout
      if (config.showLoading !== undefined) requestConfig.showLoading = config.showLoading
      if (config.loadingText !== undefined) requestConfig.loadingText = config.loadingText
      if (config.enableRetry !== undefined) requestConfig.enableRetry = config.enableRetry
      if (config.maxRetryCount !== undefined) requestConfig.maxRetryCount = config.maxRetryCount
      if (config.retryDelay !== undefined) requestConfig.retryDelay = config.retryDelay
      if (config.requireAuth !== undefined) requestConfig.requireAuth = config.requireAuth
      if (config.enableLog !== undefined) requestConfig.enableLog = config.enableLog
      if (config.tag !== undefined) requestConfig.tag = config.tag
      if (config.responseType !== undefined) requestConfig.responseType = config.responseType
      if (config.customConfig !== undefined) requestConfig.customConfig = config.customConfig
    }
    return this.request<T>(requestConfig)
  }

  /**
   * DELETE请求
   * @param url 请求URL
   * @param params 查询参数
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async delete<T>(url: string, params?: HttpParams, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    const requestConfig: HttpConfig = {
      url,
      method: RequestMethod.DELETE,
      params: params
    }
    if (config) {
      if (config.baseURL !== undefined) requestConfig.baseURL = config.baseURL
      if (config.headers !== undefined) requestConfig.headers = config.headers
      if (config.data !== undefined) requestConfig.data = config.data
      if (config.timeout !== undefined) requestConfig.timeout = config.timeout
      if (config.showLoading !== undefined) requestConfig.showLoading = config.showLoading
      if (config.loadingText !== undefined) requestConfig.loadingText = config.loadingText
      if (config.enableRetry !== undefined) requestConfig.enableRetry = config.enableRetry
      if (config.maxRetryCount !== undefined) requestConfig.maxRetryCount = config.maxRetryCount
      if (config.retryDelay !== undefined) requestConfig.retryDelay = config.retryDelay
      if (config.requireAuth !== undefined) requestConfig.requireAuth = config.requireAuth
      if (config.enableLog !== undefined) requestConfig.enableLog = config.enableLog
      if (config.tag !== undefined) requestConfig.tag = config.tag
      if (config.responseType !== undefined) requestConfig.responseType = config.responseType
      if (config.customConfig !== undefined) requestConfig.customConfig = config.customConfig
    }
    return this.request<T>(requestConfig)
  }

  /**
   * PATCH请求
   * @param url 请求URL
   * @param data 请求体数据
   * @param config 额外配置
   * @returns Promise<ApiResponse<T>>
   */
  async patch<T>(url: string, data?: HttpBody, config?: Partial<HttpConfig>): Promise<ApiResponse<T>> {
    const requestConfig: HttpConfig = {
      url,
      method: RequestMethod.PATCH,
      data: data
    }
    if (config) {
      if (config.baseURL !== undefined) requestConfig.baseURL = config.baseURL
      if (config.headers !== undefined) requestConfig.headers = config.headers
      if (config.params !== undefined) requestConfig.params = config.params
      if (config.timeout !== undefined) requestConfig.timeout = config.timeout
      if (config.showLoading !== undefined) requestConfig.showLoading = config.showLoading
      if (config.loadingText !== undefined) requestConfig.loadingText = config.loadingText
      if (config.enableRetry !== undefined) requestConfig.enableRetry = config.enableRetry
      if (config.maxRetryCount !== undefined) requestConfig.maxRetryCount = config.maxRetryCount
      if (config.retryDelay !== undefined) requestConfig.retryDelay = config.retryDelay
      if (config.requireAuth !== undefined) requestConfig.requireAuth = config.requireAuth
      if (config.enableLog !== undefined) requestConfig.enableLog = config.enableLog
      if (config.tag !== undefined) requestConfig.tag = config.tag
      if (config.responseType !== undefined) requestConfig.responseType = config.responseType
      if (config.customConfig !== undefined) requestConfig.customConfig = config.customConfig
    }
    return this.request<T>(requestConfig)
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
  addRequestInterceptor(interceptor: (config: InternalAxiosRequestConfig) => InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>): number {
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
