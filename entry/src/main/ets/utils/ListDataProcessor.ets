import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ViewStatus } from '../enum/ViewStatus';
import { ScrollActionType } from '../enum/ScrollActionType';
import { PageModel } from '../model/PageModel';

/**
 * 列表数据处理器
 * 提供统一的数据处理逻辑，避免在多个页面中重复编写相似的代码
 */
export class ListDataProcessor {
  /**
   * 处理基础列表数据响应（带分页）
   * @param dataSource 数据源
   * @param response 响应数据
   * @param scrollActionType 滚动操作类型
   * @param updateStatusCallback 状态更新回调
   */
  static processPagedListData<T>(
    dataSource: BaseListDataSource<T>,
    response: AxiosResponse<BaseResponse<PageModel<T>>>,
    scrollActionType: ScrollActionType,
    updateStatusCallback: (status: ViewStatus) => void
  ): void {
    if (scrollActionType === ScrollActionType.refresh) {
      dataSource.removeAll()

      const pageData = response.data.data
      pageData.datas.forEach((item: T) => {
        dataSource.addData(item)
      })

      if (dataSource.originData.length === 0) {
        updateStatusCallback(ViewStatus.empty)
      } else {
        updateStatusCallback(ViewStatus.success)
      }
    } else {
      const pageData = response.data.data
      pageData.datas.forEach((item: T) => {
        dataSource.addData(item)
      })
      updateStatusCallback(ViewStatus.success)
    }
  }

  /**
   * 处理基础列表数据响应（数组）
   * @param dataSource 数据源
   * @param response 响应数据
   * @param scrollActionType 滚动操作类型
   * @param updateStatusCallback 状态更新回调
   */
  static processArrayListData<T>(
    dataSource: BaseListDataSource<T>,
    response: AxiosResponse<BaseResponse<T[]>>,
    scrollActionType: ScrollActionType,
    updateStatusCallback: (status: ViewStatus) => void
  ): void {
    if (scrollActionType === ScrollActionType.refresh) {
      dataSource.removeAll()

      const data = response.data.data
      data.forEach((item: T) => {
        dataSource.addData(item)
      })

      if (dataSource.originData.length === 0) {
        updateStatusCallback(ViewStatus.empty)
      } else {
        updateStatusCallback(ViewStatus.success)
      }
    } else {
      const data = response.data.data
      data.forEach((item: T) => {
        dataSource.addData(item)
      })
      updateStatusCallback(ViewStatus.success)
    }
  }

  /**
   * 处理混合数据响应（如首页的 Banner + Article）
   * @param bannerDataSource Banner 数据源
   * @param listDataSource 列表数据源
   * @param results 多个响应数据
   * @param scrollActionType 滚动操作类型
   * @param updateStatusCallback 状态更新回调
   * @param mergeArticlesCallback 合并文章数据的回调（可选）
   */
  static processMixedRefresh<TBanner, TArticle>(
    bannerDataSource: BaseListDataSource<TBanner>,
    listDataSource: BaseListDataSource<TArticle>,
    bannerResponse: AxiosResponse<BaseResponse<TBanner[]>>,
    hotArticleResponse: AxiosResponse<BaseResponse<TArticle[]>>,
    normalArticleResponse: AxiosResponse<BaseResponse<PageModel<TArticle>>>,
    updateStatusCallback: (status: ViewStatus) => void,
    mergeArticlesCallback?: (hotArticles: TArticle[], normalArticles: TArticle[]) => TArticle[]
  ): void {
    bannerDataSource.removeAll()
    listDataSource.removeAll()

    const responseBanners = bannerResponse.data
    const responseHotArticle = hotArticleResponse.data
    const responseNormalArticle = normalArticleResponse.data

    let allArticle: TArticle[]
    if (mergeArticlesCallback) {
      allArticle = mergeArticlesCallback(responseHotArticle.data, responseNormalArticle.data.datas)
    } else {
      allArticle = [...responseHotArticle.data, ...responseNormalArticle.data.datas]
    }

    responseBanners.data.forEach((item: TBanner) => {
      bannerDataSource.addData(item)
    })

    allArticle.forEach((item: TArticle) => {
      listDataSource.addData(item)
    })

    if (listDataSource.originData.length === 0) {
      updateStatusCallback(ViewStatus.empty)
    } else {
      updateStatusCallback(ViewStatus.success)
    }
  }

  static processMixedLoadMore<TArticle>(
    listDataSource: BaseListDataSource<TArticle>,
    normalArticleResponse: AxiosResponse<BaseResponse<PageModel<TArticle>>>,
    updateStatusCallback: (status: ViewStatus) => void
  ): void {
    const pageData = normalArticleResponse.data.data
    pageData.datas.forEach((item: TArticle) => {
      listDataSource.addData(item)
    })
    updateStatusCallback(ViewStatus.success)
  }
}
