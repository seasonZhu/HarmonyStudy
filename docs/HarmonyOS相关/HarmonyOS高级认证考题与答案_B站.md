# HarmonyOS 应用开发者高级认证考题与答案

> **来源**：哔哩哔哩 - 平凡老师101
> **更新时间**：2024年10月
> **考试说明**：40个单选 + 20个多选，80分及格，选项顺序会打乱

---

## 📋 单选题

### 1. Row 组件排列方式
**题目**：如果要实现 Row 组件内的子元素均匀排列,且第一个元素与行首对齐,最后一个元素与行尾对齐,需要使用 justifyContent 的哪个枚举值?

**答案**：B. SpaceBetween

**解析**：
- `SpaceBetween`：首尾元素靠边，其余元素均匀分布
- `SpaceEvenly`：所有元素间距相等
- `Start`：左对齐
- `End`：右对齐

---

### 2. 半模态界面双向绑定
**题目**：为了使 isShow 参数值与半模态界面的状态同步，可以使用下列哪种方式双向绑定 isShow 参数？

**答案**：使用 `$$` 双向绑定语法

---

### 3. Grid 布局
**题目**：以下哪份代码可以实现 Grid 布局？

**答案**：通过设置不同 GridItem 的宽度实现

---

### 4. 创建 Module
**题目**：关于在 DevEco Studio 中创建 Module，下列选项哪种方式是错误的？

**答案**：
> 在 hvigor 目录下，单击鼠标右键，选择 New > Module，创建新的 Module；此时 module 将创建在该文件目录下。

---

### 5. 输入框自定义键盘
**题目**：如果想要设置输入框的自定义键盘，可以使用下面的哪个接口？

**答案**：A. customKeyboard

---

### 6. 图片缩放
**题目**：图片大小跟 Image 组件设置的宽高不匹配时，使用 objectFit 属性，不会缩放图片的类型是下面哪个选项？

**答案**：A. CENTER

---

### 7. Web 性能优化
**题目**：下述代码片段，使用了哪些基于 web 的性能优化手段？

```typescript
Web({ src: "https://www.example.com", controller: this.controller })
  .onPageEnd((event) => {
    this.controller.prefetchPage('https://www.example.com/nextpage')
  })
```

**答案**：D. 预加载

---

### 8. C++ 高级调试
**题目**：开发者小李使用 C++ 进行核心算法开发，需要查看代码历史执行路径，回溯到关键的变量状态。DevEco Studio 提供的哪个能力可以帮助他？

**答案**：反向调试能力

**解析**：允许开发者在调试过程中回退回到之前的代码行或断点，查看过去的堆栈信息，重现历史的全局、静态和局部变量状态。

---

### 9. 运行时调试
**题目**：开发者小张需要在应用已经运行的情况下介入调试，应该采用哪种调试方法？

**答案**：Attach Debugger to Process（附加调试）

---

### 10. DevEco Profiler
**题目**：DevEco Profiler 的设计核心和主要优势是什么？

**答案**：依据 Top-Down 设计理念，通过高度整合的数据展示范式，提供从宏观到微观的性能数据分析，加速开发者定位和解决问题的过程。

---

### 11. ArkTS 支持的函数
**题目**：arkts 支持以下哪个函数？

**答案**：D

---

### 12. 动画属性
**题目**：以下示例代码中，可以进行动画的属性有哪些？

```typescript
.width(this.compWidth)        // 1
.height(this.compHeight)     // 2
.animation({curve:Curve.Ease, duration:280})
.borderRadius(this.compRadius) // 3
```

**答案**：1、2、3 都可以

---

### 13. WebSocket 连接
**题目**：以下 WebSocket 连接开发的步骤顺序，描述错误的是？

**答案**：调用 Session.start 方法开启 metadata 数据输出（顺序错误）

---

### 14. HSP 按需加载
**题目**：某特性占用空间资源比较大，准备将该特性解耦出来，对外提供 API 方便主模块调用。以下说法正确的是？

**答案**：将该特性做成按需加载的 HSP 包，暴露接口给主模块使用。

---

### 15. HAP 打包
**题目**：以下关于 HAP(Harmony Ability Package)说法正确的是？

