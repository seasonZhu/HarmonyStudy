@Component
export struct Center {

  @BuilderParam body: () => void

  build() {
    Row() {
      Column() {
        this.body()
      }
      .width('100%')
    }
    .height('100%')
  }
}