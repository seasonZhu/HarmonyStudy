import { AxiosRequestConfig, AxiosResponse, AxiosError } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 日志级别
 */
export enum LogLevel {
  /**
   * 不记录日志
   */
  NONE = 'NONE',

  /**
   * 仅错误
   */
  ERROR = 'ERROR',

  /**
   * 警告及以上
   */
  WARN = 'WARN',

  /**
   * 信息及以上
   */
  INFO = 'INFO',

  /**
   * 调试（全部）
   */
  DEBUG = 'DEBUG'
}

/**
 * 日志拦截器配置
 */
export interface LoggingInterceptorConfig {
  /**
   * 是否启用日志
   */
  enabled?: boolean

  /**
   * 日志级别
   */
  logLevel?: LogLevel

  /**
   * 是否记录请求头
   */
  logHeaders?: boolean

  /**
   * 是否记录请求体
   */
  logBody?: boolean

  /**
   * 是否记录响应头
   */
  logResponseHeaders?: boolean

  /**
   * 是否记录响应体
   */
  logResponseBody?: boolean

  /**
   * 请求体最大日志长度（超过则截断）
   */
  maxBodyLength?: number

  /**
   * 是否格式化JSON输出
   */
  prettyPrint?: boolean

  /**
   * 自定义日志前缀
   */
  logPrefix?: string
}

/**
 * 日志条目接口
 */
export interface LogEntry {
  message: string
  timestamp?: number
}

/**
 * Headers接口
 */
export interface HttpHeadersLike {
  forEach(callback: (value: string, key: string) => void): void
}

/**
 * 完整日志拦截器配置
 */
export interface FullLoggingConfig {
  enabled: boolean
  logLevel: LogLevel
  logHeaders: boolean
  logBody: boolean
  logResponseHeaders: boolean
  logResponseBody: boolean
  maxBodyLength: number
  prettyPrint: boolean
  logPrefix: string
}

/**
 * 默认日志配置
 */
const defaultLoggingConfig: FullLoggingConfig = {
  enabled: true,
  logLevel: LogLevel.DEBUG,
  logHeaders: true,
  logBody: true,
  logResponseHeaders: false,
  logResponseBody: true,
  maxBodyLength: 1000,
  prettyPrint: true,
  logPrefix: '[HTTP]'
}

/**
 * 日志拦截器类
 * @description 记录所有HTTP请求和响应的详细信息
 */
export class LoggingInterceptor {
  /**
   * 日志配置
   */
  private config: FullLoggingConfig

  /**
   * 请求开始时间映射
   */
  private requestStartTimeMap: Map<string, number> = new Map()

  /**
   * 构造函数
   * @param config 日志配置
   */
  constructor(config: LoggingInterceptorConfig = {}) {
    this.config = {
      enabled: config.enabled !== undefined ? config.enabled : defaultLoggingConfig.enabled,
      logLevel: config.logLevel !== undefined ? config.logLevel : defaultLoggingConfig.logLevel,
      logHeaders: config.logHeaders !== undefined ? config.logHeaders : defaultLoggingConfig.logHeaders,
      logBody: config.logBody !== undefined ? config.logBody : defaultLoggingConfig.logBody,
      logResponseHeaders: config.logResponseHeaders !== undefined ? config.logResponseHeaders : defaultLoggingConfig.logResponseHeaders,
      logResponseBody: config.logResponseBody !== undefined ? config.logResponseBody : defaultLoggingConfig.logResponseBody,
      maxBodyLength: config.maxBodyLength !== undefined ? config.maxBodyLength : defaultLoggingConfig.maxBodyLength,
      prettyPrint: config.prettyPrint !== undefined ? config.prettyPrint : defaultLoggingConfig.prettyPrint,
      logPrefix: config.logPrefix !== undefined ? config.logPrefix : defaultLoggingConfig.logPrefix
    }
    LogUtil.debug('[LoggingInterceptor] 初始化完成')
  }