**答案**：应用工程如果包含多个 Module，在应用上架时，会将多个 .hap 文件打包成一个 .app 文件。

---

### 16. 逐帧调用接口
**题目**：我们需要避免在逐帧调用的接口中执行耗时操作，下面哪个选项不属于上述的接口？

**答案**：aboutToReuse

---

### 17. 静态检查
**题目**：关于静态检查描述错误的是？

**答案**：静态检查可以检测代码中的语法错误和潜在的逻辑错误，也支持检测代码在运行时出现的错误，因此静态检查可以替代动态测试。

---

### 18. UI 刷新
**题目**：依次点击 A、B、C、D 四个按钮，其中不会触发 UI 刷新的是？

**答案**：Button C（Jim 那个按钮）

---

### 19. 懒加载生效
**题目**：以下代码中，懒加载生效的是？

```typescript
// A
List() {
  ListItemGroup() {
    LazyForEach(this.data, (item:number)=>{...})
  }
}

// B
Scroll() {
  List() {
    LazyForEach(this.data, (item:number)=>{...})
  }
}

// C
List() {
  ListItem() {
    Column() {
      LazyForEach(this.data, (item: number) => {...})
    }
  }
}

// D
Scroll() {
  List() {
    LazyForEach(this.data, (item:number)=>{...})
  }
}
```

**答案**：C

**解析**：LazyForEach 必须在 List 或 ListItem 直接子组件下才能生效懒加载。

---

### 20. 应用进程数量
**题目**：应用只有一个 hap 包，包含 1 个 UIAbility(无 Web 组件)、1 个 FormExtensionAbility 组件、1 个 WorkSchedulerExtensionAbility 组件，那么该应用在运行过程中，最多会存在几个应用进程？

**答案**：3 个

---

### 21. UIAbility 启动模式
**题目**：UIAbilityA 的启动模式是 specified，AbilityStage 实现如下：依次调用 4 次启动 UIAbilityA，value 分别是"test"、"test"、"testA"、"testA"，则当前运行期 UIAbility 实例有几个？

**答案**：3 个

---

### 22. 应用安装操作
**题目**：下面安装应用操作错误的是？

**答案**：hdc install -p ohosapp.hap（错误，正确应为 `hdc install package.hap`）

---

### 23. 本地模拟器
**题目**：关于 DevEco Studio 本地模拟器所支持的规格与功能，哪一项描述是准确的？

**答案**：本地模拟器上运行的应用无需进行签名，简化了调试过程。

---

### 24. Navigation 路由栈
**题目**：PageOne 为 navigation 中的某一子页面，依次点击 toPageTwo 按钮、toPageOne 按钮，点击 get 按钮获取全部名为 name 的 NavDestination 页面的位置索引为？

**答案**：[0,2]

---

### 25. 路由栈数量
**题目**：接上题，此时获取当前页面的路由栈数量为多少？

**答案**：3

---

### 26. 模块解耦
**题目**：ModuleA → ModuleB/ModuleC，ModuleB → ModuleC/ModuleD，ModuleC → ModuleA，ModuleD → ModuleB/ModuleC，复杂的依赖关系导致需要解耦。以下哪个做法是不推荐的？

**答案**：采用静态 import 方式引入对应跳转的页面

---

### 27. 系统兼容性
**题目**：以下对系统兼容性的理解正确的是？

**答案**：已发布的系统能力有可能会发生非兼容性变更，比如特性或修改问题导致的行为不兼容，这种情况应用需要关注 changelog 并进行适配。

---

### 28. 持续交付
**题目**：下面交付&持续部署描述哪个是正确的？

**答案**：持续交付(CD,Continuous Delivery)：指的是，频繁的将软件的新版本，交付给质量团队或者用户，以供评审。如果评审通过，代码就进入生产阶段。

---

### 29. 资源文件目录
**题目**：以下关于资源说法错误的是？

**答案**：rawfile 目录，支持创建多层子目录，文件夹内可以自由放置各类资源文件。目录中的资源文件会被编译成二进制文件，并赋予资源 ID。（错误：rawfile 不会编译成二进制）

---

### 30. 配置文件错误
**题目**：module.json5 配置文件和 shortcuts_config.json 配置文件，一共存在有几处错误？

