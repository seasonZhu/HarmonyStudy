import { LogUtil } from '@pura/harmony-utils'

/**
 * 加载提示配置
 */
export interface LoadingConfig {
  /**
   * 加载文本
   */
  text?: string

  /**
   * 是否允许点击遮罩层关闭
   */
  autoCancel?: boolean

  /**
   * 遮罩层透明度
   */
  maskColor?: ResourceColor

  /**
   * 自定义样式
   */
  customStyle?: boolean
}

/**
 * 默认加载配置
 */
const defaultLoadingConfig: LoadingConfig = {
  text: '加载中...',
  autoCancel: false,
  maskColor: 'rgba(0, 0, 0, 0.6)',
  customStyle: false
}

/**
 * 加载服务类
 * @description 管理全局加载提示框
 */
export class LoadingService {
  /**
   * 单例实例
   */
  private static instance: LoadingService

  /**
   * 当前加载计数
   */
  private loadingCount: number = 0

  /**
   * 当前加载文本
   */
  private currentText: string = ''

  /**
   * CustomDialogController实例
   * 由外部注入
   */
  private dialogController: CustomDialogController | null = null

  /**
   * 私有构造函数
   */
  private constructor() {
    LogUtil.debug('[LoadingService] 创建加载服务实例')
  }

  /**
   * 获取单例实例
   * @returns LoadingService实例
   */
  static getInstance(): LoadingService {
    if (!LoadingService.instance) {
      LoadingService.instance = new LoadingService()
    }
    return LoadingService.instance
  }

  /**
   * 设置对话框控制器
   * @param controller CustomDialogController实例
   */
  setDialogController(controller: CustomDialogController): void {
    this.dialogController = controller
    LogUtil.debug('[LoadingService] 对话框控制器已设置')
  }

  /**
   * 显示加载提示
   * @param config 加载配置
   */
  show(config?: LoadingConfig | string): void {
    const loadingConfig = this.parseConfig(config)

    // 更新加载计数
    this.loadingCount++
    this.currentText = loadingConfig.text || defaultLoadingConfig.text || '加载中...'

    // 如果已经有加载框在显示，只更新文本
    if (this.loadingCount > 1) {
      LogUtil.debug(`[LoadingService] 加载计数: ${this.loadingCount}, 文本: ${this.currentText}`)
      return
    }

    // 显示加载框
    try {
      if (this.dialogController) {
        this.dialogController.open()
        LogUtil.debug(`[LoadingService] 显示加载提示: ${this.currentText}`)
      } else {
        LogUtil.warn('[LoadingService] 对话框控制器未设置，无法显示加载提示')
      }
    } catch (error) {
      LogUtil.error('[LoadingService] 显示加载提示失败', JSON.stringify(error))
    }
  }

  /**
   * 隐藏加载提示
   */
  hide(): void {
    if (this.loadingCount <= 0) {
      LogUtil.debug('[LoadingService] 加载计数已为0，无需隐藏')
      return
    }

    // 减少加载计数
    this.loadingCount--

    // 如果还有其他请求在加载，不隐藏
    if (this.loadingCount > 0) {
      LogUtil.debug(`[LoadingService] 加载计数: ${this.loadingCount}, 继续显示`)
      return
    }

    // 隐藏加载框
    try {
      if (this.dialogController) {
        this.dialogController.close()
        LogUtil.debug('[LoadingService] 隐藏加载提示')
      }
    } catch (error) {
      LogUtil.error('[LoadingService] 隐藏加载提示失败', JSON.stringify(error))
    }

    // 重置状态
    this.loadingCount = 0
    this.currentText = ''
  }

  /**
   * 强制隐藏加载提示（忽略计数）
   */
  forceHide(): void {
    this.loadingCount = 0
    this.currentText = ''

    try {
      if (this.dialogController) {
        this.dialogController.close()
        LogUtil.debug('[LoadingService] 强制隐藏加载提示')
      }
    } catch (error) {
      LogUtil.error('[LoadingService] 强制隐藏加载提示失败', JSON.stringify(error))
    }
  }

  /**
   * 更新加载文本
   * @param text 新文本
   */
  updateText(text: string): void {
    this.currentText = text
    LogUtil.debug(`[LoadingService] 更新加载文本: ${text}`)
  }

  /**
   * 是否正在加载
   * @returns 是否正在加载
   */
  isLoading(): boolean {
    return this.loadingCount > 0
  }

  /**
   * 获取当前加载计数
   * @returns 加载计数
   */
  getLoadingCount(): number {
    return this.loadingCount
  }

  /**
   * 获取当前加载文本
   * @returns 加载文本
   */
  getCurrentText(): string {
    return this.currentText
  }

  /**
   * 解析加载配置
   * @param config 配置或字符串
   * @returns LoadingConfig对象
   */
  private parseConfig(config?: LoadingConfig | string): LoadingConfig {
    if (typeof config === 'string') {
      return { ...defaultLoadingConfig, text: config }
    }

    return { ...defaultLoadingConfig, ...config }
  }
}

/**
 * 导出加载服务单例
 */
export const loadingService = LoadingService.getInstance()

/**
 * 便捷方法：显示加载提示
 * @param config 加载配置或文本
 */
export function showLoading(config?: LoadingConfig | string): void {
  loadingService.show(config)
}

/**
 * 便捷方法：隐藏加载提示
 */
export function hideLoading(): void {
  loadingService.hide()
}

/**
 * 便捷方法：强制隐藏加载提示
 */
export function forceHideLoading(): void {
  loadingService.forceHide()
}
