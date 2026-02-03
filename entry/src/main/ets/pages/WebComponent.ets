import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@pura/harmony-utils';
import { RouterName } from '../router/RouterName'

@Entry({routeName: RouterName.WebComponent})
@Component
struct WebComponent {
  controller: webview.WebviewController = new webview.WebviewController();
  ports: webview.WebMessagePort[] = [];
  @State sendFromEts: string = 'Send this message from ets to HTML';
  @State receivedFromHtml: string = 'Display received message send from HTML';

  build() {
    Navigation() {
      Column() {
        // 展示接收到的来自HTML的内容
        Text(this.receivedFromHtml)
        // 输入框的内容发送到HTML
        TextInput({ placeholder: 'Send this message from ets to HTML' })
          .onChange((value: string) => {
            this.sendFromEts = value;
          })

        // 该内容可以放在onPageEnd生命周期中调用。
        Button('postMessage')
          .onClick(() => {
            try {
              // 1、创建两个消息端口。
              this.ports = this.controller.createWebMessagePorts();
              // 2、在应用侧的消息端口(如端口1)上注册回调事件。
              this.ports[1].onMessageEvent((result: webview.WebMessage) => {
                let msg = 'Got msg from HTML:';
                if (typeof (result) === 'string') {
                  LogUtil.debug(`received string message from html5, string is: ${result}`);
                  msg = msg + result;
                } else if (typeof (result) === 'object') {
                  if (result instanceof ArrayBuffer) {
                    LogUtil.debug(`received arraybuffer from html5, length is: ${result.byteLength}`);
                    msg = msg + 'length is ' + result.byteLength;
                  } else {
                    LogUtil.debug('not support');
                  }
                } else {
                  LogUtil.debug('not support');
                }
                this.receivedFromHtml = msg;
              })
              // 3、将另一个消息端口(如端口0)发送到HTML侧，由HTML侧保存并使用。
              this.controller.postMessage('__init_port__', [this.ports[0]], '*');
            } catch (error) {
              LogUtil.debug(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })

        // 4、使用应用侧的端口给另一个已经发送到html的端口发送消息。
        Button('SendDataToHTML')
          .onClick(() => {
            try {
              if (this.ports && this.ports[1]) {
                this.ports[1].postMessageEvent(this.sendFromEts);
              } else {
                LogUtil.debug(`ports is null, Please initialize first`);
              }
            } catch (error) {
              LogUtil.debug(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
        Web({ src: $rawfile('portSendMessage.html'), controller: this.controller })
      }
    }
    .title("Web与鸿蒙通过Port交互")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }
}