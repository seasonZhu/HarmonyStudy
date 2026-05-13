// 动画容器组件
@ComponentV2
export struct Skeleton {
  @Local opacityValue: number = 1

  @BuilderParam
  default: () => void = this.defaultBuilder

  @Builder defaultBuilder () {
    Text('我是默认结构')
  }

  build() {
    Row({ space: 15 }) {
      // 挖个坑: 将来使用 HcSkeleton 的组件, 传入内容就会在这里渲染
      // 外面包了一层动画
      this.default()
    }
    .opacity(this.opacityValue)
    .onAppear(() => {
      // 当组件渲染展示的时候, 修改状态
      this.opacityValue = 0.5
    })
    .animation({
      duration: 600,
      playMode: PlayMode.Alternate, // 动画交替执行
      iterations: -1, // 动画无限次
      curve: Curve.EaseInOut // 动画效果 linear匀速, EaseInOut缓动
    })
  }
}

@ComponentV2
export struct SkeletonItem {
  @Param widthValue: Length = '100%'
  @Param heightValue: Length = 16
  build() {
    Text()
      .height(this.heightValue)
      .width(this.widthValue)
      .borderRadius(3)
      .backgroundColor(Color.Gray)
  }
}