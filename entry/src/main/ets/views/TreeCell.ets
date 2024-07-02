import { TabModel } from '../model/TabModel'

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
                console.log(`点击了话题 id: ${item.id}`)
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}