import { LogUtil } from '@pura/harmony-utils'
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'

/**
 * 错误类型枚举
 */
export enum ErrorType {
  /** 网络错误 */
  NETWORK = 'NETWORK',
  /** 服务器错误 */
  SERVER = 'SERVER',
  /** 客户端错误 */
  CLIENT = 'CLIENT',
  /** 未知错误 */
  UNKNOWN = 'UNKNOWN'
}

/**
 * 应用错误信息
 */
export interface AppError {
  type: ErrorType
  message: string
  code?: number | string
}

/**
 * 统一错误处理器
 *
 * @description
 * 提供统一的错误处理、日志记录和用户提示功能
 */
export class ErrorHandler {
  private static readonly TAG = 'ErrorHandler'

  /**
   * 处理错误并显示用户提示
   * @param error 错误对象
   * @param fallbackMessage 默认提示信息
   * @param showToast 是否显示 Toast 提示，默认 true
   * @returns 解析后的应用错误
   */
  static handle(error: Error, fallbackMessage: string = '操作失败，请稍后重试', showToast: boolean = true): AppError {
    const appError: AppError = {
      type: ErrorType.UNKNOWN,
      message: error.message || fallbackMessage
    }

    // 记录错误日志
    LogUtil.error(`${ErrorHandler.TAG}:[${appError.type}] ${appError.message}`)

    // 显示用户提示
    if (showToast) {
      ToastUtil.showToast(appError.message)
    }

    return appError
  }

  /**
   * 包装异步任务，自动处理错误
   * @param task 异步任务
   * @param fallbackMessage 默认错误提示
   * @returns 任务执行结果，失败时返回 null
   */
  static async wrap<T>(
    task: Promise<T>,
    fallbackMessage: string = '操作失败'
  ): Promise<T | null> {
    try {
      return await task
    } catch (error) {
      ErrorHandler.handle(error as Error, fallbackMessage)
      return null
    }
  }

  /**
   * 判断错误是否为特定类型
   */
  static isErrorType(error: AppError, type: ErrorType): boolean {
    return error.type === type
  }

  /**
   * 判断错误是否为网络错误
   */
  static isNetworkError(error: AppError): boolean {
    return ErrorHandler.isErrorType(error, ErrorType.NETWORK)
  }

  /**
   * 判断错误是否为认证错误 (401)
   */
  static isAuthError(error: AppError): boolean {
    return error.code === 401
  }
}
