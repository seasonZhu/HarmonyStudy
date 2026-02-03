/**
 * 错误详情类
 */
export class ErrorDetails {
  private data: Map<string, string | number | boolean | null | undefined> = new Map()

  set(key: string, value: string | number | boolean | null | undefined): void {
    this.data.set(key, value)
  }

  get(key: string): string | number | boolean | null | undefined {
    return this.data.get(key)
  }

  has(key: string): boolean {
    return this.data.has(key)
  }

  keys(): string[] {
    return Array.from(this.data.keys())
  }

  clear(): void {
    this.data.clear()
  }

  get size(): number {
    return this.data.size
  }
}

/**
 * ApiError构造函数选项接口
 */
export interface ApiErrorOptions {
  statusCode?: number
  businessCode?: number
  details?: ErrorDetails
  originalError?: Error
  url?: string
  method?: string
}

/**
 * ApiError JSON序列化接口
 */
export interface ApiErrorJson {
  name: string
  message: string
  type: ApiErrorType
  statusCode?: number
  businessCode?: number
  details?: ErrorDetails
  url?: string
  method?: string
}

/**
 * 网络错误选项
 */
export interface NetworkErrorOptions {
  url?: string
  method?: string
  originalError?: Error
}

/**
 * 服务器错误选项
 */
export interface ServerErrorOptions {
  url?: string
  method?: string
}

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
  readonly details?: ErrorDetails

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
    options?: ApiErrorOptions
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
  toJSON(): ApiErrorJson {
    const result: ApiErrorJson = {
      name: this.name,
      message: this.message,
      type: this.type,
      statusCode: this.statusCode,
      businessCode: this.businessCode,
      url: this.url,
      method: this.method
    }
    if (this.details) {
      result.details = this.details
    }
    return result
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
  options?: NetworkErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    url: options?.url,
    method: options?.method,
    originalError: options?.originalError
  }
  return new ApiError(message, ApiErrorType.NETWORK_ERROR, errorOptions)
}

/**
 * 创建超时错误
 */
export function createTimeoutError(
  message: string = '请求超时',
  options?: NetworkErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    url: options?.url,
    method: options?.method,
    originalError: options?.originalError
  }
  return new ApiError(message, ApiErrorType.TIMEOUT_ERROR, errorOptions)
}

/**
 * 创建服务器错误
 */
export function createServerError(
  statusCode: number,
  message: string = '服务器错误',
  options?: ServerErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    statusCode: statusCode
  }
  if (options) {
    errorOptions.url = options.url
    errorOptions.method = options.method
  }
  return new ApiError(message, ApiErrorType.SERVER_ERROR, errorOptions)
}

/**
 * 创建客户端错误
 */
export function createClientError(
  statusCode: number,
  message: string = '客户端错误',
  options?: ServerErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    statusCode: statusCode
  }
  if (options) {
    errorOptions.url = options.url
    errorOptions.method = options.method
  }
  return new ApiError(message, ApiErrorType.CLIENT_ERROR, errorOptions)
}

/**
 * 创建认证错误
 */
export function createAuthError(
  message: string = '认证失败',
  options?: ServerErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    statusCode: 401
  }
  if (options) {
    errorOptions.url = options.url
    errorOptions.method = options.method
  }
  return new ApiError(message, ApiErrorType.AUTH_ERROR, errorOptions)
}

/**
 * 创建业务错误
 */
export function createBusinessError(
  businessCode: number,
  message: string,
  options?: ServerErrorOptions
): ApiError {
  const errorOptions: ApiErrorOptions = {
    businessCode: businessCode
  }
  if (options) {
    errorOptions.url = options.url
    errorOptions.method = options.method
  }
  return new ApiError(message, ApiErrorType.SERVER_ERROR, errorOptions)
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
