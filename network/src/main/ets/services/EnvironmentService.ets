import preferences from '@ohos.data.preferences'
import { Context } from '@kit.AbilityKit'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 环境类型枚举
 */
export enum Environment {
  /**
   * 开发环境
   */
  DEV = 'DEV',

  /**
   * 测试环境
   */
  TEST = 'TEST',

  /**
   * 预发布环境
   */
  STAGING = 'STAGING',

  /**
   * 生产环境
   */
  PROD = 'PROD'
}

/**
 * 环境配置接口
 */
export interface EnvironmentConfig {
  /**
   * 环境名称
   */
  name: string

  /**
   * 环境描述
   */
  description: string

  /**
   * API基础URL
   */
  baseURL: string

  /**
   * 超时时间（毫秒）
   */
  timeout: number

  /**
   * 是否启用日志
   */
  enableLog: boolean

  /**
   * 是否启用调试模式
   */
  debugMode: boolean
}

/**
 * 环境配置映射表
 */
export const environmentConfigs: Record<Environment, EnvironmentConfig> = {
  [Environment.DEV]: {
    name: '开发环境',
    description: '开发环境 - 用于日常开发调试',
    baseURL: 'https://dev-api.example.com',
    timeout: 30000,
    enableLog: true,
    debugMode: true
  },

  [Environment.TEST]: {
    name: '测试环境',
    description: '测试环境 - 用于功能测试验证',
    baseURL: 'https://test-api.example.com',
    timeout: 15000,
    enableLog: true,
    debugMode: true
  },

  [Environment.STAGING]: {
    name: '预发布环境',
    description: '预发布环境 - 用于上线前验证',
    baseURL: 'https://staging-api.example.com',
    timeout: 15000,
    enableLog: true,
    debugMode: false
  },

  [Environment.PROD]: {
    name: '生产环境',
    description: '生产环境 - 正式对外发布环境',
    baseURL: 'https://api.example.com',
    timeout: 15000,
    enableLog: false,
    debugMode: false
  }
}

/**
 * 环境服务类
 * @description 管理应用运行环境，支持环境切换和配置持久化
 */
export class EnvironmentService {
  /**
   * 单例实例
   */
  private static instance: EnvironmentService

  /**
   * 存储名称
   */
  private readonly STORE_NAME = 'network_environment_store'

  /**
   * 环境键名
   */
  private readonly KEY_ENV = 'current_environment'

  /**
   * Preferences实例
   */
  private preferences: preferences.Preferences | null = null

  /**
   * 当前环境
   */
  private currentEnvironment: Environment = Environment.PROD

  /**
   * 私有构造函数
   */
  private constructor() {
    LogUtil.debug('[EnvironmentService] 创建环境服务实例')
  }

  /**
   * 获取单例实例
   * @returns EnvironmentService实例
   */
  static getInstance(): EnvironmentService {
    if (!EnvironmentService.instance) {
      EnvironmentService.instance = new EnvironmentService()
    }
    return EnvironmentService.instance
  }

  /**
   * 初始化环境服务
   * @param context 应用上下文
   */
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME)
      this.currentEnvironment = await this.loadEnvironment()
      LogUtil.info(`[EnvironmentService] 初始化完成，当前环境: ${this.currentEnvironment}`)
    } catch (error) {
      LogUtil.error('[EnvironmentService] 初始化失败', JSON.stringify(error))
      this.currentEnvironment = Environment.PROD
    }
  }

  /**
   * 从持久化存储加载环境
   * @returns 当前环境
   */
  private async loadEnvironment(): Promise<Environment> {
    if (!this.preferences) {
      return Environment.PROD
    }

    try {
      const envValue = await this.preferences.get(this.KEY_ENV, Environment.PROD)
      return envValue as Environment
    } catch (error) {
      LogUtil.error('[EnvironmentService] 加载环境配置失败', JSON.stringify(error))
      return Environment.PROD
    }
  }

  /**
   * 保存环境到持久化存储
   * @param env 环境类型
   */
  private async saveEnvironment(env: Environment): Promise<void> {
    if (!this.preferences) {
      LogUtil.warn('[EnvironmentService] Preferences未初始化，无法保存环境配置')
      return
    }

    try {
      await this.preferences.put(this.KEY_ENV, env)
      await this.preferences.flush()
      LogUtil.info(`[EnvironmentService] 环境已保存: ${env}`)
    } catch (error) {
      LogUtil.error('[EnvironmentService] 保存环境配置失败', JSON.stringify(error))
    }
  }

  /**
   * 获取当前环境
   * @returns 当前环境
   */
  getCurrentEnvironment(): Environment {
    return this.currentEnvironment
  }

  /**
   * 设置当前环境
   * @param env 环境类型
   */
  async setCurrentEnvironment(env: Environment): Promise<void> {
    if (this.currentEnvironment === env) {
      LogUtil.debug('[EnvironmentService] 环境未改变')
      return
    }

    this.currentEnvironment = env
    await this.saveEnvironment(env)
    LogUtil.info(`[EnvironmentService] 环境已切换至: ${env}`)
  }

  /**
   * 获取当前环境配置
   * @returns 环境配置
   */
  getCurrentConfig(): EnvironmentConfig {
    return environmentConfigs[this.currentEnvironment]
  }

  /**
   * 获取指定环境配置
   * @param env 环境类型
   * @returns 环境配置
   */
  getConfig(env: Environment): EnvironmentConfig {
    return environmentConfigs[env]
  }

  /**
   * 获取当前BaseURL
   * @returns BaseURL
   */
  getBaseURL(): string {
    return this.getCurrentConfig().baseURL
  }

  /**
   * 获取当前超时时间
   * @returns 超时时间（毫秒）
   */
  getTimeout(): number {
    return this.getCurrentConfig().timeout
  }

  /**
   * 是否启用日志
   * @returns 是否启用日志
   */
  isLogEnabled(): boolean {
    return this.getCurrentConfig().enableLog
  }

  /**
   * 是否调试模式
   * @returns 是否调试模式
   */
  isDebugMode(): boolean {
    return this.getCurrentConfig().debugMode
  }

  /**
   * 获取所有可用环境
   * @returns 环境列表
   */
  getAvailableEnvironments(): Environment[] {
    return Object.values(Environment)
  }

  /**
   * 获取环境的显示名称
   * @param env 环境类型
   * @returns 显示名称
   */
  getDisplayName(env: Environment): string {
    return this.getConfig(env).name
  }

  /**
   * 获取环境描述
   * @param env 环境类型
   * @returns 环境描述
   */
  getDescription(env: Environment): string {
    return this.getConfig(env).description
  }
}

/**
 * 导出环境服务单例
 */
export const environmentService = EnvironmentService.getInstance()
