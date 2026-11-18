# 多端一致的状态组件：StatusWeight 在 HarmonyOS 的实现与思考

> 咳咳，说到状态管理这件事，我想起当年做iOS开发的时候，每个页面都要写一堆if-else判断loading、error、empty、success状态，代码写得我怀疑人生。后来我做了Flutter，又做了HarmonyOS，发现这个痛点居然是跨平台的。幸好，设计思路是相通的。

---

## 一、问题背景：重复的状态页面

一个完整的状态页面应该包括：**加载中、成功、错误、空数据**。如果每个页面都重复实现这些状态，会产生大量冗余代码。

但是！但是！这种重复不仅存在于单个平台，在 **Swift / Flutter / HarmonyOS** 三个平台中都在反复出现。

---

## 二、跨平台思路一致性

### 2.1 Swift 的解决方案

```swift
enum ViewState<D> {
    case loading
    case error(_ retry: (() -> Void)?)
    case success(_ success: ViewSuccess)
}

struct ViewMaker<D, V: View>: View {
    @Binding var viewState: ViewState<D>
    let builder: BuilderWidget<D, V>
}
```

### 2.2 Flutter 的解决方案

```dart
enum ResponseStatus {
  loading,
  fail,
  successHasContent,
  successNoData,
}

class StatusView<T extends BaseController> extends StatelessWidget {
  final WidgetBuilder<T> contentBuilder;
}
```

### 2.3 思路对比

| 维度 | Swift | Flutter | 一致性 |
|------|-------|---------|--------|
| 状态定义 | `ViewState<D>` 枚举 | `ResponseStatus` 枚举 | ✅ |
| 组件设计 | `ViewMaker<D, V>` | `StatusView<T>` | ✅ |
| 内容注入 | `builder: (D) -> V` | `contentBuilder: (T) -> Widget` | ✅ |

这个思路之所以...**根本原因在于**：设计模式是跨平台的，不同语言只是语法差异。

---

## 三、HarmonyOS 实现：StatusWeight

### 3.1 状态枚举定义

```typescript
export enum ViewStatus {
  Loading = 0,
  Error = 1,
  Success = 2,
  Empty = 3
}
```

### 3.2 StatusWeight 组件实现

```typescript
@Component
export struct StatusWeight {
  @Prop status: ViewStatus;
  @BuilderParam contentBuilder: () => void;
  @Prop onRetry?: () => void;

  build() {
    if (this.status === ViewStatus.Loading) {
      this.loadingBuilder()
    } else if (this.status === ViewStatus.Error) {
      this.errorBuilder()
    } else if (this.status === ViewStatus.Empty) {
      this.emptyBuilder()
    } else {
      this.contentBuilder()
    }
  }
}
```

### 3.3 使用示例

```typescript
StatusWeight({
  status: this.status,
  contentBuilder: () => {
    this.ArticleListContent()
  },
  onRetry: () => {
    this.loadData();
  }
})
```

---

## 四、核心价值

| 价值点 | 说明 |
|--------|------|
| **思路统一** | 状态枚举 → 通用组件 → 内容注入，三端完全一致 |
| **代码复用** | 避免每个页面重复实现状态切换逻辑 |
| **灵活定制** | 支持自定义各状态的视图和样式 |

这个思路之所以优雅，**根本原因在于**：跨平台开发中，语言差异不可避免，但设计思路应该统一。

---

## 五、总结

StatusWeight 组件不仅仅是一个组件，更是 **跨平台开发思维** 的体现：**抽象共同点，接受差异点，让一致性成为生产力**。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
