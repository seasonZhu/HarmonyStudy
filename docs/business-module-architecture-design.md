# 业务模块化架构设计方案

## 文档信息

- **创建时间**: 2026-08-18
- **状态**: 规划中
- **优先级**: 阶段三

---

## 一、核心理念

### 按业务模块划分 HSP

**每个 HSP 模块包含完整的业务功能**：
- UI 页面（Pages）
- 视图模型（ViewModel）
- 数据仓库（Repository）
- 数据模型（Model）
- 路由配置（Router）

**优势**：
- 业务内聚：每个模块包含完整的业务功能
- 独立开发：不同业务可以独立开发
- 按需加载：可以动态加载业务模块
- 复用性强：业务模块可以在不同项目中复用

---

## 二、业务模块识别

### 当前项目业务分析

| 业务模块 | 包含功能 | 相关页面 | 复杂度 |
|---------|---------|---------|--------|
| **user** | 登录、注册、用户信息、我的积分、我的收藏 | Login, My, MyCoin, MyCollect | 高 |
| **home** | Banner、文章列表、置顶文章 | Home | 中 |
| **article** | 文章详情、搜索结果 | SearchResult, WebPage | 中 |
| **knowledge** | 体系分类、标签详情 | Tree, TabsDetail | 中 |
| **wechat** | 公众号列表、公众号文章 | PublicNumber, TabsDetail | 中 |
| **project** | 项目列表、项目详情 | Project, TabsDetail | 中 |
| **search** | 热门关键词、搜索 | HotKey | 低 |
| **rank** | 积分排名 | Rank | 低 |

### 模块依赖关系

```
user 模块：
- 依赖：network, common-ui, utils
- 被依赖：home（获取用户信息）

home 模块：
- 依赖：network, common-ui, utils
- 被依赖：无

article 模块：
- 依赖：network, common-ui, utils
- 被依赖：search, home

knowledge 模块：
- 依赖：network, common-ui, utils
- 被依赖：无

wechat 模块：
- 依赖：network, common-ui, utils
- 被依赖：无

project 模块：
- 依赖：network, common-ui, utils
- 被依赖：无

search 模块：
- 依赖：network, common-ui, utils, article
- 被依赖：无

rank 模块：
- 依赖：network, common-ui, utils
- 被依赖：无
```

---

## 三、架构设计

### 整体架构

```
HarmonyStudy/
├── base/                    # 基础层（基础设施）
│   ├── network/            # 网络请求模块
│   │   └── src/main/ets/
│   │       ├── http/       # HTTP 客户端
│   │       ├── interceptors/ # 拦截器
│   │       └── model/      # API 响应模型
│   │
│   ├── common-ui/          # 通用 UI 组件
│   │   └── src/main/ets/
│   │       └── components/ # 通用组件
│   │
│   └── utils/              # 工具库
│       └── src/main/ets/
│           ├── log/        # 日志工具
│           ├── toast/      # Toast 工具
│           └── other/      # 其他工具
│
├── feature/                 # 业务模块层
│   ├── feature-user/       # 用户模块
│   │   └── src/main/ets/
│   │       ├── pages/      # Login, My, MyCoin, MyCollect
│   │       ├── viewModel/  # LoginViewModel, MyCoinViewModel
│   │       ├── repository/ # LoginRepository, MyCoinRepository
│   │       ├── model/      # LoginModel, UserInfoModel
│   │       └── router/     # UserRouter
│   │
│   ├── feature-home/       # 首页模块
│   │   └── src/main/ets/
│   │       ├── pages/      # Home
│   │       ├── viewModel/  # HomeViewModel
│   │       ├── repository/ # HomeRepository
│   │       ├── model/      # Banner, Article
│   │       └── router/     # HomeRouter
│   │
│   ├── feature-article/    # 文章模块
│   │   └── src/main/ets/
│   │       ├── pages/      # SearchResult, WebPage
│   │       ├── viewModel/  # SearchResultViewModel
│   │       ├── repository/ # SearchResultRepository
│   │       ├── model/      # Article, PageModel
│   │       └── router/     # ArticleRouter
│   │
│   ├── feature-knowledge/  # 体系模块
│   │   └── src/main/ets/
│   │       ├── pages/      # Tree, TabsDetail
│   │       ├── viewModel/  # TabsDetailViewModel
│   │       ├── repository/ # TabsDetailRepository
│   │       ├── model/      # TabModel
│   │       └── router/     # KnowledgeRouter
│   │
│   ├── feature-wechat/     # 公众号模块
│   │   └── src/main/ets/
│   │       ├── pages/      # PublicNumber, TabsDetail
│   │       ├── viewModel/  # TabsDetailViewModel
│   │       ├── repository/ # TabsDetailRepository
│   │       └── router/     # WechatRouter
│   │
│   ├── feature-project/    # 项目模块
│   │   └── src/main/ets/
│   │       ├── pages/      # Project, TabsDetail
│   │       ├── viewModel/  # TabsDetailViewModel
│   │       ├── repository/ # TabsDetailRepository
│   │       └── router/     # ProjectRouter
│   │
│   ├── feature-search/     # 搜索模块
│   │   └── src/main/ets/
│   │       ├── pages/      # HotKey
│   │       ├── viewModel/  # HotKeyViewModel
│   │       ├── repository/ # HotKeyRepository
│   │       ├── model/      # HotKeyModel
│   │       └── router/     # SearchRouter
│   │
│   └── feature-rank/       # 排行榜模块
│       └── src/main/ets/
│           ├── pages/      # Rank
│           ├── viewModel/  # RankViewModel
│           ├── repository/ # RankRepository
│           ├── model/      # RankModel
│           └── router/     # RankRouter
│
└── entry/                   # 主应用（Shell）
    └── src/main/ets/
        ├── entryability/   # 应用入口
        ├── router/         # 全局路由（整合各模块路由）
        ├── app.ets         # 应用配置
        └── model/          # 全局数据模型（如 AccountManager）
```

