/**
 * HarmonyOS 原生嵌入组件定义 - 修复版
 *
 * @description
 * 为 uni-app 小程序提供 HarmonyOS 原生能力的组件封装
 *
 * @module HarmonyNativeComponents
 * @version 1.0.1
 */

import { NativeEmbedBuilderOptions, defineNativeEmbed } from '@dcloudio/uni-app-runtime';
import { LogUtil } from '@pura/harmony-utils';
import { promptAction } from '@kit.ArkUI';

// ==================== 1. 原生按钮组件 ====================

/**
 * 原生按钮选项
 */
export interface NativeButtonOptions extends NativeEmbedBuilderOptions {
  /** 按钮文字 */
  text: string;
  /** 按钮类型 */
  type?: 'primary' | 'success' | 'warning' | 'danger';
  /** 是否禁用 */
  disabled?: boolean;
}

/**
 * 原生按钮点击事件详情
 */
export interface NativeButtonClickDetail {
  type: string;
  text: string;
  timestamp: number;
}

/**
 * 原生按钮组件
 */
@Component
export struct NativeButtonComponent {
  @Prop text: string = '按钮';
  @Prop type: string = 'primary';
  @Prop disabled: boolean = false;
  onButtonClick?: Function;

  private lastClickTime: number = 0;
  private readonly DEBOUNCE_TIME: number = 500;

  build() {
    Button(this.text)
      .width('100%')
      .height('100%')
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.getBackgroundColor())
      .enabled(!this.disabled)
      .opacity(this.disabled ? 0.5 : 1)
      .onClick(() => {
        // 防抖处理
        const now: number = Date.now();
        if (now - this.lastClickTime < this.DEBOUNCE_TIME) {
          LogUtil.debug('NativeButton: 点击过快，已忽略');
          return;
        }
        this.lastClickTime = now;

        // 触发回调
        if (this.onButtonClick) {
          const detail: NativeButtonClickDetail = {
            type: this.type,
            text: this.text,
            timestamp: now
          };
          this.onButtonClick({
            detail
          });
        }

        // 触觉反馈
        promptAction.showToast({ message: `点击了${this.text}`, duration: 1000 });
      });
  }

  private getBackgroundColor(): ResourceColor {
    switch (this.type) {
      case 'primary':
        return $r('app.color.mainBlue');
      case 'success':
        return '#4CAF50';
      case 'warning':
        return '#FF9800';
      case 'danger':
        return '#F44336';
      default:
        return $r('app.color.mainBlue');
    }
  }
}

@Builder
function NativeButtonBuilder(options: NativeButtonOptions) {
  NativeButtonComponent({
    text: options.text,
    type: options.type ?? 'primary',
    disabled: options.disabled ?? false,
    onButtonClick: options?.on?.get('click')
  })
  .width(options.width)
  .height(options.height);
}

// ==================== 2. 相机组件 ====================

/**
 * 相机组件选项
 */
export interface NativeCameraOptions extends NativeEmbedBuilderOptions {
  /** 图片质量 */
  quality?: number;
  /** 是否编辑 */
  edit?: boolean;
}

/**
 * 相机组件返回结果
 */
export interface NativeCameraResult {
  success: boolean;
  uri?: string;
  width?: number;
  height?: number;
  size?: number;
  errorMessage?: string;
}

/**
 * 原生相机组件
 */
@Component
export struct NativeCameraComponent {
  @Prop quality: number = 80;
  @Prop edit: boolean = false;
  onCameraResult?: Function;

  async pickImage(): Promise<void> {
    LogUtil.debug('NativeCamera: 开始选择图片');

    try {
      // TODO: 调用 HarmonyOS 系统相册 API
      await new Promise<void>((resolve: Function) => {
        setTimeout((): void => {
          resolve();
        }, 1000);
      });

      const result: NativeCameraResult = {
        success: true,
        uri: 'mock_image_uri.jpg',
        width: 1920,
        height: 1080,
        size: 1024 * 1024
      };

      LogUtil.debug('NativeCamera: 选择成功', JSON.stringify(result));

      if (this.onCameraResult) {
        this.onCameraResult({
          detail: result
        });
      }

      promptAction.showToast({ message: '图片选择成功' });
    } catch (error) {
      LogUtil.error('NativeCamera: 选择失败', JSON.stringify(error));

      const errorResult: NativeCameraResult = {
        success: false,
        errorMessage: '图片选择失败'
      };

      if (this.onCameraResult) {
        this.onCameraResult({
          detail: errorResult
        });
      }

      promptAction.showToast({ message: '图片选择失败' });
    }
  }

