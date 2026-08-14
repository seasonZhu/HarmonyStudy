# HarmonyOS开发wandroid客户端项目实践：iOS开发者的纯血HarmonyOS踩坑记

> 咳咳，说到跨平台开发这件事，我真的是一把辛酸泪。从iOS原生开发入行，后来做Flutter跨平台，再后来又搞Android原生，如今又跳到了HarmonyOS。各位同学不要学我，技术栈太多真的会被"全干"——这个词在我们组已经是梗了。

学HarmonyOS也有大半年时间了，从最初对着文档CV战士，到自己尝试封装网络层、封装路由，再到折腾@ObservedV2状态管理，一路走来踩的坑能写三篇连载。今天就和大家好好聊聊**HarmonyStudy**这个项目——一个基于ArkTS + ArkUI的WanAndroid客户端。

---

## 一、为什么选择 WanAndroid API？

聊到移动端学习，为啥大家都在接WanAndroid API？主要有这么几个原因：

### 1.1 API 设计规范，功能完整

WanAndroid API 涵盖了一个成熟 APP 应具备的大部分功能：
- ✅ 用户系统（登录、注册、积分、排行）
- ✅ 内容展示（首页、项目、公众号、体系）
- ✅ 文章系统（列表、详情、收藏）
- ✅ 搜索功能（热词、实时搜索、历史记录）
- ✅ 交互体验（下拉刷新、上拉加载）

但是！但是！我做iOS开发那会儿，可没有这么好的API让我练手。

### 1.2 便于验证框架能力

使用同一套 API，可以专注于**HarmonyOS平台框架的探索**，验证各种功能的实现效果；同时也可以将以往的在不同平台开发的经验迁移过来，对比异同。

就像我从RxSwift迁移到Flutter的GetX，再迁移到HarmonyOS的@State，这个思路之所以迁移成本低，**根本原因在于设计模式是相通的**。

---

## 二、技术选型：从iOS到HarmonyOS的心路历程

### 2.1 我踩过的那些坑

做iOS开发的时候，我最喜欢用RxSwift写响应式代码。后来公司要做跨平台，我被迫去学Flutter，一开始内心是拒绝的——"说句实话，作为一个iOS开发，其实我打一开始是有些拒绝Flutter的"。

但是！但是！当我真正上手Flutter之后，发现Flutter是响应式的状态绘制UI的框架，其枚举的羸弱，让Swift与Kotlin的惯用者只能叹息一声。

到了HarmonyOS这边，我发现ArkUI和Flutter真的很像

### 2.2 技术栈确定

```
┌─────────────────────────────────────┐
│         ArkTS (开发语言)             │
│   - 类型安全 - 静态类型检查          │
│   - 协程支持 - 简洁的异步编程        │
│   - 方舟编译 - 高效运行             │
├─────────────────────────────────────┤
│         ArkUI (UI 框架)              │
│   - 声明式 UI - 数据驱动渲染         │
│   - 组件化 - 高度复用               │
│   - Navigation - 原生路由导航        │
├─────────────────────────────────────┤
│         @State + BaseListDataSource │
│   - 简洁的状态管理                  │
│   - 数据源模式管理列表              │
├─────────────────────────────────────┤
│         @ohos/axios (网络)          │
│   - 拦截器模式 - 统一处理            │
│   - 环境切换 - 开发/生产             │
└─────────────────────────────────────┘
```

我之所以选择这套方案，**根本原因在于**：

1. **ArkTS类型安全**：相比Flutter的Dart，ArkTS的类型系统更接近Swift，上手成本低
2. **声明式UI**：ArkUI和SwiftUI、Flutter一样都是声明式，写法统一
3. **拦截器模式**：Axios的拦截器和iOS的Alamofire、Android的OkHttp一样，都是经典设计

---

## 三、项目架构设计

### 3.1 状态管理：@State + BaseListDataSource

