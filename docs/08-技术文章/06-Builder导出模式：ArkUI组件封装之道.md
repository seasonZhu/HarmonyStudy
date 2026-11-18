# HarmonyOS Builder 导出模式：ArkUI 组件封装之道

> 咳咳，说到 ArkUI 的组件封装，我想起当年在 iOS 开发的时候，UIViewController 的初始化那叫一个痛苦——init、initWithNibName、initWithCoder，一大堆初始化方法看得眼花缭乱。到了 HarmonyOS 这边，ArkUI 给了我们 @Builder 和 @Component 两个利器，但问题来了——什么时候该用 @Builder？什么时候该用 @Component？今天就和大家好好聊聊 ArkUI 组件封装之道。

## 1. 灵魂拷问：@Builder 和 @Component 有什么区别？

聊到 ArkUI 组件封装，这是个必须回答的问题。

| 对比维度 | @Builder | @Component |
|---------|----------|------------|
| **封装粒度** | 方法级：封装一段 UI | struct级：封装完整组件 |
| **作用域** | 默认只能在本 struct 内部调用 | 导出后可在任意文件使用 |
| **状态管理** | 无状态（状态在宿主） | 可独立管理状态 |
| **使用场景** | 页面内 UI 片段复用 | 跨页面通用组件 |
| **导出能力** | export 后可跨文件调用 | export 后可跨文件调用 |

简单说：
- **@Builder**：像写方法一样写 UI，适合页面内部复用
- **@Component**：像写类一样写组件，适合跨文件复用

---

## 1. @Builder 封装：页面内的 UI 片段

### 1.1 为什么需要 @Builder？

看 Home.ets 里的例子：

```typescript
struct Home {
  @State listData: Article[] = []
  @State refreshing: boolean = false

  build() {
    NavDestination() {
      Column() {
        // 这里有一大段列表 UI
        List({ space: 0 }) {
          LazyForEach(this.listData, (item: Article) => {
            ListItem() {
              InfoCell({ article: item })
            }
          })
        }
        .cachedCount(10)
        .width("100%")
        // ... 更多配置
      }
    }
    .title($r('app.string.home'))
  }
}
```

如果这段列表 UI 在多个地方用，只能复制粘贴。但用了 @Builder：

```typescript
struct Home {
  @State listData: Article[] = []

  build() {
    NavDestination() {
      Column() {
        // 一行调用搞定
        this.getListView()
      }
    }
  }

  // ✅ 用 @Builder 封装 UI 片段
  @Builder
  private getListView() {
    List({ space: 0 }) {
      LazyForEach(this.listData, (item: Article) => {
        ListItem() {
          InfoCell({ article: item })
        }
      })
    }
    .cachedCount(10)
    .width("100%")
  }
}
```

**核心要点**：

| 特性 | 说明 |
|------|------|
| **调用方式** | 在同一个 struct 里像普通方法一样调用 `this.getListView()` |
| **作用域** | 默认只能在本 struct 内部使用 |
| **参数** | 可以接收参数，跟普通方法一样 |

### 1.2 项目实战：NativeComponentsDemo 的 @Builder 封装

看 `NativeComponentsDemo.ets` 这个页面，里面全是 @Builder 封装：

```typescript
@Entry({routeName: RouterName.NativeComponentsDemo})
@ComponentV2
struct NativeComponentsDemo {

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 页面标题
          this.HeaderSection()

          // 使用说明
          this.UsageSection()

          // 1. 原生按钮组件
          this.NativeButtonSection()

          // 2. 相机组件
          this.NativeCameraSection()

          // 3. 定位组件
          this.NativeLocationSection()

          // ...
        }
      }
    }
  }

  // 每个 @Builder 方法封装一个 UI 区块
  @Builder
  HeaderSection() {
    Column() {
      Text('原生嵌入组件')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('uni-app 小程序可直接使用这些组件')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 20, left: 16, right: 16 })
  }

  // ✅ 带参数的 Builder
  @Builder
  UsageItem(text: string) {
    Text(text)
      .fontSize(14)
      .fontColor('#666666')
      .margin({ top: 4 })
  }

  @Builder
  NativeButtonSection() {
    Column() {
      Row() {
        Column() {
          Text('原生按钮')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text('增强版按钮，支持防抖、触觉反馈')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('按钮')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#2C86EF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      // ...
    }
  }

  // 另一个带参数的 Builder
  @Builder
  ComponentTagItem(tag: string, description: string) {
    Row() {
      Text(tag)
        .fontSize(14)
        .fontColor('#2C86EF')
        .fontFamily('monospace')
        .layoutWeight(1)

      Text(description)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor('#F8F8F8')
    .margin({ top: 8 })
  }
}
```

