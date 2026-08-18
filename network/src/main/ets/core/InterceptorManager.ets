import { AxiosRequestConfig, AxiosResponse, AxiosError } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 拦截器统计信息
 */
export interface InterceptorStats {
  requestCount: number
  requestErrorCount: number
  responseCount: number
  responseErrorCount: number
}

/**
 * 请求拦截器函数类型
 */
export type RequestInterceptorFunction = (config: AxiosRequestConfig) => AxiosRequestConfig | Promise<AxiosRequestConfig>

/**
 * 请求错误拦截器函数类型
 */
export type RequestErrorInterceptorFunction = (error: AxiosError) => Error | Promise<Error>

/**
 * 响应拦截器函数类型
 */
export type ResponseInterceptorFunction = (response: AxiosResponse) => AxiosResponse | Promise<AxiosResponse>

/**
 * 响应错误拦截器函数类型
 */
export type ResponseErrorInterceptorFunction = (error: AxiosError) => Error | Promise<Error> | Promise<never>

/**
 * 拦截器管理器
 * @description 管理所有请求和响应拦截器
 */
export class InterceptorManager {
  /**
   * 请求拦截器列表
   */
  private requestInterceptors: RequestInterceptorFunction[] = []

  /**
   * 请求错误拦截器列表
   */
  private requestErrorInterceptors: RequestErrorInterceptorFunction[] = []

  /**
   * 响应拦截器列表
   */
  private responseInterceptors: ResponseInterceptorFunction[] = []

  /**
   * 响应错误拦截器列表
   */
  private responseErrorInterceptors: ResponseErrorInterceptorFunction[] = []

  /**
   * 添加请求拦截器
   * @param interceptor 拦截器函数
   */
  addRequestInterceptor(interceptor: RequestInterceptorFunction): void {
    this.requestInterceptors.push(interceptor)
    LogUtil.debug('[InterceptorManager] 请求拦截器已添加')
  }

  /**
   * 添加请求错误拦截器
   * @param interceptor 拦截器函数
   */
  addRequestErrorInterceptor(interceptor: RequestErrorInterceptorFunction): void {
    this.requestErrorInterceptors.push(interceptor)
    LogUtil.debug('[InterceptorManager] 请求错误拦截器已添加')
  }

  /**
   * 添加响应拦截器
   * @param interceptor 拦截器函数
   */
  addResponseInterceptor(interceptor: ResponseInterceptorFunction): void {
    this.responseInterceptors.push(interceptor)
    LogUtil.debug('[InterceptorManager] 响应拦截器已添加')
  }

  /**
   * 添加响应错误拦截器
   * @param interceptor 拦截器函数
   */
  addResponseErrorInterceptor(interceptor: ResponseErrorInterceptorFunction): void {
    this.responseErrorInterceptors.push(interceptor)
    LogUtil.debug('[InterceptorManager] 响应错误拦截器已添加')
  }

  /**
   * 移除所有拦截器
   */
  clearAll(): void {
    this.requestInterceptors = []
    this.requestErrorInterceptors = []
    this.responseInterceptors = []
    this.responseErrorInterceptors = []
    LogUtil.debug('[InterceptorManager] 所有拦截器已清除')
  }

  /**
   * 执行所有请求拦截器
   * @param config Axios请求配置
   * @returns 处理后的配置
   */
  async executeRequestInterceptors(config: AxiosRequestConfig): Promise<AxiosRequestConfig> {
    let processedConfig: AxiosRequestConfig = config

    for (const interceptor of this.requestInterceptors) {
      try {
        processedConfig = await interceptor(processedConfig)
      } catch (e) {
        const error = e instanceof Error ? e : new Error(String(e))
        LogUtil.error('[InterceptorManager] 请求拦截器执行失败', error.message)
        throw error
      }
    }

    return processedConfig
  }

  /**
   * 执行所有请求错误拦截器
   * @param error Axios错误
   * @returns 处理后的错误
   */
  async executeRequestErrorInterceptors(error: AxiosError): Promise<Error> {
    let processedError: AxiosError = error

    for (const interceptor of this.requestErrorInterceptors) {
      try {
        const result = await interceptor(processedError)
        processedError = result as AxiosError
      } catch (e) {
        const err = e instanceof Error ? e : new Error(String(e))
        LogUtil.error('[InterceptorManager] 请求错误拦截器执行失败', err.message)
        return processedError
      }
    }

    return processedError
  }

  /**
   * 执行所有响应拦截器
   * @param response Axios响应
   * @returns 处理后的响应
   */
  async executeResponseInterceptors(response: AxiosResponse): Promise<AxiosResponse> {
    let processedResponse: AxiosResponse = response

    for (const interceptor of this.responseInterceptors) {
      try {
        processedResponse = await interceptor(processedResponse)
      } catch (e) {
        const error = e instanceof Error ? e : new Error(String(e))
        LogUtil.error('[InterceptorManager] 响应拦截器执行失败', error.message)
        throw error
      }
    }

    return processedResponse
  }

  /**
   * 执行所有响应错误拦截器
   * @param error Axios错误
   * @returns 处理后的结果
   */
  async executeResponseErrorInterceptors(error: AxiosError): Promise<never> {
    let processedError: AxiosError = error

    for (const interceptor of this.responseErrorInterceptors) {
      try {
        const result = await interceptor(processedError)
        if (result !== undefined) {
          const errorToThrow = result instanceof Error ? result : new Error(String(result))
          throw errorToThrow
        }
      } catch (e) {
        const err = e instanceof Error ? e : new Error(String(e))
        if (err === processedError) {
          LogUtil.error('[InterceptorManager] 响应错误拦截器执行失败', err.message)
        } else {
          throw err
        }
      }
    }

    throw new Error(processedError.message)
  }

  /**
   * 获取拦截器统计信息
   */
  getStats(): InterceptorStats {
    const stats: InterceptorStats = {
      requestCount: this.requestInterceptors.length,
      requestErrorCount: this.requestErrorInterceptors.length,
      responseCount: this.responseInterceptors.length,
      responseErrorCount: this.responseErrorInterceptors.length
    }
    return stats
  }
}
