/**
 * API错误类型枚举
 * @description 定义所有可能的API错误类型
 */
export enum ApiErrorType {
  /**
   * 网络错误
   */
  NETWORK_ERROR = 'NETWORK_ERROR',

  /**
   * 超时错误
   */
  TIMEOUT_ERROR = 'TIMEOUT_ERROR',

  /**
   * 服务器错误
   */
  SERVER_ERROR = 'SERVER_ERROR',

  /**
   * 客户端错误
   */
  CLIENT_ERROR = 'CLIENT_ERROR',

  /**
   * 认证错误
   */
  AUTH_ERROR = 'AUTH_ERROR',

  /**
   * 解析错误
   */
  PARSE_ERROR = 'PARSE_ERROR',

  /**
   * 取消请求
   */
  CANCEL_ERROR = 'CANCEL_ERROR',

  /**
   * 未知错误
   */
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

/**
 * API错误类
 * @description 自定义错误类，包含详细的错误信息
 */
export class ApiError extends Error {
  /**
   * 错误类型
   */
  readonly type: ApiErrorType

  /**
   * HTTP状态码
   */
  readonly statusCode?: number

  /**
   * 业务错误码
   */
  readonly businessCode?: number

  /**
   * 错误详情
   */
  readonly details?: Record<string, unknown>

  /**
   * 原始错误对象
   */
  readonly originalError?: Error

  /**
   * 请求URL
   */
  readonly url?: string

  /**
   * 请求方法
   */
  readonly method?: string

  /**
   * 构造函数
   * @param message 错误消息
   * @param type 错误类型
   * @param options 其他可选参数
   */
  constructor(
    message: string,
    type: ApiErrorType,
    options?: {
      statusCode?: number
      businessCode?: number
      details?: Record<string, unknown>
      originalError?: Error
      url?: string
      method?: string
    }
  ) {
    super(message)
    this.name = 'ApiError'
    this.type = type
    this.statusCode = options?.statusCode
    this.businessCode = options?.businessCode
    this.details = options?.details
    this.originalError = options?.originalError
    this.url = options?.url
    this.method = options?.method
  }

  /**
   * 转换为JSON对象
   */
  toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      message: this.message,
      type: this.type,
      statusCode: this.statusCode,
      businessCode: this.businessCode,
      details: this.details,
      url: this.url,
      method: this.method
    }
  }

  /**
   * 转换为可读的错误消息
   */
  toReadableMessage(): string {
    const parts: string[] = []

    if (this.method && this.url) {
      parts.push(`${this.method} ${this.url}`)
    }

    if (this.statusCode) {
      parts.push(`状态码: ${this.statusCode}`)
    }

    parts.push(this.message)

    return parts.join(' | ')
  }
}

/**
 * 创建网络错误
 */
export function createNetworkError(
  message: string = '网络连接失败',
  options?: { url?: string; method?: string; originalError?: Error }
): ApiError {
  return new ApiError(message, ApiErrorType.NETWORK_ERROR, options)
}

/**
 * 创建超时错误
 */
export function createTimeoutError(
  message: string = '请求超时',
  options?: { url?: string; method?: string; originalError?: Error }
): ApiError {
  return new ApiError(message, ApiErrorType.TIMEOUT_ERROR, options)
}

/**
 * 创建服务器错误
 */
export function createServerError(
  statusCode: number,
  message: string = '服务器错误',
  options?: { url?: string; method?: string }
): ApiError {
  return new ApiError(message, ApiErrorType.SERVER_ERROR, { statusCode, ...options })
}

/**
 * 创建客户端错误
 */
export function createClientError(
  statusCode: number,
  message: string = '客户端错误',
  options?: { url?: string; method?: string }
): ApiError {
  return new ApiError(message, ApiErrorType.CLIENT_ERROR, { statusCode, ...options })
}

/**
 * 创建认证错误
 */
export function createAuthError(
  message: string = '认证失败',
  options?: { url?: string; method?: string }
): ApiError {
  return new ApiError(message, ApiErrorType.AUTH_ERROR, { statusCode: 401, ...options })
}

/**
 * 创建业务错误
 */
export function createBusinessError(
  businessCode: number,
  message: string,
  options?: { url?: string; method?: string }
): ApiError {
  return new ApiError(message, ApiErrorType.SERVER_ERROR, { businessCode, ...options })
}

/**
 * 从标准Error对象转换为ApiError
 */
export function convertToApiError(error: Error, url?: string, method?: string): ApiError {
  if (error instanceof ApiError) {
    return error
  }

  return new ApiError(
    error.message || '未知错误',
    ApiErrorType.UNKNOWN_ERROR,
    { url, method, originalError: error }
  )
}
