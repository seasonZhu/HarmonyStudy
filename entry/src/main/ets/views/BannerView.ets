import { Banner } from '../model/Banner';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ImageKnifeComponent, ScaleType } from '@ohos/imageknife'
import display from '@ohos.display';
import { LogUtil } from '@pura/harmony-utils';

@Component
export struct BannerView {
  private swiperControllers = new SwiperController()

  private swiperHeight = 200

  aboutToAppear(): void {
    try {
      let swiperWidth = display.getDefaultDisplaySync().width
      let densityPixels = display.getDefaultDisplaySync().densityPixels
      this.swiperHeight = (swiperWidth / densityPixels) * 0.5625
    } catch (exception) {
      LogUtil.debug('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
    }
  }

  @Link data: BaseListDataSource<Banner>;
  build() {
    Swiper(this.swiperControllers) {
      LazyForEach(this.data, (item: Banner) => {
        /// 这个库我之前用着很好，不知道为啥现在就显示不出来了
        //ImageKnifeComponent({ imageKnifeOption: {loadSrc: item.imagePath, mainScaleType: ScaleType.AUTO_HEIGHT} })
        Image(item.imagePath)
      })
    }
    .width('100%')
    .height(this.swiperHeight)
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
        .selectedColor($r('app.color.mainBlue'),))
    .curve(Curve.Linear)
    .onChange((index: number) => {
      LogUtil.debug(index.toString())
    })
    .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
      LogUtil.debug("index: " + index)
      LogUtil.debug("current offset: " + extraInfo.currentOffset)
    })
    .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
      LogUtil.debug("index: " + index)
      LogUtil.debug("targetIndex: " + targetIndex)
      LogUtil.debug("current offset: " + extraInfo.currentOffset)
      LogUtil.debug("target offset: " + extraInfo.targetOffset)
      LogUtil.debug("velocity: " + extraInfo.velocity)
    })
    .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
      LogUtil.debug("index: " + index)
      LogUtil.debug("current offset: " + extraInfo.currentOffset)
    })
  }
}