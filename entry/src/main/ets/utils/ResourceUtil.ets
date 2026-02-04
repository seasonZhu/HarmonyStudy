/**
 * 资源工具类
 * 提供同步获取资源字符串的方法
 */
export class ResourceUtil {
  /**
   * 从组件获取资源管理器
   * @param component 组件实例
   * @returns 资源管理器
   */
  private static getResourceManager(component: ESObject): ESObject | null {
    try {
      // 尝试使用 getUIContext()
      const comp = component as Record<string, Object>
      if (comp.getUIContext !== undefined) {
        const getUIContextFunc = comp.getUIContext as () => Object
        const uiContext = getUIContextFunc()
        const uiCtx = uiContext as Record<string, Object>
        if (uiCtx.resourceManager !== undefined) {
          return uiCtx.resourceManager as ESObject
        }
      }
      // 降级使用 getContext()
      if (comp.getContext !== undefined) {
        const getContextFunc = comp.getContext as (c: ESObject) => Object
        const context = getContextFunc(component)
        const ctx = context as Record<string, Object>
        if (ctx.resourceManager !== undefined) {
          return ctx.resourceManager as ESObject
        }
      }
      return null
    } catch (error) {
      console.error('ResourceUtil: Failed to get resourceManager', JSON.stringify(error))
      return null
    }
  }

  /**
   * 同步获取资源字符串的值
   * @param component 组件实例
   * @param resource 资源对象
   * @returns 字符串值
   */
  static getString(component: ESObject, resource: Resource): string {
    if (!resource) {
      console.error('ResourceUtil: Invalid resource')
      return ''
    }

    const rm: ESObject | null = ResourceUtil.getResourceManager(component)
    if (!rm) {
      console.error('ResourceUtil: Cannot get resourceManager')
      return ''
    }

    try {
      const rmObj = rm as Record<string, Object>
      // 尝试 getString(Resource) 方法
      if (typeof rmObj.getString === 'function') {
        const getStringFunc = rmObj.getString as (r: Resource) => string
        const result = getStringFunc(resource)
        if (result && result.length > 0) {
          return result
        }
      }
      // 尝试 getStringValueSync(number) 方法
      if (typeof rmObj.getStringValueSync === 'function' && resource.id !== undefined) {
        const getFunc = rmObj.getStringValueSync as (id: number) => string
        const result = getFunc(resource.id)
        if (result && result.length > 0) {
          return result
        }
      }
      // 尝试 getStringByName 方法
      if (typeof rmObj.getStringByName === 'function' && resource.bundleName !== undefined) {
        const getFunc = rmObj.getStringByName as (name: string) => string
        // 从 Resource 对象中提取资源名称，格式为 "app.string.xxx"
        const resourceId = JSON.stringify(resource)
        const match = resourceId.match(/"name":"([^"]+)"/)
        if (match && match[1]) {
          const result = getFunc(match[1])
          if (result && result.length > 0) {
            return result
          }
        }
      }
      console.error('ResourceUtil: No suitable getString method found or empty result')
      return ''
    } catch (error) {
      console.error('ResourceUtil: Failed to get string value', JSON.stringify(error))
      return ''
    }
  }

  /**
   * 同步获取资源字符串的值（带默认值）
   * @param component 组件实例
   * @param resource 资源对象
   * @param defaultValue 默认值
   * @returns 字符串值
   */
  static getStringOrDefault(component: ESObject, resource: Resource, defaultValue: string): string {
    const result = ResourceUtil.getString(component, resource)
    return result && result.length > 0 ? result : defaultValue
  }
}
