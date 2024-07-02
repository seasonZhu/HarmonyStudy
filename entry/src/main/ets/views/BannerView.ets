import { Banner } from '../model/Banner';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ImageKnifeComponent, ScaleType } from '@ohos/imageknife'
import display from '@ohos.display';

@Component
export struct BannerView {
  private swiperControllers = new SwiperController()

  private swiperHeigth = 200

  aboutToAppear(): void {
    try {
      let swiperWidth = display.getDefaultDisplaySync().width
      let densityPixels = display.getDefaultDisplaySync().densityPixels
      this.swiperHeigth = (swiperWidth / densityPixels) * 0.5625
    } catch (exception) {
      console.error('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
    }
  }

  @Link data: BaseListDataSource<Banner>;
  build() {
    Swiper(this.swiperControllers) {
      LazyForEach(this.data, (item: Banner) => {
        ImageKnifeComponent({ imageKnifeOption: {loadSrc: item.imagePath} })
        //Text(item.imagePath)
        //Image(item.imagePath)
      })
    }
    .width('100%')
    .height(this.swiperHeigth)
    .cachedCount(2)
    .index(1)
    .autoPlay(true)
    .interval(2000)
    .loop(true)
    .duration(1000)
    .itemSpace(0)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth(8)
        .itemHeight(8)
        .selectedItemWidth(8)
        .selectedItemHeight(8)
        .color('rgba(255,255,255,.3)')
        .selectedColor(Color.Blue))
    .curve(Curve.Linear)
    .onChange((index: number) => {
      console.info(index.toString())
    })
    .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
      console.info("index: " + index)
      console.info("current offset: " + extraInfo.currentOffset)
    })
    .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
      console.info("index: " + index)
      console.info("targetIndex: " + targetIndex)
      console.info("current offset: " + extraInfo.currentOffset)
      console.info("target offset: " + extraInfo.targetOffset)
      console.info("velocity: " + extraInfo.velocity)
    })
    .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
      console.info("index: " + index)
      console.info("current offset: " + extraInfo.currentOffset)
    })
  }
}