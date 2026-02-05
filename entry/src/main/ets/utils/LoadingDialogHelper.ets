import { XTPromptHUD } from '@jxt/xt_hud'
import { window } from '@kit.ArkUI'

/**
 * LoadingDialogHelper - 基于 @jxt/xt_hud 封装的加载对话框工具类
 *
 * 使用前必须在 EntryAbility.onWindowStageCreate 中调用 init() 进行全局初始化
 *
 * @example
 * ```typescript
 * // 在 EntryAbility.onWindowStageCreate 中初始化
 * windowStage.loadContent('pages/Index', (err) => {
 *   if (!err.code) {
 *     LoadingDialogHelper.init(windowStage)
 *   }
 * })
 *
 * // 在页面中使用
 * @Component
 * struct MyPage {
 *   async doSomething() {
 *     try {
 *       LoadingDialogHelper.show('加载中...')
 *       await someApi()
 *     } finally {
 *       LoadingDialogHelper.hide()
 *     }
 *   }
 *
 *   // 或使用 wrap 方法自动管理
 *   async doSomething() {
 *     await LoadingDialogHelper.wrap(someApi(), '加载中...')
 *   }
 * }
 * ```
 *
 * @author LoadingDialogHelper
 * @version 2.0.0
 */
export class LoadingDialogHelper {
  private static TAG = 'LoadingDialogHelper'
  private static initialized = false

  /**
   * 全局初始化 - 必须在 windowStage.loadContent 之后调用
   *
   * @param windowStage Window 实例
   */
  public static init(windowStage: window.WindowStage): void {
    const context = windowStage.getMainWindowSync().getUIContext()
    LoadingDialogHelper.initUIConfig(context)
    LoadingDialogHelper.initialized = true
  }

  /**
   * 初始化 UIContext 配置
   */
  private static initUIConfig(context: UIContext): void {
    const bgColor = '#CC000000'
    const fontSize = 16.0
    const radius = 8.0

    // 配置 Toast
    XTPromptHUD.globalConfigToast(context, (options) => {
      options.isQueueMode = true
      options.isModal = true
      options.closeOnPressBack = false
      options.closeOnClickOutside = false
      options.fontSize = fontSize
      options.font = { size: fontSize }
      options.borderRadius = radius
      options.backgroundColor = bgColor
      options.hidingDelay = 1500
      options.iconSize = { width: 30, height: 30 }
      options.textPadding = { top: 16, bottom: 16, left: 24, right: 24 }
    })

    // 配置 Loading
    XTPromptHUD.globalConfigLoading(context, (options) => {
      options.isModal = true
      options.closeOnPressBack = false
      options.closeOnClickOutside = false
      options.fontSize = fontSize
      options.font = { size: fontSize }
      options.borderRadius = radius
      options.backgroundColor = bgColor
      options.iconSize = { width: 50, height: 50 }
      options.iconMargin = { top: 16, bottom: 8, left: 24, right: 24 }
      options.textPadding = { top: 0, bottom: 16, left: 24, right: 24 }
    })

    // 配置 Progress
    XTPromptHUD.globalConfigProgress(context, (options) => {
      options.isModal = true
      options.closeOnPressBack = false
      options.closeOnClickOutside = false
      options.fontSize = fontSize
      options.font = { size: fontSize }
      options.borderRadius = radius
      options.backgroundColor = bgColor
      options.iconSize = { width: 50, height: 50 }
      options.iconMargin = { top: 24, bottom: 16, left: 36, right: 36 }
      options.textPadding = { top: 0, bottom: 16, left: 24, right: 24 }
      options.strokeWidth = 5
      options.progressFontSize = 5
      options.progressFont = { size: 12, weight: 600 }
      options.progressTextColor = Color.White
    })
  }

  /**
   * 显示加载对话框
   * @param text 提示文字，默认 '加载中...'
   */
  public static show(text: string = '加载中...'): void {
    LoadingDialogHelper.ensureInitialized()
    XTPromptHUD.showLoading(text, {
      iconMargin: text == ''
        ? { top: 24, bottom: 24, left: 36, right: 36 }
        : { top: 16, bottom: 8, left: 24, right: 24 }
    })
  }

  /**
   * 隐藏加载对话框
   */
  public static hide(): void {
    XTPromptHUD.hideAllLoading()
  }

  /**
   * 包装异步任务，自动显示/隐藏加载对话框
   * @param task 异步任务
   * @param text 加载提示文字
   * @returns 任务执行结果，失败时返回 null
   */
  public static async wrap<T>(task: Promise<T>, text: string = '加载中...'): Promise<T | null> {
    LoadingDialogHelper.show(text)
    try {
      return await task
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error)
      console.error(`${LoadingDialogHelper.TAG}: wrap error`, errorMsg)
      throw new Error(errorMsg)
    } finally {
      LoadingDialogHelper.hide()
    }
  }

  /**
   * 确保已初始化
   */
  private static ensureInitialized(): void {
    if (!LoadingDialogHelper.initialized) {
      console.warn(`${LoadingDialogHelper.TAG}: 未调用 init() 进行初始化，Loading 可能无法正常显示`)
    }
  }

  // ============ 兼容旧API的实例方法 ============
  // 为了保持向后兼容，保留实例方法（内部调用静态方法）

  private instanceText: string = '加载中...'

  constructor(defaultText: string = '加载中...') {
    this.instanceText = defaultText
    console.warn(`${LoadingDialogHelper.TAG}: 建议使用静态方法 LoadingDialogHelper.show()/hide()/wrap()`)
  }

  show(text?: string): void {
    LoadingDialogHelper.show(text ?? this.instanceText)
  }

  hide(): void {
    LoadingDialogHelper.hide()
  }

  async wrap<T>(task: Promise<T>, text?: string): Promise<T> {
    return LoadingDialogHelper.wrap(task, text ?? this.instanceText) as Promise<T>
  }

  destroy(): void {
    // 静态方法无需销毁
  }
}
