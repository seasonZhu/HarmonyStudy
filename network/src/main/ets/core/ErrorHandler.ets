import { AxiosError } from '@ohos/axios'
import { ApiError, ApiErrorType, createNetworkError, createTimeoutError, createServerError, createClientError, createAuthError, convertToApiError } from '../models/ApiError'
import { HttpConfig } from '../models/HttpConfig'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 错误响应数据接口
 */
interface ErrorResponseData {
  message?: string
  msg?: string
  error?: string
  errorMessage?: string
  error_message?: string
  errorMsg?: string
  error_msg?: string
}

/**
 * Axios响应接口
 */
interface AxiosResponseLike {
  status: number
  statusText: string
  data: object | null | string | number | boolean
}

/**
 * 错误处理器
 * @description 统一处理HTTP请求错误，将各种错误转换为ApiError
 */
export class ErrorHandler {
  /**
   * 判断是否可以重试
   * @param error 错误对象
   * @param config 请求配置
   * @returns 是否可以重试
   */
  canRetry(error: Error, config: HttpConfig): boolean {
    if (!config.enableRetry) {
      return false
    }

    // 如果是网络错误或超时错误，可以重试
    if (error instanceof ApiError) {
      return (
        error.type === ApiErrorType.NETWORK_ERROR ||
        error.type === ApiErrorType.TIMEOUT_ERROR
      )
    }

    return false
  }

  /**
   * 处理错误
   * @param error 原始错误
   * @param url 请求URL
   * @param method 请求方法
   * @returns ApiError
   */
  handleError(error: Error, url?: string, method?: string): ApiError {
    // 如果已经是ApiError，直接返回
    if (error instanceof ApiError) {
      return error
    }

    // 处理Axios错误
    if (this.isAxiosError(error)) {
      const axiosError: AxiosError = error as AxiosError
      return this.handleAxiosError(axiosError, url, method)
    }

    // 其他未知错误
    return convertToApiError(error, url, method)
  }

  /**
   * 判断是否为Axios错误
   * @param error 错误对象
   * @returns 是否为Axios错误
   */
  private isAxiosError(error: Error): boolean {
    const axiosError: AxiosError = error as AxiosError
    return axiosError.isAxiosError === true
  }

  /**
   * 处理Axios错误
   * @param error Axios错误
   * @param url 请求URL
   * @param method 请求方法
   * @returns ApiError
   */
  private handleAxiosError(error: AxiosError, url?: string, method?: string): ApiError {
    const code: string = error.code ?? ''
    const axiosResponse: AxiosResponseLike | null = error.response as AxiosResponseLike | null
    const message: string = error.message ?? ''

    // 网络错误
    if (code === 'ERR_NETWORK' || !axiosResponse) {
      LogUtil.error('[ErrorHandler] 网络错误', message)
      return createNetworkError(
        message || '网络连接失败，请检查网络设置',
        { url, method, originalError: error }
      )
    }

    // 超时错误
    if (code === 'ECONNABORTED' || message.includes('timeout')) {
      LogUtil.error('[ErrorHandler] 请求超时', message)
      return createTimeoutError(
        message || '请求超时，请稍后重试',
        { url, method, originalError: error }
      )
    }

    // 有响应的错误
    if (axiosResponse) {
      const response: AxiosResponseLike = axiosResponse as AxiosResponseLike
      const status: number = response.status
      const statusText: string = response.statusText ?? ''
      const data: object | null | string | number | boolean = response.data

      // 401 未授权
      if (status === 401) {
        LogUtil.error('[ErrorHandler] 认证失败', statusText)
        return createAuthError('认证失败，请重新登录', { url, method })
      }

      // 403 禁止访问
      if (status === 403) {
        LogUtil.error('[ErrorHandler] 权限不足', statusText)
        return createAuthError('权限不足，无法访问', { url, method })
      }

      // 404 未找到
      if (status === 404) {
        LogUtil.error('[ErrorHandler] 资源未找到', statusText)
        return createClientError(404, '请求的资源不存在', { url, method })
      }

      // 4xx 客户端错误
      if (status >= 400 && status < 500) {
        LogUtil.error('[ErrorHandler] 客户端错误', `${status} - ${statusText}`)
        const clientMessage = this.extractErrorMessage(data) || statusText || '客户端请求错误'
        return createClientError(status, clientMessage, { url, method })
      }

      // 5xx 服务器错误
      if (status >= 500) {
        LogUtil.error('[ErrorHandler] 服务器错误', `${status} - ${statusText}`)
        const serverMessage = this.extractErrorMessage(data) || statusText || '服务器内部错误'
        return createServerError(status, serverMessage, { url, method })
      }
    }

    // 其他未知错误
    LogUtil.error('[ErrorHandler] 未知错误', message)
    return convertToApiError(error, url, method)
  }

  /**
   * 从响应数据中提取错误消息
   * @param data 响应数据
   * @returns 错误消息
   */
  private extractErrorMessage(data: object | string | number | boolean | null): string | null {
    if (!data || typeof data !== 'object') {
      return null
    }

    const responseData: ErrorResponseData = data as ErrorResponseData

    // 尝试多种可能的错误消息字段
    if (responseData.message && typeof responseData.message === 'string') {
      return responseData.message
    }
    if (responseData.msg && typeof responseData.msg === 'string') {
      return responseData.msg
    }
    if (responseData.error && typeof responseData.error === 'string') {
      return responseData.error
    }
    if (responseData.errorMessage && typeof responseData.errorMessage === 'string') {
      return responseData.errorMessage
    }
    if (responseData.error_message && typeof responseData.error_message === 'string') {
      return responseData.error_message
    }
    if (responseData.errorMsg && typeof responseData.errorMsg === 'string') {
      return responseData.errorMsg
    }
    if (responseData.error_msg && typeof responseData.error_msg === 'string') {
      return responseData.error_msg
    }

    return null
  }

  /**
   * 格式化错误信息用于显示
   * @param error ApiError对象
   * @returns 用户友好的错误消息
   */
  formatErrorMessage(error: ApiError): string {
    switch (error.type) {
      case ApiErrorType.NETWORK_ERROR:
        return '网络连接失败，请检查网络设置'

      case ApiErrorType.TIMEOUT_ERROR:
        return '请求超时，请稍后重试'

      case ApiErrorType.AUTH_ERROR:
        return '登录已过期，请重新登录'

      case ApiErrorType.CLIENT_ERROR:
        if (error.statusCode === 404) {
          return '请求的资源不存在'
        }
        return error.message || '请求失败'

      case ApiErrorType.SERVER_ERROR:
        return '服务器异常，请稍后重试'

      default:
        return error.message || '未知错误'
    }
  }
}
