/**
 * Network - 统一网络请求模块
 * @description 提供完整的HTTP请求功能，包括拦截器、错误处理、环境管理等
 *
 * @module Network
 */

import { HttpClient } from './core/HttpClient'
import { environmentService } from './services/EnvironmentService'
import { loadingService } from './services/LoadingService'
import { createLoggingInterceptor } from './interceptors/LoggingInterceptor'
import { createTokenInterceptor } from './interceptors/TokenInterceptor'
import { createRetryInterceptor } from './interceptors/RetryInterceptor'

// ============ Models ============
export { ApiResponse, createSuccessResponse, createErrorResponse, isSuccess, extractData } from './models/ApiResponse'
export type { ApiResponse as ApiResponseType } from './models/ApiResponse'

export {
  ApiError,
  ApiErrorType,
  createNetworkError,
  createTimeoutError,
  createServerError,
  createClientError,
  createAuthError,
  createBusinessError,
  convertToApiError
} from './models/ApiError'

export {
  HttpConfig,
  HttpGlobalConfig,
  RequestMethod,
  HttpHeaders,
  HttpParams,
  HttpBody,
  defaultGlobalConfig,
  createHttpConfig,
  mergeConfig
} from './models/HttpConfig'

// ============ Core ============
export { HttpClient } from './core/HttpClient'
export { InterceptorManager } from './core/InterceptorManager'
export { ErrorHandler } from './core/ErrorHandler'

// ============ Interceptors ============
export {
  RetryInterceptor,
  RetryInterceptorConfig,
  createRetryInterceptor
} from './interceptors/RetryInterceptor'

export {
  TokenInterceptor,
  TokenInterceptorConfig,
  createTokenInterceptor
} from './interceptors/TokenInterceptor'

export {
  LoggingInterceptor,
  LogLevel,
  LoggingInterceptorConfig,
  createLoggingInterceptor
} from './interceptors/LoggingInterceptor'

// ============ Services ============
export {
  EnvironmentService,
  Environment,
  EnvironmentConfig,
  environmentConfigs,
  environmentService
} from './services/EnvironmentService'

export {
  LoadingService,
  LoadingConfig,
  loadingService,
  showLoading,
  hideLoading,
  forceHideLoading
} from './services/LoadingService'

// ============ 默认导出 ============

/**
 * 创建默认的HTTP客户端实例
 * @description 使用环境服务和默认配置创建HTTP客户端
 * @returns HttpClient实例
 */
export function createDefaultHttpClient(): HttpClient {
  const envConfig = environmentService.getCurrentConfig()

  const client = new HttpClient({
    baseURL: envConfig.baseURL,
    timeout: envConfig.timeout,
    enableLog: envConfig.enableLog
  })

  // 添加日志拦截器
  const loggingInterceptor = createLoggingInterceptor({
    enabled: envConfig.enableLog
  })
  client.getAxiosInstance().interceptors.request.use(
    loggingInterceptor.request.bind(loggingInterceptor)
  )
  client.getAxiosInstance().interceptors.response.use(
    loggingInterceptor.response.bind(loggingInterceptor),
    loggingInterceptor.responseError.bind(loggingInterceptor)
  )

  return client
}

/**
 * 默认HTTP客户端实例
 * @description 单例模式，全局共享
 */
let defaultHttpClient: HttpClient | null = null

/**
 * 获取默认HTTP客户端实例
 * @returns HttpClient实例
 */
export function getHttpClient(): HttpClient {
  if (!defaultHttpClient) {
    defaultHttpClient = createDefaultHttpClient()
  }
  return defaultHttpClient
}

/**
 * 重置默认HTTP客户端实例
 * @description 在切换环境时调用
 */
export function resetHttpClient(): void {
  defaultHttpClient = null
}