**为什么这样封装？**

1. **页面逻辑清晰**：每个 @Builder 方法负责一个 UI 区块，build() 方法变成目录
2. **代码可读性高**：扫一眼 build() 就知道页面结构
3. **复用方便**：带参数的 Builder 如 `UsageItem()`、`ComponentTagItem()` 可在不同地方调用

### 1.3 @Builder 封装的设计思路

| 场景 | 用 @Builder 的理由 |
|------|-------------------|
| **列表项** | 封装重复的列表 item 样式 |
| **状态 UI** | loading、error、empty 等状态 UI |
| **区块组件** | 页面内的固定区块（Header、Footer、Section） |
| **条件渲染** | 根据状态显示不同 UI 片段 |
| **复杂布局** | 把一个复杂布局拆成多个 Builder 方法 |

---

## 2. @Component 封装：可复用的独立组件

### 2.1 什么时候用 @Component？

当一个组件需要：
- **独立的状态管理**
- **跨文件复用**
- **完整的生命周期**

就用 @Component。

### 2.2 项目实战：StatusWeight 状态布局组件

看 `StatusWeight.ets`：

```typescript
@ComponentV2
export struct StatusWeight {
  @Param status: ViewStatus = ViewStatus.loading

  /** 内容构建器（success 状态显示） */
  @BuilderParam contentBuilder: () => void

  /** 自定义 loading 构建器 */
  @BuilderParam loadingBuilder?: () => void

  /** 自定义 error 构建器 */
  @BuilderParam errorBuilder?: () => void

  /** 自定义 empty 构建器 */
  @BuilderParam emptyBuilder?: () => void

  /** 错误提示文字 */
  @Param errorText: ResourceStr = $r('app.string.request_failed_retry')

  /** 空状态提示文字 */
  @Param emptyText: ResourceStr = $r('app.string.no_data')

  // ... 更多配置参数

  build() {
    Column() {
      this.statusUI()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private statusUI() {
    if (this.status === ViewStatus.loading) {
      if (this.loadingBuilder) {
        this.loadingBuilder()
      } else {
        this.loading()
      }
    } else if (this.status === ViewStatus.error) {
      if (this.errorBuilder) {
        this.errorBuilder()
      } else {
        this.error()
      }
    } else if (this.status === ViewStatus.empty) {
      if (this.emptyBuilder) {
        this.emptyBuilder()
      } else {
        this.empty()
      }
    } else {
      this.contentBuilder()
    }
  }

  @Builder
  private loading() {
    Column() {
      LoadingProgress()
        .color($r('app.color.app_blue'))
        .width(60)
        .height(60)

      Text(this.loadingText)
        .margin({ top: this.textMarginTop })
        .fontSize(this.textSize)
        .fontColor($r('app.color.text_secondary'))
    }
    // ...
  }

  @Builder
  private error() {
    Column() {
      Image(this.errorIcon)
        .height(this.iconSize)
        .width(this.iconSize)

      Text(this.errorText)
        .margin({ top: this.textMarginTop })
        .fontSize(this.textSize)
        .fontColor($r('app.color.text_secondary'))

      if (this.onRetry) {
        Button($r('app.string.retry'))
          .margin({ top: 24 })
          .onClick(() => {
            this.onRetry?.()
          })
      }
    }
    // ...
  }
}
```

**使用方式**：

```typescript
// Home.ets 中使用
StatusWeight({
  status: this.status,
  contentBuilder: () => {
    this.getRefreshView()
  },
  onRetry: () => {
    LogUtil.debug($r('app.string.click_retry'))
  },
})
```

**@Component 封装的设计思路**：

| 要素 | 说明 |
|------|------|
| **@BuilderParam** | 注入外部 Builder 函数，实现自定义 |
| **@Param** | 接收外部配置（文案、图标、回调） |
| **内部 @Builder** | 封装默认实现，用户不传 builder 时使用 |
| **状态切换** | 根据 status 决定显示哪个 UI |