  /**
   * 更新配置
   * @param config 新配置
   */
  updateConfig(config: Partial<LoggingInterceptorConfig>): void {
    if (config.enabled !== undefined) this.config.enabled = config.enabled
    if (config.logLevel !== undefined) this.config.logLevel = config.logLevel
    if (config.logHeaders !== undefined) this.config.logHeaders = config.logHeaders
    if (config.logBody !== undefined) this.config.logBody = config.logBody
    if (config.logResponseHeaders !== undefined) this.config.logResponseHeaders = config.logResponseHeaders
    if (config.logResponseBody !== undefined) this.config.logResponseBody = config.logResponseBody
    if (config.maxBodyLength !== undefined) this.config.maxBodyLength = config.maxBodyLength
    if (config.prettyPrint !== undefined) this.config.prettyPrint = config.prettyPrint
    if (config.logPrefix !== undefined) this.config.logPrefix = config.logPrefix
    LogUtil.debug('[LoggingInterceptor] 配置已更新')
  }

  /**
   * 生成请求的唯一标识
   * @param config 请求配置
   * @returns 请求标识
   */
  private generateRequestId(config: AxiosRequestConfig): string {
    return `${config.method}:${config.url}:${Date.now()}`
  }

  /**
   * 格式化JSON
   * @param data 数据对象
   * @returns 格式化后的JSON字符串
   */
  private formatJson(data: object): string {
    try {
      const jsonString = JSON.stringify(data, null, this.config.prettyPrint ? 2 : 0)
      if (jsonString.length > this.config.maxBodyLength) {
        return jsonString.substring(0, this.config.maxBodyLength) + `... (truncated, total ${jsonString.length} chars)`
      }
      return jsonString
    } catch (error) {
      return '[无法序列化为JSON]'
    }
  }

  /**
   * 截断字符串
   * @param str 原始字符串
   * @returns 截断后的字符串
   */
  private truncateString(str: string): string {
    if (str.length > this.config.maxBodyLength) {
      return str.substring(0, this.config.maxBodyLength) + `... (truncated, total ${str.length} chars)`
    }
    return str
  }

  /**
   * 记录请求开始时间
   * @param config 请求配置
   */
  private recordStartTime(config: AxiosRequestConfig): void {
    const requestId = this.generateRequestId(config)
    this.requestStartTimeMap.set(requestId, Date.now())
  }

  /**
   * 计算请求耗时
   * @param config 请求配置
   * @returns 耗时（毫秒）
   */
  private calculateDuration(config: AxiosRequestConfig): number {
    const requestId = this.generateRequestId(config)
    const startTime = this.requestStartTimeMap.get(requestId)
    if (startTime) {
      this.requestStartTimeMap.delete(requestId)
      return Date.now() - startTime
    }
    return 0
  }

