# Router 类优化建议与重构方案

> **文档版本**: v1.0
> **创建日期**: 2025-02-03
> **适用项目**: HarmonyStudy

---

## 📋 目录

- [一、当前问题分析](#一当前问题分析)
- [二、优化方案对比](#二优化方案对比)
- [三、推荐方案详解](#三推荐方案详解)
- [四、迁移步骤](#四迁移步骤)
- [五、使用示例对比](#五使用示例对比)

---

## 一、当前问题分析

### 1.1 当前实现回顾

```typescript
export interface RouterOptions {
  url: string
  params?: object
  success?: (() => void)
  error?: ((error: Error) => void)
  finally?: (() => void)
}

export abstract class Router {
  // 大量 toXxx 方法...
  public static toWebPage(webLink: WebLink) {
    Router.push({
      url: PagesConstant.Web,
      params: webLink
    })
  }

  // 基础路由方法
  public static push(options: RouterOptions) { /* ... */ }
  public static replace(options: RouterOptions) { /* ... */ }
  public static back(options?: RouterOptions) { /* ... */ }
  public static getParams(): Object { /* ... */ }
}
```

### 1.2 存在的问题

#### 🔴 问题1：不恰当的 abstract class

**现状**：
```typescript
export abstract class Router {
  // 类中没有抽象方法
  // 所有方法都是 static 的
  // abstract 修饰符毫无意义
}
```

**问题**：
- `abstract` 用于定义不能直接实例化的类，通常包含抽象方法
- 但 Router 类所有方法都是 `static` 的，根本不需要实例化
- `abstract` 在这里是**多余的且令人困惑**

**代码审查也会警告**：
> "Abstract class Router has no abstract members"

---

#### 🔴 问题2：类型不安全

**现状**：
```typescript
// ❌ params 是 object 类型，没有任何类型检查
Router.push({
  url: PagesConstant.Web,
  params: webLink  // 传什么都可以，没有类型检查
})

// ❌ getParams 返回 Object，需要手动转换
let webLink = Router.getParams() as WebLink
```

**问题**：
- 参数传递没有类型检查
- 获取参数需要手动类型转换，容易出错
- IDE 无法提供代码补全

---

#### 🔴 问题3：回调方式冗余

**现状**：
```typescript
Router.push({
  url: PagesConstant.Web,
  params: webLink,
  success: () => { /* 成功回调 */ },
  error: (error) => { /* 失败回调 */ },
  finally: () => { /* 最终回调 */ }
})
```

**问题**：
- 新版 `router.push()` 是**同步**的，不返回 Promise
- success/error/finally 回调实际上**没有意义**
- 但为了保持接口兼容性，不得不保留
- 增加了代码复杂度

---

#### 🔴 问题4：toXxx 方法过度封装

**现状**：
```typescript
// 16 个 toXxx 方法
Router.toWebPage(webLink)
Router.toTreeDetail(treeDetailInfo)
Router.toSearchResult(keywordInfo)
Router.toRank()
Router.toRegister()
Router.toCollect()
Router.toMyCoin()
// ... 等等
```

**问题**：
- 需要记住每个方法的参数类型
- 方法名和参数类型没有直接关联
- 维护成本高：每新增页面都要加方法
- 代码重复严重

---

#### 🔴 问题5：getParams() 不够安全

**现状**：
```typescript
export static getParams(): Object {
  return router.getParams()
}

// 使用时需要手动转换
let webLink = Router.getParams() as WebLink
let userInfo = Router.getParams() as UserInfoModel
```

**问题**：
- 返回 `Object` 类型，需要手动类型转换
- 如果转换错误，运行时才会发现问题
- 没有类型安全保障

---

#### 🔴 问题6：pushWithLogin 参数混乱

**现状**：
```typescript
private static pushWithLogin(
  url: string,
  params?: object,
  showTips: boolean = true,
  callback?: (() => void)
) {
  if (AccountManager.shared().isLogin()) {
    Router.push({url: url, params: params})
  } else {
    Router.toLogin(showTips, callback)
  }
}
```

**问题**：
- 参数顺序不直观：url, params, showTips, callback
- 很多时候只需要 url，但必须传入 params 的默认值
- callback 嵌套在 showTips 中，逻辑不清晰

---

#### 🔴 问题7：toLogin 方法逻辑混乱

**现状**：
```typescript
public static toLogin(showTips: boolean = true, callback?: (() => void)) {
  Router.push({
    url: PagesConstant.Login,
    success: () => {
      if (showTips) {  // ❌ 为什么 showTips 为 true 才执行 callback？
        if (callback) {
          callback()
        }
      }
    }
  })
}
```

**问题**：
- `showTips` 参数语义不清晰
- callback 的执行逻辑令人困惑
- success 回调在新版 API 中根本不会触发

---

### 1.3 使用体验问题

#### 当前使用方式（不够好）：

```typescript
// ❌ 需要记住方法签名
Router.toWebPage(webLink)
Router.toTreeDetail(treeDetailInfo)

// ❌ push 方法参数复杂
Router.push({
  url: PagesConstant.Web,
  params: webLink,
  success: () => {},
  error: (e) => {},
  finally: () => {}
})

// ❌ 获取参数不安全
let webLink = Router.getParams() as WebLink

// ❌ 返回逻辑混乱
Router.back({ params: userInfo, url: "" })
```

---

## 二、优化方案对比

### 方案概览

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **方案1：最小改动** | 改动小，风险低 | 治标不治本 | ⭐⭐ |
| **方案2：类型安全** | 类型安全，易维护 | 需要修改调用处 | ⭐⭐⭐⭐ |
| **方案3：现代化重构** | 最佳实践，易扩展 | 改动较大 | ⭐⭐⭐⭐⭐ |

---

### 方案1：最小改动（快速修复）

**核心思路**：移除 `abstract`，简化接口

```typescript
// ❌ 修改前
export abstract class Router { /* ... */ }

// ✅ 修改后
export class Router { /* ... */ }
export const Router = {
  // 使用对象而非类
}
```

**改动量**：约5处

**优点**：
- ✅ 改动最小
- ✅ 风险最低
- ✅ 立即可用

**缺点**：
- ❌ 没有解决根本问题
- ❌ 类型仍然不安全

---

### 方案2：类型安全（推荐 ⭐⭐⭐⭐）

**核心思路**：使用泛型 + 参数校验

```typescript
// ✅ 类型安全的路由方法
export class Router {
  // 泛型方法，支持类型推导
  static push<T = object>(
    url: string,
    params?: T
  ): void {
    try {
      router.push({ url, params })
    } catch (error) {
      LogUtil.error('路由失败', JSON.stringify(error))
    }
  }

  // 类型安全的参数获取
  static getParams<T = object>(): T | null {
    try {
      return router.getParams() as T
    } catch (error) {
      return null
    }
  }
}
```

**改动量**：约20-30处

**优点**：
- ✅ 类型安全
- ✅ 支持泛型
- ✅ 改动适中
- ✅ 向后兼容

**缺点**：
- ⚠️ 需要修改部分调用处

---

### 方案3：现代化重构（最佳 ⭐⭐⭐⭐⭐）

**核心思路**：完全重写，使用最佳实践

```typescript
// ✅ 现代化的路由实现
export class Router {
  // 链式调用 + 类型安全
  static navigate(url: string): RouterBuilder {
    return new RouterBuilder(url)
  }

  // 简化的 push 方法
  static push<T = object>(url: string, params?: T): void {
    RouterBuilder.navigate(url).params(params).go()
  }

  // 类型安全的 replace
  static replace<T = object>(url: string, params?: T): void {
    RouterBuilder.navigate(url).params(params).mode(NavMode.REPLACE).go()
  }

  // 简化的 back
  static back(): void {
    try {
      router.back()
    } catch (error) {
      LogUtil.error('返回失败', JSON.stringify(error))
    }
  }
}

// ✅ 构建器模式
export class RouterBuilder {
  private url: string
  private params?: object
  private mode: NavMode = NavMode.PUSH
  private needLogin: boolean = false

  constructor(url: string) {
    this.url = url
  }

  params<T>(value: T): RouterBuilder {
    this.params = value
    return this
  }

  replace(): RouterBuilder {
    this.mode = NavMode.REPLACE
    return this
  }

  requireLogin(): RouterBuilder {
    this.needLogin = true
    return this
  }

  go(): void {
    if (this.needLogin && !AccountManager.shared().isLogin()) {
      Router.push(PagesConstant.Login)
      return
    }

    try {
      if (this.mode === NavMode.REPLACE) {
        router.replace({ url: this.url, params: this.params })
      } else {
        router.push({ url: this.url, params: this.params })
      }
    } catch (error) {
      LogUtil.error('路由失败', JSON.stringify(error))
    }
  }
}

enum NavMode {
  PUSH,
  REPLACE
}
```

**改动量**：约50-80处

**优点**：
- ✅ 最佳实践
- ✅ 易于扩展
- ✅ 类型安全
- ✅ 链式调用，优雅

**缺点**：
- ⚠️ 改动较大
- ⚠️ 需要更多测试

---

## 三、推荐方案详解

### 3.1 推荐方案：渐进式优化

**核心思路**：先做方案2（类型安全），再逐步演进到方案3（现代化）

#### 第一阶段：类型安全（立即执行）

```typescript
/**
 * 路由工具类 - 类型安全版本
 */
export class Router {
  private static readonly TAG = 'Router'

  /**
   * 跳转到指定页面
   * @param url 页面路径
   * @param params 页面参数（可选）
   */
  static push<T = object>(url: string, params?: T): void {
    try {
      router.push({ url, params })
      LogUtil.debug(`${this.TAG}: 跳转到 ${url}`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 跳转失败`, JSON.stringify(error))
      throw error
    }
  }

  /**
   * 替换当前页面
   * @param url 页面路径
   * @param params 页面参数（可选）
   */
  static replace<T = object>(url: string, params?: T): void {
    try {
      router.replace({ url, params })
      LogUtil.debug(`${this.TAG}: 替换到 ${url}`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 替换失败`, JSON.stringify(error))
      throw error
    }
  }

  /**
   * 返回上一页
   */
  static back(): void {
    try {
      router.back()
      LogUtil.debug(`${this.TAG}: 返回上一页`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 返回失败`, JSON.stringify(error))
    }
  }

  /**
   * 获取页面参数（类型安全）
   * @template T 参数类型
   * @returns 页面参数，如果不存在返回 null
   */
  static getParams<T = object>(): T | null {
    try {
      return router.getParams() as T
    } catch (error) {
      LogUtil.error(`${this.TAG}: 获取参数失败`, JSON.stringify(error))
      return null
    }
  }

  /**
   * 跳转到登录页
   * @param callback 登录成功后的回调
   */
  static toLogin(callback?: () => void): void {
    this.push(PagesConstant.Login)
    // 注意：新版 router.push 是同步的，callback 需要在登录页面成功后调用
    if (callback) {
      // 将 callback 保存到全局，供登录页面调用
      AppStorage.setOrCreate('loginCallback', callback)
    }
  }

  /**
   * 需要登录的页面跳转
   * @param url 页面路径
   * @param params 页面参数
   */
  static pushWithLogin<T = object>(url: string, params?: T): void {
    if (AccountManager.shared().isLogin()) {
      this.push(url, params)
    } else {
      // 保存目标页面信息，登录成功后跳转
      AppStorage.setOrCreate('afterLoginTarget', { url, params })
      this.toLogin()
    }
  }
}
```

#### 第二阶段：便捷方法（逐步添加）

```typescript
/**
 * 路由工具类 - 增强版
 */
export class Router {
  // ... 基础方法同上 ...

  /**
   * 跳转到 Web 页面
   */
  static toWebPage(webLink: WebLink): void {
    this.push<WebLink>(PagesConstant.Web, webLink)
  }

  /**
   * 跳转到搜索结果页
   */
  static toSearchResult(keywordInfo: KeywordInfo): void {
    this.push<KeywordInfo>(PagesConstant.SearchResult, keywordInfo)
  }

  /**
   * 跳转到排行榜
   */
  static toRank(): void {
    this.push(PagesConstant.Rank)
  }

  /**
   * 跳转到收藏页（需要登录）
   */
  static toCollect(): void {
    this.pushWithLogin(PagesConstant.MyCollect)
  }

  /**
   * 跳转到积分页（需要登录）
   */
  static toMyCoin(): void {
    this.pushWithLogin(PagesConstant.MyCoin)
  }

  // ... 其他便捷方法 ...
}
```

---

### 3.2 新 Router 类的优势

#### ✅ 优势1：类型安全

```typescript
// ❌ 旧方式：没有类型检查
Router.push({
  url: PagesConstant.Web,
  params: webLink  // 可能传错类型
})

// ✅ 新方式：类型检查
Router.push<WebLink>(PagesConstant.Web, webLink)
//               ^^^^^^^^^^ 明确指定参数类型
```

#### ✅ 优势2：简洁的API

```typescript
// ❌ 旧方式：参数复杂
Router.push({
  url: PagesConstant.Web,
  params: webLink,
  success: () => {},
  error: (e) => {},
  finally: () => {}
})

// ✅ 新方式：简洁明了
Router.push(PagesConstant.Web, webLink)
```

#### ✅ 优势3：类型安全的参数获取

```typescript
// ❌ 旧方式：需要手动转换
let webLink = Router.getParams() as WebLink

// ✅ 新方式：自动类型推导
let webLink = Router.getParams<WebLink>()
//                        ^^^^^^^^^ 明确返回类型
```

#### ✅ 优势4：更好的错误处理

```typescript
// ✅ 自动记录日志
Router.push(PagesConstant.Web, webLink)
// 日志：Router: 跳转到 pages/WebPage

// ✅ 自动错误处理
try {
  Router.push(PagesConstant.Web, webLink)
} catch (error) {
  // 已在内部处理，可选择不捕获
}
```

---

## 四、迁移步骤

### 4.1 第一阶段：核心重构（1-2小时）

#### 步骤1：备份当前代码
```bash
git checkout -b backup/router-before-refactor
git checkout -b feature/router-refactor
```

#### 步骤2：创建新的 Router 类
```typescript
// 文件：router/RouterV2.ets（先创建新版本，不影响旧代码）
export class RouterV2 {
  // 新的实现...
}
```

#### 步骤3：逐步迁移调用处
```typescript
// ❌ 旧代码
Router.toWebPage(webLink)

// ✅ 新代码
RouterV2.toWebPage(webLink)
```

#### 步骤4：测试验证
- 测试所有路由跳转
- 测试参数传递
- 测试登录拦截

#### 步骤5：替换旧实现
```typescript
// 重命名文件
RouterV2.ets → Router.ets

// 删除旧代码
```

---

### 4.2 第二阶段：增强功能（按需添加）

#### 可选功能：
1. **路由拦截器**
```typescript
static addInterceptor(interceptor: RouterInterceptor): void {
  this.interceptors.push(interceptor)
}

interface RouterInterceptor {
  beforeNavigate?(url: string, params?: object): boolean
  afterNavigate?(url: string, params?: object): void
}
```

2. **路由历史管理**
```typescript
static getHistory(): RouteHistory[] {
  return this.history
}

static canGoBack(): boolean {
  return this.history.length > 1
}
```

3. **路由动画配置**
```typescript
static pushWithAnimation<T>(
  url: string,
  params?: T,
  animation?: PageTransition
): void {
  // 自定义转场动画
}
```

---

## 五、使用示例对比

### 5.1 基础路由跳转

| 场景 | 旧代码 | 新代码 |
|------|--------|--------|
| **简单跳转** | `Router.toRank()` | `Router.push(PagesConstant.Rank)` |
| **带参数跳转** | `Router.toWebPage(webLink)` | `Router.push(PagesConstant.Web, webLink)` |
| **替换当前页** | `Router.replace({ url: xxx })` | `Router.replace(PagesConstant.Login)` |
| **返回上一页** | `Router.back({ url: "" })` | `Router.back()` |

### 5.2 参数传递

| 场景 | 旧代码 | 新代码 |
|------|--------|--------|
| **传递参数** | `Router.push({ url, params })` | `Router.push(url, params)` |
| **获取参数** | `let p = getParams() as Type` | `let p = getParams<Type>()` |

### 5.3 登录拦截

| 场景 | 旧代码 | 新代码 |
|------|--------|--------|
| **需要登录的页面** | `Router.pushWithLogin(url, params)` | `Router.pushWithLogin(url, params)` |
| **登录成功后跳转** | `Router.toLogin(true, callback)` | `Router.toLogin(callback)` |

---

## 六、完整的新 Router 类实现

```typescript
/**
 * 路由工具类 - 优化版本
 *
 * @description
 * 提供类型安全的路由跳转功能
 *
 * @example
 * ```typescript
 * // 简单跳转
 * Router.push(PagesConstant.Home)
 *
 * // 带参数跳转
 * Router.push<WebLink>(PagesConstant.Web, webLink)
 *
 * // 类型安全的参数获取
 * let webLink = Router.getParams<WebLink>()
 *
 * // 需要登录的页面
 * Router.pushWithLogin(PagesConstant.MyCollect)
 * ```
 */
export class Router {
  private static readonly TAG = 'Router'

  /**
   * 跳转到指定页面
   * @param url 页面路径
   * @param params 页面参数（可选，支持泛型）
   */
  static push<T = object>(url: string, params?: T): void {
    try {
      router.push({ url, params })
      LogUtil.debug(`${this.TAG}: 跳转到 ${url}`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 跳转失败`, JSON.stringify(error))
      throw error
    }
  }

  /**
   * 替换当前页面
   * @param url 页面路径
   * @param params 页面参数（可选）
   */
  static replace<T = object>(url: string, params?: T): void {
    try {
      router.replace({ url, params })
      LogUtil.debug(`${this.TAG}: 替换到 ${url}`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 替换失败`, JSON.stringify(error))
      throw error
    }
  }

  /**
   * 返回上一页
   */
  static back(): void {
    try {
      router.back()
      LogUtil.debug(`${this.TAG}: 返回上一页`)
    } catch (error) {
      LogUtil.error(`${this.TAG}: 返回失败`, JSON.stringify(error))
    }
  }

  /**
   * 获取页面参数（类型安全）
   * @template T 参数类型
   * @returns 页面参数，如果不存在返回 null
   */
  static getParams<T = object>(): T | null {
    try {
      const params = router.getParams()
      return params ? (params as T) : null
    } catch (error) {
      LogUtil.error(`${this.TAG}: 获取参数失败`, JSON.stringify(error))
      return null
    }
  }

  /**
   * 跳转到登录页
   * @param callback 登录成功后的回调（可选）
   */
  static toLogin(callback?: () => void): void {
    this.push(PagesConstant.Login)
    if (callback) {
      AppStorage.setOrCreate('loginCallback', callback)
    }
  }

  /**
   * 需要登录的页面跳转
   * @param url 页面路径
   * @param params 页面参数
   */
  static pushWithLogin<T = object>(url: string, params?: T): void {
    if (AccountManager.shared().isLogin()) {
      this.push<T>(url, params)
    } else {
      AppStorage.setOrCreate('afterLoginTarget', { url, params })
      this.toLogin()
    }
  }

  // ========== 便捷方法 ==========

  /**
   * 跳转到 Web 页面
   */
  static toWebPage(webLink: WebLink): void {
    this.push<WebLink>(PagesConstant.Web, webLink)
  }

  /**
   * 跳转到搜索结果页
   */
  static toSearchResult(keywordInfo: KeywordInfo): void {
    this.push<KeywordInfo>(PagesConstant.SearchResult, keywordInfo)
  }

  /**
   * 跳转到树形详情页
   */
  static toTreeDetail(treeDetailInfo: TreeDetailInfo): void {
    this.push<TreeDetailInfo>(PagesConstant.TreeDetail, treeDetailInfo)
  }

  /**
   * 跳转到排行榜
   */
  static toRank(): void {
    this.push(PagesConstant.Rank)
  }

  /**
   * 跳转到注册页
   */
  static toRegister(): void {
    this.push(PagesConstant.Register)
  }

  /**
   * 跳转到收藏页（需要登录）
   */
  static toCollect(): void {
    this.pushWithLogin(PagesConstant.MyCollect)
  }

  /**
   * 跳转到积分页（需要登录）
   */
  static toMyCoin(): void {
    this.pushWithLogin(PagesConstant.MyCoin)
  }

  /**
   * 跳转到设置页（需要登录）
   */
  static toSetting(): void {
    this.pushWithLogin(PagesConstant.Setting)
  }

  /**
   * 跳转到环境切换页
   */
  static toEnvironmentSwitch(): void {
    this.push(PagesConstant.EnvironmentSwitch)
  }
}
```

---

## 七、总结

### 7.1 核心改进点

| 改进项 | 旧实现 | 新实现 |
|--------|--------|--------|
| **类修饰符** | `abstract class` ❌ | `class` ✅ |
| **类型安全** | `object` 类型 ❌ | 泛型 `<T>` ✅ |
| **参数获取** | `getParams() as Type` ❌ | `getParams<Type>()` ✅ |
| **返回方法** | `back({url: ""})` ❌ | `back()` ✅ |
| **回调方式** | `success/error/finally` ❌ | `try-catch` ✅ |
| **方法数量** | 16 个 toXxx 方法 | 保留常用，移除冗余 ✅ |

### 7.2 代码对比

```typescript
// ❌ 旧代码
export abstract class Router {
  public static push(options: RouterOptions) {
    try {
      router.push({ url: options.url, params: options.params })
      if(options.success) {
        options.success()
      }
    } catch (error) {
      if(options.error) {
        options.error(error as Error)
      }
    }
  }
}

// ✅ 新代码
export class Router {
  static push<T = object>(url: string, params?: T): void {
    try {
      router.push({ url, params })
    } catch (error) {
      LogUtil.error('路由失败', JSON.stringify(error))
      throw error
    }
  }
}
```

### 7.3 使用对比

```typescript
// ❌ 旧方式
Router.push({
  url: PagesConstant.Web,
  params: webLink,
  success: () => {},
  error: (e) => {},
  finally: () => {}
})

// ✅ 新方式
Router.push(PagesConstant.Web, webLink)
```

---

**下一步**：你希望我现在就执行这个优化方案吗？还是你想先review一下这份文档？
