import { router } from '@kit.ArkUI'

interface RouterExampleParams {
  message: string
}

// 路径入口登记在 main_pages.json，命名入口通过动态 import 加载。
// 此页面属于 Router 页面栈，使用 router.back 返回承载示例入口的 Index。
@Entry({ routeName: 'RouterPageExample' })
@Component
struct RouterPageExample {
  @State message: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as RouterExampleParams
    this.message = params?.message ?? '未传入参数'
  }

  build() {
    Column({ space: 20 }) {
      Text(this.message)
      Button('返回路由示例').onClick(() => {
        router.back()
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
