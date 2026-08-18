import { LoginModel } from '../model/LoginModel'
import { PreferencesUtil } from '@pura/harmony-utils'

const LOGIN_MODEL_KEY = 'loginModel'

export default class AccountManager {
  private static instance?: AccountManager

  loginModel?: LoginModel | null

  private constructor() {}

  static shared(): AccountManager {
    if (!AccountManager.instance) {
      AccountManager.instance = new AccountManager()
    }
    return AccountManager.instance
  }

  public isLogin(): boolean {
    return AccountManager.shared().loginModel != null
  }

  public toDestroy(): void {
    AccountManager.shared().loginModel = null
    PreferencesUtil.deleteSync(LOGIN_MODEL_KEY)
  }

  async saveLoginModel(model: LoginModel): Promise<void> {
    AccountManager.shared().loginModel = model
    await PreferencesUtil.put(LOGIN_MODEL_KEY, JSON.stringify(model))
  }

  async restoreLoginModel(): Promise<LoginModel | null> {
    let saved = await PreferencesUtil.get(LOGIN_MODEL_KEY, '') as string
    if (saved.length > 0) {
      try {
        let model: LoginModel = JSON.parse(saved)
        AccountManager.shared().loginModel = model
        return model
      } catch (_e) {
        return null
      }
    }
    return null
  }
}