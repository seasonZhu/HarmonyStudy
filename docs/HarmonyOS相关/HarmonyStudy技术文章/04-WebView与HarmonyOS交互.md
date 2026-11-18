# WebView与HarmonyOS交互

> **作者**：seasonZhu | **阅读时间**：约 18 分钟 | **难度等级**：中级

## 前言

本文将分享 HarmonyOS 中 WebView 与原生的交互方案，包括 Cookie 同步、JSBridge 设计、链接拦截等实战技巧。

---

## 一、WebView 基础使用

### 1.1 Web 组件简介

HarmonyOS 提供 **Web 组件**用于展示网页内容：

```typescript
import { webview } from '@kit.ArkWeb';

@Component
struct WebViewPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({ src: 'https://www.example.com', controller: this.webViewController })
        .width('100%')
        .height('100%')
    }
  }
}
```

### 1.2 Web 组件核心属性

| 属性 | 说明 |
|:-----|:-----|
| **src** | 网页 URL 或 HTML 内容 |
| **controller** | Web 控制器，用于控制页面行为 |
| **domStorageAccess** | 是否允许 DOM Storage |
| **fileAccess** | 是否允许访问本地文件 |
| **javaScriptAccess** | 是否允许执行 JavaScript |
| **mixedMode** | HTTP 和 HTTPS 混合内容模式 |
| **cacheMode** | 缓存模式 |

---

## 二、文章详情页实现

### 2.1 基础实现

```typescript
// pages/ArticleDetailPage.ets
import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ArticleDetailPage {
  @State url: string = '';
  @State title: string = '';
  @State showLoading: boolean = true;

  private webViewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.url = params.url || '';
    this.title = params.title || '';
  }

  build() {
    Column() {
      // 自定义导航栏
      this.NavigationBar()

      // WebView
      Web({
        src: this.url,
        controller: this.webViewController
      })
        .width('100%')
        .layoutWeight(1)
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .mixedMode(webview.MixedMode.All)
        .cacheMode(webview.CacheMode.Default)
        .onPageBegin(() => {
          this.showLoading = true;
        })
        .onPageEnd(() => {
          this.showLoading = false;
        })
        .onErrorReceive((event) => {
          console.error('WebView Error:', JSON.stringify(event));
          this.showLoading = false;
        })

      // Loading
      if (this.showLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  @Builder
  NavigationBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .onClick(() => {
          router.back();
        })

      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 分享按钮
      Image($r('app.media.ic_share'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetY: 2
    })
  }
}
```

### 2.2 支持返回键

```typescript
@Component
struct ArticleDetailPage {
  // ...

  build() {
    Column() {
      // ...
    }
    .onBackPressed(() => {
      // WebView 可以后退时，优先后退
      if (this.webViewController.accessBackward()) {
        this.webViewController.backward();
        return true; // 拦截默认返回行为
      }
      return false; // 执行默认返回
    })
  }
}
```

---

## 三、Cookie 同步问题

### 3.1 问题分析

```
┌─────────────────────────────────────────┐
│         原生 APP                        │
│  AccountManager.getToken() → "xxx"      │
├─────────────────────────────────────────┤
│         WebView                         │
│  document.cookie → undefined ❌         │
└─────────────────────────────────────────┘
```

### 3.2 解决方案：手动同步 Cookie

```typescript
@Component
struct ArticleDetailPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    // 同步 Cookie
    this.syncCookie();
  }

  /**
   * 同步 Cookie 到 WebView
   */
  private syncCookie() {
    const token = AccountManager.getInstance().getToken();

    if (token) {
      // 方案1：使用 requestHeader
      this.webViewController.setRequestHeader([
        {
          key: 'Cookie',
          value: token
        }
      ]);

      // 方案2：使用 JavaScript 注入
      this.webViewController.runJavaScript(`
        (function() {
          document.cookie = 'token=${encodeURIComponent(token)}; path=/';
        })();
      `);
    }
  }
}
```

### 3.3 Cookie 管理工具类

```typescript
// utils/CookieUtil.ets
import { webview } from '@kit.ArkWeb';
import { AccountManager } from '../accountManager/AccountManager';

/**
 * Cookie 管理工具
 */
export class CookieUtil {
  /**
   * 同步用户 Cookie 到 WebView
   */
  static syncUserCookie(controller: webview.WebviewController) {
    const cookie = AccountManager.getInstance().getToken();

    if (cookie) {
      // 设置请求头
      controller.setRequestHeader([
        {
          key: 'Cookie',
          value: cookie
        }
      ]);
    }
  }

  /**
   * 从响应中提取 Cookie
   */
  static extractCookie(responseHeaders: Record<string, string>): string | null {
    const setCookie = responseHeaders['set-cookie'];
    return setCookie || null;
  }

  /**
   * Cookie 格式化
   */
  static formatCookie(name: string, value: string, options: {
    path?: string;
    domain?: string;
    maxAge?: number;
  } = {}): string {
    let cookie = `${name}=${encodeURIComponent(value)}`;

    if (options.path) {
      cookie += `; Path=${options.path}`;
    }
    if (options.domain) {
      cookie += `; Domain=${options.domain}`;
    }
    if (options.maxAge) {
      cookie += `; Max-Age=${options.maxAge}`;
    }

    return cookie;
  }
}
```

