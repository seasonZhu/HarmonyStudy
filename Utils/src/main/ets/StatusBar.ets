import { AppStorageV2, window } from "@kit.ArkUI"
import { SavedContext } from "./SaveContext"

class StatusBar {
  setDarkBar () {
    this.setBar({
      statusBarContentColor: '#000000'
    })
  }
  setLightBar () {
    this.setBar({
      statusBarContentColor: '#ffffff'
    })
  }
  async setBar (config: window.SystemBarProperties) {
    let context = AppStorageV2.connect(SavedContext)!.context
    let win = await window.getLastWindow(context)
    await win.setWindowSystemBarProperties(config)
  }
}

export const statusBar = new StatusBar()