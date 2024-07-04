import { LoginModel } from '../model/LoginModel'

export default class AccountManager {
  private static instance?: AccountManager

  loginModel?: LoginModel | null

  private constructor() {

  }

  static shared(): AccountManager {
    if (!AccountManager.instance) {
      AccountManager.instance = new AccountManager()
    }
    return AccountManager.instance
  }

  isLogin(): boolean {
    return AccountManager.shared().loginModel != null
  }
}