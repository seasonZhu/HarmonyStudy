import router from '@ohos.router'
import AccountManager from '../accountManager/AccountManager'
import { KeywordInfo } from '../entity/KeywordInfo';
import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { WebLink } from '../entity/WebLink';

export abstract class PagesConstant {
  public static Splash = "pages/Splash"
  public static Index = "pages/Index"
  public static Login = "pages/Login"
  public static MyCoin = "pages/MyCoin"
  public static Rank = "pages/Rank"
  public static SearchResult = "pages/SearchResult"
  public static MyCollect = "pages/MyCollect"
  public static Web = "pages/WebPage"
  public static Hotkey = "pages/HotKey"
  public static TreeDetail = "pages/TreeDetail"
  public static Setting = "pages/Setting"
}

export interface RouterOptions {
  url: string
  params?: object
  success?: (() => void)
  error?: ((error: Error) => void)
  finally?: (() => void)
}

export abstract class Routes {
  public static toWebPage(webLink: WebLink) {
    Routes.push({
      url: PagesConstant.Web,
      params: webLink
    })
  }

  public static toTreeDetail(treeDetailInfo: TreeDetailInfo) {
    Routes.push({
      url: PagesConstant.TreeDetail,
      params: treeDetailInfo
    })
  }

  public static toSearchResult(keywordInfo: KeywordInfo) {
    Routes.push({
      url: PagesConstant.SearchResult,
      params: keywordInfo
    })
  }

  public static toRank() {
    Routes.push({ url: PagesConstant.Rank })
  }

  public static toCollect() {
    Routes.pushWithLogin(PagesConstant.MyCollect)
  }

  public static toMyCoin() {
    Routes.pushWithLogin(PagesConstant.MyCoin)
  }

  public static toSetting() {
    Routes.pushWithLogin(PagesConstant.Setting)
  }

  public static toLogin(showTips: boolean = true) {
    Routes.push({url: PagesConstant.Login,
      success: () => {
        if (showTips) {

        }
      }
    })
  }

  private static pushWithLogin(url: string, params?: object, showTips: boolean = true,) {
    if (AccountManager.shared().isLogin()) {
      Routes.push({url: url, params: params})
    } else {
      Routes.toLogin(showTips)
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

  public static back(options?: RouterOptions) {
    router.back({ url: options?.url, params: options?.params })
  }

  public static getParams(): Object {
    return router.getParams()
  }
}