
export enum Environment {
  DEV = "dev",
  TEST = "test",
  PROD = "prod"
}

export class EnvConfig {
  baseUrl: string = ""
  timeout: number = 30000
  enableLog: boolean = true

  static getConfig(env: Environment): EnvConfig {
    const config = new EnvConfig()
    switch(env) {
      case Environment.DEV:
        // 开发环境 - 使用开发服务器地址
        config.baseUrl = "https://wanandroid.com/"
        config.timeout = 30000
        config.enableLog = true
        break
      case Environment.TEST:
        // 测试环境 - 使用测试服务器地址
        config.baseUrl = "https://wanandroid.com/"
        config.timeout = 60000
        config.enableLog = true
        break
      case Environment.PROD:
        // 生产环境 - 使用正式服务器地址
        config.baseUrl = "https://wanandroid.com/"
        config.timeout = 30000
        config.enableLog = false
        break
    }
    return config
  }
}