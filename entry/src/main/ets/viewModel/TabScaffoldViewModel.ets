import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../httpRequest/Provider';
import { TabModel } from '../model/TabModel';
import { ContentType } from '../enum/ContentType';
import { ApiConstants } from '../constants/ApiConstants';

export class TabScaffoldViewModel {

  private contentType: ContentType

  constructor(contentType: ContentType) {
    this.contentType = contentType
  }

  getTabs = (): Promise<AxiosResponse<BaseResponse<TabModel[]>>> => {
    let api: string
    switch (this.contentType) {
      case ContentType.project:
        api = ApiConstants.PROJECT_TREE
        break
      case ContentType.publicNumber:
        api = ApiConstants.WX_ARTICLE_CHAPTERS
        break
      case ContentType.tree:
        api = ApiConstants.TREE
        break
    }

    return httpClient.get(api)
  }
}