import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import httpClient from '../HttpRequest/Provider';
import { TabModel } from '../model/TabModel';
import { ContentType } from '../enum/ContentType';

export class TabScaffoldViewModel {

  private contentType: ContentType

  constructor(contentType: ContentType) {
    this.contentType = contentType
  }

  getTabs = (): Promise<AxiosResponse<BaseResponse<TabModel[]>>> => {
    let api: string
    switch (this.contentType) {
      case ContentType.project:
        api = "project/tree/json"
        break
      case ContentType.publicNumber:
        api = "wxarticle/chapters/json"
        break
      case ContentType.tree:
        api = "tree/json"
        break
    }

    return httpClient.get<BaseResponse<TabModel[]>>(api)
  }
}