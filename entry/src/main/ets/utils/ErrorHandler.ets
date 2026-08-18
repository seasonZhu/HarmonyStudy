import { LogUtil } from '@pura/harmony-utils'
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil'
import { AxiosError } from '@ohos/axios'

export enum ErrorType {
  NETWORK = 'NETWORK',
  SERVER = 'SERVER',
  CLIENT = 'CLIENT',
  AUTH = 'AUTH',
  UNKNOWN = 'UNKNOWN'
}

export interface AppError {
  type: ErrorType
  message: string
  code?: number | string
}

export class ErrorHandler {
  private static readonly TAG = 'ErrorHandler'

  static handle(error: Error, fallbackMessage: string = '操作失败，请稍后重试', showToast: boolean = true): AppError {
    let type = ErrorType.UNKNOWN
    let code: number | string | undefined = undefined

    if (error instanceof AxiosError) {
      if (!error.response) {
        type = ErrorType.NETWORK
      } else if (error.response.status === 401) {
        type = ErrorType.AUTH
        code = 401
      } else if (error.response.status >= 500) {
        type = ErrorType.SERVER
        code = error.response.status
      } else if (error.response.status >= 400) {
        type = ErrorType.CLIENT
        code = error.response.status
      }
    }

    const appError: AppError = {
      type: type,
      message: error.message || fallbackMessage,
      code: code
    }

    LogUtil.error(`${ErrorHandler.TAG}:[${appError.type}] ${appError.message}`)

    if (showToast) {
      ToastUtil.showToast(appError.message)
    }

    return appError
  }

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

  static isErrorType(error: AppError, type: ErrorType): boolean {
    return error.type === type
  }

  static isNetworkError(error: AppError): boolean {
    return ErrorHandler.isErrorType(error, ErrorType.NETWORK)
  }

  static isAuthError(error: AppError): boolean {
    return ErrorHandler.isErrorType(error, ErrorType.AUTH)
  }
}
