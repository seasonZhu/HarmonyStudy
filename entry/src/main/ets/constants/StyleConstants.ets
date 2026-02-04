/**
 * 列表配置常量
 * 统一管理列表相关的配置参数
 */
export class ListConfig {
  /** 列表项间距 */
  static readonly SPACE: number = 20

  /** 列表缓存数量 */
  static readonly CACHED_COUNT: number = 3

  /** 分割线宽度 */
  static readonly DIVIDER_STROKE_WIDTH: number = 0.25

  /** 分割线颜色 (通过资源引用) */
  static readonly DIVIDER_COLOR: string = '#2F2F2F'
}
