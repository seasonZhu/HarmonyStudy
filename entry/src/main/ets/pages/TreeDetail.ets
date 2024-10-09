import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { Router } from '../routes/Router';
import { TabsDetail } from './TabsDetail';

@Entry
@Component
struct TreeDetail {

  treeDetailInfo = Router.getParams() as TreeDetailInfo

  build() {
    Navigation() {
      TabsDetail({contentType: this.treeDetailInfo.contentType, tab: this.treeDetailInfo.tab})
    }
    .title(this.treeDetailInfo.tab.name)
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }
}