---

## 四、模块职责划分

### 4.1 基础层模块

#### network 模块

**职责**：
- HTTP 客户端管理
- 拦截器管理（CookieInterceptor）
- API 响应模型定义
- 统一错误处理

**导出内容**：
```typescript
export { HttpClient, getHttpClient } from './http/HttpClient'
export { CookieInterceptor } from './interceptors/CookieInterceptor'
export { ApiResponse, ApiError } from './model/ApiResponse'
```

#### common-ui 模块

**职责**：
- 通用 UI 组件
- 通用样式
- 通用资源

**组件列表**：
```
StatusWeight      # 状态切换组件（loading/error/empty/success）
InfoCell          # 文章列表项组件
BannerView        # Banner 轮播组件
ArticleCell       # 文章卡片组件
ProjectCell       # 项目列表项组件
ArticleMetaRow    # 文章元数据行
ArticleTitle      # 文章标题
CollectButton     # 收藏按钮
Center            # 居中布局
SafeBottomArea    # 安全底部区域
TreeCell          # 树形列表项组件
```

**导出内容**：
```typescript
export { StatusWeight } from './components/StatusWeight'
export { InfoCell } from './components/InfoCell'
export { BannerView } from './components/BannerView'
// ...其他组件
```

#### utils 模块

**职责**：
- 日志工具
- Toast 工具
- 其他工具类

**导出内容**：
```typescript
export { LogUtil } from './log/LogUtil'
export { ToastUtil } from './toast/ToastUtil'
// ...其他工具
```

### 4.2 业务模块

#### feature-user 模块

**包含功能**：
- 用户登录/注册/登出
- 用户信息管理
- 我的积分
- 我的收藏

**目录结构**：
```
feature-user/
├── src/main/ets/
│   ├── pages/
│   │   ├── Login.ets
│   │   ├── My.ets
│   │   ├── MyCoin.ets
│   │   └── MyCollect.ets
│   ├── viewModel/
│   │   ├── LoginViewModel.ets
│   │   └── MyCoinViewModel.ets
│   ├── repository/
│   │   ├── LoginRepository.ets
│   │   └── MyCoinRepository.ets
│   ├── model/
│   │   ├── LoginModel.ets
│   │   ├── UserInfoModel.ets
│   │   └── LoginOrRegisterInfo.ets
│   └── router/
│       └── UserRouter.ets
├── src/main/resources/
│   └── base/
│       ├── media/       # 用户模块图片资源
│       └── string/      # 用户模块字符串资源
├── oh-package.json5
└── build-profile.json5
```

**模块配置**：
```json5
// oh-package.json5
{
  "name": "feature-user",
  "version": "1.0.0",
  "description": "用户业务模块",
  "main": "Index.ets",
  "dependencies": {
    "network": "file:../../base/network",
    "common-ui": "file:../../base/common-ui",
    "utils": "file:../../base/utils"
  }
}
```

