import { Home } from './Home';
import { My } from './My';

@Preview
@Entry
@Component
struct Index {
  @State curentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  
  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        Home()
      }
      .tabBar(this.tabBarItem('首页', 0, $r('app.media.home_selected'), $r('app.media.home')))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem('项目', 1, $r('app.media.project_selected'), $r('app.media.project')))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem('公众号', 2, $r('app.media.publicNumber_selected'), $r('app.media.publicNumber')))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem('体系', 3, $r('app.media.tree_selected'), $r('app.media.tree')))

      TabContent() {
        My()
      }
      .tabBar(this.tabBarItem('我的', 4, $r('app.media.my_selected'), $r('app.media.my')))
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
  tabBarItem(title: string, index: number, selectedImg: Resource,
             normalImg: Resource) {
    Column({space:4}) {
      Image(this.curentIndex == index ? selectedImg : normalImg)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title).fontColor(this.curentIndex == index ? '#1698CE' : '#6B6B6B').fontSize(12)
    }
    .onClick(() => {
      this.curentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }
}