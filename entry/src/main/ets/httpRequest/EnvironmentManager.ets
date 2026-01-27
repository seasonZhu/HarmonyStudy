import preferences from '@ohos.data.preferences'
import { Environment } from './Environment'
import { Context } from '@kit.AbilityKit'

/**
 * 环境管理器 - 负责环境的持久化存储和获取
 */
export class EnvironmentManager {
  private static instance: EnvironmentManager
  private readonly STORE_NAME = 'environment_store'
  private readonly KEY_ENV = 'current_environment'
  private preferences: preferences.Preferences | null = null

  private constructor() {
  }

  static getInstance(): EnvironmentManager {
    if (!EnvironmentManager.instance) {
      EnvironmentManager.instance = new EnvironmentManager()
    }
    return EnvironmentManager.instance
  }

  /**
   * 初始化环境管理器
   */
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME)
    } catch (error) {
      console.error('EnvironmentManager: 初始化失败', JSON.stringify(error))
    }
  }

  /**
   * 获取当前环境
   */
  async getCurrentEnvironment(): Promise<Environment> {
    if (!this.preferences) {
      console.warn('EnvironmentManager: preferences未初始化，返回默认环境')
      return Environment.PROD
    }

    try {
      const envValue = await this.preferences.get(this.KEY_ENV, Environment.PROD)
      return envValue as Environment
    } catch (error) {
      console.error('EnvironmentManager: 获取环境失败', JSON.stringify(error))
      return Environment.PROD
    }
  }

  /**
   * 设置当前环境
   */
  async setCurrentEnvironment(env: Environment): Promise<void> {
    if (!this.preferences) {
      console.error('EnvironmentManager: preferences未初始化')
      return
    }

    try {
      await this.preferences.put(this.KEY_ENV, env)
      await this.preferences.flush()
      console.info('EnvironmentManager: 环境已切换为', env)
    } catch (error) {
      console.error('EnvironmentManager: 设置环境失败', JSON.stringify(error))
    }
  }

  /**
   * 获取环境的显示名称
   */
  getEnvironmentDisplayName(env: Environment): string {
    switch (env) {
      case Environment.DEV:
        return "开发环境 (DEV)"
      case Environment.TEST:
        return "测试环境 (TEST)"
      case Environment.PROD:
        return "生产环境 (PROD)"
      default:
        return "未知环境"
    }
  }

  /**
   * 获取环境的描述
   */
  getEnvironmentDescription(env: Environment): string {
    switch (env) {
      case Environment.DEV:
        return "开发环境 - 用于日常开发调试"
      case Environment.TEST:
        return "测试环境 - 用于功能测试验证"
      case Environment.PROD:
        return "生产环境 - 正式对外发布环境"
      default:
        return ""
    }
  }
}

export const environmentManager = EnvironmentManager.getInstance()
