import { getHttpClient, HttpClient, ApiError } from 'network'
import { LogUtil } from '@pura/harmony-utils'

/**
 * Repository 基类
 * @description 提供统一的 HTTP 客户端和错误处理
 */
export abstract class BaseRepository {
  protected httpClient: HttpClient
  
  constructor() {
    this.httpClient = getHttpClient()
  }
  
  /**
   * 统一错误处理
   * @param error API 错误
   */
  protected handleError(error: ApiError): void {
    LogUtil.error(`API Error: ${error.message}`)
    // 错误已在 network 模块中统一处理，这里只记录日志
  }
}