  /**
   * 格式化headers对象
   */
  private formatHeaders(headers: HttpHeadersLike | object): string {
    const result: string[] = []
    // 尝试使用forEach方法
    const headersLike = headers as HttpHeadersLike
    if (headersLike.forEach && typeof headersLike.forEach === 'function') {
      headersLike.forEach((value: string, key: string) => {
        result.push(`  ${key}: ${value}`)
      })
    } else if (headers) {
      // 如果没有forEach方法，使用Object.keys来遍历
      const keys = Object.keys(headers)
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i]
        // 使用动态访问来获取值
        const value: string | number | boolean | object | null | undefined = (headers as object)[key as string]
        result.push(`  ${key}: ${String(value)}`)
      }
    }
    return result.join('\n')
  }

  /**
   * 请求拦截器
   * @param config 请求配置
   * @returns 处理后的请求配置
   */
  request(config: AxiosRequestConfig): AxiosRequestConfig {
    if (!this.config.enabled || this.config.logLevel === LogLevel.NONE) {
      return config
    }

    this.recordStartTime(config)

    const logs: string[] = []

    // 基本信息
    logs.push(`${this.config.logPrefix} Request:`)
    logs.push(`  ${config.method?.toUpperCase()} ${config.url}`)

    // 查询参数
    if (config.params && Object.keys(config.params).length > 0) {
      logs.push(`  Params: ${this.formatJson(config.params)}`)
    }

    // 请求头
    if (this.config.logHeaders && config.headers) {
      logs.push(`  Headers: ${this.formatHeaders(config.headers)}`)
    }

    // 请求体
    if (this.config.logBody && config.data) {
      if (typeof config.data === 'string') {
        logs.push(`  Body: ${this.truncateString(config.data)}`)
      } else {
        logs.push(`  Body: ${this.formatJson(config.data as object)}`)
      }
    }

    // 根据日志级别输出
    if (this.config.logLevel === LogLevel.DEBUG) {
      LogUtil.debug(logs.join('\n'))
    } else if (this.config.logLevel === LogLevel.INFO) {
      LogUtil.info(`${config.method?.toUpperCase()} ${config.url}`)
    }

    return config
  }

  /**
   * 响应拦截器
   * @param response Axios响应
   * @returns 处理后的响应
   */
  response(response: AxiosResponse): AxiosResponse {
    if (!this.config.enabled || this.config.logLevel === LogLevel.NONE) {
      return response
    }

    const duration = this.calculateDuration(response.config)
    const logs: string[] = []

    // 基本信息
    logs.push(`${this.config.logPrefix} Response:`)
    logs.push(`  ${response.config.method?.toUpperCase()} ${response.config.url}`)
    logs.push(`  Status: ${response.status} ${response.statusText}`)
    logs.push(`  Duration: ${duration}ms`)

    // 响应头
    if (this.config.logResponseHeaders && response.headers) {
      logs.push(`  Headers: ${this.formatHeaders(response.headers)}`)
    }

    // 响应体
    if (this.config.logResponseBody && response.data) {
      logs.push(`  Body: ${this.formatJson(response.data)}`)
    }

    // 根据日志级别和状态码输出
    if (response.status >= 400) {
      LogUtil.error(logs.join('\n'))
    } else if (response.status >= 300 && this.config.logLevel === LogLevel.WARN) {
      LogUtil.warn(logs.join('\n'))
    } else if (this.config.logLevel === LogLevel.DEBUG) {
      LogUtil.debug(logs.join('\n'))
    } else if (this.config.logLevel === LogLevel.INFO) {
      LogUtil.info(`${response.config.method?.toUpperCase()} ${response.config.url} - ${response.status} (${duration}ms)`)
    }

    return response
  }

  /**
   * 响应错误拦截器
   * @param error Axios错误
   * @returns Promise
   */
  responseError(error: AxiosError): Promise<never> {
    if (!this.config.enabled || this.config.logLevel === LogLevel.NONE) {
      return Promise.reject(error)
    }

    const duration = this.calculateDuration(error.config as AxiosRequestConfig)
    const logs: string[] = []

    // 基本信息
    logs.push(`${this.config.logPrefix} Error:`)
    logs.push(`  ${error.config?.method?.toUpperCase()} ${error.config?.url}`)
    logs.push(`  Duration: ${duration}ms`)

    // 错误信息
    if (error.response) {
      logs.push(`  Status: ${error.response.status} ${error.response.statusText}`)
    } else if (error.code) {
      logs.push(`  Code: ${error.code}`)
    }

    logs.push(`  Message: ${error.message}`)

    // 响应数据
    if (error.response?.data) {
      const data = error.response.data
      if (typeof data === 'object') {
        logs.push(`  Response: ${this.formatJson(data as object)}`)
      } else {
        logs.push(`  Response: ${String(data)}`)
      }
    }

    LogUtil.error(logs.join('\n'))

    return Promise.reject(error)
  }
}

/**
 * 创建日志拦截器实例
 * @param config 日志配置
 * @returns LoggingInterceptor实例
 */
export function createLoggingInterceptor(config?: LoggingInterceptorConfig): LoggingInterceptor {
  return new LoggingInterceptor(config)
}
