import { promptAction } from '@kit.ArkUI'
import AccountManager from '../accountManager/AccountManager'

/**
 * NavPathStack 单例
 * 在模块加载时创建并配置拦截器
 */
export const navPathStack: NavPathStack = new NavPathStack()

// 需要登录的页面列表
const AuthNames: string[] = [
  'MyCollect',
  'MyCoin',
  'Setting',
  'WebExample',
  'WebComponent'
]

// 配置路由拦截器
navPathStack.setInterception({
  willShow(from, to) {
    // 跳过导航栏首页
    if (typeof to === 'string') {
      return
    }
    // 防御性检查
    const pageName = to.pathInfo?.name
    if (!pageName) {
      return
    }

    // 检查是否需要登录
    if (AuthNames.includes(pageName)) {
      const accountManager = AccountManager.shared()
      if (!accountManager.isLogin()) {
        promptAction.showToast({
          message: '当前用户未登录，请先登录'
        })
        // 弹出目标页面，跳转到登录页
        to.pathStack.pop()
        to.pathStack.pushPath({
          name: 'Login'
        })
      }
    }
  }
})
