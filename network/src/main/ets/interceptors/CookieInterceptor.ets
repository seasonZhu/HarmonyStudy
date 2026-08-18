import { AxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'

/**
 * Cookie 拦截器配置
 */
export interface CookieInterceptorConfig {
  /**
   * 是否启用
   */
  enabled?: boolean
}

/**
 * AccountManager 接口定义
 * @description 用于类型安全的跨模块访问
 */
interface IAccountManager {
  loginModel?: {
    username?: string
    password?: string
  }
}

/**
 * Cookie 拦截器
 * @description 自动添加登录 Cookie 到请求头
 */
export class CookieInterceptor {
  private config: CookieInterceptorConfig

  constructor(config: CookieInterceptorConfig = {}) {
    this.config = {
      enabled: config.enabled !== undefined ? config.enabled : true
    }
  }

  /**
   * 请求拦截
   */
  async request(config: AxiosRequestConfig): Promise<AxiosRequestConfig> {
    if (!this.config.enabled) {
      return config
    }

    // 获取 Cookie（从全局获取）
    const cookie = getCookieHeaderValue()
    
    if (cookie) {
      // 不使用 spread，直接设置
      if (!config.headers) {
        config.headers = {}
      }
      config.headers['Cookie'] = cookie
      LogUtil.debug(`[CookieInterceptor] 添加 Cookie: ${cookie}`)
    }

    return config
  }
}

/**
 * 获取 Cookie Header 值
 * @description 从 AccountManager 获取登录信息并构造 Cookie
 */
export function getCookieHeaderValue(): string {
  // 从全局获取 AccountManager（需要在 entry 模块中设置）
  const accountManager = globalThis.accountManager as IAccountManager
  if (!accountManager) {
    LogUtil.warn('[CookieInterceptor] AccountManager 未初始化')
    return ''
  }

  const loginModel = accountManager.loginModel
  if (!loginModel) {
    return ''
  }
  
  const username = loginModel.username ?? ''
  const password = loginModel.password ?? ''

  if (username.length === 0 && password.length === 0) {
    return ''
  }

  return `loginUserName=${username};loginUserPassword=${password}`
}

/**
 * 创建 Cookie 拦截器
 */
export function createCookieInterceptor(config: CookieInterceptorConfig = {}): CookieInterceptor {
  return new CookieInterceptor(config)
}
