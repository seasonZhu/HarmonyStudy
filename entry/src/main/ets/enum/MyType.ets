import { AppConfig } from '../constants/AppConfig'
import { PagesConstant } from '../router/PagesConstant';

export enum MyType {
  header,
  ranking,
  myCoin,
  myCollect,
  webExample,
  webComponent,
  uniApp,
  environmentSwitch,
  routingExamples,
  uniAppMiniProgram,
  setting,
}

export let allMyTypeCases = [MyType.header, MyType.ranking, MyType.myCoin, MyType.myCollect, MyType.webExample, MyType.webComponent, MyType.uniApp, MyType.environmentSwitch, MyType.routingExamples, MyType.uniAppMiniProgram, MyType.setting]

export function getVisibleMyTypes(isAppTest: boolean = AppConfig.IS_APP_TEST): MyType[] {
  const developmentTypes: MyType[] = [
    MyType.webExample, MyType.webComponent, MyType.uniApp, MyType.environmentSwitch, MyType.routingExamples
  ]
  return allMyTypeCases.filter((type: MyType) => !isAppTest || !developmentTypes.includes(type))
}

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
      return PagesConstant.ObservedV2Test
    case MyType.environmentSwitch:
      return PagesConstant.EnvironmentSwitch
    case MyType.routingExamples:
      return ""
    case MyType.uniAppMiniProgram:
      return ""
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
      return "用例演示"
    case MyType.environmentSwitch:
      return "环境切换"
    case MyType.routingExamples:
      return "路由示例"
    case MyType.uniAppMiniProgram:
      return "UniApp 小程序"
    case MyType.setting:
      return "设置"
  }
}

export function getIconByMyType(type: MyType): Resource {
  switch (type) {
    case MyType.header:
      return $r('sys.symbol.chevron_right')
    case MyType.ranking:
      return $r('sys.symbol.list_bullet')
    case MyType.myCoin:
      return $r('sys.symbol.coins')
    case MyType.myCollect:
      return $r('sys.symbol.star')
    case MyType.webExample:
      return $r('sys.symbol.website')
    case MyType.webComponent:
      return $r('sys.symbol.website')
    case MyType.uniApp:
      return $r('sys.symbol.square_grid_2x2')
    case MyType.environmentSwitch:
      return $r('sys.symbol.arrow_clockwise')
    case MyType.routingExamples:
      return $r('sys.symbol.route')
    case MyType.uniAppMiniProgram:
      return $r('sys.symbol.application_relay')
    case MyType.setting:
      return $r('sys.symbol.gearshape')
  }
}