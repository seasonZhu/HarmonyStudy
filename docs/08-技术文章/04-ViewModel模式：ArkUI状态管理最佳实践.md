# HarmonyOS ViewModel 模式：ArkUI 状态管理最佳实践

> 咳咳，说到 ViewModel 这个话题，我想起当年在 Android 开发的时候，用 Activity 管理一切，Activity 胖得像个 300 斤的孩子。后来 Google 出了 ViewModel，LiveData，数据和 UI 分离，代码瞬间清爽了。到了 HarmonyOS 这边，ArkUI 也给我们提供了一套状态管理方案——@State、@Link、@ObservedV2，配合 ViewModel 用起来也是相当顺手。今天就和大家好好聊聊 ViewModel 模式这个话题。

## 1. 先说痛点

聊到状态管理，我们经常会遇到这么几个问题：

- **UI 和业务逻辑耦合**：所有代码都写在 @Component 里，页面越来越胖
- **状态分散**：状态分布在各个组件里，不知道谁改了哪个值
- **生命周期管理麻烦**：网络请求发出去，用户点返回了，Activity 销毁了，结果回来了都不知道往哪儿塞
- **难以测试**：UI 和逻辑混在一起，单元测试根本没法写

但是！但是！用了 ViewModel 模式之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ViewModel 模式                               │
│                                                                     │
│  ┌───────────────────────┐      ┌───────────────────────┐         │
│  │        Page           │      │      ViewModel        │         │
│  │                       │      │                       │         │
│  │  @State data: Data    │ ←──→ │  networkRequest()    │         │
│  │  @State status: State │      │  saveData()          │         │
│  │                       │      │  loadData()          │         │
│  │  aboutToAppear() {    │      │                       │         │
│  │    vm.loadData()      │      │  // 业务逻辑          │         │
│  │  }                    │      │  // 网络请求          │         │
│  └───────────────────────┘      └───────────────────────┘         │
│                                                                     │
│  ┌───────────────────────┐      ┌───────────────────────┐         │
│  │       Model           │      │       Provider        │         │
│  │                       │ ←──→ │                       │         │
│  │  Article              │      │  httpClient           │         │
│  │  Banner               │      │  preferences          │         │
│  └───────────────────────┘      └───────────────────────┘         │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **ViewModel 分离 UI 和逻辑**。ViewModel 只管数据和业务，Page 只管展示。

## 3. 核心代码展示

### 3.1 ViewModel 定义

**Talk is cheap, show me the code**

```typescript
// HomeViewModel.ets
export class HomeViewModel {

  private pageNum = 1

  // 获取 Banner
  getBanner = (): Promise<AxiosResponse<BaseResponse<Banner[]>>> => {
    return httpClient.get('banner/json')
  }

  // 获取热门文章
  getHotArticle = (): Promise<AxiosResponse<BaseResponse<Article[]>>> => {
    return httpClient.get('article/top/json')
  }

  // 获取普通文章列表
  getNormalArticle = (page: number): Promise<AxiosResponse<BaseResponse<PageModel<Article>>>> => {
    let api = 'article/list/' + page + '/json'
    return httpClient.get(api)
  }

  // 网络请求 - 统一入口
  public networkRequest(type: ScrollActionType): Promise<HomeNetworkResponseType[]> {
    if (type == ScrollActionType.refresh) {
      this.pageNum = 1
      // 下拉刷新：同时请求 Banner、热门文章、普通文章
      return Promise.all([
        this.getBanner(),
        this.getHotArticle(),
        this.getNormalArticle(this.pageNum)
      ])
    } else {
      // 上拉加载：只请求普通文章
      this.pageNum = this.pageNum + 1
      return Promise.all([this.getNormalArticle(this.pageNum)])
    }
  }
}
```

### 3.2 Page 使用 ViewModel

```typescript
// Home.ets
@Entry
@Component
struct Home {

  @State dataSource: BaseListDataSource<Banner> = new BaseListDataSource<Banner>()
  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()
  @State status: ViewStatus = ViewStatus.loading
  @State refreshing: boolean = false

  private scroller = new Scroller()
  viewModel = new HomeViewModel()  // 实例化 ViewModel

  build() {
    NavDestination() {
      StatusWeight({
        status: this.status,
        contentBuilder: () => {
          this.getRefreshView()
        },
        onRetry: () => {
          LogUtil.debug($r('app.string.click_retry'))
        },
      })
    }
    .title($r('app.string.home'))
  }

  @Builder
  private getRefreshView() {
    PullToRefresh({
      pullToRefreshType: PullToRefreshType.LIST,
      refreshing: $refreshing,
      customList: () => {
        this.getListView()
      },
      onRefresh: async () => {
        let results = await this.viewModel.networkRequest(ScrollActionType.refresh)
        // 处理响应数据...
        return '刷新成功'
      },
      onLoadMore: () => {
        return new Promise((resolve, reject) => {
          this.viewModel.networkRequest(ScrollActionType.loadMore)
            .then((results) => {
              // 处理加载更多数据...
              resolve('上拉完成')
            })
            .catch(() => {
              resolve('上拉失败')
            })
        })
      },
    })
  }

  async aboutToAppear(): Promise<void> {
    // 页面加载时请求数据
    this.viewModel.networkRequest(ScrollActionType.refresh)
      .then((results) => {
        // 处理响应数据...
      })
      .catch((error) => {
        this.status = ViewStatus.error
      })
  }
}
```

