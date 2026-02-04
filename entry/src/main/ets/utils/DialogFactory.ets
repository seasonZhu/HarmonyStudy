import { LoadingDialog } from '../httpRequest/LoadingDialog'

/**
 * Dialog 工厂类
 * 提供统一的 Dialog 配置和创建方法，避免重复代码
 */
export class DialogFactory {
  /**
   * 创建标准的 LoadingDialog Controller
   * @param text 加载提示文字
   * @returns CustomDialogController
   */
  static createLoadingDialog(text: string): CustomDialogController {
    return new CustomDialogController({
      builder: LoadingDialog({ text: text }),
      autoCancel: false,
      alignment: DialogAlignment.Center,
      customStyle: false
    })
  }

  /**
   * 创建登录场景的 LoadingDialog Controller
   * @returns CustomDialogController
   */
  static createLoginLoadingDialog(): CustomDialogController {
    return DialogFactory.createLoadingDialog('正在登录...')
  }

  /**
   * 创建注册场景的 LoadingDialog Controller
   * @returns CustomDialogController
   */
  static createRegisterLoadingDialog(): CustomDialogController {
    return DialogFactory.createLoadingDialog('正在注册...')
  }

  /**
   * 创建登出场景的 LoadingDialog Controller
   * @returns CustomDialogController
   */
  static createLogoutLoadingDialog(): CustomDialogController {
    return DialogFactory.createLoadingDialog('正在登出...')
  }

  /**
   * 创建网络请求场景的 LoadingDialog Controller
   * @returns CustomDialogController
   */
  static createNetworkLoadingDialog(): CustomDialogController {
    return DialogFactory.createLoadingDialog('请求中...')
  }
}
