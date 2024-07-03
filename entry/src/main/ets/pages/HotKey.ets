import { BaseListDataSource } from '../model/BaseListDataSource';
import { StatusWeight } from '../views/StatusWeight';
import { HotKeyViewModel } from '../viewModel/HotKeyViewModel';
import { ViewStatus } from '../Enum/ViewStatus';
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { HotKeyModel } from '../model/HotKeyModel';
import { ToastUtil } from '@pura/harmony-utils';
import { Router } from '../router/Router';

@Entry
@Component
struct HotKey {
  @State dataSource: BaseListDataSource<HotKeyModel> = new BaseListDataSource<HotKeyModel>()

  @State status: ViewStatus = ViewStatus.loading

  viewModel = new HotKeyViewModel()

  build() {
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getHotkeyView()
        },
        onRetry: () => {
          console.log("点击了重试按钮")
        },
      })
    }
    .title("热门搜索")
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .height('100%')
    .width('100%')
  }

  @Builder
  getHotkeyView() {
    Row() {
      Column() {
        Flex({ wrap:FlexWrap.Wrap, }){
          ForEach(this.dataSource.originData, (item: HotKeyModel) => {
            Text(item.name)
              .fontColor(Color.White)
              .backgroundColor("#2C86EF")
              .borderRadius(4)
              .fontSize(16)
              .textAlign(TextAlign.Center)
                // 外间距
              .margin({left: 8, right: 8, bottom: 8})
                // 内间距
              .padding(8)
              .onClick(() => {
                ToastUtil.showToast(`点击了话题 id: ${item.id}`)
              })
          })
        }
      }
      .alignSelf(ItemAlign.Start)
      .width('100%')
    }
    .height('100%')
  }

  async aboutToAppear(): Promise<void> {
    let response: AxiosResponse<BaseResponse<HotKeyModel[]>> = await this.viewModel.getHotKey()

    response.data.data.forEach((item) => {
      this.dataSource.addData(item)
    })

    if (response.data.errorCode == 0) {
      if (response.data.data.length == 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }
    } else {
      this.status = ViewStatus.error
    }
  }
}