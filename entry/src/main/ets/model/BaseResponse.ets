export interface BaseResponse<T> {
  data: T
  errorCode: number
  errorMsg: string
}
