import { AxiosResponse } from '@ohos/axios'
import { AxiosClientResponseInterceptor } from './AxiosClientResponseInterceptor'
import { LogUtil } from '@pura/harmony-utils';

export class HttpResponseLoggerInterceptor implements AxiosClientResponseInterceptor {
  onFulfilled(response: AxiosResponse) {

    LogUtil.debug("<--- http response " + response.config.baseURL + response.config.url + "   " + response.status + " --->")
    LogUtil.debug("http response status: " + response.status)
    LogUtil.debug("http response headers: " + JSON.stringify(response.headers))
    LogUtil.debug("http response config: " + JSON.stringify(response.config))
    if (response.status === 200) {
      LogUtil.debug("http response data: " + JSON.stringify(response.data))
    } else {
      LogUtil.debug("http response service error: " + JSON.stringify(response.status + response.statusText))
    }
    LogUtil.debug("<--------------------------------------------------------------------->")
    return response
  }
}