import { Home } from '../pages/Home'
import { My } from '../pages/My'

export enum TabType {
  home,
  project,
  publicNumber,
  tree,
  my,
}

export let TabTypeAllCases = [TabType.home, TabType.project, TabType.publicNumber, TabType.tree, TabType.my]

export interface TabTypeModel {
  title: string
  index: number
  selectedImage: Resource
  normalImage: Resource
}

export function getTabModel(type: TabType): TabTypeModel {
  switch (type) {
    case TabType.home:
      let model0: TabTypeModel = {
        title: "首页",
        index: type,
        selectedImage: $r('app.media.home_selected'),
        normalImage: $r('app.media.home')
      }
      return model0
    case TabType.project:
      let model1: TabTypeModel = {
        title: "项目",
        index: type,
        selectedImage: $r('app.media.project_selected'),
        normalImage: $r('app.media.project')
      }
      return model1
    case TabType.publicNumber:
      let model2: TabTypeModel = {
        title: "公众号",
        index: type,
        selectedImage: $r('app.media.publicNumber_selected'),
        normalImage: $r('app.media.publicNumber')
      }
      return model2
    case TabType.tree:
      let model3: TabTypeModel = {
        title: "体系",
        index: type,
        selectedImage: $r('app.media.tree_selected'),
        normalImage: $r('app.media.tree')
      }
      return model3
    case TabType.my:
      let model4: TabTypeModel = {
        title: "我的",
        index: type,
        selectedImage: $r('app.media.my_selected'),
        normalImage: $r('app.media.my')
      }
      return model4
  }
}

// export function getPage(type: TabType) {
//   switch (type) {
//     case TabType.home:
//       return Home()
//     case TabType.project:
//       return My()
//     case TabType.publicNumber:
//       return Home()
//     case TabType.tree:
//       return Home()
//     case TabType.my:
//       return Home()
//   }
// }