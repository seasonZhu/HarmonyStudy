/**
 * NetworkExampleViewModel - 网络请求示例 ViewModel
 * @description 展示如何使用 network 模块和 WanAndroidApi 进行网络请求
 */

import { WanAndroidApi } from '../api/WanAndroidApi'
import {
  Banner,
  Article,
  LoginResponse,
  RankUser,
  HotKey,
  UsefulSite
} from '../api/WanAndroidModels'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 视图状态
 */
export enum ViewState {
  IDLE = 'idle',
  LOADING = 'loading',
  SUCCESS = 'success',
  ERROR = 'error'
}

/**
 * NetworkExampleViewModel 类
 * @description 演示各种网络请求的使用场景，使用真实的 WanAndroid API
 */
export class NetworkExampleViewModel {
  // ========== 状态管理 ==========

  private viewState: ViewState = ViewState.IDLE
  private errorMessage: string = ''

  // ========== 数据存储 ==========

  // 首页数据
  private banners: Banner[] = []
  private topArticles: Article[] = []
  private articleList: Article[] = []
  private articlePage: number = 0
  private articleTotal: number = 0
  private hasMoreArticles: boolean = true

  // 用户数据
  private loginResponse: LoginResponse | null = null
  private userCoin: number = 0

  // 排行榜数据
  private coinRankList: RankUser[] = []

  // 搜索数据
  private hotKeys: HotKey[] = []
  private searchResults: Article[] = []

  // 常用网站
  private usefulSites: UsefulSite[] = []

  // ========== 获取状态 ==========

  getViewState(): ViewState {
    return this.viewState
  }

  getErrorMessage(): string {
    return this.errorMessage
  }

  isLoading(): boolean {
    return this.viewState === ViewState.LOADING
  }

  // ========== 获取数据 ==========

  getBanners(): Banner[] {
    return this.banners
  }

  getTopArticles(): Article[] {
    return this.topArticles
  }

  getArticleList(): Article[] {
    return this.articleList
  }

  getHasMoreArticles(): boolean {
    return this.hasMoreArticles
  }

  getLoginResponse(): LoginResponse | null {
    return this.loginResponse
  }

  getUserCoin(): number {
    return this.userCoin
  }

  getCoinRankList(): RankUser[] {
    return this.coinRankList
  }

  getHotKeys(): HotKey[] {
    return this.hotKeys
  }

  getSearchResults(): Article[] {
    return this.searchResults
  }

  getUsefulSites(): UsefulSite[] {
    return this.usefulSites
  }

  // ========== 示例1: 获取首页数据（并发请求） ==========

