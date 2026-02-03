/**
 * HTTP请求配置模型
 * @description 定义HTTP请求的所有配置选项
 */

/**
 * 请求方法枚举
 */
export enum RequestMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE',
  PATCH = 'PATCH',
  HEAD = 'HEAD',
  OPTIONS = 'OPTIONS'
}

/**
 * 请求头类型
 */
export type HttpHeaders = Record<string, string>

/**
 * 请求参数类型
 */
export type HttpParams = Record<string, string | number | boolean | undefined | null>

/**
 * 请求体类型
 */
export type HttpBody = object | string | ArrayBuffer | undefined

/**
 * HTTP请求配置
 */
export interface HttpConfig {
  /**
   * 请求URL（完整URL或相对路径）
   */
  url: string

  /**
   * 请求方法
   */
  method?: RequestMethod

  /**
   * 请求基础URL
   */
  baseURL?: string

  /**
   * 请求头
   */
  headers?: HttpHeaders

  /**
   * URL查询参数
   */
  params?: HttpParams

  /**
   * 请求体数据
   */
  data?: HttpBody

  /**
   * 超时时间（毫秒）
   */
  timeout?: number

  /**
   * 是否显示加载提示
   */
  showLoading?: boolean

  /**
   * 加载提示文本
   */
  loadingText?: string

  /**
   * 是否重试
   */
  enableRetry?: boolean

  /**
   * 最大重试次数
   */
  maxRetryCount?: number

  /**
   * 重试延迟时间（毫秒）
   */
  retryDelay?: number

  /**
   * 是否需要认证
   */
  requireAuth?: boolean

  /**
   * 是否记录日志
   */
  enableLog?: boolean

  /**
   * 请求标签（用于取消请求）
   */
  tag?: string

  /**
   * 响应类型
   */
  responseType?: 'json' | 'text' | 'arraybuffer' | 'blob'

  /**
   * 自配置
   */
  customConfig?: object
}

/**
 * HTTP客户端全局配置
 */
export interface HttpGlobalConfig {
  /**
   * 基础URL
   */
  baseURL: string

  /**
   * 默认超时时间（毫秒）
   */
  timeout: number

  /**
   * 默认请求头
   */
  headers: HttpHeaders

  /**
   * 是否启用日志
   */
  enableLog: boolean

  /**
   * 是否默认显示加载提示
   */
  showLoading: boolean

  /**
   * 默认加载提示文本
   */
  loadingText: string

  /**
   * 是否启用重试
   */
  enableRetry: boolean

  /**
   * 最大重试次数
   */
  maxRetryCount: number

  /**
   * 重试延迟时间（毫秒）
   */
  retryDelay: number

  /**
   * 是否需要认证
   */
  requireAuth: boolean
}

/**
 * 默认全局配置
 */
export const defaultGlobalConfig: HttpGlobalConfig = {
  baseURL: '',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  },
  enableLog: true,
  showLoading: false,
  loadingText: '加载中...',
  enableRetry: true,
  maxRetryCount: 3,
  retryDelay: 1000,
  requireAuth: false
}

/**
 * 创建HTTP请求配置
 * @param config 部分配置
 * @returns 完整的HTTP配置
 */
export function createHttpConfig(config: Partial<HttpConfig>): HttpConfig {
  return {
    url: config.url || '',
    method: config.method || RequestMethod.GET,
    baseURL: config.baseURL,
    headers: config.headers,
    params: config.params,
    data: config.data,
    timeout: config.timeout,
    showLoading: config.showLoading,
    loadingText: config.loadingText,
    enableRetry: config.enableRetry,
    maxRetryCount: config.maxRetryCount,
    retryDelay: config.retryDelay,
    requireAuth: config.requireAuth,
    enableLog: config.enableLog,
    tag: config.tag,
    responseType: config.responseType || 'json',
    customConfig: config.customConfig
  }
}

/**
 * 合并配置
 * @param globalConfig 全局配置
 * @param requestConfig 请求配置
 * @returns 合并后的配置
 */
export function mergeConfig(
  globalConfig: HttpGlobalConfig,
  requestConfig: HttpConfig
): HttpConfig {
  // 手动合并headers - 不使用for..in
  const mergedHeaders: HttpHeaders = {}
  const globalKeys = Object.keys(globalConfig.headers) as string[]
  for (let i = 0; i < globalKeys.length; i++) {
    const key = globalKeys[i]
    mergedHeaders[key] = globalConfig.headers[key]
  }
  if (requestConfig.headers) {
    const localKeys = Object.keys(requestConfig.headers) as string[]
    for (let i = 0; i < localKeys.length; i++) {
      const key = localKeys[i]
      mergedHeaders[key] = requestConfig.headers[key]
    }
  }

  const result: HttpConfig = {
    url: requestConfig.url,
    method: requestConfig.method,
    baseURL: requestConfig.baseURL || globalConfig.baseURL,
    headers: mergedHeaders,
    params: requestConfig.params,
    data: requestConfig.data,
    timeout: requestConfig.timeout ?? globalConfig.timeout,
    showLoading: requestConfig.showLoading ?? globalConfig.showLoading,
    loadingText: requestConfig.loadingText || globalConfig.loadingText,
    enableRetry: requestConfig.enableRetry ?? globalConfig.enableRetry,
    maxRetryCount: requestConfig.maxRetryCount ?? globalConfig.maxRetryCount,
    retryDelay: requestConfig.retryDelay ?? globalConfig.retryDelay,
    requireAuth: requestConfig.requireAuth ?? globalConfig.requireAuth,
    enableLog: requestConfig.enableLog ?? globalConfig.enableLog,
    tag: requestConfig.tag,
    responseType: requestConfig.responseType,
    customConfig: requestConfig.customConfig
  }
  return result
}
