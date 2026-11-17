import { router } from '@kit.ArkUI'
import { RouteConstant, importHeadFile } from 'librarySDK'
import { RouterName } from '../router/RouterName'
import { navPathStack } from '../router/navPathStack'

// App 内也可以像 HAR 模块一样，通过模块路径动态加载命名路由页面。
// 动态导入与目标页的 @Entry({ routeName: 'RouterPageExample' }) 配合完成注册。
// 例如 import('entry/ets/pages/HotKey') 还需要 HotKey 声明对应 routeName。
// 本示例使用专用页面演示完整流程，业务 HotKey 继续通过 routerMap 注册。
import('entry/ets/pages/RouterPageExample')

/**
 * 路由方式清单
 * 1. 路径路由依赖 main_pages.json，使用 Router 页面栈。
 * 2. 命名路由依赖 @Entry 的 routeName 和动态导入，也使用 Router 页面栈。
 * 3. 跨模块命名路由由 librarySDK 的 HeadFile 导入模块页面。
 * 4. 业务使用 Navigation + NavPathStack，目标页面由 routerMap 注册。
 * 5. pushPathByName 是 NavPathStack 的按名称入栈方法，与 pushNamedRoute 分属不同栈。
 * routerMap 将名称映射到导出的 Builder，NavPathStack 负责入栈、出栈和参数。
 */
@Component
struct RoutingExamples {
  @State result: string = '尚未收到返回值'

  @Builder
  routeRow(title: string) {
    Row({ space: 12 }) {
      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(20)
        .fontColor([$r('app.color.app_blue')])
      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(14)
        .fontColor([$r('app.color.text_secondary')])
    }
    .width('100%')
    .constraintSize({ minHeight: 64 })
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
  }

  build() {
    NavDestination() {
      List({ space: 12 }) {
        ListItem() {
          this.routeRow('路径路由')
        }
          .onClick(() => {
            // 独立 Router 页面使用 router.getParams 接收参数，router.back 返回。
            router.pushUrl({ url: 'pages/RouterPageExample', params: { message: '来自路径路由' } })
          })
        ListItem() {
          this.routeRow('命名路由')
        }
          .onClick(() => {
            router.pushNamedRoute({ name: 'RouterPageExample', params: { message: '来自命名路由' } })
          })
        ListItem() {
          this.routeRow('跨模块命名路由')
        }
          .onClick(() => {
            // 保留模块页面注册加载，模块返回时恢复当前 Navigation 及其栈。
            //importHeadFile()
            router.pushNamedRoute({ name: RouteConstant.mainPage })
          })
        ListItem() {
          this.routeRow('NavPathStack 基础跳转与动态注册，顺传0过去，但是没有取逆传值')
        }
          .onClick(() => {
            // routerMap 查找 NavPathStackTestBuilder 并创建 NavDestination。
            navPathStack.pushPath({ name: RouterName.NavPathStackTest, param: 0 })
          })
        ListItem() {
          this.routeRow('按名称入栈、顺传与返回回传，顺传0过去，同时取逆传值')
        }
          .onClick(() => {
            // 目标页 onReady 从 context.pathInfo.param 接收，pop(result) 触发回调。
            navPathStack.pushPathByName(RouterName.NavPathStackTest, 100, (info: PopInfo) => {
              this.result = '返回值为 ' + String(info.result)
            })
          })
        ListItem() {
          Text(this.result)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .padding(16)
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title('路由示例')
    .backgroundColor($r('app.color.bg_grey'))
  }
}

@Builder
export function RoutingExamplesBuilder() {
  RoutingExamples()
}
