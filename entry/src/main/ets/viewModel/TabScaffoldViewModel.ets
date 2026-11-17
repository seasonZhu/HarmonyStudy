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
    const tabs = await this.tabScaffoldRepo.getTabs(this.contentType)
    // 体系页只展示有子项的大分类，统一覆盖首次加载、刷新和失败重试。
    if (this.contentType === ContentType.tree) {
      return tabs.filter((tab: TabModel) => (tab.children?.length ?? 0) > 0)
    }
    return tabs
  }
}