### 2.3 项目实战：ArticleMetaRow 文章元信息组件

看 `ArticleMetaRow.ets`：

```typescript
@Component
export struct ArticleMetaRow {
  @Prop article: Article
  @Prop showAuthor: boolean = true

  build() {
    Row() {
      if (this.showAuthor) {
        Text(this.getAuthorName())
          .fontSize(12)
      }

      this.TagComponent()  // 内部 @Builder 调用

      Blank()

      Text(this.article.niceShareDate)
        .fontSize(12)
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(8)
  }

  private getAuthorName(): string {
    if (this.article.author !== "") {
      return this.article.author
    } else if (this.article.shareUser !== "") {
      return this.article.shareUser
    } else {
      return "佚名"
    }
  }

  @Builder
  TagComponent() {
    Row() {
      if (this.article.type === 1) {
        Text('置顶')
          .margin({ left: 6 })
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .fontColor(Color.Red)
          .border({ color: Color.Red, radius: 6, width: 1 })
          .fontSize(10)
      }

      if (this.article.fresh) {
        Text('新')
          .margin({ left: 6 })
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .fontColor($r('app.color.purple500'))
          .border({ color: Color.Orange, radius: 6, width: 1 })
          .fontSize(10)
      }

      ForEach(this.article.tags, (value: ArticleTag, index: number) => {
        Text(value.name)
          .margin({ left: 6 })
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .fontColor($r('app.color.app_blue'))
          .border({ color: $r('app.color.app_blue'), radius: 8, width: 1 })
          .fontSize(10)
      })
    }
  }
}
```

**特点**：
- **@Component struct**：导出为可复用组件
- **内部 @Builder**：封装 `TagComponent()`，build() 方法里直接调用
- **@Prop**：接收外部数据，状态由外部管理

---

## 3. @Builder export：路由标准化（顺带一提）

> 这个就是顺带一提的标准用法，占文章 10% 篇幅即可。

### 3.1 为什么需要 Builder 导出？

NavPathStack 路由系统需要配置 routerMap，框架通过 `buildFunction` 字段找到 Builder 函数来创建页面。

```typescript
// Login.ets
@Entry({routeName: RouterName.Login})
@ComponentV2
struct Login {
  @Local username: string = ""
  @Local password: string = ""

  build() {
    NavDestination() {
      Column() {
        // 登录表单 UI...
      }
    }
    .title($r('app.string.login'))
  }
}

// ✅ 导出 Builder 函数，给 routerMap 用
@Builder
export function LoginBuilder() {
  Login()
}
```

### 3.2 routerMap.json 配置

```json
{
  "routerMap": [
    {
      "name": "Login",
      "pageSourceFile": "src/main/ets/pages/Login.ets",
      "buildFunction": "LoginBuilder"
    },
    {
      "name": "Home",
      "pageSourceFile": "src/main/ets/pages/Home.ets",
      "buildFunction": "HomeBuilder"
    }
  ]
}
```

### 3.3 注意事项

| 场景 | 注意事项 |
|------|----------|
| **Builder 函数名** | 必须与 routerMap.json 中的 buildFunction 一致 |
| **@Entry 装饰器** | 带有 @Entry 的页面才能作为独立页面存在 |
| **export 关键字** | Builder 函数必须用 export 导出 |
| **NavDestination** | Builder 函数内部需要用 NavDestination 包裹页面内容 |
| **参数传递** | Builder 函数无参数，通过 navPathStack.pushPath 的 params 传递 |

---

## 4. 总结：什么时候用什么

| 场景 | 推荐方案 |
|------|----------|
| **页面内 UI 片段复用** | `@Builder` 方法 |
| **带参数的 UI 片段** | `@Builder(param: type)` |
| **跨页面的通用组件** | `@Component export struct` |
| **需要状态管理的组件** | `@Component` + `@State`/`@Local` |
| **路由页面注册** | `@Builder export function XxxBuilder()` |
| **布局容器（接受 Builder 内容）** | `@Component` + `@BuilderParam` |

**核心思想**：
- **@Builder**：方法级别的 UI 封装，适合"一段 UI"
- **@Component**：类级别的组件封装，适合"一个组件"

两者配合使用，才是 ArkUI 组件封装的正确姿势。

---

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)