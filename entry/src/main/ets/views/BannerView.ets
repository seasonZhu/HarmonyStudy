import { Banner } from '../model/Banner';
import { BaseListDataSource } from '../model/BaseListDataSource';
import { ImageKnifeComponent, ImageKnifeOption } from '@ohos/imageknife'
import { LogUtil } from '@pura/harmony-utils';

@Component
export struct BannerView {
  private swiperControllers = new SwiperController()

  itemClick?: (item: Banner) => void

  @Link data: BaseListDataSource<Banner>;

  build() {
    Swiper(this.swiperControllers) {
      LazyForEach(this.data, (item: Banner) => {
        ImageKnifeComponent({
          imageKnifeOption: {
            loadSrc:item.imagePath,
            objectFit: ImageFit.Cover
          }
        })
          .width('100%')
          .height('100%')
          .onClick(() => {
            if (this.itemClick) {
              this.itemClick(item)
            }
          })
      })
    }
    .borderRadius(8)
    .width('100%')
    // 按列表内的实际宽度计算高度，避免屏幕宽度与卡片宽度不一致产生底部空白。
    .aspectRatio(16 / 9)
    .cachedCount(3)
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
        .selectedItemWidth(10)
        .selectedItemHeight(10)
        .color('rgba(255,255,255,.3)')
        .selectedColor($r('app.color.app_blue'),))
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