**导出内容**：
```typescript
// Index.ets
export { Login } from './pages/Login'
export { My } from './pages/My'
export { MyCoin } from './pages/MyCoin'
export { MyCollect } from './pages/MyCollect'
export { UserRouter } from './router/UserRouter'
export { LoginViewModel } from './viewModel/LoginViewModel'
export { MyCoinViewModel } from './viewModel/MyCoinViewModel'
// ...其他导出
```

#### feature-home 模块

**包含功能**：
- Banner 展示
- 文章列表
- 置顶文章

**目录结构**：
```
feature-home/
├── src/main/ets/
│   ├── pages/
│   │   └── Home.ets
│   ├── viewModel/
│   │   └── HomeViewModel.ets
│   ├── repository/
│   │   └── HomeRepository.ets
│   ├── model/
│   │   ├── Banner.ets
│   │   └── Article.ets
│   └── router/
│       └── HomeRouter.ets
├── oh-package.json5
└── build-profile.json5
```

#### feature-article 模块

**包含功能**：
- 文章详情
- 搜索结果

**目录结构**：
```
feature-article/
├── src/main/ets/
│   ├── pages/
│   │   ├── SearchResult.ets
│   │   └── WebPage.ets
│   ├── viewModel/
│   │   └── SearchResultViewModel.ets
│   ├── repository/
│   │   └── SearchResultRepository.ets
│   ├── model/
│   │   ├── Article.ets
│   │   └── PageModel.ets
│   └── router/
│       └── ArticleRouter.ets
├── oh-package.json5
└── build-profile.json5
```

#### 其他业务模块

**feature-knowledge**、**feature-wechat**、**feature-project**、**feature-search**、**feature-rank** 的结构类似，不再赘述。

### 4.3 主应用（entry）

**职责**：
- 整合所有业务模块
- 全局路由管理
- 应用生命周期管理
- 全局状态管理（AccountManager）

**依赖配置**：
```json5
// entry/oh-package.json5
{
  "name": "entry",
  "version": "1.0.0",
  "description": "主应用",
  "dependencies": {
    "network": "file:../base/network",
    "common-ui": "file:../base/common-ui",
    "utils": "file:../base/utils",
    "feature-user": "file:../feature/feature-user",
    "feature-home": "file:../feature/feature-home",
    "feature-article": "file:../feature/feature-article",
    "feature-knowledge": "file:../feature/feature-knowledge",
    "feature-wechat": "file:../feature/feature-wechat",
    "feature-project": "file:../feature/feature-project",
    "feature-search": "file:../feature/feature-search",
    "feature-rank": "file:../feature/feature-rank"
  }
}
```

---

## 五、关键技术点

### 5.1 模块依赖管理

**依赖原则**：
- 业务模块依赖基础层模块
- 业务模块之间尽量解耦
- 避免循环依赖

**依赖配置示例**：
```json5
// feature-user/oh-package.json5
{
  "name": "feature-user",
  "dependencies": {
    "network": "file:../../base/network",
    "common-ui": "file:../../base/common-ui",
    "utils": "file:../../base/utils"
  }
}
```

### 5.2 路由管理

#### 模块内路由

```typescript
// feature-user/src/main/ets/router/UserRouter.ets
import { RouterName } from '../enum/RouterName'

export class UserRouter {
  // 路由名称
  static readonly Login = RouterName.Login
  static readonly My = RouterName.My
  static readonly MyCoin = RouterName.MyCoin
  static readonly MyCollect = RouterName.MyCollect
  
  // 注册路由
  static register(navPathStack: NavPathStack) {
    navPathStack.pushPath({ name: this.Login })
    navPathStack.pushPath({ name: this.My })
    navPathStack.pushPath({ name: this.MyCoin })
    navPathStack.pushPath({ name: this.MyCollect })
  }
}
```

#### 全局路由整合

```typescript
// entry/src/main/ets/router/Router.ets
import { UserRouter } from 'feature-user'
import { HomeRouter } from 'feature-home'
import { ArticleRouter } from 'feature-article'
import { KnowledgeRouter } from 'feature-knowledge'
import { WechatRouter } from 'feature-wechat'
import { ProjectRouter } from 'feature-project'
import { SearchRouter } from 'feature-search'
import { RankRouter } from 'feature-rank'

export class Router {
  private static navPathStack: NavPathStack
  
  static init(navPathStack: NavPathStack) {
    this.navPathStack = navPathStack
    
    // 注册所有模块路由
    UserRouter.register(navPathStack)
    HomeRouter.register(navPathStack)
    ArticleRouter.register(navPathStack)
    KnowledgeRouter.register(navPathStack)
    WechatRouter.register(navPathStack)
    ProjectRouter.register(navPathStack)
    SearchRouter.register(navPathStack)
    RankRouter.register(navPathStack)
  }
  
  // 全局跳转方法
  static toLogin() {
    this.navPathStack.pushPath({ name: UserRouter.Login })
  }
  
  static toHome() {
    this.navPathStack.pushPath({ name: HomeRouter.Home })
  }
  
  // ...其他跳转方法
}
```

