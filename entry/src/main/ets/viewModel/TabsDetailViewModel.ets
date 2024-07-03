import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { Article } from '../model/Article';
import { PageModel } from '../model/PageModel';
import provider from '../HttpRequest/Provider';
import { ContentType } from '../enum/ContentType';
import { ScrollActionType } from '../Enum/ScrollActionType';
import { TabModel } from '../model/TabModel';

export class TabsDetailViewModel {

  private pageNum = 1

  private contentType: ContentType

  private tab: TabModel

  constructor(contentType: ContentType, tab: TabModel) {
    this.contentType = contentType
    this.tab = tab
  }

  getTabsDetailList = (type: ScrollActionType): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
    } else {
      this.pageNum = this.pageNum + 1
    }

    let pageString = this.pageNum.toString()
    let api: string
    switch (this.contentType) {
      case ContentType.project:
        api = "project/list/" + pageString + "/json" + "?cid=" + this.tab.id?.toString()
        break
      case ContentType.publicNumber:
        api = "wxarticle/list/" + this.tab.id?.toString() + "/" + pageString + "/json"
        break
    }
    return provider.get<BaseResponse<PageModel<Article>>, AxiosResponse<BaseResponse<PageModel<Article>>>>(api)
  }
}