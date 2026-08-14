# HarmonyOS @ObservedV2 深度解析：嵌套对象追踪终于不累了

> 咳咳，说到状态管理这个话题，我想起当年在 iOS 开发的时候，用 RxSwift 折腾响应式编程，那叫一个酸爽。后来到了 Flutter，用 Provider/Bloc，嵌套数据一多，setState 就满天飞。到了 HarmonyOS 这边，一开始我用 @Observed，发现嵌套对象根本追踪不到，UI 就是不刷新。直到我遇到了 @ObservedV2，我才发现——原来嵌套对象追踪可以这么简单。今天就和大家好好聊聊这个话题。

## 1. 先说痛点

聊到状态管理，我们经常会遇到这么几个问题：

- **嵌套对象不更新**：子对象的属性变了，UI 就是不刷新
- **手动刷新麻烦**：每次都要手动调用 update，或者用 computed 计算属性
- **深层对象追踪难**：对象套对象，套个三四层，根本不知道谁变了
- **性能问题**：整个对象替换才能触发更新，性能损耗大

但是！但是！用了 @ObservedV2 之后，这些问题都能封装得服服帖帖的。

## 2. 先来看看对比

### 2.1 @Observed 的问题

```typescript
// @Observed 方案 - 有问题的写法
@Observed
class Person {
  age: number = 100
  son = new Son()  // 嵌套对象
}

@Observed
class Son {
  weight: number = 200
}

@Entry
@Component
struct MyPage {
  person = new Person()

  build() {
    Column() {
      Text(`年龄: ${this.person.age}`)
      Text(`体重: ${this.person.son.weight}`)  // ❌ UI不刷新！

      Button("改年龄")
        .onClick(() => {
          this.person.age++  // ✅ 这个会刷新
        })

      Button("改体重")
        .onClick(() => {
          this.person.son.weight++  // ❌ 这个不会刷新！
        })
    }
  }
}
```

你说烦不烦？`person.son.weight` 变了，UI 就是不刷新。原因在于 **@Observed 只能追踪到第一层属性的变化**。

### 2.2 @ObservedV2 的解决

```typescript
// @ObservedV2 方案 - 正确的写法
@ObservedV2
class Person {
  @Trace
  age: number = 100

  @Trace
  son = new Son()  // 嵌套对象也要加 @Trace
}

@ObservedV2
class Son {
  @Trace
  weight: number = 200
}

@Entry
@Component
struct MyPage {
  person = new Person()

  build() {
    Column() {
      Text(`年龄: ${this.person.age}`)
      Text(`体重: ${this.person.son.weight}`)  // ✅ UI刷新了！

      Button("改年龄")
        .onClick(() => {
          this.person.age++  // ✅ 刷新
        })

      Button("改体重")
        .onClick(() => {
          this.person.son.weight++  // ✅ 刷新了！
        })
    }
  }
}
```

妙不妙？只需要两步：

1. **类名上加 `@ObservedV2`**
2. **属性上加 `@Trace`**

## 3. 核心代码展示

**Talk is cheap, show me the code**

### 3.1 项目中的实际代码

```typescript
// ObservedV2TestPage.ets
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

@Entry
@Component
struct ObservedV2TestPage {
  person = new Person()

  build() {
    NavDestination() {
      Column() {
        // Person 状态卡片
        Column() {
          Text('Person 对象')
          Text(`${this.person.age} 岁`)
            .fontSize(24)
            .fontColor('#2C86EF')

          Button("person的age" + this.person.age)
            .onClick(() => {
              this.person.age++
            })
        }

        // Son 状态卡片
        Column() {
          Text('Son 对象')
          Text(`${this.person.son.weight} kg`)
            .fontSize(24)
            .fontColor('#FF6B6B')

          Button("son的weight" + this.person.son.weight)
            .onClick(() => {
              this.person.son.weight++
            })
        }
      }
    }
  }
}
```

### 3.2 @ObservedV2 vs @Observed

| 特性 | @Observed | @ObservedV2 |
|------|-----------|-------------|
| 嵌套对象追踪 | ❌ 不支持 | ✅ 支持 |
| 语法 | `@Observed class X {}` | `@ObservedV2 class X {}` |
| 属性标记 | 无需标记 | `@Trace` 标记需要追踪的属性 |
| 性能 | 一般 | 优化更好 |
| 嵌套深度 | 有限制 | 无限制 |

