import { AxiosError, InternalAxiosRequestConfig } from '@ohos/axios'
import { AxiosClientRequestInterceptor } from './AxiosClientRequestInterceptor'
import { AxiosClientResponseInterceptor } from './AxiosClientResponseInterceptor'
import { AxiosResponse } from '@ohos/axios'

export class LoadingOpenInterceptor implements AxiosClientRequestInterceptor {

  openCallback?: () => void

  constructor(openCallback?: () => void) {
    this.openCallback = openCallback
  }

  onFulfilled(config: InternalAxiosRequestConfig) {
    if (config.url == "banner/json") {
      if (this.openCallback) {
        this.openCallback()
      }
    }
    return config
  }
}

export class LoadingCloseInterceptor implements AxiosClientResponseInterceptor {
  closeCallback?: () => void

  constructor(closeCallback?: () => void) {
    this.closeCallback = closeCallback
  }

  onFulfilled(response: AxiosResponse) {
    if (this.closeCallback) {
      this.closeCallback()
    }
    return response
  }

  onRejected(error: AxiosError) {
    if (this.closeCallback) {
      this.closeCallback()
    }
    return error
  }
}