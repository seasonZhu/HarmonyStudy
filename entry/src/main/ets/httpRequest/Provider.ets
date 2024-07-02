import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './Interceptors/AxiosClientRequestInterceptor';
import { AxiosClientResponseInterceptor } from './Interceptors/AxiosClientResponseInterceptor';
import { ConfigurationAxiosClient } from './Configuration/ConfigurationAxiosClient'
import { HttpRequestLoggerInterceptor } from './Interceptors/HttpRequestLoggerInterceptor'
import { HttpResponseLoggerInterceptor } from './Interceptors/HttpResponseLoggerInterceptor'
import { BaseProvider } from './BaseProvider';
import { SetCookieRequestInterceptor } from './Interceptors/SetCookieRequestInterceptor';
import { LoadingDialog } from './LoadingDialog';
import { LoadingOpenInterceptor, LoadingCloseInterceptor } from './Interceptors/LoadingInterceptor';
import { print } from '@kit.BasicServicesKit';

export class Provider extends BaseProvider {
  static readonly baseUrl = "https://www.wanandroid.com/"
  static readonly timeout = 5000

  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog(),
    // 点击遮障层退出时的回调
    cancel: () => {
    },
    //是否允许点击遮障层退出
    autoCancel: false,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    //弹窗宽度占栅格宽度的个数。默认为按照窗口大小自适应，异常值按默认值处理，最大栅格数为系统最大栅格数
    gridCount: 4,
    //弹窗容器样式是否自定义。默认值：false，弹窗容器的宽度根据栅格系统自适应，不跟随子节点；高度自适应子节点，最大为窗口高度的90%；圆角为24vp。
    customStyle: false
  })

  configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
    let interceptors = new List<AxiosClientRequestInterceptor>()
    //添加拦截器
    // interceptors.add(new LoadingOpenInterceptor(() => {
    //   this.loadingDialogController.open()
    // }))
    interceptors.add(new SetCookieRequestInterceptor())
    interceptors.add(new HttpRequestLoggerInterceptor())
    return interceptors
  }

  configurationResponseInterceptor(): List<AxiosClientResponseInterceptor> {
    let interceptors = new List<AxiosClientResponseInterceptor>()
    //添加拦截器
    // interceptors.add(new LoadingCloseInterceptor(() => {
    //   this.loadingDialogController.close()
    // }))
    interceptors.add(new HttpResponseLoggerInterceptor())
    return interceptors
  }


  configurationAxios(): ConfigurationAxiosClient {
    const config: ConfigurationAxiosClient = {
      baseURL: Provider.baseUrl,
      timeout: Provider.timeout,
    }
    return config
  }
}

const provider = new Provider().instance

export default provider