学iOS的时候，我用RxSwift做响应式状态管理。但是！但是！在HarmonyOS里面，我发现这套更香：

```typescript
// 页面中使用 @State 定义状态
@Entry
@Component
struct Home {
  @State dataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()
  @State status: ViewStatus = ViewStatus.loading

  // 使用 LazyForEach 配合数据源
  LazyForEach(this.dataSource, (item: Article) => {
    ListItem() {
      ArticleCell({ article: item })
    }
  }, (item: Article) => item.id.toString())
}
```

对比一下iOS的写法：

| 平台 | 数据源模式 | 懒加载 |
|------|-----------|--------|
| iOS (UITableView) | dataSource + delegate | 手动实现 |
| Flutter (ListView) | ListView.builder | 默认懒 |
| HarmonyOS (List) | BaseListDataSource + LazyForEach | 原生支持 |

**BaseListDataSource 实现**（实现 IDataSource 接口）：

```typescript
export class BaseListDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  public originData: T[] = []

  public addData(data: T, withNotify: boolean = true) {
    this.originData.push(data)
    if (withNotify) {
      this.notifyDataAdd(this.originData.length - 1)
    }
  }

  public removeAll(withNotify: boolean = true) {
    this.originData = []
    if (withNotify) {
      this.notifyDataReload()
    }
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // ... 其他方法
}
```

这个设计思路之所以优雅，**根本原因在于**：IDataSource接口是HarmonyOS原生设计的，配合LazyForEach使用，可以实现真正的懒加载列表。

### 3.2 路由管理：从Router.push()到NavPathStack

聊到路由，iOS开发那会儿我用过天安门式的路由方案——URL路由、协议路由、各种Hack。后来到了Android，用ARouter，也是配置满天飞。

但是！但是！HarmonyOS的NavPathStack让我眼前一亮：

```typescript
// 简单跳转 - 一个方法搞定
navPathStack.pushPath({ name: 'Login' })

// 带参数跳转
navPathStack.pushPath({ name: 'Detail', params: { id: 1 } })

// 获取参数 - 两种方式
aboutToAppear(): void {
  let params = navPathStack.getParamByName('Detail') as any[]
}

NavDestination() {
  // ...
}
.onReady((context: NavDestinationContext) => {
  let params = context.pathStack.getParamByName('Detail') as any[]
})
```

对比一下各平台路由：

| 平台 | 路由方案 | 参数传递 | 类型安全 |
|------|---------|---------|---------|
| iOS | 第三方库/自己封 | URL/属性 | 弱 |
| Android | ARouter | URL/Bundle | 弱 |
| HarmonyOS | NavPathStack | params对象 | 强 |

### 3.3 架构分层

```
entry/src/main/ets/
├── pages/                    # 页面组件
│   ├── Home.ets              # 首页
│   ├── SearchResult.ets      # 搜索结果
│   └── WebPage.ets           # WebView页面
├── viewModel/                # 视图模型
│   ├── HomeViewModel.ets
│   └── SearchResultViewModel.ets
├── views/                    # 可复用视图组件
│   ├── ArticleCell.ets       # 文章列表项
│   └── BannerView.ets        # 轮播图组件
├── model/                    # 数据模型
│   ├── Article.ets           # 文章实体
│   ├── Banner.ets           # 轮播图实体
│   └── BaseListDataSource.ets # 列表数据源
├── httpRequest/              # 网络请求封装
│   ├── Provider.ets          # Axios 实例
│   └── interceptors/         # 拦截器
├── router/                   # 路由管理
│   ├── navPathStack.ets     # NavPathStack单例
│   └── NavPathStackHolder.ets
├── accountManager/           # 账户管理（单例）
├── utils/                    # 工具类
│   ├── ListDataProcessor.ets # 列表数据处理器
│   ├── ToastUtil.ets         # 吐司工具
│   └── LoadingDialogHelper.ets # 加载弹窗
└── enum/                     # 枚举定义
    ├── ViewStatus.ets        # 视图状态
    └── ScrollActionType.ets  # 滚动操作类型
```

