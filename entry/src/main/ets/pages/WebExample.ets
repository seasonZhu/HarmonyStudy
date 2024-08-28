import { webview } from '@kit.ArkWeb';

class testClass {
  constructor() {
  }

  test(): string {
    return 'ArkTS Hello World!';
  }
}

/*
 * 应用侧调用前端页面函数
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/web-in-app-frontend-page-function-invoking-V5
 * 前端页面调用应用侧函数
 * https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/web-in-page-app-function-invoking-V5
 * */
@Entry
@Component
export struct WebExample {
  webviewController: webview.WebviewController = new webview.WebviewController();
  // 声明需要注册的对象
  @State testObj: testClass = new testClass();

  build() {
    Navigation() {
      Column() {
        // Web组件加载本地index.html页面
        Web({ src: $rawfile('index.html'), controller: this.webviewController})
          // 将对象注入到web端
          .javaScriptProxy({
            object: this.testObj,
            name: "testObjName",
            methodList: ["test"],
            controller: this.webviewController
          })
      }
    }
    .title("Web与鸿蒙原生交互")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }
}