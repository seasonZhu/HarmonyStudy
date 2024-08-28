import { webview } from '@kit.ArkWeb';
import { JSONUtil } from '@pura/harmony-utils';
import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil';

class JavaScriptInterface {
  constructor() {}

  showToast(): string {
    ToastUtil.showToast("ArkTS Hello World!")
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
  @State javaScriptObject: JavaScriptInterface = new JavaScriptInterface();

  build() {
    Navigation() {
      Column() {
        // Web组件加载本地index.html页面
        Web({ src: $rawfile('index.html'), controller: this.webviewController})
          // 将对象注入到web端，javaScriptProxy可以不停的链式调用
          .javaScriptProxy({
            /// 原生侧传入的对象
            object: this.javaScriptObject,
            /// 在js侧对象的名称
            name: "javaScriptObject",
            /// 方法名
            methodList: ["showToast"],
            controller: this.webviewController
          })
      }
    }
    .title("Web与鸿蒙原生交互")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
    .menus(this.getButton())
  }

  @Builder
  getButton() {
    Button('runJavaScript')
      .onClick(async  () => {
        let map: Record<string, string> = {
          "type": "commit",
          "message": "this is a message from Flutter"
        };

        let jsonString = JSONUtil.beanToJsonStr(map)
        /// 这种交互，不支持原生向JS传递参数
        //let javaScriptCallbackResult = this.webviewController.runJavaScript(`sendMessageToDiscussList(${jsonString})`);

        // 前端页面函数无参时，将param删除。
        let javaScriptCallbackResult = await this.webviewController.runJavaScript(`harmonyOSCallJS()`)
        ToastUtil.showToast(javaScriptCallbackResult)
      })
  }
}