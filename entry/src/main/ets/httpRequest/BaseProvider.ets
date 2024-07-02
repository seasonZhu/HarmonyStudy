import axios, { AxiosError, AxiosInstance, AxiosRequestConfig, AxiosResponse} from '@ohos/axios'
import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './Interceptors/AxiosClientRequestInterceptor';
import { AxiosClientResponseInterceptor } from './Interceptors/AxiosClientResponseInterceptor';
import { ConfigurationAxiosClient } from './Configuration/ConfigurationAxiosClient'
import { BaseResponse } from '../model/BaseResponse';

export abstract class BaseProvider {

  // 请求库实例
  readonly instance: AxiosInstance

  constructor() {

    //配置基本信息
    this.instance = axios.create(this.configurationAxios())

    // 配置请求拦截器
    this.configurationRequestInterceptor().forEach((interceptor: AxiosClientRequestInterceptor) => {
      this.instance.interceptors.request.use(interceptor.onFulfilled, interceptor.onRejected)
    })

    // 配置响应拦截器
    this.configurationResponseInterceptor().forEach((interceptor: AxiosClientResponseInterceptor) => {
      this.instance.interceptors.response.use(interceptor.onFulfilled, interceptor.onRejected)
    })

  }

  /**
   * 配置Axios基本信息
   *
   * @returns ConfigurationAxiosClient
   */
  abstract configurationAxios(): ConfigurationAxiosClient

  /**
   * 配置请求拦截器
   *
   * @returns List<AxiosClientRequestInterceptor>
   */
  abstract configurationRequestInterceptor(): List<AxiosClientRequestInterceptor>

  /**
   * 配置响应拦截器
   *
   * @returns List<AxiosClientResponseInterceptor>
   */
  abstract configurationResponseInterceptor(): List<AxiosClientResponseInterceptor>

  /**
   * 封装get请求
   *
   * @param path
   * @param config
   * @returns
   */
  protected get<T>(path: string, config?: AxiosRequestConfig): Promise<AxiosResponse<BaseResponse<T>, AxiosError>> {
    return this.instance.get<BaseResponse<T>>(path, config)
  }

  /**
   * 封装post请求
   *
   * @param path
   * @param data
   * @param config
   * @returns
   */
  protected post<T>(path: string, data?: object, config?: AxiosRequestConfig): Promise<AxiosResponse<BaseResponse<T>, AxiosError>> {
    return this.instance.post<BaseResponse<T>>(path, data, config)
  }
}




