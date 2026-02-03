import { AxiosRequestConfig, InternalAxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'

/**
 * Token拦截器配置
 */
export interface TokenInterceptorConfig {
  /**
   * 是否启用Token
   */
  enabled?: boolean

  /**
   * Token存储的键名
   */
  tokenKey?: string

  /**
   * Token header名称
   */
  headerName?: string

  /**
   * Token前缀
   */
  tokenPrefix?: string

  /**
   * 获取Token的函数
   * @returns Token字符串或Promise
   */
  getToken?: () => string | Promise<string>

  /**
   * Token刷新的函数
   * @param currentToken 当前Token
   * @returns 新Token或Promise
   */
  refreshToken?: (currentToken: string) => string | Promise<string>

  /**
   * Token失效的函数
   * @param error 错误对象
   */
  onTokenExpired?: (error: Error) => void

  /**
   * 是否自动刷新Token
   */
  autoRefresh?: boolean
}

/**
 * 默认Token配置
 */
const defaultTokenConfig: Required<Omit<TokenInterceptorConfig, 'getToken' | 'refreshToken' | 'onTokenExpired'>> = {
  enabled: true,
  tokenKey: 'authorization',
  headerName: 'Authorization',
  tokenPrefix: 'Bearer ',
  autoRefresh: true
}

/**
 * Token拦截器类
 * @description 自动在请求头中添加Token，并处理Token刷新
 */
export class TokenInterceptor {
  /**
   * Token配置
   */
  private config: Required<Omit<TokenInterceptorConfig, 'getToken' | 'refreshToken' | 'onTokenExpired'>> &
    {
      getToken: () => string | Promise<string>
      refreshToken?: (currentToken: string) => string | Promise<string>
      onTokenExpired?: (error: Error) => void
    }

  /**
   * 当前Token
   */
  private currentToken: string = ''

  /**
   * 是否正在刷新Token
   */
  private isRefreshing: boolean = false

  /**
   * 等待刷新的请求队列
   */
  private refreshQueue: Array<(token: string) => void> = []

  /**
   * 构造函数
   * @param config Token配置
   */
  constructor(config: TokenInterceptorConfig = {}) {
    this.config = {
      ...defaultTokenConfig,
      ...config,
      getToken: config.getToken || this.getDefaultToken.bind(this)
    }
    LogUtil.debug('[TokenInterceptor] 初始化完成')
  }

  /**
   * 获取默认Token（从Preferences或其他存储中获取）
   * @returns Token字符串
   */
  private getDefaultToken(): string {
    // 这里可以根据实际项目从存储中获取Token
    // 例如从preferences、AccountManager等
    return this.currentToken
  }

  /**
   * 更新配置
   * @param config 新配置
   */
  updateConfig(config: Partial<TokenInterceptorConfig>): void {
    this.config = { ...this.config, ...config }
    LogUtil.debug('[TokenInterceptor] 配置已更新')
  }

  /**
   * 设置当前Token
   * @param token Token字符串
   */
  setToken(token: string): void {
    this.currentToken = token
    LogUtil.debug('[TokenInterceptor] Token已更新')
  }

  /**
   * 获取当前Token
   * @returns Token字符串
   */
  async getToken(): Promise<string> {
    if (this.currentToken) {
      return this.currentToken
    }

    const token = await this.config.getToken()
    this.currentToken = token
    return token
  }

  /**
   * 清除Token
   */
  clearToken(): void {
    this.currentToken = ''
    LogUtil.debug('[TokenInterceptor] Token已清除')
  }

  /**
   * 请求拦截器
   * @param config 请求配置
   * @returns 处理后的请求配置
   */
  async request(config: InternalAxiosRequestConfig): Promise<InternalAxiosRequestConfig> {
    // 如果不启用Token，直接返回
    if (!this.config.enabled) {
      return config
    }

    try {
      // 获取Token
      const token = await this.getToken()

      if (token) {
        // 设置Token到请求头
        const headerValue = this.config.tokenPrefix + token
        config.headers.set(this.config.headerName, headerValue)

        LogUtil.debug(`[TokenInterceptor] Token已添加到请求头: ${config.url}`)
      }
    } catch (error) {
      LogUtil.error('[TokenInterceptor] 获取Token失败', JSON.stringify(error))
    }

    return config
  }

  /**
   * 刷新Token
   * @returns 新Token
   */
  private async refreshAccessToken(): Promise<string> {
    if (this.config.refreshToken) {
      const newToken = await this.config.refreshToken(this.currentToken)
      this.setToken(newToken)
      return newToken
    }

    throw new Error('Token刷新失败：未配置refreshToken函数')
  }

  /**
   * 处理Token刷新队列
   * @param token 新Token
   */
  private processRefreshQueue(token: string): void {
    this.refreshQueue.forEach(callback => callback(token))
    this.refreshQueue = []
  }

  /**
   * 添加到刷新队列
   * @returns Promise，当Token刷新完成后resolve
   */
  private addToRefreshQueue(): Promise<string> {
    return new Promise(resolve => {
      this.refreshQueue.push(resolve)
    })
  }

  /**
   * 检查Token是否过期
   * @param error 错误对象
   * @returns 是否Token过期
   */
  isTokenExpired(error: Error): boolean {
    const errorMessage = error.message.toLowerCase()
    return (
      errorMessage.includes('401') ||
      errorMessage.includes('unauthorized') ||
      errorMessage.includes('token') ||
      errorMessage.includes('expired')
    )
  }

  /**
   * 处理Token过期
   * @param error 错误对象
   * @returns 新Token或null
   */
  async handleTokenExpired(error: Error): Promise<string | null> {
    if (!this.config.autoRefresh) {
      // 调用Token过期回调
      if (this.config.onTokenExpired) {
        this.config.onTokenExpired(error)
      }
      return null
    }

    // 如果正在刷新，加入队列等待
    if (this.isRefreshing) {
      return this.addToRefreshQueue()
    }

    try {
      this.isRefreshing = true
      LogUtil.debug('[TokenInterceptor] 开始刷新Token')

      const newToken = await this.refreshAccessToken()

      // 处理队列中的请求
      this.processRefreshQueue(newToken)

      LogUtil.debug('[TokenInterceptor] Token刷新成功')
      return newToken
    } catch (refreshError) {
      // 刷新失败，清空队列
      this.refreshQueue = []
      LogUtil.error('[TokenInterceptor] Token刷新失败', JSON.stringify(refreshError))

      // 调用Token过期回调
      if (this.config.onTokenExpired) {
        this.config.onTokenExpired(error)
      }

      return null
    } finally {
      this.isRefreshing = false
    }
  }
}

/**
 * 创建Token拦截器实例
 * @param config Token配置
 * @returns TokenInterceptor实例
 */
export function createTokenInterceptor(config?: TokenInterceptorConfig): TokenInterceptor {
  return new TokenInterceptor(config)
}