---

## 四、核心设计原则

### 4.1 纯原生开发

> **UI 和组件全部使用 HarmonyOS 原生框架**

- ✅ 原生 Navigation 导航
- ✅ 原生 List + LazyForEach 列表
- ✅ 原生 PullToRefresh 下拉刷新
- ✅ 原生 Web 组件（文章详情）

我之所以坚持纯原生开发，**根本原因在于**：跨平台框架总有你够不到的底层能力，不如一开始就用原生，至少踩坑的边界是清晰的。

### 4.2 最小依赖

```json
{
  "dependencies": {
    "@ohos/axios": "^2.2.7",           // 网络请求
    "@ohos/pulltorefresh": "^3.0.0",    // 下拉刷新
    "@ohos/imageknife": "^3.2.8",       // 图片加载
    "@pura/harmony-utils": "^1.4.0",   // 工具类库
    "@jxt/xt_hud": "^3.4.0"             // 弹窗组件
  }
}
```

各位同学，这个依赖数量比我之前做Flutter项目少多了，Flutter随便一个App，pubspec.yaml都是几十行起步。

### 4.3 统一列表处理

项目实现了 `ListDataProcessor` 统一处理列表数据：

```typescript
// 处理分页列表数据
ListDataProcessor.processPagedListData(
  dataSource,
  response,
  ScrollActionType.refresh,
  (status: ViewStatus) => {
    this.status = status
  }
)

// 处理混合数据（Banner + Article）
ListDataProcessor.processMixedData(
  bannerDataSource,
  listDataSource,
  results,
  ScrollActionType.refresh,
  (status: ViewStatus) => { this.status = status },
  (hotArticles, normalArticles) => hotArticles.concat(normalArticles)
)
```

这个思路之所以...**根本原因在于**：首页数据有Banner和Article两种类型，混合数据的处理逻辑如果不封装，每个页面都得写一遍。

### 4.4 网络请求封装

使用 `@ohos/axios` + 拦截器模式，对比一下iOS的Alamofire：

```typescript
export class Provider extends BaseProvider {
  // 配置请求拦截器
  configurationRequestInterceptor(): List<AxiosClientRequestInterceptor> {
    let interceptors = new List<AxiosClientRequestInterceptor>()
    interceptors.add(new SetCookieRequestInterceptor())  // Cookie 设置
    interceptors.add(new HttpRequestLoggerInterceptor())  // 请求日志
    return interceptors
  }

  // 配置响应拦截器
  configurationResponseInterceptor(): List<AxiosClientResponseInterceptor> {
    let interceptors = new List<AxiosClientResponseInterceptor>()
    interceptors.add(new HttpResponseLoggerInterceptor()) // 响应日志
    return interceptors
  }
}
```

对比表格：

| 特性 | iOS Alamofire | HarmonyOS Axios |
|------|---------------|-----------------|
| 请求拦截 | RequestInterceptor | AxiosClientRequestInterceptor |
| 响应拦截 | ResponseInterceptor | AxiosClientResponseInterceptor |
| 适配器 | Adapter | - |
| 合并器 | Retrier | onRejected |
| 链式执行 | 闭包链式调用 | forEach + use |

说实话，Axios的拦截器用起来比Alamofire简单多了，配置化程度也更高。

### 4.5 环境切换支持

```typescript
export enum Environment {
  DEV = 'dev',
  TEST = 'test',
  PROD = 'prod'
}

// 支持开发/生产环境切换
Provider.initEnvironment()
Provider.getCurrentEnvironment()
Provider.getBaseUrl()
```

这个设计思路之所以...**根本原因在于**：开发和生产环境的baseURL不一样，如果每次切换都要改代码，那上线前忘改了可就GG了。

---

## 五、HarmonyOS 开发实战技巧

### 5.1 列表性能优化：LazyForEach