---

## 四、JSBridge 设计

### 4.1 JSBridge 原理

```
┌─────────────────────────────────────────┐
│         原生 APP                        │
│  ← JavaScript 调用原生方法              │
│  → 原生返回结果给 JavaScript            │
├─────────────────────────────────────────┤
│         WebView                         │
│  ← JavaScript 调用                      │
│  → 接收原生返回值                       │
└─────────────────────────────────────────┘
```

### 4.2 注册 JavaScript 接口

```typescript
@Component
struct ArticleDetailPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    // 注册 JavaScript 接口
    this.registerJavaScriptInterface();
  }

  /**
   * 注册 JavaScript 接口
   */
  private registerJavaScriptInterface() {
    // 注入 JavaScript 对象
    this.webViewController.registerJavaScriptProxy({
      // 原生方法集合
      getNativeToken: () => {
        return AccountManager.getInstance().getToken();
      },

      share: (title: string, url: string) => {
        // 调用原生分享
        this.shareArticle(title, url);
        return { success: true };
      },

      collectArticle: (id: string) => {
        // 调用原生收藏
        this.collectArticle(parseInt(id));
        return { success: true };
      }
    }, 'HarmonyBridge', ['getNativeToken', 'share', 'collectArticle']);
  }

  /**
   * 分享文章
   */
  private shareArticle(title: string, url: string) {
    // 分享逻辑
  }

  /**
   * 收藏文章
   */
  private async collectArticle(id: number) {
    // 收藏逻辑
  }
}
```

### 4.3 JavaScript 调用原生方法

```html
<!-- 在 HTML 中调用 -->
<script>
// 获取 Token
const token = window.HarmonyBridge.getNativeToken();

// 分享文章
window.HarmonyBridge.share('文章标题', 'https://example.com');

// 收藏文章
window.HarmonyBridge.collectArticle('123').then(result => {
  if (result.success) {
    console.log('收藏成功');
  }
});
</script>
```

### 4.4 原生调用 JavaScript

```typescript
@Component
struct ArticleDetailPage {
  /**
   * 获取文章内容
   */
  async getArticleContent() {
    const content = await this.webViewController.runJavaScript(`
      (function() {
        return document.querySelector('.article-content').innerHTML;
      })();
    `);

    console.log('文章内容:', content);
  }

  /**
   * 滚动到指定位置
   */
  scrollToPosition(y: number) {
    this.webViewController.runJavaScript(`
      (function() {
        window.scrollTo(0, ${y});
      })();
    `);
  }

  /**
   * 高亮关键词
   */
  highlightKeyword(keyword: string) {
    this.webViewController.runJavaScript(`
      (function() {
        const content = document.querySelector('.article-content');
        const regex = new RegExp('${keyword}', 'gi');
        content.innerHTML = content.innerHTML.replace(regex, '<mark>$&</mark>');
      })();
    `);
  }
}
```

---

## 五、链接拦截处理

### 5.1 拦截链接点击

```typescript
@Component
struct ArticleDetailPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Web({
      src: this.url,
      controller: this.webViewController
    })
      // 拦截 URL 跳转
      .onInterceptRequest((event) => {
        const url = event.request.getRequestUrl();

        // 判断是否需要拦截
        if (this.shouldIntercept(url)) {
          console.log('拦截链接:', url);
          // 处理拦截逻辑
          this.handleInterceptedUrl(url);
          // 返回空响应阻止跳转
          return webview.WebResourceResponse.create('', '', '');
        }

        // 正常请求
        return null;
      })
  }

  /**
   * 判断是否需要拦截
   */
  private shouldIntercept(url: string): boolean {
    // 拦截特定域名
    if (url.includes('wanandroid.com')) {
      return true;
    }

    // 拦截特殊协议
    if (url.startsWith('native://')) {
      return true;
    }

    return false;
  }

  /**
   * 处理拦截的 URL
   */
  private handleInterceptedUrl(url: string) {
    if (url.includes('article')) {
      // 提取文章 ID，跳转到原生文章详情页
      const articleId = this.extractArticleId(url);
      router.pushUrl({
        url: 'pages/ArticleDetailPage',
        params: { articleId }
      });
    } else if (url.startsWith('native://')) {
      // 处理自定义协议
      const action = url.replace('native://', '');
      this.handleNativeAction(action);
    }
  }

  /**
   * 提取文章 ID
   */
  private extractArticleId(url: string): string {
    const match = url.match(/article\/(\d+)/);
    return match ? match[1] : '';
  }

  /**
   * 处理原生动作
   */
  private handleNativeAction(action: string) {
    // 处理自定义动作
    switch (action) {
      case 'login':
        router.pushUrl({ url: 'pages/LoginPage' });
        break;
      case 'profile':
        router.pushUrl({ url: 'pages/ProfilePage' });
        break;
    }
  }
}
```

