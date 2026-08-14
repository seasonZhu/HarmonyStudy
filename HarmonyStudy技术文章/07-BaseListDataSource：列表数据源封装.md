# HarmonyOS BaseListDataSource：列表数据源封装 so easy

> 咳咳，说到列表数据源这个话题，我想起当年在 iOS 开发的时候，用 UITableView 的 dataSource，动不动就写一堆样板代码——numberOfSections、numberOfRowsInSection、cellForRowAt，一个列表写下来，手指都酸了。后来到了 Flutter，用 ListView.builder，虽然好了一点，但数据源管理还是得自己来。到了 HarmonyOS 这边，官方给了我们 IDataSource 接口 + BaseListDataSource，用起来那是真的香。今天就和大家好好聊聊这个话题。

## 1. 先说痛点

聊到列表开发，我们经常会遇到这么几个问题：

- **数据源管理麻烦**：数据数组、操作方法分散，代码不集中
- **刷新通知繁琐**：手动调用 notifyDataChanged，一不小心就忘了
- **分页加载复杂**：下拉刷新、上拉加载，数据合并逻辑一堆
- **类型安全差**：any 类型满天飞，编译时发现不了问题

但是！但是！用了 BaseListDataSource 之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                      BaseListDataSource                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   IDataSource 接口                           │  │
│  │  - totalCount(): number                                     │  │
│  │  - getData(index: number): T                                │  │
│  │  - registerDataChangeListener(listener)                     │  │
│  │  - unregisterDataChangeListener(listener)                   │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                      │
│                              ▼                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   BaseListDataSource<T>                      │  │
│  │                                                             │  │
│  │  originData: T[]          // 原始数据                       │  │
│  │  listeners: DataChangeListener[]  // 监听器数组              │  │
│  │                                                             │  │
│  │  addData()               // 添加单条数据                    │  │
│  │  addListData()           // 添加多条数据                    │  │
│  │  removeAll()             // 清空数据                       │  │
│  │  remove()                // 删除单条数据                    │  │
│  │                                                             │  │
│  │  notifyDataReload()      // 通知刷新                       │  │
│  │  notifyDataAdd()         // 通知添加                       │  │
│  │  notifyDataChange()      // 通知变化                        │  │
│  │  notifyDataDelete()      // 通知删除                       │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

这个架构图看起来清晰明了，核心就是那个 **IDataSource 接口 + 数据操作方法**。BaseListDataSource 封装了所有列表数据操作，配合 LazyForEach 使用，简洁又高效。

## 3. 核心代码展示

### 3.1 BaseListDataSource 实现

**Talk is cheap, show me the code**

```typescript
// BaseListDataSource.ets
export class BaseListDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  public originData: T[] = []

  // IDataSource 实现
  totalCount(): number {
    return this.originData.length
  }

  getData(index: number): T {
    return this.originData[index]
  }

  // 注册数据变更监听器
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // 取消注册
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  // 添加单条数据
  addData(data: T, withNotify: boolean = true) {
    this.originData.push(data)
    if (withNotify) {
      this.notifyDataAdd(this.originData.length - 1)
    }
  }

  // 添加多条数据
  addListData(data: T[], withNotify: boolean = true) {
    if (data.length === 0) {
      return
    }
    let oldIndex = this.originData.length - 1
    data.forEach((item) => {
      this.originData.push(item)
    })
    if (withNotify) {
      for (let index = oldIndex; index < this.originData.length; index++) {
        this.notifyDataAdd(index)
      }
    }
  }

  // 清空数据
  removeAll(withNotify: boolean = true) {
    this.originData = []
    if (withNotify) {
      this.notifyDataReload()
    }
  }

  // 删除单条数据
  remove(index: number, withNotify: boolean = true) {
    this.originData.splice(index, 1)
    if (withNotify) {
      this.notifyDataReload()
    }
  }

  // 通知刷新
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  // 通知添加
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  // 通知变化
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }
}
```

### 3.2 Page 中使用

