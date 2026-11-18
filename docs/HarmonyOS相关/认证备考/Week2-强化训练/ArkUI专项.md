# ArkUI 强化专项

> **执行时间**: 2026-03-31
> **任务**: Task 4
> **状态**: 已完成

---

## 一、高频 ArkUI 考点整理

### 1. 状态管理装饰器（核心重点）

| 装饰器 | 用途 | 数据流 | 共享范围 | 注意事项 |
|--------|------|--------|----------|----------|
| @State | 组件内私有状态 | - | 否 | 只能装饰简单类型或被@Observed装饰的类 |
| @Prop | 父到子单向传递 | 拷贝 | 否 | 父组件变化时拷贝给子组件 |
| @Link | 父到子双向绑定 | 引用 | 否 | 子组件变化会更新父组件 |
| @Provide | 祖先向后代提供 | - | 是 | 必须配合@Consume使用 |
| @Consume | 响应@Provide | - | 是 | 被动接收变化 |
| @StorageLink | AppStorage双向 | - | 是 | 与AppStorage双向同步 |
| @ObjectLink | 对象引用观测 | 引用 | 是 | 配合@Observed使用 |

#### @State vs @Prop vs @Link 区别

```typescript
// @State：组件私有，适合简单值
@State count: number = 0

// @Prop：单向拷贝，父到子，父变子不变（子组件内部副本）
@Prop title: string

// @Link：双向绑定，父到子引用，父变子变，子变父变
@Link user: User
```

#### @Observed / @ObjectLink 原理

```typescript
// 1. @Observed 装饰类，使其属性可被观测
@Observed
class User {
  name: string
  address: Address  // 嵌套对象也需要@Observed
}

@Observed
class Address {
  city: string
}

// 2. @ObjectLink 装饰属性，建立双向绑定
@ObjectLink user: User

// 原理：
// - @Observed 标记类为可观测
// - 嵌套对象变化时自动通知UI刷新
// - @ObjectLink 建立引用绑定
```

#### @ObservedV2 / @Trace（新一代）

```typescript
// 使用 @ObservedV2 和 @Trace 替代旧的 @Observed/@ObjectLink
@ObservedV2
class Person {
  @Trace age: number = 100  // @Trace 追踪属性变化

  @Trace son = new Son()     // 嵌套对象自动追踪
}

@ObservedV2
class Son {
  @Trace weight: number = 200
}
```

### 2. 动态渲染（高频考点）

#### if/else vs ForEach vs LazyForEach

| 渲染方式 | 适用场景 | 性能 | 注意事项 |
|----------|----------|------|----------|
| if/else | 条件显示/隐藏 | 一般 | 切换时销毁重建 |
| ForEach | 小列表（<100项） | 一般 | 键值不能重复 |
| LazyForEach | 大列表（推荐>50项） | 优化 | 按需渲染，滚动性能好 |

```typescript
// ForEach 基本用法
ForEach(
  this.array,
  (item: Item, index: number) => {
    ItemComponent({ item: item })
  },
  (item: Item, index: number) => item.id.toString()  // 键值函数
)

// LazyForEach 优化大列表
LazyForEach(
  this.dataSource,
  (item: Item, index: number) => {
    ItemComponent({ item: item })
  },
  (item: Item, index: number) => item.id.toString()
)
```

### 3. 组件生命周期

#### Ability 生命周期
```
onCreate → onWindowStageCreate → onForeground → onBackground → onDestroy
```

| 阶段 | 说明 |
|------|------|
| onCreate | Ability创建，仅调用一次 |
| onWindowStageCreate | 窗口创建，可进行UI操作 |
| onForeground | Ability可见，进入前台 |
| onBackground | Ability不可见，进入后台 |
| onDestroy | Ability销毁，释放资源 |

#### 页面生命周期
```
aboutToAppear → build → aboutToDisappear
```

| 阶段 | 说明 |
|------|------|
| aboutToAppear | 即将显示，初始化操作 |
| build | 首次构建UI |
| aboutToDisappear | 即将销毁，清理操作 |

### 4. 自定义组件

#### @Component 装饰器
```typescript
@Component
struct MyComponent {
  @State message: string = "Hello"

  build() {
    Text(this.message)
  }
}
```

#### @Builder 装饰器
```typescript
// 普通Builder
@Builder MyBuilder(title: string) {
  Text(title)
}

// 调用
this.MyBuilder("标题")

// @BuilderParam - 传入UI定义
@BuilderParam customBuilder: () => void
```

#### @Styles 和 @Extend
```typescript
// @Styles - 复用样式
@Styles
function commonStyles() {
  .width('100%')
  .height(44)
  .backgroundColor('#00FF00')
}

// @Extend - 扩展组件样式
@Extend(Text)
function longText() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
}
```

### 5. 动画与转场

| 动画类型 | API | 适用场景 |
|----------|-----|----------|
| 显式动画 | animateTo | 属性变化动画 |
| 隐式动画 | transition | 组件出现/消失 |
| 路径动画 | propertyAnimation | 沿路径移动 |