### 5.3 状态共享

#### 使用 globalThis

```typescript
// entry/src/main/ets/entryability/EntryAbility.ets
import AccountManager from './model/AccountManager'

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 初始化全局状态
    globalThis.accountManager = AccountManager.shared()
    globalThis.navPathStack = new NavPathStack()
    
    // ...其他初始化
  }
}
```

#### 在业务模块中使用

```typescript
// feature-user/src/main/ets/viewModel/LoginViewModel.ets
export class LoginViewModel {
  public async login(info: LoginOrRegisterInfo): Promise<boolean> {
    // 使用全局状态
    const accountManager = globalThis.accountManager
    accountManager.saveLoginModel(loginModel)
    // ...
  }
}
```

### 5.4 资源管理

#### 通用资源

放在 `common-ui` 模块：
```
common-ui/
└── src/main/resources/
    └── base/
        ├── media/
        │   ├── common_icon.png
        │   └── ...
        └── string/
            ├── common_string.json
            └── ...
```

#### 业务资源

放在各自的业务模块：
```
feature-user/
└── src/main/resources/
    └── base/
        ├── media/
        │   ├── user_avatar.png
        │   └── ...
        └── string/
            ├── user_string.json
            └── ...
```

### 5.5 数据模型共享

#### 通用数据模型

放在 `network` 模块或 `utils` 模块：
```
network/
└── src/main/ets/model/
    ├── ApiResponse.ets
    ├── ApiError.ets
    └── PageModel.ets
```

#### 业务数据模型

放在各自的业务模块：
```
feature-user/
└── src/main/ets/model/
    ├── LoginModel.ets
    ├── UserInfoModel.ets
    └── LoginOrRegisterInfo.ets
```

#### 跨模块数据模型

如果某个数据模型被多个模块使用，可以：
1. 放在 `common-ui` 或 `utils` 模块
2. 或者提取为独立的 `common-model` 模块

---

## 六、迁移步骤

### 阶段三：业务模块拆分

#### 步骤 1：创建基础层模块

**任务**：
1. 创建 `base/` 目录
2. 移动 `network` 到 `base/network`
3. 移动 `Utils` 到 `base/utils`
4. 创建 `base/common-ui` 模块
5. 迁移通用 UI 组件到 `common-ui`

**验证**：
- 构建项目确保无错误
- 测试通用组件功能

#### 步骤 2：创建第一个业务模块

**建议从 `feature-rank` 开始**（最简单）：
1. 创建 `feature/feature-rank/` 目录
2. 创建模块配置文件（oh-package.json5、build-profile.json5）
3. 迁移 Rank.ets、RankViewModel.ets、RankRepository.ets
4. 创建 RankRouter.ets
5. 更新 entry 模块依赖
6. 测试验证

**验证**：
- 构建项目确保无错误
- 测试排行榜功能

#### 步骤 3：迁移其他业务模块

**迁移顺序**（从简单到复杂）：
1. feature-search（热门关键词）
2. feature-article（搜索结果、文章详情）
3. feature-project（项目）
4. feature-wechat（公众号）
5. feature-knowledge（体系）
6. feature-home（首页）
7. feature-user（用户）

**每个模块的迁移步骤**：
1. 创建模块目录和配置文件
2. 迁移页面、ViewModel、Repository、Model
3. 创建模块路由
4. 更新 entry 模块依赖
5. 更新导入路径
6. 构建测试

#### 步骤 4：整合到主应用

**任务**：
1. 更新 entry 模块依赖配置
2. 整合所有模块路由
3. 删除 entry 中的旧代码
4. 全量测试

**验证**：
- 构建项目确保无错误
- 运行所有功能测试
- 性能测试

#### 步骤 5：清理旧代码

**任务**：
1. 删除 `entry/src/main/ets/httpRequest/` 目录
2. 删除 `entry/src/main/ets/views/` 目录（已迁移到 common-ui）
3. 删除 `entry/src/main/ets/repository/` 目录（已迁移到各业务模块）
4. 删除 `entry/src/main/ets/viewModel/` 目录（已迁移到各业务模块）
5. 删除 `entry/src/main/ets/pages/` 目录（已迁移到各业务模块）

