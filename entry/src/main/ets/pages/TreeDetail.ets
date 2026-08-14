import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { TabsDetail } from './TabsDetail';

@Entry
@Component
struct TreeDetail {

  treeDetailInfo: TreeDetailInfo = { tab: { id: 0, name: '' }, contentType: 0 }

  build() {
    NavDestination() {
      TabsDetail({contentType: this.treeDetailInfo.contentType, tab: this.treeDetailInfo.tab})
    }
    .title(this.treeDetailInfo.tab.name)
    .onReady((context: NavDestinationContext) => {
      this.treeDetailInfo = context.pathInfo.param as TreeDetailInfo
    })
  }
}

@Builder
export function TreeDetailBuilder() {
  TreeDetail()
}