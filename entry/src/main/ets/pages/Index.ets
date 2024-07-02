import { TabType, TabTypeModel, TabTypeAllCases, getTabModel } from '../enum/TabType';
import { Home } from './Home';
import { My } from './My';
import { Tree } from './Tree';

@Preview
@Entry
@Component
struct Index {
  @State curentIndex: number = 0

  private tabsController = new TabsController();
  
  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Home()
      }
      .tabBar(this.tabBarItem(getTabModel(TabType.home)))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem(getTabModel(TabType.project)))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem(getTabModel(TabType.publicNumber)))

      TabContent() {
        Tree()
      }
      .tabBar(this.tabBarItem(getTabModel(TabType.tree)))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem(getTabModel(TabType.my)))
    }
    .vertical(false)
    .barWidth('100%')
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.curentIndex = index;
    })
  }

  @Builder
  tabBarItem(model: TabTypeModel) {
    Column({space:4}) {
      Image(this.curentIndex == model.index ? model.selectedImage : model.normalImage)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(model.title).fontColor(this.curentIndex == model.index ? '#1698CE' : '#6B6B6B').fontSize(12)
    }
    .onClick(() => {
      this.curentIndex = model.index;
      this.tabsController.changeIndex(model.index);
    })
  }
}