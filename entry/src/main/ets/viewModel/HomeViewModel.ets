import { HomeRepository } from '../repository/HomeRepository'
import { Banner } from '../model/Banner'
import { Article } from '../model/Article'
import { PageModel } from '../model/PageModel'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 首页刷新结果
 */
export interface HomeRefreshResult {
  banners: Banner[]
  hotArticles: Article[]
  normalArticles: PageModel<Article>
}

/**
 * 首页视图模型
 * @description 处理首页的业务逻辑（Banner、置顶文章、普通文章）
 */
export class HomeViewModel {
  private homeRepo = new HomeRepository()
  private pageNum = 1

  /**
   * 获取 Banner 列表
   * @returns Banner 列表
   */
  getBanner = async (): Promise<Banner[]> => {
    LogUtil.debug('HomeViewModel: 获取 Banner')
    return this.homeRepo.getBannerList()
  }

  /**
   * 获取置顶文章
   * @returns 置顶文章列表
   */
  getHotArticle = async (): Promise<Article[]> => {
    LogUtil.debug('HomeViewModel: 获取置顶文章')
    return this.homeRepo.getHotArticleList()
  }

  /**
   * 获取普通文章
   * @param page 页码
   * @returns 分页文章数据
   */
  getNormalArticle = async (page: number): Promise<PageModel<Article>> => {
    LogUtil.debug(`HomeViewModel: 获取普通文章，页码=${page}`)
    return this.homeRepo.getNormalArticleList(page)
  }

  /**
   * 刷新请求（同时获取 Banner、置顶文章、普通文章）
   * @returns 刷新结果
   */
  public async refreshRequest(): Promise<HomeRefreshResult> {
    this.pageNum = 1
    const banners: Banner[] = await this.homeRepo.getBannerList()
    const hotArticles: Article[] = await this.homeRepo.getHotArticleList()
    const normalArticles: PageModel<Article> = await this.homeRepo.getNormalArticleList(this.pageNum)
    
    return {
      banners: banners,
      hotArticles: hotArticles,
      normalArticles: normalArticles
    }
  }

  /**
   * 加载更多请求
   * @returns 分页文章数据
   */
  public async loadMoreRequest(): Promise<PageModel<Article>> {
    this.pageNum = this.pageNum + 1
    LogUtil.debug(`HomeViewModel: 加载更多，页码=${this.pageNum}`)
    return this.homeRepo.getNormalArticleList(this.pageNum)
  }
}