```typescript
// Home.ets
@Entry
@Component
struct Home {

  @State dataSource: BaseListDataSource<Banner> = new BaseListDataSource<Banner>()
  @State listDataSource: BaseListDataSource<Article> = new BaseListDataSource<Article>()

  build() {
    NavDestination() {
      List({ space: 0, scroller: this.scroller }) {
        // Banner
        ListItem() {
          BannerView({
            data: $dataSource,
            itemClick: (item) => {
              // 点击事件
            }
          })
        }

        // 文章列表
        LazyForEach(this.listDataSource, (item: Article) => {
          ListItem() {
            InfoCell({
              article: item,
              onItemClick: (article) => {
                // 处理点击
              }
            })
          }
        })
      }
    }
  }

  async aboutToAppear(): Promise<void> {
    // 模拟网络请求
    const response = await this.viewModel.getBanner()
    const banners = response.data.data
    // 添加 Banner 数据
    banners.forEach((banner) => {
      this.dataSource.addData(banner)
    })

    // 模拟文章请求
    const articleResponse = await this.viewModel.getArticles()
    const articles = articleResponse.data.data.datas
    // 添加文章数据
    this.listDataSource.addListData(articles)
  }
}
```

### 3.3 下拉刷新 + 上拉加载

```typescript
// Home.ets
@Builder
private getRefreshView() {
  PullToRefresh({
    pullToRefreshType: PullToRefreshType.LIST,
    refreshing: $refreshing,
    customList: () => {
      this.getListView()
    },
    onRefresh: async () => {
      // 下拉刷新
      this.dataSource.removeAll(false)  // 不通知刷新
      this.listDataSource.removeAll(false)

      const results = await this.viewModel.networkRequest(ScrollActionType.refresh)
      // 处理数据...
      return '刷新成功'
    },
    onLoadMore: () => {
      return new Promise((resolve, reject) => {
        // 上拉加载
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
```

## 4. BaseListDataSource vs 传统数组

| 特性 | 传统数组 | BaseListDataSource |
|------|----------|-------------------|
| 数据操作 | 手动 push/splice | addData/addListData/remove |
| 刷新通知 | 手动调用 | 自动通知 |
| 懒加载 | 无 | LazyForEach 原生支持 |
| 类型安全 | any | 泛型 T |
| 分页加载 | 复杂 | 简单（addListData） |

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **泛型 T** | BaseListDataSource<T>，T 是数据类型 |
| **LazyForEach** | 必须配合 LazyForEach 使用，才能发挥懒加载优势 |
| **withNotify** | 操作数据时可以选择是否通知刷新，减少不必要的刷新 |
| **监听器管理** | BaseListDataSource 内部自动管理监听器，无需手动处理 |
| **数据合并** | 分页加载时用 addListData，刷新时用 removeAll + addListData |

## 6. 对比 iOS 的 UITableViewDataSource

说实话，相比 iOS 的 UITableViewDataSource，BaseListDataSource 也是毫不逊色的：

| 特性 | iOS UITableViewDataSource | ArkUI BaseListDataSource |
|------|---------------------------|-------------------------|
| 接口方法 | numberOfSections/cellForRow | totalCount/getData |
| 刷新方法 | reloadData | notifyDataReload |
| 局部刷新 | deleteRows/insertRows | notifyDataAdd/delete |
| 懒加载 | 手动实现 | LazyForEach 原生支持 |
| 类型安全 | 需手动转换 | 泛型保证 |

iOS 方案胜在**生态成熟**，BaseListDataSource 胜在**简洁易用**。

## 总结

HarmonyOS 的 BaseListDataSource，我这段时间用下来是真的香：

1. **泛型支持**：类型安全，IDE 自动提示
2. **自动通知**：数据操作后自动通知列表刷新
3. **懒加载支持**：配合 LazyForEach，性能更好
4. **分页友好**：addListData 一行搞定数据合并
5. **代码简洁**：再也不用写一堆样板代码

推荐在需要**列表展示**、**分页加载**、**下拉刷新**的场景下使用 BaseListDataSource。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
