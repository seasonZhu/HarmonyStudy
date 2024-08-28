import { PagesConstant } from '../routes/Routes';

export enum MyType {
  header,
  ranking,
  myCoin,
  myCollect,
  webExample,
  setting,
}

export let allMyTypeCases = [MyType.header, MyType.ranking, MyType.myCoin, MyType.myCollect, MyType.webExample, MyType.setting]

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
    case MyType.setting:
      return "设置"
  }
}