import { AxiosRequestConfig, AxiosError } from '@ohos/axios'
import { HttpConfig } from '../models/HttpConfig'
import { ApiError, ApiErrorType } from '../models/ApiError'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 重试拦截器配置
 */
export interface RetryInterceptorConfig {
  /**
   * 是否启用重试
   */
  enabled?: boolean

  /**
   * 最大重试次数
   */
  maxRetryCount?: number

  /**
   * 重试延迟时间（毫秒）
   */
  retryDelay?: number

  /**
   * 是否使用指数退避策略
   */
  useExponentialBackoff?: boolean

  /**
   * 指数退避的基数（毫秒）
   */
  backoffBase?: number

  /**
   * 重试条件函数
   * @param error 错误对象
   * @returns 是否应该重试
   */
  shouldRetry?: (error: Error) => boolean
}

/**
 * 默认重试配置
 */
const defaultRetryConfig: Required<RetryInterceptorConfig> = {
  enabled: true,
  maxRetryCount: 3,
  retryDelay: 1000,
  useExponentialBackoff: true,
  backoffBase: 1000,
  shouldRetry: (error: Error) => {
    if (error instanceof ApiError) {
      return (
        error.type === ApiErrorType.NETWORK_ERROR ||
        error.type === ApiErrorType.TIMEOUT_ERROR
      )
    }
    return false
  }
}

/**
 * 重试拦截器类
 * @description 自动重试失败的请求
 */
export class RetryInterceptor {
  /**
   * 重试配置
   */
  private config: Required<RetryInterceptorConfig>

  /**
   * 当前重试计数映射
   */
  private retryCountMap: Map<string, number> = new Map()

  /**
   * 构造函数
   * @param config 重试配置
   */
  constructor(config: RetryInterceptorConfig = {}) {
    this.config = { ...defaultRetryConfig, ...config }
    LogUtil.debug('[RetryInterceptor] 初始化完成', JSON.stringify(this.config))
  }

  /**
   * 更新配置
   * @param config 新配置
   */
  updateConfig(config: Partial<RetryInterceptorConfig>): void {
    this.config = { ...this.config, ...config }
    LogUtil.debug('[RetryInterceptor] 配置已更新', JSON.stringify(this.config))
  }

  /**
   * 生成请求的唯一标识
   * @param config 请求配置
   * @returns 请求标识
   */
  private generateRequestIdentifier(config: AxiosRequestConfig): string {
    return `${config.method}:${config.url}:${JSON.stringify(config.params || {})}`
  }

  /**
   * 计算重试延迟时间
   * @param retryCount 当前重试次数
   * @returns 延迟时间（毫秒）
   */
  private calculateDelay(retryCount: number): number {
    if (this.config.useExponentialBackoff) {
      // 指数退避：base * 2^retryCount
      return this.config.backoffBase * Math.pow(2, retryCount)
    } else {
      // 固定延迟
      return this.config.retryDelay
    }
  }

  /**
   * 延迟函数
   * @param ms 延迟毫秒数
   * @returns Promise
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  /**
   * 重试请求
   * @param error 错误对象
   * @returns Promise
   */
  async retry(error: Error): Promise<void> {
    // 如果不启用重试，直接抛出错误
    if (!this.config.enabled) {
      throw error
    }

    // 检查是否应该重试
    if (!this.config.shouldRetry(error)) {
      throw error
    }

    // 获取请求标识
    const axiosError = error as AxiosError
    const config = axiosError.config as AxiosRequestConfig & { __retryCount?: number }
    const requestId = this.generateRequestIdentifier(config)

    // 获取当前重试次数
    const currentRetryCount = config.__retryCount || 0

    // 检查是否超过最大重试次数
    if (currentRetryCount >= this.config.maxRetryCount) {
      LogUtil.error(`[RetryInterceptor] 重试次数已达上限 (${this.config.maxRetryCount})`, requestId)
      throw error
    }

    // 增加重试计数
    config.__retryCount = currentRetryCount + 1
    this.retryCountMap.set(requestId, config.__retryCount)

    // 计算延迟时间
    const delayMs = this.calculateDelay(currentRetryCount)

    LogUtil.debug(
      `[RetryInterceptor] 准备重试 (${config.__retryCount}/${this.config.maxRetryCount})`,
      `延迟: ${delayMs}ms, 请求: ${requestId}`
    )

    // 延迟后重试
    await this.delay(delayMs)

    LogUtil.info(`[RetryInterceptor] 开始重试 (${config.__retryCount}/${this.config.maxRetryCount})`, requestId)
  }

  /**
   * 重置重试计数
   * @param requestId 请求标识
   */
  resetRetryCount(requestId?: string): void {
    if (requestId) {
      this.retryCountMap.delete(requestId)
    } else {
      this.retryCountMap.clear()
    }
  }

  /**
   * 获取当前重试统计
   */
  getStats(): {
    totalRetries: number
    retryingRequests: number
  } {
    let totalRetries = 0
    for (const count of this.retryCountMap.values()) {
      totalRetries += count
    }

    return {
      totalRetries,
      retryingRequests: this.retryCountMap.size
    }
  }
}

/**
 * 创建重试拦截器实例
 * @param config 重试配置
 * @returns RetryInterceptor实例
 */
export function createRetryInterceptor(config?: RetryInterceptorConfig): RetryInterceptor {
  return new RetryInterceptor(config)
}