  build() {
    Column() {
      Text('📷')
        .fontSize(40)
        .margin({ bottom: 8 })

      Text('选择图片')
        .fontSize(14)
        .fontColor($r('app.color.mainBlue'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.pickImage();
    });
  }
}

@Builder
function NativeCameraBuilder(options: NativeCameraOptions) {
  NativeCameraComponent({
    quality: options.quality ?? 80,
    edit: options.edit ?? false,
    onCameraResult: options?.on?.get('result')
  })
  .width(options.width)
  .height(options.height);
}

// ==================== 3. 定位组件 ====================

/**
 * 定位组件选项
 */
export interface NativeLocationOptions extends NativeEmbedBuilderOptions {
  /** 定位精度 */
  accuracy?: 'low' | 'medium' | 'high';
  /** 超时时间（毫秒） */
  timeout?: number;
}

/**
 * 定位组件返回结果
 */
export interface NativeLocationResult {
  success: boolean;
  latitude?: number;
  longitude?: number;
  address?: string;
  errorMessage?: string;
}

/**
 * 原生定位组件
 */
@Component
export struct NativeLocationComponent {
  @Prop accuracy: string = 'medium';
  @Prop timeout: number = 10000;
  onLocationResult?: Function;

  private isLoading: boolean = false;

  async getLocation(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    LogUtil.debug('NativeLocation: 开始获取位置');

    try {
      // TODO: 调用 HarmonyOS 位置服务
      await new Promise<void>((resolve: Function) => {
        setTimeout((): void => {
          resolve();
        }, 1000);
      });

      const result: NativeLocationResult = {
        success: true,
        latitude: 39.9042 + Math.random() * 0.01,
        longitude: 116.4074 + Math.random() * 0.01,
        address: '北京市朝阳区'
      };

      LogUtil.debug('NativeLocation: 定位成功', JSON.stringify(result));

      if (this.onLocationResult) {
        this.onLocationResult({
          detail: result
        });
      }

      promptAction.showToast({ message: '定位成功' });
    } catch (error) {
      LogUtil.error('NativeLocation: 定位失败', JSON.stringify(error));

      const errorResult: NativeLocationResult = {
        success: false,
        errorMessage: '定位失败'
      };

      if (this.onLocationResult) {
        this.onLocationResult({
          detail: errorResult
        });
      }

      promptAction.showToast({ message: '定位失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .color($r('app.color.mainBlue'))
          .width(40)
          .height(40)

        Text('定位中...')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      } else {
        Text('📍')
          .fontSize(40)
          .margin({ bottom: 8 })

        Text('获取定位')
          .fontSize(14)
          .fontColor($r('app.color.mainBlue'))
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.getLocation();
    });
  }
}

@Builder
function NativeLocationBuilder(options: NativeLocationOptions) {
  NativeLocationComponent({
    accuracy: options.accuracy ?? 'medium',
    timeout: options.timeout ?? 10000,
    onLocationResult: options?.on?.get('result')
  })
  .width(options.width)
  .height(options.height);
}

// ==================== 4. 扫码组件 ====================

/**
 * 扫码组件选项
 */
export interface NativeScannerOptions extends NativeEmbedBuilderOptions {
  /** 扫码类型 */
  scanType?: 'qr' | 'bar' | 'all';
}

/**
 * 扫码组件返回结果
 */
export interface NativeScannerResult {
  success: boolean;
  code?: string;
  format?: string;
  errorMessage?: string;
}

/**
 * 原生扫码组件
 */
@Component
export struct NativeScannerComponent {
  @Prop scanType: string = 'all';
  onScannerResult?: Function;

  async scan(): Promise<void> {
    LogUtil.debug('NativeScanner: 开始扫码');

    try {
      // TODO: 调用 HarmonyOS 扫码 API
      await new Promise<void>((resolve: Function) => {
        setTimeout((): void => {
          resolve();
        }, 1500);
      });

      const result: NativeScannerResult = {
        success: true,
        code: 'https://example.com/product/123456',
        format: 'QR_CODE'
      };

      LogUtil.debug('NativeScanner: 扫码成功', JSON.stringify(result));

      if (this.onScannerResult) {
        this.onScannerResult({
          detail: result
        });
      }

      promptAction.showToast({ message: '扫码成功' });
    } catch (error) {
      LogUtil.error('NativeScanner: 扫码失败', JSON.stringify(error));

      const errorResult: NativeScannerResult = {
        success: false,
        errorMessage: '扫码失败'
      };

      if (this.onScannerResult) {
        this.onScannerResult({
          detail: errorResult
        });
      }

      promptAction.showToast({ message: '扫码失败' });
    }
  }

