import router from '@ohos.router'
import AccountManager from '../accountManager/AccountManager'

export class PagesConstant {
  public static SPLASH_PAGE: string = 'ui/pages/SplashPage'
  public static MAIN_PAGE: string = 'ui/pages/main/MainPage'
  public static LOGIN_PAGE: string = 'ui/pages/login/LoginPage'
  public static COIN_PAGE: string = 'ui/pages/coin/CoinPage'
  public static RANK_PAGE: string = 'ui/pages/rank/RankPage'
  public static SEARCH_PAGE: string = 'ui/pages/search/SearchPage'
  public static COLLECT_PAGE: string = 'ui/pages/collect/CollectPage'
  public static SHARE_LIST_PAGE: string = 'ui/pages/share/ShareListPage'
  public static SHARE_ARTICLE_PAGE: string = 'ui/pages/share/ShareArticlePage'
  public static SETTING_PAGE: string = 'ui/pages/setting/SettingPage'
  public static AVATAR_PAGE: string = 'ui/pages/avatar/AvatarPage'
  public static WEB_PAGE: string = 'ui/pages/web/WebPage'
  public static NavigationBar: string = 'Weight/NavigationBar'
  public static Hotkey: string = 'pages/HotKey'
}

export interface WebLink {
  link: string | null
  id: number | null
  title: string | null
}

export interface RefreshValue {
  refresh: boolean | null
}

export interface RouterOptions {
  url: string
  params?: object
  success?: (() => void)
  fail?: ((error: Error) => void)
}

export class Router {
  public static toWebPage(link: string) {

    const webLink: WebLink = {
      link: link,
      id: null,
      title: null
    };

    Router.push({
      url: PagesConstant.WEB_PAGE,
      params: webLink
    })
  }


  public static toAvatarPage() {
    Router.push({url: PagesConstant.AVATAR_PAGE})
  }


  public static toSettingPage() {
    Router.push({url: PagesConstant.SETTING_PAGE})
  }

  public static toShareArticlePage(id: number | null = null, title: string | null = null, link: string | null = null) {

    const webLink: WebLink = {
      link: link,
      id: id,
      title: title
    };

    Router.pushWithLogin(
      PagesConstant.SHARE_ARTICLE_PAGE,
      webLink
    )
  }

  public static toShareListPage() {
    const refresh: RefreshValue = {
      refresh: false
    };

    Router.pushWithLogin(
      PagesConstant.SHARE_LIST_PAGE,
      refresh)
  }

  public static toCollectPage() {
    Router.pushWithLogin(PagesConstant.COLLECT_PAGE)
  }

  public static toSearchPage() {
    Router.push({url: PagesConstant.SEARCH_PAGE })
  }

  public static toRankPage() {
    Router.pushWithLogin(PagesConstant.RANK_PAGE)
  }

  public static toCoinPage() {
    Router.pushWithLogin(PagesConstant.COIN_PAGE)
  }


  public static toMainPage() {
    Router.replace({url: PagesConstant.MAIN_PAGE})
  }


  public static toLoginPage(showTips: boolean = true) {
    Router.push({url: PagesConstant.LOGIN_PAGE,
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
      .catch(options.fail)
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
        if(options.fail) {
          options.fail(error)
        }
        console.log("路由失败了")
      })
  }


  public static back(url?: string, params?: object) {
    router.back({ url: url, params: params })
  }

  public static getParams(): object | null {
    return router.getParams()
  }
}