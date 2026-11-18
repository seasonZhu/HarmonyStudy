# 多端一致的状态组件：StatusWeight 在 HarmonyOS 的实现与思考

## **前言**

本文源于在 Swift、Flutter 项目中沉淀的状态管理思路，通过 ArkUI 在 HarmonyOS 中实现相同的设计。核心价值在于：**思路统一，多端实现一致，降低维护成本**。

---

## 一、问题背景：重复的状态页面

一个完整的状态页面应该包括：**加载中、成功、错误、空数据**。如果每个页面都重复实现这些状态，会产生大量冗余代码。

以一个常见的列表页为例：

```typescript
// 每个页面都要写类似这样的状态判断
if (isLoading) {
  // 显示加载中
} else if (hasError) {
  // 显示错误
} else if (isEmpty) {
  // 显示空数据
} else {
  // 显示内容
}
```

这种重复不仅存在于单个平台，在 **Swift / Flutter / HarmonyOS** 三个平台中都在反复出现。

---

## 二、跨平台思路一致性问题

### 2.1 Swift 的解决方案

在 Swift 项目中，我们定义了统一的状态类型和视图构建器：

```swift
// SwiftUIExample/State/State.swift

/// D 代表数据，V 代表视图
typealias BuilderWidget<D, V: View> = (D) -> V

/// 视图状态枚举
enum ViewState<D> {
    case loading
    case error(_ retry: (() -> Void)?)
    case success(_ success: ViewSuccess)

    enum ViewSuccess {
        case noData
        case content(_ dataSource: D)
    }
}

/// 通用状态视图组件
struct ViewMaker<D, V: View>: View {
    @Binding var viewState: ViewState<D>
    let builder: BuilderWidget<D, V>

    var body: some View {
        switch viewState {
        case .loading:
            ProgressView()
        case .error(let retry):
            VStack {
                Text("Error")
                Button("重试") { retry?() }
            }
        case .success(let viewSuccess):
            switch viewSuccess {
            case .noData:
                Text("no data")
            case .content(let dataSource):
                builder(dataSource)
            }
        }
    }
}
```

**设计要点**：
- `ViewState<D>` 泛型枚举，封装所有状态
- `ViewMaker<D, V>` 通用组件，统一处理状态切换
- `builder` 回调注入实际内容

### 2.2 Flutter 的解决方案

在 Flutter 项目中，我们采用了几乎完全一致的设计：

```dart
// getx_study/lib/pages/common/status_view.dart

/// 响应状态枚举
enum ResponseStatus {
  loading,
  fail,
  successHasContent,
  successNoData,
}

/// 状态视图组件
class StatusView<T extends BaseController> extends StatelessWidget {
  final Widget? loadingView;
  final WidgetBuilder<T>? errorViewBuilder;
  final WidgetBuilder<T> contentBuilder;
  final WidgetBuilder<T>? emptyViewBuilder;

  const StatusView({
    this.loadingView,
    this.errorViewBuilder,
    required this.contentBuilder,
    this.emptyViewBuilder,
    this.tag
  });

  Widget responseStatusWidgetWithSwitch(T controller) {
    switch (controller.status) {
      case ResponseStatus.loading:
        return loadingView ?? const LoadingView();
      case ResponseStatus.fail:
        return _errorView(controller);
      case ResponseStatus.successHasContent:
        return contentBuilder(controller);
      case ResponseStatus.successNoData:
        return _emptyView(controller);
    }
  }
}
```

**设计要点**：
- `ResponseStatus` 枚举定义所有状态
- `StatusView<T>` 泛型组件，接收 `contentBuilder` 注入实际内容
- 支持自定义各状态视图

### 2.3 思路对比

| 维度 | Swift | Flutter | 一致性 |
|------|-------|---------|--------|
| 状态定义 | `ViewState<D>` 枚举 | `ResponseStatus` 枚举 | ✅ |
| 状态种类 | loading / error / success(noData, content) | loading / fail / successHasContent / successNoData | ✅ |
| 组件设计 | `ViewMaker<D, V>` 泛型组件 | `StatusView<T>` 泛型组件 | ✅ |
| 内容注入 | `builder: (D) -> V` 回调 | `contentBuilder: (T) -> Widget` 回调 | ✅ |
| 状态切换 | `switch` 语句 | `switch` 语句 | ✅ |

**核心结论**：三个平台的设计思路完全一致，差异仅在于语言语法特性。

---

## 三、HarmonyOS 实现：StatusWeight

### 3.1 状态枚举定义

与 Swift / Flutter 一致，首先定义状态枚举：

```typescript
// utils/ListDataProcessor.ets
export enum ViewStatus {
  Loading = 0,
  Error = 1,
  Success = 2,
  Empty = 3
}
```

### 3.2 StatusWeight 组件实现

```typescript
// views/StatusWeight.ets
import { ViewStatus } from '../utils/ListDataProcessor';

/**
 * 状态页面组件
 *
 * 统一处理页面状态：加载中、成功、错误、空数据
 *
 * 设计思路与 Swift(ViewMaker) / Flutter(StatusView) 完全一致：
 * 1. 状态枚举定义
 * 2. 泛型组件统一处理
 * 3. contentBuilder 注入实际内容
 */
@Component
export struct StatusWeight {
  @Prop status: ViewStatus;
  @BuilderParam contentBuilder: () => void;
  @Prop onRetry?: () => void;

  // 自定义视图（可选）
  @BuilderParam loadingBuilder: () => void = this.DefaultLoadingContent;
  @BuilderParam errorBuilder: () => void = this.DefaultErrorContent;
  @BuilderParam emptyBuilder: () => void = this.DefaultEmptyContent;

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

  @Builder
  DefaultLoadingContent() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DefaultErrorContent() {
    Column() {
      Image($r('app.media.ic_error'))
        .width(120)
        .height(120)

      Text('加载失败')
        .fontSize(16)
        .fontColor('#333')
        .margin({ top: 16 })

      Text('点击重试')
        .fontSize(14)
        .fontColor('#007AFF')
        .margin({ top: 8 })
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#F0F8FF')
        .borderRadius(4)
        .onClick(() => {
          this.onRetry?.();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DefaultEmptyContent() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(120)
        .height(120)

      Text('暂无数据')
        .fontSize(16)
        .fontColor('#999')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
```

