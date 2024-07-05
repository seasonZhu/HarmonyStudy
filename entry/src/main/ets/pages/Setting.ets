import { ToastUtil } from '@pura/harmony-utils/src/main/ets/action/ToastUtil';
import { KeywordInfo } from '../entity/KeywordInfo';
import { Routes } from '../routes/Routes';

@Entry
@Component
struct Setting {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let info: KeywordInfo = { k: "我回去了啦" }
            Routes.back({params: info, url: ""})
          })
      }
      .width('100%')
    }
    .height('100%')
  }

  aboutToAppear(): void {

  }

  aboutToDisappear(): void {

  }
}