这个设计思路之所以优雅，根本原因在于：

1. **装饰器模式**：通过 `@Trace` 明确标记需要追踪的属性
2. **自动代理**：框架自动生成代理对象，拦截属性访问
3. **细粒度更新**：只更新变化的属性，性能更好

## 4. 原理剖析

### 4.1 @Trace 做了什么

```typescript
// @Trace 的作用
@Trace
age: number = 100

// 相当于自动生成了
private _age: number = 100

get age(): number {
  return this._age
}

set age(value: number) {
  this._age = value
  // 通知框架，这个属性变化了，需要刷新UI
}
```

### 4.2 嵌套对象处理

```typescript
@ObservedV2
class Person {
  @Trace
  age: number = 100

  @Trace
  son = new Son()  // Son 也是 @ObservedV2 类
}
```

当 `person.son.weight++` 执行时：

1. **获取 `person.son`** → 触发 `son` 的 getter，返回 `Son` 实例
2. **修改 `weight`** → 触发 `Son` 内部 `weight` 的 setter
3. **通知框架** → `Son` 的 `weight` 属性变化了
4. **UI 刷新** → 使用 `person.son.weight` 的 Text 组件刷新

关键点：**嵌套的对象也必须是 `@ObservedV2` 类**！

## 5. 注意事项

| 场景 | 注意事项 |
|------|----------|
| **嵌套对象必须标注** | `son = new Son()` 中的 `Son` 也必须是 `@ObservedV2` 类 |
| **基本类型必须加 @Trace** | `age: number` 这种基本类型必须加 `@Trace` |
| **对象数组** | 数组元素是对象时，也需要对象类是 `@ObservedV2` |
| **不要过度使用** | 只需要响应式追踪的属性才加 `@Trace` |
| **性能考虑** | @Trace 会增加一些开销，不要给所有属性都加 |

## 6. 应用场景

### 6.1 用户信息管理

```typescript
@ObservedV2
class UserInfo {
  @Trace
  username: string = ""

  @Trace
  avatar: string = ""

  @Trace
  profile = new UserProfile()
}

@ObservedV2
class UserProfile {
  @Trace
  bio: string = ""

  @Trace
  location: string = ""
}
```

### 6.2 购物车

```typescript
@ObservedV2
class CartItem {
  @Trace
  id: number = 0

  @Trace
  count: number = 0

  @Trace
  product = new Product()
}

@ObservedV2
class Product {
  @Trace
  name: string = ""

  @Trace
  price: number = 0
}
```

## 7. 对比 iOS 的 KVO

说实话，相比 iOS 的 KVO 机制，@ObservedV2 也是毫不逊色的：

| 特性 | iOS KVO | HarmonyOS @ObservedV2 |
|------|---------|----------------------|
| 嵌套对象 | 需手动 observe | 自动追踪 |
| 语法 | addObserver/removeObserver | @ObservedV2 + @Trace |
| 内存管理 | 手动管理 | 自动管理 |
| 性能 | 一般 | 优化更好 |
| 学习成本 | 较高 | 低 |

iOS KVO 胜在**生态成熟**，@ObservedV2 胜在**简单易用**。

## 总结

HarmonyOS 的 @ObservedV2，我这段时间用下来是真的香：

1. **@ObservedV2**：标注类需要响应式管理
2. **@Trace**：标注属性需要追踪变化
3. **嵌套对象自动追踪**：子对象属性变化也能感知
4. **细粒度更新**：只更新变化的属性
5. **语法简洁**：相比 iOS KVO，上手简单太多

推荐在需要**嵌套对象响应式管理**、**简化状态管理代码**的场景下使用 @ObservedV2。

大家有什么好的思路与想法欢迎分享，我们下期见！

---

## 相关链接

- **GitHub 仓库**：[HarmonyStudy](https://github.com/seasonZhu/HarmonyStudy)
- **iOS版 RxStudy**：[RxStudy](https://github.com/seasonZhu/RxStudy)
- **Flutter版 GetXStudy**：[GetXStudy](https://github.com/seasonZhu/GetXStudy)
- **官方文档**：[HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- **玩安卓**：[WanAndroid API](https://www.wanandroid.com/blog/show/2)
