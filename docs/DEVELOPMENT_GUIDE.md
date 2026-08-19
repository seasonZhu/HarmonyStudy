# HarmonyOS 开发指南

> **版本**: v2.0  
> **更新日期**: 2026-08-19  
> **适用项目**: HarmonyStudy

---

## 目录

1. [快速开始](#一快速开始)
2. [命名规范](#二命名规范)
3. [项目结构](#三项目结构)
4. [HSP 模块开发](#四hsp-模块开发)
5. [网络请求](#五网络请求)
6. [路由框架](#六路由框架)
7. [ArkTS 最佳实践](#七arkts-最佳实践)
8. [常见问题与调试](#八常见问题与调试)
9. [附录](#九附录)

---

## 一、快速开始

### 1.1 环境准备

1. 安装 DevEco Studio
2. 配置 HarmonyOS SDK
3. 克隆项目代码

```bash
git clone https://github.com/seasonZhu/HarmonyStudy.git
cd HarmonyStudy
```

### 1.2 项目运行

1. 打开 DevEco Studio
2. 导入项目
3. 等待依赖安装完成
4. 点击运行按钮

### 1.3 项目配置

- **API 版本**: API 10+
- **开发语言**: ArkTS
- **UI 框架**: ArkUI
- **构建工具**: Hvigor

---

## 二、命名规范

### 2.1 文件命名规范

#### 页面文件命名

**规范**：
- ✅ 使用 PascalCase（大驼峰）
- ✅ 不添加 Page 后缀（文件夹已是 pages）
- ✅ 语义清晰，见名知意
- ❌ 避免使用缩写或简写

**示例**：

```
✅ 正确：
- Login.ets              # 登录页
- Profile.ets            # 个人中心
- WebBrowser.ets         # 网页浏览器
- NetworkComparison.ets  # 网络对比测试页
- SearchResult.ets       # 搜索结果页

❌ 错误：
- login.ets              # 小写
- LoginPage.ets          # 多余的 Page 后缀
- My.ets                 # 语义不清（应使用 Profile）
- WebPg.ets              # 缩写
```

#### 组件文件命名

**规范**：
- ✅ 使用 PascalCase
- ✅ 功能性前缀（如 Article、Project）
- ✅ 后缀表示类型（Cell、View、Header）

**示例**：

```
✅ 正确：
- ArticleCell.ets    # 文章单元格
- ProjectCell.ets    # 项目单元格
- BannerView.ets     # Banner 视图
- MyHeader.ets       # 我的页头部
- ArticleTitle.ets   # 文章标题
- StatusWeight.ets   # 状态权重

❌ 错误：
- articleCell.ets    # 小写开头
- ArticleListItem.ets  # 过长
- Cell.ets           # 缺少功能前缀
```

#### ViewModel 文件命名

**规范**：
- ✅ 页面名 + ViewModel
- ✅ 使用 PascalCase

**示例**：

```
✅ 正确：
- LoginViewModel.ets
- HomeViewModel.ets
- RankViewModel.ets
- SearchResultViewModel.ets
```

#### Repository 文件命名

**规范**：
- ✅ 功能名 + Repository
- ✅ 使用 PascalCase

**示例**：

```
✅ 正确：
- LoginRepository.ets
- HomeRepository.ets
- RankRepository.ets
- BaseRepository.ets  # 基类
```

---

### 2.2 组件命名规范

#### struct 命名

**规范**：
- ✅ 与文件名一致
- ✅ 使用 PascalCase

**示例**：

```typescript
// Profile.ets
@Entry({ routeName: RouterName.Profile })
@Component
struct Profile {  // ✅ 与文件名一致
  build() {
    NavDestination() {
      Column() {
        Text('个人中心')
      }
    }
  }
}

// ArticleCell.ets
@Component
export struct ArticleCell {  // ✅ 与文件名一致
  @Prop article: Article
  
  build() {
    Column() {
      Text(this.article.title)
    }
  }
}
```

#### Builder 函数命名

**规范**：
- ✅ struct 名称 + Builder
- ✅ 用于 routerMap.json 配置

**示例**：

```typescript
// Profile.ets
@Builder
export function ProfileBuilder() {  // ✅ Profile + Builder
  Profile()
}

// WebBrowser.ets
@Builder
export function WebBrowserBuilder() {  // ✅ WebBrowser + Builder
  WebBrowser()
}
```

---

### 2.3 变量命名规范

#### 状态变量

**规范**：
- ✅ 使用 @State、@Local、@Prop 等装饰器
- ✅ 语义清晰的命名
- ✅ 布尔值使用 is/has 前缀

**示例**：

```typescript
✅ 正确：
@State isLoading: boolean = false      // 加载状态
@State hasMore: boolean = true          // 是否有更多
@State currentIndex: number = 0         // 当前索引
@State articleList: Article[] = []      // 文章列表
@State status: ViewStatus = ViewStatus.loading  // 视图状态

❌ 错误：
@State loading: boolean = false         // 缺少 is 前缀
@State list: Article[] = []             // 命名不清晰
@State flag: boolean = true             // 语义不明
```

#### 私有变量

**规范**：
- ✅ 使用 private 修饰符
- ❌ 不使用下划线前缀（ArkTS 不推荐）

**示例**：

```typescript
✅ 正确：
private httpClient: HttpClient = getHttpClient()
private viewModel: HomeViewModel = new HomeViewModel()
private scroller: Scroller = new Scroller()

❌ 错误：
private _httpClient: HttpClient  // 不使用下划线
private _viewModel: HomeViewModel
```

#### 常量命名

**规范**：
- ✅ 使用 const 声明
- ✅ 全大写，单词间用下划线分隔

**示例**：

```typescript
✅ 正确：
const MAX_RETRY_COUNT = 3
const DEFAULT_TIMEOUT = 30000
const API_BASE_URL = 'https://www.wanandroid.com/'

// 枚举常量
export enum ViewStatus {
  loading,
  success,
  error,
  empty
}
```

---

### 2.4 路由命名规范

#### RouterName 枚举

**规范**：
- ✅ 枚举名与页面名一致
- ✅ 字符串值与枚举名一致
- ✅ 使用 PascalCase
- ✅ 大小写统一

**示例**：

```typescript
// RouterName.ets
export enum RouterName {
  // ✅ 正确示例
  Login = "Login",           // 登录页
  Profile = "Profile",       // 个人中心
  WebBrowser = "WebBrowser", // 网页浏览器
  HotKey = "HotKey",         // 热门关键词（大小写统一）
  SearchResult = "SearchResult",  // 搜索结果
  
  // ❌ 错误示例
  Web = "WebPage",           // ❌ 枚举名与值不一致
  Hotkey = "HotKey",         // ❌ 大小写不一致
  MyPage = "My",             // ❌ 多余的 Page 后缀
}
```

#### routerMap.json 配置

**规范**：
- ✅ name 与 RouterName 枚举值一致
- ✅ pageSourceFile 路径正确
- ✅ buildFunction 名称正确

**示例**：

```json
{
  "routerMap": [
    {
      "name": "Profile",                    // ✅ 与枚举一致
      "pageSourceFile": "src/main/ets/pages/Profile.ets",
      "buildFunction": "ProfileBuilder"     // ✅ 与 Builder 函数一致
    },
    {
      "name": "WebBrowser",                 // ✅ 与枚举一致
      "pageSourceFile": "src/main/ets/pages/WebBrowser.ets",
      "buildFunction": "WebBrowserBuilder"
    }
  ]
}
```

---

## 三、项目结构

### 3.1 目录结构

```
HarmonyStudy/
├── entry/                      # 主应用模块
│   └── src/main/
│       ├── ets/
│       │   ├── accountManager/ # 账户管理
│       │   │   └── AccountManager.ets
│       │   ├── constants/      # 常量定义
│       │   │   ├── ApiConstants.ets
│       │   │   └── StyleConstants.ets
│       │   ├── enum/           # 枚举类型
│       │   │   ├── ViewStatus.ets
│       │   │   ├── ContentType.ets
│       │   │   └── MyType.ets
│       │   ├── entity/         # 实体类
│       │   │   ├── WebLink.ets
│       │   │   └── KeywordInfo.ets
│       │   ├── httpRequest/    # 网络请求封装（旧）
│       │   │   ├── Provider.ets
│       │   │   ├── EnvironmentManager.ets
│       │   │   └── interceptors/
│       │   ├── model/          # 数据模型
│       │   │   ├── Article.ets
│       │   │   ├── Banner.ets
│       │   │   ├── LoginModel.ets
│       │   │   └── BaseListDataSource.ets
│       │   ├── pages/          # 页面组件
│       │   │   ├── Index.ets
│       │   │   ├── Login.ets
│       │   │   ├── Profile.ets
│       │   │   ├── Home.ets
│       │   │   └── ...
│       │   ├── repository/     # 数据仓库
│       │   │   ├── base/
│       │   │   │   └── BaseRepository.ets
│       │   │   ├── LoginRepository.ets
│       │   │   ├── HomeRepository.ets
│       │   │   └── ...
│       │   ├── router/         # 路由管理
│       │   │   ├── RouterName.ets
│       │   │   ├── navPathStack.ets
│       │   │   ├── Router.ets
│       │   │   └── PagesConstant.ets
│       │   ├── utils/          # 工具类
│       │   │   ├── LoadingDialogHelper.ets
│       │   │   ├── ToastUtil.ets
│       │   │   └── ErrorHandler.ets
│       │   ├── views/          # 自定义视图组件
│       │   │   ├── ArticleCell.ets
│       │   │   ├── BannerView.ets
│       │   │   └── StatusWeight.ets
│       │   └── viewModel/      # 视图模型
│       │       ├── LoginViewModel.ets
│       │       ├── HomeViewModel.ets
│       │       └── ...
│       └── resources/          # 资源文件
│           ├── base/
│           │   ├── element/    # 通用资源
│           │   ├── media/      # 图片资源
│           │   └── profile/    # 配置文件
│           ├── zh_CN/element/  # 中文资源
│           └── en_US/element/  # 英文资源
├── network/                    # 网络请求模块（HSP）
│   ├── Index.ets               # 统一导出
│   └── src/main/ets/
│       ├── Network.ets         # 主入口
│       ├── core/
│       │   ├── HttpClient.ets       # HTTP 客户端
│       │   ├── InterceptorManager.ets  # 拦截器管理
│       │   └── ErrorHandler.ets     # 错误处理
│       ├── interceptors/
│       │   ├── LoggingInterceptor.ets   # 日志拦截器
│       │   ├── TokenInterceptor.ets     # Token 拦截器
│       │   ├── RetryInterceptor.ets     # 重试拦截器
│       │   └── CookieInterceptor.ets    # Cookie 拦截器
│       ├── models/
│       │   ├── ApiResponse.ets      # 响应模型
│       │   ├── ApiError.ets         # 错误模型
│       │   └── HttpConfig.ets       # 配置模型
│       └── services/
│           ├── EnvironmentService.ets  # 环境服务
│           └── LoadingService.ets      # 加载服务
├── Utils/                      # 工具模块（HSP）
│   └── src/main/ets/
│       ├── AreaHeight.ets
│       ├── FullScreen.ets
│       └── StatusBar.ets
├── librarySDK/                 # SDK 模块（HSP）
│   └── src/main/ets/
│       └── components/
├── docs/                       # 文档目录
│   ├── DEVELOPMENT_GUIDE.md    # 开发指南
│   ├── NETWORK_USAGE.md        # 网络使用指南
│   └── navpathstack-design.md  # 路由设计文档
├── build-profile.json5         # 构建配置
├── oh-package.json5            # 依赖配置
└── README.md                   # 项目说明
```

---

### 3.2 模块职责

| 模块 | 职责 | 类型 | 依赖 |
|------|------|------|------|
| **entry** | 主应用，包含所有业务代码 | HAP | network, Utils, librarySDK |
| **network** | 网络请求封装 | HSP | @ohos/axios |
| **Utils** | 通用工具类 | HSP | 无 |
| **librarySDK** | SDK 功能 | HSP | 无 |

---

### 3.3 资源管理

#### 资源目录结构

```
resources/
├── base/                       # 通用资源（默认）
│   ├── element/
│   │   ├── color.json         # 颜色定义
│   │   ├── string.json        # 字符串定义
│   │   └── float.json         # 尺寸定义
│   ├── media/
│   │   ├── logo.png           # 图片资源
│   │   └── icon_home.svg      # 图标资源
│   └── profile/
│       ├── main_pages.json    # 页面配置
│       └── routerMap.json     # 路由配置
├── zh_CN/element/             # 中文资源
│   └── string.json
└── en_US/element/             # 英文资源
    └── string.json
```

#### 资源引用方式

```typescript
// 引用字符串
Text($r('app.string.login_button'))

// 引用颜色
.backgroundColor($r('app.color.mainBlue'))

// 引用图片
Image($r('app.media.logo'))

// 引用尺寸
.fontSize($r('app.float.page_text_font_size'))
```

---

## 四、HSP 模块开发

### 4.1 HSP 模块创建

#### 创建步骤

**步骤 1：创建模块目录**

```bash
# 在项目根目录创建 HSP 模块
mkdir -p network/src/main/ets
```

**步骤 2：创建 build-profile.json5**

```json5
// network/build-profile.json5
{
  "apiType": 'stageMode',
  "buildOption": {
    "sourceOption": {
      "workers": []
    }
  },
  "buildOptionHar": {
    "enableBuildHar": true,  // 启用 HAR 构建
    "buildHarConfig": {
      "name": "network",     // HAR 包名称
      "version": "1.0.0"     // 版本号
    }
  },
  "targets": [
    {
      "name": "default",
      "runtimeOS": "HarmonyOS"
    }
  ]
}
```

**步骤 3：创建 oh-package.json5**

```json5
// network/oh-package.json5
{
  "name": "network",
  "version": "1.0.0",
  "description": "网络请求模块",
  "main": "Index.ets",
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@ohos/axios": "2.2.14"
  }
}
```

**步骤 4：创建 module.json5**

```json5
// network/src/main/module.json5
{
  "module": {
    "name": "network",
    "type": "har",
    "deviceTypes": ["default", "tablet"],
    "deliveryWithInstall": true
  }
}
```

**步骤 5：创建 Index.ets 导出文件**

```typescript
// network/Index.ets
/**
 * Network SDK - 统一导出
 * @description 企业级网络请求模块
 */
export * from './src/main/ets/Network';

// 便捷导出
export { getHttpClient, createDefaultHttpClient } from './src/main/ets/Network';
```

**步骤 6：在主模块中依赖**

```json5
// entry/oh-package.json5
{
  "dependencies": {
    "network": "file:../network"
  }
}
```

**步骤 7：在根目录 oh-package.json5 中添加**

```json5
// oh-package.json5
{
  "dependencies": {
    "network": "file:./network"
  }
}
```

---

### 4.2 HSP 模块配置

#### build-profile.json5 配置说明

```json5
{
  "apiType": 'stageMode',  // API 类型
  
  "buildOption": {
    // 构建选项
    "sourceOption": {
      "workers": []  // Worker 配置
    }
  },
  
  "buildOptionHar": {
    "enableBuildHar": true,  // 启用 HAR 构建
    "buildHarConfig": {
      "name": "模块名",
      "version": "版本号"
    }
  },
  
  "targets": [
    {
      "name": "default",
      "runtimeOS": "HarmonyOS"
    }
  ]
}
```

#### module.json5 配置说明

```json5
{
  "module": {
    "name": "模块名",           // 模块名称
    "type": "har",              // 模块类型（har/hap）
    "deviceTypes": ["default", "tablet"],  // 支持设备类型
    "deliveryWithInstall": true  // 是否随应用安装
  }
}
```

---

### 4.3 HSP 模块使用

#### 导入模块

```typescript
// 方式 1：导入所有导出
import * as Network from 'network'

// 方式 2：按需导入
import { getHttpClient, HttpClient } from 'network'

// 方式 3：导入特定功能
import { ApiError, ApiResponse } from 'network'

// 方式 4：导入类型
import type { ApiResponse } from 'network'
```

#### 使用示例

```typescript
import { getHttpClient, HttpClient } from 'network'
import { ApiError } from 'network'

// 获取 HTTP 客户端
const httpClient: HttpClient = getHttpClient()

// 发送 GET 请求
const response = await httpClient.get<Article[]>('/article/list/0/json')

// 发送 POST 请求
const response = await httpClient.post<LoginModel>('/user/login', {
  username: 'user',
  password: 'pass'
})

// 错误处理
try {
  const data = await httpClient.get('/api/data')
} catch (error) {
  const apiError = error as ApiError
  console.error(apiError.message)
}
```

---

### 4.4 HSP 模块最佳实践

#### 模块划分原则

1. **按功能划分**：
   - network：网络请求
   - common-ui：通用 UI 组件
   - utils：工具库
   - user：用户业务模块

2. **依赖关系**：
   - 基础模块不依赖业务模块
   - 业务模块可以依赖基础模块
   - 避免循环依赖

3. **导出规范**：
   - 统一在 Index.ets 中导出
   - 只导出必要的 API
   - 内部实现不导出

#### 模块内部结构

```
network/
├── Index.ets                    # 统一导出（必需）
├── build-profile.json5          # 构建配置（必需）
├── oh-package.json5             # 依赖配置（必需）
├── hvigorfile.ts                # 构建脚本（必需）
└── src/main/
    ├── module.json5             # 模块配置（必需）
    ├── ets/                     # 源代码
    │   ├── Network.ets          # 主入口
    │   ├── core/                # 核心功能
    │   ├── interceptors/        # 拦截器
    │   ├── models/              # 数据模型
    │   └── services/            # 服务
    └── resources/               # 资源文件
```

#### 导出最佳实践

```typescript
// Index.ets

// ✅ 正确：统一导出
export * from './src/main/ets/Network'

// ✅ 正确：便捷导出
export { getHttpClient } from './src/main/ets/Network'

// ❌ 错误：导出内部实现
export { InternalHelper } from './src/main/ets/core/InternalHelper'
```

---

## 五、网络请求

### 5.1 network 模块介绍

#### 模块结构

```
network/
├── Index.ets                    # 统一导出
└── src/main/ets/
    ├── Network.ets              # 主入口
    ├── core/
    │   ├── HttpClient.ets       # HTTP 客户端
    │   ├── InterceptorManager.ets  # 拦截器管理
    │   └── ErrorHandler.ets     # 错误处理
    ├── interceptors/
    │   ├── LoggingInterceptor.ets   # 日志拦截器
    │   ├── TokenInterceptor.ets     # Token 拦截器
    │   ├── RetryInterceptor.ets     # 重试拦截器
    │   └── CookieInterceptor.ets    # Cookie 拦截器
    ├── models/
    │   ├── ApiResponse.ets      # 响应模型
    │   ├── ApiError.ets         # 错误模型
    │   └── HttpConfig.ets       # 配置模型
    └── services/
        ├── EnvironmentService.ets  # 环境服务
        └── LoadingService.ets      # 加载服务
```

#### 核心功能

- ✅ 统一的 HTTP 客户端
- ✅ 拦截器机制
- ✅ 自动重试
- ✅ 错误处理
- ✅ 环境管理
- ✅ Cookie 自动添加

---

### 5.2 基本使用

#### 初始化

```typescript
// EntryAbility.ets
import { NetworkProvider } from './httpRequest/NetworkProvider'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化 NetworkProvider
    NetworkProvider.init(this.context)
    
    // 设置 globalThis.accountManager（Cookie 拦截器需要）
    globalThis.accountManager = AccountManager.shared()
  }
}
```

#### 发送请求

```typescript
import { getHttpClient } from 'network'

// GET 请求
const response = await getHttpClient().get<Article[]>('/article/list/0/json')

// POST 请求
const response = await getHttpClient().post<LoginModel>('/user/login', {
  username: 'user',
  password: 'pass'
})

// PUT 请求
const response = await getHttpClient().put<Article>('/article/update', article)

// DELETE 请求
const response = await getHttpClient().delete<void>('/article/delete/123')

// 带配置的请求
const response = await getHttpClient().get<Article[]>('/article/list/0/json', {
  timeout: 10000,
  headers: { 'Custom-Header': 'value' }
})
```

---

### 5.3 Repository 模式

#### 创建 BaseRepository

```typescript
// BaseRepository.ets
import { getHttpClient, HttpClient, ApiError } from 'network'
import { LogUtil } from '@pura/harmony-utils'

export { ApiError } from 'network'

export abstract class BaseRepository {
  protected httpClient: HttpClient
  
  constructor() {
    this.httpClient = getHttpClient()
  }
  
  /**
   * 统一错误处理
   */
  protected handleError(error: ApiError): void {
    LogUtil.error(`API Error: ${error.message}`)
  }
}
```

#### 创建具体 Repository

```typescript
// LoginRepository.ets
import { BaseRepository, ApiError } from './base/BaseRepository'
import { ApiConstants } from '../constants/ApiConstants'
import { LoginModel } from '../model/LoginModel'
import { LogUtil } from '@pura/harmony-utils'

export class LoginRepository extends BaseRepository {
  /**
   * 用户登录
   */
  async login(username: string, password: string): Promise<LoginModel> {
    try {
      const response = await this.httpClient.post<LoginModel>(
        ApiConstants.userLogin(username, password)
      )
      
      // 检查错误码
      if (response.errorCode !== 0) {
        LogUtil.error(`登录失败: ${response.errorMsg}`)
        throw new Error(response.errorMsg || '登录失败')
      }
      
      LogUtil.debug(`登录成功: ${username}`)
      return response.data
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
  
  /**
   * 用户登出
   */
  async logout(): Promise<boolean> {
    try {
      const response = await this.httpClient.get<string>(
        ApiConstants.USER_LOGOUT
      )
      
      if (response.errorCode !== 0) {
        LogUtil.error(`登出失败: ${response.errorMsg}`)
        throw new Error(response.errorMsg || '登出失败')
      }
      
      LogUtil.debug('登出成功')
      return true
    } catch (error) {
      this.handleError(error as ApiError)
      throw error as Error
    }
  }
}
```

#### 在 ViewModel 中使用

```typescript
// LoginViewModel.ets
import { LoginRepository } from '../repository/LoginRepository'
import { LoginModel } from '../model/LoginModel'
import { ErrorHandler } from '../utils/ErrorHandler'

export class LoginViewModel {
  private loginRepo = new LoginRepository()
  
  /**
   * 用户登录
   */
  async login(username: string, password: string): Promise<boolean> {
    try {
      const loginModel: LoginModel = await this.loginRepo.login(username, password)
      // 处理登录成功逻辑
      AccountManager.shared().saveLoginModel(loginModel)
      return true
    } catch (error) {
      ErrorHandler.handle(error, '登录失败')
      return false
    }
  }
}
```

---

### 5.4 拦截器配置

#### Cookie 拦截器

```typescript
// CookieInterceptor.ets
import { AxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'

/**
 * Cookie 拦截器
 * @description 自动添加登录 Cookie 到请求头
 */
export class CookieInterceptor {
  async request(config: AxiosRequestConfig): Promise<AxiosRequestConfig> {
    // 获取 Cookie
    const cookie = getCookieHeaderValue()
    
    if (cookie) {
      if (!config.headers) {
        config.headers = {}
      }
      config.headers['Cookie'] = cookie
      LogUtil.debug(`[CookieInterceptor] 添加 Cookie: ${cookie}`)
    }
    
    return config
  }
}

/**
 * 获取 Cookie Header 值
 */
export function getCookieHeaderValue(): string {
  const accountManager = globalThis.accountManager as IAccountManager
  if (!accountManager) {
    return ''
  }
  
  const loginModel = accountManager.loginModel
  if (!loginModel) {
    return ''
  }
  
  const username = loginModel.username ?? ''
  const password = loginModel.password ?? ''
  
  if (username.length === 0 && password.length === 0) {
    return ''
  }
  
  return `loginUserName=${username};loginUserPassword=${password}`
}
```

#### 日志拦截器

```typescript
// 自动记录请求和响应日志
import { createLoggingInterceptor } from 'network'

const loggingInterceptor = createLoggingInterceptor({
  enabled: true,
  logLevel: 'debug'  // 'debug' | 'info' | 'warn' | 'error'
})
```

---

### 5.5 错误处理

#### ApiError 类型

```typescript
import { ApiError, ApiErrorType } from 'network'

// 错误类型
enum ApiErrorType {
  NETWORK,      // 网络错误
  TIMEOUT,      // 超时错误
  SERVER,       // 服务器错误
  CLIENT,       // 客户端错误
  AUTH,         // 认证错误
  BUSINESS      // 业务错误
}
```

#### 统一错误处理

```typescript
import { ApiError, ApiErrorType } from 'network'

try {
  const data = await repository.getData()
} catch (error) {
  const apiError = error as ApiError
  
  switch (apiError.type) {
    case ApiErrorType.NETWORK:
      ToastUtil.showToast('网络连接失败')
      break
      
    case ApiErrorType.TIMEOUT:
      ToastUtil.showToast('请求超时')
      break
      
    case ApiErrorType.SERVER:
      ToastUtil.showToast('服务器错误')
      break
      
    case ApiErrorType.AUTH:
      // 跳转到登录页
      navPathStack.pushPath({ name: RouterName.Login })
      break
      
    case ApiErrorType.BUSINESS:
      ToastUtil.showToast(apiError.message)
      break
  }
}
```

---

## 六、路由框架

### 6.1 NavPathStack 介绍

#### 核心概念

- **NavPathStack**：HarmonyOS 内置的路由栈
- **routerMap.json**：路由配置文件
- **RouterName**：路由名称枚举
- **拦截器**：登录拦截、权限控制

#### 优势

- ✅ 原生支持，性能优异
- ✅ 支持拦截器
- ✅ 支持参数传递
- ✅ 支持路由栈管理
- ✅ 支持动画配置

#### 与 router.pushUrl 对比

| 特性 | NavPathStack | router.pushUrl |
|------|-------------|----------------|
| 依赖配置 | routerMap.json | @Entry routeName |
| 拦截器 | ✅ 支持 | ❌ 不支持 |
| 参数传递 | ✅ 类型安全 | ⚠️ 弱类型 |
| 路由栈管理 | ✅ 灵活 | ⚠️ 有限 |
| 性能 | ✅ 优异 | ✅ 优异 |

---

### 6.2 路由配置

#### 完整配置流程

**步骤 1：创建页面**

```typescript
// Profile.ets
import { RouterName } from '../router/RouterName'

@Entry({ routeName: RouterName.Profile })
@Component
struct Profile {
  build() {
    NavDestination() {
      Column() {
        Text('个人中心')
      }
    }
  }
}

@Builder
export function ProfileBuilder() {
  Profile()
}
```

**步骤 2：添加 RouterName import**

```typescript
// RouterName.ets
import ("entry/ets/pages/Profile")

export enum RouterName {
  Profile = "Profile"
}
```

**步骤 3：配置 routerMap.json**

```json
// resources/base/profile/routerMap.json
{
  "routerMap": [
    {
      "name": "Profile",
      "pageSourceFile": "src/main/ets/pages/Profile.ets",
      "buildFunction": "ProfileBuilder"
    }
  ]
}
```

**步骤 4：更新 main_pages.json**

```json
// resources/base/profile/main_pages.json
{
  "src": [
    "pages/Profile"
  ]
}
```

---

### 6.3 路由跳转

#### 基本跳转

```typescript
import { navPathStack } from '../router/navPathStack'
import { RouterName } from '../router/RouterName'

// 跳转到指定页面
navPathStack.pushPath({ name: RouterName.Profile })

// 跳转并传参
navPathStack.pushPath({ 
  name: RouterName.WebBrowser,
  param: { 
    id: 123, 
    title: '文章标题',
    url: 'https://example.com'
  }
})

// 返回上一页
navPathStack.pop()

// 返回并传参
navPathStack.pop({ result: 'success', data: userInfo })

// 返回到指定页面
navPathStack.popToName(RouterName.Index)

// 清空路由栈
navPathStack.clear()

// 替换当前页面
navPathStack.replacePath({ name: RouterName.Login })
```

#### 获取路由信息

```typescript
// 获取路由栈长度
const size = navPathStack.size()

// 获取所有路由信息
const allPathName = navPathStack.getAllPathName()

// 获取指定索引的路由信息
const pathInfo = navPathStack.getParamByIndex(0)

// 获取指定名称的路由信息
const pathInfo = navPathStack.getParamByName(RouterName.Profile)
```

---

### 6.4 参数传递

#### 顺传值（父→子）

```typescript
// 发送方
navPathStack.pushPath({ 
  name: RouterName.WebBrowser,
  param: { 
    url: 'https://example.com',
    title: '文章标题'
  }
})

// 接收方
import { NavDestinationContext } from '@kit.ArkUI'

@Entry({ routeName: RouterName.WebBrowser })
@Component
struct WebBrowser {
  @State url: string = ''
  @State title: string = ''
  
  aboutToAppear(): void {
    const context = getContext(this) as NavDestinationContext
    const param = context.pathInfo.param as { url: string, title: string }
    this.url = param.url
    this.title = param.title
  }
  
  build() {
    NavDestination() {
      Column() {
        Text(this.title)
        // ...
      }
    }
  }
}
```

#### 逆传值（子→父）

```typescript
// 子页面：返回时传递数据
@Entry({ routeName: RouterName.Login })
@Component
struct Login {
  build() {
    NavDestination() {
      Button('登录成功')
        .onClick(() => {
          // 返回并传递用户信息
          navPathStack.pop({ 
            result: 'success',
            data: { userId: 123, username: 'user' }
          })
        })
    }
  }
}

// 父页面：接收返回数据
@Entry({ routeName: RouterName.Index })
@Component
struct Index {
  build() {
    NavDestination() {
      Button('跳转登录')
        .onClick(() => {
          navPathStack.pushPath({
            name: RouterName.Login,
            onPop: (popInfo: PopInfo) => {
              // 接收返回值
              if (popInfo.result?.result === 'success') {
                const userData = popInfo.result.data
                console.log('用户ID:', userData.userId)
              }
            }
          })
        })
    }
  }
}
```

---

### 6.5 路由拦截

#### 配置拦截器

```typescript
// navPathStack.ets
import { promptAction } from '@kit.ArkUI'
import AccountManager from '../accountManager/AccountManager'

export const navPathStack: NavPathStack = new NavPathStack()

// 需要登录的页面列表
const AuthNames: string[] = [
  'MyCollect',     // 我的收藏
  'MyCoin',        // 我的积分
  'Setting',       // 设置
  'WebExample',    // Web 示例
  'WebComponent'   // Web 组件
]

// 配置路由拦截器
navPathStack.setInterception({
  willShow(from, to) {
    // 跳过导航栏首页
    if (typeof to === 'string') {
      return
    }
    
    // 防御性检查
    const pageName = to.pathInfo?.name
    if (!pageName) {
      return
    }
    
    // 检查是否需要登录
    if (AuthNames.includes(pageName)) {
      const accountManager = AccountManager.shared()
      if (!accountManager.isLogin()) {
        // 提示用户
        promptAction.showToast({
          message: '当前用户未登录，请先登录'
        })
        
        // 弹出目标页面，跳转到登录页
        to.pathStack.pop()
        to.pathStack.pushPath({
          name: 'Login'
        })
      }
    }
  }
})
```

---

### 6.6 注意事项

#### ⚠️ 常见错误

**1. 忘记配置 routerMap.json**

- **现象**：`navPathStack.pushPath` 无法跳转
- **原因**：routerMap.json 中缺少配置
- **解决**：在 routerMap.json 中添加配置

**2. 忘记添加 RouterName import**

- **现象**：编译错误 `Cannot find name 'RouterName'`
- **原因**：RouterName.ets 中缺少 import
- **解决**：在 RouterName.ets 中添加 `import ("entry/ets/pages/PageName")`

**3. Builder 函数名称不匹配**

- **现象**：运行时错误 `buildFunction does not exist`
- **原因**：Builder 函数名与 routerMap.json 中的 buildFunction 不一致
- **解决**：确保 Builder 函数名 = struct 名 + Builder

**4. 忘记 NavDestination 包裹**

- **现象**：页面无法正常显示
- **原因**：页面内容未用 NavDestination 包裹
- **解决**：用 NavDestination 包裹页面内容

**5. @Entry routeName 不一致**

- **现象**：路由跳转失败
- **原因**：@Entry routeName 与 RouterName 枚举不一致
- **解决**：确保 @Entry routeName 使用 RouterName 枚举

---

#### ✅ 配置检查清单

```markdown
创建新页面时，请检查以下配置：

- [ ] 1. 页面文件创建（如 Profile.ets）
- [ ] 2. @Entry routeName 配置（使用 RouterName 枚举）
- [ ] 3. struct 名称正确（与文件名一致）
- [ ] 4. Builder 函数创建（struct 名 + Builder）
- [ ] 5. RouterName.ets import 添加
- [ ] 6. RouterName.ets 枚举定义
- [ ] 7. routerMap.json 配置
- [ ] 8. main_pages.json 更新
- [ ] 9. NavDestination 包裹
- [ ] 10. 如需登录拦截，添加到 AuthNames 列表
```

---

## 七、ArkTS 最佳实践

### 7.1 状态管理

#### @State vs @Local

```typescript
// @Component 中使用 @State
@Component
struct MyComponent {
  @State count: number = 0
  @State message: string = 'Hello'
  
  build() {
    Column() {
      Text(this.message)
      Button('增加')
        .onClick(() => {
          this.count++  // 触发 UI 更新
        })
    }
  }
}

// @ComponentV2 中使用 @Local
@ComponentV2
struct MyComponentV2 {
  @Local count: number = 0
  @Local message: string = 'Hello'
  
  build() {
    Column() {
      Text(this.message)
      Button('增加')
        .onClick(() => {
          this.count++  // 触发 UI 更新
        })
    }
  }
}
```

#### @Prop vs @Link

```typescript
// @Prop：单向数据流（父→子）
@Component
struct ChildComponent {
  @Prop title: string  // 父组件传入，子组件只读
  
  build() {
    Text(this.title)
  }
}

// 使用
@Component
struct ParentComponent {
  @State title: string = '标题'
  
  build() {
    Column() {
      ChildComponent({ title: this.title })
    }
  }
}

// @Link：双向数据流（父↔子）
@Component
struct ChildComponent {
  @Link count: number  // 父子组件双向同步
  
  build() {
    Button(`计数: ${this.count}`)
      .onClick(() => {
        this.count++  // 修改会影响父组件
      })
  }
}

// 使用
@Component
struct ParentComponent {
  @State count: number = 0
  
  build() {
    Column() {
      Text(`父组件计数: ${this.count}`)
      ChildComponent({ count: $count })  // 使用 $ 语法
    }
  }
}
```

#### @Provide/@Consume

```typescript
// 父组件提供数据
@Component
struct ParentComponent {
  @Provide userInfo: UserInfo = {}
  @Provide theme: string = 'light'
  
  build() {
    Column() {
      ChildComponent()
      GrandchildComponent()
    }
  }
}

// 子组件消费数据（任意层级）
@Component
struct GrandchildComponent {
  @Consume userInfo: UserInfo
  @Consume theme: string
  
  build() {
    Column() {
      Text(this.userInfo.name)
      Text(`主题: ${this.theme}`)
    }
  }
}
```

---

### 7.2 生命周期

#### 组件生命周期

```typescript
@Component
struct MyComponent {
  // 组件即将出现（build 之前）
  aboutToAppear(): void {
    console.log('组件即将出现')
    // 初始化数据
    this.loadData()
  }
  
  // 组件即将消失
  aboutToDisappear(): void {
    console.log('组件即将消失')
    // 清理资源
    this.cleanup()
  }
  
  build() {
    Column() {
      Text('Hello')
    }
  }
}
```

#### 页面生命周期

```typescript
@Entry
struct MyPage {
  // 页面即将显示
  onPageShow(): void {
    console.log('页面即将显示')
    // 刷新数据
    this.refreshData()
  }
  
  // 页面即将隐藏
  onPageHide(): void {
    console.log('页面即将隐藏')
    // 暂停操作
    this.pauseOperations()
  }
  
  // 组件即将出现
  aboutToAppear(): void {
    console.log('组件即将出现')
  }
  
  build() {
    NavDestination() {
      Column() {
        Text('Page')
      }
    }
  }
}
```

---

### 7.3 组件通信

#### 父子组件通信

```typescript
// 父组件
@Component
struct ParentComponent {
  @State count: number = 0
  
  build() {
    Column() {
      Text(`计数: ${this.count}`)
      
      // 传递数据给子组件
      ChildComponent({ 
        count: this.count,
        onCountChange: (newCount: number) => {
          this.count = newCount
        }
      })
    }
  }
}

// 子组件
@Component
struct ChildComponent {
  @Prop count: number
  onCountChange?: (count: number) => void  // 回调函数
  
  build() {
    Row() {
      Button('增加')
        .onClick(() => {
          this.onCountChange?.(this.count + 1)
        })
      
      Button('减少')
        .onClick(() => {
          this.onCountChange?.(this.count - 1)
        })
    }
  }
}
```

#### 跨组件通信（emitter）

```typescript
import { emitter } from '@kit.BasicServicesKit'

// 定义事件
export const LOGIN_SUCCESS_EVENT = "LOGIN_SUCCESS_EVENT"

// 发送事件
emitter.emit(LOGIN_SUCCESS_EVENT, { 
  data: { userId: 123, username: 'user' } 
})

// 接收事件
@Component
struct MyComponent {
  aboutToAppear(): void {
    emitter.on(LOGIN_SUCCESS_EVENT, (data: emitter.EventData) => {
      const userInfo = data.data as { userId: number, username: string }
      console.log('用户登录成功:', userInfo.username)
    })
  }
  
  aboutToDisappear(): void {
    // 取消监听
    emitter.off(LOGIN_SUCCESS_EVENT)
  }
  
  build() {
    Column() {
      Text('Component')
    }
  }
}
```

---

### 7.4 性能优化

#### LazyForEach 使用

```typescript
// 使用 LazyForEach 优化长列表
@Component
struct MyComponent {
  @State dataList: DataItem[] = []
  
  build() {
    List() {
      LazyForEach(
        new MyDataSource(this.dataList),
        (item: DataItem) => {
          ListItem() {
            ItemView({ item: item })
          }
        },
        (item: DataItem) => item.id.toString()  // 唯一键
      )
    }
    .width('100%')
    .height('100%')
  }
}

// 自定义数据源
class MyDataSource implements IDataSource {
  private dataArray: DataItem[] = []
  
  constructor(data: DataItem[]) {
    this.dataArray = data
  }
  
  totalCount(): number {
    return this.dataArray.length
  }
  
  getData(index: number): DataItem {
    return this.dataArray[index]
  }
  
  registerDataChangeListener(listener: DataChangeListener): void {
    // 注册监听器
  }
  
  unregisterDataChangeListener(listener: DataChangeListener): void {
    // 取消监听器
  }
}
```

#### 避免频繁更新

```typescript
// ❌ 错误：频繁更新整个数组
this.dataList = [...this.dataList, newItem]

// ✅ 正确：使用 LazyForEach 的数据源
this.dataSource.addDataItem(newItem)

// ❌ 错误：频繁更新整个对象
this.userInfo = { ...this.userInfo, name: 'newName' }

// ✅ 正确：只更新需要变化的属性
this.userInfo.name = 'newName'
```

#### 条件渲染优化

```typescript
// ❌ 错误：使用 if-else 导致组件重建
if (this.isLoading) {
  LoadingView()
} else {
  ContentView()
}

// ✅ 正确：使用状态控制显示隐藏
LoadingView()
  .visibility(this.isLoading ? Visibility.Visible : Visibility.None)

ContentView()
  .visibility(this.isLoading ? Visibility.None : Visibility.Visible)
```

---

### 7.5 类型安全

#### 避免使用 any

```typescript
// ❌ 错误：使用 any
let data: any = response.data
let result: any = JSON.parse(jsonStr)

// ✅ 正确：使用具体类型
interface Article {
  id: number
  title: string
  author: string
}

let data: Article = response.data
let result: Article = JSON.parse(jsonStr) as Article
```

#### 避免类型断言

```typescript
// ❌ 错误：滥用 as 断言
const article = data as Article
const user = obj as UserInfo

// ✅ 正确：使用类型守卫
function isArticle(data: Object): data is Article {
  return 'id' in data && 'title' in data && 'author' in data
}

function isUserInfo(obj: Object): obj is UserInfo {
  return 'userId' in obj && 'username' in obj
}

if (isArticle(data)) {
  // 安全使用 data
  console.log(data.title)
}

if (isUserInfo(obj)) {
  // 安全使用 obj
  console.log(obj.username)
}
```

#### 使用接口定义类型

```typescript
// ✅ 正确：定义清晰的接口
interface ApiResponse<T> {
  data: T
  errorCode: number
  errorMsg: string
}

interface UserInfo {
  userId: number
  username: string
  email?: string  // 可选属性
}

// 使用泛型
const response: ApiResponse<Article[]> = await httpClient.get('/articles')
```

---

## 八、常见问题与调试

### 8.1 编译错误

#### arkts-no-standalone-this

**错误信息**：
```
ArkTS: Cannot use 'this' in standalone function
```

**原因**：在静态方法或独立函数中使用 this

**解决方案**：

```typescript
// ❌ 错误
class MyClass {
  private httpClient: HttpClient = getHttpClient()
  
  static function getData() {
    return this.httpClient.get()  // this 不存在
  }
}

// ✅ 正确
class MyClass {
  static function getData() {
    return getHttpClient().get()  // 使用全局函数
  }
}
```

#### arkts-no-obj-literals-as-types

**错误信息**：
```
Object literals cannot be used as type declarations
```

**原因**：使用对象字面量作为类型

**解决方案**：

```typescript
// ❌ 错误
interface IAccountManager {
  loginModel?: {
    username?: string
    password?: string
  }
}

// ✅ 正确
interface ILoginModel {
  username?: string
  password?: string
}

interface IAccountManager {
  loginModel?: ILoginModel
}
```

#### arkts-no-any

**错误信息**：
```
ArkTS: Use of 'any' is not allowed
```

**原因**：使用了 any 类型

**解决方案**：

```typescript
// ❌ 错误
let data: any = response.data

// ✅ 正确
interface Article {
  id: number
  title: string
}
let data: Article = response.data
```

---

### 8.2 运行时错误

#### 页面无法跳转

**现象**：`navPathStack.pushPath` 无反应

**排查步骤**：

1. 检查 routerMap.json 是否配置
2. 检查 RouterName 是否定义
3. 检查 Builder 函数是否存在
4. 检查 main_pages.json 是否更新
5. 检查 @Entry routeName 是否正确

**解决方案**：参考 [路由配置检查清单](#66-注意事项)

#### 数据不更新

**现象**：修改数据后 UI 不刷新

**原因**：
- 未使用状态装饰器
- 直接修改数组/对象

**解决方案**：

```typescript
// ❌ 错误：直接修改数组
this.list.push(newItem)

// ✅ 正确：创建新数组
this.list = [...this.list, newItem]

// ❌ 错误：直接修改对象属性
this.user.name = 'newName'

// ✅ 正确：创建新对象
this.user = { ...this.user, name: 'newName' }
```

---

### 8.3 路由问题

#### 路由配置缺失

**检查清单**：

```markdown
1. 页面文件是否存在
   - 检查路径：entry/src/main/ets/pages/PageName.ets

2. @Entry routeName 是否配置
   - 检查：@Entry({ routeName: RouterName.PageName })

3. RouterName.ets 是否有 import
   - 检查：import ("entry/ets/pages/PageName")

4. RouterName.ets 是否有枚举定义
   - 检查：PageName = "PageName"

5. routerMap.json 是否有配置
   - 检查：
     {
       "name": "PageName",
       "pageSourceFile": "src/main/ets/pages/PageName.ets",
       "buildFunction": "PageNameBuilder"
     }

6. main_pages.json 是否有路径
   - 检查："pages/PageName"

7. Builder 函数是否存在
   - 检查：export function PageNameBuilder()

8. NavDestination 是否包裹
   - 检查：build() { NavDestination() { ... } }
```

---

### 8.4 网络问题

#### 请求失败

**排查步骤**：

1. 检查网络权限
   ```json5
   // module.json5
   {
     "module": {
       "requestPermissions": [
         {
           "name": "ohos.permission.INTERNET"
         }
       ]
     }
   }
   ```

2. 检查 URL 是否正确
3. 检查参数格式
4. 查看日志输出

#### Cookie 未携带

**原因**：CookieInterceptor 未正确配置

**解决方案**：

```typescript
// EntryAbility.ets
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  // 设置 globalThis.accountManager（Cookie 拦截器需要）
  globalThis.accountManager = AccountManager.shared()
}
```

---

### 8.5 调试技巧

#### 日志输出

```typescript
import { LogUtil } from '@pura/harmony-utils'

// 不同级别的日志
LogUtil.debug('调试信息')    // 开发调试
LogUtil.info('一般信息')     // 重要信息
LogUtil.warn('警告信息')     // 警告提示
LogUtil.error('错误信息')    // 错误记录

// 带标签的日志
LogUtil.debug('[MyComponent] 数据加载完成')
LogUtil.error('[Network] 请求失败: ' + error.message)
```

#### 断点调试

1. 在 DevEco Studio 中设置断点
2. 点击调试按钮（虫子图标）
3. 查看变量值和调用栈
4. 单步执行、继续执行

#### 网络请求调试

```typescript
// 开启日志拦截器
const loggingInterceptor = createLoggingInterceptor({
  enabled: true,
  logLevel: 'debug'
})

// 查看请求和响应日志
// 输出示例：
// [LoggingInterceptor] Request: GET /article/list/0/json
// [LoggingInterceptor] Response: 200 OK, 1234ms
```

---

## 九、附录

### 9.1 技术栈说明

| 技术 | 版本 | 用途 |
|------|------|------|
| **ArkTS** | - | HarmonyOS 官方开发语言 |
| **ArkUI** | - | 声明式 UI 框架 |
| **@ohos/axios** | 2.2.14 | HTTP 网络请求 |
| **@ohos/pulltorefresh** | 3.0.1 | 下拉刷新组件 |
| **@ohos/imageknife** | 3.2.10 | 图片加载缓存 |
| **@pura/harmony-utils** | 1.4.2 | 工具类库 |
| **@dcloudio/uni-app-runtime** | 5.2.3 | UniApp 运行时 |

---

### 9.2 参考链接

#### 官方文档

- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/)
- [ArkTS 语言指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-started-V5)
- [ArkUI 组件参考](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/arkui-overview-V5)

#### 项目文档

- [网络请求使用指南](./NETWORK_USAGE.md)
- [路由设计文档](./navpathstack-design.md)
- [业务模块化架构设计](./business-module-architecture-design.md)

---

### 9.3 更新日志

#### v2.0 (2026-08-19)

**路由框架治理**：
- ✅ 统一页面命名规范（移除 Page 后缀）
- ✅ 完善 routerMap.json 配置
- ✅ 统一 @Entry routeName 使用方式
- ✅ 更新路由跳转代码

**网络层迁移**：
- ✅ 创建 network 模块
- ✅ 实现 Repository 模式
- ✅ 添加 Cookie 拦截器
- ✅ 统一错误处理

**代码质量**：
- ✅ 修复类型安全问题
- ✅ 统一错误处理策略
- ✅ 优化代码结构

#### v1.0 (2026-02-03)

- ✅ 初始版本发布
- ✅ 基础功能实现
- ✅ MVVM 架构搭建

---

## 结语

本开发指南将持续更新，如有疑问或建议，请提交 Issue 或 Pull Request。

**Happy Coding! 🎉**
