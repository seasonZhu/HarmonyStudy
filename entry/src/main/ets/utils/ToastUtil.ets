/**
 * Toast 提示工具类
 *
 * @description
 * 统一管理所有 Toast 提示，支持成功、失败、信息、加载等类型
 *
 * @module ToastUtil
 * @version 1.0.0
 */

import { promptAction } from '@kit.ArkUI';
import { LogUtil } from '@pura/harmony-utils';

/**
 * Toast 类型
 */
export type ToastType = 'success' | 'error' | 'info' | 'warning' | 'loading';

/**
 * Toast 配置选项
 */
export interface ToastOptions {
  /** 提示信息 */
  message: string;
  /** 显示时长（毫秒），默认 2000 */
  duration?: number;
  /** 是否显示底部 */
  isBottom?: boolean;
}

/**
 * Toast 工具类
 *
 * @example
 * ```typescript
 * // 成功提示
 * ToastUtil.success('操作成功');
 *
 * // 错误提示
 * ToastUtil.error('操作失败');
 *
 * // 自定义提示
 * ToastUtil.show({ message: '自定义消息', duration: 3000 });
 *
 * // 显示加载提示
 * ToastUtil.loading('加载中...');
 * const hide = () => ToastUtil.hideLoading();
 * ```
 */
export class ToastUtil {
  /** 默认显示时长 */
  private static readonly DEFAULT_DURATION: number = 2000;

  /** 加载提示的显示/隐藏控制 */
  private static loadingDialog: Object | null = null;

  /**
   * 显示成功提示
   *
   * @param message - 提示信息
   * @param duration - 显示时长（毫秒）
   */
  static success(message: string, duration: number = this.DEFAULT_DURATION): void {
    LogUtil.debug('ToastUtil.success:', message);
    promptAction.showToast({
      message,
      duration,
      // 成功提示使用绿色背景（如果支持）
    });
  }

  /**
   * 显示错误提示
   *
   * @param message - 提示信息
   * @param duration - 显示时长（毫秒），默认 3000
   */
  static error(message: string, duration: number = 3000): void {
    LogUtil.error('ToastUtil.error:', message);
    promptAction.showToast({
      message,
      duration,
    });
  }

  /**
   * 显示警告提示
   *
   * @param message - 提示信息
   * @param duration - 显示时长（毫秒）
   */
  static warning(message: string, duration: number = this.DEFAULT_DURATION): void {
    LogUtil.warn('ToastUtil.warning:', message);
    promptAction.showToast({
      message,
      duration,
    });
  }

  /**
   * 显示信息提示
   *
   * @param message - 提示信息
   * @param duration - 显示时长（毫秒）
   */
  static info(message: string, duration: number = this.DEFAULT_DURATION): void {
    LogUtil.debug('ToastUtil.info:', message);
    promptAction.showToast({
      message,
      duration,
    });
  }

  /**
   * 显示加载提示（需要手动关闭）
   *
   * @param message - 提示信息，默认 "加载中..."
   */
  static loading(message: string = '加载中...'): void {
    LogUtil.debug('ToastUtil.loading:', message);

    // 注意：HarmonyOS 的 promptAction 不直接支持 loading
    // 这里使用普通 Toast，实际项目中应使用 LoadingDialogHelper
    promptAction.showToast({
      message,
      duration: ToastUtil.DEFAULT_DURATION,
    });
  }

  /**
   * 隐藏加载提示
   */
  static hideLoading(): void {
    LogUtil.debug('ToastUtil.hideLoading');
    // 如果使用 LoadingDialogHelper，这里可以调用隐藏方法
  }

  /**
   * 显示 Toast（自定义）
   *
   * @param options - Toast 配置选项
   */
  static show(options: ToastOptions): void {
    LogUtil.debug('ToastUtil.show:', options.message);
    promptAction.showToast({
      message: options.message,
      duration: options.duration ?? ToastUtil.DEFAULT_DURATION,
    });
  }

  /**
   * 显示底部 Toast
   *
   * @param message - 提示信息
   * @param duration - 显示时长（毫秒）
   */
  static showAtBottom(message: string, duration: number = this.DEFAULT_DURATION): void {
    LogUtil.debug('ToastUtil.showAtBottom:', message);
    promptAction.showToast({
      message,
      duration,
      bottom: 100, // 距离底部的距离
    });
  }
}
