import { LogUtil } from "@pura/harmony-utils"

export abstract class SDKTools {
  static printMessage(): string {
    LogUtil.debug("librarySDK SDK Tools")
    return "librarySDK SDK Tools"
  }
}

