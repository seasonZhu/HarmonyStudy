import { webview } from '@kit.ArkWeb';
import { JSONUtil, DateUtil, FileUtil,ImageUtil,LogUtil,PickerUtil,ToastUtil} from '@pura/harmony-utils';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import axios from '@ohos/axios'
import { AxiosResponse } from '@ohos/axios';
import { AxiosError } from '@ohos/axios';

class JavaScriptInterface {
  constructor() {}

  showToast(): string {
    ToastUtil.showToast("ArkTS Hello World!")
    return 'ArkTS Hello World!';
  }

  showMessage(message: string) {
    ToastUtil.showToast("ArkTS Hello World!" + message)
    return 'ArkTS Hello World!';
  }

  /// 'https://evfile.dna-nev.com.cn/dna-app/preprod/20231129/da637ae245fa49ecb8f10c78dbdf8c88.jpg?x-oss-process=image/quality,q_80'
  /// 前端下载图片事件
  downloadImage(url: string) {
    LogUtil.info("test ", "触发了js的保存图片")
    axios({
      url: url,
      method: 'get',
    }).then( async (res: AxiosResponse)=>{
      LogUtil.info("test ", JSON.stringify(res.data))
      let imageData = res.data as ArrayBuffer
      let imageSource: image.ImageSource = image.createImageSource(imageData)
      let pixelMap = await imageSource.createPixelMap()
      let filePath = await ImageUtil.savePixelMap(pixelMap, FileUtil.getFilesDirPath(""), "download.png")
      let imgName = `download_${DateUtil.getTodayTime()}.png`;
      PickerUtil.savePhoto([imgName]).then(async (uris) => {
        let uri = uris[0];
        let file = FileUtil.openSync(uri);
        FileUtil.copyFile(filePath, file.fd).then(() => {
          ToastUtil.showToast("图片保存成功");
        })
      }).catch((err: BusinessError) => {
        LogUtil.info("test ", `调用保存图片，异常：\n${JSON.stringify(err)}`)
      })
    }).catch((error: AxiosError)=>{
      LogUtil.info("error:" + JSON.stringify(error));
    })
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
            methodList: ["showMessage", "downloadImage"],
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