import axios, { AxiosError, AxiosInstance, AxiosRequestConfig, AxiosResponse} from '@ohos/axios'
import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './interceptors/AxiosClientRequestInterceptor';
import { AxiosClientResponseInterceptor } from './interceptors/AxiosClientResponseInterceptor';
import { ConfigurationAxiosClient } from './configuration/ConfigurationAxiosClient'
import { BaseResponse } from '../model/BaseResponse';
import { ErrorHandler } from '../utils/ErrorHandler';
import { LogUtil } from '@pura/harmony-utils';

export abstract class BaseProvider {

  // 请求库实例
  readonly instance: AxiosInstance

  constructor() {

    //配置基本信息
    this.instance = axios.create(this.configurationAxios())

    // 配置请求拦截器
    try {
      this.configurationRequestInterceptor().forEach((interceptor: AxiosClientRequestInterceptor) => {
        this.instance.interceptors.request.use(interceptor.onFulfilled, interceptor.onRejected)
      })
    } catch (error) {
      ErrorHandler.handle(error, '请求拦截器配置失败')
    }

    // 配置响应拦截器
    try {
      this.configurationResponseInterceptor().forEach((interceptor: AxiosClientResponseInterceptor) => {
        this.instance.interceptors.response.use(interceptor.onFulfilled, interceptor.onRejected)
      })
    } catch (error) {
      ErrorHandler.handle(error, '响应拦截器配置失败')
    }

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
    /// 如果需要修改请求的配置，在这里进行修改会比较好，另外，我目前这个架构切换baseUrl的环境，也只能在这里进行操作
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




