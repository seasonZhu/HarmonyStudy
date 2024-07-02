import { AxiosError, InternalAxiosRequestConfig } from '@ohos/axios';

export interface AxiosClientRequestInterceptor {
  onFulfilled?: (config: InternalAxiosRequestConfig) => InternalAxiosRequestConfig | Promise<InternalAxiosRequestConfig>
  onRejected?: (error: AxiosError) => Error
}