  /**
   * 加载首页数据
   * @description 使用 Promise.all 并发获取轮播图和置顶文章
   */
  async loadHomeData(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      const results = await Promise.all([
        WanAndroidApi.getBanner(),
        WanAndroidApi.getTopArticles(),
        WanAndroidApi.getArticleList(0)
      ])

      this.banners = results[0]
      this.topArticles = results[1]
      this.articleList = results[2].datas
      this.articleTotal = results[2].total
      this.articlePage = 0
      this.hasMoreArticles = !results[2].over

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载首页数据成功')
    } catch (error) {
      this.handleError(error, '加载首页数据失败')
    }
  }

  // ========== 示例2: 加载更多文章列表 ==========

  /**
   * 加载更多文章
   * @description 分页加载示例
   */
  async loadMoreArticles(): Promise<void> {
    if (!this.hasMoreArticles) {
      LogUtil.info('[NetworkExampleViewModel] 没有更多文章了')
      return
    }

    try {
      const nextPage = this.articlePage + 1
      const response = await WanAndroidApi.getArticleList(nextPage)

      this.articleList = [...this.articleList, ...response.datas]
      this.articlePage = response.curPage
      this.hasMoreArticles = !response.over

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载更多文章成功')
    } catch (error) {
      this.handleError(error, '加载更多文章失败')
    }
  }

  // ========== 示例3: 用户登录 ==========

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   */
  async login(username: string, password: string): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      this.loginResponse = await WanAndroidApi.login(username, password)

      // 登录成功后自动获取积分
      this.userCoin = await WanAndroidApi.getUserCoin()

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 登录成功')
    } catch (error) {
      this.handleError(error, '登录失败')
    }
  }

  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   */
  async register(username: string, password: string): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      this.loginResponse = await WanAndroidApi.register(username, password, password)

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 注册成功')
    } catch (error) {
      this.handleError(error, '注册失败')
    }
  }

  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    try {
      await WanAndroidApi.logout()
      this.loginResponse = null
      this.userCoin = 0
      LogUtil.info('[NetworkExampleViewModel] 退出登录成功')
    } catch (error) {
      this.handleError(error, '退出登录失败')
    }
  }

  // ========== 示例4: 获取积分排行榜 ==========

  /**
   * 加载积分排行榜
   */
  async loadCoinRank(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      this.coinRankList = await WanAndroidApi.getCoinRank(1)

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载积分排行榜成功')
    } catch (error) {
      this.handleError(error, '加载积分排行榜失败')
    }
  }

  // ========== 示例5: 收藏/取消收藏 ==========

  /**
   * 收藏文章
   * @param articleId 文章ID
   */
  async collectArticle(articleId: number): Promise<void> {
    try {
      await WanAndroidApi.collectArticle(articleId)

      // 更新本地状态
      const article = this.articleList.find(a => a.id === articleId)
      if (article) {
        article.collect = true
      }

      LogUtil.info('[NetworkExampleViewModel] 收藏成功')
    } catch (error) {
      this.handleError(error, '收藏失败')
    }
  }

  /**
   * 取消收藏文章
   * @param articleId 文章ID
   */
  async uncollectArticle(articleId: number): Promise<void> {
    try {
      await WanAndroidApi.uncollectArticle(articleId)

      // 更新本地状态
      const article = this.articleList.find(a => a.id === articleId)
      if (article) {
        article.collect = false
      }

      LogUtil.info('[NetworkExampleViewModel] 取消收藏成功')
    } catch (error) {
      this.handleError(error, '取消收藏失败')
    }
  }

  // ========== 示例6: 搜索功能 ==========

  /**
   * 加载搜索热词
   */
  async loadHotKeys(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      this.hotKeys = await WanAndroidApi.getHotKey()

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载搜索热词成功')
    } catch (error) {
      this.handleError(error, '加载搜索热词失败')
    }
  }

  /**
   * 搜索文章
   * @param keyword 搜索关键词
   */
  async searchArticles(keyword: string): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      const response = await WanAndroidApi.searchArticles(0, keyword)
      this.searchResults = response.datas

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 搜索成功，找到 ' + response.datas.length + ' 篇文章')
    } catch (error) {
      this.handleError(error, '搜索失败')
    }
  }

  // ========== 示例7: 常用网站 ==========

  /**
   * 加载常用网站
   */
  async loadUsefulSites(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      this.usefulSites = await WanAndroidApi.getUsefulSites()

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载常用网站成功')
    } catch (error) {
      this.handleError(error, '加载常用网站失败')
    }
  }

  // ========== 示例8: 组合请求 ==========

  /**
   * 加载完整用户数据
   * @description 并发请求用户积分和排行榜
   */
  async loadUserCompleteData(): Promise<void> {
    this.setViewState(ViewState.LOADING)

    try {
      const results = await Promise.all([
        WanAndroidApi.getUserCoin(),
        WanAndroidApi.getCoinRank(1)
      ])

      this.userCoin = results[0]
      this.coinRankList = results[1]

      this.setViewState(ViewState.SUCCESS)
      LogUtil.info('[NetworkExampleViewModel] 加载用户完整数据成功')
    } catch (error) {
      this.handleError(error, '加载数据失败')
    }
  }

  // ========== 错误处理 ==========

  /**
   * 处理错误
   */
  private handleError(error: Error | object | string, defaultMessage: string): void {
    this.viewState = ViewState.ERROR

    if (error instanceof Error) {
      this.errorMessage = error.message || defaultMessage
    } else if (typeof error === 'string') {
      this.errorMessage = error
    } else {
      this.errorMessage = defaultMessage
    }

    LogUtil.error('[NetworkExampleViewModel] 错误', this.errorMessage)
  }

  /**
   * 设置视图状态
   */
  private setViewState(state: ViewState): void {
    this.viewState = state
    if (state === ViewState.ERROR) {
      // 保持错误消息
    } else if (state === ViewState.SUCCESS) {
      this.errorMessage = ''
    }
  }

  /**
   * 重置状态
   */
  reset(): void {
    this.viewState = ViewState.IDLE
    this.errorMessage = ''
    this.banners = []
    this.topArticles = []
    this.articleList = []
    this.articlePage = 0
    this.articleTotal = 0
    this.hasMoreArticles = true
    this.loginResponse = null
    this.userCoin = 0
    this.coinRankList = []
    this.hotKeys = []
    this.searchResults = []
    this.usefulSites = []
  }
}

export default NetworkExampleViewModel
