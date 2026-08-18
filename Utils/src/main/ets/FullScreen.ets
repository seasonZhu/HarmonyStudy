import { AppStorageV2, window } from "@kit.ArkUI"
import { AreaHeight } from "./AreaHeight"
import { SavedContext } from "./SaveContext"

class FullScreen {
  async enable () {
    // 思路: 可以将context对象, 暂存到AppStorageV2中, 便于访问
    // 这里进行的是获取
    SavedContext
    let context = AppStorageV2.connect(SavedContext)!.context
    // 获取window窗口对象(注意window需要导入)
    let win = await window.getLastWindow(context)
    // 设置沉浸式布局 true
    await win.setWindowLayoutFullScreen(true)

    // 获取安全区的高度, 将安全区的高度存起来, 存入 AppStorageV2
    // AreaHeight: { topHeight: xx, bottomHeight: xx }
    let topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM) // 顶部区域
    let bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) // 底部区域
    let topHeight = px2vp(topArea.topRect.height) // 顶部系统默认区域高度, 坑: 默认拿到的是px单位
    let bottomHeight = px2vp(bottomArea.bottomRect.height) // 底部导航区域高度, 坑: 默认拿到的是px单位

    // 设置存储
    let areaHeight: AreaHeight = AppStorageV2.connect(AreaHeight, () => new AreaHeight(0, 0))!
    areaHeight.topHeight = topHeight
    areaHeight.bottomHeight = bottomHeight
  }
  async disable() {
    let context = AppStorageV2.connect(SavedContext)!.context
    let win = await window.getLastWindow(context)
    await win.setWindowLayoutFullScreen(false)

    // 设置存储
    let areaHeight: AreaHeight = AppStorageV2.connect(AreaHeight, () => new AreaHeight(0, 0))!
    areaHeight.topHeight = 0
    areaHeight.bottomHeight = 0
  }
}

export const fullScreen = new FullScreen()