---

## 六、优化 WebView 性能

### 6.1 启用硬件加速

```typescript
Web({
  src: this.url,
  controller: this.webViewController
})
  // 启用硬件加速
  .hardwareAccelerated(true)
  // 启用缓存
  .cacheMode(webview.CacheMode.Default)
```

### 6.2 预加载 WebView

```typescript
@Component
struct ArticleListPage {
  private preloadWebViewController: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      // 文章列表
      List() {
        ForEach(this.articles, (article) => {
          ListItem() {
            ArticleItem({ article: article })
              .onClick(() => {
                // 跳转到详情页
                router.pushUrl({
                  url: 'pages/ArticleDetailPage',
                  params: { url: article.link }
                });
              })
          }
        })
      }

      // 隐藏的预加载 WebView
      Web({
        src: '',
        controller: this.preloadWebViewController
      })
        .width(0)
        .height(0)
        .visibility(Visibility.Hidden)
    }
  }

  /**
   * 预加载下一篇文章
   */
  preloadNextArticle(url: string) {
    this.preloadWebViewController.loadUrl(url);
  }
}
```

### 6.3 优化加载速度

```typescript
@Component
struct ArticleDetailPage {
  build() {
    Web({
      src: this.url,
      controller: this.webViewController
    })
      // 启用 DOM Storage
      .domStorageAccess(true)
      // 启用数据库
      .databaseAccess(true)
      // 缓存模式
      .cacheMode(webview.CacheMode.Default)
      // 混合内容模式
      .mixedMode(webview.MixedMode.All)
      // 缩放支持
      .zoomAccess(false)
      // 用户代理
      .userAgent('Mozilla/5.0 (Linux; Android 12; HarmonyOS) AppleWebKit/537.36')
  }
}
```

---

## 七、常见问题与解决方案

### 7.1 WebView 内存泄漏

**问题**：WebView 页面关闭后内存没有释放

**解决方案**：
```typescript
@Component
struct ArticleDetailPage {
  private webViewController: webview.WebviewController = new webview.WebviewController();

  aboutToDisappear() {
    // 清理 WebView
    this.webViewController.deleteJavaScriptRegister();
    this.webViewController.clearHistory();
  }
}
```

### 7.2 JavaScript 不执行

**问题**：注入的 JavaScript 代码不生效

**解决方案**：
```typescript
// 确保启用了 JavaScript
Web({
  src: this.url,
  controller: this.webViewController
})
  .javaScriptAccess(true)  // 必须启用

// 等待页面加载完成
.onPageEnd(() => {
  // 在页面加载完成后执行
  this.webViewController.runJavaScript('console.log("Hello")');
})
```

### 7.3 文件上传问题

**问题**：WebView 中的文件上传不工作

**解决方案**：
```typescript
// 配置文件访问权限
Web({
  src: this.url,
  controller: this.webViewController
})
  .domStorageAccess(true)
  .fileAccess(true)  // 允许访问文件
  .onFileSelectorShow((event) => {
    // 处理文件选择
    console.log('File selector show:', event);
  })
  .onFileSelectorHide(() => {
    console.log('File selector hide');
  })
```

---

## 八、总结

WebView 与原生交互的关键点：

✅ **Cookie 同步**：手动设置请求头或 JavaScript 注入
✅ **JSBridge**：使用 registerJavaScriptProxy 实现双向通信
✅ **链接拦截**：onInterceptRequest 拦截特定 URL
✅ **性能优化**：硬件加速、预加载、缓存策略
✅ **内存管理**：页面销毁时清理 WebView

---

**相关文章**：
- 05 - HarmonyOS 网络请求最佳实践（待发布）
- 16 - UniApp 调用 HarmonyOS 原生组件（待发布）

**标签**：#HarmonyOS #WebView #混合开发 #JSBridge
