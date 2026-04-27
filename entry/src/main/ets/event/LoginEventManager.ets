import { emitter } from '@kit.BasicServicesKit';
import { UserInfoModel } from '../model/UserInfoModel';

/**
 * 登录成功事件管理器 - 用于跨组件通信
 * 类似iOS的NotificationCenter，当登录成功时通知所有订阅者
 */

class LoginEventManager {
  // 登录成功事件ID
  static readonly LOGIN_SUCCESS_EVENT: string = "LOGIN_SUCCESS_EVENT";

  constructor() {}

  /**
   * 发送登录成功事件
   */
  emitLoginSuccess(userInfo: UserInfoModel): void {
    let eventData: emitter.EventData = {
      data: {
        'userInfo': userInfo
      }
    };

    emitter.emit(LoginEventManager.LOGIN_SUCCESS_EVENT, eventData);
  }

  emitLoginCallback(callback: Callback<emitter.EventData>): void {
    emitter.on(LoginEventManager.LOGIN_SUCCESS_EVENT, callback)
  }
}

export const loginEventManager = new LoginEventManager();