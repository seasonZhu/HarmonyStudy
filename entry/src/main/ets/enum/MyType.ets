import { PagesConstant } from '../router/PagesConstant';

export enum MyType {
  header,
  ranking,
  myCoin,
  myCollect,
  webExample,
  webComponent,
  uniApp,
  setting,
}

export let allMyTypeCases = [MyType.header, MyType.ranking, MyType.myCoin, MyType.myCollect, MyType.webExample, MyType.webComponent, MyType.uniApp, MyType.setting]

export function getPathByMyType(type: MyType): PagesConstant {
  switch (type) {
    case MyType.header:
      return ""
    case MyType.ranking:
      return PagesConstant.Rank
    case MyType.myCoin:
      return PagesConstant.MyCoin
    case MyType.myCollect:
      return PagesConstant.MyCollect
    case MyType.webExample:
      return PagesConstant.WebExample
    case MyType.webComponent:
      return PagesConstant.WebComponent
    case MyType.uniApp:
      return PagesConstant.ObservedV2TestPage
    case MyType.setting:
      return PagesConstant.Setting
  }
}

export function getTitleByMyType(type: MyType): string {
  switch (type) {
    case MyType.header:
      return ""
    case MyType.ranking:
      return "积分排名"
    case MyType.myCoin:
      return "我的积分"
    case MyType.myCollect:
      return "我的收藏"
    case MyType.webExample:
      return "Web与鸿蒙原生交互"
    case MyType.webComponent:
      return "Web与鸿蒙通过Port交互"
    case MyType.uniApp:
      return "跳转UniApp"
    case MyType.setting:
      return "设置"
  }
}