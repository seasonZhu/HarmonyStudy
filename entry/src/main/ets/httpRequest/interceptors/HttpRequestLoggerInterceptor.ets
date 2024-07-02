import { InternalAxiosRequestConfig } from '@ohos/axios'
import { AxiosClientRequestInterceptor } from './AxiosClientRequestInterceptor'

export class HttpRequestLoggerInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    console.log("<--- http request " + config.baseURL + config.url + "   " + config.method + ' --->')
    console.log("http request config: " + JSON.stringify(config))
    console.log("<--------------------------------------------------------------------->")
    return config
  }
}