```typescript
// 使用 LazyForEach 实现懒加载
LazyForEach(this.dataSource, (item: Article) => {
  ListItem() {
    ArticleCell({ article: item })
  }
}, (item: Article) => item.id.toString())
//                        ↑ 必须提供唯一 key

// 配合 BaseListDataSource 使用
.cachedCount(5)  // 缓存数量
```

这里有个小坑要提醒大家：**LazyForEach的第三个参数（唯一key）必须提供**，否则列表渲染会出问题。这个我一开始写的时候愣是搞错了，调了半天都不知道为啥列表显示不对。

### 5.2 Navigation 导航

```typescript
Navigation() {
  // 页面内容
}
.title('首页')
.mode(NavigationMode.Auto)
.titleMode(NavigationTitleMode.Mini)
.hideBackButton(true)  // 隐藏返回按钮
.menus([                // 导航栏菜单
  { value: 'search', action: () => {} }
])
```

### 5.3 状态管理：@ObservedV2（HarmonyOS 4.0+ 新特性）

项目中包含 `@ObservedV2` 测试页面：

```typescript
@ObservedV2
class Person {
  @Trace
  age: number = 100

  son = new Son()
}

@ObservedV2
class Son {
  @Trace
  weight: number = 200
}

// 嵌套对象自动响应
this.person.son.weight++  // UI 自动刷新
```

但是！但是！说实话，@ObservedV2我目前用得还不多，主要项目还是用@State + BaseListDataSource。@ObservedV2作为新特性探索，后续再慢慢迁移。

### 5.4 登录拦截器封装

```typescript
// 路由层面封装登录检查
navPathStack.setInterception({
  willShow(from, to) {
    const pageName = to.pathInfo?.name
    if (AuthNames.includes(pageName)) {
      const accountManager = AccountManager.shared()
      if (!accountManager.isLogin()) {
        promptAction.showToast({
          message: '当前用户未登录，请先登录'
        })
        to.pathStack.pop()
        to.pathStack.pushPath({ name: 'Login' })
      }
    }
  }
})
```

这个设计思路之所以优雅，**根本原因在于**：登录拦截统一在NavPathStack配置，不用在每个页面单独判断，舒服。

---

## 六、iOS开发者的HarmonyOS学习路线

作为一个从iOS转过来的开发者，我总结了一套学习路线：

```
1. ArkTS 基础语法（1周）
   - 类型系统 - 接口、泛型、装饰器
   - 异步编程 - Promise、async/await
   ↓
2. ArkUI 组件系统（2周）
   - 基础组件 - Text、Image、Button
   - 容器组件 - Column、Row、Stack
   - 列表组件 - List、LazyForEach
   ↓
3. 状态管理（1周）
   - @State 基础状态
   - @Link/@Prop 父子通信
   - IDataSource 数据源模式
   ↓
4. 网络与路由（1周）
   - @ohos/axios 使用
   - NavPathStack 路由
   ↓
5. 实战项目（4周+）
```

说实话，学了这么多语言下来，我发现**编程语言没有特定的墙，你所谓的墙都是自己给自己界定的**。Python和Swift，API上的远方亲戚嘛。

---

## 总结

好了，今天就聊到这里。HarmonyStudy项目的核心价值：

✅ **纯血 HarmonyOS**：完全使用 ArkTS + ArkUI 原生开发
✅ **简洁状态管理**：@State + BaseListDataSource 方案
✅ **NavPathStack 路由**：配置化路由 + 登录拦截
✅ **最小依赖**：只引入必要的第三方库
✅ **统一数据处理**：ListDataProcessor 处理分页/混合数据
✅ **完整网络层**：Axios + 拦截器 + 环境切换

这个项目不仅是 WanAndroid API 的 HarmonyOS 实现，更是一个**iOS开发者视角的HarmonyOS开发实践**。希望它能帮助更多从iOS/Flutter转过来的同学快速上手HarmonyOS。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)

---

