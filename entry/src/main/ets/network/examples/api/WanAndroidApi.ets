/**
 * WanAndroid API
 * @description 基于真实 WanAndroid API 的接口封装
 * 使用 network 模块的 NetworkProvider 进行网络请求
 */

import { NetworkProvider } from '../NetworkProvider'
import { ApiResponse, isSuccess, extractData, HttpConfig } from 'network'
import { LogUtil } from '@pura/harmony-utils'
import {
  Banner,
  Article,
  ArticlePageResponse,
  LoginResponse,
  RankUser,
  UsefulSite,
  HotKey,
  UserCoinResponse
} from './WanAndroidModels'

/**
 * WanAndroid API 类
 * @description 封装所有 WanAndroid 相关的 API 调用
 */
export class WanAndroidApi {
  // WanAndroid API 基础路径（相对路径，baseURL 由环境管理）
  private static readonly BASE_PATH = ''

  /**
   * ============ 首页相关接口 ============
   */

  /**
   * 获取首页轮播图
   * @returns Promise<Banner[]>
   */
  static async getBanner(): Promise<Banner[]> {
    try {
      const response: ApiResponse<Banner[]> = await NetworkProvider.get<Banner[]>(
        `${WanAndroidApi.BASE_PATH}banner/json`
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取轮播图成功')
        return data as Banner[]
      } else {
        throw new Error(response.errorMsg || '获取轮播图失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取轮播图失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 获取置顶文章
   * @returns Promise<Article[]>
   */
  static async getTopArticles(): Promise<Article[]> {
    try {
      const response: ApiResponse<Article[]> = await NetworkProvider.get<Article[]>(
        `${WanAndroidApi.BASE_PATH}article/top/json`,
        {} as Record<string, string | number | boolean>,
        {} as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取置顶文章成功')
        return data as Article[]
      } else {
        throw new Error(response.errorMsg || '获取置顶文章失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取置顶文章失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 获取首页文章列表（分页）
   * @param page 页码，从 0 开始
   * @returns Promise<ArticlePageResponse>
   */
  static async getArticleList(page: number): Promise<ArticlePageResponse> {
    try {
      const response: ApiResponse<ArticlePageResponse> = await NetworkProvider.get<ArticlePageResponse>(
        `${WanAndroidApi.BASE_PATH}article/list/${page}/json`,
        {} as Record<string, string | number | boolean>,
        { showLoading: page === 0 } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取文章列表成功')
        return data as ArticlePageResponse
      } else {
        throw new Error(response.errorMsg || '获取文章列表失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取文章列表失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * ============ 用户相关接口 ============
   */

  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   * @returns Promise<LoginResponse>
   */
  static async login(username: string, password: string): Promise<LoginResponse> {
    try {
      const params: Record<string, string | number | boolean> = {} as Record<string, string | number | boolean>
      params['username'] = username
      params['password'] = password

      const response: ApiResponse<LoginResponse> = await NetworkProvider.post<LoginResponse>(
        `${WanAndroidApi.BASE_PATH}user/login`,
        params,
        { showLoading: true, loadingText: '登录中...' } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 登录成功')
        return data as LoginResponse
      } else {
        throw new Error(response.errorMsg || '登录失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 登录失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param repassword 确认密码
   * @returns Promise<LoginResponse>
   */
  static async register(username: string, password: string, repassword: string): Promise<LoginResponse> {
    try {
      const params: Record<string, string | number | boolean> = {} as Record<string, string | number | boolean>
      params['username'] = username
      params['password'] = password
      params['repassword'] = repassword

      const response: ApiResponse<LoginResponse> = await NetworkProvider.post<LoginResponse>(
        `${WanAndroidApi.BASE_PATH}user/register`,
        params,
        { showLoading: true, loadingText: '注册中...' } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 注册成功')
        return data as LoginResponse
      } else {
        throw new Error(response.errorMsg || '注册失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 注册失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 用户退出登录
   */
  static async logout(): Promise<void> {
    try {
      const response: ApiResponse<void> = await NetworkProvider.get<void>(
        `${WanAndroidApi.BASE_PATH}user/logout/json`,
        {} as Record<string, string | number | boolean>,
        { showLoading: true, loadingText: '退出中...' } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        LogUtil.info('[WanAndroidApi] 退出登录成功')
      } else {
        throw new Error(response.errorMsg || '退出登录失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 退出登录失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 获取个人积分
   */
  static async getUserCoin(): Promise<number> {
    try {
      const response: ApiResponse<UserCoinResponse> = await NetworkProvider.get<UserCoinResponse>(
        `${WanAndroidApi.BASE_PATH}lg/coin/userinfo/json`,
        {} as Record<string, string | number | boolean>,
        { showLoading: true, loadingText: '加载中...' } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取积分成功')
        return (data as UserCoinResponse).coinCount
      } else {
        throw new Error(response.errorMsg || '获取积分失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取积分失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 获取积分排行榜
   * @param page 页码，从 1 开始
   */
  static async getCoinRank(page: number): Promise<RankUser[]> {
    try {
      const response: ApiResponse<RankUser[]> = await NetworkProvider.get<RankUser[]>(
        `${WanAndroidApi.BASE_PATH}coin/rank/${page}/json`,
        {} as Record<string, string | number | boolean>,
        { showLoading: page === 1 } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取积分排行榜成功')
        return data as RankUser[]
      } else {
        throw new Error(response.errorMsg || '获取积分排行榜失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取积分排行榜失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * ============ 收藏相关接口 ============
   */

  /**
   * 收藏文章
   * @param articleId 文章ID
   */
  static async collectArticle(articleId: number): Promise<void> {
    try {
      const response: ApiResponse<void> = await NetworkProvider.post<void>(
        `${WanAndroidApi.BASE_PATH}lg/collect/${articleId}/json`,
        {} as Record<string, string | number | boolean>,
        {} as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        LogUtil.info('[WanAndroidApi] 收藏成功')
      } else {
        throw new Error(response.errorMsg || '收藏失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 收藏失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 取消收藏文章
   * @param articleId 文章ID
   */
  static async uncollectArticle(articleId: number): Promise<void> {
    try {
      const response: ApiResponse<void> = await NetworkProvider.post<void>(
        `${WanAndroidApi.BASE_PATH}lg/uncollect_originId/${articleId}/json`,
        {} as Record<string, string | number | boolean>,
        {} as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        LogUtil.info('[WanAndroidApi] 取消收藏成功')
      } else {
        throw new Error(response.errorMsg || '取消收藏失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 取消收藏失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 获取收藏列表
   * @param page 页码，从 0 开始
   */
  static async getCollectList(page: number): Promise<ArticlePageResponse> {
    try {
      const response: ApiResponse<ArticlePageResponse> = await NetworkProvider.get<ArticlePageResponse>(
        `${WanAndroidApi.BASE_PATH}lg/collect/list/${page}/json`,
        {} as Record<string, string | number | boolean>,
        { showLoading: page === 0 } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取收藏列表成功')
        return data as ArticlePageResponse
      } else {
        throw new Error(response.errorMsg || '获取收藏列表失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取收藏列表失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * ============ 搜索相关接口 ============
   */

  /**
   * 获取搜索热词
   */
  static async getHotKey(): Promise<HotKey[]> {
    try {
      const response: ApiResponse<HotKey[]> = await NetworkProvider.get<HotKey[]>(
        `${WanAndroidApi.BASE_PATH}hotkey/json`,
        {} as Record<string, string | number | boolean>,
        {} as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取搜索热词成功')
        return data as HotKey[]
      } else {
        throw new Error(response.errorMsg || '获取搜索热词失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取搜索热词失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * 搜索文章
   * @param page 页码，从 0 开始
   * @param keyword 搜索关键词
   */
  static async searchArticles(page: number, keyword: string): Promise<ArticlePageResponse> {
    try {
      const params: Record<string, string | number | boolean> = {} as Record<string, string | number | boolean>
      params['k'] = keyword

      const response: ApiResponse<ArticlePageResponse> = await NetworkProvider.post<ArticlePageResponse>(
        `${WanAndroidApi.BASE_PATH}article/query/${page}/json`,
        params,
        { showLoading: page === 0 } as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 搜索文章成功')
        return data as ArticlePageResponse
      } else {
        throw new Error(response.errorMsg || '搜索文章失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 搜索文章失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }

  /**
   * ============ 常用网站接口 ============
   */

  /**
   * 获取常用网站
   */
  static async getUsefulSites(): Promise<UsefulSite[]> {
    try {
      const response: ApiResponse<UsefulSite[]> = await NetworkProvider.get<UsefulSite[]>(
        `${WanAndroidApi.BASE_PATH}friend/json`,
        {} as Record<string, string | number | boolean>,
        {} as Partial<HttpConfig>
      )

      if (isSuccess(response)) {
        const data = extractData(response)
        LogUtil.info('[WanAndroidApi] 获取常用网站成功')
        return data as UsefulSite[]
      } else {
        throw new Error(response.errorMsg || '获取常用网站失败')
      }
    } catch (error) {
      LogUtil.error('[WanAndroidApi] 获取常用网站失败', JSON.stringify(error))
      throw error instanceof Error ? error : new Error(String(error))
    }
  }
}

export default WanAndroidApi
