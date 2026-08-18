import { TabScaffoldRepository } from '../repository/TabScaffoldRepository'
import { TabModel } from '../model/TabModel'
import { ContentType } from '../enum/ContentType'
import { LogUtil } from '@pura/harmony-utils'

/**
 * 标签脚手架视图模型
 * @description 处理标签列表的业务逻辑（项目、公众号、体系）
 */
export class TabScaffoldViewModel {
  private tabScaffoldRepo = new TabScaffoldRepository()
  private contentType: ContentType

  constructor(contentType: ContentType) {
    this.contentType = contentType
  }

  /**
   * 获取标签列表
   * @returns 标签列表
   */
  getTabs = async (): Promise<TabModel[]> => {
    LogUtil.debug(`TabScaffoldViewModel: 获取标签列表，类型=${this.contentType}`)
    return this.tabScaffoldRepo.getTabs(this.contentType)
  }
}