### 3.3 LoginViewModel

```typescript
// LoginViewModel.ets
export interface LoginResult {
  success: boolean
  userInfo?: UserInfoModel
  errorCode?: number
}

export class LoginViewModel {

  // 登录
  public login(info: LoginOrRegisterInfo): Promise<boolean> {
    let api = 'user/login?username=' + info.username + '&password=' + info.password
    return new Promise<boolean>((resolve, _reject) => {
      httpClient.post(api)
        .then((response) => {
          if (response.data.errorCode == 0) {
            response.data.data.password = info.password
            AccountManager.shared().loginModel = response.data.data
            this.saveLoginOrRegisterInfo(info)
            resolve(true)
          } else {
            resolve(false)
          }
        })
        .catch((error) => {
          ErrorHandler.handle(error, '登录失败', false)
          resolve(false)
        })
    })
  }

  // 登录并获取用户信息
  public async loginWithUserInfo(info: LoginOrRegisterInfo): Promise<LoginResult> {
    try {
      const loginSuccess = await this.login(info)
      if (!loginSuccess) {
        return { success: false }
      }

      const response = await httpClient.get("lg/coin/userinfo/json")
      if (response.data.errorCode == 0) {
        return {
          success: true,
          userInfo: response.data.data
        }
      } else {
        return {
          success: false,
          errorCode: response.data.errorCode
        }
      }
    } catch (error) {
      ErrorHandler.handle(error, '登录流程失败')
      return { success: false }
    }
  }

  // 保存登录信息到本地
  async saveLoginOrRegisterInfo(info: LoginOrRegisterInfo) {
    PreferencesUtil.put("username", info.username)
    PreferencesUtil.put("password", info.password)
  }
}
```

## 4. ViewModel 模式的好处

| 好处 | 说明 |
|------|------|
| **UI 和逻辑分离** | ViewModel 只管数据和业务，Page 只管展示 |
| **生命周期安全** | ViewModel 比 Page 生命周期长，可以安全持有数据 |
| **可测试性** | ViewModel 是纯逻辑类，可以直接单元测试 |
| **代码复用** | 同一个 ViewModel 可以被多个 Page 使用 |
| **状态集中管理** | 状态在 ViewModel 中集中管理，清晰明了 |

## 5. 对比 iOS 的 MVVM

说实话，相比 iOS 的 MVVM 模式，ArkUI 的 ViewModel 也是毫不逊色的：

| 特性 | iOS MVVM | ArkUI ViewModel |
|------|----------|-----------------|
| 数据绑定 | Combine/ RxSwift | @State/@Link/@ObservedV2 |
| 生命周期 | ViewModel 比 VC 生命周期长 | ViewModel 比 Component 生命周期长 |
| 依赖注入 | 需要手动注入 | 直接 new |
| 网络请求 | 在 ViewModel 中 | 在 ViewModel 中 |
| UI 更新 | Publisher/Observable | 状态装饰器 |

iOS 方案胜在**响应式绑定更强大**，ArkUI 方案胜在**上手简单**。

## 6. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **ViewModel 实例化** | 在 Page 中直接 `new HomeViewModel()` 即可 |
| **生命周期** | ViewModel 生命周期比 Component 长，可以安全持有数据 |
| **状态更新** | ViewModel 中不要直接修改 @State，要返回数据让 Page 修改 |
| **网络请求** | 网络请求放在 ViewModel 中，Page 只调用方法 |
| **内存泄漏** | ViewModel 中不要持有 Page 的引用，避免内存泄漏 |

## 总结

HarmonyOS 的 ViewModel 模式，我这段时间用下来是真的香：

1. **UI 和逻辑分离**：ViewModel 只管数据和业务，Page 只管展示
2. **生命周期安全**：ViewModel 比 Component 生命周期长
3. **可测试性**：ViewModel 是纯逻辑类，可以直接单元测试
4. **代码复用**：同一个 ViewModel 可以被多个 Page 使用
5. **上手简单**：直接 new 实例即可，不需要复杂的依赖注入

推荐在需要**UI 和逻辑分离**、**提高代码可维护性**、**方便单元测试**的场景下使用 ViewModel 模式。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
