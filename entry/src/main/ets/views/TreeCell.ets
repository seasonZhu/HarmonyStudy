import { RandomUtil } from '@pura/harmony-utils'
import { ContentType } from '../enum/ContentType'
import { TabModel } from '../model/TabModel'
import { Router } from '../router/Router'

@Component
export struct TreeCell {

  @Prop item: TabModel

  build() {
    ListItem() {
      Column() {
        Text(this.item.name)
          .textAlign(TextAlign.Start)
          .padding({left: 8, bottom: 20})

        Flex({ wrap:FlexWrap.Wrap, }){
          ForEach(this.item.children, (item: TabModel) => {
            Text(item.name)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.app_blue'))
              .borderRadius(4)
              .fontSize(16)
              .textAlign(TextAlign.Center)
                // 外间距
              .margin({left: 8, right: 8, bottom: 8})
                // 内间距
              .padding(8)
              .onClick(() => {
                Router.toTreeDetail({tab: item, contentType: ContentType.tree})
              })
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  getRandomString(): string {
    let color = RandomUtil.getRandomColor()
    if (color === '#FFFFFF') {
      return '#2C86EF'
    } else {
      return color
    }
  }
}