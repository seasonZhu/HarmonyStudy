import { TabType, TabTypeModel, TabTypeAllCases, getTabModel, } from '../enum/TabType';
import { Home } from './Home';
import { My } from './My';
import { TabScaffold } from './TabScaffold';
import { Tree } from './Tree';
import { ContentType } from '../enum/ContentType';

@Preview
@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  private tabsController = new TabsController();
  
  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      ForEach(TabTypeAllCases, (type: TabType) => {
        this.getPage(type)
      })
    }
    .scrollable(false)
    .vertical(false)
    .barWidth('100%')
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  @Builder
  tabBarItem(model: TabTypeModel) {
    Column({space:4}) {
      Image(this.currentIndex == model.index ? model.selectedImage : model.normalImage)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(model.title)
        .fontColor(this.currentIndex == model.index ? '#1698CE' : '#6B6B6B')
        .fontSize(12)
    }
    .onClick(() => {
      this.currentIndex = model.index;
      this.tabsController.changeIndex(model.index);
    })
  }

  @Builder
  getPage(type: TabType) {
    if (type == TabType.home) {
      TabContent() {
        Home()
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.project) {
      TabContent() {
        TabScaffold({contentType: ContentType.project})
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.publicNumber) {
      TabContent() {
        TabScaffold({contentType: ContentType.publicNumber})
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else if (type == TabType.tree) {
      TabContent() {
        Tree()
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    } else {
      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem(getTabModel(type)))
    }
  }
}