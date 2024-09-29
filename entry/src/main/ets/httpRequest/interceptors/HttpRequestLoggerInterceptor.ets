import { InternalAxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils';
import { AxiosClientRequestInterceptor } from './AxiosClientRequestInterceptor'

export class HttpRequestLoggerInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    LogUtil.debug("<--- http request " + config.baseURL + config.url + "   " + config.method + ' --->')
    LogUtil.debug("http request config: " + JSON.stringify(config))
    LogUtil.debug("<--------------------------------------------------------------------->")
    return config
  }
}