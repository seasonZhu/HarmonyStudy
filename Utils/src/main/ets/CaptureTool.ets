import { componentSnapshot, promptAction } from "@kit.ArkUI"
import image from "@ohos.multimedia.image"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"

/**
 * 图片保存选项
 */
export interface ImageSaveOptions {
  /** 文件名前缀，默认 "capture" */
  prefix?: string
  /** 文件格式，默认 "image/jpeg" */
  format?: 'image/jpeg' | 'image/png'
  /** 图片质量 (1-100)，默认 98 */
  quality?: number
  /** 成功提示消息，默认 "存入相册成功" */
  successMessage?: string
  /** 失败提示消息，默认 "保存失败" */
  failMessage?: string
}

/**
 * 截图保存工具类
 *
 * 将任意组件截图并保存到系统相册
 *
 * @example
* ```ets
 * // 基本用法（需在安全控件点击回调中调用）
 * await CaptureTool.saveImage('share')
 *
 * // 自定义配置
 * await CaptureTool.saveImage('myComponent', {
 *   prefix: 'myImage',
 *   quality: 90,
 *   successMessage: '保存成功'
 * })
 * ```
 */
export class CaptureTool {
  /**
   * 截图并保存到相册
   * @param componentId 组件的 id 属性值
   * @param options 保存选项
   */
  static async saveImage(componentId: string, options?: ImageSaveOptions): Promise<void> {
    const prefix = options?.prefix ?? 'capture'
    const format = options?.format ?? 'image/jpeg'
    const quality = options?.quality ?? 98
    const successMessage = options?.successMessage ?? '存入相册成功'
    const failMessage = options?.failMessage ?? '保存失败'

    try {
      // 1. 组件截图 => pixelMap
      const pixelMap = await componentSnapshot.get(componentId)

      // 2. 转二进制数据
      const imagePacker = image.createImagePacker()
      const packOptions: image.PackingOption = {
        format: format,
        quality: quality
      }
      const arrayBuffer = await imagePacker.packToData(pixelMap, packOptions)

      // 3. 存入沙箱缓存
      const ctx = getContext()
      const extension = format === 'image/png' ? 'png' : 'jpeg'
      const imagePath = ctx.cacheDir + '/' + prefix + '_' + Date.now() + '.' + extension

      const file = fileIo.openSync(imagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      fileIo.write(file.fd, arrayBuffer)
      fileIo.close(file.fd)

      // 4. 保存到相册
      const uri = fileUri.getUriFromPath(imagePath)
      const imgChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(ctx, uri)
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(ctx)
      await phAccessHelper.applyChanges(imgChangeRequest)

      promptAction.showToast({ message: successMessage })
    } catch (error) {
      promptAction.showToast({ message: failMessage })
      console.error('[CaptureTool] saveImage failed:', JSON.stringify(error))
    }
  }
}
