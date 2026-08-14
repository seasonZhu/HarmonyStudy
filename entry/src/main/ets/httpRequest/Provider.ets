import List from '@ohos.util.List'
import { AxiosClientRequestInterceptor } from './interceptors/AxiosClientRequestInterceptor';
import { AxiosClientResponseInterceptor } from './interceptors/AxiosClientResponseInterceptor';
import { ConfigurationAxiosClient } from './configuration/ConfigurationAxiosClient'
import { HttpRequestLoggerInterceptor } from './interceptors/HttpRequestLoggerInterceptor'
import { HttpResponseLoggerInterceptor } from './interceptors/HttpResponseLoggerInterceptor'
import { BaseProvider } from './BaseProvider';
import { SetCookieRequestInterceptor } from './interceptors/SetCookieRequestInterceptor';
import { Environment, EnvConfig } from './Environment';
import { environmentManager } from './EnvironmentManager';
import { LogUtil } from '@pura/harmony-utils';

export class Provider extends BaseProvider {
  private static currentEnv: Environment = Environment.PROD
  private static currentConfig: EnvConfig = EnvConfig.getConfig(Environment.PROD)

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

  static async refreshEnvironment(): Promise<void> {
    await Provider.initEnvironment()
  }

  static getCurrentEnvironment(): Environment {
    return Provider.currentEnv
  }

  static getBaseUrl(): string {
    return Provider.currentConfig.baseUrl
  }

  static getTimeout(): number {
    return Provider.currentConfig.timeout
  }

  static isLogEnabled(): boolean {
    return Provider.currentConfig.enableLog
  }

  configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
    let interceptors = new List<AxiosClientRequestInterceptor>()
    interceptors.add(new SetCookieRequestInterceptor())
    interceptors.add(new HttpRequestLoggerInterceptor())
    return interceptors
  }

  configurationResponseInterceptor(): List<AxiosClientResponseInterceptor> {
    let interceptors = new List<AxiosClientResponseInterceptor>()
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

const provider = new Provider()

export default provider.instance
