import { ContentType } from '../enum/ContentType'
import { TabModel } from '../model/TabModel'
import { Routes } from '../routes/Routes'

@Component
export struct TreeCell {

  @Prop item: TabModel

  build() {
    ListItem() {
      Column() {
        Text(this.item.name)
          .textAlign(TextAlign.Start)
          .padding({left: 12, bottom: 16})

        Flex({ wrap:FlexWrap.Wrap, }){
          ForEach(this.item.children, (item: TabModel) => {
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
                Routes.toTreeDetail({tab: item, contentType: ContentType.tree})
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}