**验证**：
- 构建项目确保无错误
- 全量功能测试

---

## 七、优势与挑战

### 7.1 优势

1. **业务内聚**
   - 每个模块包含完整的业务功能
   - 业务边界清晰
   - 易于理解和维护

2. **独立开发**
   - 不同业务团队可以独立开发自己的模块
   - 减少代码冲突
   - 提高开发效率

3. **按需加载**
   - 可以动态加载业务模块
   - 减少主包体积
   - 提升启动速度

4. **复用性强**
   - 业务模块可以在不同项目中复用
   - 减少重复开发
   - 提高代码质量

5. **易于测试**
   - 每个模块可以独立测试
   - 提高测试覆盖率
   - 降低测试成本

### 7.2 挑战

1. **模块边界划分**
   - 需要明确业务边界
   - 避免模块职责不清
   - 解决方案：基于领域驱动设计（DDD）划分

2. **依赖管理**
   - 需要管理模块间的依赖关系
   - 避免循环依赖
   - 解决方案：使用依赖图工具检测

3. **路由整合**
   - 需要整合各模块的路由
   - 处理跨模块跳转
   - 解决方案：统一路由管理器

4. **状态共享**
   - 需要处理跨模块的状态共享
   - 避免状态不一致
   - 解决方案：使用 globalThis 或状态管理库

5. **资源管理**
   - 需要管理跨模块的资源
   - 避免资源重复
   - 解决方案：统一资源管理策略

---

## 八、风险评估

### 8.1 技术风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|----------|
| 模块依赖循环 | 高 | 中 | 使用依赖图工具检测，及时重构 |
| 路由冲突 | 中 | 低 | 统一路由命名规范，使用命名空间 |
| 状态不一致 | 高 | 中 | 使用单一数据源，统一状态管理 |
| 构建失败 | 高 | 低 | 增量迁移，每步验证 |

### 8.2 业务风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|----------|
| 功能回归 | 高 | 中 | 全量测试，逐步上线 |
| 性能下降 | 中 | 低 | 性能测试，优化加载策略 |
| 用户体验变化 | 中 | 低 | 保持 UI 一致性，充分测试 |

---

## 九、时间规划

### 阶段三：业务模块拆分

**预计时间**：2-3 周

| 任务 | 预计时间 | 优先级 |
|------|---------|--------|
| 创建基础层模块 | 2 天 | 高 |
| 创建 feature-rank | 1 天 | 高 |
| 创建 feature-search | 1 天 | 高 |
| 创建 feature-article | 2 天 | 中 |
| 创建 feature-project | 2 天 | 中 |
| 创建 feature-wechat | 2 天 | 中 |
| 创建 feature-knowledge | 2 天 | 中 |
| 创建 feature-home | 3 天 | 高 |
| 创建 feature-user | 4 天 | 高 |
| 整合到主应用 | 2 天 | 高 |
| 清理旧代码 | 1 天 | 中 |
| 全量测试 | 2 天 | 高 |

---

## 十、附录

### 10.1 相关文档

- [网络模块迁移指南](./network-migration-guide.md)
- [网络模块迁移完成报告](./network-migration-complete.md)
- [性能对比报告](./network-comparison-report.md)

### 10.2 参考资料

- [HarmonyOS HSP 开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/hsp-overview-V5)
- [领域驱动设计（DDD）](https://domain-driven-design.org/)
- [模块化架构设计](https://www.martinfowler.com/articles/modular-monolith.html)

### 10.3 工具推荐

- **依赖分析**：使用 `ohpm` 分析模块依赖
- **路由管理**：自定义路由管理器或使用第三方库
- **状态管理**：使用 globalThis 或第三方状态管理库

---

## 十一、总结

### 核心要点

1. **按业务划分模块**，而非技术层面
2. **每个模块包含完整业务功能**，实现业务内聚
3. **基础层提供基础设施**，业务层专注业务逻辑
4. **主应用负责整合**，管理全局路由和状态

### 下一步行动

1. 审阅本文档，确认架构设计
2. 评估时间和资源，制定详细计划
3. 从最简单的模块开始迁移
4. 增量迁移，每步验证
5. 全量测试，确保质量

---

**文档状态**：规划中，待实施
**下一步**：等待确认后开始阶段三迁移
