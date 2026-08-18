/**
 * 统一API响应模型
 * @description 封装所有API请求的响应数据结构
 * @typeparam T 响应数据的类型
 */
export interface ApiResponse<T> {
  /**
   * 响应数据
   */
  data: T

  /**
   * 响应码
   * @description 0表示成功，其他值表示错误
   */
  errorCode: number

  /**
   * 响应消息
   * @description 成功时为成功消息，失败时为错误信息
   */
  errorMsg: string

  /**
   * 响应时间戳
   * @description 服务器返回的时间戳（可选）
   */
  timestamp?: number

  /**
   * 追踪ID
   * @description 用于日志追踪和问题排查（可选）
   */
  traceId?: string
}

/**
 * 创建成功的响应对象
 * @param data 响应数据
 * @param message 成功消息
 * @returns ApiResponse对象
 */
export function createSuccessResponse<T>(data: T, message: string = '操作成功'): ApiResponse<T> {
  return {
    data,
    errorCode: 0,
    errorMsg: message
  }
}

/**
 * 创建失败的响应对象
 * @param errorCode 错误码
 * @param errorMessage 错误消息
 * @returns ApiResponse对象
 */
export function createErrorResponse<T>(errorCode: number, errorMessage: string): ApiResponse<T> {
  return {
    data: null as T,
    errorCode,
    errorMsg: errorMessage
  }
}

/**
 * 判断响应是否成功
 * @param response API响应对象
 * @returns 是否成功
 */
export function isSuccess<T>(response: ApiResponse<T>): boolean {
  return response.errorCode === 0
}

/**
 * 从响应中提取数据
 * @param response API响应对象
 * @returns 响应数据
 * @throws 如果响应失败则抛出错误
 */
export function extractData<T>(response: ApiResponse<T>): T {
  if (!isSuccess(response)) {
    throw new Error(response.errorMsg || '请求失败')
  }
  return response.data
}