**答案**：1 处

---

### 31. 多设备构建配置
**题目**：项目需要为不同的设备形态(如手机、智能手表)提供定制化构建，如何在 DevEco Studio 中设置不同的构建配置？

**答案**：在模块级别 build-profile.json5 定义多个 target，在每个 target 的 config/deviceType 中定义不同的设备类型

---

### 32. 模块依赖配置
**题目**：feature 模块对 library 公共库模块有依赖，如何配置？

**答案**：在 feature 的 oh-package.json5 文件的 dependencies 字段中配置 library 的依赖

---

### 33. HAR 构建
**题目**：要对某个静态共享模块构建出静态构建包产物，如何构建？

**答案**：选中 har 模块，点击 build 菜单栏 make module 'har'

---

### 34. 类名重命名
**题目**：需要对核心类名进行更改，如何高效且安全地完成，同时确保所有相关引用同步更新？

**答案**：选中需要更名的类名，使用快捷键 Shift+F6 或右键菜单 Refactor → Rename，在弹出框中输入新名称并选择替换范围后，点击"Refactor"完成更名操作。

---

### 35. ArkTS 赋值语句合法性
**题目**：以下 a1\a2\a3\a4 哪些赋值语句在 ArkTS 中是合法的？

```typescript
class A { v: number = 0; }
class B extends A { u: string = ''; }
class C { v: number = 0; }

let a1: A = new C();
let a2: A = new B();
let a3: B = new A();
let a4: C = new B();
```

**答案**：let a2: A = new B();

---

### 36. 内存信息读取
**题目**：想搭建运维平台，想在应用内定时读取当前的内存信息，可以通过什么接口来实现？

**答案**：hiDebug

---

### 37. 代码修改时机
**题目**：根据代码，以下解释正确的是？

**答案**：在自定义组件 Page 的 build 方法里改变状态变量是非法操作，可能导致未定义的异常 UI 行为。

---

### 38. 编译产物
**题目**：HarmonyOS 提供了多种包结构，每种包编译后的产物都不同，下面说法错误的是？

**答案**：app 包编译后的产物是 .app

---

### 39. 长时任务
**题目**：关于长时任务开发使用的接口是？

**答案**：使用 startBackgroundRunning 申请任务，使用 stopBackgroundRunning 取消任务

---

### 40. 短时任务
**题目**：关于短时任务开发使用的接口是？

**答案**：使用 requestSuspendDelay 申请任务，使用 getRemainingDelayTime 获取任务剩余时间

---

### 41. 延迟任务
**题目**：关于延迟任务开发使用的接口是？

**答案**：使用 startWork 申请任务，使用 stopWork 取消任务，使用 getWorkStatus 获取任务状态

---

## 📋 多选题

### 42. LocalStorage
**题目**：以下关于 LocalStorage 的说法正确有哪些？

**答案**：①②③

**解析**：
- ① 被 @Component 装饰的组件最多可以访问一个 LocalStorage 实例和 AppStorage，未被 @Entry 装饰的组件不可被独立分配 LocalStorage 实例，只能接受父组件的 LocalStorage 实例
- ② 组件树的根节点，即被 @Entry 装饰的 @Component，可以被分配一个 LocalStorage 实例，此组件的所有子组件实例将自动获得对该 LocalStorage 实例的访问权限
- ③ 应用程序可以创建多个 LocalStorage 实例，LocalStorage 实例可以在页面内共享，也可以通过 GetShared 接口，获取在 UIAbility 里创建的 GetShared，实现跨页面、UAbility 内共享

---

### 43. app.json5 配置
**题目**：基于 Stage 模型开发的应用项目代码下，都存在一个 app.json5 配置文件，以下 app.json5 配置文件错误的是？

**答案**：① 少了 versionName 那一项；② label 属性少了 $string 的

---

### 44. 方舟字节码指令
**题目**：下面关于方舟字节码指令含义说明正确的是？

**答案**：①②

**解析**：
- ① 假设寄存器 v0 存放了对象 A，累加器(acc)存放了对象 B，那么执行指令"lda v0"后，v0 存放对象 A，acc 存放对象 A
- ② 假设寄存器 v0 存放了对象 A，寄存器 v1 存放了对象 B，那么执行指令"mov v0, v1"后，v0 存放对象 B，v1 存放对象 B

