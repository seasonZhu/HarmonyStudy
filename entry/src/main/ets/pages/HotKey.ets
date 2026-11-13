import { BaseListDataSource } from '../model/BaseListDataSource';
import { StatusWeight } from '../views/StatusWeight';
import { HotKeyViewModel } from '../viewModel/HotKeyViewModel';
import { ViewStatus } from '../enum/ViewStatus';
import { HotKeyModel } from '../model/HotKeyModel';
import { ToastUtil, LogUtil } from '@pura/harmony-utils';
import { RouterName } from '../router/RouterName'
import { KeywordInfo } from '../entity/KeywordInfo';
import { CaptureTool } from 'utils';
import { navPathStack } from '../router/navPathStack';

@Entry({routeName: RouterName.HotKey})
@ComponentV2
struct HotKey {
  @Local dataSource: BaseListDataSource<HotKeyModel> = new BaseListDataSource<HotKeyModel>()

  @Local status: ViewStatus = ViewStatus.loading

  viewModel = new HotKeyViewModel()

  inputController = new TextInputController()

  build() {
    NavDestination() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getHotkeyView()
        },
        onRetry: () => {
          this.reloadData()
        },
      })
    }
    .title(this.getTextInput())
  }

  @Builder
  getHotkeyView() {
    Row() {
      Column() {
        Flex({ wrap:FlexWrap.Wrap, }){
          ForEach(this.dataSource.originData, (item: HotKeyModel) => {
            Text(item.name)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.app_blue'))
              .borderRadius(4)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .margin({left: 8, right: 8, bottom: 8})
              .padding(8)
              .onClick(() => {
                let keywordInfo: KeywordInfo = {
                  k: item.name
                }
                navPathStack.pushPath({ name: 'SearchResult', param: keywordInfo })
              })
          })

          SaveButton({
            icon: SaveIconStyle.FULL_FILLED,
            text: SaveDescription.SAVE_IMAGE,
            buttonType: ButtonType.Normal
          })
            .fontColor(Color.White)
            .backgroundColor($r('app.color.app_blue'))
            .borderRadius(4)
            .fontSize(16)
            .padding(8)
            .onClick((event, result) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                CaptureTool.saveImage("HotKey")
              }
            })
        }
      }
      .alignSelf(ItemAlign.Start)
      .width('100%')
    }
    .height('100%')
    .padding({ top: 8 })
    .id("HotKey")
  }

  @Builder
  getTextInput() {
    TextInput({placeholder: "搜索关键词", controller: this.inputController})
      .enterKeyType(EnterKeyType.Search)
      .margin({ top: 8, left: 16, right: 16 })
      .onSubmit((_enterKey: EnterKeyType, event: SubmitEvent) => {
        let keyword = event.text
        if (keyword.length != 0) {
          let keywordInfo: KeywordInfo = {
            k: keyword
          }
          navPathStack.pushPath({ name: 'SearchResult', param: keywordInfo })
        } else {
          ToastUtil.showToast($r('app.string.search_keyword_empty'))
        }
      })
  }

  async aboutToAppear(): Promise<void> {
    await this.reloadData()
  }

  private async reloadData(): Promise<void> {
    try {
      const hotKeys: HotKeyModel[] = await this.viewModel.getHotKey()
      
      this.dataSource.refreshData(hotKeys)
      
      if (hotKeys.length === 0) {
        this.status = ViewStatus.empty
      } else {
        this.status = ViewStatus.success
      }
    } catch (error) {
      LogUtil.error("HotKey load error: " + JSON.stringify(error))
      this.status = ViewStatus.error
    }
  }

  aboutToDisappear(): void {
    this.inputController.stopEditing()
  }
}

@Builder
export function HotKeyBuilder() {
  HotKey()
}