```typescript
// animateTo 显式动画
animateTo({
  duration: 300,
  curve: Curve.EaseOut
}, () => {
  this.scale += 0.1
})

// transition 转场动画
transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
```

### 6. 手势处理

| 手势 | 类 | 优先级 |
|------|-----|--------|
| 点击 | TapGesture | 低 |
| 长按 | LongPressGesture | 中 |
| 滑动 | PanGesture | 高 |
| 缩放 | PinchGesture | 高 |
| 旋转 | RotationGesture | 高 |

```typescript
// 手势竞争
PanGesture()
  .onStart(() => { })
  .onUpdate((event: GestureEvent) => {
    this.offsetX = event.localX
  })
  .onEnd(() => { })
```

---

## 二、ArkUI 专项错题记录

### 题目1
**题目**: @State 装饰器可以装饰以下哪种类型？
- A. 简单类型（number, string, boolean）
- B. 被 @Observed 装饰的类
- C. 普通类（未装饰）
- D. 数组类型

**正确答案**: A, B
**解析**: @State只能装饰简单类型和被@Observed装饰的类。普通类和数组不能直接作为@State的类型。

**错误原因**: 对@State的限制条件理解不深

---

### 题目2
**题目**: 下列关于 @Link 和 @Prop 的说法正确的是？
- A. @Link和@Prop的数据流都是单向的
- B. @Link是双向绑定，@Prop是单向拷贝
- C. @Link和@Prop都是双向绑定
- D. @Link是单向传递，@Prop是双向绑定

**正确答案**: B
**解析**: @Link建立父组件和子组件之间的双向数据绑定。@Prop是父到子的单向拷贝，子组件内部有一份独立的副本。

**错误原因**: 混淆了@Link和@Prop的数据流方向

---

### 题目3
**题目**: ForEach 和 LazyForEach 的主要区别是？
- A. ForEach支持条件渲染，LazyForEach不支持
- B. LazyForEach按需渲染，性能更好
- C. ForEach不支持键值函数
- D. 两者没有区别

**正确答案**: B
**解析**: LazyForEach会按需渲染列表项，当列表项滑出屏幕时会销毁，滑入时重新创建，适合大列表优化。

**错误原因**: 对LazyForEach的性能优势理解不足

---

### 题目4
**题目**: @Observed 装饰的类中，嵌套对象是否也需要 @Observed 装饰？
- A. 不需要，所有嵌套对象都会自动被观测
- B. 需要，否则嵌套对象变化不会触发UI更新
- C. 只有第一层嵌套需要
- D. 取决于对象大小

**正确答案**: B
**解析**: @Observed只装饰顶层类，嵌套对象需要单独@Observed装饰才能被观测到变化。

**错误原因**: 对@Observed的作用域理解有误

---

### 题目5
**题目**: 页面生命周期中，aboutToAppear 和 aboutToDisappear 的调用时机是？
- A. aboutToAppear在build之前，aboutToDisappear在build之后
- B. aboutToAppear在build之后，aboutToDisappear在build之前
- C. 两者都在build方法中调用
- D. 取决于页面复杂度

**正确答案**: A
**解析**: aboutToAppear在页面即将显示时调用（build之前），aboutToDisappear在页面即将销毁时调用。

**错误原因**: 对页面生命周期顺序记忆不准确

---

### 题目6
**题目**: 在 HarmonyOS 中，实现列表性能优化的最佳实践是？
- A. 使用ForEach替代LazyForEach
- B. 使用@State存储整个列表
- C. 使用LazyForEach配合@Reusable
- D. 减少build()方法中的计算

**正确答案**: C, D
**解析**: LazyForEach按需渲染，@Reusable减少组件创建开销，两者结合是最佳性能优化实践。

**错误原因**: 忽略了@Reusable的作用

---

## 三、状态管理 Demo 说明

详见: `entry/src/main/ets/pages/StateManagementDemo.ets`

该 Demo 包含：
1. @State 基本用法
2. @Prop 单向传递
3. @Link 双向绑定
4. @Observed / @ObjectLink 嵌套对象
5. @Provide / @Consume 跨层级共享
6. @StorageLink AppStorage 持久化
7. @ObservedV2 / @Trace 新一代状态管理

---

## 四、关键考点速记

### 状态管理
- **@State**: 组件私有，简单值
- **@Prop**: 单向拷贝，父到子
- **@Link**: 双向绑定，引用传递
- **@Observed**: 让类可被观测
- **@ObjectLink**: 配合@Observed建立引用

### 生命周期
- **Ability**: onCreate → onWindowStageCreate → onForeground → onBackground → onDestroy
- **页面**: aboutToAppear → build → aboutToDisappear

### 渲染优化
- **大列表**: LazyForEach > ForEach
- **@Reusable**: 减少组件创建
- **减少build()计算**: 避免重复创建对象

---

## 五、相关文档

- 状态管理Demo: `entry/src/main/ets/pages/StateManagementDemo.ets`
- ObservedV2测试: `entry/src/main/ets/pages/ObservedV2TestPage.ets`
- ArkUI官方文档: HarmonyOS应用开发文档 - ArkUI声明式开发