---

### 45. Code Linter 配置
**题目**：Code Linter 针对 ArkTS/TS 代码进行最佳实践/编程规范方面的检查，关于配置项以下哪些说法是正确的？

**答案**：①②③

**解析**：
- ① ruleSet：配置检查使用的规则集，规则导入多条规则
- ② ignore：配置无需检查的文件目录，其指定的目录或文件需使用相对路径格式
- ③ files：配置待检查的文件名单，如未指定目录，规则适用于所有文件

---

### 46. 文本字号
**题目**：以下哪些实现方式可实现文本字号 20 的效果？

**答案**：不选 minSize 那个

---

### 47. ArkTS export 用法
**题目**：下面关于 ArkTS 中 export 用法，正确的是？

**答案**：BCD

```typescript
① export { export1 as alias1 } from "ets file name"
② export { export1 } from "ets file name"
③ export * as name from "ets file name"
④ export * from "ets file name"
```

---

### 48. ArkTS 设计理念
**题目**：ArkTS 是鸿蒙生态的应用开发语言，以下哪些选项是 ArkTS 的设计理念？

**答案**：①②③

**解析**：
- ① ArkTS 保留了 TS 大部分的语法特性，帮助开发者更容易上手 ArkTS
- ② 通过规范强化静态检查和分析，减少运行时的类型检查，从而降低了运行时负担，提升执行性能
- ③ 通过规范强化静态检查和分析，使得许多错误在编译时可以被检查出来，降低代码运行错误的风险

---

### 49. DevEco Studio 测试框架
**题目**：在 DevEco Studio 的测试框架下，以下描述中，哪些是正确的？

**答案**：①②③

**解析**：
- ① DevEco Studio 的测试框架提供测试用例执行能力，包含基础接口以编写和输出测试结果，鼓励用户创建易于维护的自动化测试脚本，并且统计代码覆盖率
- ② Instrument Test：测试用例存储于项目的 ohosTest 目录，要求在 HarmonyOS 设备或模拟器上执行，兼容 ArkTS 与 JS 语言编写
- ③ 无论选择 Instrument Test 还是 Local Test，DevEco Studio 均内置了详尽的测试报告功能，实时显示测试进度，且直接在 IDE 中可查看代码覆盖率报告

---

### 50. 同层渲染
**题目**：以下哪些方式可以实例 arkweb 同层？

**答案**：C、D

---

### 51. 组件复用未生效原因
**题目**：使用 ArkUI 组件复用之后，还是没有显著提升列表滑动场景的性能，于组件复用未生效可能的原因有？

**答案**：ABC

- A. 复用的自定义组件中使用了 if 等条件渲染语句导致结构不相同，未使用 reused 标记
- B. 页面嵌套了过多自定义组件
- C. 在 aboutToReuse 回调的函数中更新了冗余的状态变量

---

### 52. 系统事件与 HiLog
**题目**：订阅到的系统事件，哪些包含 HiLog 日志？

**答案**：B、D

- B. 卡死事件
- D. 崩溃事件

---

### 53. 持续部署最佳实践
**题目**：以下 A 到 G 选项，哪些是持续部署最佳实践？

**答案**：B、E、F、G

- B. 监控和回滚机制：实时监控部署后的应用状态，如有问题及时回滚
- E. 灰度发布：先在小部分用户或区域进行部署，观察没问题后再全面推广
- F. 环境一致性：保持开发、测试、生产等环境的高度一致性
- G. 自动化部署流程：从代码提交到部署的整个流程应尽可能自动化

---

### 54. 系统资源引用方式
**题目**：以下哪个是系统资源的引用方式？

**答案**：A

```typescript
// 正确
$r('sys.type.resource_id')

// 错误
$r('app.type.name')
$sys('type.resource_id')
$app('type.name')
```

---

### 55. layoutWeight 计算
**题目**：Row 父容器宽度 100，其中子组件 X 设置了 layoutWeight(3) 和 width('20%')，子组件 Y 设置了 layoutWeight(2) 和 width('30%')，会出现什么样的效果？

**答案**：C

- 子组件 X 宽度 60
- 子组件 Y 宽度 40