### 3.3 使用示例

```typescript
@Entry
@Component
struct HomePage {
  @State status: ViewStatus = ViewStatus.Loading;
  @State articleList: ArticleModel[] = [];

  aboutToAppear() {
    this.loadData();
  }

  build() {
    StatusWeight({
      status: this.status,
      contentBuilder: () => {
        this.ArticleListContent()
      },
      onRetry: () => {
        this.loadData();
      }
    })
  }

  @Builder
  ArticleListContent() {
    List() {
      ForEach(this.articleList, (article) => {
        ListItem() {
          ArticleItemView({ article: article })
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  async loadData() {
    this.status = ViewStatus.Loading;

    try {
      const data = await ArticleApi.getHomeArticles(0);
      this.articleList = data.datas.map(e => new ArticleModel(e));

      if (this.articleList.length === 0) {
        this.status = ViewStatus.Empty;
      } else {
        this.status = ViewStatus.Success;
      }
    } catch (error) {
      this.status = ViewStatus.Error;
    }
  }
}
```

### 3.4 自定义视图

```typescript
StatusWeight({
  status: this.status,
  contentBuilder: () => {
    this.Content()
  },
  onRetry: () => {
    this.loadData();
  },
  loadingBuilder: () => {
    // 自定义加载视图
    Column() {
      LottieView({ animation: 'loading.json' })
      Text('正在努力加载...')
    }
  },
  errorBuilder: () => {
    // 自定义错误视图
    Column() {
      Image($r('app.media.ic_network_error'))
      Text('网络开小差了')
      Button('刷新')
        .onClick(() => {
          this.onRetry?.();
        })
    }
  },
  emptyBuilder: () => {
    // 自定义空视图
    Column() {
      Image($r('app.media.ic_no_data'))
      Text('还没有内容')
      Button('去逛逛')
        .onClick(() => {
          router.pushUrl({ url: 'pages/DiscoverPage' });
        })
    }
  }
})
```

---

## 四、多平台实现对比

### 4.1 核心模式一致

```
┌─────────────────────────────────────────────────────────────┐
│                        核心设计模式                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐                                           │
│   │ 状态枚举定义  │ ──→ Swift: ViewState<D>                   │
│   │             │ ──→ Flutter: ResponseStatus               │
│   │             │ ──→ HarmonyOS: ViewStatus                  │
│   └─────────────┘                                           │
│          │                                                  │
│          ▼                                                  │
│   ┌─────────────┐                                           │
│   │ 通用组件      │ ──→ Swift: ViewMaker<D, V>                │
│   │             │ ──→ Flutter: StatusView<T>                │
│   │             │ ──→ HarmonyOS: StatusWeight               │
│   └─────────────┘                                           │
│          │                                                  │
│          ▼                                                  │
│   ┌─────────────┐                                           │
│   │ 内容注入     │ ──→ Swift: builder(dataSource)             │
│   │             │ ──→ Flutter: contentBuilder(controller)   │
│   │             │ ──→ HarmonyOS: contentBuilder()            │
│   └─────────────┘                                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 关键代码对比

**Swift**:
```swift
struct ViewMaker<D, V: View>: View {
    @Binding var viewState: ViewState<D>
    let builder: BuilderWidget<D, V>

    var body: some View {
        switch viewState {
        case .loading: return ProgressView()
        case .error(let retry): return Button("重试") { retry?() }
        case .success(let s): return builder(s.dataSource)
        }
    }
}
```

**Flutter**:
```dart
Widget responseStatusWidgetWithSwitch(T controller) {
  switch (controller.status) {
    case ResponseStatus.loading:
      return loadingView ?? const LoadingView();
    case ResponseStatus.fail:
      return _errorView(controller);
    case ResponseStatus.successHasContent:
      return contentBuilder(controller);
    case ResponseStatus.successNoData:
      return _emptyView(controller);
  }
}
```

**HarmonyOS**:
```typescript
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
```

---

## 五、总结

### 5.1 核心价值

| 价值点 | 说明 |
|--------|------|
| **思路统一** | 状态枚举 → 通用组件 → 内容注入，三端完全一致 |
| **代码复用** | 避免每个页面重复实现状态切换逻辑 |
| **灵活定制** | 支持自定义各状态的视图和样式 |
| **维护成本** | 一次设计，多端复用，修改时保持同步 |
| **学习成本** | 掌握一种实现，即可理解所有平台的实现 |

### 5.2 移动端一致性思考

在跨平台开发中，**语言差异不可避免，但设计思路应该统一**。当我们在 Swift 中沉淀了 `ViewMaker` 模式，在 Flutter 中自然地复用为 `StatusView`，如今在 HarmonyOS 中又是 `StatusWeight`。

这种一致性的价值在于：

1. **认知一致性**：开发者在任意平台积累的经验，可以无障碍地迁移到其他平台
2. **维护一致性**：当产品需求变更时，只需要在一个地方理解逻辑，然后同步修改
3. **团队协作**：不同平台开发者可以互相 review 代码，因为大家在说同一种"语言"

StatusWeight 组件不仅仅是一个组件，更是 **跨平台开发思维** 的体现：**抽象共同点，接受差异点，让一致性成为生产力**。
