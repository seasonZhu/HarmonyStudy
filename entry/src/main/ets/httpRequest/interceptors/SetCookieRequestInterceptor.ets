import { AxiosHeaders, InternalAxiosRequestConfig } from '@ohos/axios';
import AccountManager from '../../AccountManager/AccountManager';
import { AxiosClientRequestInterceptor } from './AxiosClientRequestInterceptor';

export class SetCookieRequestInterceptor implements AxiosClientRequestInterceptor {
  onFulfilled(config: InternalAxiosRequestConfig) {
    // 配置Cookie
    let cookie = getCookieHeaderValue()
    console.log("http cookie: " + cookie)
    config.headers.set('Cookie', cookie)
    return config
  }
}

/// 这个函数不能写在这个SetCookieRequestInterceptor类中，否则所有的网络请求都报错
export function getCookieHeaderValue(): string {
  let username = AccountManager.shared().loginModel?.username ?? ""
  let password = AccountManager.shared().loginModel?.password ?? ""

  if (username.length == 0 && password.length == 0) {
    return ""
  } else {
    return "loginUserName=" + username + ";loginUserPassword=" + password
  }
}