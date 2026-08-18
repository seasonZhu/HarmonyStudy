// window 鸿蒙提供好的一个全局对象
import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
// https://juejin.cn/post/7377202850378596364
// 封装开启/关闭沉浸式模式类
export class Immersion {

  onOrOff = false

  // 获取当前窗口对象,并返出
  /**
   * @throws
   */
  async fullScreen(context: common.Context) {
    const lastWindow = await window.getLastWindow(context)
    return lastWindow
  }

  // 设置全屏模式开启或关闭（需要传入context参数）
  /**
   * @throws
   */
  async onOrOffFullScreen(onOrOff: boolean, context: common.Context) {
    // 获取当前窗口对象
    const lastWindow = await this.fullScreen(context)
    // 开启或关闭全屏模式(沉浸式模式)
    this.onOrOff = onOrOff
    lastWindow.setWindowLayoutFullScreen(onOrOff)
  }

}
export const immersion = new Immersion() // 创建该类并导出
