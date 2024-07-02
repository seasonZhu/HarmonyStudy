import { AxiosResponse } from '@ohos/axios'
import { AxiosClientResponseInterceptor } from './AxiosClientResponseInterceptor'

export class HttpResponseLoggerInterceptor implements AxiosClientResponseInterceptor {
  onFulfilled(response: AxiosResponse) {

    console.log("<--- http response " + response.config.baseURL + response.config.url + "   " + response.status + " --->")
    console.log("http response status: " + response.status)
    console.log("http response headers: " + JSON.stringify(response.headers))
    console.log("http response config: " + JSON.stringify(response.config))
    if (response.status === 200) {
      console.log("http response data: " + JSON.stringify(response.data))
    } else {
      console.log("http response service error: " + JSON.stringify(response.status + response.statusText))
    }
    console.log("<--------------------------------------------------------------------->")
    return response
  }
}