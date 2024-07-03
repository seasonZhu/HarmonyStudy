import router from '@ohos.router'
import AccountManager from '../accountManager/AccountManager'
import { WebLink } from '../model/WebLink';

export class PagesConstant {
  public static Splash = "pages/Splash"
  public static Index = "pages/Index"
  public static Login = "pages/Login"
  public static Coin = "pages/Coin"
  public static Rank = "pages/Rank"
  public static Search = "pages/Search"
  public static Collect = "pages/Collect"
  public static Web = "pages/WebPage"
  public static Hotkey = 'pages/HotKey'
}

export interface RouterOptions {
  url: string
  params?: object
  success?: (() => void)
  error?: ((error: Error) => void)
  finally?: (() => void)
}

export class Router {
  public static toWebPage(webLink: WebLink) {
    Router.push({
      url: PagesConstant.Web,
      params: webLink
    })
  }

  public static toCollectPage() {
    Router.pushWithLogin(PagesConstant.Collect)
  }

  public static toSearchPage() {
    Router.push({url: PagesConstant.Search })
  }

  public static toRankPage() {
    Router.pushWithLogin(PagesConstant.Rank)
  }

  public static toCoinPage() {
    Router.pushWithLogin(PagesConstant.Coin)
  }


  public static toLoginPage(showTips: boolean = true) {
    Router.push({url: PagesConstant.Login,
      success: () => {
        if (showTips) {

        }
      }
    })
  }

  private static pushWithLogin(url: string, params?: object, showTips: boolean = true,) {
    if (AccountManager.shared().loginModel == null) {
      Router.toLoginPage(showTips)
    } else {
      Router.push({url: url, params: params})
    }
  }

  public static replace(options: RouterOptions) {
    router.replaceUrl(
      { url: options.url, params: options.params },
      router.RouterMode.Standard)
      .then(options.success)
      .catch(options.error)
  }

  public static push(
    options: RouterOptions) {
    router.pushUrl(
      { url: options.url, params: options.params },
      router.RouterMode.Standard
    )
      .then(() => {
        if(options.success) {
          options.success()
        }
        console.log("路由成功了")
      })
      .catch((error: Error) => {
        if(options.error) {
          options.error(error)
        }
        console.log("路由失败了")
      })
      .finally(() => {
        if(options.finally) {
          options.finally()
        }
      })
  }

  public static back(url?: string, params?: object) {
    router.back({ url: url, params: params })
  }

  public static getParams(): object | null {
    return router.getParams()
  }
}