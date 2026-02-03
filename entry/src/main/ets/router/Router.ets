import { router } from '@kit.ArkUI'
import { LogUtil } from '@pura/harmony-utils';
import AccountManager from '../accountManager/AccountManager'
import { KeywordInfo } from '../entity/KeywordInfo';
import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { WebLink } from '../entity/WebLink';
import { PagesConstant } from './PagesConstant';

/**
 * 命名路由选项
 */
interface NamedRouteOptions {
  url: string
  params?: object
}

/**
 * 路由工具类 - 优化版本
 *
 * @description
 * 提供类型安全的路由跳转功能
 *
 * @example
 * ```typescript
 * // 简单跳转
 * Router.push(PagesConstant.Home)
 *
 * // 带参数跳转
 * Router.push(PagesConstant.Web, webLink)
 *
 * // 类型安全的参数获取
 * let webLink = Router.getParams<WebLink>()
 *
 * // 需要登录的页面
 * Router.pushWithLogin(PagesConstant.MyCollect)
 * ```
 */
export class Router {
  private static readonly TAG = 'Router'

  // ==================== 核心路由方法 ====================

  /**
   * 跳转到指定页面
   * @param url 页面路径
   * @param params 页面参数（可选，支持泛型）
   */
  static push<T = object>(url: string, params?: T): void {
    try {
      router.push({ url, params })
      LogUtil.debug(`${Router.TAG}: 跳转到 ${url}`)
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 跳转失败`, JSON.stringify(error))
      if (error instanceof Error) {
        throw error
      }
    }
  }

  /**
   * 替换当前页面
   * @param url 页面路径
   * @param params 页面参数（可选）
   */
  static replace<T = object>(url: string, params?: T): void {
    try {
      router.replace({ url, params })
      LogUtil.debug(`${Router.TAG}: 替换到 ${url}`)
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 替换失败`, JSON.stringify(error))
      if (error instanceof Error) {
        throw error
      }
    }
  }

  /**
   * 返回上一页
   */
  static back(): void {
    try {
      router.back()
      LogUtil.debug(`${Router.TAG}: 返回上一页`)
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 返回失败`, JSON.stringify(error))
    }
  }

  /**
   * 获取页面参数（类型安全）
   * @template T 参数类型
   * @returns 页面参数，如果不存在返回 null
   */
  static getParams<T = object>(): T | null {
    try {
      const params = router.getParams()
      return params ? (params as T) : null
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 获取参数失败`, JSON.stringify(error))
      return null
    }
  }

  // ==================== 登录相关方法 ====================

  /**
   * 跳转到登录页
   * @param callback 登录成功后的回调（可选）
   */
  static toLogin(callback?: () => void): void {
    Router.push(PagesConstant.Login)
    if (callback) {
      // 将回调保存到全局，供登录页面调用
      AppStorage.setOrCreate('loginCallback', callback)
    }
  }

  /**
   * 需要登录的页面跳转
   * @param url 页面路径
   * @param params 页面参数
   */
  static pushWithLogin<T = object>(url: string, params?: T): void {
    if (AccountManager.shared().isLogin()) {
      Router.push<T>(url, params)
    } else {
      // 保存目标页面信息，登录成功后跳转
      AppStorage.setOrCreate('afterLoginTarget', { url, params })
      Router.toLogin()
    }
  }

  // ==================== 便捷方法 ====================

  /**
   * 跳转到 Web 页面
   */
  static toWebPage(webLink: WebLink): void {
    Router.push(PagesConstant.Web, webLink)
  }

  /**
   * 跳转到搜索结果页
   */
  static toSearchResult(keywordInfo: KeywordInfo): void {
    Router.push(PagesConstant.SearchResult, keywordInfo)
  }

  /**
   * 跳转到树形详情页
   */
  static toTreeDetail(treeDetailInfo: TreeDetailInfo): void {
    Router.push(PagesConstant.TreeDetail, treeDetailInfo)
  }

  /**
   * 跳转到排行榜
   */
  static toRank(): void {
    Router.push(PagesConstant.Rank)
  }

  /**
   * 跳转到注册页
   */
  static toRegister(): void {
    Router.push(PagesConstant.Register)
  }

  /**
   * 跳转到收藏页（需要登录）
   */
  static toCollect(): void {
    Router.pushWithLogin(PagesConstant.MyCollect)
  }

  /**
   * 跳转到积分页（需要登录）
   */
  static toMyCoin(): void {
    Router.pushWithLogin(PagesConstant.MyCoin)
  }

  /**
   * 跳转到设置页（需要登录）
   */
  static toSetting(): void {
    Router.pushWithLogin(PagesConstant.Setting)
  }

  /**
   * 跳转到Web示例页（需要登录）
   */
  static toWebExample(): void {
    Router.pushWithLogin(PagesConstant.WebExample)
  }

  /**
   * 跳转到Web组件页（需要登录）
   */
  static toWebComponent(): void {
    Router.pushWithLogin(PagesConstant.WebComponent)
  }

  /**
   * 跳转到测试页面
   */
  static toObservedV2TestPage(): void {
    Router.push(PagesConstant.ObservedV2TestPage)
  }

  /**
   * 跳转到环境切换页
   */
  static toEnvironmentSwitch(): void {
    Router.push(PagesConstant.EnvironmentSwitch)
  }

  /**
   * 跳转到网络请求示例页
   */
  static toNetworkExample(): void {
    Router.push(PagesConstant.NetworkExample)
  }

  // ==================== 兼容性方法（已废弃，保持向后兼容）====================

  /**
   * @deprecated 请使用 push(url, params) 替代
   * 保留此方法仅用于向后兼容
   */
  static pushName(options: NamedRouteOptions): void {
    try {
      router.pushNamedRoute({ name: options.url, params: options.params })
      LogUtil.debug(`${Router.TAG}: 命名路由跳转 ${options.url}`)
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 命名路由跳转失败`, JSON.stringify(error))
    }
  }

  /**
   * @deprecated 请使用 back() 替代
   * 保留此方法仅用于向后兼容
   */
  static backWithParams(url: string, params?: object): void {
    try {
      router.back({ url, params })
      LogUtil.debug(`${Router.TAG}: 返回到 ${url}`)
    } catch (error) {
      LogUtil.error(`${Router.TAG}: 返回失败`, JSON.stringify(error))
    }
  }
}
