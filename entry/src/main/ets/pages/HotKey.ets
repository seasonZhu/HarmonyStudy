import { BaseListDataSource } from '../model/BaseListDataSource';
import { StatusWeight } from '../views/StatusWeight';
import { HotKeyViewModel } from '../viewModel/HotKeyViewModel';
import { ViewStatus } from '../Enum/ViewStatus';
import { AxiosResponse } from '@ohos/axios';
import { BaseResponse } from '../model/BaseResponse';
import { HotKeyModel } from '../model/HotKeyModel';
import { KeyboardUtil, ToastUtil, LogUtil } from '@pura/harmony-utils';
import { Routes } from '../routes/Routes';
import { KeywordInfo } from '../entity/KeywordInfo';

@Entry
@Component
struct HotKey {
  @State dataSource: BaseListDataSource<HotKeyModel> = new BaseListDataSource<HotKeyModel>()

  @State status: ViewStatus = ViewStatus.loading

  viewModel = new HotKeyViewModel()

  inputController = new TextInputController()

  build() {
    Navigation() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getHotkeyView()
        },
        onRetry: () => {
          LogUtil.debug("点击了重试按钮")
        },
      })
    }
    .title(this.getTextInput())
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
                let keywordInfo: KeywordInfo = {
                  k: item.name
                }
                Routes.toSearchResult(keywordInfo)
              })
          })
        }
      }
      .alignSelf(ItemAlign.Start)
      .width('100%')
    }
    .height('100%')
    .padding({ top: 8 })
  }

  @Builder
  getTextInput() {
    TextInput({placeholder: "搜索关键词", controller: this.inputController})
      .enterKeyType(EnterKeyType.Search)
      .margin({ right: 16 })
      .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
        let keyword = event.text
        if (keyword.length != 0) {
          let keywordInfo: KeywordInfo = {
            k: keyword
          }
          Routes.toSearchResult(keywordInfo)
        } else {
          ToastUtil.showToast("搜索词不能为空")
        }
      })
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

  aboutToDisappear(): void {
    this.inputController.stopEditing()
  }
}