**解析**：layoutWeight 优先级高于固定宽度，剩余空间按比例分配

---

### 56. 动态 import 支持模块
**题目**：当前动态 import 支持导入的模块类型有哪些？

**答案**：ABCD

- A. 动态 import 支持加载 HSP 模块
- B. 动态 import 支持加载远程 HAR 模块
- C. 动态 import 支持加载 OHPM 模块
- D. 动态 import 支持加载本地 HAR 模块

---

### 57. build 函数中 if 描述错误
**题目**：关于 build 函数中的 if，以下哪些描述是错误的？

**答案**：A、D

- A. if 自身是需要绘制的节点（错误）
- D. if 分支中的自定义组件，无法使用组件复用，因此建议使用 reuseId 避免 if 切换（错误）

---

### 58. 属性字符串支持类型
**题目**：以下哪几个属于属性字符串支持的 StyledStringValue？

**答案**：C、D

- C. TextStyle
- D. TextShadowStyle

---

### 59. 列表图片优化
**题目**：列表数据较多，且图片为远端图片，能有效减少列表滑动过程中的图片白块的措施有？

**答案**：A、B、D

- A. 为 List 添加 cachedCount 属性
- B. 为 LazyForEach 添加第三参数（keyGenerator）
- D. 为 img 添加有效缓存管理

---

### 60. 平板下拉关闭弹窗
**题目**：以下代码在平板设备下，支持下拉关闭弹窗的是？

**答案**：A、C

```typescript
// A - 支持
.bindSheet($$this.isShow, this.myBuilder(),{
  preferType: SheetType.CENTER,
  ...
})

// C - 支持
.bindSheet($$this.isShow, this.myBuilder(),{
  preferType: SheetType.BOTTOM,
  ...
})
```

---

## 📝 答案汇总表

### 单选题答案

| 题号 | 答案 | 题号 | 答案 | 题号 | 答案 |
|:----:|:----:|:----:|:----:|:----:|:----:|
| 1 | B | 15 | - | 29 | - |
| 2 | $$双向绑定 | 16 | aboutToReuse | 30 | 1处 |
| 3 | GridItem宽度 | 17 | 静态检查替代测试 | 31 | build-profile |
| 4 | hvigor右键 | 18 | Button C | 32 | oh-package.json5 |
| 5 | customKeyboard | 19 | C | 33 | make module |
| 6 | CENTER | 20 | 3个 | 34 | Shift+F6 |
| 7 | 预加载 | 21 | 3个 | 35 | a2 |
| 8 | 反向调试 | 22 | hdc install | 36 | hiDebug |
| 9 | Attach | 23 | 无需签名 | 37 | build中改状态 |
| 10 | Top-Down | 24 | [0,2] | 38 | .app |
| 11 | D | 25 | 3 | 39 | startBackground |
| 12 | 1,2,3 | 26 | 静态import | 40 | requestSuspend |
| 13 | Session.start | 27 | changelog | 41 | startWork |
| 14 | HSP按需加载 | 28 | CD | - | - |

---

## 📚 重要考点速记

### 1. 布局相关
- **SpaceBetween**：首尾靠边，元素均匀分布
- **layoutWeight**：优先级高于固定宽度

### 2. 懒加载生效条件
- LazyForEach 必须在 **List 或 ListItem 直接子组件**下

### 3. 进程数量计算
- UIAbility + FormExtension + WorkSchedulerExtension = 最多 3 个进程

### 4. UIAbility 启动模式
- specified 模式下，相同 value 只创建一个实例

### 5. 资源引用
- 系统资源：`$r('sys.type.resource_id')`
- 应用资源：`$r('app.type.name')`

### 6. 任务类型
| 类型 | 申请接口 | 取消接口 |
|:-----|:---------|:---------|
| 长时任务 | startBackgroundRunning | stopBackgroundRunning |
| 短时任务 | requestSuspendDelay | - |
| 延迟任务 | startWork | stopWork |

---

> **声明**：本题库来源于哔哩哔哩用户平凡老师101，仅供学习参考，实际考试内容请以官方发布为准。
>
> **联系方式**：如需完整版题库，可联系 CV39453423

---

*更新时间：2024年10月*