  build() {
    Column() {
      Text('📷')
        .fontSize(40)
        .margin({ bottom: 8 })

      Text('扫一扫')
        .fontSize(14)
        .fontColor($r('app.color.mainBlue'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.scan();
    });
  }
}

@Builder
function NativeScannerBuilder(options: NativeScannerOptions) {
  NativeScannerComponent({
    scanType: options.scanType ?? 'all',
    onScannerResult: options?.on?.get('result')
  })
  .width(options.width)
  .height(options.height);
}

// ==================== 5. 系统信息组件 ====================

/**
 * 系统信息选项
 */
export interface NativeSystemInfoOptions extends NativeEmbedBuilderOptions {
  /** 信息类型 */
  infoType?: 'basic' | 'network' | 'storage' | 'all';
}

/**
 * 系统信息详情接口
 */
export interface SystemInfoData {
  brand: string;
  model: string;
  platform: string;
  system: string;
  version: string;
  SDKVersion: string;
}

export interface NetworkInfoData {
  isConnected: boolean;
  type: string;
}

export interface StorageInfoData {
  total: number;
  used: number;
  available: number;
}

/**
 * 系统信息结果
 */
export interface NativeSystemInfoResult {
  success: boolean;
  systemInfo?: SystemInfoData;
  networkInfo?: NetworkInfoData;
  storageInfo?: StorageInfoData;
  errorMessage?: string;
}

/**
 * 原生系统信息组件
 */
@Component
export struct NativeSystemInfoComponent {
  @Prop infoType: string = 'basic';
  onSystemInfoResult?: Function;

  private isLoading: boolean = false;

  async getSystemInfo(): Promise<void> {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    LogUtil.debug('NativeSystemInfo: 开始获取系统信息');

    try {
      // TODO: 调用 HarmonyOS 系统信息 API
      await new Promise<void>((resolve: Function) => {
        setTimeout((): void => {
          resolve();
        }, 800);
      });

      const systemInfo: SystemInfoData = {
        brand: 'HarmonyOS',
        model: 'Next',
        platform: 'ohos',
        system: 'HarmonyOS NEXT',
        version: '5.0',
        SDKVersion: 'API 12'
      };

      const networkInfo: NetworkInfoData = {
        isConnected: true,
        type: 'wifi'
      };

      const storageInfo: StorageInfoData = {
        total: 128 * 1024 * 1024 * 1024,
        used: 32 * 1024 * 1024 * 1024,
        available: 96 * 1024 * 1024 * 1024
      };

      const result: NativeSystemInfoResult = {
        success: true,
        systemInfo: systemInfo,
        networkInfo: networkInfo,
        storageInfo: storageInfo
      };

      LogUtil.debug('NativeSystemInfo: 获取成功', JSON.stringify(result));

      if (this.onSystemInfoResult) {
        this.onSystemInfoResult({
          detail: result
        });
      }

      promptAction.showToast({ message: '获取成功' });
    } catch (error) {
      LogUtil.error('NativeSystemInfo: 获取失败', JSON.stringify(error));

      const errorResult: NativeSystemInfoResult = {
        success: false,
        errorMessage: '获取系统信息失败'
      };

      if (this.onSystemInfoResult) {
        this.onSystemInfoResult({
          detail: errorResult
        });
      }

      promptAction.showToast({ message: '获取失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .color($r('app.color.mainBlue'))
          .width(40)
          .height(40)

        Text('获取中...')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      } else {
        Text('ℹ️')
          .fontSize(40)
          .margin({ bottom: 8 })

        Text('系统信息')
          .fontSize(14)
          .fontColor($r('app.color.mainBlue'))
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.getSystemInfo();
    });
  }
}

@Builder
function NativeSystemInfoBuilder(options: NativeSystemInfoOptions) {
  NativeSystemInfoComponent({
    infoType: options.infoType ?? 'basic',
    onSystemInfoResult: options?.on?.get('result')
  })
  .width(options.width)
  .height(options.height);
}

// ==================== 注册所有组件 ====================

/**
 * 注册所有原生嵌入组件
 */
export function registerAllNativeComponents(): void {
  LogUtil.debug('registerAllNativeComponents: 开始注册原生组件');

  // 1. 注册原生按钮
  defineNativeEmbed('native-button', {
    builder: NativeButtonBuilder
  });

  // 2. 注册相机组件
  defineNativeEmbed('native-camera', {
    builder: NativeCameraBuilder
  });

  // 3. 注册定位组件
  defineNativeEmbed('native-location', {
    builder: NativeLocationBuilder
  });

  // 4. 注册扫码组件
  defineNativeEmbed('native-scanner', {
    builder: NativeScannerBuilder
  });

  // 5. 注册系统信息组件
  defineNativeEmbed('native-system-info', {
    builder: NativeSystemInfoBuilder
  });

  LogUtil.debug('registerAllNativeComponents: 原生组件注册完成');
}
