import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import httpClient from '../httpRequest/Provider';
import { ContentType } from '../enum/ContentType';
import { ScrollActionType } from '../enum/ScrollActionType';
import { TabModel } from '../model/TabModel';
import { ApiConstants } from '../constants/ApiConstants';

export class TabsDetailViewModel {

  private pageNum = 0

  private contentType: ContentType

  private tab: TabModel

  constructor(contentType: ContentType, tab: TabModel) {
    this.contentType = contentType
    this.tab = tab
  }

  getTabsDetailList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      if (this.contentType == ContentType.tree) {
        this.pageNum = 0
      } else {
        this.pageNum = 1
      }
    } else {
      this.pageNum = this.pageNum + 1
    }

    let api: string
    switch (this.contentType) {
      case ContentType.project:
        api = ApiConstants.projectList(this.pageNum, this.tab.id ?? 0)
        break
      case ContentType.publicNumber:
        api = ApiConstants.wxArticleList(this.tab.id ?? 0, this.pageNum)
        break
      case ContentType.tree:
        api = ApiConstants.treeDetailList(this.pageNum, this.tab.id ?? 0)
        break
    }
    return httpClient.get(api)
  }
}