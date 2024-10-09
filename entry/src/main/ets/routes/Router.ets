import router from '@ohos.router'
import { LogUtil } from '@pura/harmony-utils';
import AccountManager from '../accountManager/AccountManager'
import { KeywordInfo } from '../entity/KeywordInfo';
import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { WebLink } from '../entity/WebLink';
import { PagesConstant } from './PagesConstant';

/// 这个Router只是对router的简单封装，其实不用也罢
export interface RouterOptions {
  url: string
  params?: object
  success?: (() => void)
  error?: ((error: Error) => void)
  finally?: (() => void)
}

export abstract class Router {
  public static toWebPage(webLink: WebLink) {
    Router.push({
      url: PagesConstant.Web,
      params: webLink
    })
  }

  public static toTreeDetail(treeDetailInfo: TreeDetailInfo) {
    Router.push({
      url: PagesConstant.TreeDetail,
      params: treeDetailInfo
    })
  }

  public static toSearchResult(keywordInfo: KeywordInfo) {
    Router.push({
      url: PagesConstant.SearchResult,
      params: keywordInfo
    })
  }

  public static toRank() {
    Router.push({ url: PagesConstant.Rank })
  }

  public static toRegister() {
    Router.push({ url: PagesConstant.Register })
  }

  public static toCollect() {
    Router.pushWithLogin(PagesConstant.MyCollect)
  }

  public static toMyCoin() {
    Router.pushWithLogin(PagesConstant.MyCoin)
  }

  public static toSetting() {
    Router.pushWithLogin(PagesConstant.Setting)
  }

  public static toWebExample() {
    Router.pushWithLogin(PagesConstant.WebExample)
  }

  public static toWebComponent() {
    Router.pushWithLogin(PagesConstant.WebComponent)
  }

  public static toLogin(showTips: boolean = true, callback?: (() => void)) {
    Router.push({url: PagesConstant.Login,
      success: () => {
        if (showTips) {
          if (callback) {
            callback()
          }
        }
      }
    })
  }

  private static pushWithLogin(url: string, params?: object, showTips: boolean = true, callback?: (() => void)) {
    if (AccountManager.shared().isLogin()) {
      Router.push({url: url, params: params})
    } else {
      Router.toLogin(showTips, callback)
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
        LogUtil.debug("路由成功了")
      })
      .catch((error: Error) => {
        if(options.error) {
          options.error(error)
        }
        LogUtil.debug("路由失败了")
      })
      .finally(() => {
        if(options.finally) {
          options.finally()
        }
      })
  }

  public static pushName(options: RouterOptions) {
    router.pushNamedRoute(
      { name: options.url, params: options.params },
      router.RouterMode.Standard
    )
      .then(() => {
        if(options.success) {
          options.success()
        }
        LogUtil.debug("路由成功了")
      })
      .catch((error: Error) => {
        if(options.error) {
          options.error(error)
        }
        LogUtil.debug("路由失败了")
      })
      .finally(() => {
        if(options.finally) {
          options.finally()
        }
      })
  }

  public static back(options?: RouterOptions) {
    let url = options?.url ?? ""
    router.back({url: url, params: options?.params })
  }

  public static getParams(): Object {
    return router.getParams()
  }
}