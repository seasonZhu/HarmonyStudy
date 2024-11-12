// [Harmony 状态管理神器 @ObservedV2](https://juejin.cn/post/7391704406327164982)

@ObservedV2
class Person {
  @Trace
  age: number = 100

  son = new Son()
}

@ObservedV2
class Son {
  @Trace
  weight: number = 200
}

@Entry
@Component
export struct ObservedV2TestPage {
  person = new Person()

  build() {
    RelativeContainer() {
      Column({ space: 10 }) {
        Button("person的age" + this.person.age)
          .onClick(() => {
            this.person.age++
          })

        Button("son的weight" + this.person.son.weight)
          .onClick(() => {
            this.person.son.weight++
          })
      }
    }
    .height('100%')
    .width('100%')
  }
}