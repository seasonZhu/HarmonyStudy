import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { TabsDetail } from './TabsDetail';
import { navPathStack } from '../router/navPathStack';

@Entry
@Component
struct TreeDetail {

  treeDetailInfo: TreeDetailInfo = { tab: { id: 0, name: '' }, contentType: 0 }

  aboutToAppear(): void {
    let params = navPathStack.getParamByName('TreeDetail') as TreeDetailInfo[]
    if (params && params.length > 0) {
      this.treeDetailInfo = params[0]
    }
  }

  build() {
    NavDestination() {
      TabsDetail({contentType: this.treeDetailInfo.contentType, tab: this.treeDetailInfo.tab})
    }
    .title(this.treeDetailInfo.tab.name)
    .onReady((context: NavDestinationContext) => {
      let params = context.pathStack.getParamByName('TreeDetail') as TreeDetailInfo[]
      if (params && params.length > 0) {
        this.treeDetailInfo = params[0]
      }
    })
  }
}

@Builder
export function TreeDetailBuilder() {
  TreeDetail()
}