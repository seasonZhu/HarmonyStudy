# WebView与HarmonyOS交互：iOS开发者的踩坑笔记

> 咳咳，说到WebView混合开发这件事，我真的是一把辛酸泪。当年在iOS上搞WKWebView和H5交互，用WKScriptMessageHandler，一顿操作下来bug比代码还多。如今到了HarmonyOS，发现WebView的API设计竟然比iOS还优雅，但是！但是！该踩的坑一个也没少。今天就和大家好好聊聊HarmonyOS的WebView交互。

---

## 一、WebView 基础使用

### 1.1 Web 组件简介

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

说实话，HarmonyOS的Web组件用起来比iOS的WKWebView简单多了，至少不用写那堆代理方法。

---

## 二、Cookie 同步问题

### 2.1 问题分析

```
┌─────────────────────────────────────────┐
│         原生 APP                        │
│  AccountManager.getToken() → "xxx"      │
├─────────────────────────────────────────┤
│         WebView                         │
│  document.cookie → undefined ❌         │
└─────────────────────────────────────────┘
```

但是！但是！在iOS上这个问题更坑，WKWebView的cookie同步简直是噩梦。

### 2.2 解决方案

```typescript
private syncCookie() {
  const token = AccountManager.getInstance().getToken();
  if (token) {
    this.webViewController.setRequestHeader([
      { key: 'Cookie', value: token }
    ]);
  }
}
```

---

## 三、JSBridge 设计

### 3.1 注册 JavaScript 接口

```typescript
this.webViewController.registerJavaScriptProxy({
  getNativeToken: () => {
    return AccountManager.getInstance().getToken();
  },
  share: (title: string, url: string) => {
    this.shareArticle(title, url);
    return { success: true };
  }
}, 'HarmonyBridge', ['getNativeToken', 'share']);
```

### 3.2 JavaScript 调用

```javascript
const token = window.HarmonyBridge.getNativeToken();
window.HarmonyBridge.share('标题', 'https://example.com');
```

---

## 四、链接拦截处理

```typescript
.onInterceptRequest((event) => {
  const url = event.request.getRequestUrl();
  if (this.shouldIntercept(url)) {
    this.handleInterceptedUrl(url);
    return webview.WebResourceResponse.create('', '', '');
  }
  return null;
})
```

---

## 五、总结

WebView 与原生交互的关键点：

✅ **Cookie 同步**：手动设置请求头
✅ **JSBridge**：使用 registerJavaScriptProxy 实现双向通信
✅ **链接拦截**：onInterceptRequest 拦截特定 URL
✅ **性能优化**：硬件加速、预加载、缓存策略

说实话，HarmonyOS的WebView API比iOS的WKWebView简洁多了，至少不用写一堆代理方法。但是！但是！该踩的坑还是得踩。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)

---

