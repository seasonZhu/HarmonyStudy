import { TreeDetailInfo } from '../entity/TreeDetailInfo';
import { Routes } from '../routes/Routes';
import { TabsDetail } from './TabsDetail';

@Entry
@Component
struct TreeDetail {

  treeDetailInfo = Routes.getParams() as TreeDetailInfo

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