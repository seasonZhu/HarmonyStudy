
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
        config.baseUrl = "https://www.wanandroid.com/"
        config.enableLog = true
        break
      case Environment.TEST:
        config.baseUrl = "https://www.wanandroid.com/"
        config.timeout = 60000
        break
      case Environment.PROD:
        config.baseUrl = "https://www.wanandroid.com/"
        config.enableLog = false
        break
    }
    return config
  }
}