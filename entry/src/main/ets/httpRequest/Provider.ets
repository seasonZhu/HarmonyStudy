import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './interceptors/AxiosClientRequestInterceptor';
import { AxiosClientResponseInterceptor } from './interceptors/AxiosClientResponseInterceptor';
import { ConfigurationAxiosClient } from './configuration/ConfigurationAxiosClient'
import { HttpRequestLoggerInterceptor } from './interceptors/HttpRequestLoggerInterceptor'
import { HttpResponseLoggerInterceptor } from './interceptors/HttpResponseLoggerInterceptor'
import { BaseProvider } from './BaseProvider';
import { SetCookieRequestInterceptor } from './interceptors/SetCookieRequestInterceptor';
import { LoadingDialog } from './LoadingDialog';
import { LoadingOpenInterceptor, LoadingCloseInterceptor } from './interceptors/LoadingInterceptor';
import { Environment, EnvConfig } from './Environment';
import { environmentManager } from './EnvironmentManager';
import { LogUtil } from '@pura/harmony-utils';

export class Provider extends BaseProvider {
  private static currentEnv: Environment = Environment.PROD
  private static currentConfig: EnvConfig = EnvConfig.getConfig(Environment.PROD)

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

  /**
   * 初始化环境配置（需要在应用启动时调用）
   */
  static async initEnvironment(): Promise<void> {
    try {
      Provider.currentEnv = await environmentManager.getCurrentEnvironment()
      Provider.currentConfig = EnvConfig.getConfig(Provider.currentEnv)
      LogUtil.info('Provider: 当前环境已初始化为 ' + Provider.currentEnv)
      LogUtil.info('Provider: BaseURL = ' + Provider.currentConfig.baseUrl)
    } catch (error) {
      LogUtil.error('Provider: 初始化环境失败，使用默认环境')
    }
  }

  /**
   * 刷新环境配置（切换环境时调用）
   */
  static async refreshEnvironment(): Promise<void> {
    await Provider.initEnvironment()
  }

  /**
   * 获取当前环境
   */
  static getCurrentEnvironment(): Environment {
    return Provider.currentEnv
  }

  /**
   * 获取当前BaseURL
   */
  static getBaseUrl(): string {
    return Provider.currentConfig.baseUrl
  }

  /**
   * 获取当前超时时间
   */
  static getTimeout(): number {
    return Provider.currentConfig.timeout
  }

  /**
   * 是否启用日志
   */
  static isLogEnabled(): boolean {
    return Provider.currentConfig.enableLog
  }

  /**
   * @throws
   */
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

  /**
   * @throws
   */
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
      baseURL: Provider.getBaseUrl(),
      timeout: Provider.getTimeout(),
    }
    return config
  }
}

const provider = new Provider().instance

export default provider;

const httpClient = new Provider()

export { httpClient };
